# papercutting

切纸自动控制：Electron 界面 + Python 后端 + STM32F103 固件。

## 目录

- `electron/` — 控制界面
- `python/` — 流程控制、串口、Cutting Master 4 (Ctrl+P)
- `firmware/` — Keil 工程 `CutPPaper.uvprojx`
- `STM32F103C8T6开发板LED闪示例代码/` — LED 参考工程
- `config.json` — 时序与串口配置

## 运行

```powershell
npm install
pip install -r python/requirements.txt
npm start
```

默认 **模拟模式**，无需硬件即可测试界面与流程。

## 固件

Keil5 打开 `firmware/CutPPaper.uvprojx`，ST-LINK 烧录。

## 接线图

- **可视化接线图（推荐）**：双击打开 [`docs/wiring-diagram.html`](wiring-diagram.html)  
  含思维导图总览、工艺流程、引脚图、ST-LINK / USB-TTL / 伸缩杆 / 继电器 / 电源等分页图。
- **文字详细说明**：[`docs/wiring.md`](wiring.md)
