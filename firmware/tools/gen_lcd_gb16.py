from PIL import Image, ImageDraw, ImageFont

# Keep ASCII-only source; chars listed explicitly for stable GB2312 generation.
CHARS = (
    "\u5207\u7eb8\u673a\u72b6\u6001"  # 切纸机状态
    "\u538b\u4e2d"  # 压中
    "\u7535"  # 电（电机标签）
    "\u672a\u8fde\u63a5\u5df2"  # 未连接已
    "\u505c\u6b62\u7f29\u51fa"  # 停止缩出
    "\u6746\u4f4d\u4e32\u53e3\u5728\u7ebf\u79bb\u7ec8\u70b9"  # 杆位串口在线离终点
    "\u4f60\u597d\u5c4f\u5c31\u7eea"  # 你好屏就绪
)
FONT_PATH = r"C:\Windows\Fonts\simhei.ttf"
OUT_PATH = r"h:\papercutting\firmware\User\lcd_font_gb16.c"


def glyph_bytes(ch):
    font = ImageFont.truetype(FONT_PATH, 14)
    img = Image.new("1", (16, 16), 0)
    draw = ImageDraw.Draw(img)
    draw.text((0, -1), ch, font=font, fill=1)
    rows = []
    for y in range(16):
        b0 = b1 = 0
        for x in range(8):
            if img.getpixel((x, y)):
                b0 |= 1 << x
        for x in range(8, 16):
            if img.getpixel((x, y)):
                b1 |= 1 << (x - 8)
        rows.extend([b0, b1])
    return rows


def main():
    seen = set()
    lines = ['#include "lcd_font_gb16.h"', "", "const LcdFontGb16_t g_lcd_font_gb16[] = {"]
    for ch in CHARS:
        if ch in seen:
            continue
        seen.add(ch)
        gb = ch.encode("gb2312")
        rows = glyph_bytes(ch)
        body = ", ".join("0x%02X" % b for b in rows)
        lines.append(
            "  { {0x%02X, 0x%02X}, { %s } }, /* U+%04X */" % (gb[0], gb[1], body, ord(ch))
        )
    lines.append("};")
    lines.append("")
    lines.append(
        "const uint16_t g_lcd_font_gb16_count = "
        "sizeof(g_lcd_font_gb16) / sizeof(g_lcd_font_gb16[0]);"
    )
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("chars:", len(seen))


if __name__ == "__main__":
    main()
