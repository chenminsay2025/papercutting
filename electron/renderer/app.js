const DEFAULT_START_HOTKEY = "f5";

const HOTKEY_PRESETS = [
  { label: "Ctrl+P", value: "ctrl+p" },
  { label: "Enter", value: "enter" },
  { label: "F5", value: "f5" },
  { label: "Esc", value: "esc" },
  { label: "Space", value: "space" },
  { label: "Tab", value: "tab" },
  { label: "Ctrl+S", value: "ctrl+s" },
  { label: "Ctrl+Enter", value: "ctrl+enter" },
  { label: "Alt+F4", value: "alt+f4" },
  { label: "Ctrl+Shift+P", value: "ctrl+shift+p" },
];

const HOTKEY_KEY_ALIASES = {
  " ": "space",
  ArrowUp: "up",
  ArrowDown: "down",
  ArrowLeft: "left",
  ArrowRight: "right",
  Escape: "esc",
  Delete: "delete",
  Backspace: "backspace",
  Tab: "tab",
  Enter: "enter",
  Home: "home",
  End: "end",
  PageUp: "page up",
  PageDown: "page down",
  Insert: "insert",
  CapsLock: "caps lock",
  NumLock: "num lock",
  ScrollLock: "scroll lock",
  PrintScreen: "print screen",
  Pause: "pause",
};

const STEP_TYPE_META = {
  retract: { label: "伸缩杆缩回", testStep: "retract" },
  pulse_a: { testStep: "pulse_a" },
  focus_window: { label: "激活窗口", testStep: "focus_window" },
  send_hotkey: { label: "按键操作", testStep: "send_hotkey" },
  restore_app: { label: "回到窗口", testStep: "restore_app" },
  extend: { label: "伸缩杆伸出", testStep: "extend" },
  pulse_b: { testStep: "pulse_b" },
  wait: { label: "等待", testStep: "wait" },
  confirm_dialog: { label: "弹窗确认" },
  condition_check: { label: "如果" },
  else_branch: { label: "否则" },
  end_if: { label: "结束如果" },
  call_group: { label: "调用动作组" },
  stop: { label: "停止流程" },
};

const STEP_DEFAULTS = {
  retract: { duration_ms: 3000 },
  extend: { duration_ms: 3000 },
  pulse_a: { duration_ms: 200 },
  pulse_b: { duration_ms: 200 },
  wait: { duration_ms: 1000 },
  focus_window: { window_keyword: "Cutting Master", delay_ms: 800 },
  send_hotkey: { hotkey: "ctrl+p", delay_ms: 200, press_count: 1, press_interval_ms: 0 },
  restore_app: { window_keyword: "PaperCutting", delay_ms: 0 },
  confirm_dialog: { prompt_text: "请确认后继续" },
  condition_check: { status_key: "paper", expected_value: "home" },
  call_group: { group_name: "" },
};

const CONDITION_STATUS_KEYS = [
  { value: "paper", label: "压纸" },
  { value: "motor", label: "电机" },
  { value: "usb", label: "USB" },
];

const CONDITION_STATUS_OPTIONS = {
  paper: [
    { value: "home", label: "压纸中" },
    { value: "away", label: "未压纸" },
  ],
  motor: [
    { value: "idle", label: "停止" },
    { value: "retract", label: "缩回" },
    { value: "extend", label: "伸出" },
    { value: "relay", label: "继电器" },
  ],
  usb: [
    { value: "connected", label: "已连接" },
  ],
};

function getConditionValueLabel(statusKey, expectedValue) {
  const options = CONDITION_STATUS_OPTIONS[statusKey] || [];
  return options.find((item) => item.value === expectedValue)?.label || expectedValue || "—";
}

function updateConditionStepLabel(step) {
  if (step?.type !== "condition_check") return;
  const keyLabel = CONDITION_STATUS_KEYS.find((item) => item.value === step.status_key)?.label || step.status_key;
  const valLabel = getConditionValueLabel(step.status_key, step.expected_value);
  step.label = `如果·${keyLabel}=${valLabel}`;
}

function updateCallGroupStepLabel(step) {
  if (step?.type !== "call_group") return;
  const name = String(step.group_name || "").trim();
  step.label = name ? `调用·${name}` : "调用动作组";
}

function computeBranchLayout(steps) {
  const layout = steps.map(() => ({}));
  const stack = [];
  const setDepth = (index, depth) => {
    layout[index].depth = Math.max(layout[index].depth ?? 0, depth);
  };
  for (let i = 0; i < steps.length; i++) {
    const type = steps[i].type;
    if (type === "condition_check") {
      const depth = stack.length;
      stack.push({ ifIdx: i, depth });
      layout[i].role = "if";
      setDepth(i, depth);
    } else if (type === "else_branch") {
      const depth = Math.max(0, stack.length - 1);
      if (stack.length) {
        stack[stack.length - 1].elseIdx = i;
      }
      layout[i].role = "else";
      setDepth(i, depth);
    } else if (type === "end_if") {
      if (!stack.length) {
        layout[i].role = "endif";
        layout[i].invalid = true;
        continue;
      }
      const block = stack.pop();
      layout[i].role = "endif";
      setDepth(i, block.depth);
      const elseIdx = block.elseIdx ?? -1;
      const thenEnd = elseIdx >= 0 ? elseIdx : i;
      const bodyDepth = block.depth + 1;
      for (let j = block.ifIdx + 1; j < thenEnd; j++) {
        layout[j].zone = "then";
        setDepth(j, bodyDepth);
      }
      if (elseIdx >= 0) {
        for (let j = elseIdx + 1; j < i; j++) {
          layout[j].zone = "else";
          setDepth(j, bodyDepth);
        }
      }
    }
  }
  layout.unbalanced = stack.length > 0;
  return layout;
}

const STEP_NOTE_DEFAULT = "";
const STEP_DELAY_DEFAULT = 0;

const LEGACY_TIMING_KEYS = {
  retract: "retract",
  extend: "extend",
  pulse_a: "relay_pulse",
  pulse_b: "relay_pulse",
};

const DEFAULT_STEP_TYPES = [
  "retract", "pulse_a", "focus_window", "send_hotkey", "wait", "extend", "pulse_b",
];

const DEFAULT_STEP_TABLE_COLUMNS = {
  enable: 40,
  name: 108,
  settings: 220,
  actions: 40,
};

const STEP_TABLE_COLUMN_LIMITS = { min: 32, max: 480 };

const INSERT_STEP_TYPES = [
  "retract", "pulse_a", "focus_window", "send_hotkey", "restore_app", "extend", "pulse_b", "wait", "confirm_dialog",
  "condition_check", "else_branch", "end_if", "call_group", "stop",
];

const DEFAULT_RELAY_LABELS = {
  relay_k3: "继电器K3",
  relay_k4: "继电器K4",
};

function getRelayLabels(config = state.config) {
  const raw = config?.relay_labels || {};
  const legacy = config?.simulated_buttons || {};
  const relayK3 = String(
    raw.relay_k3 || legacy.button_b || DEFAULT_RELAY_LABELS.relay_k3
  ).trim() || DEFAULT_RELAY_LABELS.relay_k3;
  const relayK4 = String(
    raw.relay_k4 || legacy.button_a || DEFAULT_RELAY_LABELS.relay_k4
  ).trim() || DEFAULT_RELAY_LABELS.relay_k4;
  return { relay_k3: relayK3, relay_k4: relayK4 };
}

function getPulseStepLabel(type, config = state.config) {
  const names = getRelayLabels(config);
  if (type === "pulse_a") return names.relay_k3;
  if (type === "pulse_b") return names.relay_k4;
  return STEP_TYPE_META[type]?.label || type;
}

function getStepTypeLabel(type, config = state.config) {
  if (type === "pulse_a" || type === "pulse_b") return getPulseStepLabel(type, config);
  return STEP_TYPE_META[type]?.label || type;
}

function getStepDisplayLabel(step, config = state.config) {
  if (step.type === "pulse_a" || step.type === "pulse_b") {
    return getPulseStepLabel(step.type, config);
  }
  return step.label;
}

function syncPulseStepLabels(steps, config = state.config) {
  return steps.map((step) => {
    if (step.type === "pulse_a" || step.type === "pulse_b") {
      return { ...step, label: getPulseStepLabel(step.type, config) };
    }
    return step;
  });
}

const state = {
  config: null,
  workflowSteps: [],
  running: false,
  connected: false,
  connectedPort: "",
  rodPosition: null,
  motorState: null,
  pythonReady: false,
  pythonExit: false,
  autoConnectInProgress: false,
  phaseLabel: "空闲",
  progressElapsed: 0,
  progressTotal: 0,
  progressRatio: null,
  simulation: false,
  currentStepId: null,
  currentStepProgress: 0,
  doneStepIds: new Set(),
  loopIndex: 0,
  waitingLoop: false,
  loopIntervalMs: 3000,
  totalMs: 0,
  dragIndex: null,
  dropInsertIndex: null,
  actionGroups: [],
  dropPreviewEl: null,
  landedStepId: null,
  stepRowMenuScrollBound: false,
  stepNoteEditIndex: null,
  stepDelayEditIndex: null,
  hotkeyEditIndex: null,
  hotkeyPickerMode: null,
  hotkeyPickerDraft: "",
  windowPickerIndex: null,
  openWindowsCache: [],
  openWindowsFetchedAt: 0,
  waitingPrompt: false,
  columnResize: null,
};

const els = {
  connStatusDot: document.getElementById("connStatusDot"),
  connBar: document.getElementById("connBar"),
  logBtn: document.getElementById("logBtn"),
  settingsBtn: document.getElementById("settingsBtn"),
  settingsModal: document.getElementById("settingsModal"),
  settingsBackdrop: document.getElementById("settingsBackdrop"),
  settingsCloseBtn: document.getElementById("settingsCloseBtn"),
  connectionModal: document.getElementById("connectionModal"),
  connectionBackdrop: document.getElementById("connectionBackdrop"),
  connectionCloseBtn: document.getElementById("connectionCloseBtn"),
  connModalStatus: document.getElementById("connModalStatus"),
  modalConnectBtn: document.getElementById("modalConnectBtn"),
  modalDisconnectBtn: document.getElementById("modalDisconnectBtn"),
  serialPanel: document.getElementById("serialPanel"),
  portSelect: document.getElementById("portSelect"),
  baudrate: document.getElementById("baudrate"),
  timeoutMs: document.getElementById("timeoutMs"),
  refreshPortsBtn: document.getElementById("refreshPortsBtn"),
  relayK3Name: document.getElementById("relayK3Name"),
  relayK4Name: document.getElementById("relayK4Name"),
  startHotkeyBtn: document.getElementById("startHotkeyBtn"),
  startHotkeyClearBtn: document.getElementById("startHotkeyClearBtn"),
  simulationMode: document.getElementById("simulationMode"),
  autoConnectMode: document.getElementById("autoConnectMode"),
  stepEditor: document.getElementById("stepEditor"),
  colEnable: document.getElementById("colEnable"),
  colName: document.getElementById("colName"),
  colSettings: document.getElementById("colSettings"),
  colActions: document.getElementById("colActions"),
  stepTable: document.querySelector(".step-table"),
  addStepMenuBtn: document.getElementById("addStepMenuBtn"),
  addStepMenu: document.getElementById("addStepMenu"),
  loopMenuBtn: document.getElementById("loopMenuBtn"),
  loopMenu: document.getElementById("loopMenu"),
  actionFileMenuBtn: document.getElementById("actionFileMenuBtn"),
  actionFileMenu: document.getElementById("actionFileMenu"),
  saveGroupModal: document.getElementById("saveGroupModal"),
  saveGroupBackdrop: document.getElementById("saveGroupBackdrop"),
  saveGroupCloseBtn: document.getElementById("saveGroupCloseBtn"),
  saveGroupConfirmBtn: document.getElementById("saveGroupConfirmBtn"),
  groupNameInput: document.getElementById("groupNameInput"),
  manageGroupsModal: document.getElementById("manageGroupsModal"),
  manageGroupsBackdrop: document.getElementById("manageGroupsBackdrop"),
  manageGroupsCloseBtn: document.getElementById("manageGroupsCloseBtn"),
  manageGroupsList: document.getElementById("manageGroupsList"),
  cycleHint: document.getElementById("cycleHint"),
  progressFill: document.getElementById("progressFill"),
  startBtn: document.getElementById("startBtn"),
  estopBtn: document.getElementById("estopBtn"),
  autoLoop: document.getElementById("autoLoop"),
  loopIntervalMs: document.getElementById("loopIntervalMs"),
  confirmPromptModal: document.getElementById("confirmPromptModal"),
  confirmPromptBackdrop: document.getElementById("confirmPromptBackdrop"),
  confirmPromptStep: document.getElementById("confirmPromptStep"),
  confirmPromptMessage: document.getElementById("confirmPromptMessage"),
  confirmPromptDetail: document.getElementById("confirmPromptDetail"),
  confirmPromptOkBtn: document.getElementById("confirmPromptOkBtn"),
  confirmPromptCancelBtn: document.getElementById("confirmPromptCancelBtn"),
  stepNoteModal: document.getElementById("stepNoteModal"),
  stepNoteBackdrop: document.getElementById("stepNoteBackdrop"),
  stepNoteCloseBtn: document.getElementById("stepNoteCloseBtn"),
  stepNoteInput: document.getElementById("stepNoteInput"),
  stepNoteSaveBtn: document.getElementById("stepNoteSaveBtn"),
  stepNoteClearBtn: document.getElementById("stepNoteClearBtn"),
  stepDelayModal: document.getElementById("stepDelayModal"),
  stepDelayBackdrop: document.getElementById("stepDelayBackdrop"),
  stepDelayCloseBtn: document.getElementById("stepDelayCloseBtn"),
  stepDelayInput: document.getElementById("stepDelayInput"),
  stepDelaySaveBtn: document.getElementById("stepDelaySaveBtn"),
  stepDelayClearBtn: document.getElementById("stepDelayClearBtn"),
  confirmPromptPanel: document.getElementById("confirmPromptPanel"),
  winMinimizeBtn: document.getElementById("winMinimizeBtn"),
  winCloseBtn: document.getElementById("winCloseBtn"),
  hotkeyPickerModal: document.getElementById("hotkeyPickerModal"),
  hotkeyPickerBackdrop: document.getElementById("hotkeyPickerBackdrop"),
  hotkeyPickerCloseBtn: document.getElementById("hotkeyPickerCloseBtn"),
  hotkeyPickerCancelBtn: document.getElementById("hotkeyPickerCancelBtn"),
  hotkeyPickerSaveBtn: document.getElementById("hotkeyPickerSaveBtn"),
  hotkeyCaptureZone: document.getElementById("hotkeyCaptureZone"),
  hotkeyCaptureValue: document.getElementById("hotkeyCaptureValue"),
  hotkeyPresetGrid: document.getElementById("hotkeyPresetGrid"),
  windowPickerMenu: document.getElementById("windowPickerMenu"),
  windowPickerSearch: document.getElementById("windowPickerSearch"),
  windowPickerList: document.getElementById("windowPickerList"),
};

function log(level, message) {
  const time = new Date().toLocaleTimeString();
  const line = `[${time}] [${level}] ${message}`;
  if (window.cutppaper.logLine) {
    window.cutppaper.logLine(line);
  }
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
        label: "激活窗口",
        window_keyword: step.window_keyword,
        delay_ms: step.before_send_ms ?? step.focus_timeout_ms ?? step.delay_ms ?? 800,
      });
      expanded.push({
        ...step,
        id: `${step.id || newStepId()}-hotkey`,
        type: "send_hotkey",
        label: "按键操作",
        hotkey: step.hotkey || step.send_hotkey || "ctrl+p",
        delay_ms: step.after_hotkey_ms ?? step.delay_after_ms ?? step.delay_ms ?? 200,
        press_count: step.press_count ?? 1,
        press_interval_ms: step.press_interval_ms ?? 0,
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
  const defaults = STEP_DEFAULTS[type] || {};
  const timings = config?.timings_ms || {};
  const cm = config?.cutting_master || {};
  const lastFocus = findLastStep("focus_window");
  const lastHotkey = findLastStep("send_hotkey");

  const step = {
    id: newStepId(),
    type,
    enabled: true,
    label: getStepTypeLabel(type, config),
    note: findLastStep(type)?.note ?? STEP_NOTE_DEFAULT,
    delay_ms: findLastStep(type)?.delay_ms ?? STEP_DEFAULTS[type]?.delay_ms ?? STEP_DELAY_DEFAULT,
  };

  if (type === "focus_window") {
    const base = lastFocus || defaults;
    step.window_keyword = base.window_keyword || cm.window_title_contains || defaults.window_keyword;
  } else if (type === "send_hotkey") {
    const base = lastHotkey || defaults;
    step.hotkey = base.hotkey || cm.send_hotkey || defaults.hotkey;
    step.press_count = Number(base.press_count ?? defaults.press_count ?? 1);
    step.press_interval_ms = Number(base.press_interval_ms ?? defaults.press_interval_ms ?? 0);
  } else if (type === "restore_app") {
    const lastRestore = findLastStep("restore_app");
    const base = lastRestore || defaults;
    step.window_keyword = base.window_keyword || defaults.window_keyword || "PaperCutting";
  } else if (type === "confirm_dialog") {
    const lastConfirm = findLastStep("confirm_dialog");
    step.prompt_text = lastConfirm?.prompt_text || defaults.prompt_text || "请确认后继续";
  } else if (type === "condition_check") {
    const lastCondition = findLastStep("condition_check");
    step.status_key = lastCondition?.status_key || defaults.status_key || "paper";
    const options = CONDITION_STATUS_OPTIONS[step.status_key] || CONDITION_STATUS_OPTIONS.paper;
    const fallback = options[0]?.value || "home";
    step.expected_value = lastCondition?.expected_value || defaults.expected_value || fallback;
    if (!options.some((item) => item.value === step.expected_value)) {
      step.expected_value = fallback;
    }
    updateConditionStepLabel(step);
  } else if (type === "call_group") {
    const lastCall = findLastStep("call_group");
    step.group_name = String(lastCall?.group_name || defaults.group_name || "").trim();
    updateCallGroupStepLabel(step);
  } else if (type === "else_branch" || type === "end_if" || type === "stop") {
    // 分支标记，无额外字段
  } else if (type === "wait") {
    const lastWait = findLastStep("wait");
    step.duration_ms = Number(
      lastWait?.duration_ms ?? defaults.duration_ms ?? timings.cut_wait ?? timings.wait ?? 1000
    );
  } else {
    const legacyKey = LEGACY_TIMING_KEYS[type] || type;
    step.duration_ms = defaults.duration_ms ?? timings[legacyKey] ?? 1000;
  }
  return step;
}

function getStepDelayMs(step) {
  if (step?.delay_ms != null && step.delay_ms !== "") {
    return Math.max(0, Number(step.delay_ms) || 0);
  }
  if (step?.type === "focus_window") {
    return Math.max(0, Number(step.focus_timeout_ms) || 0);
  }
  if (step?.type === "send_hotkey") {
    return Math.max(0, Number(step.delay_after_ms) || 0);
  }
  return STEP_DELAY_DEFAULT;
}

function normalizeWorkflowSteps(steps, config) {
  const timings = config?.timings_ms || {};
  const cm = config?.cutting_master || {};
  const source = expandLegacySteps(Array.isArray(steps) && steps.length ? steps : []);
  if (!source.length) {
    return DEFAULT_STEP_TYPES.map((type) => {
      const step = createStep(type, config);
      if (type === "wait") {
        step.label = "等待切割";
        step.duration_ms = Number(timings.cut_wait ?? 6000);
        step.note = "等待切割机完成";
      }
      return step;
    });
  }
  return syncPulseStepLabels(
    source.map((rawStep) => {
    let step = rawStep;
    let type = step.type;
    if (type === "cut_wait") {
      type = "wait";
      step = {
        ...step,
        type: "wait",
        note: String(step.note || step.label || "等待切割").trim(),
      };
    }
    if (!STEP_TYPE_META[type]) return null;
    const normalized = {
      id: step.id || newStepId(),
      type,
      enabled: step.enabled !== false,
      label: step.label || getStepTypeLabel(type, config),
    };
    if (type === "send_hotkey" && normalized.label === "发送快捷键") {
      normalized.label = getStepTypeLabel(type, config);
    }
    if (type === "focus_window") {
      normalized.window_keyword = step.window_keyword || cm.window_title_contains || STEP_DEFAULTS.focus_window.window_keyword;
    } else if (type === "send_hotkey") {
      normalized.hotkey = step.hotkey || step.send_hotkey || cm.send_hotkey || STEP_DEFAULTS.send_hotkey.hotkey;
      normalized.press_count = Math.max(
        1,
        Number(step.press_count ?? STEP_DEFAULTS.send_hotkey.press_count ?? 1)
      );
      normalized.press_interval_ms = normalized.press_count > 1
        ? Math.max(
            0,
            Number(step.press_interval_ms ?? STEP_DEFAULTS.send_hotkey.press_interval_ms ?? 0)
          )
        : 0;
    } else if (type === "restore_app") {
      normalized.window_keyword = String(
        step.window_keyword || STEP_DEFAULTS.restore_app.window_keyword || "PaperCutting"
      ).trim();
    } else if (type === "confirm_dialog") {
      normalized.prompt_text = String(
        step.prompt_text || step.message || STEP_DEFAULTS.confirm_dialog.prompt_text
      ).trim() || STEP_DEFAULTS.confirm_dialog.prompt_text;
    } else if (type === "condition_check") {
      normalized.status_key = String(step.status_key || STEP_DEFAULTS.condition_check.status_key).trim();
      if (!CONDITION_STATUS_OPTIONS[normalized.status_key]) {
        normalized.status_key = STEP_DEFAULTS.condition_check.status_key;
      }
      const options = CONDITION_STATUS_OPTIONS[normalized.status_key] || [];
      normalized.expected_value = String(step.expected_value || options[0]?.value || "home").trim();
      if (!options.some((item) => item.value === normalized.expected_value)) {
        normalized.expected_value = options[0]?.value || "home";
      }
      updateConditionStepLabel(normalized);
    } else if (type === "call_group") {
      normalized.group_name = String(step.group_name || "").trim();
      updateCallGroupStepLabel(normalized);
    } else if (type === "stop") {
      normalized.label = String(step.label || STEP_TYPE_META.stop.label).trim() || STEP_TYPE_META.stop.label;
    } else if (type === "else_branch" || type === "end_if") {
      // 分支标记，无额外字段
    } else {
      const legacyKey = LEGACY_TIMING_KEYS[type] || type;
      normalized.duration_ms = Number(step.duration_ms ?? timings[legacyKey] ?? STEP_DEFAULTS[type]?.duration_ms ?? 1000);
    }
    normalized.note = String(step.note ?? STEP_NOTE_DEFAULT).trim();
    normalized.delay_ms = getStepDelayMs(step);
    return normalized;
  }).filter(Boolean),
    config,
  );
}

function sendHotkeyIntervalMs(step) {
  const pressCount = Math.max(1, Number(step.press_count) || 1);
  const pressInterval = Math.max(0, Number(step.press_interval_ms) || 0);
  return Math.max(0, pressCount - 1) * pressInterval;
}

function showPressIntervalField(step) {
  return Math.max(1, Number(step?.press_count) || 1) > 1;
}

function normalizeHotkeyKey(key) {
  if (!key) return "";
  if (HOTKEY_KEY_ALIASES[key]) return HOTKEY_KEY_ALIASES[key];
  if (key.length === 1) return key.toLowerCase();
  if (/^F\d+$/i.test(key)) return key.toLowerCase();
  return String(key).trim().toLowerCase();
}

function eventToHotkeyString(event) {
  if (event.repeat) return null;
  if (["Control", "Alt", "Shift", "Meta"].includes(event.key)) return null;

  const parts = [];
  if (event.ctrlKey) parts.push("ctrl");
  if (event.altKey) parts.push("alt");
  if (event.shiftKey) parts.push("shift");
  if (event.metaKey) parts.push("windows");

  const keyName = normalizeHotkeyKey(event.key);
  if (!keyName) return null;
  parts.push(keyName);
  return parts.join("+");
}

function formatHotkeyLabel(hotkey) {
  return String(hotkey || "")
    .split("+")
    .map((part) => {
      const token = part.trim().toLowerCase();
      if (token === "ctrl") return "Ctrl";
      if (token === "alt") return "Alt";
      if (token === "shift") return "Shift";
      if (token === "windows") return "Win";
      if (token === "enter") return "Enter";
      if (token === "esc") return "Esc";
      if (token === "space") return "Space";
      if (token === "tab") return "Tab";
      if (/^f\d+$/.test(token)) return token.toUpperCase();
      if (token.length === 1) return token.toUpperCase();
      return part;
    })
    .join("+");
}

function renderHotkeyPickerField(step, index, canEdit) {
  const dis = canEdit ? "" : "disabled";
  const hotkey = String(step.hotkey || "ctrl+p").trim() || "ctrl+p";
  return `
    <label class="step-inline-field">
      <span class="step-field-label">按键</span>
      <button type="button" class="step-hotkey-btn" data-index="${index}" title="点击选择快捷键" ${dis}>${escAttr(formatHotkeyLabel(hotkey))}</button>
    </label>
  `;
}

function stepDurationMs(step) {
  if (!step.enabled) return 0;
  let actionMs = 0;
  if (step.type === "focus_window") {
    actionMs = 0;
  } else if (step.type === "restore_app") {
    actionMs = 0;
  } else if (step.type === "send_hotkey") {
    actionMs = sendHotkeyIntervalMs(step);
  } else if (step.type === "pulse_a" || step.type === "pulse_b") {
    actionMs = (Number(step.duration_ms) || 0) + 30;
  } else if (step.type === "confirm_dialog") {
    actionMs = 0;
  } else if (step.type === "condition_check") {
    actionMs = 0;
  } else if (step.type === "else_branch" || step.type === "end_if" || step.type === "call_group" || step.type === "stop") {
    actionMs = 0;
  } else {
    actionMs = Number(step.duration_ms) || 0;
  }
  return actionMs + getStepDelayMs(step);
}

function renderStepDelayBadge(step) {
  const ms = getStepDelayMs(step);
  return `<span class="step-delay-badge" title="步骤完成后的等待时间">延时 ${ms}ms</span>`;
}

function renderWindowPickerField(label, step, index, canEdit, placeholder = "输入或选择窗口关键字") {
  const dis = canEdit ? "" : "disabled";
  const value = escAttr(step.window_keyword ?? "");
  return `
    <label class="step-inline-field window-picker-field">
      <span class="step-field-label">${label}</span>
      <span class="window-picker">
        <input type="text" class="step-input-text window-picker-input" data-field="window_keyword" data-index="${index}" value="${value}" placeholder="${escAttr(placeholder)}" ${dis} />
        <button type="button" class="window-picker-btn" data-index="${index}" title="选择已打开窗口" ${dis} aria-expanded="false">▾</button>
      </span>
    </label>
  `;
}

function renderInlineField(label, field, step, index, canEdit, inputClass = "", title = "") {
  const dis = canEdit ? "" : "disabled";
  const value = escAttr(step[field] ?? "");
  const cls = inputClass ? `class="${inputClass}"` : "";
  const titleAttr = title ? `title="${escAttr(title)}"` : "";
  return `<label class="step-inline-field"><span class="step-field-label">${label}</span><input type="text" data-field="${field}" data-index="${index}" value="${value}" ${dis} ${cls} ${titleAttr} /></label>`;
}

function renderInlineNumber(label, field, step, index, canEdit, min = 0, stepVal = 100, title = "") {
  const dis = canEdit ? "" : "disabled";
  const titleAttr = title ? `title="${escAttr(title)}"` : "";
  return `<label class="step-inline-field"><span class="step-field-label">${label}</span><input type="number" class="step-input-num" min="${min}" step="${stepVal}" data-field="${field}" data-index="${index}" value="${step[field] ?? 0}" ${dis} ${titleAttr} /></label>`;
}

const STEP_NUM_INPUT_MIN_CH = 3.5;
const STEP_NUM_INPUT_MAX_CH = 12;

function fitStepNumberInputWidth(input) {
  if (!(input instanceof HTMLInputElement)) return;
  const digits = String(input.value ?? "0").trim().length || 1;
  const ch = Math.min(STEP_NUM_INPUT_MAX_CH, Math.max(STEP_NUM_INPUT_MIN_CH, digits + 0.75));
  input.style.width = `${ch}ch`;
}

function fitAllStepNumberInputs(root = els.stepEditor) {
  root.querySelectorAll(".step-input-num").forEach(fitStepNumberInputWidth);
}

function renderInlineSelect(label, field, step, index, canEdit, options) {
  const dis = canEdit ? "" : "disabled";
  const value = step[field] ?? options[0]?.value ?? "";
  const opts = options.map((item) => (
    `<option value="${escAttr(item.value)}"${item.value === value ? " selected" : ""}>${escAttr(item.label)}</option>`
  )).join("");
  return `<label class="step-inline-field"><span class="step-field-label">${label}</span><select class="step-input-select" data-field="${field}" data-index="${index}" ${dis}>${opts}</select></label>`;
}

function getActionGroupOptions() {
  const groups = state.actionGroups || [];
  if (!groups.length) {
    return [{ value: "", label: "（暂无动作组）" }];
  }
  return groups.map((group) => ({ value: group.name, label: group.name }));
}

function renderStepParams(step, index, canEdit) {
  let inner = "";
  if (step.type === "focus_window") {
    inner = renderWindowPickerField("窗口", step, index, canEdit);
  } else if (step.type === "restore_app") {
    inner = renderWindowPickerField("窗口", step, index, canEdit, "如 PaperCutting 或 Cutting Master");
  } else if (step.type === "send_hotkey") {
    const intervalField = showPressIntervalField(step)
      ? renderInlineNumber("间隔", "press_interval_ms", step, index, canEdit, 0, 50, "多次按键之间的等待时间")
      : "";
    inner = `
      ${renderHotkeyPickerField(step, index, canEdit)}
      ${renderInlineNumber("次数", "press_count", step, index, canEdit, 1, 1)}
      ${intervalField}
    `;
  } else if (step.type === "confirm_dialog") {
    inner = renderInlineField("提示", "prompt_text", step, index, canEdit, "step-input-text step-input-prompt");
  } else if (step.type === "condition_check") {
    const statusKey = step.status_key || "paper";
    const valueOptions = CONDITION_STATUS_OPTIONS[statusKey] || CONDITION_STATUS_OPTIONS.paper;
    inner = `
      ${renderInlineSelect("状态", "status_key", step, index, canEdit, CONDITION_STATUS_KEYS)}
      ${renderInlineSelect("等于", "expected_value", step, index, canEdit, valueOptions)}
    `;
  } else if (step.type === "else_branch") {
    inner = `<span class="branch-marker-hint">条件不成立时执行以下步骤</span>`;
  } else if (step.type === "end_if") {
    inner = `<span class="branch-marker-hint">条件分支结束</span>`;
  } else if (step.type === "call_group") {
    inner = renderInlineSelect("动作组", "group_name", step, index, canEdit, getActionGroupOptions());
  } else if (step.type === "stop") {
    inner = `<span class="branch-marker-hint">结束本轮，不执行后续步骤</span>`;
  } else if (step.type === "wait") {
    inner = renderInlineNumber("等待", "duration_ms", step, index, canEdit, 0, 100);
  } else {
    const isPulse = step.type === "pulse_a" || step.type === "pulse_b";
    const label = "时长";
    inner = renderInlineNumber(label, "duration_ms", step, index, canEdit, isPulse ? 50 : 0, isPulse ? 10 : 100);
  }
  const skipDelayBadge = new Set([
    "condition_check", "else_branch", "end_if", "call_group", "stop",
  ]);
  if (!skipDelayBadge.has(step.type)) {
    inner += renderStepDelayBadge(step);
  }
  return `<div class="step-settings-inner">${inner}</div>`;
}

function getStepTestAction(step) {
  if (step.type === "focus_window") return { kind: "focus_window" };
  if (step.type === "send_hotkey") return { kind: "send_hotkey" };
  if (step.type === "restore_app") return { kind: "restore_app" };
  const meta = STEP_TYPE_META[step.type];
  if (meta?.testStep) return { kind: "test", testStep: meta.testStep };
  return null;
}

function renderStepNameCell(step) {
  const note = String(step.note || "").trim();
  const noteHtml = note
    ? `<span class="step-note" title="${escAttr(note)}">${escAttr(note)}</span>`
    : "";

  return `
    <div class="step-name-stack">
      <span class="step-title" title="${escAttr(getStepDisplayLabel(step))}">${getStepDisplayLabel(step)}</span>
      ${noteHtml}
    </div>
  `;
}

function renderStepDragCell(index, canEdit, preview) {
  const dragDis = preview || !canEdit ? "disabled" : "";
  const dragAttr = preview || !canEdit ? 'draggable="false"' : 'draggable="true"';
  return `
    <td class="col-drag">
      <button type="button" class="step-drag" ${dragAttr} data-index="${index}" title="拖拽排序" ${dragDis}>⋮⋮</button>
    </td>
  `;
}

function renderStepActionsMenu(step, index, canEdit) {
  const testAction = getStepTestAction(step);
  const canTest = !!(canEdit && state.connected && testAction);
  const canDelete = !!(canEdit && state.workflowSteps.length > 1);
  const testDis = canTest ? "" : "disabled";
  const deleteDis = canDelete ? "" : "disabled";
  const noteDis = canEdit ? "" : "disabled";
  const noteLabel = String(step.note || "").trim() ? "编辑说明" : "添加说明";
  const delayLabel = getStepDelayMs(step) > 0 ? "编辑延时" : "添加延时";
  const testKindAttr = testAction ? `data-test-kind="${testAction.kind}"` : "";
  const testStepAttr = testAction?.kind === "test" ? `data-test-step="${testAction.testStep}"` : "";
  const moreDis = canEdit ? "" : "disabled";

  return `
    <div class="step-actions step-actions-menu">
      <button type="button" class="step-more-btn" data-index="${index}" title="更多操作" aria-expanded="false" aria-haspopup="menu" ${moreDis}>⋮</button>
      <div class="dropdown-menu step-row-menu hidden" role="menu" data-index="${index}">
        <button type="button" class="dropdown-item step-menu-test" data-index="${index}" ${testKindAttr} ${testStepAttr} ${testDis} role="menuitem">测试</button>
        <button type="button" class="dropdown-item step-menu-note" data-index="${index}" ${noteDis} role="menuitem">${noteLabel}</button>
        <button type="button" class="dropdown-item step-menu-delay" data-index="${index}" ${noteDis} role="menuitem">${delayLabel}</button>
        <button type="button" class="dropdown-item step-menu-delete" data-index="${index}" ${deleteDis} role="menuitem">删除</button>
      </div>
    </div>
  `;
}

function enabledSteps() {
  return state.workflowSteps.filter((step) => step.enabled);
}

function normalizeStepTableColumns(raw) {
  const result = { ...DEFAULT_STEP_TABLE_COLUMNS };
  if (!raw || typeof raw !== "object") return result;
  Object.keys(DEFAULT_STEP_TABLE_COLUMNS).forEach((key) => {
    const value = Number(raw[key]);
    if (Number.isFinite(value)) {
      result[key] = Math.max(
        STEP_TABLE_COLUMN_LIMITS.min,
        Math.min(STEP_TABLE_COLUMN_LIMITS.max, Math.round(value))
      );
    }
  });
  return result;
}

function applyStepTableColumnWidths(widths) {
  const cols = normalizeStepTableColumns(widths);
  els.colEnable.style.width = `${cols.enable}px`;
  els.colName.style.width = `${cols.name}px`;
  els.colSettings.style.width = `${cols.settings}px`;
  els.colActions.style.width = `${cols.actions}px`;
  if (state.config) {
    state.config.ui = { ...(state.config.ui || {}), step_table_columns: cols };
  }
  return cols;
}

function readStepTableColumnWidths() {
  return normalizeStepTableColumns(state.config?.ui?.step_table_columns);
}

function initStepColumnResize() {
  if (!els.stepTable) return;
  els.stepTable.querySelectorAll(".col-resizer").forEach((handle) => {
    handle.addEventListener("mousedown", (event) => {
      if (state.running) return;
      event.preventDefault();
      event.stopPropagation();
      const colKey = handle.dataset.col;
      if (!colKey || !(colKey in DEFAULT_STEP_TABLE_COLUMNS)) return;
      const widths = readStepTableColumnWidths();
      state.columnResize = {
        colKey,
        startX: event.clientX,
        startWidth: widths[colKey],
      };
      document.body.classList.add("is-col-resizing");
    });
  });
}

function onStepColumnResizeMove(event) {
  if (!state.columnResize) return;
  const { colKey, startX, startWidth } = state.columnResize;
  const delta = event.clientX - startX;
  const nextWidth = Math.max(
    STEP_TABLE_COLUMN_LIMITS.min,
    Math.min(STEP_TABLE_COLUMN_LIMITS.max, Math.round(startWidth + delta))
  );
  applyStepTableColumnWidths({
    ...readStepTableColumnWidths(),
    [colKey]: nextWidth,
  });
}

async function onStepColumnResizeEnd() {
  if (!state.columnResize) return;
  state.columnResize = null;
  document.body.classList.remove("is-col-resizing");
  try {
    await saveConfigSilently();
  } catch (err) {
    log("error", err.message);
  }
}

function renderStepRowHtml(step, index, canEdit, { preview = false } = {}) {
  const dis = preview || !canEdit ? "disabled" : "";

  return `
    ${renderStepDragCell(index, canEdit, preview)}
    <td class="col-enable">
      <label class="step-enable" title="是否执行">
        <input type="checkbox" data-field="enabled" data-index="${index}" ${step.enabled ? "checked" : ""} ${dis} />
      </label>
    </td>
    <td class="col-name">
      ${renderStepNameCell(step)}
    </td>
    <td class="col-settings step-settings-cell">${renderStepParams(step, index, canEdit && !preview)}</td>
    <td class="col-actions">
      ${renderStepActionsMenu(step, index, canEdit && !preview)}
    </td>
  `;
}

function renderStepEditor() {
  const canEdit = !state.running;
  const branchLayout = computeBranchLayout(state.workflowSteps);

  els.stepEditor.innerHTML = state.workflowSteps.map((step, index) => {
    let status = "pending";
    if (step.id === state.currentStepId) status = "active";
    else if (state.doneStepIds.has(step.id)) status = "done";
    if (!step.enabled) status = "disabled";

    const branch = branchLayout[index] || {};
    const depth = branch.depth ?? 0;
    const depthStyle = depth > 0 ? ` style="--branch-depth:${depth}"` : "";
    const branchClass = [
      branch.zone ? `branch-zone-${branch.zone}` : "",
      branch.role ? `branch-role-${branch.role}` : "",
      branch.invalid ? "branch-invalid" : "",
    ].filter(Boolean).join(" ");

    return `
      <tr class="step-row ${status} ${branchClass}" data-step-id="${step.id}" data-index="${index}"${depthStyle}>
        ${renderStepRowHtml(step, index, canEdit)}
      </tr>
    `;
  }).join("");

  if (state.landedStepId) {
    const landedId = state.landedStepId;
    state.landedStepId = null;
    requestAnimationFrame(() => {
      const row = els.stepEditor.querySelector(`.step-row[data-step-id="${landedId}"]`);
      if (!row) return;
      row.classList.add("step-row-landed");
      row.addEventListener("animationend", () => row.classList.remove("step-row-landed"), { once: true });
    });
  }

  updateToolbarState();
  applyStepProgressToDom();
  fitAllStepNumberInputs();
}

function applyStepProgressToDom() {
  els.stepEditor.querySelectorAll(".step-row").forEach((row) => {
    const stepId = row.dataset.stepId;
    if (state.doneStepIds.has(stepId)) {
      row.style.setProperty("--step-progress", "100%");
      return;
    }
    if (stepId === state.currentStepId && state.running) {
      row.style.setProperty("--step-progress", `${Math.min(100, Math.max(0, state.currentStepProgress * 100))}%`);
      return;
    }
    row.style.setProperty("--step-progress", "0%");
  });
}

function updateActiveStepProgress(ratio) {
  const next = Math.min(1, Math.max(0, Number(ratio) || 0));
  // 同一步骤内进度只增不减，避免动作阶段先到 100% 后延时阶段分母变大而回弹
  state.currentStepProgress = Math.max(state.currentStepProgress, next);
  applyStepProgressToDom();
}

function resolveStepProgress(payload) {
  if (payload.step_progress !== undefined && payload.step_progress !== null) {
    return Number(payload.step_progress);
  }
  const stepTotal = Number(payload.step_total_ms) || 0;
  const stepElapsed = Number(payload.step_elapsed_ms) || 0;
  if (stepTotal > 0) return stepElapsed / stepTotal;
  return state.currentStepProgress;
}

function handleStepRunUpdate(payload) {
  const stepChanged = payload.step_id && payload.step_id !== state.currentStepId;
  if (payload.step_id) {
    state.currentStepId = payload.step_id;
    markDoneBeforeStep(payload.step_id);
  }
  if (stepChanged) {
    state.currentStepProgress = 0;
    renderStepEditor();
  } else if (payload.step_progress !== undefined || payload.step_elapsed_ms !== undefined) {
    updateActiveStepProgress(resolveStepProgress(payload));
  }
  if (!state.waitingLoop) {
    updateProgress(
      payload.elapsed_ms ?? 0,
      payload.total_ms ?? state.totalMs,
      payload.phase_label || payload.message || "运行中",
      payload.progress
    );
  }
}

function getAnchorRows() {
  return [...els.stepEditor.querySelectorAll(".step-row:not(.step-row-preview):not(.is-drag-source)")];
}

function captureRowTops(rows) {
  return new Map(rows.map((row) => [row, row.getBoundingClientRect().top]));
}

function animateRowShifts(beforeTops, rows) {
  rows.forEach((row) => {
    const beforeTop = beforeTops.get(row);
    if (beforeTop === undefined) return;
    const delta = beforeTop - row.getBoundingClientRect().top;
    if (Math.abs(delta) < 0.5) return;
    row.style.transition = "none";
    row.style.transform = `translateY(${delta}px)`;
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        row.style.transition = "transform 0.28s cubic-bezier(0.22, 1, 0.36, 1)";
        row.style.transform = "";
      });
    });
    row.addEventListener("transitionend", (event) => {
      if (event.propertyName !== "transform") return;
      row.style.transition = "";
      row.style.transform = "";
    }, { once: true });
  });
}

function clearRowMotionStyles() {
  els.stepEditor.querySelectorAll(".step-row").forEach((row) => {
    row.style.transform = "";
    row.style.transition = "";
  });
}

function clearDragUi() {
  state.dragIndex = null;
  state.dropInsertIndex = null;
  if (state.dropPreviewEl) {
    state.dropPreviewEl.remove();
    state.dropPreviewEl = null;
  }
  els.stepEditor.querySelectorAll(".step-row").forEach((row) => {
    row.classList.remove("is-drag-source", "is-dragging", "drop-target");
  });
  clearRowMotionStyles();
}

function resolveInsertIndex(clientY) {
  const rows = getAnchorRows();
  if (!rows.length) return 0;
  for (let i = 0; i < rows.length; i += 1) {
    const rect = rows[i].getBoundingClientRect();
    if (clientY < rect.top + rect.height / 2) return i;
  }
  return rows.length;
}

function ensureDropPreview() {
  const step = state.workflowSteps[state.dragIndex];
  if (!step) return null;

  if (!state.dropPreviewEl) {
    state.dropPreviewEl = document.createElement("tr");
  }

  const canEdit = !state.running;
  state.dropPreviewEl.className = "step-row step-row-preview pending";
  state.dropPreviewEl.dataset.preview = "true";
  state.dropPreviewEl.innerHTML = renderStepRowHtml(step, state.dragIndex, canEdit, { preview: true });
  return state.dropPreviewEl;
}

function showDropAt(insertIndex) {
  const preview = ensureDropPreview();
  if (!preview) return;

  if (state.dropInsertIndex === insertIndex) return;

  const anchorRows = getAnchorRows();
  const beforeTops = captureRowTops(anchorRows);

  state.dropInsertIndex = insertIndex;

  if (insertIndex >= anchorRows.length) {
    els.stepEditor.appendChild(preview);
  } else {
    els.stepEditor.insertBefore(preview, anchorRows[insertIndex]);
  }

  animateRowShifts(beforeTops, getAnchorRows());

  preview.classList.remove("step-row-preview-enter");
  void preview.offsetWidth;
  preview.classList.add("step-row-preview-enter");
}

function reorderSteps(fromIndex, insertIndex) {
  // insertIndex 基于「去掉拖拽行后」的锚点行列表，而非 workflowSteps 下标
  if (insertIndex === fromIndex) return null;

  const fullInsert = insertIndex >= fromIndex ? insertIndex + 1 : insertIndex;
  const target = fromIndex < fullInsert ? fullInsert - 1 : fullInsert;
  if (target === fromIndex) return null;

  const [moved] = state.workflowSteps.splice(fromIndex, 1);
  state.workflowSteps.splice(target, 0, moved);
  return moved;
}

const DRAG_GHOST = new Image();
DRAG_GHOST.src = "data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7";

function initStepDragDrop() {
  const tableWrap = els.stepEditor.closest(".step-table-wrap");

  els.stepEditor.addEventListener("dragstart", (event) => {
    const handle = event.target.closest(".step-drag");
    if (!handle || state.running) return;
    const row = handle.closest(".step-row");
    state.dragIndex = Number(handle.dataset.index);
    state.dropInsertIndex = null;
    event.dataTransfer.effectAllowed = "move";
    event.dataTransfer.setData("text/plain", String(state.dragIndex));
    event.dataTransfer.setDragImage(DRAG_GHOST, 0, 0);
    // 必须在 drag 建立后再隐藏源行，否则浏览器会立刻取消拖拽
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        if (state.dragIndex === null) return;
        row?.classList.add("is-drag-source");
      });
    });
  });

  const onDragOver = (event) => {
    if (state.dragIndex === null || state.running) return;
    event.preventDefault();
    event.dataTransfer.dropEffect = "move";
    showDropAt(resolveInsertIndex(event.clientY));
  };

  els.stepEditor.addEventListener("dragover", onDragOver);
  tableWrap?.addEventListener("dragover", onDragOver);

  const onDrop = (event) => {
    event.preventDefault();
    if (state.dragIndex === null || state.running) return;
    const fromIndex = state.dragIndex;
    const insertIndex = state.dropInsertIndex ?? resolveInsertIndex(event.clientY);
    const moved = reorderSteps(fromIndex, insertIndex);
    clearDragUi();
    if (moved) {
      state.landedStepId = moved.id;
    }
    recalcTotalMs({ rerender: false });
    updateControls();
  };

  els.stepEditor.addEventListener("drop", onDrop);
  tableWrap?.addEventListener("drop", onDrop);

  els.stepEditor.addEventListener("dragend", () => {
    if (state.dragIndex !== null) clearDragUi();
  });
}

function updateToolbarState() {
  const canEdit = !state.running;
  els.addStepMenuBtn.disabled = !canEdit;
  els.loopMenuBtn.disabled = !canEdit;
  els.actionFileMenuBtn.disabled = !canEdit;
  els.addStepMenu?.querySelectorAll(".dropdown-item").forEach((btn) => {
    btn.disabled = !canEdit;
  });
  els.actionFileMenu?.querySelectorAll(".dropdown-item").forEach((btn) => {
    btn.disabled = !canEdit;
  });
}

function resetFloatingMenuPosition(menu) {
  if (!menu) return;
  menu.classList.remove("is-floating");
  menu.style.top = "";
  menu.style.left = "";
  menu.style.right = "";
  menu.style.bottom = "";
  menu.style.visibility = "";
}

function positionFloatingMenu(btnEl, menuEl, { align = "left" } = {}) {
  const margin = 8;
  const gap = 4;

  menuEl.classList.add("is-floating");
  menuEl.style.visibility = "hidden";
  menuEl.style.top = "0px";
  menuEl.style.left = "0px";

  const menuRect = menuEl.getBoundingClientRect();
  const btnRect = btnEl.getBoundingClientRect();

  let top = btnRect.bottom + gap;
  let left = align === "right" ? btnRect.right - menuRect.width : btnRect.left;

  if (left < margin) left = margin;
  if (left + menuRect.width > window.innerWidth - margin) {
    left = Math.max(margin, window.innerWidth - menuRect.width - margin);
  }

  if (top + menuRect.height > window.innerHeight - margin) {
    top = btnRect.top - menuRect.height - gap;
  }
  if (top < margin) top = margin;

  menuEl.style.top = `${Math.round(top)}px`;
  menuEl.style.left = `${Math.round(left)}px`;
  menuEl.style.visibility = "";
}

function positionStepRowMenu(btnEl, menuEl) {
  positionFloatingMenu(btnEl, menuEl, { align: "right" });
}

function ensureStepRowMenuDismissHandlers() {
  if (state.stepRowMenuScrollBound) return;
  state.stepRowMenuScrollBound = true;
  const wrap = els.stepEditor?.closest(".step-table-wrap");
  wrap?.addEventListener("scroll", closeAllMenus, { passive: true });
  window.addEventListener("resize", closeAllMenus);
}

function closeAllStepRowMenus() {
  els.stepEditor.querySelectorAll(".step-row-menu").forEach((menu) => {
    menu.classList.add("hidden");
    resetFloatingMenuPosition(menu);
  });
  els.stepEditor.querySelectorAll(".step-more-btn").forEach((btn) => {
    btn.setAttribute("aria-expanded", "false");
  });
}

function closeAllMenus() {
  [els.addStepMenu, els.loopMenu, els.actionFileMenu].forEach((menu) => {
    menu?.classList.add("hidden");
    resetFloatingMenuPosition(menu);
  });
  els.addStepMenuBtn?.setAttribute("aria-expanded", "false");
  els.loopMenuBtn?.setAttribute("aria-expanded", "false");
  els.actionFileMenuBtn?.setAttribute("aria-expanded", "false");
  closeAllStepRowMenus();
  closeWindowPickerMenu();
}

function closeWindowPickerMenu() {
  els.windowPickerMenu?.classList.add("hidden");
  els.stepEditor?.querySelectorAll(".window-picker-btn").forEach((btn) => {
    btn.setAttribute("aria-expanded", "false");
  });
  state.windowPickerIndex = null;
  if (els.windowPickerSearch) {
    els.windowPickerSearch.value = "";
  }
}

async function fetchOpenWindows(force = false) {
  const now = Date.now();
  if (!force && state.openWindowsCache.length && now - state.openWindowsFetchedAt < 1500) {
    return state.openWindowsCache;
  }
  const res = await sendCommand({ cmd: "list_open_windows", max_count: 120 });
  state.openWindowsCache = Array.isArray(res.windows) ? res.windows : [];
  state.openWindowsFetchedAt = now;
  return state.openWindowsCache;
}

function renderWindowPickerList(filter = "") {
  if (!els.windowPickerList) return;
  const query = String(filter || "").trim().toLowerCase();
  const windows = state.openWindowsCache.filter((title) => !query || title.toLowerCase().includes(query));
  if (!windows.length) {
    els.windowPickerList.innerHTML = `<div class="window-picker-empty">${query ? "无匹配窗口" : "未找到可见窗口"}</div>`;
    return;
  }
  els.windowPickerList.innerHTML = windows
    .map(
      (title) =>
        `<button type="button" class="window-picker-item dropdown-item" data-title="${escAttr(title)}" role="option">${escAttr(title)}</button>`
    )
    .join("");
}

function positionWindowPickerMenu(btnEl) {
  if (!els.windowPickerMenu || !btnEl) return;
  const margin = 8;
  const gap = 4;
  els.windowPickerMenu.classList.add("is-floating");
  els.windowPickerMenu.style.visibility = "hidden";
  els.windowPickerMenu.style.top = "0px";
  els.windowPickerMenu.style.left = "0px";

  const menuRect = els.windowPickerMenu.getBoundingClientRect();
  const btnRect = btnEl.getBoundingClientRect();
  let top = btnRect.bottom + gap;
  let left = btnRect.left;
  if (left + menuRect.width > window.innerWidth - margin) {
    left = Math.max(margin, window.innerWidth - menuRect.width - margin);
  }
  if (top + menuRect.height > window.innerHeight - margin) {
    top = btnRect.top - menuRect.height - gap;
  }
  if (top < margin) top = margin;
  els.windowPickerMenu.style.top = `${Math.round(top)}px`;
  els.windowPickerMenu.style.left = `${Math.round(left)}px`;
  els.windowPickerMenu.style.visibility = "";
}

async function openWindowPickerMenu(index, btnEl) {
  if (state.running || !btnEl || !els.windowPickerMenu) return;
  const willOpen = els.windowPickerMenu.classList.contains("hidden") || state.windowPickerIndex !== index;
  closeAllMenus();
  if (!willOpen) return;

  state.windowPickerIndex = index;
  btnEl.setAttribute("aria-expanded", "true");
  els.windowPickerMenu.classList.remove("hidden");
  positionWindowPickerMenu(btnEl);

  try {
    await fetchOpenWindows(true);
  } catch (err) {
    log("error", err.message);
    state.openWindowsCache = [];
  }
  renderWindowPickerList(els.windowPickerSearch?.value || "");
  requestAnimationFrame(() => {
    els.windowPickerSearch?.focus();
    els.windowPickerSearch?.select();
  });
}

function applyWindowPickerSelection(title) {
  const index = state.windowPickerIndex;
  if (index == null || !state.workflowSteps[index]) return;
  state.workflowSteps[index].window_keyword = String(title || "").trim();
  closeWindowPickerMenu();
  updateControls();
}

function toggleStepRowMenu(index, btnEl) {
  const menu = els.stepEditor.querySelector(`.step-row-menu[data-index="${index}"]`);
  if (!menu || !btnEl) return;
  const willOpen = menu.classList.contains("hidden");
  closeAllMenus();
  if (willOpen) {
    menu.classList.remove("hidden");
    positionStepRowMenu(btnEl, menu);
    btnEl.setAttribute("aria-expanded", "true");
    ensureStepRowMenuDismissHandlers();
  }
}

async function runStepTest(index, testKind, testStep) {
  const step = state.workflowSteps[index];
  if (!step || !testKind) return;
  try {
    if (testKind === "focus_window") {
      await testFocusWindowStep(step);
    } else if (testKind === "send_hotkey") {
      await testHotkeyStep(step);
    } else if (testKind === "restore_app") {
      await testRestoreAppStep(step, index);
    } else if (testKind === "test" && testStep) {
      await saveConfigSilently();
      await sendCommand({
        cmd: "test_step",
        step: testStep,
        workflow_step: readWorkflowStepsFromState()[index],
      });
    }
  } catch (err) {
    log("error", err.message);
  }
}

function toggleMenu(menuEl, btnEl, options = {}) {
  const willOpen = menuEl.classList.contains("hidden");
  closeAllMenus();
  if (willOpen) {
    menuEl.classList.remove("hidden");
    positionFloatingMenu(btnEl, menuEl, options);
    btnEl.setAttribute("aria-expanded", "true");
  }
}

function initAddStepMenu() {
  els.addStepMenu.innerHTML = INSERT_STEP_TYPES.map(
    (type) => `<button type="button" class="dropdown-item" data-step-type="${type}" role="menuitem">${getStepTypeLabel(type)}</button>`
  ).join("");
}

function refreshRelayLabelUi(config = state.config) {
  const names = getRelayLabels(config);
  if (els.relayK3Name) els.relayK3Name.value = names.relay_k3;
  if (els.relayK4Name) els.relayK4Name.value = names.relay_k4;
}

function applyRelayLabelsFromForm() {
  if (!state.config) state.config = {};
  const labels = {
    relay_k3: String(els.relayK3Name?.value || DEFAULT_RELAY_LABELS.relay_k3).trim() || DEFAULT_RELAY_LABELS.relay_k3,
    relay_k4: String(els.relayK4Name?.value || DEFAULT_RELAY_LABELS.relay_k4).trim() || DEFAULT_RELAY_LABELS.relay_k4,
  };
  state.config.relay_labels = labels;
  state.config.simulated_buttons = {
    button_b: labels.relay_k3,
    button_a: labels.relay_k4,
  };
  state.workflowSteps = syncPulseStepLabels(state.workflowSteps, state.config);
  initAddStepMenu();
  updateControls();
}

function addStepOfType(type) {
  if (state.running || !type) return;
  if (type === "condition_check") {
    state.workflowSteps.push(createStep("condition_check", state.config));
    state.workflowSteps.push(createStep("else_branch", state.config));
    state.workflowSteps.push(createStep("end_if", state.config));
  } else {
    state.workflowSteps.push(createStep(type, state.config));
  }
  recalcTotalMs();
  updateControls();
  closeAllMenus();
}

function openSaveGroupModal() {
  closeAllMenus();
  els.groupNameInput.value = els.groupNameInput.value.trim() || "";
  els.saveGroupModal.classList.remove("hidden");
  els.saveGroupModal.setAttribute("aria-hidden", "false");
  els.groupNameInput.focus();
}

function closeSaveGroupModal() {
  els.saveGroupModal.classList.add("hidden");
  els.saveGroupModal.setAttribute("aria-hidden", "true");
}

function openManageGroupsModal() {
  closeAllMenus();
  refreshActionGroups().catch((err) => log("error", err.message));
  els.manageGroupsModal.classList.remove("hidden");
  els.manageGroupsModal.setAttribute("aria-hidden", "false");
}

function closeManageGroupsModal() {
  els.manageGroupsModal.classList.add("hidden");
  els.manageGroupsModal.setAttribute("aria-hidden", "true");
}

function renderManageGroupsList(groups = state.actionGroups) {
  state.actionGroups = groups;
  if (!groups.length) {
    els.manageGroupsList.innerHTML = '<div class="manage-groups-empty">暂无已保存的动作组</div>';
    return;
  }
  els.manageGroupsList.innerHTML = groups.map((group) => `
    <div class="manage-group-row" data-group-name="${escAttr(group.name)}">
      <div class="manage-group-meta">
        <div class="manage-group-name">${escAttr(group.name)}</div>
        <div class="manage-group-sub">${group.step_count} 步</div>
      </div>
      <div class="manage-group-actions">
        <button type="button" class="btn btn-primary btn-xs group-open-btn">打开</button>
        <button type="button" class="btn btn-secondary btn-xs group-export-btn">导出</button>
        <button type="button" class="btn btn-ghost btn-xs group-delete-btn">删除</button>
      </div>
    </div>
  `).join("");
}

async function refreshActionGroups() {
  const response = await sendCommand({ cmd: "list_action_groups" });
  if (response.event === "action_groups") {
    renderManageGroupsList(response.groups || []);
    if (!state.running) {
      renderStepEditor();
    }
  }
}

async function saveGroupToLibrary(name) {
  const trimmed = String(name || "").trim();
  if (!trimmed) {
    log("warn", "请输入动作组名称");
    return;
  }
  await saveConfigSilently();
  const response = await sendCommand({
    cmd: "save_action_group",
    name: trimmed,
    workflow_steps: readWorkflowStepsFromState(),
  });
  if (response.event === "error") {
    throw new Error(response.message || "保存动作组失败");
  }
  els.groupNameInput.value = trimmed;
  closeSaveGroupModal();
  await refreshActionGroups();
  log("info", `动作组「${trimmed}」已保存`);
}

async function exportCurrentGroup() {
  closeAllMenus();
  const name = els.groupNameInput.value.trim() || "动作组";
  const filePath = await window.cutppaper.pickExportActionGroupFile(name);
  if (!filePath) return;
  await saveConfigSilently();
  const response = await sendCommand({
    cmd: "export_action_group",
    name,
    file_path: filePath,
    workflow_steps: readWorkflowStepsFromState(),
  });
  if (response.event === "error") {
    throw new Error(response.message || "导出动作组失败");
  }
}

async function importGroupFromFile() {
  closeAllMenus();
  const filePath = await window.cutppaper.pickImportActionGroupFile();
  if (!filePath) return;
  const response = await sendCommand({ cmd: "import_action_group", file_path: filePath });
  if (response.event === "error") {
    throw new Error(response.message || "导入动作组失败");
  }
}

async function openGroupByName(name) {
  const response = await sendCommand({ cmd: "load_action_group", name });
  if (response.event === "error") {
    throw new Error(response.message || "打开动作组失败");
  }
  els.groupNameInput.value = name;
  closeManageGroupsModal();
}

async function exportGroupByName(name) {
  const filePath = await window.cutppaper.pickExportActionGroupFile(name);
  if (!filePath) return;
  const response = await sendCommand({
    cmd: "export_saved_action_group",
    name,
    file_path: filePath,
  });
  if (response.event === "error") {
    throw new Error(response.message || "导出动作组失败");
  }
}

async function deleteGroupByName(name) {
  if (!window.confirm(`确定删除动作组「${name}」？此操作不可恢复。`)) return;
  const response = await sendCommand({ cmd: "delete_action_group", name });
  if (response.event === "error") {
    throw new Error(response.message || "删除动作组失败");
  }
}

function updateLoopMenuBtn() {
  const enabled = els.autoLoop.checked;
  els.loopMenuBtn.classList.toggle("is-active", enabled);
  els.loopMenuBtn.textContent = enabled ? "循环 ✓ ▾" : "循环 ▾";
}

function getStartHotkey(config = state.config) {
  return String(config?.app?.start_hotkey || "").trim().toLowerCase();
}

function refreshStartHotkeyUi(hotkey = getStartHotkey()) {
  const value = String(hotkey || "").trim().toLowerCase();
  if (els.startHotkeyBtn) {
    els.startHotkeyBtn.textContent = value ? formatHotkeyLabel(value) : "未设置";
    els.startHotkeyBtn.disabled = state.running;
  }
  if (els.startHotkeyClearBtn) {
    els.startHotkeyClearBtn.disabled = state.running || !value;
  }
}

async function applyStartHotkeyRegistration(hotkey) {
  if (!window.cutppaper?.setStartHotkey) return;
  const value = String(hotkey || "").trim().toLowerCase();
  const result = await window.cutppaper.setStartHotkey(value);
  if (value && result?.ok === false) {
    log("warn", `执行动作快捷键「${formatHotkeyLabel(value)}」注册失败，可能与其他程序冲突`);
  }
}

function updateStartBtnLabel() {
  const labelEl = els.startBtn.querySelector(".start-btn-label") || els.startBtn;
  if (state.running) {
    els.startBtn.classList.remove("has-loop-check");
    labelEl.textContent = state.waitingLoop ? "等待下一轮…" : "运行中…";
    els.startBtn.title = "";
    return;
  }
  els.startBtn.classList.toggle("has-loop-check", els.autoLoop.checked);
  const hotkey = getStartHotkey();
  const hotkeyHint = hotkey ? ` (${formatHotkeyLabel(hotkey)})` : "";
  labelEl.textContent = "执行动作";
  els.startBtn.title = `执行动作${hotkeyHint}`;
  updateLoopMenuBtn();
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
  refreshStatusPanel();
}

function parseRodPosition(raw) {
  const upper = String(raw || "").toUpperCase();
  if (upper.includes("ROD:HOME")) return "home";
  if (upper.includes("ROD:AWAY")) return "away";
  return null;
}

function buildStatusSnapshot() {
  return {
    connected: state.connected,
    simulation: state.simulation,
    connectedPort: state.connectedPort,
    baudrate: Number(els.baudrate?.value) || 115200,
    timeoutMs: Number(els.timeoutMs?.value) || 2000,
    rodPosition: state.rodPosition,
    motorState: state.motorState,
    pythonReady: state.pythonReady,
    pythonExit: state.pythonExit,
    running: state.running,
    waitingLoop: state.waitingLoop,
    loopIndex: state.loopIndex,
    phaseLabel: state.phaseLabel,
    progressElapsed: state.progressElapsed,
    progressTotal: state.progressTotal,
    progressRatio: state.progressRatio,
    cycleHint: els.cycleHint?.textContent || "",
  };
}

function updateConnIndicator() {
  if (!els.connBar) return;
  els.connBar.classList.toggle("is-connected", state.connected);
  els.connBar.classList.toggle("is-disconnected", !state.connected);
  els.connBar.title = state.connected
    ? (state.simulation ? "USB · 模拟已连接" : `USB · ${state.connectedPort || "已连接"}`)
    : "USB · 未连接 — 点击连接";
}

function refreshStatusPanel() {
  StatusPanel.render(buildStatusSnapshot());
  updateConnIndicator();
}

async function refreshDeviceStatus() {
  if (!state.connected) return;
  try {
    await sendCommand({ cmd: "device_status" });
  } catch (err) {
    log("warn", err.message || "刷新设备状态失败");
  }
}

function getConnectionDetailLabel() {
  if (!state.connected) return "未连接";
  if (state.simulation) {
    return "模拟硬件 · 已连接";
  }
  const port = state.connectedPort || els.portSelect.value || "串口";
  const baud = els.baudrate.value || 115200;
  const timeout = els.timeoutMs.value || 2000;
  return `${port} · ${baud} · 超时 ${timeout}ms`;
}

function updateConnectionModal() {
  const canChange = !state.running;
  if (state.connected) {
    els.connModalStatus.textContent = getConnectionDetailLabel();
    els.connModalStatus.className = "conn-modal-status is-connected";
    els.modalConnectBtn.classList.add("hidden");
    els.modalDisconnectBtn.classList.remove("hidden");
  } else {
    els.connModalStatus.textContent = "当前未连接，配置完成后点击下方连接";
    els.connModalStatus.className = "conn-modal-status";
    els.modalConnectBtn.classList.remove("hidden");
    els.modalDisconnectBtn.classList.add("hidden");
  }
  els.modalConnectBtn.disabled = !canChange;
  els.modalDisconnectBtn.disabled = !canChange;
  els.simulationMode.disabled = state.running || state.connected;
  els.portSelect.disabled = state.running || state.connected;
  els.baudrate.disabled = state.running || state.connected;
  els.timeoutMs.disabled = state.running || state.connected;
  els.refreshPortsBtn.disabled = state.running || state.connected;
}

function updateControls() {
  const canRun = state.connected && !state.running && enabledSteps().length > 0;
  els.startBtn.disabled = !canRun;
  els.simulationMode.disabled = state.running || state.connected;
  els.autoLoop.disabled = state.running;
  els.loopIntervalMs.disabled = state.running;
  els.loopMenuBtn.disabled = state.running;
  els.serialPanel.classList.toggle("disabled", state.simulation);
  els.connBar.disabled = state.running;
  updateConnectionModal();
  refreshStatusPanel();
  updateSettingsModal();
  updateStartBtnLabel();
  renderStepEditor();
}

function recalcTotalMs({ rerender = true } = {}) {
  state.totalMs = enabledSteps().reduce(
    (sum, step) => sum + stepDurationMs(step),
    0
  );
  updateCycleHint();
  if (rerender) {
    renderStepEditor();
  }
}

function syncRunTotalMs(totalMs) {
  if (Number.isFinite(Number(totalMs)) && Number(totalMs) >= 0) {
    state.totalMs = Math.round(Number(totalMs));
    updateCycleHint();
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
  return syncPulseStepLabels(state.workflowSteps, state.config).map((step) => {
    const copy = {
      id: step.id,
      type: step.type,
      enabled: step.enabled,
      label: step.label,
      note: String(step.note || "").trim(),
      delay_ms: getStepDelayMs(step),
    };
    if (step.type === "focus_window") {
      copy.window_keyword = String(step.window_keyword || "").trim();
    } else if (step.type === "restore_app") {
      copy.window_keyword = String(step.window_keyword || "PaperCutting").trim();
    } else if (step.type === "send_hotkey") {
      copy.hotkey = String(step.hotkey || "ctrl+p").trim();
      copy.press_count = Math.max(1, Number(step.press_count) || 1);
      copy.press_interval_ms = Math.max(0, Number(step.press_interval_ms) || 0);
    } else if (step.type === "confirm_dialog") {
      copy.prompt_text = String(step.prompt_text || "请确认后继续").trim() || "请确认后继续";
    } else if (step.type === "condition_check") {
      copy.status_key = String(step.status_key || "paper").trim();
      copy.expected_value = String(step.expected_value || "home").trim();
    } else if (step.type === "call_group") {
      copy.group_name = String(step.group_name || "").trim();
    } else if (step.type === "else_branch" || step.type === "end_if" || step.type === "stop") {
      // 无额外字段
    } else {
      copy.duration_ms = Number(step.duration_ms) || 0;
    }
    return copy;
  });
}

function applyConfigToForm(config) {
  state.config = config;
  state.simulation = config.app?.simulation_mode === true;
  state.workflowSteps = normalizeWorkflowSteps(config.workflow_steps, config);
  refreshRelayLabelUi(config);
  els.simulationMode.checked = state.simulation;
  if (els.autoConnectMode) {
    els.autoConnectMode.checked = config.app?.auto_connect !== false;
  }
  els.autoLoop.checked = config.app?.auto_loop === true;
  els.loopIntervalMs.value = config.app?.loop_interval_ms ?? 3000;
  updateLoopMenuBtn();
  els.portSelect.value = config.serial.port;
  els.baudrate.value = config.serial.baudrate ?? 115200;
  els.timeoutMs.value = config.serial.timeout_ms ?? 2000;
  applyStepTableColumnWidths(config.ui?.step_table_columns);
  refreshStartHotkeyUi(getStartHotkey(config));
  void applyStartHotkeyRegistration(getStartHotkey(config));
  recalcTotalMs();
  initAddStepMenu();
  updateControls();
}

function readConfigFromForm() {
  const cuttingMaster = legacyCuttingMasterFromSteps();
  const relayLabels = getRelayLabels({
    relay_labels: {
      relay_k3: els.relayK3Name?.value,
      relay_k4: els.relayK4Name?.value,
    },
  });
  return {
    serial: {
      port: els.portSelect.value,
      baudrate: Number(els.baudrate.value) || 115200,
      timeout_ms: Number(els.timeoutMs.value) || 2000,
    },
    timings_ms: state.config?.timings_ms || {
      retract: 0,
      extend: 0,
      relay_pulse: 200,
      before_send_keys: 0,
      after_focus_ms: 0,
      after_hotkey_ms: 0,
    },
    cutting_master: cuttingMaster,
    relay_labels: relayLabels,
    simulated_buttons: {
      button_b: relayLabels.relay_k3,
      button_a: relayLabels.relay_k4,
    },
    app: {
      simulation_mode: els.simulationMode.checked,
      auto_loop: els.autoLoop.checked,
      loop_interval_ms: Number(els.loopIntervalMs.value) || 0,
      start_hotkey: getStartHotkey(),
      auto_connect: els.autoConnectMode?.checked !== false,
    },
    ui: {
      step_table_columns: readStepTableColumnWidths(),
    },
    workflow_steps: readWorkflowStepsFromState(),
  };
}

function updateProgress(elapsedMs, totalMs, label, progressRatio) {
  state.phaseLabel = label || "空闲";
  state.progressElapsed = elapsedMs;
  state.progressTotal = totalMs;
  state.progressRatio = progressRatio;
  refreshStatusPanel();
}

function markDoneBeforeStep(stepId) {
  const done = new Set();
  for (const step of enabledSteps()) {
    if (step.id === stepId) break;
    done.add(step.id);
  }
  state.doneStepIds = done;
}

function clearStepRunVisuals() {
  state.currentStepId = null;
  state.currentStepProgress = 0;
  state.doneStepIds = new Set();
}

function resetRunVisuals() {
  state.currentStepId = enabledSteps()[0]?.id || null;
  state.currentStepProgress = 0;
  state.doneStepIds = new Set();
}

let promptInFlight = null;
let confirmPromptResolver = null;
let confirmPromptKeyHandler = null;

function showCustomConfirmDialog({ title, message, detail, stepLabel, okLabel, cancelLabel }) {
  return new Promise((resolve) => {
    if (confirmPromptResolver) {
      closeCustomConfirmDialog("cancel");
    }
    confirmPromptResolver = resolve;

    els.confirmPromptStep.textContent = stepLabel || title || "弹窗确认";
    els.confirmPromptMessage.textContent = message || "请确认后继续";
    if (els.confirmPromptOkBtn) {
      els.confirmPromptOkBtn.textContent = okLabel || "确认继续";
    }
    if (els.confirmPromptCancelBtn) {
      els.confirmPromptCancelBtn.textContent = cancelLabel || "取消";
    }
    if (detail) {
      els.confirmPromptDetail.textContent = detail;
      els.confirmPromptDetail.classList.remove("hidden");
    } else {
      els.confirmPromptDetail.textContent = "";
      els.confirmPromptDetail.classList.add("hidden");
    }

    confirmPromptKeyHandler = (event) => {
      if (els.confirmPromptModal.classList.contains("hidden")) return;
      if (event.key === "Escape") {
        event.preventDefault();
        event.stopImmediatePropagation();
        closeCustomConfirmDialog("cancel");
      } else if (event.key === "Enter") {
        event.preventDefault();
        event.stopImmediatePropagation();
        closeCustomConfirmDialog("confirm");
      }
    };
    document.addEventListener("keydown", confirmPromptKeyHandler, true);

    els.confirmPromptModal.classList.remove("hidden");
    els.confirmPromptModal.setAttribute("aria-hidden", "false");
    requestAnimationFrame(() => {
      els.confirmPromptPanel?.focus();
      els.confirmPromptOkBtn?.focus();
    });
  });
}

function closeCustomConfirmDialog(action) {
  if (confirmPromptKeyHandler) {
    document.removeEventListener("keydown", confirmPromptKeyHandler, true);
    confirmPromptKeyHandler = null;
  }
  els.confirmPromptModal.classList.add("hidden");
  els.confirmPromptModal.setAttribute("aria-hidden", "true");
  if (els.confirmPromptOkBtn) els.confirmPromptOkBtn.textContent = "确认继续";
  if (els.confirmPromptCancelBtn) els.confirmPromptCancelBtn.textContent = "取消";
  if (confirmPromptResolver) {
    confirmPromptResolver(action);
    confirmPromptResolver = null;
  }
}

function initConfirmPromptModal() {
  els.confirmPromptOkBtn.addEventListener("click", () => closeCustomConfirmDialog("confirm"));
  els.confirmPromptCancelBtn.addEventListener("click", () => closeCustomConfirmDialog("cancel"));
  els.confirmPromptBackdrop.addEventListener("click", () => closeCustomConfirmDialog("cancel"));
}

function openStepNoteModal(index) {
  if (state.running || !els.stepNoteModal) return;
  const step = state.workflowSteps[index];
  if (!step) return;
  state.stepNoteEditIndex = index;
  els.stepNoteInput.value = String(step.note || "");
  els.stepNoteModal.classList.remove("hidden");
  els.stepNoteModal.setAttribute("aria-hidden", "false");
  requestAnimationFrame(() => {
    els.stepNoteInput.focus();
    els.stepNoteInput.setSelectionRange(els.stepNoteInput.value.length, els.stepNoteInput.value.length);
  });
}

function closeStepNoteModal() {
  if (!els.stepNoteModal) return;
  state.stepNoteEditIndex = null;
  els.stepNoteModal.classList.add("hidden");
  els.stepNoteModal.setAttribute("aria-hidden", "true");
}

async function saveStepNote() {
  const index = state.stepNoteEditIndex;
  if (index == null || !state.workflowSteps[index]) return;
  state.workflowSteps[index].note = String(els.stepNoteInput.value || "").trim();
  closeStepNoteModal();
  recalcTotalMs({ rerender: false });
  updateControls();
  try {
    await saveConfigSilently();
  } catch (err) {
    log("error", err.message);
  }
}

function initStepNoteModal() {
  if (!els.stepNoteModal) return;
  els.stepNoteSaveBtn.addEventListener("click", () => {
    saveStepNote();
  });
  els.stepNoteClearBtn.addEventListener("click", () => {
    els.stepNoteInput.value = "";
    els.stepNoteInput.focus();
  });
  els.stepNoteCloseBtn.addEventListener("click", closeStepNoteModal);
  els.stepNoteBackdrop.addEventListener("click", closeStepNoteModal);
  els.stepNoteModal.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      event.preventDefault();
      closeStepNoteModal();
    }
  });
}

function openStepDelayModal(index) {
  if (state.running || !els.stepDelayModal) return;
  const step = state.workflowSteps[index];
  if (!step) return;
  state.stepDelayEditIndex = index;
  els.stepDelayInput.value = String(getStepDelayMs(step));
  els.stepDelayModal.classList.remove("hidden");
  els.stepDelayModal.setAttribute("aria-hidden", "false");
  requestAnimationFrame(() => {
    els.stepDelayInput.focus();
    els.stepDelayInput.select();
  });
}

function closeStepDelayModal() {
  if (!els.stepDelayModal) return;
  state.stepDelayEditIndex = null;
  els.stepDelayModal.classList.add("hidden");
  els.stepDelayModal.setAttribute("aria-hidden", "true");
}

async function saveStepDelay() {
  const index = state.stepDelayEditIndex;
  if (index == null || !state.workflowSteps[index]) return;
  state.workflowSteps[index].delay_ms = Math.max(0, Number(els.stepDelayInput.value) || 0);
  closeStepDelayModal();
  recalcTotalMs({ rerender: false });
  updateControls();
  try {
    await saveConfigSilently();
  } catch (err) {
    log("error", err.message);
  }
}

function initStepDelayModal() {
  if (!els.stepDelayModal) return;
  els.stepDelaySaveBtn.addEventListener("click", () => {
    saveStepDelay();
  });
  els.stepDelayClearBtn.addEventListener("click", () => {
    els.stepDelayInput.value = "0";
    els.stepDelayInput.focus();
  });
  els.stepDelayCloseBtn.addEventListener("click", closeStepDelayModal);
  els.stepDelayBackdrop.addEventListener("click", closeStepDelayModal);
  els.stepDelayModal.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      event.preventDefault();
      closeStepDelayModal();
    }
  });
}

let hotkeyCaptureHandler = null;

function updateHotkeyPickerDisplay(value) {
  state.hotkeyPickerDraft = String(value || "").trim();
  if (els.hotkeyCaptureValue) {
    els.hotkeyCaptureValue.textContent = state.hotkeyPickerDraft
      ? formatHotkeyLabel(state.hotkeyPickerDraft)
      : "—";
  }
  els.hotkeyPresetGrid?.querySelectorAll(".hotkey-preset-btn").forEach((btn) => {
    btn.classList.toggle("is-active", btn.dataset.hotkey === state.hotkeyPickerDraft);
  });
}

function bindHotkeyCapture() {
  if (!els.hotkeyCaptureZone || hotkeyCaptureHandler) return;
  hotkeyCaptureHandler = (event) => {
    if (els.hotkeyPickerModal?.classList.contains("hidden")) return;
    const hotkey = eventToHotkeyString(event);
    if (!hotkey) return;
    event.preventDefault();
    event.stopPropagation();
    updateHotkeyPickerDisplay(hotkey);
  };
  els.hotkeyCaptureZone.addEventListener("keydown", hotkeyCaptureHandler);
}

function unbindHotkeyCapture() {
  if (hotkeyCaptureHandler && els.hotkeyCaptureZone) {
    els.hotkeyCaptureZone.removeEventListener("keydown", hotkeyCaptureHandler);
  }
  hotkeyCaptureHandler = null;
}

function renderHotkeyPresets() {
  if (!els.hotkeyPresetGrid) return;
  els.hotkeyPresetGrid.innerHTML = HOTKEY_PRESETS.map(
    ({ label, value }) =>
      `<button type="button" class="hotkey-preset-btn" data-hotkey="${escAttr(value)}">${escAttr(label)}</button>`
  ).join("");
}

function openHotkeyPickerModal(index) {
  if (state.running || !els.hotkeyPickerModal) return;
  const step = state.workflowSteps[index];
  if (!step || step.type !== "send_hotkey") return;
  state.hotkeyPickerMode = "step";
  state.hotkeyEditIndex = index;
  updateHotkeyPickerDisplay(String(step.hotkey || "ctrl+p").trim() || "ctrl+p");
  els.hotkeyPickerModal.classList.remove("hidden");
  els.hotkeyPickerModal.setAttribute("aria-hidden", "false");
  bindHotkeyCapture();
  requestAnimationFrame(() => {
    els.hotkeyCaptureZone?.focus();
  });
}

function openStartHotkeyPicker() {
  if (state.running || !els.hotkeyPickerModal) return;
  state.hotkeyPickerMode = "start";
  state.hotkeyEditIndex = null;
  updateHotkeyPickerDisplay(getStartHotkey() || DEFAULT_START_HOTKEY);
  els.hotkeyPickerModal.classList.remove("hidden");
  els.hotkeyPickerModal.setAttribute("aria-hidden", "false");
  bindHotkeyCapture();
  requestAnimationFrame(() => {
    els.hotkeyCaptureZone?.focus();
  });
}

function closeHotkeyPickerModal() {
  if (!els.hotkeyPickerModal) return;
  unbindHotkeyCapture();
  state.hotkeyEditIndex = null;
  state.hotkeyPickerMode = null;
  state.hotkeyPickerDraft = "";
  els.hotkeyPickerModal.classList.add("hidden");
  els.hotkeyPickerModal.setAttribute("aria-hidden", "true");
}

async function saveHotkeyPicker() {
  const hotkey = String(state.hotkeyPickerDraft || "").trim().toLowerCase();
  if (!hotkey) {
    log("error", "请先选择或录制一个快捷键");
    return;
  }

  if (state.hotkeyPickerMode === "start") {
    if (!state.config) state.config = {};
    if (!state.config.app) state.config.app = {};
    state.config.app.start_hotkey = hotkey;
    closeHotkeyPickerModal();
    refreshStartHotkeyUi(hotkey);
    updateStartBtnLabel();
    try {
      await saveConfigSilently();
      await applyStartHotkeyRegistration(hotkey);
      log("info", `执行动作快捷键已设为 ${formatHotkeyLabel(hotkey)}`);
    } catch (err) {
      log("error", err.message);
    }
    return;
  }

  const index = state.hotkeyEditIndex;
  if (index == null || !state.workflowSteps[index]) return;
  state.workflowSteps[index].hotkey = hotkey;
  closeHotkeyPickerModal();
  updateControls();
  try {
    await saveConfigSilently();
  } catch (err) {
    log("error", err.message);
  }
}

function initHotkeyPickerModal() {
  if (!els.hotkeyPickerModal) return;
  renderHotkeyPresets();
  els.hotkeyPickerSaveBtn.addEventListener("click", () => {
    saveHotkeyPicker();
  });
  els.hotkeyPickerCancelBtn.addEventListener("click", closeHotkeyPickerModal);
  els.hotkeyPickerCloseBtn.addEventListener("click", closeHotkeyPickerModal);
  els.hotkeyPickerBackdrop.addEventListener("click", closeHotkeyPickerModal);
  els.hotkeyPresetGrid?.addEventListener("click", (event) => {
    const btn = event.target.closest(".hotkey-preset-btn");
    if (!btn) return;
    updateHotkeyPickerDisplay(btn.dataset.hotkey);
    els.hotkeyCaptureZone?.focus();
  });
  els.hotkeyPickerModal.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      event.preventDefault();
      closeHotkeyPickerModal();
    } else if (event.key === "Enter" && event.target === els.hotkeyCaptureZone) {
      event.preventDefault();
      saveHotkeyPicker();
    }
  });
}

async function sendCommand(message) {
  return window.cutppaper.sendCommand(message);
}


async function handleUserPrompt(payload) {
  if (promptInFlight === payload.prompt_id) return;
  promptInFlight = payload.prompt_id;
  state.waitingPrompt = true;
  updateProgress(0, state.totalMs, `等待确认: ${payload.step_label || "步骤"}`);
  updateControls();

  try {
    const isConfirm = payload.prompt_kind === "confirm" || payload.prompt_kind === "condition";
    const action = isConfirm
      ? await showCustomConfirmDialog({
          title: payload.title || (payload.prompt_kind === "condition" ? "状态判断未通过" : "弹窗确认"),
          message: payload.message || "请确认后继续",
          detail: payload.detail || "",
          stepLabel: payload.step_label || payload.title || "",
          okLabel: payload.prompt_kind === "condition" ? "继续执行" : "确认继续",
          cancelLabel: "取消",
        })
      : await window.cutppaper.showActionDialog({
          title: payload.title || "步骤执行出现问题",
          message: payload.message || "发生未知错误",
          detail: payload.detail || payload.step_label || "",
        });
    const label = isConfirm
      ? (action === "confirm" ? (payload.prompt_kind === "condition" ? "继续执行" : "确认") : "取消")
      : (action === "retry" ? "重试" : action === "skip" ? "跳过此步" : "停止流程");
    log(isConfirm && action === "cancel" ? "warn" : "info", `用户确认: ${label}`);
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
        action: payload.prompt_kind === "confirm" ? "cancel" : "abort",
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
  const simulation = els.simulationMode.checked;
  const response = await sendCommand({
    cmd: "list_ports",
    simulation_mode: simulation,
  });
  if (response.event !== "ports") return;
  const current = els.portSelect.value;
  els.portSelect.innerHTML = "";
  const ports = response.ports || [];
  if (!ports.length && !simulation) {
    const empty = document.createElement("option");
    empty.value = "";
    empty.textContent = "未检测到串口";
    empty.disabled = true;
    els.portSelect.appendChild(empty);
    return;
  }
  ports.forEach((port) => {
    const option = document.createElement("option");
    const portName = typeof port === "string" ? port : port.port;
    const description = typeof port === "string" ? "" : port.description || "";
    option.value = portName;
    option.textContent = description ? `${portName} — ${description}` : portName;
    els.portSelect.appendChild(option);
  });
  let preferred = current;
  if (simulation) {
    preferred = "SIM（模拟）";
  } else if (!preferred || preferred.startsWith("SIM")) {
    preferred = state.config?.serial?.port || ports[0]?.port || ports[0];
  }
  if (preferred && [...els.portSelect.options].some((opt) => opt.value === preferred)) {
    els.portSelect.value = preferred;
  }
}

async function connectDevice() {
  await saveConfigSilently();
  await sendCommand({ cmd: "connect", port: els.portSelect.value });
}

function shouldAutoConnect() {
  return state.config?.app?.auto_connect !== false;
}

async function tryAutoConnect() {
  if (state.connected || state.running || state.autoConnectInProgress || !state.pythonReady) {
    return;
  }
  if (!shouldAutoConnect()) {
    return;
  }

  const simulation = state.config?.app?.simulation_mode === true;
  if (simulation) {
    els.portSelect.value = "SIM（模拟）";
  } else {
    const preferred = String(state.config?.serial?.port || "").trim();
    const options = [...els.portSelect.options].map((opt) => opt.value).filter(Boolean);
    if (!options.length) {
      log("warn", "自动连接跳过：未检测到串口，请插入 USB 后点刷新");
      return;
    }
    if (preferred && options.includes(preferred)) {
      els.portSelect.value = preferred;
    } else if (preferred) {
      log("warn", `自动连接跳过：配置端口 ${preferred} 未找到，请在连接窗口选择端口`);
      return;
    } else {
      els.portSelect.value = options[0];
    }
  }

  state.autoConnectInProgress = true;
  try {
    await connectDevice();
  } catch (err) {
    log("warn", `自动连接失败: ${err.message}`);
  } finally {
    state.autoConnectInProgress = false;
  }
}

async function disconnectDevice() {
  await sendCommand({ cmd: "disconnect" });
}

function openConnectionModal() {
  refreshPorts().catch((err) => log("error", err.message));
  updateConnectionModal();
  els.connectionModal.classList.remove("hidden");
  els.connectionModal.setAttribute("aria-hidden", "false");
}

function closeConnectionModal() {
  els.connectionModal.classList.add("hidden");
  els.connectionModal.setAttribute("aria-hidden", "true");
}

function updateSettingsModal() {
  els.relayK3Name.disabled = state.running;
  els.relayK4Name.disabled = state.running;
  refreshStartHotkeyUi();
}

function openSettingsModal() {
  refreshRelayLabelUi(state.config);
  refreshStartHotkeyUi();
  updateSettingsModal();
  els.settingsModal.classList.remove("hidden");
  els.settingsModal.setAttribute("aria-hidden", "false");
}

function closeSettingsModal() {
  els.settingsModal.classList.add("hidden");
  els.settingsModal.setAttribute("aria-hidden", "true");
}

function handleBackendEvent(payload) {
  switch (payload.event) {
    case "ready":
      state.pythonReady = true;
      state.pythonExit = false;
      refreshStatusPanel();
      sendCommand({ cmd: "get_config" }).then((res) => {
        if (res.event === "config") applyConfigToForm(res.config);
        return refreshPorts();
      }).then(refreshActionGroups)
        .then(() => tryAutoConnect())
        .catch((err) => log("error", err.message));
      break;
    case "python_exit":
      state.pythonReady = false;
      state.pythonExit = true;
      refreshStatusPanel();
      log("error", payload.message);
      break;
    case "config":
      applyConfigToForm(payload.config);
      break;
    case "cut_window_ok":
      if (payload.sent) {
        log("info", `已激活「${payload.title}」并发送 ${payload.hotkey}`);
      } else {
        log("info", `已找到并激活窗口「${payload.title}」（关键字: ${payload.keyword}）`);
      }
      break;
    case "cut_hotkey_sent":
      break;
    case "app_focus_restored":
      if (payload.ok === false) {
        log("warn", `窗口激活失败: ${payload.keyword || payload.title || "未知窗口"}`);
      } else if (payload.title) {
        log("info", `已回到窗口: ${payload.title}`);
      }
      break;
    case "config_saved":
      applyConfigToForm(payload.config);
      log("info", "设置已保存");
      break;
    case "connected":
      state.connected = true;
      state.connectedPort = payload.port || "";
      state.simulation = payload.simulation === true;
      state.rodPosition = null;
      state.motorState = null;
      log("info", payload.simulation ? "模拟模式已连接" : `串口已连接 ${payload.port}`);
      updateControls();
      void refreshDeviceStatus();
      break;
    case "device_status":
      if (payload.position) state.rodPosition = payload.position;
      else if (payload.raw) state.rodPosition = parseRodPosition(payload.raw);
      if (payload.motor) state.motorState = payload.motor;
      refreshStatusPanel();
      updateConnectionModal();
      break;
    case "rod_sensor":
      state.rodPosition = payload.position || parseRodPosition(payload.raw);
      refreshStatusPanel();
      updateConnectionModal();
      break;
    case "disconnected":
      state.connected = false;
      state.connectedPort = "";
      state.rodPosition = null;
      state.motorState = null;
      log("info", "连接已断开");
      updateControls();
      break;
    case "cycle_started":
      state.running = true;
      state.waitingLoop = false;
      state.loopIndex = 1;
      syncRunTotalMs(payload.total_ms);
      resetRunVisuals();
      updateProgress(0, state.totalMs, "准备运行", 0);
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
      syncRunTotalMs(payload.total_ms);
      resetRunVisuals();
      updateProgress(0, state.totalMs, `第 ${state.loopIndex} 轮`, 0);
      updateControls();
      log("info", `开始第 ${state.loopIndex} 轮`);
      break;
    case "loop_wait":
      state.waitingLoop = true;
      clearStepRunVisuals();
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
      clearStepRunVisuals();
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
      clearStepRunVisuals();
      updateControls();
      log("warn", "流程已中止");
      break;
    case "progress":
    case "state":
      handleStepRunUpdate(payload);
      break;
    case "log":
      log(payload.level || "info", payload.message);
      break;
    case "user_prompt":
      void handleUserPrompt(payload);
      break;
    case "restore_focus_request":
      break;
    case "error":
      if (!state.running) {
        state.waitingLoop = false;
        state.loopIndex = 0;
        clearStepRunVisuals();
        updateControls();
      }
      log("error", payload.message);
      break;
    case "test_done":
      log("info", `单步测试完成: ${payload.step}`);
      break;
    case "action_groups":
      renderManageGroupsList(payload.groups || []);
      break;
    case "action_group_saved":
      renderManageGroupsList(payload.groups || []);
      els.groupNameInput.value = payload.name || els.groupNameInput.value;
      log("info", `动作组已保存到软件库: ${payload.name}`);
      break;
    case "action_group_loaded":
      applyConfigToForm(payload.config);
      els.groupNameInput.value = payload.name || "";
      log("info", `已从软件库打开: ${payload.name}`);
      break;
    case "action_group_exported":
      els.groupNameInput.value = payload.name || els.groupNameInput.value;
      log("info", `动作组已导出: ${payload.file_path || payload.name}`);
      break;
    case "action_group_imported":
      applyConfigToForm(payload.config);
      els.groupNameInput.value = payload.name || "";
      log("info", `已从文件导入: ${payload.name}${payload.file_path ? ` (${payload.file_path})` : ""}`);
      break;
    case "action_group_deleted":
      renderManageGroupsList(payload.groups || []);
      log("info", `已删除动作组: ${payload.name}`);
      break;
    default:
      break;
  }
}

els.refreshPortsBtn.addEventListener("click", async () => {
  try {
    await refreshPorts();
    if (!state.connected) {
      await tryAutoConnect();
    }
  } catch (err) {
    log("error", err.message);
  }
});

els.connBar.addEventListener("click", () => {
  if (state.running) return;
  openConnectionModal();
});

els.logBtn.addEventListener("click", () => {
  window.cutppaper.openLogWindow();
});

if (els.winMinimizeBtn) {
  els.winMinimizeBtn.addEventListener("mousedown", (event) => event.stopPropagation());
  els.winMinimizeBtn.addEventListener("click", (event) => {
    event.preventDefault();
    event.stopPropagation();
    window.cutppaper?.windowMinimize?.();
  });
}

if (els.winCloseBtn) {
  els.winCloseBtn.addEventListener("mousedown", (event) => event.stopPropagation());
  els.winCloseBtn.addEventListener("click", (event) => {
    event.preventDefault();
    event.stopPropagation();
    window.cutppaper?.windowClose?.();
  });
}

els.settingsBtn.addEventListener("click", () => {
  openSettingsModal();
});

els.settingsCloseBtn.addEventListener("click", closeSettingsModal);
els.settingsBackdrop.addEventListener("click", closeSettingsModal);

els.connectionCloseBtn.addEventListener("click", closeConnectionModal);
els.connectionBackdrop.addEventListener("click", closeConnectionModal);

els.modalConnectBtn.addEventListener("click", async () => {
  try {
    await connectDevice();
    closeConnectionModal();
  } catch (err) {
    log("error", err.message);
  }
});

els.modalDisconnectBtn.addEventListener("click", async () => {
  try {
    await disconnectDevice();
    closeConnectionModal();
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

async function restoreElectronFocus() {
  if (!window.cutppaper.restoreFocus) {
    return false;
  }
  const result = await window.cutppaper.restoreFocus();
  return result?.ok === true;
}

async function testFocusWindowStep(step) {
  const keyword = String(step.window_keyword || "").trim();
  await saveConfigSilently();
  if (/cutppaper|papercutting/i.test(keyword)) {
    const ok = await restoreElectronFocus();
    if (!ok) {
      throw new Error("无法激活窗口「PaperCutting」，请手动点击本程序窗口后重试");
    }
    log("info", `已找到并激活窗口「PaperCutting」（关键字: ${keyword}）`);
    return;
  }
  await yieldAppFocus();
  await sendCommand({
    cmd: "test_cut_window",
    keyword,
    send_keys: false,
  });
}

async function testHotkeyStep(step) {
  await saveConfigSilently();
  await yieldAppFocus();
  await sendCommand({
    cmd: "test_cut_window",
    keyword: "",
    hotkey: String(step.hotkey || "ctrl+p").trim(),
    send_keys: true,
    delay_ms: getStepDelayMs(step),
    press_count: Math.max(1, Number(step.press_count) || 1),
    press_interval_ms: Math.max(0, Number(step.press_interval_ms) || 0),
  });
}

async function testRestoreAppStep(step, index) {
  await saveConfigSilently();
  await sendCommand({
    cmd: "test_step",
    step: "restore_app",
    workflow_step: readWorkflowStepsFromState()[index],
  });
}

async function triggerStartCycle() {
  const canRun = state.connected && !state.running && enabledSteps().length > 0;
  if (!canRun) return;
  await saveConfigSilently();
  await sendCommand({ cmd: "start_cycle" });
}

els.startBtn.addEventListener("click", async () => {
  try {
    await triggerStartCycle();
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
  const isInput = target instanceof HTMLInputElement;
  const isSelect = target instanceof HTMLSelectElement;
  if (!isInput && !isSelect) return;
  const index = Number(target.dataset.index);
  const field = target.dataset.field;
  if (Number.isNaN(index) || !field || !state.workflowSteps[index]) return;

  if (isInput && field === "enabled") {
    state.workflowSteps[index].enabled = target.checked;
    recalcTotalMs();
    updateControls();
    return;
  }
  if (field === "status_key") {
    state.workflowSteps[index][field] = target.value;
    const options = CONDITION_STATUS_OPTIONS[target.value] || [];
    const current = state.workflowSteps[index].expected_value;
    if (!options.some((item) => item.value === current)) {
      state.workflowSteps[index].expected_value = options[0]?.value || "";
    }
    updateConditionStepLabel(state.workflowSteps[index]);
    recalcTotalMs();
    renderStepEditor();
    return;
  }
  if (field === "expected_value") {
    state.workflowSteps[index][field] = target.value;
    updateConditionStepLabel(state.workflowSteps[index]);
    recalcTotalMs({ rerender: false });
    renderStepEditor();
    return;
  }
  if (field === "group_name") {
    state.workflowSteps[index][field] = target.value;
    updateCallGroupStepLabel(state.workflowSteps[index]);
    recalcTotalMs({ rerender: false });
    renderStepEditor();
    return;
  }
  if (field === "press_count") {
    const nextCount = Math.max(1, Number(target.value) || 1);
    state.workflowSteps[index][field] = nextCount;
    if (nextCount <= 1) {
      state.workflowSteps[index].press_interval_ms = 0;
    }
    recalcTotalMs();
    return;
  } else if (field === "duration_ms" || field.endsWith("_ms")) {
    state.workflowSteps[index][field] = Number(target.value) || 0;
  } else {
    state.workflowSteps[index][field] = target.value;
  }
  recalcTotalMs({ rerender: false });
  if (target.classList.contains("step-input-num")) {
    fitStepNumberInputWidth(target);
  }
}

els.stepEditor.addEventListener("click", async (event) => {
  const target = event.target;
  if (!(target instanceof HTMLElement)) return;

  if (target.classList.contains("window-picker-btn")) {
    event.stopPropagation();
    if (target.disabled || state.running) return;
    await openWindowPickerMenu(Number(target.dataset.index), target);
    return;
  }

  if (target.classList.contains("step-more-btn")) {
    event.stopPropagation();
    if (target.disabled || state.running) return;
    toggleStepRowMenu(Number(target.dataset.index), target);
    return;
  }

  if (target.classList.contains("step-menu-delay")) {
    event.stopPropagation();
    const index = Number(target.dataset.index);
    if (target.disabled || state.running) return;
    closeAllMenus();
    openStepDelayModal(index);
    return;
  }

  if (target.classList.contains("step-hotkey-btn")) {
    event.stopPropagation();
    const index = Number(target.dataset.index);
    if (target.disabled || state.running) return;
    openHotkeyPickerModal(index);
    return;
  }

  if (target.classList.contains("step-menu-delete")) {
    event.stopPropagation();
    const index = Number(target.dataset.index);
    if (target.disabled || state.running || state.workflowSteps.length <= 1) return;
    state.workflowSteps.splice(index, 1);
    closeAllMenus();
    recalcTotalMs();
    updateControls();
    return;
  }

  if (target.classList.contains("step-menu-test")) {
    event.stopPropagation();
    const index = Number(target.dataset.index);
    if (target.disabled) return;
    closeAllMenus();
    await runStepTest(index, target.dataset.testKind, target.dataset.testStep);
    return;
  }

  if (target.classList.contains("step-menu-note")) {
    event.stopPropagation();
    const index = Number(target.dataset.index);
    if (target.disabled || state.running) return;
    closeAllMenus();
    openStepNoteModal(index);
    return;
  }
});

els.addStepMenuBtn.addEventListener("click", (e) => {
  e.stopPropagation();
  if (state.running) return;
  toggleMenu(els.addStepMenu, els.addStepMenuBtn, { align: "left" });
});

els.addStepMenu.addEventListener("click", (e) => {
  const btn = e.target.closest("[data-step-type]");
  if (!btn || btn.disabled) return;
  addStepOfType(btn.dataset.stepType);
});

els.loopMenuBtn.addEventListener("click", (e) => {
  e.stopPropagation();
  if (state.running) return;
  toggleMenu(els.loopMenu, els.loopMenuBtn, { align: "left" });
});

els.loopMenu.addEventListener("click", (e) => {
  e.stopPropagation();
});

els.actionFileMenuBtn.addEventListener("click", (e) => {
  e.stopPropagation();
  if (state.running) return;
  toggleMenu(els.actionFileMenu, els.actionFileMenuBtn, { align: "left" });
});

els.actionFileMenu.addEventListener("click", async (e) => {
  const btn = e.target.closest("[data-file-action]");
  if (!btn || btn.disabled) return;
  const action = btn.dataset.fileAction;
  try {
    if (action === "save") openSaveGroupModal();
    else if (action === "import") await importGroupFromFile();
    else if (action === "export") await exportCurrentGroup();
    else if (action === "manage") openManageGroupsModal();
  } catch (err) {
    log("error", err.message);
  }
});

document.addEventListener("click", (e) => {
  if (e.target.closest(".menu-anchor")) return;
  if (e.target.closest(".window-picker")) return;
  if (e.target.closest("#windowPickerMenu")) return;
  closeAllMenus();
});

els.windowPickerSearch?.addEventListener("input", (event) => {
  renderWindowPickerList(event.target.value);
});

els.windowPickerList?.addEventListener("click", (event) => {
  const btn = event.target.closest(".window-picker-item");
  if (!btn) return;
  event.stopPropagation();
  applyWindowPickerSelection(btn.dataset.title || btn.textContent);
});

els.saveGroupCloseBtn.addEventListener("click", closeSaveGroupModal);
els.saveGroupBackdrop.addEventListener("click", closeSaveGroupModal);
els.saveGroupConfirmBtn.addEventListener("click", async () => {
  try {
    await saveGroupToLibrary(els.groupNameInput.value);
  } catch (err) {
    log("error", err.message);
  }
});

els.manageGroupsCloseBtn.addEventListener("click", closeManageGroupsModal);
els.manageGroupsBackdrop.addEventListener("click", closeManageGroupsModal);

els.manageGroupsList.addEventListener("click", async (e) => {
  const row = e.target.closest(".manage-group-row");
  if (!row) return;
  const name = row.dataset.groupName;
  if (!name) return;
  try {
    if (e.target.classList.contains("group-open-btn")) {
      await openGroupByName(name);
    } else if (e.target.classList.contains("group-export-btn")) {
      await exportGroupByName(name);
    } else if (e.target.classList.contains("group-delete-btn")) {
      await deleteGroupByName(name);
    }
  } catch (err) {
    log("error", err.message);
  }
});

initAddStepMenu();

function applyLoopSettingsFromForm() {
  updateStartBtnLabel();
  updateCycleHint();
}

els.autoLoop.addEventListener("change", async () => {
  applyLoopSettingsFromForm();
  try {
    await saveConfigSilently();
  } catch (err) {
    log("error", err.message);
  }
});

els.loopIntervalMs.addEventListener("input", () => {
  applyLoopSettingsFromForm();
});

els.loopIntervalMs.addEventListener("change", async () => {
  applyLoopSettingsFromForm();
  try {
    await saveConfigSilently();
  } catch (err) {
    log("error", err.message);
  }
});

els.simulationMode.addEventListener("change", async () => {
  state.simulation = els.simulationMode.checked;
  updateControls();
  try {
    await saveConfigSilently();
    await refreshPorts();
    if (state.connected) {
      await sendCommand({ cmd: "disconnect" });
    }
    await tryAutoConnect();
  } catch (err) {
    log("error", err.message);
  }
});

els.autoConnectMode?.addEventListener("change", async () => {
  if (state.running) return;
  try {
    await saveConfigSilently();
    if (els.autoConnectMode.checked && !state.connected) {
      await tryAutoConnect();
    }
  } catch (err) {
    log("error", err.message);
  }
});

[els.relayK3Name, els.relayK4Name].forEach((el) => {
  if (!el) return;
  el.addEventListener("input", () => {
    applyRelayLabelsFromForm();
  });
  el.addEventListener("change", async () => {
    try {
      await saveConfigSilently();
    } catch (err) {
      log("error", err.message);
    }
  });
});

els.startHotkeyBtn?.addEventListener("click", () => {
  openStartHotkeyPicker();
});

els.startHotkeyClearBtn?.addEventListener("click", async () => {
  if (state.running) return;
  if (!state.config) state.config = {};
  if (!state.config.app) state.config.app = {};
  state.config.app.start_hotkey = "";
  refreshStartHotkeyUi("");
  updateStartBtnLabel();
  try {
    await saveConfigSilently();
    await applyStartHotkeyRegistration("");
    log("info", "执行动作快捷键已清除");
  } catch (err) {
    log("error", err.message);
  }
});

function setWindowFocusState(focused) {
  const root = document.getElementById("appRoot");
  if (!root) return;
  root.classList.toggle("is-window-focused", focused === true);
  root.classList.toggle("is-window-blurred", focused !== true);
}

window.cutppaper.onWindowFocusChanged?.((payload) => {
  setWindowFocusState(payload?.focused === true);
});

window.cutppaper.onStartHotkey?.(() => {
  triggerStartCycle().catch((err) => log("error", err.message));
});

window.cutppaper.onBackendEvent(handleBackendEvent);
StatusPanel.init({
  onUsbClick: () => {
    if (!state.running) openConnectionModal();
  },
  onRefresh: () => {
    void refreshDeviceStatus();
  },
});
initConfirmPromptModal();
initStepNoteModal();
initStepDelayModal();
initHotkeyPickerModal();
initStepColumnResize();
document.addEventListener("mousemove", onStepColumnResizeMove);
document.addEventListener("mouseup", onStepColumnResizeEnd);
initStepDragDrop();
applyStepTableColumnWidths(state.config?.ui?.step_table_columns || DEFAULT_STEP_TABLE_COLUMNS);
updateControls();
recalcTotalMs();

setInterval(async () => {
  const ready = await window.cutppaper.isBackendReady();
  if (ready && !state.pythonReady) {
    state.pythonReady = true;
    state.pythonExit = false;
    refreshStatusPanel();
  } else if (!ready && state.pythonReady) {
    state.pythonReady = false;
    refreshStatusPanel();
  }
}, 1000);
