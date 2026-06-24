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
        self._motor_state = "idle"
        self._rod_position = "away"
        self._obstacle_state = "clear"

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

    def send_line(self, command: str) -> None:
        if not self._open:
            return
        self._log(f"→ STM32: {command}")

    def ui_progress(self, percent_x10: int) -> None:
        self.send_line(f"UI_PROGRESS:{max(0, min(1000, int(percent_x10)))}")

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

    def send_command(self, command: str) -> str:
        if not self._open:
            raise RuntimeError("模拟串口未连接")
        self._log(f"→ STM32: {command}")
        time.sleep(0.05)
        cmd = str(command or "").strip().upper()
        if cmd == "PING":
            return "OK:PONG"
        if cmd == "ROD_SENSOR":
            pos = "HOME" if self._rod_position == "home" else "AWAY"
            return f"ROD:{pos}"
        if cmd in ("OBSTACLE", "OBSTACLE?"):
            obs = "BLOCKED" if self._obstacle_state == "blocked" else "CLEAR"
            return f"OBSTACLE:{obs}"
        if cmd == "STATUS":
            motor = "RETRACTING" if self._motor_state == "retract" else (
                "EXTENDING" if self._motor_state == "extend" else "IDLE"
            )
            rod = "HOME" if self._rod_position == "home" else "AWAY"
            obs = "BLOCKED" if self._obstacle_state == "blocked" else "CLEAR"
            return f"STATUS:{motor};ROD:{rod};OBSTACLE:{obs}"
        if cmd == "RETRACT":
            self._motor_state = "retract"
            self._rod_position = "home"
            return "OK"
        if cmd == "EXTEND":
            self._motor_state = "extend"
            self._rod_position = "away"
            return "OK"
        if cmd == "STOP":
            self._motor_state = "idle"
            return "OK"
        if cmd == "ESTOP":
            self._motor_state = "idle"
            return "OK:ESTOP"
        if cmd.startswith("PULSE_"):
            self._motor_state = "relay"
            return "OK"
        if cmd.startswith("BUZZER:"):
            if cmd == "BUZZER:OFF":
                return "OK"
            return "OK"
        if cmd.startswith("UI_PROGRESS:"):
            return "OK"
        if cmd.startswith("UI_STEPIDX:"):
            return "OK"
        if cmd.startswith("UI_STEPS:"):
            return "OK"
        if cmd.startswith("UI_STEP:"):
            return "OK"
        if cmd.startswith("UI_META:"):
            return "OK"
        if cmd.startswith("UI_PHASE:"):
            return "OK"
        if cmd.startswith("UI_LOOP:"):
            return "OK"
        return "OK"

    def ping(self) -> str:
        return self.send_command("PING")

    def rod_sensor(self) -> str:
        return self.send_command("ROD_SENSOR")

    def obstacle_sensor(self) -> str:
        return self.send_command("OBSTACLE?")

    def status(self) -> str:
        return self.send_command("STATUS")

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

    def _log(self, message: str) -> None:
        if self._emit_log:
            self._emit_log("info", f"[模拟] {message}")
