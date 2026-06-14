const STEP_TYPE_META = {
  retract: { label: "伸缩杆缩回", timingKey: "retract", testStep: "retract" },
  pulse_a: { label: "继续 (继电器A)", timingKey: "relay_pulse", testStep: "pulse_a" },
  send_cut: { label: "发送切割 Ctrl+P", sendCutBudget: true, testStep: "send_cut" },
  cut_wait: { label: "等待切割", timingKey: "cut_wait", testStep: "cut_wait" },
  extend: { label: "伸缩杆伸出", timingKey: "extend", testStep: "extend" },
  pulse_b: { label: "原点 (继电器B)", timingKey: "relay_pulse", testStep: "pulse_b" },
  wait: { label: "等待", customDuration: true, testStep: "wait" },
};

const INSERT_OPTIONS = [
  { type: "retract", label: "伸缩杆缩回" },
  { type: "pulse_a", label: "继续 (继电器A)" },
  { type: "send_cut", label: "发送切割" },
  { type: "cut_wait", label: "等待切割" },
  { type: "extend", label: "伸缩杆伸出" },
  { type: "pulse_b", label: "原点 (继电器B)" },
  { type: "wait", label: "等待时间" },
];

const state = {
  config: null,
  workflowSteps: [],
  running: false,
  connected: false,
  simulation: true,
  currentStepId: null,
  doneStepIds: new Set(),
  loopIndex: 0,
  waitingLoop: false,
  loopIntervalMs: 3000,
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
  stepEditor: document.getElementById("stepEditor"),
  phaseLabel: document.getElementById("phaseLabel"),
  progressText: document.getElementById("progressText"),
  cycleHint: document.getElementById("cycleHint"),
  progressFill: document.getElementById("progressFill"),
  startBtn: document.getElementById("startBtn"),
  estopBtn: document.getElementById("estopBtn"),
  autoLoop: document.getElementById("autoLoop"),
  loopIntervalMs: document.getElementById("loopIntervalMs"),
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

function newStepId() {
  return `step-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
}

function createStep(type) {
  const meta = STEP_TYPE_META[type];
  const step = {
    id: newStepId(),
    type,
    enabled: true,
    label: meta?.label || type,
  };
  if (type === "wait") {
    step.duration_ms = 1000;
  }
  return step;
}

function normalizeWorkflowSteps(steps) {
  if (!Array.isArray(steps) || steps.length === 0) {
    return INSERT_OPTIONS.slice(0, 6).map((opt) => createStep(opt.type));
  }
  return steps.map((step) => ({
    id: step.id || newStepId(),
    type: step.type,
    enabled: step.enabled !== false,
    label: step.label || STEP_TYPE_META[step.type]?.label || step.type,
    ...(step.type === "wait" ? { duration_ms: Number(step.duration_ms) || 1000 } : {}),
  }));
}

function currentTimings() {
  return {
    retract: Number(els.retractMs.value) || 0,
    extend: Number(els.extendMs.value) || 0,
    cut_wait: Number(els.cutWaitMs.value) || 0,
    relay_pulse: Number(els.relayPulseMs.value) || 0,
    before_send_keys: Number(els.beforeSendMs.value) || 0,
    after_focus_ms: Number(els.afterFocusMs.value) || 0,
    after_hotkey_ms: Number(els.afterHotkeyMs.value) || 0,
  };
}

function sendCutBudgetMs(timings) {
  return timings.before_send_keys + timings.after_focus_ms + timings.after_hotkey_ms;
}

function stepDurationMs(step, timings) {
  const meta = STEP_TYPE_META[step.type];
  if (!step.enabled) return 0;
  if (step.type === "wait") return Number(step.duration_ms) || 0;
  if (meta?.sendCutBudget) {
    if (state.simulation && els.simulateCut.checked) return 0;
    return sendCutBudgetMs(timings);
  }
  if (step.type === "pulse_a" || step.type === "pulse_b") {
    return (timings.relay_pulse || 0) + 30;
  }
  if (meta?.timingKey) return timings[meta.timingKey] || 0;
  return 0;
}

function enabledSteps() {
  return state.workflowSteps.filter((step) => step.enabled);
}

function renderStepEditor() {
  const timings = currentTimings();
  const canEdit = !state.running;

  els.stepEditor.innerHTML = state.workflowSteps.map((step, index) => {
    const meta = STEP_TYPE_META[step.type] || {};
    const duration = stepDurationMs(step, timings);
    let status = "pending";
    if (step.id === state.currentStepId) status = "active";
    else if (state.doneStepIds.has(step.id)) status = "done";
    if (!step.enabled) status = "disabled";

    const waitField = step.type === "wait"
      ? `<label class="step-wait-ms">等待 (ms)<input type="number" min="0" step="100" data-field="duration_ms" data-index="${index}" value="${step.duration_ms ?? 1000}" ${canEdit ? "" : "disabled"} /></label>`
      : `<span class="step-duration">${duration} ms</span>`;

    const insertOptions = INSERT_OPTIONS.map(
      (opt) => `<button type="button" class="insert-option" data-insert-type="${opt.type}" data-after-index="${index}">${opt.label}</button>`
    ).join("");

    return `
      <div class="step-row ${status}" data-step-id="${step.id}">
        <label class="step-enable" title="是否执行">
          <input type="checkbox" data-field="enabled" data-index="${index}" ${step.enabled ? "checked" : ""} ${canEdit ? "" : "disabled"} />
        </label>
        <div class="step-index">${index + 1}</div>
        <div class="step-body">
          <div class="step-title">${step.label}</div>
          <div class="step-meta">
            <span class="step-type">${meta.label || step.type}</span>
            ${waitField}
          </div>
        </div>
        <div class="step-actions">
          ${meta.testStep ? `<button type="button" class="btn btn-secondary btn-xs step-test" data-test-step="${meta.testStep}" data-index="${index}" ${canEdit && state.connected ? "" : "disabled"}>测</button>` : ""}
          <button type="button" class="btn btn-ghost btn-xs step-delete" data-index="${index}" ${canEdit && state.workflowSteps.length > 1 ? "" : "disabled"} title="删除">×</button>
        </div>
      </div>
      <div class="step-insert-row">
        <details class="step-insert" ${canEdit ? "" : "data-disabled=true"}>
          <summary>＋ 在此后插入</summary>
          <div class="insert-menu">${insertOptions}</div>
        </details>
      </div>
    `;
  }).join("");
}

function updateStartBtnLabel() {
  if (state.running) {
    els.startBtn.textContent = state.waitingLoop ? "等待下一轮…" : "运行中…";
    return;
  }
  els.startBtn.textContent = els.autoLoop.checked ? "开始（自动循环）" : "开始本轮";
}

function updateCycleHint() {
  const base = `~${(state.totalMs / 1000).toFixed(1)}s`;
  const enabledCount = enabledSteps().length;
  const suffix = enabledCount < state.workflowSteps.length ? ` · ${enabledCount}/${state.workflowSteps.length} 步` : "";
  if (els.autoLoop.checked) {
    const gap = Number(els.loopIntervalMs.value) || 0;
    els.cycleHint.textContent = gap > 0 ? `${base}${suffix} · 间隔 ${gap} ms` : `${base}${suffix} · 连续循环`;
  } else {
    els.cycleHint.textContent = `${base}${suffix}`;
  }
}

function updateControls() {
  const canRun = state.connected && !state.running && enabledSteps().length > 0;
  els.startBtn.disabled = !canRun;
  els.connectBtn.disabled = state.connected || state.running;
  els.disconnectBtn.disabled = !state.connected || state.running;
  els.saveConfigBtn.disabled = state.running;
  els.simulationMode.disabled = state.running;
  els.autoLoop.disabled = state.running;
  els.loopIntervalMs.disabled = state.running;
  els.serialPanel.classList.toggle("disabled", state.simulation);
  updateStartBtnLabel();
  renderStepEditor();
}

function recalcTotalMs() {
  const timings = currentTimings();
  state.totalMs = state.workflowSteps.reduce(
    (sum, step) => sum + stepDurationMs(step, timings),
    0
  );
  updateCycleHint();
  renderStepEditor();
}

function readWorkflowStepsFromState() {
  return state.workflowSteps.map((step) => {
    const copy = {
      id: step.id,
      type: step.type,
      enabled: step.enabled,
      label: step.label,
    };
    if (step.type === "wait") {
      copy.duration_ms = Number(step.duration_ms) || 0;
    }
    return copy;
  });
}

function applyConfigToForm(config) {
  state.config = config;
  state.simulation = config.app?.simulation_mode !== false;
  state.workflowSteps = normalizeWorkflowSteps(config.workflow_steps);
  els.simulationMode.checked = state.simulation;
  els.simulateCut.checked = config.app?.simulate_cut !== false;
  els.autoLoop.checked = config.app?.auto_loop === true;
  els.loopIntervalMs.value = config.app?.loop_interval_ms ?? 3000;
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
  updateControls();
}

function readConfigFromForm() {
  return {
    serial: {
      port: els.portSelect.value,
      baudrate: Number(els.baudrate.value) || 115200,
      timeout_ms: Number(els.timeoutMs.value) || 2000,
    },
    timings_ms: currentTimings(),
    cutting_master: {
      window_title_contains: els.windowKeyword.value.trim(),
      send_hotkey: els.sendHotkey.value.trim() || "ctrl+p",
    },
    app: {
      simulation_mode: els.simulationMode.checked,
      simulate_cut: els.simulateCut.checked,
      auto_loop: els.autoLoop.checked,
      loop_interval_ms: Number(els.loopIntervalMs.value) || 0,
    },
    workflow_steps: readWorkflowStepsFromState(),
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

function markDoneBeforeStep(stepId) {
  const done = new Set();
  for (const step of enabledSteps()) {
    if (step.id === stepId) break;
    done.add(step.id);
  }
  state.doneStepIds = done;
}

function markAllEnabledDone() {
  state.doneStepIds = new Set(enabledSteps().map((step) => step.id));
}

function resetRunVisuals() {
  state.currentStepId = enabledSteps()[0]?.id || null;
  state.doneStepIds = new Set();
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
      state.waitingLoop = false;
      state.loopIndex = 1;
      resetRunVisuals();
      updateControls();
      if (payload.auto_loop) {
        const gap = payload.loop_interval_ms ?? 0;
        log("info", gap > 0 ? `自动循环已启动（轮间间隔 ${gap} ms）` : "自动循环已启动（无间隔）");
      } else {
        log("info", "开始本轮");
      }
      break;
    case "cycle_looped":
      state.waitingLoop = false;
      state.loopIndex = payload.loop_index || state.loopIndex + 1;
      resetRunVisuals();
      updateControls();
      log("info", `开始第 ${state.loopIndex} 轮`);
      break;
    case "loop_wait":
      state.waitingLoop = true;
      state.currentStepId = null;
      markAllEnabledDone();
      updateProgress(0, payload.duration_ms || state.loopIntervalMs, "等待下一轮");
      updateControls();
      log("info", payload.message || "轮间等待");
      break;
    case "loop_wait_tick":
      updateProgress(
        payload.elapsed_ms ?? 0,
        payload.total_ms ?? state.loopIntervalMs,
        `等待下一轮（剩余 ${payload.remaining_ms ?? 0} ms）`
      );
      break;
    case "cycle_done":
      markAllEnabledDone();
      state.currentStepId = null;
      if (payload.will_repeat) {
        state.loopIntervalMs = payload.loop_interval_ms ?? state.loopIntervalMs;
        updateProgress(state.totalMs, state.totalMs, `第 ${payload.loop_index || state.loopIndex} 轮完成`);
        updateControls();
        log("info", `第 ${payload.loop_index || state.loopIndex} 轮完成，等待下一轮…`);
        break;
      }
      state.running = false;
      state.waitingLoop = false;
      state.loopIndex = 0;
      updateProgress(state.totalMs, state.totalMs, "本轮完成");
      updateControls();
      log("info", "本轮完成，请取纸后可再次开始");
      break;
    case "cycle_aborted":
      state.running = false;
      state.waitingLoop = false;
      state.loopIndex = 0;
      state.currentStepId = null;
      state.doneStepIds = new Set();
      updateControls();
      log("warn", "流程已中止");
      break;
    case "progress":
    case "state":
      if (payload.step_id) {
        state.currentStepId = payload.step_id;
        markDoneBeforeStep(payload.step_id);
      }
      if (!state.waitingLoop) {
        updateProgress(
          payload.elapsed_ms ?? 0,
          payload.total_ms ?? state.totalMs,
          payload.phase_label || payload.message || "运行中"
        );
      }
      updateControls();
      break;
    case "log":
      log(payload.level || "info", payload.message);
      break;
    case "error":
      state.running = false;
      state.waitingLoop = false;
      state.loopIndex = 0;
      state.currentStepId = null;
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

els.stepEditor.addEventListener("change", (event) => {
  const target = event.target;
  if (!(target instanceof HTMLInputElement)) return;
  const index = Number(target.dataset.index);
  if (Number.isNaN(index) || !state.workflowSteps[index]) return;

  if (target.dataset.field === "enabled") {
    state.workflowSteps[index].enabled = target.checked;
    recalcTotalMs();
    updateControls();
  }
  if (target.dataset.field === "duration_ms") {
    state.workflowSteps[index].duration_ms = Number(target.value) || 0;
    recalcTotalMs();
  }
});

els.stepEditor.addEventListener("click", async (event) => {
  const target = event.target;
  if (!(target instanceof HTMLElement)) return;

  if (target.classList.contains("step-delete")) {
    const index = Number(target.dataset.index);
    if (state.running || state.workflowSteps.length <= 1) return;
    state.workflowSteps.splice(index, 1);
    recalcTotalMs();
    updateControls();
    return;
  }

  if (target.classList.contains("insert-option")) {
    if (state.running) return;
    const index = Number(target.dataset.afterIndex);
    const type = target.dataset.insertType;
    if (Number.isNaN(index) || !type) return;
    state.workflowSteps.splice(index + 1, 0, createStep(type));
    recalcTotalMs();
    updateControls();
    return;
  }

  if (target.classList.contains("step-test")) {
    const index = Number(target.dataset.index);
    const testStep = target.dataset.testStep;
    const step = state.workflowSteps[index];
    if (!testStep || !step) return;
    try {
      await saveConfigSilently();
      const message = { cmd: "test_step", step: testStep };
      if (testStep === "wait") {
        message.duration_ms = Number(step.duration_ms) || 1000;
      }
      await sendCommand(message);
    } catch (err) {
      log("error", err.message);
    }
  }
});

[
  els.retractMs,
  els.extendMs,
  els.cutWaitMs,
  els.relayPulseMs,
  els.beforeSendMs,
  els.afterFocusMs,
  els.afterHotkeyMs,
  els.simulateCut,
  els.autoLoop,
  els.loopIntervalMs,
].forEach((el) => {
  el.addEventListener("input", () => {
    recalcTotalMs();
    if (el === els.autoLoop || el === els.loopIntervalMs) {
      updateStartBtnLabel();
    }
  });
});

els.autoLoop.addEventListener("change", updateStartBtnLabel);

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
recalcTotalMs();

setInterval(async () => {
  const ready = await window.cutppaper.isBackendReady();
  if (!ready) {
    setBadge(els.pythonStatus, "badge-off", "Python 启动中");
  }
}, 1000);
