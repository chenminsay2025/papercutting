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
  windowKeyword: document.getElementById("windowKeyword"),
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

function setBadge(el, className, text) {
  el.className = `badge ${className}`;
  el.textContent = text;
}

function renderTimeline(activePhase = "idle", donePhases = new Set()) {
  const timings = state.config?.timings_ms || {};
  els.stepTimeline.innerHTML = STEPS.map((step) => {
    let duration = timings[step.configKey] || 0;
    if (step.id === "2-3") {
      duration = (timings.before_send_keys || 0) + (timings.cut_wait || 0);
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
      <div class="step-item ${status}">
        <div class="step-id">${step.id}</div>
        <div class="step-name">${step.name}</div>
        <div class="step-duration">${duration} ms</div>
      </div>
    `;
  }).join("");
}

function updateControls() {
  const canRun = state.connected && !state.running;
  els.startBtn.disabled = !canRun;
  els.connectBtn.disabled = state.connected;
  els.disconnectBtn.disabled = !state.connected;
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
  els.retractMs.value = config.timings_ms.retract;
  els.extendMs.value = config.timings_ms.extend;
  els.cutWaitMs.value = config.timings_ms.cut_wait;
  els.relayPulseMs.value = config.timings_ms.relay_pulse;
  els.beforeSendMs.value = config.timings_ms.before_send_keys;
  els.windowKeyword.value = config.cutting_master.window_title_contains;
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
  };
  state.totalMs =
    t.retract + t.relay_pulse + t.cut_wait + t.extend + t.relay_pulse;
  if (!(state.simulation && els.simulateCut.checked)) {
    state.totalMs += t.before_send_keys;
  }
  els.cycleHint.textContent = `~${(state.totalMs / 1000).toFixed(1)}s`;
  renderTimeline(state.currentPhase);
}

function readConfigFromForm() {
  return {
    serial: {
      port: els.portSelect.value,
    },
    timings_ms: {
      retract: Number(els.retractMs.value),
      extend: Number(els.extendMs.value),
      cut_wait: Number(els.cutWaitMs.value),
      relay_pulse: Number(els.relayPulseMs.value),
      before_send_keys: Number(els.beforeSendMs.value),
    },
    cutting_master: {
      window_title_contains: els.windowKeyword.value.trim(),
      send_hotkey: "ctrl+p",
    },
    app: {
      simulation_mode: els.simulationMode.checked,
      simulate_cut: els.simulateCut.checked,
    },
  };
}

function updateModeBadge() {
  if (state.simulation) {
    setBadge(els.modeStatus, "badge-sim", "模拟模式");
  } else {
    setBadge(els.modeStatus, "badge-off", "硬件模式");
  }
}

function updateProgress(elapsedMs, totalMs, label) {
  const progress = totalMs > 0 ? Math.min(1, elapsedMs / totalMs) : 0;
  els.progressFill.style.width = `${progress * 100}%`;
  els.progressText.textContent = `${elapsedMs}/${totalMs}ms`;
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
    option.value = port;
    option.textContent = port;
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
      setBadge(els.serialStatus, "badge-on", "模拟已连接");
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
      setBadge(els.pythonStatus, "badge-on", "Python 运行中");
      sendCommand({ cmd: "get_config" }).then((res) => {
        if (res.event === "config") applyConfigToForm(res.config);
        return refreshPorts();
      }).then(autoConnectSimulation);
      break;
    case "python_exit":
      setBadge(els.pythonStatus, "badge-off", "Python 已退出");
      log("error", payload.message);
      break;
    case "config":
      applyConfigToForm(payload.config);
      break;
    case "config_saved":
      applyConfigToForm(payload.config);
      log("info", "设置已保存");
      break;
    case "connected":
      state.connected = true;
      state.simulation = payload.simulation === true;
      updateModeBadge();
      setBadge(
        els.serialStatus,
        "badge-on",
        payload.simulation ? "模拟已连接" : `已连接 ${payload.port}`
      );
      log("info", payload.simulation ? "模拟模式已连接" : `串口已连接 ${payload.port}`);
      updateControls();
      break;
    case "disconnected":
      state.connected = false;
      setBadge(els.serialStatus, "badge-off", "未连接");
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

[els.retractMs, els.extendMs, els.cutWaitMs, els.relayPulseMs, els.beforeSendMs, els.simulateCut].forEach((el) => {
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
    setBadge(els.pythonStatus, "badge-off", "Python 启动中");
  }
}, 1000);
