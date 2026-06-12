from __future__ import annotations

import json
import sys
import threading
import traceback
from typing import Any

from config import load_config, save_config
from mock_stm32 import MockStm32Client
from serial_stm32 import Stm32Client
from workflow import WorkflowRunner


class ControllerService:
    def __init__(self):
        self.config = load_config()
        self.client: Stm32Client | MockStm32Client | None = None
        self._using_mock = False
        self.workflow = WorkflowRunner(self.emit)
        self._write_lock = threading.Lock()
        self._ensure_client()

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

    def _recreate_client_if_needed(self) -> None:
        simulation = self.config.get("app", {}).get("simulation_mode", True)
        if simulation != self._using_mock:
            if self.client is not None:
                self.client.close()
            self.client = None
            self._ensure_client()

    def emit(self, payload: dict[str, Any], request_id: str | None = None) -> None:
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
                merged = load_config()
                for key, value in incoming.items():
                    if isinstance(value, dict) and isinstance(merged.get(key), dict):
                        merged[key].update(value)
                    else:
                        merged[key] = value
                self.config = merged
                save_config(self.config)
                self._recreate_client_if_needed()
                if self.client and not self._using_mock:
                    self.client.port = self.config["serial"]["port"]
                    self.client.baudrate = self.config["serial"]["baudrate"]
                    self.client.timeout = self.config["serial"]["timeout_ms"] / 1000.0
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
                self._recreate_client_if_needed()
                port = message.get("port") or self.config["serial"]["port"]
                simulation = self.config.get("app", {}).get("simulation_mode", True)

                if simulation or str(port).startswith("SIM"):
                    self.config.setdefault("app", {})["simulation_mode"] = True
                    self._recreate_client_if_needed()
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
                self._recreate_client_if_needed()
                assert self.client is not None
                self.client.port = port
                self.client.connect()
                response = self.client.ping()
                reply({"event": "connected", "port": port, "response": response, "simulation": False})
                return

            if cmd == "disconnect":
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

            if cmd == "serial_ping":
                if self.client is None or not self.client.connected:
                    raise RuntimeError("未连接")
                response = self.client.ping()
                reply({"event": "serial_ping", "response": response})
                return

            reply({"event": "error", "message": f"未知命令: {cmd}"})
        except Exception as exc:
            reply({"event": "error", "message": str(exc), "trace": traceback.format_exc()})


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
