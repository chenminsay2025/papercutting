const STEP_TYPE_META = {
  retract: { label: "伸缩杆缩回", testStep: "retract" },
  pulse_a: { label: "继续 (继电器A)", testStep: "pulse_a" },
  focus_window: { label: "获取窗口", testStep: "focus_window" },
  send_hotkey: { label: "发送快捷键", testStep: "send_hotkey" },
  cut_wait: { label: "等待切割", testStep: "cut_wait" },
  extend: { label: "伸缩杆伸出", testStep: "extend" },
  pulse_b: { label: "原点 (继电器B)", testStep: "pulse_b" },
  wait: { label: "等待", testStep: "wait" },
};

const STEP_DEFAULTS = {
  retract: { duration_ms: 3000 },
  extend: { duration_ms: 3000 },
  cut_wait: { duration_ms: 6000 },
  pulse_a: { duration_ms: 200 },
  pulse_b: { duration_ms: 200 },
  wait: { duration_ms: 1000 },
  focus_window: { window_keyword: "Cutting Master", focus_timeout_ms: 800 },
  send_hotkey: { hotkey: "ctrl+p", delay_before_ms: 100, delay_after_ms: 200 },
};

const LEGACY_TIMING_KEYS = {
  retract: "retract",
  extend: "extend",
  cut_wait: "cut_wait",
  pulse_a: "relay_pulse",
  pulse_b: "relay_pulse",
};

const DEFAULT_STEP_TYPES = [
  "retract", "pulse_a", "focus_window", "send_hotkey", "cut_wait", "extend", "pulse_b",
];

const INSERT_OPTIONS = [
  { type: "retract", label: "伸缩杆缩回" },
  { type: "pulse_a", label: "继续 (继电器A)" },
  { type: "focus_window", label: "获取窗口" },
  { type: "send_hotkey", label: "发送快捷键" },
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
  dragIndex: null,
  dropInsertIndex: null,
  actionGroups: [],
  dropIndicatorEl: null,
  waitingPrompt: false,
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
  saveConfigBtn: document.getElementById("saveConfigBtn"),
  stepEditor: document.getElementById("stepEditor"),
  insertStepType: document.getElementById("insertStepType"),
  addStepBtn: document.getElementById("addStepBtn"),
  groupName: document.getElementById("groupName"),
  saveGroupBtn: document.getElementById("saveGroupBtn"),
  groupSelect: document.getElementById("groupSelect"),
  openGroupBtn: document.getElementById("openGroupBtn"),
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

function escAttr(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;");
}

function expandLegacySteps(steps) {
  const expanded = [];
  steps.forEach((step) => {
    if (step.type === "send_cut") {
      expanded.push({
        ...step,
        id: `${step.id || newStepId()}-focus`,
        type: "focus_window",
        label: "获取窗口",
        window_keyword: step.window_keyword,
        focus_timeout_ms: step.before_send_ms ?? step.focus_timeout_ms ?? 800,
      });
      expanded.push({
        ...step,
        id: `${step.id || newStepId()}-hotkey`,
        type: "send_hotkey",
        label: "发送快捷键",
        hotkey: step.hotkey || step.send_hotkey || "ctrl+p",
        delay_before_ms: step.after_focus_ms ?? step.delay_before_ms ?? 100,
        delay_after_ms: step.after_hotkey_ms ?? step.delay_after_ms ?? 200,
      });
    } else {
      expanded.push(step);
    }
  });
  return expanded;
}

function findLastStep(type) {
  return [...state.workflowSteps].reverse().find((step) => step.type === type);
}

function createStep(type, config) {
  const meta = STEP_TYPE_META[type];
  const defaults = STEP_DEFAULTS[type] || {};
  const timings = config?.timings_ms || {};
  const cm = config?.cutting_master || {};
  const lastFocus = findLastStep("focus_window");
  const lastHotkey = findLastStep("send_hotkey");

  const step = {
    id: newStepId(),
    type,
    enabled: true,
    label: meta?.label || type,
  };

  if (type === "focus_window") {
    const base = lastFocus || defaults;
    step.window_keyword = base.window_keyword || cm.window_title_contains || defaults.window_keyword;
    step.focus_timeout_ms = base.focus_timeout_ms ?? timings.before_send_keys ?? defaults.focus_timeout_ms;
  } else if (type === "send_hotkey") {
    const base = lastHotkey || defaults;
    step.hotkey = base.hotkey || cm.send_hotkey || defaults.hotkey;
    step.delay_before_ms = base.delay_before_ms ?? timings.after_focus_ms ?? defaults.delay_before_ms;
    step.delay_after_ms = base.delay_after_ms ?? timings.after_hotkey_ms ?? defaults.delay_after_ms;
  } else {
    const legacyKey = LEGACY_TIMING_KEYS[type] || type;
    step.duration_ms = defaults.duration_ms ?? timings[legacyKey] ?? 1000;
  }
  return step;
}

function normalizeWorkflowSteps(steps, config) {
  const timings = config?.timings_ms || {};
  const cm = config?.cutting_master || {};
  const source = expandLegacySteps(Array.isArray(steps) && steps.length ? steps : []);
  if (!source.length) {
    return DEFAULT_STEP_TYPES.map((type) => createStep(type, config));
  }
  return source.map((step) => {
    const type = step.type;
    if (!STEP_TYPE_META[type]) return null;
    const normalized = {
      id: step.id || newStepId(),
      type,
      enabled: step.enabled !== false,
      label: step.label || STEP_TYPE_META[type]?.label || type,
    };
    if (type === "focus_window") {
      normalized.window_keyword = step.window_keyword || cm.window_title_contains || STEP_DEFAULTS.focus_window.window_keyword;
      normalized.focus_timeout_ms = Number(
        step.focus_timeout_ms ?? step.before_send_ms ?? timings.before_send_keys ?? STEP_DEFAULTS.focus_window.focus_timeout_ms
      );
    } else if (type === "send_hotkey") {
      normalized.hotkey = step.hotkey || step.send_hotkey || cm.send_hotkey || STEP_DEFAULTS.send_hotkey.hotkey;
      normalized.delay_before_ms = Number(
        step.delay_before_ms ?? step.after_focus_ms ?? timings.after_focus_ms ?? STEP_DEFAULTS.send_hotkey.delay_before_ms
      );
      normalized.delay_after_ms = Number(
        step.delay_after_ms ?? step.after_hotkey_ms ?? timings.after_hotkey_ms ?? STEP_DEFAULTS.send_hotkey.delay_after_ms
      );
    } else {
      const legacyKey = LEGACY_TIMING_KEYS[type] || type;
      normalized.duration_ms = Number(step.duration_ms ?? timings[legacyKey] ?? STEP_DEFAULTS[type]?.duration_ms ?? 1000);
    }
    return normalized;
  }).filter(Boolean);
}

function stepDurationMs(step) {
  if (!step.enabled) return 0;
  if (step.type === "focus_window") {
    if (state.simulation && els.simulateCut.checked) return 0;
    return Number(step.focus_timeout_ms) || 0;
  }
  if (step.type === "send_hotkey") {
    if (state.simulation && els.simulateCut.checked) return 0;
    return (Number(step.delay_before_ms) || 0) + (Number(step.delay_after_ms) || 0);
  }
  if (step.type === "pulse_a" || step.type === "pulse_b") {
    return (Number(step.duration_ms) || 0) + 30;
  }
  return Number(step.duration_ms) || 0;
}

function renderInlineField(label, field, step, index, canEdit, inputAttrs = "") {
  const dis = canEdit ? "" : "disabled";
  const value = escAttr(step[field] ?? "");
  return `<label class="step-inline-field">${label}<input type="text" data-field="${field}" data-index="${index}" value="${value}" ${dis} ${inputAttrs} /></label>`;
}

function renderInlineNumber(label, field, step, index, canEdit, min = 0, stepVal = 100) {
  const dis = canEdit ? "" : "disabled";
  return `<label class="step-inline-field">${label}<input type="number" min="${min}" step="${stepVal}" data-field="${field}" data-index="${index}" value="${step[field] ?? 0}" ${dis} /></label>`;
}

function renderStepParams(step, index, canEdit) {
  if (step.type === "focus_window") {
    return `
      ${renderInlineField("窗口", "window_keyword", step, index, canEdit, 'class="step-input-grow"')}
      ${renderInlineNumber("超时ms", "focus_timeout_ms", step, index, canEdit, 0, 100)}
    `;
  }
  if (step.type === "send_hotkey") {
    return `
      ${renderInlineField("快捷键", "hotkey", step, index, canEdit)}
      ${renderInlineNumber("前延迟", "delay_before_ms", step, index, canEdit, 0, 50)}
      ${renderInlineNumber("后延迟", "delay_after_ms", step, index, canEdit, 0, 50)}
    `;
  }
  const isPulse = step.type === "pulse_a" || step.type === "pulse_b";
  const label = step.type === "wait" ? "等待ms" : "时长ms";
  return renderInlineNumber(label, "duration_ms", step, index, canEdit, isPulse ? 50 : 0, isPulse ? 10 : 100);
}

function renderStepTestButtons(step, index, canEdit) {
  const disabled = !(canEdit && state.connected);
  const dis = disabled ? "disabled" : "";
  if (step.type === "focus_window") {
    return `<button type="button" class="btn btn-secondary btn-xs step-test-window" data-index="${index}" ${dis} title="测试获取窗口">窗</button>`;
  }
  if (step.type === "send_hotkey") {
    return `<button type="button" class="btn btn-secondary btn-xs step-test-hotkey" data-index="${index}" ${dis} title="测试快捷键">键</button>`;
  }
  const meta = STEP_TYPE_META[step.type];
  if (!meta?.testStep) return "";
  return `<button type="button" class="btn btn-secondary btn-xs step-test" data-test-step="${meta.testStep}" data-index="${index}" ${dis}>测</button>`;
}

function enabledSteps() {
  return state.workflowSteps.filter((step) => step.enabled);
}

function renderStepEditor() {
  const canEdit = !state.running;

  els.stepEditor.innerHTML = state.workflowSteps.map((step, index) => {
    const duration = stepDurationMs(step);
    let status = "pending";
    if (step.id === state.currentStepId) status = "active";
    else if (state.doneStepIds.has(step.id)) status = "done";
    if (!step.enabled) status = "disabled";

    return `
      <div class="step-row ${status}" data-step-id="${step.id}" data-index="${index}">
        <div class="step-row-main">
          <button type="button" class="step-drag" draggable="${canEdit ? "true" : "false"}" data-index="${index}" title="拖拽排序" ${canEdit ? "" : "disabled"}>⋮⋮</button>
          <label class="step-enable" title="是否执行">
            <input type="checkbox" data-field="enabled" data-index="${index}" ${step.enabled ? "checked" : ""} ${canEdit ? "" : "disabled"} />
          </label>
          <div class="step-index">${index + 1}</div>
          <div class="step-title">${step.label}</div>
          <span class="step-duration-badge">${duration} ms</span>
          <div class="step-actions">
            ${renderStepTestButtons(step, index, canEdit)}
            <button type="button" class="btn btn-ghost btn-xs step-delete" data-index="${index}" ${canEdit && state.workflowSteps.length > 1 ? "" : "disabled"} title="删除">×</button>
          </div>
        </div>
        <div class="step-row-params">${renderStepParams(step, index, canEdit)}</div>
      </div>
    `;
  }).join("");

  updateToolbarState();
}

function getDropIndicator() {
  if (!state.dropIndicatorEl) {
    state.dropIndicatorEl = document.createElement("div");
    state.dropIndicatorEl.className = "step-drop-indicator";
  }
  return state.dropIndicatorEl;
}

function clearDragUi() {
  state.dragIndex = null;
  state.dropInsertIndex = null;
  getDropIndicator().remove();
  els.stepEditor.querySelectorAll(".step-row").forEach((row) => {
    row.classList.remove("is-dragging", "drop-target");
  });
}

function resolveInsertIndex(clientY) {
  const rows = [...els.stepEditor.querySelectorAll(".step-row")];
  if (!rows.length) return 0;
  for (let i = 0; i < rows.length; i += 1) {
    const rect = rows[i].getBoundingClientRect();
    if (clientY < rect.top + rect.height / 2) return i;
  }
  return rows.length;
}

function showDropAt(insertIndex) {
  if (state.dropInsertIndex === insertIndex) return;
  state.dropInsertIndex = insertIndex;
  const rows = [...els.stepEditor.querySelectorAll(".step-row")];
  rows.forEach((row, index) => {
    row.classList.toggle("drop-target", index === insertIndex);
  });
  const indicator = getDropIndicator();
  if (insertIndex >= rows.length) {
    els.stepEditor.appendChild(indicator);
  } else {
    els.stepEditor.insertBefore(indicator, rows[insertIndex]);
  }
}

function reorderSteps(fromIndex, insertIndex) {
  if (fromIndex === insertIndex || fromIndex + 1 === insertIndex) return;
  const [moved] = state.workflowSteps.splice(fromIndex, 1);
  const target = insertIndex > fromIndex ? insertIndex - 1 : insertIndex;
  state.workflowSteps.splice(target, 0, moved);
}

function initStepDragDrop() {
  els.stepEditor.addEventListener("dragstart", (event) => {
    const handle = event.target.closest(".step-drag");
    if (!handle || state.running) return;
    state.dragIndex = Number(handle.dataset.index);
    handle.closest(".step-row")?.classList.add("is-dragging");
    event.dataTransfer.effectAllowed = "move";
    event.dataTransfer.setData("text/plain", String(state.dragIndex));
  });

  els.stepEditor.addEventListener("dragover", (event) => {
    if (state.dragIndex === null || state.running) return;
    event.preventDefault();
    event.dataTransfer.dropEffect = "move";
    showDropAt(resolveInsertIndex(event.clientY));
  });

  els.stepEditor.addEventListener("dragleave", (event) => {
    if (!els.stepEditor.contains(event.relatedTarget)) {
      clearDragUi();
    }
  });

  els.stepEditor.addEventListener("drop", (event) => {
    event.preventDefault();
    if (state.dragIndex === null || state.running) return;
    const insertIndex = resolveInsertIndex(event.clientY);
    reorderSteps(state.dragIndex, insertIndex);
    clearDragUi();
    recalcTotalMs();
    updateControls();
  });

  els.stepEditor.addEventListener("dragend", clearDragUi);
}

function updateToolbarState() {
  const canEdit = !state.running;
  els.addStepBtn.disabled = !canEdit;
  els.saveGroupBtn.disabled = !canEdit;
  els.openGroupBtn.disabled = !canEdit || !els.groupSelect.value;
  els.insertStepType.disabled = !canEdit;
  els.groupName.disabled = !canEdit;
  els.groupSelect.disabled = !canEdit;
}

function updateDurationBadges() {
  els.stepEditor.querySelectorAll(".step-row").forEach((row, index) => {
    const badge = row.querySelector(".step-duration-badge");
    const step = state.workflowSteps[index];
    if (badge && step) badge.textContent = `${stepDurationMs(step)} ms`;
  });
}
function renderActionGroupSelect(groups = state.actionGroups) {
  state.actionGroups = groups;
  const current = els.groupSelect.value;
  els.groupSelect.innerHTML = '<option value="">— 选择 —</option>';
  groups.forEach((group) => {
    const option = document.createElement("option");
    option.value = group.name;
    option.textContent = `${group.name} (${group.step_count} 步)`;
    els.groupSelect.appendChild(option);
  });
  if (current && groups.some((group) => group.name === current)) {
    els.groupSelect.value = current;
  }
  updateToolbarState();
}

async function refreshActionGroups() {
  const response = await sendCommand({ cmd: "list_action_groups" });
  if (response.event === "action_groups") {
    renderActionGroupSelect(response.groups || []);
  }
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

function recalcTotalMs({ rerender = true } = {}) {
  state.totalMs = state.workflowSteps.reduce(
    (sum, step) => sum + stepDurationMs(step),
    0
  );
  updateCycleHint();
  if (rerender) {
    renderStepEditor();
  } else {
    updateDurationBadges();
  }
}

function legacyCuttingMasterFromSteps() {
  const focusStep = state.workflowSteps.find((step) => step.type === "focus_window");
  const hotkeyStep = state.workflowSteps.find((step) => step.type === "send_hotkey");
  return {
    window_title_contains: (focusStep?.window_keyword || "Cutting Master").trim(),
    send_hotkey: (hotkeyStep?.hotkey || "ctrl+p").trim(),
  };
}

function readWorkflowStepsFromState() {
  return state.workflowSteps.map((step) => {
    const copy = {
      id: step.id,
      type: step.type,
      enabled: step.enabled,
      label: step.label,
    };
    if (step.type === "focus_window") {
      copy.window_keyword = String(step.window_keyword || "").trim();
      copy.focus_timeout_ms = Number(step.focus_timeout_ms) || 0;
    } else if (step.type === "send_hotkey") {
      copy.hotkey = String(step.hotkey || "ctrl+p").trim();
      copy.delay_before_ms = Number(step.delay_before_ms) || 0;
      copy.delay_after_ms = Number(step.delay_after_ms) || 0;
    } else {
      copy.duration_ms = Number(step.duration_ms) || 0;
    }
    return copy;
  });
}

function applyConfigToForm(config) {
  state.config = config;
  state.simulation = config.app?.simulation_mode !== false;
  state.workflowSteps = normalizeWorkflowSteps(config.workflow_steps, config);
  els.simulationMode.checked = state.simulation;
  els.simulateCut.checked = config.app?.simulate_cut !== false;
  els.autoLoop.checked = config.app?.auto_loop === true;
  els.loopIntervalMs.value = config.app?.loop_interval_ms ?? 3000;
  els.portSelect.value = config.serial.port;
  els.baudrate.value = config.serial.baudrate ?? 115200;
  els.timeoutMs.value = config.serial.timeout_ms ?? 2000;
  recalcTotalMs();
  updateModeBadge();
  updateControls();
}

function readConfigFromForm() {
  const cuttingMaster = legacyCuttingMasterFromSteps();
  return {
    serial: {
      port: els.portSelect.value,
      baudrate: Number(els.baudrate.value) || 115200,
      timeout_ms: Number(els.timeoutMs.value) || 2000,
    },
    timings_ms: state.config?.timings_ms || {
      retract: 0,
      extend: 0,
      cut_wait: 0,
      relay_pulse: 200,
      before_send_keys: 0,
      after_focus_ms: 0,
      after_hotkey_ms: 0,
    },
    cutting_master: cuttingMaster,
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

let promptInFlight = null;

async function sendCommand(message) {
  return window.cutppaper.sendCommand(message);
}

async function handleUserPrompt(payload) {
  if (promptInFlight === payload.prompt_id) return;
  promptInFlight = payload.prompt_id;
  state.waitingPrompt = true;
  els.phaseLabel.textContent = `等待确认: ${payload.step_label || "步骤"}`;
  updateControls();

  try {
    await restoreAppFocus();
    const action = await window.cutppaper.showActionDialog({
      title: payload.title || "步骤执行出现问题",
      message: payload.message || "发生未知错误",
      detail: payload.detail || payload.step_label || "",
    });
    const label = action === "retry" ? "重试" : action === "skip" ? "跳过此步" : "停止流程";
    log("warn", `用户确认: ${label}`);
    await sendCommand({
      cmd: "prompt_response",
      prompt_id: payload.prompt_id,
      action,
    });
  } catch (err) {
    log("error", err.message);
    try {
      await sendCommand({
        cmd: "prompt_response",
        prompt_id: payload.prompt_id,
        action: "abort",
      });
    } catch (_err) {
      // ignore secondary failure
    }
  } finally {
    state.waitingPrompt = false;
    promptInFlight = null;
    updateControls();
  }
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
      }).then(autoConnectSimulation).then(refreshActionGroups);
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
    case "user_prompt":
      void handleUserPrompt(payload);
      break;
    case "error":
      if (!state.running) {
        state.waitingLoop = false;
        state.loopIndex = 0;
        state.currentStepId = null;
        updateControls();
      }
      log("error", payload.message);
      break;
    case "test_done":
      log("info", `单步测试完成: ${payload.step}`);
      break;
    case "action_groups":
      renderActionGroupSelect(payload.groups || []);
      break;
    case "action_group_saved":
      renderActionGroupSelect(payload.groups || []);
      els.groupName.value = payload.name || els.groupName.value;
      els.groupSelect.value = payload.name || "";
      log("info", `动作组已保存: ${payload.name}`);
      break;
    case "action_group_loaded":
      applyConfigToForm(payload.config);
      els.groupName.value = payload.name || "";
      els.groupSelect.value = payload.name || "";
      log("info", `已打开动作组: ${payload.name}`);
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

async function testFocusWindowStep(step) {
  await saveConfigSilently();
  await yieldAppFocus();
  await sendCommand({
    cmd: "test_cut_window",
    keyword: String(step.window_keyword || "").trim(),
    send_keys: false,
  });
}

async function testHotkeyStep(step) {
  await saveConfigSilently();
  await yieldAppFocus();
  await sendCommand({
    cmd: "test_cut_window",
    keyword: "Cutting Master",
    hotkey: String(step.hotkey || "ctrl+p").trim(),
    send_keys: true,
    delay_before_ms: Number(step.delay_before_ms) || 0,
    delay_after_ms: Number(step.delay_after_ms) || 0,
  });
}

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
  handleStepFieldInput(event.target);
});

els.stepEditor.addEventListener("input", (event) => {
  handleStepFieldInput(event.target);
});

function handleStepFieldInput(target) {
  if (!(target instanceof HTMLInputElement)) return;
  const index = Number(target.dataset.index);
  const field = target.dataset.field;
  if (Number.isNaN(index) || !field || !state.workflowSteps[index]) return;

  if (field === "enabled") {
    state.workflowSteps[index].enabled = target.checked;
    recalcTotalMs();
    updateControls();
    return;
  }
  if (field === "duration_ms" || field.endsWith("_ms")) {
    state.workflowSteps[index][field] = Number(target.value) || 0;
  } else {
    state.workflowSteps[index][field] = target.value;
  }
  recalcTotalMs({ rerender: false });
}

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

  if (target.classList.contains("step-test")) {
    const index = Number(target.dataset.index);
    const testStep = target.dataset.testStep;
    const step = state.workflowSteps[index];
    if (!testStep || !step) return;
    try {
      await saveConfigSilently();
      await sendCommand({
        cmd: "test_step",
        step: testStep,
        workflow_step: readWorkflowStepsFromState()[index],
      });
    } catch (err) {
      log("error", err.message);
    }
    return;
  }

  if (target.classList.contains("step-test-window")) {
    const index = Number(target.dataset.index);
    const step = state.workflowSteps[index];
    if (!step || step.type !== "focus_window") return;
    try {
      await testFocusWindowStep(step);
    } catch (err) {
      log("error", err.message);
    }
    return;
  }

  if (target.classList.contains("step-test-hotkey")) {
    const index = Number(target.dataset.index);
    const step = state.workflowSteps[index];
    if (!step || step.type !== "send_hotkey") return;
    try {
      await testHotkeyStep(step);
    } catch (err) {
      log("error", err.message);
    }
  }
});

els.addStepBtn.addEventListener("click", () => {
  if (state.running) return;
  const type = els.insertStepType.value;
  if (!type) return;
  state.workflowSteps.push(createStep(type, state.config));
  recalcTotalMs();
  updateControls();
});

els.saveGroupBtn.addEventListener("click", async () => {
  try {
    const name = els.groupName.value.trim();
    if (!name) {
      log("warn", "请输入动作组名称");
      return;
    }
    await saveConfigSilently();
    const response = await sendCommand({
      cmd: "save_action_group",
      name,
      workflow_steps: readWorkflowStepsFromState(),
    });
    if (response.event === "error") {
      throw new Error(response.message || "保存动作组失败");
    }
  } catch (err) {
    log("error", err.message);
  }
});

els.openGroupBtn.addEventListener("click", async () => {
  try {
    const name = els.groupSelect.value;
    if (!name) {
      log("warn", "请选择要打开的动作组");
      return;
    }
    const response = await sendCommand({ cmd: "load_action_group", name });
    if (response.event === "error") {
      throw new Error(response.message || "打开动作组失败");
    }
  } catch (err) {
    log("error", err.message);
  }
});

els.groupSelect.addEventListener("change", updateToolbarState);

INSERT_OPTIONS.forEach((opt) => {
  const option = document.createElement("option");
  option.value = opt.type;
  option.textContent = opt.label;
  els.insertStepType.appendChild(option);
});

els.simulateCut.addEventListener("change", recalcTotalMs);

[
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
initStepDragDrop();
updateControls();
recalcTotalMs();

setInterval(async () => {
  const ready = await window.cutppaper.isBackendReady();
  if (!ready) {
    setBadge(els.pythonStatus, "badge-off", "Python 启动中");
  }
}, 1000);
