const STEPS = [
  { id: "2-1", phase: "2-1_retract", name: "伸缩杆缩回", configKey: "retract" },
  { id: "2-2", phase: "2-2_continue", name: "继续 (继电器A)", configKey: "relay_pulse" },
  { id: "2-3", phase: "2-3_send", name: "发送切割 Ctrl+P", configKey: "before_send_keys", altKey: "cut_wait" },
  { id: "3", phase: "3_extend", name: "伸缩杆伸出", configKey: "extend" },
  { id: "4", phase: "4_origin", name: "原点 (继电器B)", configKey: "relay_pulse" },
];

const state = {
  config: null,
  running: false,
  connected: false,
  simulation: true,
  currentPhase: "idle",
  totalMs: 0,
};

const els = {
  pythonStatus: document.getElementById("pythonStatus"),
  modeStatus: document.getElementById("modeStatus"),
  serialStatus: document.getElementById("serialStatus"),
  serialPanel: document.getElementById("serialPanel"),
  portSelect: document.getElementById("portSelect"),
  baudrate: document.getElementById("baudrate"),
  timeoutMs: document.getElementById("timeoutMs"),
  refreshPortsBtn: document.getElementById("refreshPortsBtn"),
  connectBtn: document.getElementById("connectBtn"),
  disconnectBtn: document.getElementById("disconnectBtn"),
  simulationMode: document.getElementById("simulationMode"),
  simulateCut: document.getElementById("simulateCut"),
  retractMs: document.getElementById("retractMs"),
  extendMs: document.getElementById("extendMs"),
  cutWaitMs: document.getElementById("cutWaitMs"),
  relayPulseMs: document.getElementById("relayPulseMs"),
  beforeSendMs: document.getElementById("beforeSendMs"),
  afterFocusMs: document.getElementById("afterFocusMs"),
  afterHotkeyMs: document.getElementById("afterHotkeyMs"),
  windowKeyword: document.getElementById("windowKeyword"),
  sendHotkey: document.getElementById("sendHotkey"),
  testWindowBtn: document.getElementById("testWindowBtn"),
  testHotkeyBtn: document.getElementById("testHotkeyBtn"),
  saveConfigBtn: document.getElementById("saveConfigBtn"),
  stepTimeline: document.getElementById("stepTimeline"),
  phaseLabel: document.getElementById("phaseLabel"),
  progressText: document.getElementById("progressText"),
  cycleHint: document.getElementById("cycleHint"),
  progressFill: document.getElementById("progressFill"),
  startBtn: document.getElementById("startBtn"),
  estopBtn: document.getElementById("estopBtn"),
  clearLogBtn: document.getElementById("clearLogBtn"),
  logView: document.getElementById("logView"),
};

function log(level, message) {
  const time = new Date().toLocaleTimeString();
  els.logView.textContent += `[${time}] [${level}] ${message}\n`;
  els.logView.scrollTop = els.logView.scrollHeight;
}

function setStatus(el, state, text) {
  el.dataset.state = state;
  const label = el.querySelector(".status-text");
  if (label) {
    label.textContent = text;
  }
}

function sendCutBudgetMs(timings) {
  return (
    (timings.before_send_keys || 0)
    + (timings.after_focus_ms || 0)
    + (timings.after_hotkey_ms || 0)
  );
}

function renderTimeline(activePhase = "idle", donePhases = new Set()) {
  const timings = state.config?.timings_ms || {};
  els.stepTimeline.innerHTML = STEPS.map((step) => {
    let duration = timings[step.configKey] || 0;
    if (step.id === "2-3") {
      duration = sendCutBudgetMs(timings) + (timings.cut_wait || 0);
      if (state.simulation && els.simulateCut.checked) {
        duration = timings.cut_wait || 0;
      }
    }
    let status = "pending";
    if (step.phase === activePhase || (step.id === "2-3" && activePhase === "2-3_wait")) {
      status = "active";
    } else if (donePhases.has(step.phase) || (step.id === "2-3" && donePhases.has("2-3_wait"))) {
      status = "done";
    }
    return `
      <div class="step-item ${status}" role="listitem">
        <div class="step-num">${step.id}</div>
        <div class="step-name">${step.name}</div>
        <div class="step-duration">${duration} ms</div>
      </div>
    `;
  }).join("");
}

function updateControls() {
  const canRun = state.connected && !state.running;
  els.startBtn.disabled = !canRun;
  els.connectBtn.disabled = state.connected || state.running;
  els.disconnectBtn.disabled = !state.connected || state.running;
  els.saveConfigBtn.disabled = state.running;
  els.simulationMode.disabled = state.running;
  document.querySelectorAll("[data-step]").forEach((btn) => {
    btn.disabled = !canRun;
  });
  els.serialPanel.classList.toggle("disabled", state.simulation);
}

function applyConfigToForm(config) {
  state.config = config;
  state.simulation = config.app?.simulation_mode !== false;
  els.simulationMode.checked = state.simulation;
  els.simulateCut.checked = config.app?.simulate_cut !== false;
  els.portSelect.value = config.serial.port;
  els.baudrate.value = config.serial.baudrate ?? 115200;
  els.timeoutMs.value = config.serial.timeout_ms ?? 2000;
  els.retractMs.value = config.timings_ms.retract;
  els.extendMs.value = config.timings_ms.extend;
  els.cutWaitMs.value = config.timings_ms.cut_wait;
  els.relayPulseMs.value = config.timings_ms.relay_pulse;
  els.beforeSendMs.value = config.timings_ms.before_send_keys;
  els.afterFocusMs.value = config.timings_ms.after_focus_ms ?? 100;
  els.afterHotkeyMs.value = config.timings_ms.after_hotkey_ms ?? 200;
  els.windowKeyword.value = config.cutting_master.window_title_contains;
  els.sendHotkey.value = config.cutting_master.send_hotkey ?? "ctrl+p";
  recalcTotalMs();
  updateModeBadge();
  renderTimeline();
  updateControls();
}

function recalcTotalMs() {
  const t = {
    retract: Number(els.retractMs.value) || 0,
    extend: Number(els.extendMs.value) || 0,
    cut_wait: Number(els.cutWaitMs.value) || 0,
    relay_pulse: Number(els.relayPulseMs.value) || 0,
    before_send_keys: Number(els.beforeSendMs.value) || 0,
    after_focus_ms: Number(els.afterFocusMs.value) || 0,
    after_hotkey_ms: Number(els.afterHotkeyMs.value) || 0,
  };
  state.totalMs =
    t.retract + t.relay_pulse + t.cut_wait + t.extend + t.relay_pulse;
  if (!(state.simulation && els.simulateCut.checked)) {
    state.totalMs += sendCutBudgetMs(t);
  }
  els.cycleHint.textContent = `~${(state.totalMs / 1000).toFixed(1)} s`;
  renderTimeline(state.currentPhase);
}

function readConfigFromForm() {
  return {
    serial: {
      port: els.portSelect.value,
      baudrate: Number(els.baudrate.value) || 115200,
      timeout_ms: Number(els.timeoutMs.value) || 2000,
    },
    timings_ms: {
      retract: Number(els.retractMs.value),
      extend: Number(els.extendMs.value),
      cut_wait: Number(els.cutWaitMs.value),
      relay_pulse: Number(els.relayPulseMs.value),
      before_send_keys: Number(els.beforeSendMs.value),
      after_focus_ms: Number(els.afterFocusMs.value),
      after_hotkey_ms: Number(els.afterHotkeyMs.value),
    },
    cutting_master: {
      window_title_contains: els.windowKeyword.value.trim(),
      send_hotkey: els.sendHotkey.value.trim() || "ctrl+p",
    },
    app: {
      simulation_mode: els.simulationMode.checked,
      simulate_cut: els.simulateCut.checked,
    },
  };
}

function updateModeBadge() {
  if (state.simulation) {
    setStatus(els.modeStatus, "sim", "模拟模式");
  } else {
    setStatus(els.modeStatus, "off", "硬件模式");
  }
}

function updateProgress(elapsedMs, totalMs, label) {
  const progress = totalMs > 0 ? Math.min(1, elapsedMs / totalMs) : 0;
  els.progressFill.style.width = `${progress * 100}%`;
  els.progressText.textContent = `${elapsedMs} / ${totalMs} ms`;
  els.phaseLabel.textContent = label;
}

function getDonePhases(currentPhase) {
  const order = ["2-1_retract", "2-2_continue", "2-3_send", "2-3_wait", "3_extend", "4_origin", "done"];
  const idx = order.indexOf(currentPhase);
  const done = new Set();
  if (idx > 0) {
    order.slice(0, idx).forEach((p) => done.add(p));
  }
  return done;
}

async function sendCommand(message) {
  return window.cutppaper.sendCommand(message);
}

async function saveConfigSilently() {
  const response = await sendCommand({ cmd: "save_config", config: readConfigFromForm() });
  if (response.event === "error") {
    throw new Error(response.message || "保存设置失败");
  }
  if (response.event === "config_saved") {
    applyConfigToForm(response.config);
  }
}

async function refreshPorts() {
  const response = await sendCommand({ cmd: "list_ports" });
  if (response.event !== "ports") return;
  const current = els.portSelect.value;
  els.portSelect.innerHTML = "";
  response.ports.forEach((port) => {
    const option = document.createElement("option");
    const portName = typeof port === "string" ? port : port.port;
    const description = typeof port === "string" ? "" : port.description || "";
    option.value = portName;
    option.textContent = description ? `${portName} — ${description}` : portName;
    els.portSelect.appendChild(option);
  });
  const preferred = current || (state.simulation ? "SIM（模拟）" : state.config?.serial?.port);
  if (preferred) {
    els.portSelect.value = preferred;
  }
}

async function autoConnectSimulation() {
  if (!state.simulation) return;
  try {
    await saveConfigSilently();
    const response = await sendCommand({ cmd: "connect", port: "SIM（模拟）" });
    if (response.event === "connected") {
      state.connected = true;
      setStatus(els.serialStatus, "ok", "模拟已连接");
      log("info", "已自动进入模拟连接，可直接测试界面与流程");
      updateControls();
    }
  } catch (err) {
    log("error", err.message);
  }
}

function handleBackendEvent(payload) {
  switch (payload.event) {
    case "ready":
      setStatus(els.pythonStatus, "ok", "后端就绪");
      sendCommand({ cmd: "get_config" }).then((res) => {
        if (res.event === "config") applyConfigToForm(res.config);
        return refreshPorts();
      }).then(autoConnectSimulation);
      break;
    case "python_exit":
      setStatus(els.pythonStatus, "err", "后端已退出");
      log("error", payload.message);
      break;
    case "config":
      applyConfigToForm(payload.config);
      break;
    case "cut_window_ok":
      if (payload.sent) {
        log("info", `已激活「${payload.title}」并发送 ${payload.hotkey}`);
        restoreAppFocus();
      } else {
        log("info", `已找到并激活窗口「${payload.title}」（关键字: ${payload.keyword}）`);
      }
      break;
    case "cut_hotkey_sent":
      restoreAppFocus();
      break;
    case "config_saved":
      applyConfigToForm(payload.config);
      log("info", "设置已保存");
      break;
    case "connected":
      state.connected = true;
      state.simulation = payload.simulation === true;
      updateModeBadge();
      setStatus(
        els.serialStatus,
        "ok",
        payload.simulation ? "模拟已连接" : payload.port
      );
      log("info", payload.simulation ? "模拟模式已连接" : `串口已连接 ${payload.port}`);
      updateControls();
      break;
    case "disconnected":
      state.connected = false;
      setStatus(els.serialStatus, "off", "未连接");
      log("info", "连接已断开");
      updateControls();
      break;
    case "cycle_started":
      state.running = true;
      state.currentPhase = "2-1_retract";
      renderTimeline(state.currentPhase);
      updateControls();
      log("info", "开始本轮");
      break;
    case "cycle_done":
      state.running = false;
      state.currentPhase = "done";
      renderTimeline("done", new Set(["2-1_retract", "2-2_continue", "2-3_send", "2-3_wait", "3_extend", "4_origin"]));
      updateProgress(state.totalMs, state.totalMs, "本轮完成");
      updateControls();
      log("info", "本轮完成，请取纸后可再次开始");
      break;
    case "cycle_aborted":
      state.running = false;
      state.currentPhase = "aborted";
      renderTimeline("idle");
      updateControls();
      log("warn", "流程已中止");
      break;
    case "progress":
    case "state":
      state.currentPhase = payload.phase || state.currentPhase;
      updateProgress(payload.elapsed_ms ?? 0, payload.total_ms ?? state.totalMs, payload.phase_label || "运行中");
      renderTimeline(state.currentPhase, getDonePhases(state.currentPhase));
      break;
    case "log":
      log(payload.level || "info", payload.message);
      break;
    case "error":
      state.running = false;
      updateControls();
      log("error", payload.message);
      break;
    case "test_done":
      log("info", `单步测试完成: ${payload.step}`);
      break;
    default:
      break;
  }
}

els.refreshPortsBtn.addEventListener("click", () => {
  refreshPorts().catch((err) => log("error", err.message));
});

els.connectBtn.addEventListener("click", async () => {
  try {
    await saveConfigSilently();
    await sendCommand({ cmd: "connect", port: els.portSelect.value });
  } catch (err) {
    log("error", err.message);
  }
});

els.disconnectBtn.addEventListener("click", async () => {
  try {
    await sendCommand({ cmd: "disconnect" });
  } catch (err) {
    log("error", err.message);
  }
});

els.saveConfigBtn.addEventListener("click", async () => {
  try {
    await saveConfigSilently();
  } catch (err) {
    log("error", err.message);
  }
});

async function yieldAppFocus() {
  if (window.cutppaper.yieldFocus) {
    await window.cutppaper.yieldFocus();
    await new Promise((resolve) => setTimeout(resolve, 80));
  }
}

async function restoreAppFocus() {
  if (window.cutppaper.restoreFocus) {
    await window.cutppaper.restoreFocus();
  }
}

els.testWindowBtn.addEventListener("click", async () => {
  try {
    await saveConfigSilently();
    await yieldAppFocus();
    await sendCommand({
      cmd: "test_cut_window",
      keyword: els.windowKeyword.value.trim(),
      send_keys: false,
    });
  } catch (err) {
    log("error", err.message);
  }
});

els.testHotkeyBtn.addEventListener("click", async () => {
  try {
    await saveConfigSilently();
    await yieldAppFocus();
    await sendCommand({
      cmd: "test_cut_window",
      keyword: els.windowKeyword.value.trim(),
      hotkey: els.sendHotkey.value.trim() || "ctrl+p",
      send_keys: true,
    });
  } catch (err) {
    log("error", err.message);
  }
});

els.startBtn.addEventListener("click", async () => {
  try {
    await saveConfigSilently();
    await sendCommand({ cmd: "start_cycle" });
  } catch (err) {
    log("error", err.message);
  }
});

els.estopBtn.addEventListener("click", async () => {
  try {
    await sendCommand({ cmd: "estop" });
  } catch (err) {
    log("error", err.message);
  }
});

document.querySelectorAll("[data-step]").forEach((button) => {
  button.addEventListener("click", async () => {
    try {
      await saveConfigSilently();
      await sendCommand({ cmd: "test_step", step: button.dataset.step });
    } catch (err) {
      log("error", err.message);
    }
  });
});

[els.retractMs, els.extendMs, els.cutWaitMs, els.relayPulseMs, els.beforeSendMs, els.afterFocusMs, els.afterHotkeyMs, els.simulateCut].forEach((el) => {
  el.addEventListener("input", recalcTotalMs);
});

els.simulationMode.addEventListener("change", async () => {
  state.simulation = els.simulationMode.checked;
  updateModeBadge();
  updateControls();
  try {
    await saveConfigSilently();
    await refreshPorts();
    if (state.simulation) {
      await autoConnectSimulation();
    } else if (state.connected) {
      await sendCommand({ cmd: "disconnect" });
    }
  } catch (err) {
    log("error", err.message);
  }
});

els.clearLogBtn.addEventListener("click", () => {
  els.logView.textContent = "";
});

window.cutppaper.onBackendEvent(handleBackendEvent);
updateControls();
renderTimeline();

setInterval(async () => {
  const ready = await window.cutppaper.isBackendReady();
  if (!ready) {
    setStatus(els.pythonStatus, "warn", "后端启动中");
  }
}, 1000);
