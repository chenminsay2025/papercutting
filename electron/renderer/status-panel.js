/**
 * 统一设备状态面板（图标芯片：压纸 / USB / 后端）
 */
const StatusPanel = (() => {
  const TONE = {
    ok: "ok",
    warn: "warn",
    danger: "danger",
    off: "off",
    active: "active",
    idle: "idle",
  };

  const CHIP_CLASS = {
    paper: "status-chip",
    obstacle: "status-chip",
    usb: "status-chip status-chip-usb status-seg-clickable",
    backend: "status-chip",
  };

  let els = {};
  let onUsbClick = null;

  function setChip(chipKey, valueEl, text, tone, hint) {
    if (valueEl) {
      valueEl.textContent = text;
    }
    const chip = els.chips?.[chipKey];
    if (!chip) return;
    chip.className = CHIP_CLASS[chipKey] || "status-chip";
    chip.classList.add(`tone-${tone || TONE.off}`);
    if (hint) {
      chip.title = hint;
    } else {
      chip.removeAttribute("title");
    }
  }

  function formatPaper(snapshot) {
    if (!snapshot.connected) {
      return { text: "—", tone: TONE.off, hint: "连接 USB 后刷新" };
    }
    if (snapshot.simulation) {
      const sim = snapshot.rodPosition === "home" ? "压纸中" : "未压纸";
      return { text: sim, tone: TONE.warn, hint: "模拟硬件模式" };
    }
    if (snapshot.rodPosition === "home") {
      return { text: "压纸中", tone: TONE.ok, hint: "传感器遮挡 · 已缩回" };
    }
    if (snapshot.rodPosition === "away") {
      return { text: "未压纸", tone: TONE.warn, hint: "传感器未遮挡 · 已伸出" };
    }
    return { text: "—", tone: TONE.off, hint: "等待传感器数据" };
  }

  function formatObstacle(snapshot) {
    if (!snapshot.connected) {
      return { text: "—", tone: TONE.off, hint: "连接 USB 后刷新" };
    }
    if (snapshot.simulation) {
      const sim = snapshot.obstaclePosition === "blocked" ? "有遮挡" : "无遮挡";
      return { text: sim, tone: TONE.warn, hint: "模拟硬件模式" };
    }
    if (snapshot.obstaclePosition === "blocked") {
      return { text: "有遮挡", tone: TONE.warn, hint: "KY-032 检测到遮挡" };
    }
    if (snapshot.obstaclePosition === "clear") {
      return { text: "无遮挡", tone: TONE.ok, hint: "KY-032 未检测到遮挡" };
    }
    return { text: "—", tone: TONE.off, hint: "等待传感器数据" };
  }

  function formatUsb(snapshot) {
    if (!snapshot.connected) {
      return { text: "未连接", tone: TONE.danger, hint: "点击此处连接 USB 串口" };
    }
    if (snapshot.simulation) {
      return { text: "模拟", tone: TONE.warn, hint: "模拟硬件，不驱动串口" };
    }
    const port = snapshot.connectedPort || "串口";
    return {
      text: port,
      tone: TONE.ok,
      hint: `${port} · ${snapshot.baudrate || 115200} · 超时 ${snapshot.timeoutMs || 2000}ms`,
    };
  }

  function formatBackend(snapshot) {
    if (snapshot.pythonExit) {
      return { text: "已退出", tone: TONE.danger, hint: "Python 后端异常退出" };
    }
    if (!snapshot.pythonReady) {
      return { text: "启动中", tone: TONE.warn, hint: "等待 Python 后端就绪" };
    }
    return { text: "正常", tone: TONE.ok, hint: "Python 后端正常" };
  }

  function init(options = {}) {
    els = {
      module: document.getElementById("statusModule"),
      chips: {
        paper: document.getElementById("statusChipPaper"),
        obstacle: document.getElementById("statusChipObstacle"),
        usb: document.getElementById("statusUsbRow"),
        backend: document.getElementById("statusChipBackend"),
      },
      paper: document.getElementById("statusPaper"),
      obstacle: document.getElementById("statusObstacle"),
      usb: document.getElementById("statusUsb"),
      usbRow: document.getElementById("statusUsbRow"),
      backend: document.getElementById("statusBackend"),
      phase: document.getElementById("statusPhase"),
      progressMeta: document.getElementById("statusProgressMeta"),
      progressFill: document.getElementById("progressFill"),
      cycleHint: document.getElementById("cycleHint"),
      refreshBtn: document.getElementById("statusRefreshBtn"),
    };
    onUsbClick = options.onUsbClick || null;

    if (els.usbRow && onUsbClick) {
      els.usbRow.addEventListener("click", onUsbClick);
      els.usbRow.addEventListener("keydown", (event) => {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          onUsbClick();
        }
      });
    }
    if (els.refreshBtn && options.onRefresh) {
      els.refreshBtn.addEventListener("click", options.onRefresh);
    }
  }

  function formatWaitTimer(elapsedMs, totalMs) {
    const elapsed = Math.max(0, Number(elapsedMs) || 0);
    const sec = (elapsed / 1000).toFixed(1);
    const total = Math.max(0, Number(totalMs) || 0);
    if (total > 0) {
      const totalSec = total >= 10000 ? String(Math.round(total / 1000)) : (total / 1000).toFixed(1);
      return `${sec}s / ${totalSec}s`;
    }
    return `${sec}s`;
  }

  function updateProgress(elapsedMs, totalMs, label, progressRatio, waitTimer) {
    const total = Math.max(0, Number(totalMs) || 0);
    const elapsed = Math.max(0, Number(elapsedMs) || 0);
    const progress = progressRatio != null
      ? Math.min(1, Math.max(0, Number(progressRatio)))
      : (total > 0 ? Math.min(1, elapsed / total) : 0);
    const shownElapsed = total > 0 ? Math.min(elapsed, total) : elapsed;

    if (els.progressFill) {
      els.progressFill.style.width = `${progress * 100}%`;
    }
    if (els.progressMeta) {
      if (waitTimer?.active) {
        els.progressMeta.textContent = formatWaitTimer(waitTimer.elapsedMs, waitTimer.totalMs);
      } else {
        els.progressMeta.textContent = total > 0 ? `${shownElapsed}/${total}ms` : `${shownElapsed}ms`;
      }
    }
    if (els.phase) {
      els.phase.textContent = label || "空闲";
    }
  }

  function render(snapshot) {
    const paper = formatPaper(snapshot);
    const obstacle = formatObstacle(snapshot);
    const usb = formatUsb(snapshot);
    const backend = formatBackend(snapshot);

    setChip("paper", els.paper, paper.text, paper.tone, paper.hint);
    if (els.chips?.paper) {
      els.chips.paper.classList.toggle("is-paper-away", paper.text === "未压纸");
    }
    setChip("obstacle", els.obstacle, obstacle.text, obstacle.tone, obstacle.hint);
    if (els.chips?.obstacle) {
      els.chips.obstacle.classList.toggle("is-obstacle-blocked", obstacle.text === "有遮挡");
    }
    setChip("usb", els.usb, usb.text, usb.tone, usb.hint);
    setChip("backend", els.backend, backend.text, backend.tone, backend.hint);

    if (els.module) {
      els.module.classList.toggle("is-running", !!snapshot.running);
    }

    const appRoot = document.getElementById("appRoot");
    if (appRoot) {
      appRoot.classList.toggle("is-paper-away", paper.text === "未压纸");
    }

    if (snapshot.phaseLabel != null) {
      updateProgress(
        snapshot.progressElapsed,
        snapshot.progressTotal,
        snapshot.phaseLabel,
        snapshot.progressRatio,
        snapshot.waitTimerActive
          ? { active: true, elapsedMs: snapshot.waitElapsedMs, totalMs: snapshot.waitTotalMs }
          : null,
      );
    }

    const cycleHintEl = els.cycleHint || document.getElementById("cycleHint");
    if (cycleHintEl && snapshot.cycleHint != null) {
      cycleHintEl.textContent = snapshot.cycleHint;
    }
  }

  return { init, render, updateProgress };
})();
