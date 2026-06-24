labels = [
    "伸缩杆缩回",
    "继电器K3",
    "激活窗口",
    "发送切割",
    "等待切割",
    "伸缩杆伸出",
    "继电器K4",
    "回到窗口",
    "弹窗确认",
    "调用组",
    "条件",
    "停止",
    "其他",
]

lines = [
    '#include "lcd_ui_labels.h"',
    "",
    "static const char *const s_lcd_step_labels[] = {",
]
for s in labels:
    gb = s.encode("gb2312")
    esc = "".join("\\x%02x" % b for b in gb)
    lines.append(f'  "{esc}", /* {s} */')
lines.append("};")
lines.append("")
lines.append(
    "const uint8_t g_lcd_step_label_count = "
    "sizeof(s_lcd_step_labels) / sizeof(s_lcd_step_labels[0]);"
)
lines.append("")
lines.append("const char *LcdUiLabels_Get(uint8_t id)")
lines.append("{")
lines.append("  if (id >= g_lcd_step_label_count)")
lines.append('    return s_lcd_step_labels[g_lcd_step_label_count - 1u];')
lines.append("  return s_lcd_step_labels[id];")
lines.append("}")

out = r"h:\PaperCutting-backup-20260618\firmware\User\lcd_ui_labels.c"
with open(out, "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")
print("wrote", out)
