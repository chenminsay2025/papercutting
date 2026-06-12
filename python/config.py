from __future__ import annotations

import json
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


def project_root() -> Path:
    return Path(__file__).resolve().parent.parent


def config_path() -> Path:
    return project_root() / "config.json"


def load_config() -> dict[str, Any]:
    path = config_path()
    config = deepcopy(DEFAULT_CONFIG)
    if path.exists():
        with path.open("r", encoding="utf-8") as fp:
            loaded = json.load(fp)
        _deep_merge(config, loaded)
    return config


def save_config(config: dict[str, Any]) -> None:
    path = config_path()
    with path.open("w", encoding="utf-8") as fp:
        json.dump(config, fp, indent=2, ensure_ascii=False)
        fp.write("\n")


def _deep_merge(base: dict[str, Any], override: dict[str, Any]) -> None:
    for key, value in override.items():
        if isinstance(value, dict) and isinstance(base.get(key), dict):
            _deep_merge(base[key], value)
        else:
            base[key] = value
