from __future__ import annotations

import time


def _find_window(title_keyword: str):
    import win32gui

    keyword = title_keyword.lower()
    matches: list[tuple[int, str]] = []

    def callback(hwnd, _extra):
        if not win32gui.IsWindowVisible(hwnd):
            return True
        title = win32gui.GetWindowText(hwnd)
        if title and keyword in title.lower():
            matches.append((hwnd, title))
        return True

    win32gui.EnumWindows(callback, None)
    if not matches:
        raise RuntimeError(f"未找到窗口，关键字: {title_keyword}")
    return matches[0]


def focus_cutting_master(window_title_contains: str) -> str:
    hwnd, title = _find_window(window_title_contains)
    import win32gui
    import win32con

    if win32gui.IsIconic(hwnd):
        win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
    win32gui.SetForegroundWindow(hwnd)

    deadline = time.monotonic() + 1.0
    while time.monotonic() < deadline:
        if win32gui.GetForegroundWindow() == hwnd:
            time.sleep(0.05)
            return title
        time.sleep(0.05)

    raise RuntimeError(f"无法将窗口置于前台: {title}")


def send_hotkey(hotkey: str) -> None:
    import keyboard

    keyboard.send(hotkey)


def send_cut_job(window_title_contains: str, hotkey: str, before_send_ms: int) -> str:
    title = focus_cutting_master(window_title_contains)
    if before_send_ms > 0:
        time.sleep(before_send_ms / 1000.0)
    send_hotkey(hotkey)
    return title
