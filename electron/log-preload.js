const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("cutppaperLog", {
  onLogInit: (callback) => {
    const listener = (_event, text) => callback(text);
    ipcRenderer.on("log-init", listener);
    return () => ipcRenderer.removeListener("log-init", listener);
  },
  onLogAppend: (callback) => {
    const listener = (_event, line) => callback(line);
    ipcRenderer.on("log-append", listener);
    return () => ipcRenderer.removeListener("log-append", listener);
  },
  clearLog: () => ipcRenderer.invoke("clear-log"),
});
