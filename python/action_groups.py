from __future__ import annotations

import json
import re
import time
from copy import deepcopy
from pathlib import Path
from typing import Any

from config import project_root, validate_config

ACTION_GROUPS_DIR_NAME = "action_groups"
MAX_GROUP_NAME_LEN = 64
SAFE_NAME_RE = re.compile(r"^[\w\u4e00-\u9fff\- ]+$", re.UNICODE)


def action_groups_dir() -> Path:
    path = project_root() / ACTION_GROUPS_DIR_NAME
    path.mkdir(parents=True, exist_ok=True)
    return path


def _normalize_name(name: str) -> str:
    cleaned = str(name or "").strip()
    if not cleaned:
        raise ValueError("动作组名称不能为空")
    if len(cleaned) > MAX_GROUP_NAME_LEN:
        raise ValueError(f"动作组名称不能超过 {MAX_GROUP_NAME_LEN} 个字符")
    if not SAFE_NAME_RE.match(cleaned):
        raise ValueError("动作组名称仅支持中文、字母、数字、空格、- 和 _")
    return cleaned


def _group_path(name: str) -> Path:
    safe = _normalize_name(name)
    return action_groups_dir() / f"{safe}.json"


def _clone_steps(steps: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return deepcopy(steps)


def list_action_groups() -> list[dict[str, Any]]:
    groups: list[dict[str, Any]] = []
    for file_path in sorted(action_groups_dir().glob("*.json")):
        try:
            with file_path.open("r", encoding="utf-8") as fp:
                payload = json.load(fp)
        except (OSError, json.JSONDecodeError):
            continue

        name = str(payload.get("name") or file_path.stem)
        steps = payload.get("workflow_steps")
        if not isinstance(steps, list):
            continue

        stat = file_path.stat()
        groups.append(
            {
                "name": name,
                "filename": file_path.name,
                "step_count": len(steps),
                "updated_at": int(stat.st_mtime * 1000),
            }
        )
    groups.sort(key=lambda item: item["name"].lower())
    return groups


def save_action_group(name: str, workflow_steps: list[dict[str, Any]]) -> dict[str, Any]:
    normalized = _normalize_name(name)
    if not isinstance(workflow_steps, list) or len(workflow_steps) == 0:
        raise ValueError("动作组至少包含一个步骤")

    probe = {"workflow_steps": _clone_steps(workflow_steps)}
    errors = validate_config(
        {
            "serial": {"port": "COM3", "baudrate": 115200, "timeout_ms": 2000},
            "timings_ms": {
                "retract": 0,
                "extend": 0,
                "cut_wait": 0,
                "relay_pulse": 50,
                "before_send_keys": 0,
                "after_focus_ms": 0,
                "after_hotkey_ms": 0,
            },
            "cutting_master": {"window_title_contains": "Cutting Master", "send_hotkey": "ctrl+p"},
            "app": {
                "simulation_mode": True,
                "simulate_cut": True,
                "auto_loop": False,
                "loop_interval_ms": 0,
            },
            "workflow_steps": probe["workflow_steps"],
        }
    )
    if errors:
        raise ValueError("; ".join(errors))

    payload = {
        "name": normalized,
        "saved_at": int(time.time() * 1000),
        "workflow_steps": _clone_steps(workflow_steps),
    }
    file_path = _group_path(normalized)
    tmp_path = file_path.with_suffix(".json.tmp")
    with tmp_path.open("w", encoding="utf-8") as fp:
        json.dump(payload, fp, indent=2, ensure_ascii=False)
        fp.write("\n")
    tmp_path.replace(file_path)
    return payload


def load_action_group(name: str) -> dict[str, Any]:
    file_path = _group_path(name)
    if not file_path.exists():
        raise FileNotFoundError(f"动作组不存在: {name}")

    with file_path.open("r", encoding="utf-8") as fp:
        payload = json.load(fp)

    steps = payload.get("workflow_steps")
    if not isinstance(steps, list) or len(steps) == 0:
        raise ValueError("动作组文件无效或步骤为空")

    normalized = _normalize_name(str(payload.get("name") or name))
    return {
        "name": normalized,
        "workflow_steps": _clone_steps(steps),
    }
