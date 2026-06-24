"""Export glyph sets to C source, binary, PNG sheet, and index map."""
from __future__ import annotations

from pathlib import Path

from PIL import Image

from .core import (
    GlyphResult,
    RenderConfig,
    char_index_bytes,
    pack_alpha_nibbles,
)


def export_cutppaper_c(
    glyphs: list[GlyphResult],
    cfg: RenderConfig,
    out_path: Path,
    font_label: str,
    *,
    aa_levels: int = 16,
) -> None:
    w, h = cfg.cell_w, cfg.cell_h
    if aa_levels > 0:
        mode = f"{w}x{h} {aa_levels}-level AA nibble"
    else:
        mode = f"{w}x{h} 1-bit MSB row"
    lines = [
        '#include "lcd_font_gb16.h"',
        "",
        f"/* {mode} — LCD Font Studio ({font_label}) */",
        "const LcdFontGb16_t g_lcd_font_gb16[] = {",
    ]
    for g in glyphs:
        idx = char_index_bytes(g.char)
        if aa_levels > 0:
            msk = pack_alpha_nibbles(g.gray, aa_levels)
        else:
            msk = g.mask
        body = ", ".join(f"0x{b:02X}" for b in msk)
        ch = g.char
        if ord(ch[0]) < 128:
            comment = f"'{ch}'" if ch.isprintable() and ch not in ("\\", "'") else f"0x{ord(ch):02X}"
        else:
            comment = ch
        lines.append(
            f"  {{ {{0x{idx[0]:02X}, 0x{idx[1]:02X}}}, {g.adv_w}u, {{ {body} }} }}, /* {comment} */"
        )
    lines += [
        "};",
        "",
        "const uint16_t g_lcd_font_gb16_count = "
        "sizeof(g_lcd_font_gb16) / sizeof(g_lcd_font_gb16[0]);",
        "",
    ]
    out_path.write_text("\n".join(lines), encoding="utf-8")


def export_header_stub(cfg: RenderConfig, out_path: Path, *, aa_levels: int = 16) -> None:
    w, h = cfg.cell_w, cfg.cell_h
    rb = cfg.row_bytes
    if aa_levels > 0:
        msk_expr = f"(((LCD_GB16_W * LCD_GB16_H) + 1u) / 2u)"
        aa_def = f"#define LCD_GB16_AA_LEVELS   {aa_levels}u"
    else:
        msk_expr = "(LCD_GB16_H * LCD_GB16_ROW_BYTES)"
        aa_def = "#define LCD_GB16_AA_LEVELS   0u"
    text = f"""#ifndef __LCD_FONT_GB16_H
#define __LCD_FONT_GB16_H

#include <stdint.h>

#define LCD_GB16_W           {w}u
#define LCD_GB16_H           {h}u
#define LCD_GB16_ROW_BYTES   {rb}u
{aa_def}
#if (LCD_GB16_AA_LEVELS > 0u)
#define LCD_GB16_MSK_BYTES   {msk_expr}
#else
#define LCD_GB16_MSK_BYTES   (LCD_GB16_H * LCD_GB16_ROW_BYTES)
#endif
#define LCD_GB16_HALF_W      {(w + 1) // 2}u

typedef struct
{{
\tuint8_t Index[2];
\tuint8_t AdvW;
\tuint8_t Msk[LCD_GB16_MSK_BYTES];
}} LcdFontGb16_t;

extern const LcdFontGb16_t g_lcd_font_gb16[];
extern const uint16_t g_lcd_font_gb16_count;

#endif
"""
    out_path.write_text(text, encoding="utf-8")


def export_binary(glyphs: list[GlyphResult], out_path: Path, *, aa_levels: int = 16) -> None:
    with out_path.open("wb") as f:
        for g in glyphs:
            if aa_levels > 0:
                f.write(pack_alpha_nibbles(g.gray, aa_levels))
            else:
                f.write(g.mask)


def export_index_map(glyphs: list[GlyphResult], out_path: Path) -> None:
    lines = ["# index\tchar\tgb0\tgb1\tink", ""]
    for i, g in enumerate(glyphs):
        idx = char_index_bytes(g.char)
        lines.append(f"{i}\t{g.char}\t0x{idx[0]:02X}\t0x{idx[1]:02X}\t{g.ink}")
    out_path.write_text("\n".join(lines), encoding="utf-8")


def export_char_order(glyphs: list[GlyphResult], out_path: Path) -> None:
    out_path.write_text("".join(g.char for g in glyphs), encoding="utf-8")


def export_png_sheet(
    glyphs: list[GlyphResult],
    cfg: RenderConfig,
    out_path: Path,
    *,
    cols: int = 16,
    scale: int = 4,
    padding: int = 2,
    aa_levels: int = 16,
) -> None:
    if not glyphs:
        return
    from .core import crop_glyph_display, is_half_width, lcd_preview_rgb, mask_to_image

    cw_full = cfg.cell_w * scale + padding * 2
    ch_row = cfg.cell_h * scale + padding * 2
    rows = (len(glyphs) + cols - 1) // cols
    sheet = Image.new("L", (cols * cw_full, rows * ch_row), 255)
    for i, g in enumerate(glyphs):
        if aa_levels > 0:
            tile = lcd_preview_rgb(g.gray, cfg, levels=aa_levels, ch=g.char, adv_w=g.adv_w).convert("L")
        else:
            tile = mask_to_image(g.mask, cfg, 1)
            if is_half_width(g.char):
                tile = crop_glyph_display(tile, cfg, g.char, g.adv_w)
        tw = tile.width * scale
        th = tile.height * scale
        tile = tile.resize((tw, th), Image.Resampling.NEAREST)
        x = (i % cols) * cw_full + padding
        y = (i // cols) * ch_row + padding
        sheet.paste(tile, (x, y))
    sheet.save(out_path)


def export_text_dump(glyphs: list[GlyphResult], cfg: RenderConfig, out_path: Path) -> None:
    from .core import mask_to_image

    lines: list[str] = []
    for i, g in enumerate(glyphs):
        lines.append(f"=== [{i}] {g.char!r} ink={g.ink} ===")
        img = mask_to_image(g.mask, cfg, 1)
        for row in range(cfg.cell_h):
            row_s = "".join("#" if img.getpixel((col, row)) else "." for col in range(cfg.cell_w))
            lines.append(row_s)
        lines.append("")
    out_path.write_text("\n".join(lines), encoding="utf-8")
