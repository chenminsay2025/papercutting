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

    @staticmethod
    def is_port_available(port: str) -> bool:
        if not port:
            return False
        for item in list_ports.comports():
            if item.device == port:
                return True
        return False

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
            time.sleep(0.2)
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
        deadline = time.monotonic() + 0.35
        idle_rounds = 0
        while time.monotonic() < deadline:
            line = self._read_line_nowait()
            if line is None:
                idle_rounds += 1
                if idle_rounds >= 2:
                    return
                time.sleep(0.03)
            elif line.startswith("OK:"):
                return
            else:
                idle_rounds = 0

    def _read_line_nowait(self) -> Optional[str]:
        if self._ser is None:
            return None
        try:
            if self._ser.in_waiting == 0:
                return None
            raw = self._ser.readline()
        except (serial.SerialException, OSError):
            self.close()
            raise RuntimeError("串口已断开") from None
        if not raw:
            return None
        return raw.decode("utf-8", errors="ignore").strip()

    def send_line(self, command: str) -> None:
        if self._ser is None or not self._ser.is_open:
            raise RuntimeError("串口未连接")
        payload = f"{command}\r\n".encode("utf-8")
        try:
            self._ser.write(payload)
            self._ser.flush()
        except (serial.SerialException, OSError):
            self.close()
            raise RuntimeError("串口已断开") from None

    def drain_ok_lines(self, max_lines: int = 8) -> None:
        if self._ser is None or not self._ser.is_open:
            return
        for _ in range(max(0, int(max_lines))):
            line = self._read_line_nowait()
            if line is None:
                break

    def ui_progress(self, percent_x10: int) -> None:
        pct = max(0, min(1000, int(percent_x10)))
        self.send_line(f"UI_PROGRESS:{pct}")

    def ui_progress_clear(self) -> None:
        self.send_line("UI_PROGRESS:OFF")

    def ui_step(self, label_id: int) -> None:
        self.send_command(f"UI_STEP:{max(0, min(255, int(label_id)))}")

    def ui_step_clear(self) -> None:
        self.send_command("UI_STEP:CLEAR")

    def ui_steps(self, current_idx: int, label_ids: list[int]) -> None:
        cur = max(0, min(255, int(current_idx)))
        parts = [str(cur)] + [str(max(0, min(255, int(label_id)))) for label_id in label_ids[:16]]
        self.send_line(f"UI_STEPS:{','.join(parts)}")

    def ui_step_index(self, idx: int) -> None:
        self.send_line(f"UI_STEPIDX:{max(0, min(255, int(idx)))}")

    def ui_meta(self, idx: int, total: int, elapsed_ms: int, total_ms: int, loop: int = 0) -> None:
        self.send_line(
            f"UI_META:{max(0, int(idx))},{max(0, int(total))},"
            f"{max(0, int(elapsed_ms))},{max(0, int(total_ms))},{max(0, int(loop))}"
        )

    def ui_phase(self, phase: int) -> None:
        self.send_line(f"UI_PHASE:{max(0, min(3, int(phase)))}")

    def ui_loop_reset(self) -> None:
        self.send_line("UI_LOOP:0")

    def ui_loop(self, loop: int) -> None:
        self.send_line(f"UI_LOOP:{max(0, min(9999, int(loop)))}")

    def ui_wait_timer(self, elapsed_ds: int, total_ds: int) -> None:
        self.send_line(f"UI_WAIT:{max(0, min(9999, int(elapsed_ds)))},{max(0, min(9999, int(total_ds)))}")

    def ui_wait_clear(self) -> None:
        self.send_line("UI_WAIT:OFF")

    def send_command(self, command: str) -> str:
        if self._ser is None or not self._ser.is_open:
            raise RuntimeError("串口未连接")

        payload = f"{command}\r\n".encode("utf-8")
        self._ser.reset_input_buffer()
        try:
            self._ser.write(payload)
        except (serial.SerialException, OSError):
            self.close()
            raise RuntimeError("串口已断开") from None

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
            if line.startswith("OK") or line.startswith("ERR") or line.startswith("STATUS") or line.startswith("ROD:") or line.startswith("OBSTACLE:"):
                return line
        raise TimeoutError(f"等待 STM32 响应超时: {command}")

    def ping(self) -> str:
        return self.send_command("PING")

    def status(self) -> str:
        return self.send_command("STATUS")

    @staticmethod
    def parse_motor_state(line: str) -> str | None:
        upper = str(line or "").upper()
        if "RETRACTING" in upper:
            return "retract"
        if "EXTENDING" in upper:
            return "extend"
        if "RELAY" in upper:
            return "relay"
        if "TIMEOUT" in upper:
            return "timeout"
        if "IDLE" in upper:
            return "idle"
        return None

    @staticmethod
    def parse_device_status(line: str) -> dict[str, str | None]:
        return {
            "motor": Stm32Client.parse_motor_state(line),
            "rod_position": Stm32Client.parse_rod_position(line),
            "obstacle": Stm32Client.parse_obstacle_state(line),
        }

    def rod_sensor(self) -> str:
        return self.send_command("ROD_SENSOR")

    def obstacle_sensor(self) -> str:
        return self.send_command("OBSTACLE?")

    @staticmethod
    def parse_rod_position(line: str) -> str | None:
        upper = str(line or "").upper()
        if "ROD:HOME" in upper:
            return "home"
        if "ROD:AWAY" in upper:
            return "away"
        return None

    @staticmethod
    def parse_obstacle_state(line: str) -> str | None:
        upper = str(line or "").upper()
        if "OBSTACLE:BLOCKED" in upper:
            return "blocked"
        if "OBSTACLE:CLEAR" in upper:
            return "clear"
        return None

    def buzzer(
        self,
        pattern: str,
        on_ms: int = 200,
        gap_ms: int = 100,
        repeat: int = 1,
    ) -> str:
        p = str(pattern or "short").strip().upper()
        if p == "OFF":
            return self.send_command("BUZZER:OFF")
        if p in ("SHORT", "LONG"):
            return self.send_command(f"BUZZER:{p},{int(on_ms)}")
        if p in ("DOUBLE", "TRIPLE", "CONTINUOUS"):
            return self.send_command(f"BUZZER:{p},{int(on_ms)},{int(gap_ms)}")
        if repeat <= 1:
            return self.send_command(f"BUZZER:{int(on_ms)}")
        return self.send_command(f"BUZZER:{int(on_ms)},{int(gap_ms)},{int(repeat)}")

    def buzzer_off(self) -> str:
        return self.send_command("BUZZER:OFF")

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
