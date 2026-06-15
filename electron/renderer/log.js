const logView = document.getElementById("logView");
const clearLogBtn = document.getElementById("clearLogBtn");

function scrollToBottom() {
  logView.scrollTop = logView.scrollHeight;
}

function setLogText(text) {
  logView.textContent = text ? `${text}\n` : "";
  scrollToBottom();
}

function appendLogLine(line) {
  logView.textContent += `${line}\n`;
  scrollToBottom();
}

window.cutppaperLog.onLogInit((text) => {
  setLogText(text);
});

window.cutppaperLog.onLogAppend((line) => {
  appendLogLine(line);
});

clearLogBtn.addEventListener("click", async () => {
  await window.cutppaperLog.clearLog();
  setLogText("");
});
