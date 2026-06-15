from __future__ import annotations

import json
import os
import re
import shutil
import time
from copy import deepcopy
from pathlib import Path
from typing import Any

from config import project_root, validate_config

ACTION_GROUPS_DIR_NAME = "action_groups"
MAX_GROUP_NAME_LEN = 64
SAFE_NAME_RE = re.compile(r"^[\w\u4e00-\u9fff\- ]+$", re.UNICODE)


def bundled_groups_dir() -> Path:
    return project_root() / ACTION_GROUPS_DIR_NAME


def action_groups_dir() -> Path:
    override = os.environ.get("CUTPPAPER_ACTION_GROUPS_DIR", "").strip()
    path = Path(override) if override else bundled_groups_dir()
    path.mkdir(parents=True, exist_ok=True)
    return path


def ensure_internal_groups_seeded() -> None:
    internal = action_groups_dir()
    if any(internal.glob("*.json")):
        return
    bundled = bundled_groups_dir()
    if not bundled.is_dir():
        return
    for src in bundled.glob("*.json"):
        dst = internal / src.name
        if not dst.exists():
            shutil.copy2(src, dst)


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


def _validate_steps(workflow_steps: list[dict[str, Any]]) -> None:
    if not isinstance(workflow_steps, list) or len(workflow_steps) == 0:
        raise ValueError("动作组至少包含一个步骤")
    errors = validate_config(
        {
            "serial": {"port": "COM3", "baudrate": 115200, "timeout_ms": 2000},
            "timings_ms": {
                "retract": 0,
                "extend": 0,
                "relay_pulse": 50,
                "before_send_keys": 0,
                "after_focus_ms": 0,
                "after_hotkey_ms": 0,
            },
            "cutting_master": {"window_title_contains": "Cutting Master", "send_hotkey": "ctrl+p"},
            "app": {
                "simulation_mode": False,
                "auto_loop": False,
                "loop_interval_ms": 0,
            },
            "workflow_steps": _clone_steps(workflow_steps),
        }
    )
    if errors:
        raise ValueError("; ".join(errors))


def _build_payload(name: str, workflow_steps: list[dict[str, Any]]) -> dict[str, Any]:
    normalized = _normalize_name(name)
    _validate_steps(workflow_steps)
    return {
        "name": normalized,
        "saved_at": int(time.time() * 1000),
        "workflow_steps": _clone_steps(workflow_steps),
    }


def _write_payload(file_path: Path, payload: dict[str, Any]) -> None:
    file_path.parent.mkdir(parents=True, exist_ok=True)
    tmp_path = file_path.with_suffix(file_path.suffix + ".tmp")
    with tmp_path.open("w", encoding="utf-8") as fp:
        json.dump(payload, fp, indent=2, ensure_ascii=False)
        fp.write("\n")
    tmp_path.replace(file_path)


def _read_payload(file_path: Path, *, fallback_name: str = "") -> dict[str, Any]:
    if not file_path.is_file():
        raise FileNotFoundError(f"动作组文件不存在: {file_path}")

    with file_path.open("r", encoding="utf-8") as fp:
        payload = json.load(fp)

    steps = payload.get("workflow_steps")
    if not isinstance(steps, list) or len(steps) == 0:
        raise ValueError("动作组文件无效或步骤为空")

    normalized = _normalize_name(str(payload.get("name") or fallback_name or file_path.stem))
    return {
        "name": normalized,
        "workflow_steps": _clone_steps(steps),
    }


def list_action_groups() -> list[dict[str, Any]]:
    ensure_internal_groups_seeded()
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
                "storage": "internal",
            }
        )
    groups.sort(key=lambda item: item["name"].lower())
    return groups


def save_action_group(name: str, workflow_steps: list[dict[str, Any]]) -> dict[str, Any]:
    payload = _build_payload(name, workflow_steps)
    _write_payload(_group_path(payload["name"]), payload)
    return payload


def load_action_group(name: str) -> dict[str, Any]:
    ensure_internal_groups_seeded()
    return _read_payload(_group_path(name), fallback_name=name)


def export_action_group(file_path: str, name: str, workflow_steps: list[dict[str, Any]]) -> dict[str, Any]:
    payload = _build_payload(name, workflow_steps)
    target = Path(str(file_path or "").strip())
    if not target.suffix:
        target = target.with_suffix(".json")
    _write_payload(target, payload)
    return {**payload, "file_path": str(target)}


def delete_action_group(name: str) -> str:
    file_path = _group_path(name)
    if not file_path.is_file():
        raise FileNotFoundError(f"动作组不存在: {name}")
    normalized = _normalize_name(str(name))
    file_path.unlink()
    return normalized


def export_saved_action_group(name: str, file_path: str) -> dict[str, Any]:
    payload = load_action_group(name)
    return export_action_group(file_path, payload["name"], payload["workflow_steps"])


def import_action_group(file_path: str) -> dict[str, Any]:
    target = Path(str(file_path or "").strip())
    payload = _read_payload(target)
    return {**payload, "file_path": str(target)}
