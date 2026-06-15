from __future__ import annotations

import time
from typing import Callable, Optional

import serial
from serial.tools import list_ports


class Stm32Client:
    def __init__(self, port: str, baudrate: int = 115200, timeout_ms: int = 2000):
        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout_ms / 1000.0
        self._ser: Optional[serial.Serial] = None

    @staticmethod
    def list_ports() -> list[dict[str, str]]:
        ports: list[dict[str, str]] = []
        for item in list_ports.comports():
            ports.append(
                {
                    "port": item.device,
                    "description": item.description or "",
                    "hwid": item.hwid or "",
                }
            )
        return ports

    @property
    def connected(self) -> bool:
        return self._ser is not None and self._ser.is_open

    def connect(self) -> None:
        self.close()
        try:
            self._ser = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                timeout=self.timeout,
                write_timeout=self.timeout,
                rtscts=False,
                dsrdtr=False,
            )
            # CH340 模块若 RTS 接 NRST，须避免 dtr=False,rts=True（会拉住复位无响应）
            self._ser.dtr = True
            self._ser.rts = True
            time.sleep(0.35)
            self._drain_boot_messages()
        except Exception:
            self.close()
            raise

    def close(self) -> None:
        if self._ser is not None:
            self._ser.close()
            self._ser = None

    def _drain_boot_messages(self) -> None:
        if self._ser is None:
            return
        deadline = time.monotonic() + 0.5
        while time.monotonic() < deadline:
            line = self._read_line_nowait()
            if line is None:
                time.sleep(0.05)
            elif line.startswith("OK:"):
                return

    def _read_line_nowait(self) -> Optional[str]:
        if self._ser is None:
            return None
        if self._ser.in_waiting == 0:
            return None
        raw = self._ser.readline()
        if not raw:
            return None
        return raw.decode("utf-8", errors="ignore").strip()

    def send_command(self, command: str) -> str:
        if self._ser is None or not self._ser.is_open:
            raise RuntimeError("串口未连接")

        payload = f"{command}\r\n".encode("utf-8")
        self._ser.reset_input_buffer()
        self._ser.write(payload)

        deadline = time.monotonic() + self.timeout
        first = True
        while time.monotonic() < deadline:
            line = self._read_line_nowait()
            if line is None:
                if first:
                    first = False
                    continue
                time.sleep(0.01)
                continue
            if line.startswith("OK") or line.startswith("ERR") or line.startswith("STATUS"):
                return line
        raise TimeoutError(f"等待 STM32 响应超时: {command}")

    def ping(self) -> str:
        return self.send_command("PING")

    def retract(self) -> str:
        return self.send_command("RETRACT")

    def extend(self) -> str:
        return self.send_command("EXTEND")

    def stop(self) -> str:
        return self.send_command("STOP")

    def estop(self) -> str:
        try:
            return self.send_command("ESTOP")
        except Exception:
            return "ERR:DISCONNECTED"

    def pulse_a(self, duration_ms: int) -> str:
        return self.send_command(f"PULSE_A:{duration_ms}")

    def pulse_b(self, duration_ms: int) -> str:
        return self.send_command(f"PULSE_B:{duration_ms}")


def wait_ms(duration_ms: int, cancel_event, on_tick: Optional[Callable[[int, int], None]] = None) -> bool:
    if duration_ms <= 0:
        return True

    start = time.monotonic()
    total = duration_ms
    while True:
        if cancel_event.is_set():
            return False

        elapsed_ms = int((time.monotonic() - start) * 1000)
        if on_tick is not None:
            on_tick(min(elapsed_ms, total), total)
        if elapsed_ms >= total:
            return True

        remaining = total - elapsed_ms
        if remaining > 200:
            time.sleep(0.1)
        elif remaining > 50:
            time.sleep(0.02)
        elif remaining > 20:
            time.sleep(0.01)
        else:
            time.sleep(0.001)
