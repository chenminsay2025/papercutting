from __future__ import annotations

import atexit
import json
import sys
import threading
import time
import traceback
from typing import Any

from action_groups import (
    delete_action_group,
    export_action_group,
    export_saved_action_group,
    import_action_group,
    list_action_groups,
    load_action_group,
    save_action_group,
)
from config import load_config, save_config, validate_config
from mock_stm32 import MockStm32Client
from serial_stm32 import Stm32Client
from workflow import WorkflowRunner


class ControllerService:
    def __init__(self):
        self.config = load_config()
        self.client: Stm32Client | MockStm32Client | None = None
        self._using_mock = False
        self._client_lock = threading.RLock()
        self._pending_client_refresh = False
        self.workflow = WorkflowRunner(self.emit, client_lock=self._client_lock)
        self._write_lock = threading.Lock()
        self._heartbeat_stop = threading.Event()
        self._heartbeat_interval_s = 0.5
        self._ensure_client()
        self._start_heartbeat()
        atexit.register(self._shutdown)

    def _start_heartbeat(self) -> None:
        def loop() -> None:
            while not self._heartbeat_stop.wait(self._heartbeat_interval_s):
                try:
                    with self._client_lock:
                        if self.client is None or not self.client.connected:
                            continue
                        self.client.ping()
                        status_line = self.client.status()
                    parsed = Stm32Client.parse_device_status(status_line)
                    payload = {
                        "event": "device_status",
                        "motor": parsed.get("motor"),
                        "position": parsed.get("rod_position"),
                        "raw": status_line,
                    }
                    self.emit(payload)
                    if parsed.get("rod_position"):
                        self.emit({
                            "event": "rod_sensor",
                            "position": parsed["rod_position"],
                            "raw": status_line,
                        })
                except Exception:
                    pass

        threading.Thread(target=loop, name="serial-heartbeat", daemon=True).start()

    def _shutdown(self) -> None:
        self._heartbeat_stop.set()
        try:
            with self._client_lock:
                if self.client is not None and self.client.connected:
                    try:
                        self.client.estop()
                    except Exception:
                        pass
                    self.client.close()
        except Exception:
            pass

    def _log_from_mock(self, level: str, message: str) -> None:
        self.emit({"event": "log", "level": level, "message": message})

    def _ensure_client(self) -> None:
        if self.client is not None:
            self.workflow.attach_client(self.client)
            return
        if self.config.get("app", {}).get("simulation_mode", False):
            self.client = MockStm32Client(emit_log=self._log_from_mock)
            self._using_mock = True
        else:
            self.client = Stm32Client(
                port=self.config["serial"]["port"],
                baudrate=self.config["serial"]["baudrate"],
                timeout_ms=self.config["serial"]["timeout_ms"],
            )
            self._using_mock = False
        self.workflow.attach_client(self.client)

    def _apply_client_settings(self) -> None:
        if self.client is None or self._using_mock:
            return
        self.client.port = self.config["serial"]["port"]
        self.client.baudrate = self.config["serial"]["baudrate"]
        self.client.timeout = self.config["serial"]["timeout_ms"] / 1000.0

    def _recreate_client_if_needed(self, *, force: bool = False) -> None:
        if self.workflow.running and not force:
            self._pending_client_refresh = True
            return

        simulation = self.config.get("app", {}).get("simulation_mode", False)
        if simulation != self._using_mock:
            with self._client_lock:
                if self.client is not None:
                    self.client.close()
                self.client = None
            self._ensure_client()
        else:
            with self._client_lock:
                self._apply_client_settings()

        self._pending_client_refresh = False

    def _apply_pending_client_refresh(self) -> None:
        if self._pending_client_refresh and not self.workflow.running:
            self._recreate_client_if_needed(force=True)

    def _merge_config(self, incoming: dict[str, Any]) -> dict[str, Any]:
        merged = deepcopy_config(self.config)
        for key, value in incoming.items():
            if isinstance(value, dict) and isinstance(merged.get(key), dict):
                merged[key].update(value)
            else:
                merged[key] = value
        return merged

    def emit(self, payload: dict[str, Any], request_id: str | None = None) -> None:
        event = payload.get("event")
        if event in ("cycle_done", "cycle_aborted"):
            self._apply_pending_client_refresh()

        if request_id:
            payload = {**payload, "id": request_id}
        line = json.dumps(payload, ensure_ascii=False)
        with self._write_lock:
            sys.stdout.write(line + "\n")
            sys.stdout.flush()

    def handle(self, message: dict[str, Any]) -> None:
        cmd = message.get("cmd")
        req_id = message.get("id")

        def reply(payload: dict[str, Any]) -> None:
            self.emit(payload, request_id=req_id)

        try:
            if cmd == "ping":
                reply({"event": "pong"})
                return

            if cmd == "get_config":
                reply({"event": "config", "config": self.config})
                return

            if cmd == "save_config":
                incoming = message.get("config", {})
                merged = self._merge_config(incoming)
                errors = validate_config(merged)
                if errors:
                    reply({"event": "error", "message": "; ".join(errors)})
                    return

                self.config = merged
                save_config(self.config)
                self._recreate_client_if_needed()
                if not self.workflow.running:
                    with self._client_lock:
                        self._apply_client_settings()
                reply({"event": "config_saved", "config": self.config})
                return

            if cmd == "list_ports":
                if "simulation_mode" in message:
                    simulation = bool(message.get("simulation_mode"))
                else:
                    simulation = bool(self.config.get("app", {}).get("simulation_mode", False))
                if simulation:
                    ports = MockStm32Client.list_ports()
                else:
                    ports = Stm32Client.list_ports()
                reply({"event": "ports", "ports": ports, "simulation": simulation})
                return

            if cmd == "connect":
                if self.workflow.running:
                    raise RuntimeError("流程运行中，无法连接/切换串口")
                self._recreate_client_if_needed(force=True)
                port = message.get("port") or self.config["serial"]["port"]
                simulation = self.config.get("app", {}).get("simulation_mode", False)

                if simulation:
                    self.config.setdefault("app", {})["simulation_mode"] = True
                    self._recreate_client_if_needed(force=True)
                    with self._client_lock:
                        assert self.client is not None
                        self.client.connect()
                        response = self.client.ping()
                    reply(
                        {
                            "event": "connected",
                            "port": "SIM（模拟）",
                            "response": response,
                            "simulation": True,
                        }
                    )
                    return

                self.config.setdefault("app", {})["simulation_mode"] = False
                self.config["serial"]["port"] = port
                save_config(self.config)
                self._recreate_client_if_needed(force=True)
                with self._client_lock:
                    assert self.client is not None
                    self.client.port = port
                    try:
                        self.client.connect()
                        response = self.client.ping()
                    except Exception:
                        self.client.close()
                        raise
                reply({"event": "connected", "port": port, "response": response, "simulation": False})
                return

            if cmd == "disconnect":
                if self.workflow.running:
                    raise RuntimeError("流程运行中，无法断开连接")
                with self._client_lock:
                    if self.client is not None:
                        self.client.close()
                reply({"event": "disconnected"})
                return

            if cmd == "start_cycle":
                from workflow import _cycle_total_ms

                self.workflow.start_cycle(self.config)
                app_cfg = self.config.get("app", {})
                reply(
                    {
                        "event": "cycle_started",
                        "total_ms": _cycle_total_ms(self.config),
                        "auto_loop": bool(app_cfg.get("auto_loop", False)),
                        "loop_interval_ms": int(app_cfg.get("loop_interval_ms", 0)),
                    }
                )
                return

            if cmd == "estop":
                self.workflow.estop()
                reply({"event": "estop"})
                return

            if cmd == "test_step":
                step = message.get("step")
                duration_ms = message.get("duration_ms")
                workflow_step = message.get("workflow_step")
                self.workflow.test_step(
                    step,
                    self.config,
                    workflow_step=workflow_step,
                    duration_ms=duration_ms,
                )
                reply({"event": "test_done", "step": step})
                return

            if cmd == "restore_app_focus":
                from cutting_master import restore_window

                keyword = str(message.get("keyword") or "PaperCutting").strip()
                title = restore_window(keyword)
                reply({"event": "app_focus_restored", "title": title})
                return

            if cmd == "list_open_windows":
                from cutting_master import list_open_windows

                max_count = int(message.get("max_count", 100))
                windows = list_open_windows(max_count)
                reply({"event": "open_windows", "windows": windows})
                return

            if cmd == "restore_focus_ack":
                request_id = str(message.get("request_id", "")).strip()
                ok = bool(message.get("ok", False))
                title = str(message.get("title") or "").strip()
                self.workflow.resolve_restore_focus(request_id, ok, title)
                reply({"event": "restore_focus_ack", "request_id": request_id})
                return

            if cmd == "test_cut_window":
                from cutting_master import ensure_window_foreground, press_hotkey_step, probe_cut_window

                cm = self.config.get("cutting_master", {})
                timings = self.config.get("timings_ms", {})
                keyword = str(message.get("keyword") or cm.get("window_title_contains", "")).strip()
                hotkey = str(message.get("hotkey") or cm.get("send_hotkey", "")).strip()
                send_keys = bool(message.get("send_keys", False))

                if send_keys:
                    if not hotkey:
                        raise RuntimeError("发送热键不能为空")
                    if len(keyword) >= 2:
                        ensure_window_foreground(keyword)
                    press_hotkey_step(
                        hotkey,
                        0,
                        0,
                        int(message.get("press_count", 1)),
                        int(message.get("press_interval_ms", 0)),
                        window_title_contains=keyword or None,
                    )
                    delay_ms = int(message.get("delay_ms", timings.get("after_hotkey_ms", 0)))
                    if delay_ms > 0:
                        from serial_stm32 import wait_ms
                        import threading

                        wait_ms(delay_ms, threading.Event())
                    title = hotkey
                else:
                    if len(keyword) < 2:
                        raise RuntimeError("窗口关键字至少需要 2 个字符")
                    title = probe_cut_window(keyword)

                reply(
                    {
                        "event": "cut_window_ok",
                        "title": title,
                        "keyword": keyword,
                        "hotkey": hotkey,
                        "sent": send_keys,
                    }
                )
                return

            if cmd == "serial_ping":
                with self._client_lock:
                    if self.client is None or not self.client.connected:
                        raise RuntimeError("未连接")
                    response = self.client.ping()
                reply({"event": "serial_ping", "response": response})
                return

            if cmd == "rod_sensor":
                with self._client_lock:
                    if self.client is None or not self.client.connected:
                        raise RuntimeError("未连接")
                    response = self.client.rod_sensor()
                position = Stm32Client.parse_rod_position(response)
                reply({"event": "rod_sensor", "position": position, "raw": response})
                return

            if cmd == "device_status":
                with self._client_lock:
                    if self.client is None or not self.client.connected:
                        raise RuntimeError("未连接")
                    response = self.client.status()
                parsed = Stm32Client.parse_device_status(response)
                reply({
                    "event": "device_status",
                    "motor": parsed.get("motor"),
                    "position": parsed.get("rod_position"),
                    "raw": response,
                })
                return

            if cmd == "list_action_groups":
                reply({"event": "action_groups", "groups": list_action_groups()})
                return

            if cmd == "save_action_group":
                if self.workflow.running:
                    raise RuntimeError("流程运行中，无法保存动作组")
                name = str(message.get("name", "")).strip()
                steps = message.get("workflow_steps") or self.config.get("workflow_steps") or []
                payload = save_action_group(name, steps)
                reply(
                    {
                        "event": "action_group_saved",
                        "name": payload["name"],
                        "groups": list_action_groups(),
                    }
                )
                return

            if cmd == "load_action_group":
                if self.workflow.running:
                    raise RuntimeError("流程运行中，无法打开动作组")
                name = str(message.get("name", "")).strip()
                payload = load_action_group(name)
                self.config["workflow_steps"] = payload["workflow_steps"]
                save_config(self.config)
                reply(
                    {
                        "event": "action_group_loaded",
                        "name": payload["name"],
                        "config": self.config,
                        "storage": "internal",
                    }
                )
                return

            if cmd == "export_action_group":
                if self.workflow.running:
                    raise RuntimeError("流程运行中，无法导出动作组")
                file_path = str(message.get("file_path", "")).strip()
                if not file_path:
                    raise ValueError("请选择导出文件路径")
                name = str(message.get("name", "")).strip()
                steps = message.get("workflow_steps") or self.config.get("workflow_steps") or []
                payload = export_action_group(file_path, name, steps)
                reply(
                    {
                        "event": "action_group_exported",
                        "name": payload["name"],
                        "file_path": payload["file_path"],
                    }
                )
                return

            if cmd == "import_action_group":
                if self.workflow.running:
                    raise RuntimeError("流程运行中，无法导入动作组")
                file_path = str(message.get("file_path", "")).strip()
                if not file_path:
                    raise ValueError("请选择动作组文件")
                payload = import_action_group(file_path)
                self.config["workflow_steps"] = payload["workflow_steps"]
                save_config(self.config)
                reply(
                    {
                        "event": "action_group_imported",
                        "name": payload["name"],
                        "file_path": payload["file_path"],
                        "config": self.config,
                    }
                )
                return

            if cmd == "delete_action_group":
                if self.workflow.running:
                    raise RuntimeError("流程运行中，无法删除动作组")
                name = str(message.get("name", "")).strip()
                deleted = delete_action_group(name)
                reply(
                    {
                        "event": "action_group_deleted",
                        "name": deleted,
                        "groups": list_action_groups(),
                    }
                )
                return

            if cmd == "export_saved_action_group":
                if self.workflow.running:
                    raise RuntimeError("流程运行中，无法导出动作组")
                name = str(message.get("name", "")).strip()
                file_path = str(message.get("file_path", "")).strip()
                if not name:
                    raise ValueError("请指定动作组名称")
                if not file_path:
                    raise ValueError("请选择导出文件路径")
                payload = export_saved_action_group(name, file_path)
                reply(
                    {
                        "event": "action_group_exported",
                        "name": payload["name"],
                        "file_path": payload["file_path"],
                    }
                )
                return

            if cmd == "prompt_response":
                prompt_id = str(message.get("prompt_id", "")).strip()
                action = str(message.get("action", "")).strip()
                self.workflow.resolve_prompt(prompt_id, action)
                reply({"event": "prompt_ack", "prompt_id": prompt_id, "action": action})
                return

            reply({"event": "error", "message": f"未知命令: {cmd}"})
        except Exception as exc:
            reply({"event": "error", "message": str(exc), "trace": traceback.format_exc()})


def deepcopy_config(config: dict[str, Any]) -> dict[str, Any]:
    from copy import deepcopy

    return deepcopy(config)


def main() -> None:
    service = ControllerService()
    service.emit({"event": "ready"})

    for raw_line in sys.stdin:
        line = raw_line.strip()
        if not line:
            continue
        try:
            message = json.loads(line)
            if not isinstance(message, dict):
                raise ValueError("消息必须是 JSON 对象")
            service.handle(message)
        except Exception as exc:
            service.emit(
                {
                    "event": "error",
                    "message": str(exc),
                    "trace": traceback.format_exc(),
                }
            )


if __name__ == "__main__":
    main()
