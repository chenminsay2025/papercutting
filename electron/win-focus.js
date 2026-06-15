const koffi = require("koffi");

const user32 = koffi.load("user32.dll");

const SetForegroundWindow = user32.func("bool __stdcall SetForegroundWindow(void *hwnd)");
const ShowWindow = user32.func("int __stdcall ShowWindow(void *hwnd, int nCmdShow)");
const GetForegroundWindow = user32.func("void * __stdcall GetForegroundWindow()");
const BringWindowToTop = user32.func("bool __stdcall BringWindowToTop(void *hwnd)");
const AllowSetForegroundWindow = user32.func("bool __stdcall AllowSetForegroundWindow(uint32 dwProcessId)");
const AttachThreadInput = user32.func("bool __stdcall AttachThreadInput(uint32 idAttach, uint32 idAttachTo, bool fAttach)");
const GetWindowThreadProcessId = user32.func(
  "uint32 __stdcall GetWindowThreadProcessId(void *hwnd, _Out_ uint32 *lpdwProcessId)"
);
const keybd_event = user32.func(
  "void __stdcall keybd_event(uint8 bVk, uint8 bScan, uint32 dwFlags, uintptr dwExtraInfo)"
);
const IsIconic = user32.func("bool __stdcall IsIconic(void *hwnd)");

const SW_RESTORE = 9;
const SW_SHOW = 5;
const VK_MENU = 0x12;
const KEYEVENTF_KEYUP = 0x0002;
const ASFW_ANY = 0xffffffff;

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function getWindowHwnd(win) {
  const buf = win.getNativeWindowHandle();
  if (process.arch === "x64") {
    return koffi.decode(buf, "void *");
  }
  return koffi.decode(buf, "void *");
}

function pointersEqual(a, b) {
  if (!a || !b) return false;
  try {
    return koffi.address(a) === koffi.address(b);
  } catch (_err) {
    return a === b;
  }
}

function isForeground(hwnd) {
  try {
    return pointersEqual(GetForegroundWindow(), hwnd);
  } catch (_err) {
    return false;
  }
}

function altKeyPulse() {
  keybd_event(VK_MENU, 0, 0, 0);
  keybd_event(VK_MENU, 0, KEYEVENTF_KEYUP, 0);
}

function forceForegroundOnce(hwnd) {
  AllowSetForegroundWindow(ASFW_ANY);

  if (IsIconic(hwnd)) {
    ShowWindow(hwnd, SW_RESTORE);
  } else {
    ShowWindow(hwnd, SW_SHOW);
  }

  const foreground = GetForegroundWindow();
  let attached = false;
  let fgTid = 0;
  let tgTid = 0;

  try {
    if (foreground && !pointersEqual(foreground, hwnd)) {
      const fgPidOut = [0];
      const tgPidOut = [0];
      fgTid = GetWindowThreadProcessId(foreground, fgPidOut);
      tgTid = GetWindowThreadProcessId(hwnd, tgPidOut);
      if (fgTid && tgTid && fgTid !== tgTid) {
        attached = AttachThreadInput(fgTid, tgTid, true);
      }
    }

    altKeyPulse();
    SetForegroundWindow(hwnd);
    BringWindowToTop(hwnd);
    SetForegroundWindow(hwnd);
  } finally {
    if (attached && fgTid && tgTid) {
      AttachThreadInput(fgTid, tgTid, false);
    }
  }

  return isForeground(hwnd);
}

async function forceWindowForeground(win, retries = 3) {
  if (process.platform !== "win32" || !win || win.isDestroyed()) {
    return Boolean(win && !win.isDestroyed() && win.isFocused());
  }

  const hwnd = getWindowHwnd(win);
  if (!hwnd) {
    return false;
  }

  for (let attempt = 0; attempt < retries; attempt += 1) {
    if (forceForegroundOnce(hwnd)) {
      return true;
    }
    await sleep(100);
  }

  return isForeground(hwnd);
}

module.exports = {
  forceWindowForeground,
  getWindowHwnd,
  isForeground,
};
