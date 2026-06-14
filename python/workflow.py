from __future__ import annotations

import threading
import time
from enum import Enum
from typing import Any, Callable, Optional

from config import STEP_TYPE_LABELS
from cutting_master import send_cut_job
from serial_stm32 import Stm32Client, wait_ms


def _send_cut_budget_ms(timings: dict[str, Any]) -> int:
    return (
        int(timings.get("before_send_keys", 0))
        + int(timings.get("after_focus_ms", 0))
        + int(timings.get("after_hotkey_ms", 0))
    )


def _invoke_send_cut_job(cm: dict[str, Any], timings: dict[str, Any]) -> str:
    return send_cut_job(
        cm["window_title_contains"],
        cm["send_hotkey"],
        int(timings.get("before_send_keys", 0)),
        int(timings.get("after_focus_ms", 0)),
        int(timings.get("after_hotkey_ms", 0)),
    )


class Phase(str, Enum):
    IDLE = "idle"
    DONE = "done"
    ABORTED = "aborted"


def _enabled_steps(config: dict[str, Any]) -> list[dict[str, Any]]:
    steps = config.get("workflow_steps") or []
    return [step for step in steps if step.get("enabled") is True]


def _step_duration_ms(step: dict[str, Any], timings: dict[str, Any], *, simulate_cut: bool) -> int:
    step_type = step.get("type")
    if step_type == "retract":
        return int(timings["retract"])
    if step_type == "extend":
        return int(timings["extend"])
    if step_type == "pulse_a" or step_type == "pulse_b":
        return int(timings["relay_pulse"]) + 30
    if step_type == "cut_wait":
        return int(timings["cut_wait"])
    if step_type == "send_cut":
        if simulate_cut:
            return 0
        return _send_cut_budget_ms(timings)
    if step_type == "wait":
        return int(step.get("duration_ms", 0))
    return 0


def _cycle_total_ms(config: dict[str, Any], *, simulate_cut: bool) -> int:
    timings = config["timings_ms"]
    return sum(
        _step_duration_ms(step, timings, simulate_cut=simulate_cut)
        for step in _enabled_steps(config)
    )


class WorkflowRunner:
    def __init__(self, emit: Callable[[dict[str, Any]], None], client_lock: threading.Lock | None = None):
        self._emit = emit
        self._client_lock = client_lock or threading.RLock()
        self._thread: Optional[threading.Thread] = None
        self._cancel = threading.Event()
        self._client: Optional[Stm32Client] = None
        self._phase = Phase.IDLE
        self._running = False
        self._simulation = False
        self._simulate_cut = True
        self._auto_loop = False
        self._loop_interval_ms = 0
        self._active_step_id: str | None = None

    @property
    def phase(self) -> Phase:
        return self._phase

    @property
    def running(self) -> bool:
        return self._running

    def attach_client(self, client: Optional[Stm32Client]) -> None:
        with self._client_lock:
            self._client = client

    def set_mode(self, simulation: bool, simulate_cut: bool) -> None:
        self._simulation = simulation
        self._simulate_cut = simulate_cut

    def start_cycle(self, config: dict[str, Any]) -> None:
        if self._running:
            raise RuntimeError("流程正在运行")
        with self._client_lock:
            if self._client is None or not self._client.connected:
                raise RuntimeError("请先连接（模拟或真实串口）")

        enabled = _enabled_steps(config)
        if not enabled:
            raise RuntimeError("请至少启用一个流程步骤")

        app_cfg = config.get("app", {})
        self._simulation = bool(app_cfg.get("simulation_mode", False))
        self._simulate_cut = bool(app_cfg.get("simulate_cut", True))
        self._auto_loop = bool(app_cfg.get("auto_loop", False))
        self._loop_interval_ms = int(app_cfg.get("loop_interval_ms", 0))

        self._cancel.clear()
        self._running = True
        self._thread = threading.Thread(
            target=self._run_cycle,
            args=(config,),
            daemon=True,
            name="cutppaper-workflow",
        )
        self._thread.start()

    def estop(self) -> None:
        self._cancel.set()
        with self._client_lock:
            if self._client is not None:
                self._client.estop()
        self._set_phase(Phase.ABORTED, "已执行急停")

    def test_step(self, step: str, config: dict[str, Any], *, duration_ms: int | None = None) -> None:
        if self._running:
            raise RuntimeError("流程正在运行，无法单步测试")
        with self._client_lock:
            if self._client is None or not self._client.connected:
                raise RuntimeError("请先连接")

        app_cfg = config.get("app", {})
        self._simulation = bool(app_cfg.get("simulation_mode", False))
        self._simulate_cut = bool(app_cfg.get("simulate_cut", True))

        timings = config["timings_ms"]
        cm = config["cutting_master"]

        if step == "retract":
            with self._client_lock:
                self._client.retract()
            wait_ms(timings["retract"], threading.Event())
            with self._client_lock:
                self._client.stop()
        elif step == "extend":
            with self._client_lock:
                self._client.extend()
            wait_ms(timings["extend"], threading.Event())
            with self._client_lock:
                self._client.stop()
        elif step == "pulse_a":
            with self._client_lock:
                self._client.pulse_a(timings["relay_pulse"])
            wait_ms(timings["relay_pulse"] + 50, threading.Event())
        elif step == "pulse_b":
            with self._client_lock:
                self._client.pulse_b(timings["relay_pulse"])
            wait_ms(timings["relay_pulse"] + 50, threading.Event())
        elif step == "send_cut":
            if self._simulation and self._simulate_cut:
                self._emit_log("info", "[模拟] 跳过 Cutting Master Ctrl+P")
            else:
                title = _invoke_send_cut_job(cm, timings)
                self._emit_log("info", f"已向窗口发送 {cm['send_hotkey']}: {title}")
                self._emit({"event": "cut_hotkey_sent", "title": title, "hotkey": cm["send_hotkey"]})
        elif step == "cut_wait":
            wait_ms(timings["cut_wait"], threading.Event())
        elif step == "wait":
            wait_ms(int(duration_ms or 1000), threading.Event())
        else:
            raise ValueError(f"未知测试步骤: {step}")

    def _run_cycle(self, config: dict[str, Any]) -> None:
        loop_index = 0
        try:
            while True:
                loop_index += 1
                if loop_index > 1:
                    self._emit(
                        {
                            "event": "cycle_looped",
                            "loop_index": loop_index,
                        }
                    )
                    self._emit_log("info", f"开始第 {loop_index} 轮")

                self._run_one_cycle(config, loop_index)

                if self._cancel.is_set():
                    self._set_phase(Phase.ABORTED, "流程已中止")
                    self._emit({"event": "cycle_aborted", "loop_index": loop_index})
                    break

                if not self._auto_loop:
                    self._emit({"event": "cycle_done", "loop_index": loop_index, "will_repeat": False})
                    break

                self._emit(
                    {
                        "event": "cycle_done",
                        "loop_index": loop_index,
                        "will_repeat": True,
                        "loop_interval_ms": self._loop_interval_ms,
                    }
                )

                if not self._wait_loop_interval():
                    self._set_phase(Phase.ABORTED, "流程已中止")
                    self._emit({"event": "cycle_aborted", "loop_index": loop_index})
                    break
        except Exception as exc:
            if self._cancel.is_set():
                self._set_phase(Phase.ABORTED, "流程已中止")
                self._emit({"event": "cycle_aborted", "loop_index": loop_index})
            else:
                self._emit({"event": "error", "message": str(exc)})
                self._set_phase(Phase.ABORTED, str(exc))
        finally:
            self._running = False
            self._active_step_id = None

    def _wait_loop_interval(self) -> bool:
        duration_ms = self._loop_interval_ms
        if duration_ms <= 0:
            return not self._cancel.is_set()

        self._emit(
            {
                "event": "loop_wait",
                "duration_ms": duration_ms,
                "message": f"轮间等待 {duration_ms} ms",
            }
        )
        self._set_phase(Phase.DONE, f"等待下一轮（{duration_ms} ms）")

        def on_tick(elapsed_ms: int, total_ms: int) -> None:
            self._emit(
                {
                    "event": "loop_wait_tick",
                    "elapsed_ms": elapsed_ms,
                    "total_ms": total_ms,
                    "remaining_ms": max(0, total_ms - elapsed_ms),
                }
            )

        return wait_ms(duration_ms, self._cancel, on_tick)

    def _run_one_cycle(self, config: dict[str, Any], loop_index: int) -> None:
        timings = config["timings_ms"]
        cm = config["cutting_master"]
        simulate_cut = self._simulation and self._simulate_cut
        total_ms = _cycle_total_ms(config, simulate_cut=simulate_cut)
        cycle_start = time.monotonic()
        steps = _enabled_steps(config)

        for step in steps:
            self._execute_step(step, cm, timings, total_ms, cycle_start, simulate_cut)

        label = f"第 {loop_index} 轮完成" if self._auto_loop else "本轮完成"
        self._active_step_id = None
        self._set_phase(Phase.DONE, label)

    def _execute_step(
        self,
        step: dict[str, Any],
        cm: dict[str, Any],
        timings: dict[str, Any],
        total_ms: int,
        cycle_start: float,
        simulate_cut: bool,
    ) -> None:
        step_id = str(step.get("id", ""))
        step_type = str(step.get("type", ""))
        label = str(step.get("label") or STEP_TYPE_LABELS.get(step_type, step_type))
        self._active_step_id = step_id
        self._set_step(step_id, step_type, label)

        if step_type == "retract":
            self._do_retract(timings["retract"], step_id, step_type, label, total_ms, cycle_start)
        elif step_type == "pulse_a":
            self._do_pulse_a(timings["relay_pulse"], step_id, step_type, label, total_ms, cycle_start)
        elif step_type == "send_cut":
            self._do_send_cut(cm, timings, step_id, step_type, label, total_ms, cycle_start, simulate_cut)
        elif step_type == "cut_wait":
            self._do_wait(timings["cut_wait"], step_id, step_type, label, total_ms, cycle_start)
        elif step_type == "extend":
            self._do_extend(timings["extend"], step_id, step_type, label, total_ms, cycle_start)
        elif step_type == "pulse_b":
            self._do_pulse_b(timings["relay_pulse"], step_id, step_type, label, total_ms, cycle_start)
        elif step_type == "wait":
            self._do_wait(int(step.get("duration_ms", 0)), step_id, step_type, label, total_ms, cycle_start)
        else:
            raise RuntimeError(f"未知步骤类型: {step_type}")

    def _ensure_client(self) -> Stm32Client:
        with self._client_lock:
            if self._client is None:
                raise RuntimeError("未连接")
            return self._client

    def _do_retract(
        self,
        duration_ms: int,
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
    ) -> None:
        with self._client_lock:
            self._ensure_client().retract()
        if not self._wait(duration_ms, step_id, step_type, label, total_ms, cycle_start):
            with self._client_lock:
                self._ensure_client().stop()
            raise RuntimeError("缩回阶段被中止")
        with self._client_lock:
            self._ensure_client().stop()

    def _do_pulse_a(
        self,
        duration_ms: int,
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
    ) -> None:
        with self._client_lock:
            self._ensure_client().pulse_a(duration_ms)
        if not self._wait(duration_ms + 30, step_id, step_type, label, total_ms, cycle_start):
            raise RuntimeError("继电器A 阶段被中止")

    def _do_send_cut(
        self,
        cm: dict[str, Any],
        timings: dict[str, int],
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
        simulate_cut: bool,
    ) -> None:
        if simulate_cut:
            self._emit_log("info", "[模拟] 跳过 Cutting Master Ctrl+P")
        else:
            title = _invoke_send_cut_job(cm, timings)
            self._emit_log("info", f"已发送 {cm['send_hotkey']} -> {title}")
            self._emit({"event": "cut_hotkey_sent", "title": title, "hotkey": cm["send_hotkey"]})
        elapsed = int((time.monotonic() - cycle_start) * 1000)
        self._emit_progress(step_id, step_type, label, elapsed, total_ms, "切割任务已发送")

    def _do_wait(
        self,
        duration_ms: int,
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
    ) -> None:
        if not self._wait(duration_ms, step_id, step_type, label, total_ms, cycle_start):
            raise RuntimeError(f"{label} 被中止")

    def _do_extend(
        self,
        duration_ms: int,
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
    ) -> None:
        with self._client_lock:
            self._ensure_client().extend()
        if not self._wait(duration_ms, step_id, step_type, label, total_ms, cycle_start):
            with self._client_lock:
                self._ensure_client().stop()
            raise RuntimeError("伸出阶段被中止")
        with self._client_lock:
            self._ensure_client().stop()

    def _do_pulse_b(
        self,
        duration_ms: int,
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
    ) -> None:
        with self._client_lock:
            self._ensure_client().pulse_b(duration_ms)
        if not self._wait(duration_ms + 30, step_id, step_type, label, total_ms, cycle_start):
            raise RuntimeError("继电器B 阶段被中止")

    def _wait(
        self,
        duration_ms: int,
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
    ) -> bool:
        def on_tick(_elapsed_step_ms: int, _step_total_ms: int) -> None:
            elapsed_cycle_ms = int((time.monotonic() - cycle_start) * 1000)
            self._emit_progress(step_id, step_type, label, elapsed_cycle_ms, total_ms, label)

        return wait_ms(duration_ms, self._cancel, on_tick)

    def _set_phase(self, phase: Phase, message: str) -> None:
        self._phase = phase
        self._emit(
            {
                "event": "state",
                "phase": phase.value,
                "phase_label": message,
                "message": message,
                "step_id": self._active_step_id,
            }
        )
        level = "warn" if phase == Phase.ABORTED else "info"
        self._emit_log(level, message)

    def _set_step(self, step_id: str, step_type: str, label: str) -> None:
        self._emit(
            {
                "event": "state",
                "phase": step_type,
                "phase_label": label,
                "message": label,
                "step_id": step_id,
            }
        )
        self._emit_log("info", label)

    def _emit_progress(
        self,
        step_id: str,
        step_type: str,
        label: str,
        elapsed_ms: int,
        total_ms: int,
        message: str,
    ) -> None:
        self._emit(
            {
                "event": "progress",
                "phase": step_type,
                "phase_label": label,
                "step_id": step_id,
                "elapsed_ms": elapsed_ms,
                "total_ms": total_ms,
                "progress": min(1.0, elapsed_ms / total_ms) if total_ms else 0,
                "message": message,
            }
        )

    def _emit_log(self, level: str, message: str) -> None:
        self._emit({"event": "log", "level": level, "message": message})
