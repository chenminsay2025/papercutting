from __future__ import annotations

import threading
import time
from enum import Enum
from typing import Any, Callable, Optional

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
    RETRACT = "2-1_retract"
    PULSE_A = "2-2_continue"
    SEND_CUT = "2-3_send"
    CUT_WAIT = "2-3_wait"
    EXTEND = "3_extend"
    PULSE_B = "4_origin"
    DONE = "done"
    ABORTED = "aborted"


PHASE_LABELS = {
    Phase.IDLE: "空闲",
    Phase.RETRACT: "2-1 伸缩杆缩回",
    Phase.PULSE_A: "2-2 继电器A（继续）",
    Phase.SEND_CUT: "2-3 发送切割任务",
    Phase.CUT_WAIT: "2-3 等待切割",
    Phase.EXTEND: "3 伸缩杆伸出",
    Phase.PULSE_B: "4 继电器B（原点）",
    Phase.DONE: "本轮完成",
    Phase.ABORTED: "已中止",
}


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

        app_cfg = config.get("app", {})
        self._simulation = bool(app_cfg.get("simulation_mode", False))
        self._simulate_cut = bool(app_cfg.get("simulate_cut", True))

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

    def test_step(self, step: str, config: dict[str, Any]) -> None:
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
        else:
            raise ValueError(f"未知测试步骤: {step}")

    def _run_cycle(self, config: dict[str, Any]) -> None:
        timings = config["timings_ms"]
        cm = config["cutting_master"]
        total_ms = (
            timings["retract"]
            + timings["relay_pulse"]
            + _send_cut_budget_ms(timings)
            + timings["cut_wait"]
            + timings["extend"]
            + timings["relay_pulse"]
        )
        if self._simulation and self._simulate_cut:
            total_ms -= _send_cut_budget_ms(timings)
        cycle_start = time.monotonic()

        try:
            self._step_retract(timings["retract"], total_ms, cycle_start)
            self._step_pulse_a(timings["relay_pulse"], total_ms, cycle_start)
            self._step_send_cut(cm, timings, total_ms, cycle_start)
            self._step_cut_wait(timings["cut_wait"], total_ms, cycle_start)
            self._step_extend(timings["extend"], total_ms, cycle_start)
            self._step_pulse_b(timings["relay_pulse"], total_ms, cycle_start)

            self._set_phase(Phase.DONE, "本轮完成")
            self._emit({"event": "cycle_done"})
        except Exception as exc:
            if self._cancel.is_set():
                self._set_phase(Phase.ABORTED, "流程已中止")
                self._emit({"event": "cycle_aborted"})
            else:
                self._emit({"event": "error", "message": str(exc)})
                self._set_phase(Phase.ABORTED, str(exc))
        finally:
            self._running = False

    def _ensure_client(self) -> Stm32Client:
        with self._client_lock:
            if self._client is None:
                raise RuntimeError("未连接")
            return self._client

    def _step_retract(self, duration_ms: int, total_ms: int, cycle_start: float) -> None:
        self._set_phase(Phase.RETRACT, "开始缩回")
        with self._client_lock:
            self._ensure_client().retract()
        if not self._wait(duration_ms, Phase.RETRACT, total_ms, cycle_start):
            with self._client_lock:
                self._ensure_client().stop()
            raise RuntimeError("缩回阶段被中止")
        with self._client_lock:
            self._ensure_client().stop()

    def _step_pulse_a(self, duration_ms: int, total_ms: int, cycle_start: float) -> None:
        self._set_phase(Phase.PULSE_A, "继电器A 脉冲（继续）")
        with self._client_lock:
            self._ensure_client().pulse_a(duration_ms)
        if not self._wait(duration_ms + 30, Phase.PULSE_A, total_ms, cycle_start):
            raise RuntimeError("继电器A 阶段被中止")

    def _step_send_cut(self, cm: dict[str, Any], timings: dict[str, int], total_ms: int, cycle_start: float) -> None:
        self._set_phase(Phase.SEND_CUT, "激活 Cutting Master 4")
        if self._simulation and self._simulate_cut:
            self._emit_log("info", "[模拟] 跳过 Cutting Master Ctrl+P")
        else:
            title = _invoke_send_cut_job(cm, timings)
            self._emit_log("info", f"已发送 {cm['send_hotkey']} -> {title}")
            self._emit({"event": "cut_hotkey_sent", "title": title, "hotkey": cm["send_hotkey"]})
        elapsed = int((time.monotonic() - cycle_start) * 1000)
        self._emit_progress(Phase.SEND_CUT, elapsed, total_ms, "切割任务已发送")

    def _step_cut_wait(self, duration_ms: int, total_ms: int, cycle_start: float) -> None:
        self._set_phase(Phase.CUT_WAIT, "等待切割完成")
        if not self._wait(duration_ms, Phase.CUT_WAIT, total_ms, cycle_start):
            raise RuntimeError("切割等待阶段被中止")

    def _step_extend(self, duration_ms: int, total_ms: int, cycle_start: float) -> None:
        self._set_phase(Phase.EXTEND, "开始伸出")
        with self._client_lock:
            self._ensure_client().extend()
        if not self._wait(duration_ms, Phase.EXTEND, total_ms, cycle_start):
            with self._client_lock:
                self._ensure_client().stop()
            raise RuntimeError("伸出阶段被中止")
        with self._client_lock:
            self._ensure_client().stop()

    def _step_pulse_b(self, duration_ms: int, total_ms: int, cycle_start: float) -> None:
        self._set_phase(Phase.PULSE_B, "继电器B 脉冲（原点）")
        with self._client_lock:
            self._ensure_client().pulse_b(duration_ms)
        if not self._wait(duration_ms + 30, Phase.PULSE_B, total_ms, cycle_start):
            raise RuntimeError("继电器B 阶段被中止")

    def _wait(self, duration_ms: int, phase: Phase, total_ms: int, cycle_start: float) -> bool:
        def on_tick(_elapsed_step_ms: int, _step_total_ms: int) -> None:
            elapsed_cycle_ms = int((time.monotonic() - cycle_start) * 1000)
            self._emit_progress(phase, elapsed_cycle_ms, total_ms, PHASE_LABELS[phase])

        return wait_ms(duration_ms, self._cancel, on_tick)

    def _set_phase(self, phase: Phase, message: str) -> None:
        self._phase = phase
        self._emit(
            {
                "event": "state",
                "phase": phase.value,
                "phase_label": PHASE_LABELS[phase],
                "message": message,
            }
        )
        level = "warn" if phase == Phase.ABORTED else "info"
        self._emit_log(level, message)

    def _emit_progress(self, phase: Phase, elapsed_ms: int, total_ms: int, message: str) -> None:
        self._emit(
            {
                "event": "progress",
                "phase": phase.value,
                "phase_label": PHASE_LABELS[phase],
                "elapsed_ms": elapsed_ms,
                "total_ms": total_ms,
                "progress": min(1.0, elapsed_ms / total_ms) if total_ms else 0,
                "message": message,
            }
        )

    def _emit_log(self, level: str, message: str) -> None:
        self._emit({"event": "log", "level": level, "message": message})
