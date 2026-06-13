const { contextBridge, ipcRenderer } = require("electron");

contextBridge.exposeInMainWorld("cutppaper", {
  sendCommand: (message) => ipcRenderer.invoke("backend-send", message),
  yieldFocus: () => ipcRenderer.invoke("yield-focus"),
  restoreFocus: () => ipcRenderer.invoke("restore-focus"),
  isBackendReady: () => ipcRenderer.invoke("backend-ready"),
  onBackendEvent: (callback) => {
    const listener = (_event, payload) => callback(payload);
    ipcRenderer.on("backend-event", listener);
    return () => ipcRenderer.removeListener("backend-event", listener);
  },
});
