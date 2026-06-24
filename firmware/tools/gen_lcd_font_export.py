"""Generate deduplicated LCD font character list for user export."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(r"h:\PaperCutting-backup-20260618")

# Firmware UI strings (from lcd_ui.c, lcd_ui_labels.c, gen_lcd_gb16.py, comments)
UI_CN = (
    "切纸机状态压中未连接已停止缩出杆位串口在线离终点你好屏就绪"
    "电机通信纸伸缩回模拟按键激活窗口发送切割等待动作执行"
    "第轮空闲运行完成开始中止其他确认调用组条件按下步骤"
    "在线离线已压未压继电器杆"
    "运行完成中止空闲在线离线已压未压缩回伸出通信压纸电机"
    "等待开始执行动作步骤按下缩伸"
    "伸缩杆缩回继电器激活窗口发送切割等待切割伸缩杆伸出"
    "继电器回到窗口弹窗确认调用组条件停止其他"
    "下中串他件伸位作你信停其出切到割动压发口器回在好始完就屏已开弹待态成执拟按接未机杆条模止步活激点状用电确离空窗第等纸线组终继绪缩行认调轮运连送通键闲骤"
    "离线未压亮黄红底"
)

# Likely future / common UI reserve
RESERVE_CN = (
    "正常错误失败超时警告提示断开端口测试自动手动循环轮次进度用时"
    "秒毫秒重试取消复位清零初始化就绪原继续返回首页隐藏流程暂停"
    "加载保存设置版本固件升级调试日志记录成功跳过忽略重连"
    "上升下降前进后退打开关闭启用禁用有效无效忙碌准备"
    "数据查询刷新控制说明编号名称许可同步校准检测传感器急停"
)

# ASCII + punctuation used on LCD (16x16 unified)
ASCII = (
    " %./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    "~!@#$%^&*_-+=<>"
)
SYMBOLS = "：·（）【】"

EXTRA_ASCII = "K34PB8sL"  # ensure K3 K4 PB8 3s L loop etc.


def is_cjk(ch: str) -> bool:
    o = ord(ch)
    return 0x4E00 <= o <= 0x9FFF


def extract_comments(root: Path) -> str:
    text = ""
    for path in (root / "firmware/User/lcd_ui.c", root / "firmware/User/lcd_ui_labels.c"):
        if path.exists():
            for m in re.finditer(r"/\* ([^*]+) \*/", path.read_text(encoding="utf-8", errors="ignore")):
                text += "".join(ch for ch in m.group(1) if is_cjk(ch))
    return text


def dedupe(s: str) -> str:
    seen: set[str] = set()
    out: list[str] = []
    for ch in s:
        if ch not in seen:
            seen.add(ch)
            out.append(ch)
    return "".join(out)


def main() -> None:
    all_cn = UI_CN + RESERVE_CN + extract_comments(ROOT)
    cn = dedupe("".join(ch for ch in all_cn if is_cjk(ch)))
    ascii_chars = dedupe("".join(ch for ch in (ASCII + EXTRA_ASCII + "PaperCutting") if ord(ch) < 128))
    sym_chars = dedupe(SYMBOLS)
    full = cn + ascii_chars + sym_chars

    out_path = ROOT / "docs" / "lcd-font-export.txt"
    lines = [
        f"汉字 {len(cn)} 个 + ASCII {len(ascii_chars)} 个 + 符号 {len(sym_chars)} 个 = 合计 {len(full)} 个",
        "",
        "【复制到取模软件 · 16×16 · 微软雅黑 Regular · 逐行高位在前 · 阴码】",
        "",
        full,
        "",
        "【仅汉字】",
        cn,
        "",
        "【仅 ASCII】",
        ascii_chars,
        "",
        "【仅全角符号】",
        sym_chars,
    ]
    out_path.write_text("\n".join(lines), encoding="utf-8")
    print(f"CN={len(cn)} ASCII={len(ascii_chars)} TOTAL={len(full)}")
    print(full)


if __name__ == "__main__":
    main()
