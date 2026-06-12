const { app, BrowserWindow, ipcMain } = require("electron");
const path = require("path");
const { spawn } = require("child_process");
const readline = require("readline");

let mainWindow = null;
let pythonProcess = null;
let pythonReady = false;
const pendingRequests = new Map();

function pythonScriptPath() {
  return path.join(__dirname, "..", "python", "controller.py");
}

function resolvePythonCommand() {
  if (process.env.CUTPPAPER_PYTHON) {
    return process.env.CUTPPAPER_PYTHON;
  }
  return process.platform === "win32" ? "python" : "python3";
}

function startPythonBackend() {
  if (pythonProcess) {
    return;
  }

  pythonReady = false;
  const child = spawn(resolvePythonCommand(), [pythonScriptPath()], {
    cwd: path.join(__dirname, ".."),
    stdio: ["pipe", "pipe", "pipe"],
    env: { ...process.env, PYTHONIOENCODING: "utf-8" },
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

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 720,
    height: 580,
    minWidth: 640,
    minHeight: 480,
    webPreferences: {
      preload: path.join(__dirname, "preload.js"),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  mainWindow.loadFile(path.join(__dirname, "renderer", "index.html"));
  startPythonBackend();
}

app.whenReady().then(createWindow);

app.on("window-all-closed", () => {
  if (pythonProcess) {
    pythonProcess.kill();
    pythonProcess = null;
  }
  if (process.platform !== "darwin") {
    app.quit();
  }
});

ipcMain.handle("backend-send", async (_event, message) => {
  return sendCommand(message);
});

ipcMain.handle("backend-ready", async () => {
  return pythonReady;
});
