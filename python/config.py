from __future__ import annotations

import json
import os
import time
from copy import deepcopy
from pathlib import Path
from typing import Any

STEP_TYPES = (
    "retract",
    "pulse_a",
    "send_cut",
    "cut_wait",
    "extend",
    "pulse_b",
    "wait",
)

STEP_TYPE_LABELS: dict[str, str] = {
    "retract": "伸缩杆缩回",
    "pulse_a": "继续 (继电器A)",
    "send_cut": "发送切割 Ctrl+P",
    "cut_wait": "等待切割",
    "extend": "伸缩杆伸出",
    "pulse_b": "原点 (继电器B)",
    "wait": "等待",
}

DEFAULT_WORKFLOW_STEPS: list[dict[str, Any]] = [
    {"id": "step-retract", "type": "retract", "enabled": True, "label": "伸缩杆缩回"},
    {"id": "step-pulse-a", "type": "pulse_a", "enabled": True, "label": "继续 (继电器A)"},
    {"id": "step-send-cut", "type": "send_cut", "enabled": True, "label": "发送切割 Ctrl+P"},
    {"id": "step-cut-wait", "type": "cut_wait", "enabled": True, "label": "等待切割"},
    {"id": "step-extend", "type": "extend", "enabled": True, "label": "伸缩杆伸出"},
    {"id": "step-pulse-b", "type": "pulse_b", "enabled": True, "label": "原点 (继电器B)"},
]

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
        "before_send_keys": 800,
        "after_focus_ms": 100,
        "after_hotkey_ms": 200,
    },
    "cutting_master": {
        "window_title_contains": "Cutting Master",
        "send_hotkey": "ctrl+p",
    },
    "app": {
        "simulation_mode": True,
        "simulate_cut": True,
        "auto_loop": False,
        "loop_interval_ms": 3000,
    },
    "workflow_steps": deepcopy(DEFAULT_WORKFLOW_STEPS),
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
    for key in ("retract", "extend", "cut_wait", "before_send_keys", "after_focus_ms", "after_hotkey_ms"):
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
    if not isinstance(app_cfg.get("auto_loop"), bool):
        errors.append("auto_loop 必须是布尔值")

    loop_interval_ms = app_cfg.get("loop_interval_ms")
    if not isinstance(loop_interval_ms, int) or not (0 <= loop_interval_ms <= MAX_TIMING_MS):
        errors.append(f"轮间间隔 loop_interval_ms 必须是 0–{MAX_TIMING_MS} 的整数")

    if not app_cfg.get("simulation_mode", True):
        port = str(serial.get("port", "")).strip()
        if not port or port.startswith("SIM"):
            errors.append("硬件模式下 serial.port 必须是有效 COM 口")

    steps = config.get("workflow_steps")
    if steps is None:
        config["workflow_steps"] = deepcopy(DEFAULT_WORKFLOW_STEPS)
    elif not isinstance(steps, list) or len(steps) == 0:
        errors.append("workflow_steps 必须是非空数组")
    else:
        seen_ids: set[str] = set()
        for index, step in enumerate(steps):
            prefix = f"步骤 #{index + 1}"
            if not isinstance(step, dict):
                errors.append(f"{prefix} 必须是对象")
                continue
            step_id = str(step.get("id", "")).strip()
            if not step_id:
                errors.append(f"{prefix} 缺少 id")
            elif step_id in seen_ids:
                errors.append(f"{prefix} id 重复: {step_id}")
            else:
                seen_ids.add(step_id)

            step_type = str(step.get("type", "")).strip()
            if step_type not in STEP_TYPES:
                errors.append(f"{prefix} type 无效: {step_type}")

            if not isinstance(step.get("enabled"), bool):
                errors.append(f"{prefix} enabled 必须是布尔值")

            label = str(step.get("label", "")).strip()
            if not label:
                errors.append(f"{prefix} label 不能为空")

            if step_type == "wait":
                duration_ms = step.get("duration_ms")
                if not isinstance(duration_ms, int) or not (0 <= duration_ms <= MAX_TIMING_MS):
                    errors.append(f"{prefix} duration_ms 必须是 0–{MAX_TIMING_MS} 的整数")

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
    if not config.get("workflow_steps"):
        config["workflow_steps"] = deepcopy(DEFAULT_WORKFLOW_STEPS)
    return config


def save_config(config: dict[str, Any]) -> None:
    path = config_path()
    tmp_path = path.with_suffix(".json.tmp")
    payload = json.dumps(config, indent=2, ensure_ascii=False) + "\n"
    with tmp_path.open("w", encoding="utf-8") as fp:
        fp.write(payload)

    last_err: OSError | None = None
    for attempt in range(8):
        try:
            os.replace(tmp_path, path)
            return
        except OSError as err:
            last_err = err
            time.sleep(0.05 * (attempt + 1))

    try:
        with path.open("w", encoding="utf-8") as fp:
            fp.write(payload)
        try:
            tmp_path.unlink()
        except OSError:
            pass
        return
    except OSError:
        if last_err is not None:
            raise last_err
        raise


def _deep_merge(base: dict[str, Any], override: dict[str, Any]) -> None:
    for key, value in override.items():
        if isinstance(value, dict) and isinstance(base.get(key), dict):
            _deep_merge(base[key], value)
        else:
            base[key] = value
