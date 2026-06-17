"""Generate SSD1306 16x16 GB2312 glyphs for firmware/User/oled_font_gb16.c"""
from PIL import Image, ImageDraw, ImageFont

CHARS = (
    "\u5207\u7eb8\u673a\u72b6\u6001"  # 切纸机状态
    "\u538b\u7eb8\u4e2d"  # 压纸 / 压纸中
    "\u672a"  # 未
    "\u7535\u673a"  # 电机
    "\u5df2\u8fde\u63a5"  # 已连接
    "\u505c\u6b62\u7f29\u56de\u4f38\u51fa"  # 停止缩回伸出
)
FONT_PATH = r"C:\Windows\Fonts\simhei.ttf"
OUT_PATH = r"h:\papercutting\firmware\User\oled_font_gb16.c"


def col_byte(img, col, y0):
    """One SSD1306 page column: bit0 = top pixel (same as F8X16 in oled_font_ascii.h)."""
    byte = 0
    for row in range(8):
        if img.getpixel((col, y0 + row)):
            byte |= 1 << row
    return byte


def glyph_pages(ch):
    font = ImageFont.truetype(FONT_PATH, 14)
    img = Image.new("1", (16, 16), 0)
    draw = ImageDraw.Draw(img)
    draw.text((0, -1), ch, font=font, fill=1)

    top = [col_byte(img, col, 0) for col in range(16)]
    bottom = [col_byte(img, col, 8) for col in range(16)]
    return top, bottom


def main():
    seen = set()
    lines = [
        '#include "oled_font_gb16.h"',
        "",
        "const OledFontGb16_t g_oled_font_gb16[] = {",
    ]
    for ch in CHARS:
        if ch in seen:
            continue
        seen.add(ch)
        gb = ch.encode("gb2312")
        top, bottom = glyph_pages(ch)
        top_s = ", ".join("0x%02X" % b for b in top)
        bot_s = ", ".join("0x%02X" % b for b in bottom)
        lines.append(
            "  { {0x%02X, 0x%02X}, { %s }, { %s } }, /* %s */"
            % (gb[0], gb[1], top_s, bot_s, ch)
        )
    lines.append("};")
    lines.append("")
    lines.append(
        "const uint16_t g_oled_font_gb16_count = "
        "sizeof(g_oled_font_gb16) / sizeof(g_oled_font_gb16[0]);"
    )
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("chars:", len(seen))


if __name__ == "__main__":
    main()
