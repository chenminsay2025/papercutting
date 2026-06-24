from __future__ import annotations

import ctypes
import time


def list_open_windows(max_count: int = 100) -> list[str]:
    """列出当前可见窗口标题（去重、排序）。"""
    import win32gui

    titles: list[str] = []
    seen: set[str] = set()

    def callback(hwnd, _extra):
        if len(titles) >= max_count:
            return False
        if not win32gui.IsWindowVisible(hwnd):
            return True
        title = win32gui.GetWindowText(hwnd).strip()
        if not title or title in seen:
            return True
        seen.add(title)
        titles.append(title)
        return True

    win32gui.EnumWindows(callback, None)
    titles.sort(key=str.lower)
    return titles


def is_app_window_keyword(keyword: str) -> bool:
    return "cutppaper" in str(keyword or "").lower()


def _list_visible_titles(max_count: int = 12) -> list[str]:
    import win32gui

    titles: list[str] = []

    def callback(hwnd, _extra):
        if len(titles) >= max_count:
            return False
        if not win32gui.IsWindowVisible(hwnd):
            return True
        title = win32gui.GetWindowText(hwnd).strip()
        if title:
            titles.append(title)
        return True

    win32gui.EnumWindows(callback, None)
    return titles


def _find_window(title_keyword: str):
    import win32gui

    keyword = title_keyword.lower().strip()
    if len(keyword) < 2:
        raise RuntimeError("窗口关键字至少需要 2 个字符")

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
        samples = _list_visible_titles(8)
        sample_text = "、".join(samples) if samples else "（无可见窗口）"
        raise RuntimeError(
            f"未找到窗口，关键字: {title_keyword}。"
            f"请修改步骤中的窗口关键字后点「窗」测试。"
            f"可见窗口示例: {sample_text}"
        )
    return matches[0]


def _allow_set_foreground() -> None:
    try:
        ctypes.windll.user32.AllowSetForegroundWindow(ctypes.c_uint(-1))
    except Exception:
        pass


def _alt_key_pulse() -> None:
    KEYEVENTF_KEYUP = 0x0002
    VK_MENU = 0x12
    user32 = ctypes.windll.user32
    user32.keybd_event(VK_MENU, 0, 0, 0)
    user32.keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, 0)


def _force_foreground(hwnd: int) -> bool:
    import win32con
    import win32gui
    import win32process

    if win32gui.GetForegroundWindow() == hwnd:
        return True

    _allow_set_foreground()

    if win32gui.IsIconic(hwnd):
        win32gui.ShowWindow(hwnd, win32con.SW_RESTORE)
    else:
        win32gui.ShowWindow(hwnd, win32con.SW_SHOW)

    try:
        win32gui.SetWindowPos(
            hwnd,
            win32con.HWND_TOPMOST,
            0,
            0,
            0,
            0,
            win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_SHOWWINDOW,
        )
        win32gui.SetWindowPos(
            hwnd,
            win32con.HWND_NOTOPMOST,
            0,
            0,
            0,
            0,
            win32con.SWP_NOMOVE | win32con.SWP_NOSIZE | win32con.SWP_SHOWWINDOW,
        )
    except Exception:
        pass

    foreground = win32gui.GetForegroundWindow()
    attached = False
    fg_tid = tg_tid = 0
    try:
        if foreground and foreground != hwnd:
            fg_tid = win32process.GetWindowThreadProcessId(foreground)[0]
            tg_tid = win32process.GetWindowThreadProcessId(hwnd)[0]
            if fg_tid != tg_tid:
                win32process.AttachThreadInput(fg_tid, tg_tid, True)
                attached = True

        _alt_key_pulse()
        try:
            win32gui.SetForegroundWindow(hwnd)
        except Exception:
            pass
        win32gui.BringWindowToTop(hwnd)
        try:
            win32gui.SetForegroundWindow(hwnd)
        except Exception:
            pass
    finally:
        if attached:
            try:
                win32process.AttachThreadInput(fg_tid, tg_tid, False)
            except Exception:
                pass

    return win32gui.GetForegroundWindow() == hwnd


def _wait_foreground(hwnd: int, timeout_ms: int, poll_ms: int = 30) -> bool:
    import win32gui

    if timeout_ms <= 0:
        timeout_ms = 2000

    deadline = time.monotonic() + timeout_ms / 1000.0
    while time.monotonic() < deadline:
        if win32gui.GetForegroundWindow() == hwnd:
            return True
        _force_foreground(hwnd)
        time.sleep(poll_ms / 1000.0)
    return win32gui.GetForegroundWindow() == hwnd


def focus_cutting_master(window_title_contains: str) -> str:
    import win32gui

    hwnd, title = _find_window(window_title_contains)

    deadline = time.monotonic() + 2.0
    while time.monotonic() < deadline:
        if _force_foreground(hwnd):
            time.sleep(0.05)
            return title
        time.sleep(0.1)

    if win32gui.IsWindowVisible(hwnd):
        raise RuntimeError(
            f"已找到窗口「{title}」，但 Windows 阻止自动置顶。"
            f"请先手动点一下该窗口，再点「测试热键」或「开始本轮」。"
        )

    raise RuntimeError(f"无法激活窗口: {title}")


def _ensure_english_input() -> None:
    """关闭中文 IME 并切换到美式英文键盘，避免按键被输入法拦截。"""
    user32 = ctypes.windll.user32

    hwnd = user32.GetForegroundWindow()
    if hwnd:
        try:
            imm32 = ctypes.windll.imm32
            himc = imm32.ImmGetContext(hwnd)
            if himc:
                try:
                    if imm32.ImmGetOpenStatus(himc):
                        imm32.ImmSetOpenStatus(himc, False)
                finally:
                    imm32.ImmReleaseContext(hwnd, himc)
        except Exception:
            pass

    try:
        hkl = user32.LoadKeyboardLayoutW("00000409", 1)
        if hkl:
            user32.ActivateKeyboardLayout(hkl, 0)
    except Exception:
        pass

    time.sleep(0.02)


def send_hotkey(hotkey: str) -> None:
    import keyboard

    _ensure_english_input()
    keyboard.send(hotkey)


def press_hotkey_step(
    hotkey: str,
    delay_before_ms: int = 0,
    delay_after_ms: int = 0,
    press_count: int = 1,
    press_interval_ms: int = 0,
    window_title_contains: str | None = None,
) -> None:
    hotkey = str(hotkey or "").strip()
    if not hotkey:
        raise RuntimeError("按键不能为空")
    count = max(1, int(press_count or 1))
    interval_ms = max(0, int(press_interval_ms or 0))
    keyword = str(window_title_contains or "").strip()
    if delay_before_ms > 0:
        time.sleep(delay_before_ms / 1000.0)
    for index in range(count):
        send_hotkey_to_window(hotkey, keyword or None)
        if index < count - 1 and interval_ms > 0:
            time.sleep(interval_ms / 1000.0)
            if keyword:
                ensure_window_foreground(keyword)
    if delay_after_ms > 0:
        time.sleep(delay_after_ms / 1000.0)


WINDOW_ACTIVATION_TIMEOUT_MS = 2000


def ensure_window_foreground(
    window_title_contains: str,
    activation_timeout_ms: int = WINDOW_ACTIVATION_TIMEOUT_MS,
) -> str:
    import win32gui

    hwnd, title = _find_window(window_title_contains)
    _force_foreground(hwnd)
    if not _wait_foreground(hwnd, activation_timeout_ms):
        raise RuntimeError(f"无法激活窗口「{title}」")
    time.sleep(0.05)
    if win32gui.GetForegroundWindow() != hwnd:
        _force_foreground(hwnd)
        time.sleep(0.05)
    if win32gui.GetForegroundWindow() != hwnd:
        raise RuntimeError(f"无法激活窗口「{title}」，热键未发送")
    return title


def focus_window_step(
    window_title_contains: str,
    delay_after_ms: int = 0,
    activation_timeout_ms: int = WINDOW_ACTIVATION_TIMEOUT_MS,
) -> str:
    title = ensure_window_foreground(window_title_contains, activation_timeout_ms)
    if delay_after_ms > 0:
        time.sleep(delay_after_ms / 1000.0)
    return title


def send_hotkey_to_window(hotkey: str, window_title_contains: str | None = None) -> None:
    """发送热键。仅当指定 window_title_contains 时才激活该窗口，否则发到当前前台窗口。"""
    keyword = str(window_title_contains or "").strip()
    if keyword:
        ensure_window_foreground(keyword)
    send_hotkey(hotkey)


def send_cut_job(
    window_title_contains: str,
    hotkey: str,
    focus_timeout_ms: int,
    after_focus_ms: int = 0,
    after_hotkey_ms: int = 0,
) -> str:
    import win32gui

    hwnd, title = _find_window(window_title_contains)
    ensure_window_foreground(window_title_contains, focus_timeout_ms)
    if after_focus_ms > 0:
        time.sleep(after_focus_ms / 1000.0)
    send_hotkey_to_window(hotkey, window_title_contains)
    if after_hotkey_ms > 0:
        time.sleep(after_hotkey_ms / 1000.0)
    return title


def probe_cut_window(window_title_contains: str) -> str:
    """仅查找并激活窗口，不发送热键。"""
    return focus_cutting_master(window_title_contains)


def restore_window(title_keyword: str) -> str:
    """将指定窗口强制置前并夺回键盘焦点。"""
    keyword = str(title_keyword or "").strip()
    if len(keyword) < 2:
        raise RuntimeError("窗口关键字至少需要 2 个字符")
    return ensure_window_foreground(keyword)


def restore_app_window(title_keyword: str = "PaperCutting") -> str:
    """兼容旧调用。"""
    return restore_window(title_keyword)
