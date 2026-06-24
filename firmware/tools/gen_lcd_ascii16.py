"""Generate 8x16 ASCII glyphs from Microsoft YaHei Regular (crisp 1-bit)."""
from PIL import Image, ImageDraw, ImageFont

FONT_PATH = r"C:\Windows\Fonts\msyh.ttc"
FONT_INDEX = 0
OUT_C = r"h:\PaperCutting-backup-20260618\firmware\User\lcd_font_ascii16.c"
CELL_W = 8
CELL_H = 16
FONT_PX = 13
THRESH = 128


def glyph_rows(ch: str):
    img = Image.new("L", (CELL_W, CELL_H), 0)
    draw = ImageDraw.Draw(img)
    font = ImageFont.truetype(FONT_PATH, FONT_PX, index=FONT_INDEX)
    bbox = draw.textbbox((0, 0), ch, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    ox = (CELL_W - tw) // 2 - bbox[0]
    oy = (CELL_H - th) // 2 - bbox[1]
    draw.text((ox, oy), ch, font=font, fill=255)

    rows = []
    for row in range(CELL_H):
        byte = 0
        for col in range(CELL_W):
            if img.getpixel((col, row)) >= THRESH:
                byte |= 1 << (7 - col)
        rows.append(byte)
    return rows


def main():
    lines = [
        '#include "lcd_font_ascii16.h"',
        "",
        "/* Microsoft YaHei Regular 8x16, 1 bit/pixel */",
        "static const uint8_t s_font_ascii16[][16] = {",
    ]
    for code in range(32, 127):
        ch = chr(code)
        rows = glyph_rows(ch)
        body = ", ".join("0x%02X" % b for b in rows)
        safe = ch if ch.isprintable() and ch not in ("\\", "'") else "?"
        lines.append("  { %s }, /* '%s' */" % (body, safe))
    lines.append("};")
    lines.append("")
    lines.append("const uint8_t *LcdFontAscii16_GetGlyph(char c)")
    lines.append("{")
    lines.append("\tif (c < 32 || c > 126)")
    lines.append("\t\treturn s_font_ascii16[0];")
    lines.append("\treturn s_font_ascii16[(uint8_t)(c - 32)];")
    lines.append("}")
    with open(OUT_C, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print("ascii glyphs:", 127 - 32)


if __name__ == "__main__":
    main()
