# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CutPPaper is a **paper cutting automation system** with a three-layer architecture:

1. **Electron UI** — desktop control interface (renderer + main process)
2. **Python backend** — workflow state machine, serial comms, Cutting Master 4 integration
3. **STM32F103 firmware** — GPIO control for telescopic rod motor and two relays

The system automates a 5-step cycle: retract rod → pulse relay A → send cut job (Ctrl+P to Cutting Master 4) → wait for cut → extend rod → pulse relay B (return to origin).

## Build & Run

```powershell
npm install                        # Install Electron
pip install -r python/requirements.txt   # pyserial, pywin32, keyboard
npm start                          # Launch the app (Electron spawns Python backend automatically)
```

The app defaults to **simulation mode** — no hardware needed. The Python backend is spawned as a child process by Electron's main process.

No test suite, no linter, no build step currently exists in this project.

## Architecture

### Communication flow

```
[Renderer UI]  --IPC (contextBridge)-->  [Electron Main]  --stdin/stdout JSON-line-->  [Python Controller]
                                                                                            |
                                                                              +-----------+-----------+
                                                                              |                       |
                                                                     [Serial / Mock Client]    [cutting_master.py]
                                                                              |                       |
                                                                     [STM32F103 via USART]   [Cutting Master 4 window]
```

### Electron ↔ Python protocol

The Python backend runs as a child process (`python/controller.py`). Communication is **newline-delimited JSON over stdin/stdout**:

- **Renderer → Python**: `{ "cmd": "start_cycle", "id": "timestamp-random" }`
- **Python → Renderer**: `{ "event": "progress", "phase": "2-1_retract", "elapsed_ms": 500, ... }`
- The `id` field enables request-response matching with a 20-second timeout.
- Push events have no `id` and are forwarded directly to the renderer.

### Python ↔ STM32 serial protocol

Text-based, line-delimited with `\r\n`. Commands are case-insensitive (uppercased by firmware):

| Command | Response | Purpose |
|---------|----------|---------|
| `PING` | `OK:PONG` | Connectivity check |
| `RETRACT` | `OK` | K1 吸合（PA0 高，缩回） |
| `EXTEND` | `OK` | K2 吸合（PA1 高，伸出） |
| `STOP` | `OK` | K1/K2 释放（停止） |
| `ESTOP` | `OK:ESTOP` | Motor stop + relays off |
| `PULSE_A:200` | `OK` | Relay A pulse for N ms |
| `PULSE_B:200` | `OK` | Relay B pulse for N ms |
| `STATUS` | `STATUS:IDLE` | Query motor/relay state |

### Key Python modules

- **`controller.py`** — Central `ControllerService` class. Receives JSON commands, dispatches to config/workflow/serial, emits events. Manages client lifecycle (MockStm32Client vs real Stm32Client) based on `simulation_mode` config flag.
- **`workflow.py`** — `WorkflowRunner` runs the 5-phase cycle in a daemon thread. Phases defined by the `Phase` enum (`IDLE → RETRACT → PULSE_A → SEND_CUT → CUT_WAIT → EXTEND → PULSE_B → DONE`). Supports `estop()` (sets a `threading.Event` cancelling the wait), `test_step()` (single-step testing), and progress reporting.
- **`config.py`** — Loads `config.json` at project root, deep-merges with `DEFAULT_CONFIG` dict. `save_config()` writes the full config back.
- **`serial_stm32.py`** — Real serial client using `pyserial`. Also contains the shared `wait_ms()` function used by both real and mock clients for timed waits with cancellation support.
- **`mock_stm32.py`** — Drop-in mock of `Stm32Client` for UI testing. All commands return `"OK"` immediately.
- **`cutting_master.py`** — **Windows-only**. Uses `win32gui` to find and focus the Cutting Master 4 window by title keyword, then uses `keyboard` library to send the configured hotkey (default `ctrl+p`).

### Key Electron files

- **`electron/main.js`** — Spawns Python, manages JSON-line protocol over stdio, bridges IPC between renderer and Python. Tracks pending requests with timeout in a `Map`. The `CUTPPAPER_PYTHON` env var can override the Python executable path.
- **`electron/preload.js`** — Context bridge: exposes `cutppaper.sendCommand()`, `cutppaper.isBackendReady()`, `cutppaper.onBackendEvent()` to the renderer.
- **`electron/renderer/app.js`** — All UI logic: step timeline rendering, progress bar, config form, serial port management, and event handling from the backend. Steps are defined in the `STEPS` array. Auto-connects in simulation mode on startup.
- **`electron/renderer/index.html`** — Two-column layout: left = workflow panel (timeline + progress + start/estop + single-step test buttons), right = config/serial/log sidebar.

### STM32 firmware pinout (STM32F103C8T6, GPIOA)

| Pin | Function | Direction |
|-----|----------|-----------|
| PA0 | Relay IN1 / K1 (retract) | Output |
| PA1 | Relay IN2 / K2 (extend) | Output |
| PA2 | Relay IN3 / K3 (continue) | Output |
| PA3 | Relay IN4 / K4 (origin) | Output |
| PA4 | LED retract | Output |
| PA5 | LED extend | Output |
| PA6 | LED serial/COM status | Output |
| PA9 | USART1 TX (USB-TTL) | AF output |
| PA10 | USART1 RX (USB-TTL) | Input |

**Key firmware modules in `firmware/User/`:**
- `main.c` — Init sequence: Motor (first, pull PA0/PA1 low) → Board → Relay → Led → Serial → Protocol. Main loop: `Protocol_Poll()` + `Relay_Tick()` + `Led_Tick()`.
- `protocol.c` — Parses text commands (case-insensitive), dispatches to motor/relay modules. `Protocol_IsCommActive()` for COM LED (3s window).
- `motor.c` — H-bridge relays (jumpers H): retract IN1 only; extend IN2 only; stop both released; 80ms before reverse.
- `led.c` — PA4/PA5 motor status LEDs; PA6 COM LED (fast blink offline, PWM breathing when comm active).
- `relay.c` — Pulse-based relay control with tick-based auto-off timing.
- `board.h` — All pin definitions consolidated here.
- `usart_serial.c` — USART1 at 115200 baud, line-buffered receive.

Build with Keil5: open `firmware/CutPPaper.uvprojx`, flash via ST-LINK.

### Config (`config.json`)

Runtime configuration at project root, deep-merged with defaults defined in `config.py`:
- `serial` — Port, baudrate, timeout
- `timings_ms` — Duration for each phase (retract, extend, cut_wait, relay_pulse, before_send_keys)
- `cutting_master` — Window title keyword to find, hotkey to send
- `app` — `simulation_mode` (use mock STM32), `simulate_cut` (skip actual Cutting Master 4 hotkey)

## Development notes

- The entire app is **Windows-only** due to `pywin32` and `keyboard` dependencies in `cutting_master.py`. Simulation mode works cross-platform.
- There is no hot-reload or watch mode. Restart `npm start` after changes to Electron or Python code.
- Python stdout is exclusively for the JSON-line protocol — any stray print will break the IPC. Use `emit()` / `_emit_log()` only.
- The firmware uses STM32F10x Standard Peripheral Library (not HAL). Startup file used is `startup_stm32f10x_md.s` (medium-density device).
- Relay pulses are self-terminating via `Relay_Tick()` polling — no timer interrupts needed.
