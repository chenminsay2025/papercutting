---
name: cutppaper
description: >-
  CutPPaper 切纸自动化项目领域知识：可配置工作流、Electron↔Python IPC、STM32 串口协议、
  config.json 结构、固件引脚与开发约定。在修改 CutPPaper 代码、工作流、串口、Electron UI、
  Python 后端或 STM32 固件时使用。
---

# CutPPaper 项目 Skill

## 系统概览

三层架构：

```
[Electron Renderer] --IPC--> [Electron Main] --stdin/stdout JSON--> [Python controller.py]
                                                                    |
                                    +-------------------------------+
                                    |                               |
                            [Stm32Client / MockStm32Client]   [cutting_master.py]
                                    |                               |
                            [STM32F103 USART]              [Cutting Master 4 窗口]
```

- **Windows-only**（`pywin32`、`keyboard`、`koffi`）；模拟模式可跨平台测 UI。
- Python **stdout 仅用于 JSON 行协议**，禁止 `print()`；日志用 `emit({"event":"log",...})`。
- 改代码后需重启 `npm start`（无热重载）。

## 运行

```powershell
npm install
pip install -r python/requirements.txt
npm start
```

- `CUTPPAPER_PYTHON`：覆盖 Python 可执行路径
- `CUTPPAPER_ACTION_GROUPS_DIR`：覆盖动作组存储目录

## 工作流（核心概念）

流程由 `config.json` 的 **`workflow_steps`** 数组驱动（非固定 5 步枚举）。默认步骤：

| 顺序 | type | 作用 |
|------|------|------|
| 1 | `retract` | 伸缩杆缩回（STM32 `RETRACT`） |
| 2 | `pulse_a` | 继电器 A 脉冲 → UI 称「模拟【按键B】」 |
| 3 | `focus_window` | 激活 Cutting Master 窗口 |
| 4 | `send_hotkey` | 发送热键（默认 `ctrl+p`） |
| 5 | `wait` | 等待切割完成 |
| 6 | `extend` | 伸缩杆伸出（`EXTEND`） |
| 7 | `pulse_b` | 继电器 B 脉冲 → UI 称「模拟【按键A】」 |

### 命名易混点（必读）

| 代码 type | 串口命令 | 固件引脚 | UI 显示名 |
|-----------|----------|----------|-----------|
| `pulse_a` | `PULSE_A:N` | PA2 继电器 A（继续） | 模拟【按键B】 |
| `pulse_b` | `PULSE_B:N` | PA3 继电器 B（原点） | 模拟【按键A】 |

`simulated_buttons.button_a/button_b` 仅影响 UI 标签，不改变硬件映射。

### 全部 step type

定义于 `python/config.py` → `STEP_TYPES`：

- `retract`, `extend` — 电机，`duration_ms`
- `pulse_a`, `pulse_b` — 继电器脉冲，50–2000 ms
- `focus_window` — `window_keyword`, `delay_ms`
- `send_hotkey` — `hotkey`, `press_count`, `press_interval_ms`, `delay_ms`
- `restore_app` — 回到 CutPPaper 窗口
- `wait` — `duration_ms`, `note`
- `confirm_dialog` — 弹窗等待用户（`prompt_response` 回复）

**已废弃**：`send_cut`（拆成 `focus_window` + `send_hotkey`）、`cut_wait`（改为 `wait`）。

### 流程运行时约束

- `workflow.running == true` 时禁止 connect/disconnect/save/load 动作组
- `estop()` 取消等待并发送 `ESTOP`
- `auto_loop` + `loop_interval_ms` 支持自动循环
- `confirm_dialog` 步骤通过 `prompt_response` 命令回复

## 关键文件

| 层 | 文件 | 职责 |
|----|------|------|
| Electron | `electron/main.js` | spawn Python、JSON 协议、IPC、全局启动热键 |
| Electron | `electron/preload.js` | `window.cutppaper.*` API |
| Electron | `electron/renderer/app.js` | UI、步骤表、事件处理 |
| Python | `python/controller.py` | 命令分发、`ControllerService` |
| Python | `python/workflow.py` | `WorkflowRunner`、进度/状态事件 |
| Python | `python/config.py` | 默认配置、校验、`normalize_workflow_steps` |
| Python | `python/serial_stm32.py` | 真实串口 + `wait_ms()` |
| Python | `python/mock_stm32.py` | 模拟 STM32 |
| Python | `python/cutting_master.py` | 窗口聚焦、热键（Windows） |
| Python | `python/action_groups.py` | 动作组 CRUD（`action_groups/`） |
| 固件 | `firmware/User/protocol.c` | 文本命令解析 |
| 配置 | `config.json` | 运行时配置（deep-merge 默认值） |

## config.json 要点

- `serial` — `port`, `baudrate`（9600–115200）, `timeout_ms`
- `timings_ms` — 全局默认时序；单步可覆盖 `duration_ms` / `delay_ms`
- `cutting_master` — 兼容字段；实际以 `workflow_steps` 中首个 focus/hotkey 步骤为准
- `app.simulation_mode` — `true` 用 Mock，无需硬件
- `app.auto_loop`, `app.start_hotkey`（默认 F5）
- `workflow_steps` — 步骤数组，经 `validate_config` + `normalize_workflow_steps` 处理

修改配置逻辑时同步更新 `DEFAULT_CONFIG`、`validate_config`、`normalize_workflow_steps`。

## Electron ↔ Python 协议（摘要）

- **传输**：换行分隔 JSON；请求带 `id`，20s 超时；推送事件无 `id`
- **Renderer API**：`cutppaper.sendCommand()`, `onBackendEvent()`, `isBackendReady()`

常用命令：`ping`, `get_config`, `save_config`, `list_ports`, `connect`, `disconnect`, `start_cycle`, `estop`, `test_step`, `prompt_response`, `restore_focus_ack`, 动作组 CRUD。

常用推送事件：`ready`, `progress`, `state`, `cycle_done`, `cycle_aborted`, `log`, `user_prompt`, `restore_focus_request`。

完整命令/事件列表见 [protocol-reference.md](protocol-reference.md)。

## STM32 串口协议（摘要）

115200 8N1，`\r\n` 行结束，命令大小写不敏感：

| 命令 | 响应 | 说明 |
|------|------|------|
| `PING` | `OK:PONG` | 连通检查 |
| `RETRACT` / `EXTEND` / `STOP` | `OK` | 电机控制 |
| `ESTOP` | `OK:ESTOP` | 急停 + 继电器全关 |
| `PULSE_A:N` / `PULSE_B:N` | `OK` | 继电器脉冲（N ms，最大 5000） |
| `STATUS` | `STATUS:IDLE` 等 | 状态查询 |

70s 无通信固件自动 ESTOP（`COMM_TIMEOUT_MS`）。

## 固件引脚（STM32F103C8T6）

| 引脚 | 功能 |
|------|------|
| PA0 / PA1 | 电机缩回 / 伸出（H 桥 IN1/IN2） |
| PA2 / PA3 | 继电器 A（继续）/ B（原点） |
| PA4 / PA5 | LED 缩回 / 伸出 |
| PA6 | nologo：LCD 背光；标准板：串口 LED |
| PA7 | nologo：LCD RES；标准板：切换按键 → GND |
| PA8 | 槽型光电 DO（遮挡=压纸中 `ROD:HOME`） |
| PB8 | 切换按键 → GND（nologo 一体板） |
| PB9 | 串口状态 LED D3（nologo 一体板） |
| PB0~PB11 | 板载 ST7735 LCD（nologo，FPC 已焊） |
| PA9 / PA10 | USART1 TX/RX |

Keil 工程：`firmware/CutPPaper.uvprojx`。详细接线见 `docs/wiring.md`。

### 编译与烧录（必读）

- 输出文件：`firmware/Objects/CutPPaper.axf`
- **必须先 Build（F7）成功，再 Download（F8）**；只烧录不编译会报 `Could not load file ...CutPPaper.axf`
- 修改 `lcd_font_gb16.c` 或运行 `lcd-font-studio/export_cutppaper_aa.py` 后必须 **Rebuild**
- Build 失败时看 `firmware/Objects/CutPPaper.build_log.htm`（常见：`LCD_GB16_MSK_BYTES` 未定义）
- 字体导出：`cd lcd-font-studio && python export_cutppaper_aa.py`

## 开发约定

1. **最小改动**：只改任务相关文件；匹配现有命名与风格。
2. **IPC 安全**：Python 不向 stdout 写非 JSON；Electron 解析失败会断链。
3. **线程**：`WorkflowRunner` 在 daemon 线程；串口访问用 `_client_lock`。
4. **模拟 vs 硬件**：`simulation_mode` 切换时 `_recreate_client_if_needed()` 重建 client。
5. **UI 步骤表**：列宽存于 `ui.step_table_columns`；步骤启用用 `enabled` 字段。
6. **动作组**：JSON 存 `action_groups/` 或 `CUTPPAPER_ACTION_GROUPS_DIR`；导入导出为 `.json` 文件。
7. **无测试/linter**：改完手动 `npm start` 验证；模拟模式可测完整 UI 流程。

## 常见任务指引

### 新增工作流步骤类型

1. `config.py`：`STEP_TYPES`、标签、`validate_config` 分支、`normalize_workflow_steps`
2. `workflow.py`：`_step_duration_ms`、执行分支、进度上报
3. `app.js`：步骤编辑器 UI、STEPS 元数据
4. 若需硬件：固件 `protocol.c` + `serial_stm32.py` / `mock_stm32.py`

### 调试切割窗口/热键

- 命令 `test_cut_window`（probe 或 send_keys）
- `cutting_master.py`：`ensure_window_foreground`, `press_hotkey_step`
- Electron `win-focus.js` + `koffi` 强制前台

### 修改默认时序

改 `DEFAULT_WORKFLOW_STEPS` 和/或 `DEFAULT_CONFIG.timings_ms`，并检查现有 `config.json` 是否需迁移说明。
