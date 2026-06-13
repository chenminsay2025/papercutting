from __future__ import annotations

import json
import os
from copy import deepcopy
from pathlib import Path
from typing import Any

DEFAULT_CONFIG: dict[str, Any] = {
    "serial": {
        "port": "COM3",
        "baudrate": 115200,
        "timeout_ms": 2000,
    },
    "timings_ms": {
        "retract": 3000,
        "extend": 3000,
        "cut_wait": 6000,
        "relay_pulse": 200,
        "before_send_keys": 300,
    },
    "cutting_master": {
        "window_title_contains": "Cutting Master",
        "send_hotkey": "ctrl+p",
    },
    "app": {
        "simulation_mode": True,
        "simulate_cut": True,
    },
}

VALID_BAUDRATES = {9600, 19200, 38400, 57600, 115200}
MAX_TIMING_MS = 60_000
MIN_RELAY_PULSE_MS = 50
MAX_RELAY_PULSE_MS = 2000


def project_root() -> Path:
    return Path(__file__).resolve().parent.parent


def config_path() -> Path:
    return project_root() / "config.json"


def validate_config(config: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    serial = config.get("serial", {})
    baudrate = serial.get("baudrate")
    if baudrate not in VALID_BAUDRATES:
        errors.append(f"波特率无效: {baudrate}，可选 {sorted(VALID_BAUDRATES)}")

    timeout_ms = serial.get("timeout_ms")
    if not isinstance(timeout_ms, int) or not (100 <= timeout_ms <= 30_000):
        errors.append("串口超时 timeout_ms 必须是 100–30000 的整数")

    timings = config.get("timings_ms", {})
    for key in ("retract", "extend", "cut_wait", "before_send_keys"):
        value = timings.get(key)
        if not isinstance(value, int) or not (0 <= value <= MAX_TIMING_MS):
            errors.append(f"时序 {key} 必须是 0–{MAX_TIMING_MS} 的整数")

    relay_pulse = timings.get("relay_pulse")
    if not isinstance(relay_pulse, int) or not (MIN_RELAY_PULSE_MS <= relay_pulse <= MAX_RELAY_PULSE_MS):
        errors.append(
            f"继电器脉冲 relay_pulse 必须是 {MIN_RELAY_PULSE_MS}–{MAX_RELAY_PULSE_MS} 的整数"
        )

    cm = config.get("cutting_master", {})
    keyword = str(cm.get("window_title_contains", "")).strip()
    if len(keyword) < 2:
        errors.append("窗口关键字 window_title_contains 至少需要 2 个字符")

    hotkey = str(cm.get("send_hotkey", "")).strip()
    if not hotkey:
        errors.append("热键 send_hotkey 不能为空")

    app_cfg = config.get("app", {})
    if not isinstance(app_cfg.get("simulation_mode"), bool):
        errors.append("simulation_mode 必须是布尔值")
    if not isinstance(app_cfg.get("simulate_cut"), bool):
        errors.append("simulate_cut 必须是布尔值")

    if not app_cfg.get("simulation_mode", True):
        port = str(serial.get("port", "")).strip()
        if not port or port.startswith("SIM"):
            errors.append("硬件模式下 serial.port 必须是有效 COM 口")

    return errors


def load_config() -> dict[str, Any]:
    path = config_path()
    config = deepcopy(DEFAULT_CONFIG)
    if path.exists():
        try:
            with path.open("r", encoding="utf-8") as fp:
                loaded = json.load(fp)
            _deep_merge(config, loaded)
        except json.JSONDecodeError:
            backup = path.with_suffix(f".corrupted-{path.stat().st_mtime_ns}.json")
            try:
                path.rename(backup)
            except OSError:
                pass
    return config


def save_config(config: dict[str, Any]) -> None:
    path = config_path()
    tmp_path = path.with_suffix(".json.tmp")
    with tmp_path.open("w", encoding="utf-8") as fp:
        json.dump(config, fp, indent=2, ensure_ascii=False)
        fp.write("\n")
    os.replace(tmp_path, path)


def _deep_merge(base: dict[str, Any], override: dict[str, Any]) -> None:
    for key, value in override.items():
        if isinstance(value, dict) and isinstance(base.get(key), dict):
            _deep_merge(base[key], value)
        else:
            base[key] = value
