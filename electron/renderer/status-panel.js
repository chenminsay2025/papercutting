/**
 * 统一设备状态面板（压纸 / USB / 电机 / 流程 / 后端 / 模式）
 */
const StatusPanel = (() => {
  const TONE = {
    ok: "is-ok",
    warn: "is-warn",
    danger: "is-danger",
    off: "is-off",
    active: "is-active",
    idle: "is-idle",
  };

  let els = {};
  let onUsbClick = null;

  function setValue(el, text, tone) {
    if (!el) return;
    el.textContent = text;
    el.className = "status-value";
    if (tone) el.classList.add(tone);
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
      return { text: `模拟 · ${sim}`, tone: TONE.warn, hint: "模拟硬件模式" };
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
      return { text: "未连接", tone: TONE.danger, hint: "点击配置串口并连接" };
    }
    if (snapshot.simulation) {
      return { text: "模拟 · 已连接", tone: TONE.warn, hint: "模拟硬件，不驱动串口" };
    }
    const port = snapshot.connectedPort || "串口";
    const baud = snapshot.baudrate || 115200;
    return {
      text: `${port} · ${baud}`,
      tone: TONE.ok,
      hint: `${port} · ${baud} · 超时 ${snapshot.timeoutMs || 2000}ms`,
    };
  }

  function formatBackend(snapshot) {
    if (snapshot.pythonExit) {
      return { text: "已退出", tone: TONE.danger, hint: "Python 后端异常退出" };
    }
    if (!snapshot.pythonReady) {
      return { text: "启动中", tone: TONE.warn, hint: "等待 Python 后端就绪" };
    }
    return { text: "运行中", tone: TONE.ok, hint: "Python 后端正常" };
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
        return { text: `运行中 · 第 ${snapshot.loopIndex} 轮`, tone: TONE.active };
      }
      return { text: "运行中", tone: TONE.active };
    }
    return { text: "空闲", tone: TONE.idle };
  }

  function init(options = {}) {
    els = {
      module: document.getElementById("statusModule"),
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

    setValue(els.paper, paper.text, paper.tone);
    if (els.paper) els.paper.title = paper.hint;

    setValue(els.usb, usb.text, usb.tone);
    if (els.usbRow) els.usbRow.title = usb.hint;

    setValue(els.motor, motor.text, motor.tone);
    setValue(els.backend, backend.text, backend.tone);
    if (els.backend) els.backend.title = backend.hint;

    setValue(els.mode, mode.text, mode.tone);
    if (els.mode) els.mode.title = mode.hint;

    setValue(els.workflow, workflow.text, workflow.tone);

    if (els.module) {
      els.module.classList.toggle("is-running", !!snapshot.running);
      els.module.classList.toggle("is-connected", !!snapshot.connected);
    }

    if (snapshot.phaseLabel != null) {
      updateProgress(
        snapshot.progressElapsed,
        snapshot.progressTotal,
        snapshot.phaseLabel,
        snapshot.progressRatio,
      );
    }

    if (els.cycleHint && snapshot.cycleHint != null) {
      els.cycleHint.textContent = snapshot.cycleHint;
    }
  }

  return { init, render, updateProgress };
})();
