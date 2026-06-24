const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("cutppaper", {
  sendCommand: (message) => ipcRenderer.invoke("backend-send", message),
  yieldFocus: () => ipcRenderer.invoke("yield-focus"),
  restoreFocus: () => ipcRenderer.invoke("restore-focus"),
  setStartHotkey: (hotkey) => ipcRenderer.invoke("set-start-hotkey", hotkey),
  onStartHotkey: (callback) => {
    const listener = () => callback();
    ipcRenderer.on("start-cycle-hotkey", listener);
    return () => ipcRenderer.removeListener("start-cycle-hotkey", listener);
  },
  onWindowFocusChanged: (callback) => {
    const listener = (_event, payload) => callback(payload);
    ipcRenderer.on("window-focus-changed", listener);
    return () => ipcRenderer.removeListener("window-focus-changed", listener);
  },
  isBackendReady: () => ipcRenderer.invoke("backend-ready"),
  showActionDialog: (options) => ipcRenderer.invoke("show-action-dialog", options),
  pickImportActionGroupFile: () => ipcRenderer.invoke("pick-import-action-group-file"),
  pickExportActionGroupFile: (defaultName) => ipcRenderer.invoke("pick-export-action-group-file", defaultName),
  openLogWindow: () => ipcRenderer.invoke("open-log-window"),
  windowMinimize: () => ipcRenderer.invoke("window-minimize"),
  windowClose: () => ipcRenderer.invoke("window-close"),
  logLine: (line) => ipcRenderer.send("log-line", line),
  onBackendEvent: (callback) => {
    const listener = (_event, payload) => callback(payload);
    ipcRenderer.on("backend-event", listener);
    return () => ipcRenderer.removeListener("backend-event", listener);
  },
});
