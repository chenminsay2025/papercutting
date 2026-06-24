"""Generate AA lcd_font_gb16.c into CutPPaper firmware/User/."""
from __future__ import annotations

import sys
from pathlib import Path

STUDIO = Path(__file__).resolve().parent
PAPER = STUDIO.parent
sys.path.insert(0, str(STUDIO))

from font_studio.core import RenderConfig, default_font_candidates, render_all, unique_chars
from font_studio.export import export_cutppaper_c, export_header_stub, export_index_map

OUT_C = PAPER / "firmware" / "User" / "lcd_font_gb16.c"
OUT_H = PAPER / "firmware" / "User" / "lcd_font_gb16.h"
MAP = PAPER / "docs" / "lcd-font-index-map.txt"
CHARS_GBK = PAPER / "docs" / "lcd-fon-paste-gbk.txt"
CHARS_UTF = PAPER / "docs" / "lcd-font-order.txt"


def load_chars() -> str:
    if CHARS_GBK.exists():
        return unique_chars(CHARS_GBK.read_bytes().decode("gbk"))
    if CHARS_UTF.exists():
        return unique_chars(CHARS_UTF.read_text(encoding="utf-8"))
    raise SystemExit(f"Missing {CHARS_GBK} or {CHARS_UTF}")


def main() -> None:
    cands = default_font_candidates()
    if not cands:
        raise SystemExit("No system font found")
    cfg = RenderConfig(
        font_path=cands[1] if len(cands) > 1 else cands[0],
        cell_w=16,
        cell_h=16,
        super_sample=6,
        threshold=132,
        gamma=1.0,
        blur_hi=0.3,
        sharpen_amount=180,
        sharpen_radius=0.7,
        sharpen_threshold=2,
        downscale="box",
        binarize="threshold",
    )
    text = load_chars()
    print(f"Font: {cfg.font_path}  size={cfg.cell_w}x{cfg.cell_h}  chars={len(text)}  AA=16")
    glyphs = render_all(text, cfg)
    export_header_stub(cfg, OUT_H, aa_levels=16)
    export_cutppaper_c(glyphs, cfg, OUT_C, Path(cfg.font_path).name, aa_levels=16)
    export_index_map(glyphs, MAP)
    print(f"Wrote {OUT_C} ({len(glyphs)} glyphs, {cfg.cell_w * cfg.cell_h // 2} B/glyph AA)")


if __name__ == "__main__":
    main()
