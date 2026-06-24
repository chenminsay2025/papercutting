"""Convert LCDimg/*.png to RGB565 C arrays for STM32 (pre-multiplied on black)."""
from __future__ import annotations

import os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC_DIR = os.path.join(ROOT, "LCDimg")
OUT_C = os.path.join(ROOT, "firmware", "User", "lcd_img_data.c")
OUT_H = os.path.join(ROOT, "firmware", "User", "lcd_img.h")

# 0 = 使用 PNG 原尺寸，1:1 显示不缩放
TARGET_W = 0
TARGET_H = 0

# (source filename, C symbol)
IMAGES = (
    ("\u5df2\u538b\u7eb8.png", "g_lcd_img_paper_press"),
    ("\u672a\u538b\u7eb8.png", "g_lcd_img_paper_lift"),
    ("USB\u5df2\u8fde\u63a5.png", "g_lcd_img_usb_on"),
    ("USB\u672a\u8fde\u63a5.png", "g_lcd_img_usb_off"),
    ("\u4f20\u611f\u5668\u5df2\u906e\u6321.png", "g_lcd_img_obstacle_blocked"),
    ("\u4f20\u611f\u5668\u672a\u906e\u6321.png", "g_lcd_img_obstacle_clear"),
)


def rgba_to_rgb565(r: int, g: int, b: int, a: int) -> int:
    if a <= 0:
        return 0x0000
    r = (r * a) // 255
    g = (g * a) // 255
    b = (b * a) // 255
    return ((r & 0xF8) << 8) | ((g & 0xFC) << 3) | (b >> 3)


def load_rgb565(path: str) -> tuple[int, int, list[int]]:
    img = Image.open(path).convert("RGBA")
    try:
        resample = Image.Resampling.LANCZOS
    except AttributeError:
        resample = Image.LANCZOS
    if TARGET_W > 0 and TARGET_H > 0:
        img = img.resize((TARGET_W, TARGET_H), resample)
    w, h = img.size
    px = img.load()
    out: list[int] = []
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            out.append(rgba_to_rgb565(r, g, b, a))
    return w, h, out


def write_header(symbols: list[tuple[str, int, int]]) -> None:
    lines = [
        "#ifndef __LCD_IMG_H",
        "#define __LCD_IMG_H",
        "",
        "#include <stdint.h>",
        "",
        "typedef struct",
        "{",
        "\tuint16_t W;",
        "\tuint16_t H;",
        "\tconst uint16_t *Data;",
        "} LcdImg_t;",
        "",
    ]
    for sym, _w, _h in symbols:
        lines.append("extern const LcdImg_t %s;" % sym)
    lines.extend(["", "#endif", ""])
    with open(OUT_H, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


def write_source(entries: list[tuple[str, str, int, int, list[int]]]) -> None:
    lines = ['#include "lcd_img.h"', ""]
    symbols: list[tuple[str, int, int]] = []

    for sym, var, w, h, data in entries:
        arr = "lcd_img_%s_data" % var
        body = ", ".join("0x%04X" % v for v in data)
        lines.append("static const uint16_t %s[%d] = { %s };" % (arr, len(data), body))
        lines.append("")
        lines.append("const LcdImg_t %s = { %d, %d, %s };" % (sym, w, h, arr))
        lines.append("")
        symbols.append((sym, w, h))

    with open(OUT_C, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    write_header(symbols)


def main() -> None:
    entries = []
    total = 0
    for fname, sym in IMAGES:
        path = os.path.join(SRC_DIR, fname)
        if not os.path.isfile(path):
            raise SystemExit("missing: " + path)
        w, h, data = load_rgb565(path)
        var = sym.replace("g_lcd_img_", "")
        entries.append((sym, var, w, h, data))
        total += len(data) * 2
        print("%s -> %dx%d (%d bytes)" % (fname, w, h, len(data) * 2))

    write_source(entries)
    print("total RO-data ~%d bytes -> %s" % (total, OUT_C))


if __name__ == "__main__":
    main()
