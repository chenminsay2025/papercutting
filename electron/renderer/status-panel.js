/**
 * 统一设备状态面板（图标芯片：压纸 / USB / 电机 / 流程 / 后端 / 模式）
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
    workflow: "status-chip",
    paper: "status-chip",
    usb: "status-chip status-chip-usb status-seg-clickable",
    motor: "status-chip",
    backend: "status-chip",
    mode: "status-chip",
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

  function formatMotor(motor) {
    switch (motor) {
      case "retract":
        return { text: "缩回", tone: TONE.active };
      case "extend":
        return { text: "伸出", tone: TONE.active };
      case "relay":
        return { text: "继电器", tone: TONE.warn };
      case "timeout":
        return { text: "通信超时", tone: TONE.danger };
      case "stop":
      case "idle":
        return { text: "停止", tone: TONE.idle };
      default:
        return { text: "—", tone: TONE.off };
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

  function formatMode(snapshot) {
    if (snapshot.simulation) {
      return { text: "模拟", tone: TONE.warn, hint: "不驱动真实串口" };
    }
    return { text: "硬件", tone: TONE.idle, hint: "真实 STM32 串口" };
  }

  function formatWorkflow(snapshot) {
    if (snapshot.running) {
      if (snapshot.waitingLoop) {
        return { text: "轮间等待", tone: TONE.warn };
      }
      if (snapshot.loopIndex > 1) {
        return { text: `第 ${snapshot.loopIndex} 轮`, tone: TONE.active };
      }
      return { text: "运行中", tone: TONE.active };
    }
    return { text: "空闲", tone: TONE.idle };
  }

  function init(options = {}) {
    els = {
      module: document.getElementById("statusModule"),
      chips: {
        workflow: document.getElementById("statusChipWorkflow"),
        paper: document.getElementById("statusChipPaper"),
        usb: document.getElementById("statusUsbRow"),
        motor: document.getElementById("statusChipMotor"),
        backend: document.getElementById("statusChipBackend"),
        mode: document.getElementById("statusChipMode"),
      },
      paper: document.getElementById("statusPaper"),
      usb: document.getElementById("statusUsb"),
      usbRow: document.getElementById("statusUsbRow"),
      motor: document.getElementById("statusMotor"),
      workflow: document.getElementById("statusWorkflow"),
      backend: document.getElementById("statusBackend"),
      mode: document.getElementById("statusMode"),
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

  function updateProgress(elapsedMs, totalMs, label, progressRatio) {
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
      els.progressMeta.textContent = total > 0 ? `${shownElapsed}/${total}ms` : `${shownElapsed}ms`;
    }
    if (els.phase) {
      els.phase.textContent = label || "空闲";
    }
  }

  function render(snapshot) {
    const paper = formatPaper(snapshot);
    const usb = formatUsb(snapshot);
    const motor = formatMotor(snapshot.motorState);
    const backend = formatBackend(snapshot);
    const mode = formatMode(snapshot);
    const workflow = formatWorkflow(snapshot);

    setChip("workflow", els.workflow, workflow.text, workflow.tone);
    setChip("paper", els.paper, paper.text, paper.tone, paper.hint);
    setChip("usb", els.usb, usb.text, usb.tone, usb.hint);
    setChip("motor", els.motor, motor.text, motor.tone);
    setChip("backend", els.backend, backend.text, backend.tone, backend.hint);
    setChip("mode", els.mode, mode.text, mode.tone, mode.hint);

    if (els.module) {
      els.module.classList.toggle("is-running", !!snapshot.running);
      els.module.classList.toggle("is-connected", !!snapshot.connected);
      els.module.classList.toggle("is-disconnected", !snapshot.connected);
    }

    if (snapshot.phaseLabel != null) {
      updateProgress(
        snapshot.progressElapsed,
        snapshot.progressTotal,
        snapshot.phaseLabel,
        snapshot.progressRatio,
      );
    }

    const cycleHintEl = els.cycleHint || document.getElementById("cycleHint");
    if (cycleHintEl && snapshot.cycleHint != null) {
      cycleHintEl.textContent = snapshot.cycleHint;
    }
  }

  return { init, render, updateProgress };
})();
