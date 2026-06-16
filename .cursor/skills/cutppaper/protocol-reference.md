# CutPPaper 协议参考

## Electron IPC（Renderer → Main）

通过 `window.cutppaper`（`electron/preload.js`）：

| 方法 | 说明 |
|------|------|
| `sendCommand(message)` | 转发至 Python，`{ cmd, id?, ... }` |
| `onBackendEvent(callback)` | 订阅 Python 推送/响应 |
| `isBackendReady()` | Python 是否已 emit `ready` |
| `yieldFocus()` / `restoreFocus()` | 窗口焦点让出/恢复 |
| `setStartHotkey(hotkey)` | 全局启动循环热键 |
| `onStartHotkey(callback)` | 热键触发 `start_cycle` |
| `showActionDialog(options)` | 原生对话框 |
| `pickImportActionGroupFile()` / `pickExportActionGroupFile(name)` | 文件选择 |
| `openLogWindow()` | 独立日志窗口 |
| `logLine(line)` | 写入日志面板 |

## Python 命令（Renderer/Main → controller.py）

所有命令为 JSON 对象，必须含 `cmd`。需要响应时含 `id`（字符串）。

| cmd | 主要字段 | 响应 event |
|-----|----------|------------|
| `ping` | — | `pong` |
| `get_config` | — | `config` |
| `save_config` | `config` | `config_saved` / `error` |
| `list_ports` | `simulation_mode?` | `ports` |
| `connect` | `port?` | `connected` |
| `disconnect` | — | `disconnected` |
| `start_cycle` | — | `cycle_started` |
| `estop` | — | `estop` |
| `test_step` | `step`, `workflow_step?`, `duration_ms?` | `test_done` |
| `serial_ping` | — | `serial_ping` |
| `rod_sensor` | — | `rod_sensor` |
| `restore_app_focus` | `keyword?` | `app_focus_restored` |
| `list_open_windows` | `max_count?` | `open_windows` |
| `restore_focus_ack` | `request_id`, `ok`, `title?` | `restore_focus_ack` |
| `test_cut_window` | `keyword?`, `hotkey?`, `send_keys?`, `press_count?`, ... | `cut_window_ok` |
| `prompt_response` | `prompt_id`, `action` | `prompt_ack` |
| `list_action_groups` | — | `action_groups` |
| `save_action_group` | `name`, `workflow_steps?` | `action_group_saved` |
| `load_action_group` | `name` | `action_group_loaded` |
| `delete_action_group` | `name` | `action_group_deleted` |
| `export_action_group` | `name`, `file_path`, `workflow_steps?` | `action_group_exported` |
| `import_action_group` | `file_path` | `action_group_imported` |
| `export_saved_action_group` | `name`, `file_path` | `action_group_exported` |

`prompt_response.action` 取值：`confirm`, `cancel`, `retry`, `skip`, `abort`（见 `workflow.py` 常量）。

## Python 推送事件（无 id，或带 id 匹配请求）

### 生命周期

| event | 字段 | 说明 |
|-------|------|------|
| `ready` | — | 后端启动完成 |
| `error` | `message`, `trace?` | 错误 |

### 工作流

| event | 字段 | 说明 |
|-------|------|------|
| `cycle_started` | `total_ms`, `auto_loop`, `loop_interval_ms` | 循环开始 |
| `state` | `phase`, `phase_label`, `step_id`, `message` | 步骤切换 |
| `progress` | `phase`, `step_id`, `elapsed_ms`, `total_ms`, `progress`, `step_progress`, ... | 进度条 |
| `cycle_done` | `loop_index`, `will_repeat?` | 单次完成 |
| `cycle_looped` | `loop_index`, `next_loop_index` | 自动下一轮 |
| `cycle_aborted` | `loop_index`, `message?` | 中止 |
| `estop` | — | 急停确认 |
| `cut_hotkey_sent` | `hotkey`, `title` | 热键已发送 |
| `rod_sensor` | `position`, `raw` | 压纸状态：`home`=压纸中（遮挡），`away`=未压纸 |
| `user_prompt` | `prompt_id`, `prompt_text`, `step_id`, ... | 等待用户确认 |
| `restore_focus_request` | `request_id`, `keyword` | 请求 Electron 恢复焦点 |

### 配置 / 串口 / 动作组

| event | 说明 |
|-------|------|
| `config`, `config_saved` | 配置读写 |
| `ports`, `connected`, `disconnected`, `serial_ping` | 串口 |
| `action_groups`, `action_group_*` | 动作组 |
| `log` | `{ level, message }` 日志行 |
| `open_windows`, `app_focus_restored`, `cut_window_ok` | 窗口工具 |

## STM32 文本协议

- 波特率：115200（`config.serial.baudrate`）
- 帧格式：命令字符串 + `\r\n`
- 响应：`OK`, `OK:PONG`, `OK:ESTOP`, `ERR:INVALID`, `STATUS:*`, `ROD:HOME`（压纸中）, `ROD:AWAY`（未压纸）

Python 客户端（`serial_stm32.py`）方法：

```text
ping()           → PING
retract()        → RETRACT
extend()         → EXTEND
stop()           → STOP
estop()          → ESTOP
pulse_a(ms)      → PULSE_A:{ms}
pulse_b(ms)     → PULSE_B:{ms}
rod_sensor()    → ROD_SENSOR
status()         → STATUS
```

`wait_ms(ms, cancel_event)` 用于可取消的定时等待，mock 与 real 共用。

## workflow_steps 字段参考

```json
{
  "id": "step-unique-id",
  "type": "send_hotkey",
  "enabled": true,
  "label": "按键操作",
  "hotkey": "ctrl+p",
  "press_count": 1,
  "press_interval_ms": 0,
  "delay_ms": 200,
  "note": ""
}
```

按 type 额外字段：

- `retract` / `extend` / `wait`：`duration_ms`
- `pulse_a` / `pulse_b`：`duration_ms`（50–2000）
- `focus_window` / `restore_app`：`window_keyword`
- `confirm_dialog`：`prompt_text`
- `condition_check`：`status_key`（paper/motor/usb），`expected_value`
- `else_branch` / `end_if`：分支标记，与「如果」成对使用（见下）

### 如果 / 否则 / 结束如果（if-else）

在 `workflow_steps` 中按顺序放置：

1. **如果**（`condition_check`）— 设置状态条件
2. **则** — 紧跟其后的普通步骤（条件成立时执行）
3. **否则**（`else_branch`）— 可选
4. **否则** 后的步骤（条件不成立时执行）
5. **结束如果**（`end_if`）— 必须，闭合分支

条件成立 → 执行「则」段，跳到「结束如果」；不成立 → 跳过「则」段，执行「否则」段（若有）。无「否则」时不成立则直接跳到「结束如果」。若未配「结束如果」/「否则」，条件不成立时仍弹窗询问是否继续。
