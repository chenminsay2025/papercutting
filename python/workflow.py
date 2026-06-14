from __future__ import annotations

import threading
import time
from enum import Enum
from typing import Any, Callable, Optional

from config import STEP_TYPE_LABELS
from cutting_master import focus_window_step, press_hotkey_step
from serial_stm32 import Stm32Client, wait_ms


def _step_duration_ms(step: dict[str, Any], timings: dict[str, Any], *, simulate_cut: bool) -> int:
    step_type = step.get("type")
    if step_type == "focus_window":
        if simulate_cut:
            return 0
        return int(step.get("focus_timeout_ms", timings.get("before_send_keys", 0)))
    if step_type == "send_hotkey":
        if simulate_cut:
            return 0
        return int(step.get("delay_before_ms", timings.get("after_focus_ms", 0))) + int(
            step.get("delay_after_ms", timings.get("after_hotkey_ms", 0))
        )
    if step_type in ("pulse_a", "pulse_b"):
        return int(step.get("duration_ms", timings.get("relay_pulse", 0))) + 30
    if step_type in ("retract", "extend", "cut_wait", "wait"):
        legacy_key = {
            "retract": "retract",
            "extend": "extend",
            "cut_wait": "cut_wait",
        }.get(step_type, step_type)
        return int(step.get("duration_ms", timings.get(legacy_key, 0)))
    return 0


class Phase(str, Enum):
    IDLE = "idle"
    DONE = "done"
    ABORTED = "aborted"
    WAITING_USER = "waiting_user"


class WorkflowUserAbort(Exception):
    """用户选择停止流程。"""


PROMPT_RETRY = "retry"
PROMPT_SKIP = "skip"
PROMPT_ABORT = "abort"


def _enabled_steps(config: dict[str, Any]) -> list[dict[str, Any]]:
    steps = config.get("workflow_steps") or []
    return [step for step in steps if step.get("enabled") is True]


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
        self._prompt_lock = threading.Lock()
        self._prompt_event = threading.Event()
        self._pending_prompt_id: str | None = None
        self._prompt_result: str | None = None

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
        self._resolve_prompt_locked(PROMPT_ABORT)
        with self._client_lock:
            if self._client is not None:
                self._client.estop()
        self._set_phase(Phase.ABORTED, "已执行急停")

    def resolve_prompt(self, prompt_id: str, action: str) -> None:
        normalized = str(action or PROMPT_ABORT).strip().lower()
        if normalized not in (PROMPT_RETRY, PROMPT_SKIP, PROMPT_ABORT):
            raise ValueError(f"无效的 prompt 动作: {action}")
        with self._prompt_lock:
            if self._pending_prompt_id != prompt_id:
                raise RuntimeError("确认请求已过期或不存在")
            self._prompt_result = normalized
            self._prompt_event.set()

    def test_step(
        self,
        step: str,
        config: dict[str, Any],
        *,
        workflow_step: dict[str, Any] | None = None,
        duration_ms: int | None = None,
    ) -> None:
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
        wf_step = workflow_step or {}

        if step == "retract":
            ms = int(wf_step.get("duration_ms", duration_ms or timings["retract"]))
            with self._client_lock:
                self._client.retract()
            wait_ms(ms, threading.Event())
            with self._client_lock:
                self._client.stop()
        elif step == "extend":
            ms = int(wf_step.get("duration_ms", duration_ms or timings["extend"]))
            with self._client_lock:
                self._client.extend()
            wait_ms(ms, threading.Event())
            with self._client_lock:
                self._client.stop()
        elif step == "pulse_a":
            ms = int(wf_step.get("duration_ms", duration_ms or timings["relay_pulse"]))
            with self._client_lock:
                self._client.pulse_a(ms)
            wait_ms(ms + 50, threading.Event())
        elif step == "pulse_b":
            ms = int(wf_step.get("duration_ms", duration_ms or timings["relay_pulse"]))
            with self._client_lock:
                self._client.pulse_b(ms)
            wait_ms(ms + 50, threading.Event())
        elif step == "focus_window":
            if self._simulation and self._simulate_cut:
                self._emit_log("info", "[模拟] 跳过获取窗口")
            else:
                keyword = str(wf_step.get("window_keyword") or cm.get("window_title_contains", "")).strip()
                timeout_ms = int(wf_step.get("focus_timeout_ms", timings.get("before_send_keys", 800)))
                title = focus_window_step(keyword, timeout_ms)
                self._emit_log("info", f"已激活窗口: {title}")
        elif step == "send_hotkey":
            if self._simulation and self._simulate_cut:
                self._emit_log("info", "[模拟] 跳过发送快捷键")
            else:
                hotkey = str(wf_step.get("hotkey") or cm.get("send_hotkey", "")).strip()
                press_hotkey_step(
                    hotkey,
                    int(wf_step.get("delay_before_ms", timings.get("after_focus_ms", 0))),
                    int(wf_step.get("delay_after_ms", timings.get("after_hotkey_ms", 0))),
                )
                self._emit_log("info", f"已发送快捷键: {hotkey}")
                self._emit({"event": "cut_hotkey_sent", "title": "", "hotkey": hotkey})
        elif step == "cut_wait":
            ms = int(wf_step.get("duration_ms", duration_ms or timings["cut_wait"]))
            wait_ms(ms, threading.Event())
        elif step == "wait":
            wait_ms(int(wf_step.get("duration_ms", duration_ms or 1000)), threading.Event())
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
        except WorkflowUserAbort:
            self._set_phase(Phase.ABORTED, "流程已停止")
            self._emit({"event": "cycle_aborted", "loop_index": loop_index})
        except Exception as exc:
            if self._cancel.is_set():
                self._set_phase(Phase.ABORTED, "流程已中止")
                self._emit({"event": "cycle_aborted", "loop_index": loop_index})
            else:
                action = self._prompt_user(exc, {"id": "", "type": "cycle"}, "流程异常")
                if action == PROMPT_RETRY and not self._cancel.is_set():
                    self._emit_log("info", "用户要求重试，请再次点击开始")
                else:
                    self._set_phase(Phase.ABORTED, str(exc))
                    self._emit({"event": "cycle_aborted", "loop_index": loop_index, "message": str(exc)})
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
            label = str(step.get("label") or STEP_TYPE_LABELS.get(step.get("type", ""), step.get("type", "")))
            while True:
                try:
                    self._execute_step(step, cm, timings, total_ms, cycle_start, simulate_cut)
                    break
                except Exception as exc:
                    if self._should_fail_immediately(exc):
                        raise
                    action = self._prompt_user(exc, step, label)
                    if action == PROMPT_RETRY:
                        self._emit_log("info", f"重试步骤: {label}")
                        continue
                    if action == PROMPT_SKIP:
                        self._emit_log("warn", f"已跳过步骤: {label}")
                        break
                    raise WorkflowUserAbort(str(exc)) from exc

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
            self._do_retract(int(step.get("duration_ms", timings["retract"])), step_id, step_type, label, total_ms, cycle_start)
        elif step_type == "pulse_a":
            self._do_pulse_a(int(step.get("duration_ms", timings["relay_pulse"])), step_id, step_type, label, total_ms, cycle_start)
        elif step_type == "focus_window":
            self._do_focus_window(step, cm, timings, step_id, step_type, label, total_ms, cycle_start, simulate_cut)
        elif step_type == "send_hotkey":
            self._do_send_hotkey(step, cm, timings, step_id, step_type, label, total_ms, cycle_start, simulate_cut)
        elif step_type == "cut_wait":
            self._do_wait(int(step.get("duration_ms", timings["cut_wait"])), step_id, step_type, label, total_ms, cycle_start)
        elif step_type == "extend":
            self._do_extend(int(step.get("duration_ms", timings["extend"])), step_id, step_type, label, total_ms, cycle_start)
        elif step_type == "pulse_b":
            self._do_pulse_b(int(step.get("duration_ms", timings["relay_pulse"])), step_id, step_type, label, total_ms, cycle_start)
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

    def _do_focus_window(
        self,
        step: dict[str, Any],
        cm: dict[str, Any],
        timings: dict[str, int],
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
        simulate_cut: bool,
    ) -> None:
        budget_ms = int(step.get("focus_timeout_ms", timings.get("before_send_keys", 800)))
        if simulate_cut:
            self._emit_log("info", "[模拟] 跳过获取窗口")
            elapsed = int((time.monotonic() - cycle_start) * 1000)
            self._emit_progress(step_id, step_type, label, elapsed, total_ms, "已跳过获取窗口")
            return
        keyword = str(step.get("window_keyword") or cm.get("window_title_contains", "")).strip()
        title = focus_window_step(keyword, budget_ms)
        self._emit_log("info", f"已激活窗口: {title}")
        elapsed = int((time.monotonic() - cycle_start) * 1000)
        self._emit_progress(step_id, step_type, label, elapsed, total_ms, f"已激活 {title}")

    def _do_send_hotkey(
        self,
        step: dict[str, Any],
        cm: dict[str, Any],
        timings: dict[str, int],
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
        simulate_cut: bool,
    ) -> None:
        delay_before = int(step.get("delay_before_ms", timings.get("after_focus_ms", 0)))
        delay_after = int(step.get("delay_after_ms", timings.get("after_hotkey_ms", 0)))
        if simulate_cut:
            self._emit_log("info", "[模拟] 跳过发送快捷键")
            elapsed = int((time.monotonic() - cycle_start) * 1000)
            self._emit_progress(step_id, step_type, label, elapsed, total_ms, "已跳过发送快捷键")
            return
        hotkey = str(step.get("hotkey") or cm.get("send_hotkey", "")).strip()
        if not self._wait(delay_before, step_id, step_type, label, total_ms, cycle_start):
            raise RuntimeError("发送快捷键前等待被中止")
        press_hotkey_step(hotkey, 0, delay_after)
        self._emit_log("info", f"已发送快捷键: {hotkey}")
        self._emit({"event": "cut_hotkey_sent", "title": "", "hotkey": hotkey})
        elapsed = int((time.monotonic() - cycle_start) * 1000)
        self._emit_progress(step_id, step_type, label, elapsed, total_ms, f"已发送 {hotkey}")

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

    def _should_fail_immediately(self, exc: Exception) -> bool:
        if self._cancel.is_set():
            return True
        message = str(exc)
        return "被中止" in message

    def _resolve_prompt_locked(self, action: str) -> None:
        if self._pending_prompt_id is not None:
            self._prompt_result = action
            self._prompt_event.set()

    def _prompt_user(self, exc: Exception, step: dict[str, Any], label: str) -> str:
        prompt_id = f"prompt-{time.time_ns()}"
        step_type = str(step.get("type") or "")
        detail_parts = [f"步骤: {label}"]
        if step_type:
            detail_parts.append(f"类型: {STEP_TYPE_LABELS.get(step_type, step_type)}")
        detail_parts.append(f"原因: {exc}")

        with self._prompt_lock:
            self._prompt_event.clear()
            self._prompt_result = None
            self._pending_prompt_id = prompt_id

        self._emit(
            {
                "event": "user_prompt",
                "prompt_id": prompt_id,
                "title": "步骤执行出现问题",
                "message": str(exc),
                "detail": "\n".join(detail_parts),
                "step_label": label,
                "step_id": step.get("id"),
                "step_type": step_type,
            }
        )
        self._set_phase(Phase.WAITING_USER, f"等待确认: {label}")
        self._emit_log("warn", f"{label} 出错，等待用户确认: {exc}")

        while True:
            if self._prompt_event.wait(0.2):
                break
            if self._cancel.is_set():
                with self._prompt_lock:
                    self._pending_prompt_id = None
                    self._prompt_result = None
                return PROMPT_ABORT

        with self._prompt_lock:
            action = self._prompt_result or PROMPT_ABORT
            self._pending_prompt_id = None
            self._prompt_result = None

        return action

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
