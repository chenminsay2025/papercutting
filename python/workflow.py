from __future__ import annotations

import threading
import time
from enum import Enum
from typing import Any, Callable, Optional

from action_groups import load_action_group
from config import (
    CONDITION_STATUS_LABELS,
    STEP_TYPE_LABELS,
    call_group_label,
    condition_value_label,
    pulse_step_label,
)
from cutting_master import focus_window_step, is_app_window_keyword, press_hotkey_step, send_hotkey_to_window
from serial_stm32 import Stm32Client, wait_ms

MAX_CALL_DEPTH = 8


def _step_delay_ms(step: dict[str, Any], timings: dict[str, Any] | None = None) -> int:
    timings = timings or {}
    if "delay_ms" in step:
        return max(0, int(step.get("delay_ms") or 0))
    step_type = step.get("type")
    if step_type == "focus_window":
        return max(0, int(step.get("focus_timeout_ms", timings.get("before_send_keys", 0))))
    if step_type == "send_hotkey":
        return max(0, int(step.get("delay_after_ms", timings.get("after_hotkey_ms", 0))))
    return 0


def _step_action_duration_ms(step: dict[str, Any], timings: dict[str, Any]) -> int:
    step_type = step.get("type")
    if step_type == "focus_window":
        return 0
    if step_type == "send_hotkey":
        press_count = max(1, int(step.get("press_count", 1)))
        press_interval = max(0, int(step.get("press_interval_ms", 0)))
        return max(0, press_count - 1) * press_interval
    if step_type in ("pulse_a", "pulse_b"):
        return int(step.get("duration_ms", timings.get("relay_pulse", 0))) + 30
    if step_type in ("retract", "extend", "wait"):
        legacy_key = {
            "retract": "retract",
            "extend": "extend",
        }.get(step_type, step_type)
        default_ms = timings.get(legacy_key, 0)
        if step_type == "wait":
            default_ms = timings.get("cut_wait", timings.get("wait", default_ms))
        return int(step.get("duration_ms", default_ms))
    if step_type == "confirm_dialog":
        return 0
    if step_type == "condition_check":
        return 0
    if step_type in ("else_branch", "end_if", "call_group", "stop"):
        return 0
    if step_type == "restore_app":
        return 0
    return 0


def _step_duration_ms(step: dict[str, Any], timings: dict[str, Any]) -> int:
    return _step_action_duration_ms(step, timings) + _step_delay_ms(step, timings)


class Phase(str, Enum):
    IDLE = "idle"
    DONE = "done"
    ABORTED = "aborted"
    WAITING_USER = "waiting_user"


class WorkflowUserAbort(Exception):
    """用户选择停止流程。"""


class WorkflowStopCycle(Exception):
    """显式「停止流程」步骤：正常结束本轮。"""


PROMPT_RETRY = "retry"
PROMPT_SKIP = "skip"
PROMPT_ABORT = "abort"
PROMPT_CONFIRM = "confirm"
PROMPT_CANCEL = "cancel"


def _step_label(step: dict[str, Any], config: dict[str, Any] | None = None) -> str:
    step_type = str(step.get("type", ""))
    if step_type in ("pulse_a", "pulse_b"):
        return pulse_step_label(step_type, config)
    if step_type == "call_group":
        return call_group_label(str(step.get("group_name") or ""))
    return str(step.get("label") or STEP_TYPE_LABELS.get(step_type, step_type))


class _BranchFrame:
    __slots__ = ("skip_until_else", "skip_until_end", "condition_met")

    def __init__(self) -> None:
        self.skip_until_else = False
        self.skip_until_end = False
        self.condition_met: bool | None = None


def _enabled_steps(config: dict[str, Any]) -> list[dict[str, Any]]:
    steps = config.get("workflow_steps") or []
    return [step for step in steps if step.get("enabled") is True]


def _cycle_total_ms(config: dict[str, Any]) -> int:
    timings = config["timings_ms"]
    return sum(
        _step_duration_ms(step, timings)
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
        self._auto_loop = False
        self._loop_interval_ms = 0
        self._active_step_id: str | None = None
        self._prompt_lock = threading.Lock()
        self._prompt_event = threading.Event()
        self._pending_prompt_id: str | None = None
        self._prompt_result: str | None = None
        self._restore_focus_lock = threading.Lock()
        self._restore_focus_event = threading.Event()
        self._pending_restore_focus_id: str | None = None
        self._restore_focus_ok = False
        self._restore_focus_title: str = ""
        self._cycle_total_ms = 0
        self._cycle_progress_ms = 0
        self._step_progress_base_ms = 0
        self._active_step_total_ms = 0
        self._branch_stack: list[_BranchFrame] = []
        self._call_stack: list[str] = []

    def _reset_branch_state(self) -> None:
        self._branch_stack.clear()

    def _current_branch(self) -> _BranchFrame | None:
        return self._branch_stack[-1] if self._branch_stack else None

    @staticmethod
    def _if_block_info(steps: list[dict[str, Any]], if_index: int) -> tuple[bool, bool]:
        has_else = False
        has_end = False
        depth = 0
        for i in range(if_index + 1, len(steps)):
            step_type = str(steps[i].get("type", "")).strip()
            if step_type == "condition_check":
                depth += 1
            elif step_type == "else_branch":
                if depth == 0:
                    has_else = True
            elif step_type == "end_if":
                if depth == 0:
                    has_end = True
                    break
                depth -= 1
        return has_else, has_end

    def _handle_branch_gate(
        self,
        step: dict[str, Any],
        steps: list[dict[str, Any]],
        idx: int,
        config: dict[str, Any],
    ) -> bool:
        """处理分支标记；返回 True 表示本步已消费，不再走普通 execute。"""
        step_type = str(step.get("type", "")).strip()
        label = _step_label(step, config)
        frame = self._current_branch()

        if frame is not None and frame.skip_until_else:
            if step_type == "else_branch":
                frame.skip_until_else = False
                self._emit_log("info", "进入否则分支")
                self._set_step(str(step.get("id", "")), step_type, label)
                return True
            return True

        if frame is not None and frame.skip_until_end:
            if step_type == "end_if":
                self._branch_stack.pop()
                self._emit_log("info", "结束条件分支")
                self._set_step(str(step.get("id", "")), step_type, label)
                return True
            return True

        if step_type == "else_branch":
            if frame is None:
                self._emit_log("warn", "遇到「否则」但没有对应的「如果」")
                self._set_step(str(step.get("id", "")), step_type, label)
                return True
            if frame.condition_met:
                frame.skip_until_end = True
                self._emit_log("info", "条件成立，跳过否则分支")
            else:
                self._emit_log("info", "进入否则分支")
            self._set_step(str(step.get("id", "")), step_type, label)
            return True

        if step_type == "end_if":
            if frame is not None:
                self._branch_stack.pop()
            else:
                self._emit_log("warn", "遇到「结束如果」但没有对应的「如果」")
            self._emit_log("info", "结束条件分支")
            self._set_step(str(step.get("id", "")), step_type, label)
            return True

        return False

    def _begin_cycle_progress(self, total_ms: int) -> None:
        self._cycle_total_ms = max(int(total_ms), 0)
        self._cycle_progress_ms = 0
        self._step_progress_base_ms = 0

    def _begin_step_progress(self) -> None:
        self._step_progress_base_ms = self._cycle_progress_ms

    def _complete_step_progress(self, step: dict[str, Any], timings: dict[str, Any]) -> None:
        self._cycle_progress_ms = min(
            self._cycle_total_ms,
            self._cycle_progress_ms + _step_duration_ms(step, timings),
        )

    @staticmethod
    def _hotkey_step_window_keyword(_step: dict[str, Any]) -> str:
        return ""

    @staticmethod
    def _focus_step_window_keyword(step: dict[str, Any], cm: dict[str, Any]) -> str:
        return str(step.get("window_keyword") or cm.get("window_title_contains", "")).strip()

    def _focus_window_title(self, keyword: str) -> str:
        if is_app_window_keyword(keyword):
            return self._activate_window(keyword)
        return focus_window_step(keyword, delay_after_ms=0)

    def _reensure_focus_window(self, step: dict[str, Any], cm: dict[str, Any]) -> None:
        from cutting_master import ensure_window_foreground

        keyword = self._focus_step_window_keyword(step, cm)
        if len(keyword) < 2:
            return
        if is_app_window_keyword(keyword):
            self._activate_window(keyword)
            return
        ensure_window_foreground(keyword)

    def _progress_elapsed(self, step_elapsed_in_step: int = 0) -> int:
        return min(
            self._step_progress_base_ms + max(0, int(step_elapsed_in_step)),
            self._cycle_total_ms,
        )

    @property
    def phase(self) -> Phase:
        return self._phase

    @property
    def running(self) -> bool:
        return self._running

    def attach_client(self, client: Optional[Stm32Client]) -> None:
        with self._client_lock:
            self._client = client

    def set_mode(self, simulation: bool) -> None:
        self._simulation = simulation

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
        self._resolve_restore_focus_locked(False, "")
        with self._client_lock:
            if self._client is not None:
                self._client.estop()
        self._set_phase(Phase.ABORTED, "已执行急停")

    def resolve_prompt(self, prompt_id: str, action: str) -> None:
        normalized = str(action or PROMPT_ABORT).strip().lower()
        allowed = {PROMPT_RETRY, PROMPT_SKIP, PROMPT_ABORT, PROMPT_CONFIRM, PROMPT_CANCEL}
        if normalized not in allowed:
            raise ValueError(f"无效的 prompt 动作: {action}")
        with self._prompt_lock:
            if self._pending_prompt_id != prompt_id:
                raise RuntimeError("确认请求已过期或不存在")
            self._prompt_result = normalized
            self._prompt_event.set()

    def resolve_restore_focus(self, request_id: str, ok: bool, title: str = "") -> None:
        with self._restore_focus_lock:
            if self._pending_restore_focus_id != request_id:
                return
            self._restore_focus_ok = bool(ok)
            self._restore_focus_title = str(title or "").strip()
            self._restore_focus_event.set()

    def _resolve_restore_focus_locked(self, ok: bool, title: str = "") -> None:
        if self._pending_restore_focus_id is not None:
            self._restore_focus_ok = bool(ok)
            self._restore_focus_title = str(title or "").strip()
            self._restore_focus_event.set()

    def _wait_for_restore_focus(self, request_id: str, timeout_s: float = 5.0) -> tuple[bool, str]:
        deadline = time.monotonic() + timeout_s
        while time.monotonic() < deadline:
            if self._restore_focus_event.wait(0.15):
                break
            if self._cancel.is_set():
                with self._restore_focus_lock:
                    self._pending_restore_focus_id = None
                    self._restore_focus_ok = False
                    self._restore_focus_title = ""
                return False, ""
        with self._restore_focus_lock:
            ok = self._restore_focus_ok
            title = self._restore_focus_title
            self._pending_restore_focus_id = None
            self._restore_focus_ok = False
            self._restore_focus_title = ""
            self._restore_focus_event.clear()
        return ok, title

    def _activate_window(self, keyword: str) -> str:
        keyword = str(keyword or "").strip()
        if len(keyword) < 2:
            raise RuntimeError("窗口关键字至少需要 2 个字符")

        request_id = f"restore-focus-{time.time_ns()}"
        with self._restore_focus_lock:
            self._restore_focus_event.clear()
            self._restore_focus_ok = False
            self._restore_focus_title = ""
            self._pending_restore_focus_id = request_id

        self._emit(
            {
                "event": "restore_focus_request",
                "request_id": request_id,
                "keyword": keyword,
            }
        )

        ok, title = self._wait_for_restore_focus(request_id)
        if ok:
            time.sleep(0.1)
            return title or keyword

        if is_app_window_keyword(keyword):
            raise RuntimeError(
                f"无法激活窗口「{keyword}」。"
                "Windows 阻止自动切回，请手动点击 CutPPaper 窗口后重试。"
            )

        from cutting_master import ensure_window_foreground

        return ensure_window_foreground(keyword)

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
            keyword = str(wf_step.get("window_keyword") or cm.get("window_title_contains", "")).strip()
            title = self._focus_window_title(keyword)
            self._emit_log("info", f"已激活窗口: {title}")
            delay_ms = _step_delay_ms(wf_step, timings)
            if delay_ms > 0:
                wait_ms(delay_ms, threading.Event())
        elif step == "send_hotkey":
            hotkey = str(wf_step.get("hotkey") or cm.get("send_hotkey", "")).strip()
            keyword = self._hotkey_step_window_keyword(wf_step)
            press_hotkey_step(
                hotkey,
                0,
                0,
                int(wf_step.get("press_count", 1)),
                int(wf_step.get("press_interval_ms", 0)),
                window_title_contains=keyword or None,
            )
            delay_ms = _step_delay_ms(wf_step, timings)
            if delay_ms > 0:
                wait_ms(delay_ms, threading.Event())
            count = max(1, int(wf_step.get("press_count", 1)))
            suffix = f" x{count}" if count > 1 else ""
            self._emit_log("info", f"已执行按键: {hotkey}{suffix}")
            self._emit({"event": "cut_hotkey_sent", "title": "", "hotkey": hotkey})
        elif step == "restore_app":
            keyword = str(wf_step.get("window_keyword") or "CutPPaper").strip()
            title = self._activate_window(keyword)
            self._emit_log("info", f"已回到窗口: {title}")
            self._emit({"event": "app_focus_restored", "title": title})
            delay_ms = _step_delay_ms(wf_step, timings)
            if delay_ms > 0:
                wait_ms(delay_ms, threading.Event())
        elif step == "wait":
            ms = int(wf_step.get("duration_ms", duration_ms or timings.get("wait", 1000)))
            note = str(wf_step.get("note", "")).strip()
            if note:
                self._emit_log("info", note)
            wait_ms(ms, threading.Event())
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
        except WorkflowStopCycle:
            self._set_phase(Phase.DONE, "流程已停止")
            self._emit(
                {
                    "event": "cycle_done",
                    "loop_index": loop_index,
                    "will_repeat": False,
                    "stopped": True,
                }
            )
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
        total_ms = _cycle_total_ms(config)
        self._begin_cycle_progress(total_ms)
        self._reset_branch_state()
        self._call_stack.clear()
        cycle_start = time.monotonic()
        steps = _enabled_steps(config)
        self._run_steps(steps, config, loop_index, cycle_start, call_depth=0)

        label = f"第 {loop_index} 轮完成" if self._auto_loop else "本轮完成"
        self._active_step_id = None
        self._set_phase(Phase.DONE, label)

    def _run_steps(
        self,
        steps: list[dict[str, Any]],
        config: dict[str, Any],
        loop_index: int,
        cycle_start: float,
        *,
        call_depth: int = 0,
    ) -> None:
        timings = config["timings_ms"]
        cm = config["cutting_master"]
        total_ms = self._cycle_total_ms

        for idx, step in enumerate(steps):
            if self._handle_branch_gate(step, steps, idx, config):
                continue

            label = _step_label(step, config)
            while True:
                try:
                    step_type = str(step.get("type", "")).strip()
                    if step_type == "condition_check":
                        has_else, has_end = self._if_block_info(steps, idx)
                        self._active_step_id = str(step.get("id", ""))
                        self._begin_step_progress()
                        self._set_step(str(step.get("id", "")), step_type, label)
                        self._do_condition_check(
                            step,
                            str(step.get("id", "")),
                            step_type,
                            label,
                            total_ms,
                            cycle_start,
                            has_else_branch=has_else,
                            has_end_if=has_end,
                        )
                        self._complete_step_progress(step, timings)
                    elif step_type == "call_group":
                        self._do_call_group(
                            step,
                            config,
                            loop_index,
                            cycle_start,
                            call_depth=call_depth,
                        )
                    elif step_type == "stop":
                        self._do_stop(step, config)
                    else:
                        self._execute_step(step, cm, timings, total_ms, cycle_start, config)
                    break
                except WorkflowStopCycle:
                    raise
                except WorkflowUserAbort:
                    raise
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

    def _do_call_group(
        self,
        step: dict[str, Any],
        config: dict[str, Any],
        loop_index: int,
        cycle_start: float,
        *,
        call_depth: int,
    ) -> None:
        if call_depth >= MAX_CALL_DEPTH:
            raise RuntimeError(f"动作组调用嵌套超过 {MAX_CALL_DEPTH} 层")

        group_name = str(step.get("group_name") or "").strip()
        if not group_name:
            raise RuntimeError("调用动作组未指定名称")
        if group_name in self._call_stack:
            raise RuntimeError(f"动作组「{group_name}」不能递归调用")

        step_id = str(step.get("id", ""))
        step_type = str(step.get("type", ""))
        label = _step_label(step, config)
        self._active_step_id = step_id
        self._begin_step_progress()
        self._set_step(step_id, step_type, label)

        payload = load_action_group(group_name)
        sub_steps = [item for item in payload.get("workflow_steps") or [] if item.get("enabled") is True]
        if not sub_steps:
            raise RuntimeError(f"动作组「{group_name}」没有已启用的步骤")

        self._emit_log("info", f"调用动作组「{group_name}」（{len(sub_steps)} 步）")
        self._call_stack.append(group_name)
        try:
            self._run_steps(
                sub_steps,
                config,
                loop_index,
                cycle_start,
                call_depth=call_depth + 1,
            )
        finally:
            if self._call_stack and self._call_stack[-1] == group_name:
                self._call_stack.pop()

        self._complete_step_progress(step, config["timings_ms"])

    def _do_stop(self, step: dict[str, Any], config: dict[str, Any]) -> None:
        step_id = str(step.get("id", ""))
        step_type = str(step.get("type", ""))
        label = _step_label(step, config)
        self._active_step_id = step_id
        self._begin_step_progress()
        self._set_step(step_id, step_type, label)
        self._emit_log("info", "执行停止流程")
        self._complete_step_progress(step, config["timings_ms"])
        raise WorkflowStopCycle("流程已停止")

    def _execute_step(
        self,
        step: dict[str, Any],
        cm: dict[str, Any],
        timings: dict[str, Any],
        total_ms: int,
        cycle_start: float,
        config: dict[str, Any],
    ) -> None:
        step_id = str(step.get("id", ""))
        step_type = str(step.get("type", ""))
        label = _step_label(step, config)
        self._active_step_id = step_id
        self._begin_step_progress()
        self._active_step_total_ms = max(_step_duration_ms(step, timings), 1)
        self._set_step(step_id, step_type, label)

        try:
            if step_type == "retract":
                self._do_retract(int(step.get("duration_ms", timings["retract"])), step_id, step_type, label, total_ms, cycle_start)
            elif step_type == "pulse_a":
                self._do_pulse_a(int(step.get("duration_ms", timings["relay_pulse"])), step_id, step_type, label, total_ms, cycle_start)
            elif step_type == "focus_window":
                self._do_focus_window(step, cm, timings, step_id, step_type, label, total_ms, cycle_start, config)
            elif step_type == "send_hotkey":
                self._do_send_hotkey(step, cm, timings, step_id, step_type, label, total_ms, cycle_start, config)
            elif step_type == "restore_app":
                self._do_restore_app(step, step_id, step_type, label, total_ms, cycle_start, timings)
            elif step_type == "wait":
                note = str(step.get("note", "")).strip()
                ms = int(
                    step.get(
                        "duration_ms",
                        timings.get("cut_wait", timings.get("wait", 1000)),
                    )
                )
                if note:
                    self._emit_log("info", f"{label} — {note}")
                self._do_wait(ms, step_id, step_type, label, total_ms, cycle_start)
            elif step_type == "extend":
                self._do_extend(int(step.get("duration_ms", timings["extend"])), step_id, step_type, label, total_ms, cycle_start)
            elif step_type == "pulse_b":
                self._do_pulse_b(int(step.get("duration_ms", timings["relay_pulse"])), step_id, step_type, label, total_ms, cycle_start)
            elif step_type == "confirm_dialog":
                self._do_confirm_dialog(step, step_id, step_type, label, total_ms, cycle_start)
            else:
                raise RuntimeError(f"未知步骤类型: {step_type}")

            self._apply_step_delay(step, cm, timings, step_id, step_type, label, total_ms, cycle_start, config)
            self._complete_step_progress(step, timings)
        finally:
            self._active_step_total_ms = 0

    def _apply_step_delay(
        self,
        step: dict[str, Any],
        cm: dict[str, Any],
        timings: dict[str, Any],
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
        config: dict[str, Any],
    ) -> None:
        delay_ms = _step_delay_ms(step, timings)
        if delay_ms <= 0:
            if step.get("type") == "focus_window":
                self._reensure_focus_window(step, cm)
            return
        action_ms = _step_action_duration_ms(step, timings)
        step_total = max(action_ms + delay_ms, 1)
        if not self._wait(
            delay_ms,
            step_id,
            step_type,
            label,
            total_ms,
            cycle_start,
            step_elapsed_offset_ms=action_ms,
            step_total_override_ms=step_total,
        ):
            raise RuntimeError(f"{label} 延时等待被中止")
        if step.get("type") == "focus_window":
            self._reensure_focus_window(step, cm)

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
            raise RuntimeError(f"{label} 被中止")

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
        config: dict[str, Any],
    ) -> None:
        keyword = self._focus_step_window_keyword(step, cm)
        title = self._focus_window_title(keyword)
        self._emit_log("info", f"已激活窗口: {title}")
        delay_ms = _step_delay_ms(step, timings)
        step_total = self._active_step_total_ms or max(delay_ms, 1)
        self._emit_progress(
            step_id,
            step_type,
            label,
            self._progress_elapsed(0),
            total_ms,
            f"已激活 {title}",
            step_elapsed_ms=0,
            step_total_ms=step_total,
        )

    def _do_restore_app(
        self,
        step: dict[str, Any],
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
        timings: dict[str, int],
    ) -> None:
        keyword = str(step.get("window_keyword") or "CutPPaper").strip()
        title = self._activate_window(keyword)
        self._emit_log("info", f"已回到窗口: {title}")
        self._emit({"event": "app_focus_restored", "title": title})
        delay_ms = _step_delay_ms(step, timings)
        step_total = self._active_step_total_ms or max(delay_ms, 1)
        self._emit_progress(
            step_id,
            step_type,
            label,
            self._progress_elapsed(0),
            total_ms,
            f"已回到 {title}",
            step_elapsed_ms=0,
            step_total_ms=step_total,
        )

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
        config: dict[str, Any],
    ) -> None:
        press_count = max(1, int(step.get("press_count", 1)))
        press_interval_ms = max(0, int(step.get("press_interval_ms", 0)))
        hotkey = str(step.get("hotkey") or cm.get("send_hotkey", "")).strip()
        if not hotkey:
            raise RuntimeError("快捷键不能为空")

        action_ms = max(0, press_count - 1) * press_interval_ms
        step_total = self._active_step_total_ms or max(action_ms, 1)
        step_offset = 0

        for index in range(press_count):
            send_hotkey_to_window(hotkey, None)
            self._emit_progress(
                step_id,
                step_type,
                label,
                self._progress_elapsed(step_offset),
                total_ms,
                label,
                step_elapsed_ms=min(step_offset, step_total),
                step_total_ms=step_total,
            )
            if index >= press_count - 1 or press_interval_ms <= 0:
                continue
            if not self._wait(
                press_interval_ms,
                step_id,
                step_type,
                label,
                total_ms,
                cycle_start,
                step_elapsed_offset_ms=step_offset,
            ):
                raise RuntimeError("按键操作间隔等待被中止")
            step_offset += press_interval_ms

        count_suffix = f" x{press_count}" if press_count > 1 else ""
        self._emit_log("info", f"已执行按键: {hotkey}{count_suffix} → 当前前台窗口")
        self._emit({"event": "cut_hotkey_sent", "title": "", "hotkey": hotkey, "press_count": press_count})
        self._emit_progress(
            step_id,
            step_type,
            label,
            self._progress_elapsed(action_ms),
            total_ms,
            f"已发送 {hotkey}{count_suffix}",
            step_elapsed_ms=action_ms,
            step_total_ms=step_total,
        )

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
            raise RuntimeError(f"{label} 被中止")

    def _wait_for_prompt(self, prompt_id: str) -> str:
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

    def _do_confirm_dialog(
        self,
        step: dict[str, Any],
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
    ) -> None:
        prompt_text = str(step.get("prompt_text") or step.get("message") or "请确认后继续").strip()
        if not prompt_text:
            raise RuntimeError("弹窗确认步骤缺少提示文本")

        prompt_id = f"confirm-{time.time_ns()}"
        with self._prompt_lock:
            self._prompt_event.clear()
            self._prompt_result = None
            self._pending_prompt_id = prompt_id

        self._emit_progress(
            step_id,
            step_type,
            label,
            self._progress_elapsed(0),
            total_ms,
            "等待用户确认",
            step_elapsed_ms=0,
            step_total_ms=1,
        )
        self._emit(
            {
                "event": "user_prompt",
                "prompt_id": prompt_id,
                "prompt_kind": "confirm",
                "title": label,
                "message": prompt_text,
                "detail": "",
                "step_label": label,
                "step_id": step_id,
                "step_type": step_type,
            }
        )
        self._set_phase(Phase.WAITING_USER, f"等待确认: {label}")
        self._emit_log("info", f"等待弹窗确认: {label}")

        action = self._wait_for_prompt(prompt_id)
        if action in (PROMPT_CANCEL, PROMPT_ABORT) or self._cancel.is_set():
            raise WorkflowUserAbort("用户取消")
        if action != PROMPT_CONFIRM:
            raise WorkflowUserAbort("用户取消")

        self._emit_progress(
            step_id,
            step_type,
            label,
            self._progress_elapsed(0),
            total_ms,
            "已确认",
            step_elapsed_ms=1,
            step_total_ms=1,
        )
        self._emit_log("info", f"用户已确认: {label}")

    def _read_live_status(self) -> dict[str, str | None]:
        if self._client is None or not getattr(self._client, "connected", False):
            return {"paper": None, "motor": None, "usb": "disconnected"}
        with self._client_lock:
            line = self._client.status()
        parsed = Stm32Client.parse_device_status(line)
        return {
            "paper": parsed.get("rod_position"),
            "motor": parsed.get("motor"),
            "usb": "connected",
        }

    def _resolve_condition_actual(self, status_key: str, live: dict[str, str | None]) -> str | None:
        if status_key == "paper":
            return live.get("paper")
        if status_key == "motor":
            return live.get("motor")
        if status_key == "usb":
            return live.get("usb")
        return None

    def _do_condition_check(
        self,
        step: dict[str, Any],
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
        *,
        has_else_branch: bool = False,
        has_end_if: bool = False,
    ) -> None:
        status_key = str(step.get("status_key") or "paper").strip()
        expected = str(step.get("expected_value") or "").strip()
        if not expected:
            raise RuntimeError("判断步骤缺少期望值")

        key_label = CONDITION_STATUS_LABELS.get(status_key, status_key)
        expected_label = condition_value_label(status_key, expected)

        self._branch_stack.append(_BranchFrame())
        frame = self._current_branch()
        assert frame is not None

        self._emit_progress(
            step_id,
            step_type,
            label,
            self._progress_elapsed(0),
            total_ms,
            f"检查{key_label}",
            step_elapsed_ms=0,
            step_total_ms=2,
        )

        live = self._read_live_status()
        actual = self._resolve_condition_actual(status_key, live)
        actual_label = condition_value_label(status_key, actual)

        if actual == expected:
            frame.condition_met = True
            self._emit_log("info", f"判断通过: {key_label} = {expected_label}")
            self._emit_progress(
                step_id,
                step_type,
                label,
                self._progress_elapsed(2),
                total_ms,
                "条件成立",
                step_elapsed_ms=2,
                step_total_ms=2,
            )
            return

        frame.condition_met = False

        if has_else_branch:
            frame.skip_until_else = True
            self._emit_log(
                "info",
                f"条件不成立，跳过「则」分支: 当前{key_label}=「{actual_label}」，期望「{expected_label}」",
            )
            self._emit_progress(
                step_id,
                step_type,
                label,
                self._progress_elapsed(2),
                total_ms,
                "走否则分支",
                step_elapsed_ms=2,
                step_total_ms=2,
            )
            return

        if has_end_if:
            frame.skip_until_end = True
            self._emit_log(
                "info",
                f"条件不成立，跳到结束如果: 当前{key_label}=「{actual_label}」，期望「{expected_label}」",
            )
            self._emit_progress(
                step_id,
                step_type,
                label,
                self._progress_elapsed(2),
                total_ms,
                "跳过本段",
                step_elapsed_ms=2,
                step_total_ms=2,
            )
            return

        warn_message = f"当前{key_label}为「{actual_label}」，不等于期望的「{expected_label}」"
        detail = "是否仍继续执行后续步骤？选择「取消」将中止整个流程。"

        prompt_id = f"condition-{time.time_ns()}"
        with self._prompt_lock:
            self._prompt_event.clear()
            self._prompt_result = None
            self._pending_prompt_id = prompt_id

        self._emit_progress(
            step_id,
            step_type,
            label,
            self._progress_elapsed(1),
            total_ms,
            "判断未通过",
            step_elapsed_ms=1,
            step_total_ms=2,
        )
        self._emit(
            {
                "event": "user_prompt",
                "prompt_id": prompt_id,
                "prompt_kind": "condition",
                "title": "状态判断未通过",
                "message": warn_message,
                "detail": detail,
                "step_label": label,
                "step_id": step_id,
                "step_type": step_type,
                "status_key": status_key,
                "expected_value": expected,
                "actual_value": actual,
            }
        )
        self._set_phase(Phase.WAITING_USER, f"判断未通过: {label}")
        self._emit_log("warn", f"判断未通过: {warn_message}")

        action = self._wait_for_prompt(prompt_id)
        if action in (PROMPT_CANCEL, PROMPT_ABORT) or self._cancel.is_set():
            raise WorkflowUserAbort("用户取消")
        if action != PROMPT_CONFIRM:
            raise WorkflowUserAbort("用户取消")

        self._emit_log("warn", f"用户选择继续执行（判断未通过）: {warn_message}")
        self._emit_progress(
            step_id,
            step_type,
            label,
            self._progress_elapsed(2),
            total_ms,
            "已强制继续",
            step_elapsed_ms=2,
            step_total_ms=2,
        )

    def _wait(
        self,
        duration_ms: int,
        step_id: str,
        step_type: str,
        label: str,
        total_ms: int,
        cycle_start: float,
        *,
        step_elapsed_offset_ms: int = 0,
        step_total_override_ms: int | None = None,
    ) -> bool:
        step_total = max(int(step_total_override_ms if step_total_override_ms is not None else (self._active_step_total_ms or duration_ms)), 1)

        def on_tick(elapsed_slice_ms: int, _slice_total_ms: int) -> None:
            step_elapsed = min(step_elapsed_offset_ms + elapsed_slice_ms, step_total)
            elapsed_cycle_ms = self._progress_elapsed(step_elapsed)
            self._emit_progress(
                step_id,
                step_type,
                label,
                elapsed_cycle_ms,
                total_ms,
                label,
                step_elapsed_ms=step_elapsed,
                step_total_ms=step_total,
            )

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
        step_elapsed_ms: int | None = None,
        step_total_ms: int | None = None,
    ) -> None:
        step_total = max(int(step_total_ms or 0), 0)
        step_elapsed = max(int(step_elapsed_ms or 0), 0)
        if step_total <= 0:
            step_progress = 0.0
        else:
            step_progress = min(1.0, step_elapsed / step_total)
        cycle_progress = min(1.0, elapsed_ms / total_ms) if total_ms else 0.0
        self._emit(
            {
                "event": "progress",
                "phase": step_type,
                "phase_label": label,
                "step_id": step_id,
                "elapsed_ms": elapsed_ms,
                "total_ms": total_ms,
                "progress": cycle_progress,
                "step_elapsed_ms": step_elapsed,
                "step_total_ms": step_total,
                "step_progress": step_progress,
                "message": message,
            }
        )

    def _emit_log(self, level: str, message: str) -> None:
        self._emit({"event": "log", "level": level, "message": message})
