# CutPPaper 接线总表

> 固件：`firmware/CutPPaper.uvprojx` · 主控：STM32F103C8T6 · 继电器：四路 U4 · 串口：115200 8N1  
> **默认硬件：标准 C8T6 最小系统板 + 外接 0.96" SPI OLED（SSD1306）** · 无板载 TFT  
> 图例：[`wiring-diagram.html`](wiring-diagram.html) · 详述：[`wiring.md`](wiring.md)

**电机 H 桥：** NO1–NO2 拱桥 → 24V+，NC1–NC2 拱桥 → GND，COM1/COM2 → 伸缩杆两根线。  
**继电器触发：** 跳线 S1~S4 插 **H**（高电平触发，3.3V 吸合）。  
**压纸检测：** PA8 槽型光电遮挡 = 压纸中（`ROD:HOME`）；未遮挡 = 未压纸（`ROD:AWAY`）。

---

## 一、通信与烧录

**01**　USB-TTL TX → STM32 PA10（USART1_RX）  
　功能：电脑发、MCU 收  
　要求：与 RX 交叉接线；模块 3.3V TTL；115200 8N1  

**02**　USB-TTL RX → STM32 PA9（USART1_TX）  
　功能：MCU 发、电脑收  
　要求：与 TX 交叉接线；VCC 勿接 MCU  

**03**　USB-TTL GND → STM32 GND  
　功能：串口共地  
　要求：必接；与 24V 负极、继电器 DC− 共地  

**04**　USB-TTL VCC → （不接 MCU）  
　功能：模块自供电  
　要求：拨 3.3V 档；勿给 STM32 反向供电  

**05**　ST-LINK SWDIO → STM32 PA13  
　功能：SWD 烧录  
　要求：可与 USB-TTL 同时插；线色建议绿  

**06**　ST-LINK SWCLK → STM32 PA14  
　功能：SWD 烧录  
　要求：BOOT0 接 GND；线色建议蓝  

**07**　ST-LINK GND → STM32 GND  
　功能：烧录共地  
　要求：必接  

**08**　ST-LINK 3.3V → STM32 3.3V  
　功能：烧录供电  
　要求：可选；板子已有 3.3V 时可不接  

---

## 二、电源与共地

**09**　220V AC → 24V 开关电源  
**10**　24V+ → NO1 与 NO2（短接拱桥）  
**11**　24V−（GND）→ NC1 与 NC2（短接拱桥）  
**12**　24V− → 系统 GND 总线  
**13**　12V 电源+ → 继电器 DC+  
**14**　系统 GND → 继电器 DC−  
**15**　3.3V 电源 → STM32 3.3V  

（各条要求同前版，详见 [`wiring.md`](wiring.md) §二、§五）

---

## 三、继电器控制线

**16**　跳线 S1~S4 → 插 H 位  
**17**　STM32 PA0 → 继电器 IN1（K1）缩回  
**18**　STM32 PA1 → 继电器 IN2（K2）伸出  
**19**　STM32 PA2 → 继电器 IN3（K3）脉冲「继续」  
**20**　STM32 PA3 → 继电器 IN4（K4）脉冲「原点」  

---

## 四、伸缩杆电机（K1/K2 · H 桥）

**21**　NO1 ↔ NO2 短接 → 24V+  
**22**　NC1 ↔ NC2 短接 → GND  
**23**　伸缩杆线 A → COM1  
**24**　伸缩杆线 B → COM2  
**25**　NC2 → （悬空）  
**26**　停止（PA0=0 PA1=0）→ K1/K2 释放，电机无电压  

---

## 五、切纸机按钮并联（K3/K4）

**27~32**　COM3/NO3 并联「继续」；COM4/NO4 并联「原点」；NC3/NC4 悬空  

---

## 六、现场按键与指示灯

**33**　STM32 **PA7** → 切换按钮 → GND  
　功能：现场手动伸缩  
　要求：按一次缩回 3s，再按伸出 3s，交替  

**34**　STM32 **PA6** → D3 串口 LED → 330Ω → GND  
　功能：通信状态  
　要求：快闪=未连接；慢呼吸=已连接  

**35**　STM32 PA4 → D1 缩回 LED → 330Ω → GND  
**36**　STM32 PA5 → D2 伸出 LED → 330Ω → GND  

---

## 六点五、槽型光电（压纸检测）

**45**　槽型光电 VCC → 3.3V  
**46**　槽型光电 GND → 系统 GND  
**47**　槽型光电 DO → STM32 **PA8**  
**48**　槽型光电 AO → （悬空）  

---

## 六点六、外接 0.96" SPI OLED（SSD1306 · 7 针）

**49**　OLED GND → 系统 GND  
**50**　OLED VCC → 3.3V（勿接 5V）  
**51**　OLED SCL/CLK → STM32 **PB8**  
**52**　OLED SDA/DIN → STM32 **PB9**  
**53**　OLED RES → **3.3V**（模块 RST 直连，固件不占 RST 脚）  
**54**　OLED DC → STM32 **PB13**  
**55**　OLED CS → STM32 **PB14**  

OLED 显示（固件）：**切纸机状态** · **压纸** 压纸中/未压纸 · **USB** 已连接/未连接 · **电机** 停止/缩回/伸出  

引脚与示例 `SPI接口液晶显示中文字符串数字(标准库)/Source/oled.h` 一致。

---

## 七、软件（无硬件线）

**38**　PaperCutting → Cutting Master 4（Ctrl+P）  
**39**　PaperCutting → USB-TTL COM 口  
**40**　串口连接（CH340 RTS 接 NRST 时 DTR=1、RTS=1，连接后约 350ms）  

---

## 八、软件步骤 ↔ 硬件

- **A 缩回** · `RETRACT` · PA0=1 PA1=0；PA8 压纸中时自动停电机  
- **B 继续** · `PULSE_A` · PA2 脉冲，K3  
- **C 切割** · PC 热键 · 无继电器  
- **D 伸出** · `EXTEND` · PA0=0 PA1=1，K2  
- **E 原点** · `PULSE_B` · PA3 脉冲，K4  

**状态显示：** 外接 OLED + PaperCutting 上位机；D3 串口灯接 **PA6**。

---

## 九、线材 · 十、上电前检查 · 十一、禁止

**上电前检查（摘要）：**

1. 所有 GND 共地  
2. 电机 H 桥：NO1–NO2→24V+，NC1–NC2→GND，COM1/COM2→电机  
3. 串口 TX/RX 交叉，115200；VCC 不接 MCU  
4. 跳线 S1~S4 插 H  
5. 槽型光电 DO→PA8  
6. **OLED：** PB8/PB9/PB13/PB14；RES→3.3V；VCC 3.3V  
7. **PA6**=D3 串口灯，**PA7**=切换键（勿与 OLED 引脚混淆）  
8. 先不接 24V 测 K1/K2，再空载试转
