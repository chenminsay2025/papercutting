from __future__ import annotations

import time
from typing import Optional

from serial_stm32 import wait_ms


class MockStm32Client:
    """模拟 STM32 串口，用于界面调试。"""

    def __init__(self, emit_log=None):
        self.port = "SIM"
        self.baudrate = 115200
        self.timeout = 2.0
        self._emit_log = emit_log
        self._open = False

    @staticmethod
    def list_ports() -> list[dict[str, str]]:
        return [{"port": "SIM（模拟）", "description": "无需硬件", "hwid": ""}]

    @property
    def connected(self) -> bool:
        return self._open

    def connect(self) -> None:
        self._open = True
        self._log("模拟串口已连接")

    def close(self) -> None:
        self._open = False
        self._log("模拟串口已断开")

    def send_command(self, command: str) -> str:
        if not self._open:
            raise RuntimeError("模拟串口未连接")
        self._log(f"→ STM32: {command}")
        time.sleep(0.05)
        return "OK"

    def ping(self) -> str:
        return self.send_command("PING")

    def retract(self) -> str:
        return self.send_command("RETRACT")

    def extend(self) -> str:
        return self.send_command("EXTEND")

    def stop(self) -> str:
        return self.send_command("STOP")

    def estop(self) -> str:
        return self.send_command("ESTOP")

    def pulse_a(self, duration_ms: int) -> str:
        return self.send_command(f"PULSE_A:{duration_ms}")

    def pulse_b(self, duration_ms: int) -> str:
        return self.send_command(f"PULSE_B:{duration_ms}")

    def _log(self, message: str) -> None:
        if self._emit_log:
            self._emit_log("info", f"[模拟] {message}")
