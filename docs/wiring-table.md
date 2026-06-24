-# CutPPaper 接线速查（一页）

> STM32F103C8T6 · 115200 8N1 · 默认有 2.4" ST7789V 屏  
> 说明详见 [`wiring.md`](wiring.md)

---

## 全部接线

| # | 从 | 到 | 备注 |
|---|-----|-----|------|
| **通信** |
| 1 | USB-TTL TX | PA10 | 交叉 |
| 2 | USB-TTL RX | PA9 | 交叉 |
| 3 | USB-TTL GND | GND | 必接 |
| 4 | ST-LINK SWDIO | PA13 | |
| 5 | ST-LINK SWCLK | PA14 | |
| 6 | ST-LINK GND | GND | |
| **继电器控制** |
| 7 | 12V+ | 继电器 DC+ | 勿 24V |
| 8 | GND | 继电器 DC− | |
| 9 | PA0 | IN1 | K1 缩回 |
| 10 | PA1 | IN2 | K2 伸出 |
| 11 | PA2 | IN3 | K3 继续 |
| 12 | PA3 | IN4 | K4 原点 |
| 13 | 跳线 S1~S4 | H | 高电平触发 |
| **电机 H 桥 K1/K2** |
| 14 | 24V+ | NO1↔NO2 | 短接 |
| 15 | GND | NC1↔NC2 | 短接 |
| 16 | 电机 A | COM1 | |
| 17 | 电机 B | COM2 | |
| **切纸按钮 K3/K4** |
| 18 | 继续按钮 | COM3/NO3 | 干触点 |
| 19 | 原点按钮 | COM4/NO4 | 干触点 |
| **光电 / 按键 / 灯** |
| 20 | 光电 VCC | 3.3V | |
| 21 | 光电 GND | GND | |
| 22 | 光电 DO | PA8 | 遮挡=压纸 |
| 23 | PB8 | 按钮→GND | 3s 缩/伸 |
| 24 | PA4 | D1→330Ω→GND | 缩回灯 |
| 25 | PA5 | D2→330Ω→GND | 伸出灯 |
| 26 | PB9 | D3 | 通信灯 |
| **蜂鸣 / 避障** |
| 27 | PB0 | 蜂鸣器 I/O | 排针 B0，**低电平响**（默认；若不响改 `board.h` 中 `BUZZER_ACTIVE_LOW=0`） |
| 28 | KY-032 VCC | 3.3V | |
| 29 | KY-032 GND | GND | |
| 30 | KY-032 EN | GND | 跳线常使能 |
| 31 | KY-032 S | PB6 | LOW=有遮挡 |
| **2.4" LCD（8 针）** |
| 32 | 屏 GND | GND | |
| 33 | 屏 VCC | 3.3V | J1=3.3V |
| 34 | 屏 SCL | PB13 | |
| 35 | 屏 SDA | PB15 | |
| 36 | 屏 RES | PB11 | |
| 37 | 屏 DC | PB14 | |
| 38 | 屏 CS | PB12 | |
| 39 | 屏 BLC | PB10 | 高=亮 |

---

## 无屏差异（`BOARD_LCD_MODE=2`）

| 引脚 | 改接 |
|------|------|
| PA6 | 通信灯 D3 |
| PA7 | 按钮→GND |
| PB10~PB15 | 不接 |

---

## 必记

- **共地：** 24V− = MCU GND = TTL GND = 继电器 DC−  
- **禁止：** 24V 接 MCU · TTL 5V 档 · 继电器 DC+ 接 24V  
- **通信灯 PB9**，不是 PA9
