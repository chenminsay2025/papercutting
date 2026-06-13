from __future__ import annotations

import atexit
import json
import sys
import threading
import time
import traceback
from typing import Any

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
        self._ensure_client()
        self._start_heartbeat()
        atexit.register(self._shutdown)

    def _start_heartbeat(self) -> None:
        def loop() -> None:
            while not self._heartbeat_stop.wait(1.5):
                try:
                    with self._client_lock:
                        if self.client is None or not self.client.connected:
                            continue
                        self.client.ping()
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
        if self.config.get("app", {}).get("simulation_mode", True):
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

        simulation = self.config.get("app", {}).get("simulation_mode", True)
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
                if self.config.get("app", {}).get("simulation_mode", True):
                    ports = MockStm32Client.list_ports()
                else:
                    ports = Stm32Client.list_ports()
                reply({"event": "ports", "ports": ports})
                return

            if cmd == "connect":
                if self.workflow.running:
                    raise RuntimeError("流程运行中，无法连接/切换串口")
                self._recreate_client_if_needed(force=True)
                port = message.get("port") or self.config["serial"]["port"]
                simulation = self.config.get("app", {}).get("simulation_mode", True)

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
                    self.client.connect()
                    response = self.client.ping()
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
                self.workflow.start_cycle(self.config)
                reply({"event": "cycle_started"})
                return

            if cmd == "estop":
                self.workflow.estop()
                reply({"event": "estop"})
                return

            if cmd == "test_step":
                step = message.get("step")
                self.workflow.test_step(step, self.config)
                reply({"event": "test_done", "step": step})
                return

            if cmd == "test_cut_window":
                from cutting_master import probe_cut_window, send_cut_job

                cm = self.config.get("cutting_master", {})
                keyword = str(message.get("keyword") or cm.get("window_title_contains", "")).strip()
                hotkey = str(message.get("hotkey") or cm.get("send_hotkey", "")).strip()
                send_keys = bool(message.get("send_keys", False))
                if len(keyword) < 2:
                    raise RuntimeError("窗口关键字至少需要 2 个字符")
                if send_keys and not hotkey:
                    raise RuntimeError("发送热键不能为空")

                if send_keys:
                    timings = self.config.get("timings_ms", {})
                    title = send_cut_job(
                        keyword,
                        hotkey,
                        int(timings.get("before_send_keys", 0)),
                        int(timings.get("after_focus_ms", 0)),
                        int(timings.get("after_hotkey_ms", 0)),
                    )
                else:
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
