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
    "focus_window",
    "send_hotkey",
    "restore_app",
    "extend",
    "pulse_b",
    "wait",
    "confirm_dialog",
)

STEP_TYPE_LABELS: dict[str, str] = {
    "retract": "伸缩杆缩回",
    "pulse_a": "模拟【按键B】",
    "focus_window": "获取窗口",
    "send_hotkey": "按键操作",
    "restore_app": "回到窗口",
    "extend": "伸缩杆伸出",
    "pulse_b": "模拟【按键A】",
    "wait": "等待",
    "confirm_dialog": "弹窗确认",
}

DEFAULT_BUTTON_NAMES: dict[str, str] = {
    "button_a": "按键A",
    "button_b": "按键B",
}

DEFAULT_STEP_TABLE_COLUMNS: dict[str, int] = {
    "enable": 40,
    "name": 108,
    "settings": 220,
    "actions": 58,
}

MIN_STEP_TABLE_COLUMN_PX = 32
MAX_STEP_TABLE_COLUMN_PX = 480


def get_button_names(config: dict[str, Any] | None = None) -> dict[str, str]:
    raw = (config or {}).get("simulated_buttons", {})
    button_a = str(raw.get("button_a") or DEFAULT_BUTTON_NAMES["button_a"]).strip() or DEFAULT_BUTTON_NAMES["button_a"]
    button_b = str(raw.get("button_b") or DEFAULT_BUTTON_NAMES["button_b"]).strip() or DEFAULT_BUTTON_NAMES["button_b"]
    return {"button_a": button_a, "button_b": button_b}


def pulse_step_label(step_type: str, config: dict[str, Any] | None = None) -> str:
    names = get_button_names(config)
    if step_type == "pulse_a":
        return f"模拟【{names['button_b']}】"
    if step_type == "pulse_b":
        return f"模拟【{names['button_a']}】"
    return STEP_TYPE_LABELS.get(step_type, step_type)

DEFAULT_WORKFLOW_STEPS: list[dict[str, Any]] = [
    {"id": "step-retract", "type": "retract", "enabled": True, "label": "伸缩杆缩回", "duration_ms": 3000},
    {"id": "step-pulse-a", "type": "pulse_a", "enabled": True, "label": "模拟【按键B】", "duration_ms": 200},
    {
        "id": "step-focus",
        "type": "focus_window",
        "enabled": True,
        "label": "获取窗口",
        "window_keyword": "Cutting Master",
        "delay_ms": 800,
    },
    {
        "id": "step-hotkey",
        "type": "send_hotkey",
        "enabled": True,
        "label": "按键操作",
        "hotkey": "ctrl+p",
        "delay_ms": 200,
        "press_count": 1,
        "press_interval_ms": 0,
    },
    {"id": "step-cut-wait", "type": "wait", "enabled": True, "label": "等待切割", "duration_ms": 6000, "note": "等待切割机完成"},
    {"id": "step-extend", "type": "extend", "enabled": True, "label": "伸缩杆伸出", "duration_ms": 3000},
    {"id": "step-pulse-b", "type": "pulse_b", "enabled": True, "label": "模拟【按键A】", "duration_ms": 200},
]

FOCUS_WINDOW_DEFAULTS: dict[str, Any] = {
    "window_keyword": "Cutting Master",
    "delay_ms": 800,
}

SEND_HOTKEY_DEFAULTS: dict[str, Any] = {
    "hotkey": "ctrl+p",
    "delay_ms": 200,
    "press_count": 1,
    "press_interval_ms": 0,
}

RESTORE_APP_DEFAULTS: dict[str, Any] = {
    "window_keyword": "CutPPaper",
    "delay_ms": 0,
}

STEP_DELAY_DEFAULT_MS = 0


def step_delay_ms_from_raw(raw: dict[str, Any], step_type: str, timings: dict[str, Any]) -> int:
    if "delay_ms" in raw:
        return max(0, int(raw.get("delay_ms") or 0))
    if step_type == "focus_window":
        return max(
            0,
            int(
                raw.get(
                    "focus_timeout_ms",
                    raw.get("before_send_ms", timings.get("before_send_keys", FOCUS_WINDOW_DEFAULTS["delay_ms"])),
                )
            ),
        )
    if step_type == "send_hotkey":
        return max(
            0,
            int(
                raw.get(
                    "delay_after_ms",
                    raw.get("after_hotkey_ms", timings.get("after_hotkey_ms", SEND_HOTKEY_DEFAULTS["delay_ms"])),
                )
            ),
        )
    return STEP_DELAY_DEFAULT_MS

CONFIRM_DIALOG_DEFAULTS: dict[str, Any] = {
    "prompt_text": "请确认后继续",
}

WAIT_DEFAULTS: dict[str, Any] = {
    "duration_ms": 1000,
    "note": "",
}

STEP_DURATION_DEFAULTS: dict[str, int] = {
    "retract": 3000,
    "extend": 3000,
    "pulse_a": 200,
    "pulse_b": 200,
}

LEGACY_TIMING_KEYS: dict[str, str] = {
    "retract": "retract",
    "extend": "extend",
    "pulse_a": "relay_pulse",
    "pulse_b": "relay_pulse",
}

SEND_CUT_DEFAULTS: dict[str, Any] = {
    **FOCUS_WINDOW_DEFAULTS,
    **SEND_HOTKEY_DEFAULTS,
    "send_hotkey": "ctrl+p",
    "before_send_ms": 800,
    "after_focus_ms": 100,
    "after_hotkey_ms": 200,
}


def _expand_legacy_steps(steps: list[dict[str, Any]]) -> list[dict[str, Any]]:
    expanded: list[dict[str, Any]] = []
    for raw in steps:
        if str(raw.get("type", "")).strip() != "send_cut":
            expanded.append(raw)
            continue
        base_id = str(raw.get("id") or f"step-legacy-{len(expanded)}")
        expanded.append(
            {
                "id": f"{base_id}-focus",
                "type": "focus_window",
                "enabled": raw.get("enabled", True),
                "label": "获取窗口",
                "window_keyword": raw.get("window_keyword"),
                "delay_ms": raw.get(
                    "before_send_ms",
                    raw.get("before_send_keys", raw.get("focus_timeout_ms", raw.get("delay_ms", 800))),
                ),
            }
        )
        expanded.append(
            {
                "id": f"{base_id}-hotkey",
                "type": "send_hotkey",
                "enabled": raw.get("enabled", True),
                "label": "按键操作",
                "hotkey": raw.get("hotkey") or raw.get("send_hotkey"),
                "delay_ms": raw.get("after_hotkey_ms", raw.get("delay_after_ms", raw.get("delay_ms", 200))),
                "press_count": raw.get("press_count", 1),
                "press_interval_ms": raw.get("press_interval_ms", 0),
            }
        )
    return expanded

DEFAULT_CONFIG: dict[str, Any] = {
    "serial": {
        "port": "COM3",
        "baudrate": 115200,
        "timeout_ms": 2000,
    },
    "timings_ms": {
        "retract": 3000,
        "extend": 3000,
        "relay_pulse": 200,
        "before_send_keys": 800,
        "after_focus_ms": 100,
        "after_hotkey_ms": 200,
    },
    "cutting_master": {
        "window_title_contains": "Cutting Master",
        "send_hotkey": "ctrl+p",
    },
    "simulated_buttons": deepcopy(DEFAULT_BUTTON_NAMES),
    "app": {
        "simulation_mode": False,
        "auto_loop": False,
        "loop_interval_ms": 3000,
        "start_hotkey": "f5",
    },
    "ui": {
        "step_table_columns": deepcopy(DEFAULT_STEP_TABLE_COLUMNS),
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
    for key in ("retract", "extend", "before_send_keys", "after_focus_ms", "after_hotkey_ms"):
        value = timings.get(key)
        if not isinstance(value, int) or not (0 <= value <= MAX_TIMING_MS):
            errors.append(f"时序 {key} 必须是 0–{MAX_TIMING_MS} 的整数")

    relay_pulse = timings.get("relay_pulse")
    if not isinstance(relay_pulse, int) or not (MIN_RELAY_PULSE_MS <= relay_pulse <= MAX_RELAY_PULSE_MS):
        errors.append(
            f"继电器脉冲 relay_pulse 必须是 {MIN_RELAY_PULSE_MS}–{MAX_RELAY_PULSE_MS} 的整数"
        )

    cm = config.get("cutting_master", {})
    steps_for_cm = config.get("workflow_steps") or []
    focus_steps = [step for step in steps_for_cm if step.get("type") == "focus_window"]
    hotkey_steps = [step for step in steps_for_cm if step.get("type") == "send_hotkey"]
    if focus_steps:
        keyword = str(focus_steps[0].get("window_keyword") or cm.get("window_title_contains", "")).strip()
    else:
        keyword = str(cm.get("window_title_contains", "")).strip()
    if hotkey_steps:
        hotkey = str(hotkey_steps[0].get("hotkey") or cm.get("send_hotkey", "")).strip()
    else:
        hotkey = str(cm.get("send_hotkey", "")).strip()
    if focus_steps and len(keyword) < 2:
        errors.append("获取窗口步骤 window_keyword 至少需要 2 个字符")
    if hotkey_steps and not hotkey:
        errors.append("按键操作步骤 hotkey 不能为空")

    app_cfg = config.get("app", {})
    if not isinstance(app_cfg.get("simulation_mode"), bool):
        errors.append("simulation_mode 必须是布尔值")
    if not isinstance(app_cfg.get("auto_loop"), bool):
        errors.append("auto_loop 必须是布尔值")

    loop_interval_ms = app_cfg.get("loop_interval_ms")
    if not isinstance(loop_interval_ms, int) or not (0 <= loop_interval_ms <= MAX_TIMING_MS):
        errors.append(f"轮间间隔 loop_interval_ms 必须是 0–{MAX_TIMING_MS} 的整数")

    buttons = config.get("simulated_buttons", {})
    for key, default in DEFAULT_BUTTON_NAMES.items():
        value = str(buttons.get(key, default)).strip()
        if not value:
            errors.append(f"simulated_buttons.{key} 不能为空")
        elif len(value) > 16:
            errors.append(f"simulated_buttons.{key} 不能超过 16 个字符")

    ui_cfg = config.get("ui", {})
    columns = ui_cfg.get("step_table_columns", {})
    if columns is not None:
        if not isinstance(columns, dict):
            errors.append("ui.step_table_columns 必须是对象")
        else:
            for key, default in DEFAULT_STEP_TABLE_COLUMNS.items():
                value = columns.get(key, default)
                if not isinstance(value, int) or not (MIN_STEP_TABLE_COLUMN_PX <= value <= MAX_STEP_TABLE_COLUMN_PX):
                    errors.append(
                        f"ui.step_table_columns.{key} 必须是 "
                        f"{MIN_STEP_TABLE_COLUMN_PX}–{MAX_STEP_TABLE_COLUMN_PX} 的整数"
                    )

    if not app_cfg.get("simulation_mode", False):
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
            if step_type == "send_cut":
                errors.append(f"{prefix} type 已废弃，请改用 focus_window + send_hotkey")
                continue
            if step_type not in STEP_TYPES:
                errors.append(f"{prefix} type 无效: {step_type}")
                continue

            if not isinstance(step.get("enabled"), bool):
                errors.append(f"{prefix} enabled 必须是布尔值")

            label = str(step.get("label", "")).strip()
            if not label:
                errors.append(f"{prefix} label 不能为空")

            if step_type == "focus_window":
                window_keyword = str(step.get("window_keyword", "")).strip()
                if len(window_keyword) < 2:
                    errors.append(f"{prefix} window_keyword 至少需要 2 个字符")
            elif step_type == "send_hotkey":
                hotkey_value = str(step.get("hotkey", "")).strip()
                if not hotkey_value:
                    errors.append(f"{prefix} hotkey 不能为空")
                for field in ("press_interval_ms",):
                    value = step.get(field)
                    if not isinstance(value, int) or not (0 <= value <= MAX_TIMING_MS):
                        errors.append(f"{prefix} {field} 必须是 0–{MAX_TIMING_MS} 的整数")
                press_count = step.get("press_count")
                if not isinstance(press_count, int) or not (1 <= press_count <= 50):
                    errors.append(f"{prefix} press_count 必须是 1–50 的整数")
            elif step_type == "restore_app":
                window_keyword = str(step.get("window_keyword", RESTORE_APP_DEFAULTS["window_keyword"])).strip()
                if len(window_keyword) < 2:
                    errors.append(f"{prefix} window_keyword 至少需要 2 个字符")
            elif step_type == "confirm_dialog":
                prompt_text = str(step.get("prompt_text", "")).strip()
                if not prompt_text:
                    errors.append(f"{prefix} prompt_text 不能为空")
                elif len(prompt_text) > 500:
                    errors.append(f"{prefix} prompt_text 不能超过 500 个字符")
            elif step_type == "wait":
                duration_ms = step.get("duration_ms")
                if not isinstance(duration_ms, int) or not (0 <= duration_ms <= MAX_TIMING_MS):
                    errors.append(f"{prefix} duration_ms 必须是 0–{MAX_TIMING_MS} 的整数")
            elif step_type in STEP_DURATION_DEFAULTS:
                duration_ms = step.get("duration_ms")
                if step_type in ("pulse_a", "pulse_b"):
                    valid = (
                        isinstance(duration_ms, int)
                        and MIN_RELAY_PULSE_MS <= duration_ms <= MAX_RELAY_PULSE_MS
                    )
                    if not valid:
                        errors.append(
                            f"{prefix} duration_ms 必须是 {MIN_RELAY_PULSE_MS}–{MAX_RELAY_PULSE_MS} 的整数"
                        )
                elif not isinstance(duration_ms, int) or not (0 <= duration_ms <= MAX_TIMING_MS):
                    errors.append(f"{prefix} duration_ms 必须是 0–{MAX_TIMING_MS} 的整数")

            note = str(step.get("note", "")).strip()
            if len(note) > 500:
                errors.append(f"{prefix} note 不能超过 500 个字符")

            delay_ms = step.get("delay_ms")
            if not isinstance(delay_ms, int) or not (0 <= delay_ms <= MAX_TIMING_MS):
                errors.append(f"{prefix} delay_ms 必须是 0–{MAX_TIMING_MS} 的整数")

    return errors


def normalize_workflow_steps(
    steps: list[dict[str, Any]] | None,
    config: dict[str, Any] | None = None,
) -> list[dict[str, Any]]:
    config = config or {}
    timings = config.get("timings_ms", {})
    cm = config.get("cutting_master", {})
    source = steps if isinstance(steps, list) and steps else deepcopy(DEFAULT_WORKFLOW_STEPS)
    source = _expand_legacy_steps(source)
    normalized: list[dict[str, Any]] = []

    for raw in source:
        step_type = str(raw.get("type", "")).strip()
        if step_type == "cut_wait":
            raw = {
                **raw,
                "type": "wait",
                "note": str(raw.get("note") or raw.get("label") or "等待切割").strip(),
            }
            step_type = "wait"
        if step_type not in STEP_TYPES:
            continue
        label = str(raw.get("label") or STEP_TYPE_LABELS.get(step_type, step_type)).strip()
        if step_type in ("pulse_a", "pulse_b"):
            label = pulse_step_label(step_type, config)
        elif step_type == "send_hotkey" and label == "发送快捷键":
            label = STEP_TYPE_LABELS["send_hotkey"]
        elif step_type == "restore_app" and label in ("回到本窗口", "回到本程序"):
            label = STEP_TYPE_LABELS["restore_app"]
        item: dict[str, Any] = {
            "id": str(raw.get("id") or f"step-{len(normalized)}"),
            "type": step_type,
            "enabled": raw.get("enabled") is not False,
            "label": label,
        }
        if step_type == "focus_window":
            item["window_keyword"] = str(
                raw.get("window_keyword") or cm.get("window_title_contains") or FOCUS_WINDOW_DEFAULTS["window_keyword"]
            ).strip()
        elif step_type == "send_hotkey":
            item["hotkey"] = str(
                raw.get("hotkey") or raw.get("send_hotkey") or cm.get("send_hotkey") or SEND_HOTKEY_DEFAULTS["hotkey"]
            ).strip()
            item["press_count"] = int(raw.get("press_count", SEND_HOTKEY_DEFAULTS["press_count"]))
            item["press_interval_ms"] = int(
                raw.get("press_interval_ms", SEND_HOTKEY_DEFAULTS["press_interval_ms"])
            )
        elif step_type == "restore_app":
            item["window_keyword"] = str(
                raw.get("window_keyword") or RESTORE_APP_DEFAULTS["window_keyword"]
            ).strip()
        elif step_type == "confirm_dialog":
            item["prompt_text"] = str(
                raw.get("prompt_text") or raw.get("message") or CONFIRM_DIALOG_DEFAULTS["prompt_text"]
            ).strip() or CONFIRM_DIALOG_DEFAULTS["prompt_text"]
        elif step_type == "wait":
            item["duration_ms"] = int(
                raw.get(
                    "duration_ms",
                    timings.get("cut_wait", timings.get("wait", WAIT_DEFAULTS["duration_ms"])),
                )
            )
        elif step_type in STEP_DURATION_DEFAULTS:
            legacy_key = LEGACY_TIMING_KEYS.get(step_type, step_type)
            item["duration_ms"] = int(
                raw.get("duration_ms", timings.get(legacy_key, STEP_DURATION_DEFAULTS[step_type]))
            )
        item["delay_ms"] = step_delay_ms_from_raw(raw, step_type, timings)
        item["note"] = str(raw.get("note", WAIT_DEFAULTS["note"])).strip()
        normalized.append(item)

    return normalized or deepcopy(DEFAULT_WORKFLOW_STEPS)


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
    config["workflow_steps"] = normalize_workflow_steps(config.get("workflow_steps"), config)
    first_focus = next((step for step in config["workflow_steps"] if step.get("type") == "focus_window"), None)
    first_hotkey = next((step for step in config["workflow_steps"] if step.get("type") == "send_hotkey"), None)
    config.setdefault("cutting_master", {})
    if first_focus:
        config["cutting_master"]["window_title_contains"] = first_focus.get("window_keyword", "")
    if first_hotkey:
        config["cutting_master"]["send_hotkey"] = first_hotkey.get("hotkey", "ctrl+p")
    config.setdefault("ui", {})
    raw_columns = config["ui"].get("step_table_columns") or {}
    normalized_columns: dict[str, int] = {}
    for key, default in DEFAULT_STEP_TABLE_COLUMNS.items():
        try:
            value = int(raw_columns.get(key, default))
        except (TypeError, ValueError):
            value = default
        normalized_columns[key] = max(MIN_STEP_TABLE_COLUMN_PX, min(MAX_STEP_TABLE_COLUMN_PX, value))
    config["ui"]["step_table_columns"] = normalized_columns
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
