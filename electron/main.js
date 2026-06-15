const { app, BrowserWindow, ipcMain, dialog, Menu, screen, globalShortcut } = require("electron");
const path = require("path");
const fs = require("fs");
const { spawn } = require("child_process");
const readline = require("readline");
const { forceWindowForeground } = require("./win-focus");
const { toElectronAccelerator } = require("./hotkey");

let mainWindow = null;
let logWindow = null;
let pythonProcess = null;
let pythonReady = false;
const pendingRequests = new Map();
const logLines = [];

const MAIN_WINDOW_DEFAULTS = {
  width: 680,
  height: 820,
  minWidth: 560,
  minHeight: 640,
};

let saveMainWindowStateTimer = null;
let registeredStartHotkey = "";

function unregisterStartHotkey() {
  if (!registeredStartHotkey) {
    return;
  }
  globalShortcut.unregister(registeredStartHotkey);
  registeredStartHotkey = "";
}

function triggerStartCycleHotkey() {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send("start-cycle-hotkey");
  }
}

function applyStartHotkey(hotkey) {
  unregisterStartHotkey();
  const accelerator = toElectronAccelerator(hotkey);
  if (!accelerator) {
    return { ok: true, registered: false, accelerator: "" };
  }

  const registered = globalShortcut.register(accelerator, triggerStartCycleHotkey);
  if (registered) {
    registeredStartHotkey = accelerator;
    return { ok: true, registered: true, accelerator };
  }

  return { ok: false, registered: false, accelerator };
}

function appendLogLine(line) {
  logLines.push(line);
  if (logWindow && !logWindow.isDestroyed()) {
    logWindow.webContents.send("log-append", line);
  }
}

function openLogWindow() {
  if (logWindow && !logWindow.isDestroyed()) {
    if (logWindow.isMinimized()) {
      logWindow.restore();
    }
    logWindow.show();
    logWindow.focus();
    return;
  }

  const iconPath = path.join(__dirname, "assets", "icon.png");
  logWindow = new BrowserWindow({
    width: 560,
    height: 420,
    minWidth: 400,
    minHeight: 240,
    title: "CutPPaper 日志",
    icon: iconPath,
    autoHideMenuBar: true,
    webPreferences: {
      preload: path.join(__dirname, "log-preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
      devTools: true,
    },
  });

  attachDevToolsShortcuts(logWindow);
  logWindow.setMenuBarVisibility(false);
  logWindow.loadFile(path.join(__dirname, "renderer", "log.html"));
  logWindow.on("closed", () => {
    logWindow = null;
  });
  logWindow.webContents.on("did-finish-load", () => {
    if (logWindow && !logWindow.isDestroyed()) {
      logWindow.webContents.send("log-init", logLines.join("\n"));
    }
  });
}

function pythonScriptPath() {
  return path.join(__dirname, "..", "python", "controller.py");
}

function resolvePythonCommand() {
  if (process.env.CUTPPAPER_PYTHON) {
    return process.env.CUTPPAPER_PYTHON;
  }
  return process.platform === "win32" ? "python" : "python3";
}

function actionGroupsDir() {
  const dir = path.join(app.getPath("userData"), "action_groups");
  fs.mkdirSync(dir, { recursive: true });
  return dir;
}

function startPythonBackend() {
  if (pythonProcess) {
    return;
  }

  pythonReady = false;
  const child = spawn(resolvePythonCommand(), [pythonScriptPath()], {
    cwd: path.join(__dirname, ".."),
    stdio: ["pipe", "pipe", "pipe"],
    env: {
      ...process.env,
      PYTHONIOENCODING: "utf-8",
      CUTPPAPER_ACTION_GROUPS_DIR: actionGroupsDir(),
    },
  });

  pythonProcess = child;

  const rl = readline.createInterface({ input: child.stdout });
  rl.on("line", (line) => {
    let payload;
    try {
      payload = JSON.parse(line);
    } catch (_err) {
      sendToRenderer({ event: "log", level: "warn", message: `Python 输出: ${line}` });
      return;
    }

    if (payload.event === "ready") {
      pythonReady = true;
    }

    if (payload.id && pendingRequests.has(payload.id)) {
      const { resolve, timer } = pendingRequests.get(payload.id);
      clearTimeout(timer);
      pendingRequests.delete(payload.id);
      resolve(payload);
    }

    if (payload.event === "restore_focus_request") {
      void handleRestoreFocusRequest(payload);
    }

    sendToRenderer(payload);
  });

  child.stderr.on("data", (chunk) => {
    sendToRenderer({
      event: "log",
      level: "error",
      message: chunk.toString("utf-8").trim(),
    });
  });

  child.on("exit", (code) => {
    pythonProcess = null;
    pythonReady = false;
    pendingRequests.forEach(({ reject, timer }) => {
      clearTimeout(timer);
      reject(new Error("Python 后端已退出"));
    });
    pendingRequests.clear();
    sendToRenderer({
      event: "python_exit",
      code,
      message: `Python 后端已退出 (code=${code})`,
    });
  });
}

function sendToRenderer(payload) {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send("backend-event", payload);
  }
}

function sendCommand(message) {
  return new Promise((resolve, reject) => {
    if (!pythonProcess || !pythonProcess.stdin.writable) {
      reject(new Error("Python 后端未运行"));
      return;
    }

    const id = `${Date.now()}-${Math.random().toString(16).slice(2)}`;
    const payload = { ...message, id };
    const timer = setTimeout(() => {
      pendingRequests.delete(id);
      reject(new Error(`命令超时: ${message.cmd}`));
    }, 20000);

    pendingRequests.set(id, { resolve, reject, timer });
    pythonProcess.stdin.write(`${JSON.stringify(payload)}\n`, (err) => {
      if (err) {
        clearTimeout(timer);
        pendingRequests.delete(id);
        reject(err);
      }
    });
  });
}

function buildAppMenu() {
  const template = [
    {
      label: "文件",
      submenu: [{ role: "quit", label: "退出" }],
    },
    {
      label: "视图",
      submenu: [
        { role: "reload", label: "重新加载" },
        { role: "forceReload", label: "强制重新加载" },
        { type: "separator" },
        { role: "toggleDevTools", label: "开发者工具" },
        { type: "separator" },
        { role: "resetZoom", label: "实际大小" },
        { role: "zoomIn", label: "放大" },
        { role: "zoomOut", label: "缩小" },
        { type: "separator" },
        { role: "togglefullscreen", label: "全屏" },
      ],
    },
  ];

  if (process.platform === "darwin") {
    template.unshift({
      label: app.name,
      submenu: [
        { role: "about", label: `关于 ${app.name}` },
        { type: "separator" },
        { role: "quit", label: `退出 ${app.name}` },
      ],
    });
    template.splice(1, 1);
  }

  return Menu.buildFromTemplate(template);
}

function attachDevToolsShortcuts(win) {
  if (!win) return;
  win.webContents.on("before-input-event", (_event, input) => {
    if (input.type !== "keyDown") return;
    const key = String(input.key || "").toLowerCase();
    const openDevTools =
      key === "f12" ||
      (input.control && input.shift && key === "i") ||
      (input.meta && input.alt && key === "i");
    if (openDevTools) {
      win.webContents.toggleDevTools();
    }
  });
}

function mainWindowStatePath() {
  return path.join(app.getPath("userData"), "window-state.json");
}

function clampWindowSize(value, min, max, fallback) {
  const num = Number(value);
  if (!Number.isFinite(num)) return fallback;
  return Math.max(min, Math.min(max, Math.round(num)));
}

function ensureWindowStateOnScreen(state) {
  if (state.x === undefined || state.y === undefined) {
    return state;
  }

  const bounds = {
    x: state.x,
    y: state.y,
    width: state.width,
    height: state.height,
  };

  const visible = screen.getAllDisplays().some((display) => {
    const area = display.workArea;
    return (
      bounds.x < area.x + area.width &&
      bounds.x + bounds.width > area.x &&
      bounds.y < area.y + area.height &&
      bounds.y + bounds.height > area.y
    );
  });

  if (!visible) {
    return { ...state, x: undefined, y: undefined };
  }
  return state;
}

function loadMainWindowState() {
  const fallback = {
    width: MAIN_WINDOW_DEFAULTS.width,
    height: MAIN_WINDOW_DEFAULTS.height,
    x: undefined,
    y: undefined,
    isMaximized: false,
  };

  try {
    const raw = fs.readFileSync(mainWindowStatePath(), "utf-8");
    const saved = JSON.parse(raw);
    const state = {
      width: clampWindowSize(
        saved.width,
        MAIN_WINDOW_DEFAULTS.minWidth,
        4096,
        fallback.width
      ),
      height: clampWindowSize(
        saved.height,
        MAIN_WINDOW_DEFAULTS.minHeight,
        4096,
        fallback.height
      ),
      x: Number.isFinite(Number(saved.x)) ? Math.round(Number(saved.x)) : undefined,
      y: Number.isFinite(Number(saved.y)) ? Math.round(Number(saved.y)) : undefined,
      isMaximized: saved.isMaximized === true,
    };
    return ensureWindowStateOnScreen(state);
  } catch (_err) {
    return fallback;
  }
}

function saveMainWindowState() {
  if (!mainWindow || mainWindow.isDestroyed()) return;

  try {
    const bounds = mainWindow.isMaximized()
      ? mainWindow.getNormalBounds()
      : mainWindow.getBounds();
    const payload = {
      x: bounds.x,
      y: bounds.y,
      width: bounds.width,
      height: bounds.height,
      isMaximized: mainWindow.isMaximized(),
    };
    fs.mkdirSync(app.getPath("userData"), { recursive: true });
    fs.writeFileSync(mainWindowStatePath(), `${JSON.stringify(payload, null, 2)}\n`, "utf-8");
  } catch (_err) {
    // ignore persistence errors
  }
}

function scheduleSaveMainWindowState() {
  if (saveMainWindowStateTimer) {
    clearTimeout(saveMainWindowStateTimer);
  }
  saveMainWindowStateTimer = setTimeout(() => {
    saveMainWindowStateTimer = null;
    saveMainWindowState();
  }, 250);
}

function attachMainWindowStatePersistence(win) {
  win.on("move", scheduleSaveMainWindowState);
  win.on("resize", scheduleSaveMainWindowState);
  win.on("maximize", scheduleSaveMainWindowState);
  win.on("unmaximize", scheduleSaveMainWindowState);
  win.on("close", () => {
    if (saveMainWindowStateTimer) {
      clearTimeout(saveMainWindowStateTimer);
      saveMainWindowStateTimer = null;
    }
    saveMainWindowState();
  });
}

function attachWindowFocusState(win) {
  const notify = () => {
    if (win.isDestroyed()) {
      return;
    }
    win.webContents.send("window-focus-changed", { focused: win.isFocused() });
  };

  win.on("focus", notify);
  win.on("blur", notify);
  win.webContents.on("did-finish-load", notify);
}

function createWindow() {
  const iconPath = path.join(__dirname, "assets", "icon.png");
  const savedState = loadMainWindowState();
  const windowOptions = {
    width: savedState.width,
    height: savedState.height,
    minWidth: MAIN_WINDOW_DEFAULTS.minWidth,
    minHeight: MAIN_WINDOW_DEFAULTS.minHeight,
    title: "CutPPaper",
    icon: iconPath,
    frame: false,
    backgroundColor: "#ffffff",
    autoHideMenuBar: true,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
      devTools: true,
    },
  };

  if (savedState.x !== undefined && savedState.y !== undefined) {
    windowOptions.x = savedState.x;
    windowOptions.y = savedState.y;
  }

  mainWindow = new BrowserWindow(windowOptions);

  if (savedState.isMaximized) {
    mainWindow.maximize();
  }

  attachDevToolsShortcuts(mainWindow);
  attachMainWindowStatePersistence(mainWindow);
  attachWindowFocusState(mainWindow);
  mainWindow.setMenuBarVisibility(false);
  mainWindow.loadFile(path.join(__dirname, "renderer", "index.html"));
  startPythonBackend();
}

app.whenReady().then(() => {
  Menu.setApplicationMenu(buildAppMenu());
  createWindow();
});

async function shutdownPythonBackend() {
  if (!pythonProcess) {
    return;
  }

  try {
    await sendCommand({ cmd: "estop" });
  } catch (_err) {
    // ignore if backend already stopping
  }

  await new Promise((resolve) => setTimeout(resolve, 300));
  if (pythonProcess) {
    pythonProcess.kill();
    pythonProcess = null;
  }
}

app.on("window-all-closed", () => {
  shutdownPythonBackend().finally(() => {
    if (process.platform !== "darwin") {
      app.quit();
    }
  });
});

app.on("will-quit", () => {
  globalShortcut.unregisterAll();
});

ipcMain.handle("backend-send", async (_event, message) => {
  return sendCommand(message);
});

function writePythonCommand(message) {
  if (!pythonProcess || !pythonProcess.stdin.writable) {
    return false;
  }
  pythonProcess.stdin.write(`${JSON.stringify(message)}\n`);
  return true;
}

async function forceMainWindowFocus() {
  if (!mainWindow || mainWindow.isDestroyed()) {
    return false;
  }

  if (mainWindow.isMinimized()) {
    mainWindow.restore();
  }
  mainWindow.show();
  mainWindow.moveTop();
  mainWindow.setAlwaysOnTop(true, "screen-saver");
  mainWindow.focus();
  if (mainWindow.webContents && !mainWindow.webContents.isDestroyed()) {
    mainWindow.webContents.focus();
  }

  let ok = await forceWindowForeground(mainWindow);
  mainWindow.setAlwaysOnTop(false);

  if (!ok) {
    mainWindow.focus();
    if (mainWindow.webContents && !mainWindow.webContents.isDestroyed()) {
      mainWindow.webContents.focus();
    }
    await new Promise((resolve) => setTimeout(resolve, 80));
    ok = await forceWindowForeground(mainWindow, 2);
  }

  return ok;
}

async function handleRestoreFocusRequest(payload) {
  const keyword = String(payload.keyword || "").trim();
  const requestId = String(payload.request_id || "").trim();
  if (!requestId) {
    return;
  }

  let ok = false;
  let title = "";

  try {
    if (/cutppaper/i.test(keyword)) {
      ok = await forceMainWindowFocus();
      title = ok ? "CutPPaper" : "";
    } else {
      const res = await sendCommand({ cmd: "restore_app_focus", keyword });
      ok = true;
      title = res.title || keyword;
    }
  } catch (_err) {
    ok = false;
    title = "";
  }

  writePythonCommand({
    cmd: "restore_focus_ack",
    request_id: requestId,
    ok,
    title,
  });

  sendToRenderer({
    event: "app_focus_restored",
    title: ok ? title : "",
    ok,
    keyword,
  });
}

ipcMain.handle("yield-focus", async () => {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.blur();
  }
});

ipcMain.handle("restore-focus", async () => {
  const ok = await forceMainWindowFocus();
  return { ok };
});

ipcMain.handle("set-start-hotkey", async (_event, hotkey) => {
  return applyStartHotkey(hotkey);
});

ipcMain.handle("backend-ready", async () => {
  return pythonReady;
});

ipcMain.handle("show-action-dialog", async (_event, options) => {
  if (!mainWindow || mainWindow.isDestroyed()) {
    return "abort";
  }
  if (mainWindow.isMinimized()) {
    mainWindow.restore();
  }
  mainWindow.show();
  mainWindow.focus();

  const result = await dialog.showMessageBox(mainWindow, {
    type: "warning",
    title: options?.title || "需要确认",
    message: options?.message || "步骤执行出现问题",
    detail: options?.detail || "",
    buttons: ["重试", "跳过此步", "停止流程"],
    defaultId: 0,
    cancelId: 2,
    noLink: true,
  });

  return ["retry", "skip", "abort"][result.response] || "abort";
});

ipcMain.handle("pick-import-action-group-file", async () => {
  if (!mainWindow || mainWindow.isDestroyed()) {
    return null;
  }
  const result = await dialog.showOpenDialog(mainWindow, {
    title: "导入动作组",
    properties: ["openFile"],
    filters: [{ name: "动作组 JSON", extensions: ["json"] }],
  });
  if (result.canceled || !result.filePaths.length) {
    return null;
  }
  return result.filePaths[0];
});

ipcMain.handle("pick-export-action-group-file", async (_event, defaultName) => {
  if (!mainWindow || mainWindow.isDestroyed()) {
    return null;
  }
  const safeName = String(defaultName || "动作组").replace(/[<>:"/\\|?*]/g, "_").trim() || "动作组";
  const result = await dialog.showSaveDialog(mainWindow, {
    title: "导出动作组",
    defaultPath: `${safeName}.json`,
    filters: [{ name: "动作组 JSON", extensions: ["json"] }],
  });
  if (result.canceled || !result.filePath) {
    return null;
  }
  return result.filePath;
});

ipcMain.handle("open-log-window", async () => {
  openLogWindow();
});

ipcMain.handle("window-minimize", () => {
  const win = BrowserWindow.getFocusedWindow() || mainWindow;
  if (win && !win.isDestroyed()) {
    win.minimize();
  }
});

ipcMain.handle("window-close", () => {
  const win = BrowserWindow.getFocusedWindow() || mainWindow;
  if (win && !win.isDestroyed()) {
    win.close();
  }
});

ipcMain.on("log-line", (_event, line) => {
  if (typeof line === "string" && line.length > 0) {
    appendLogLine(line);
  }
});

ipcMain.handle("clear-log", async () => {
  logLines.length = 0;
  if (logWindow && !logWindow.isDestroyed()) {
    logWindow.webContents.send("log-init", "");
  }
});
