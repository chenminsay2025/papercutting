"""Render TTF/TTC glyphs to 1-bit MSB-first row bitmaps."""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

RESAMPLE = {
    "box": Image.Resampling.BOX,
    "lanczos": Image.Resampling.LANCZOS,
    "bicubic": Image.Resampling.BICUBIC,
}


@dataclass
class RenderConfig:
    cell_w: int = 16
    cell_h: int = 16
    super_sample: int = 6
    threshold: int = 128
    font_path: str = ""
    font_index: int = 0
    ascii_shrink: int = 6
    cjk_shrink: int = 6
    gamma: float = 1.15
    blur_hi: float = 1.0
    sharpen_amount: int = 0
    sharpen_radius: float = 0.8
    sharpen_threshold: int = 3
    downscale: str = "box"
    binarize: str = "threshold"
    baseline_shift: int = 2  # cell pixels down (positive = lower on LCD)

    @property
    def row_bytes(self) -> int:
        return (self.cell_w + 7) // 8

    @property
    def msk_bytes(self) -> int:
        return self.cell_h * self.row_bytes


@dataclass
class GlyphResult:
    char: str
    mask: bytes
    gray: Image.Image
    hi: Image.Image
    ink: int = 0
    adv_w: int = 16


QUALITY_PRESETS: dict[str, dict] = {
    "标准": {
        "super_sample": 4,
        "threshold": 135,
        "gamma": 1.0,
        "blur_hi": 0.6,
        "downscale": "box",
        "binarize": "threshold",
    },
    "平滑": {
        "super_sample": 6,
        "threshold": 128,
        "gamma": 1.15,
        "blur_hi": 1.0,
        "downscale": "box",
        "binarize": "threshold",
    },
    "极平滑": {
        "super_sample": 8,
        "threshold": 118,
        "gamma": 1.22,
        "blur_hi": 1.4,
        "downscale": "box",
        "binarize": "threshold",
    },
    "抖动(细线)": {
        "super_sample": 6,
        "threshold": 128,
        "gamma": 1.1,
        "blur_hi": 0.8,
        "sharpen_amount": 0,
        "sharpen_radius": 0.8,
        "sharpen_threshold": 3,
        "downscale": "box",
        "binarize": "floyd",
    },
    "锐化": {
        "super_sample": 6,
        "threshold": 132,
        "gamma": 1.0,
        "blur_hi": 0.3,
        "sharpen_amount": 180,
        "sharpen_radius": 0.7,
        "sharpen_threshold": 2,
        "downscale": "box",
        "binarize": "threshold",
    },
    "强锐化": {
        "super_sample": 8,
        "threshold": 138,
        "gamma": 0.95,
        "blur_hi": 0.0,
        "sharpen_amount": 260,
        "sharpen_radius": 0.5,
        "sharpen_threshold": 1,
        "downscale": "lanczos",
        "binarize": "threshold",
    },
}


def unique_chars(text: str) -> str:
    seen: set[str] = set()
    out: list[str] = []
    for ch in text:
        if ch in ("\r", "\n", "\t"):
            continue
        if ch not in seen:
            seen.add(ch)
            out.append(ch)
    return "".join(out)


def is_half_width(ch: str) -> bool:
    """ASCII letters/digits/symbols — STM32 draws LCD_GB16_HALF_W columns only."""
    return len(ch) == 1 and ord(ch[0]) < 128


def cell_half_w(cfg: RenderConfig) -> int:
    return (cfg.cell_w + 1) // 2


def font_point_size(cfg: RenderConfig, ch: str) -> int:
    """Same cap height for ASCII and CJK; half-width affects horizontal slot only."""
    base = cfg.cell_w * cfg.super_sample
    shrink = cfg.ascii_shrink if is_half_width(ch) else cfg.cjk_shrink
    return max(8, base - shrink)


def crop_glyph_display(gray: Image.Image, cfg: RenderConfig, ch: str, adv_w: int | None = None) -> Image.Image:
    """Preview crop: ASCII uses TTF advance width."""
    if is_half_width(ch):
        w = adv_w if adv_w is not None else cell_half_w(cfg)
        return gray.crop((0, 0, min(w, cfg.cell_w), cfg.cell_h))
    return gray


def _baseline_y_hi(cfg: RenderConfig, font: ImageFont.FreeTypeFont, hi_w: int, hi_h: int) -> int:
    """Typographic baseline; baseline_shift nudges all glyphs down in the cell."""
    pad = max(1, cfg.super_sample // 2)
    _, descent = font.getmetrics()
    return hi_h - pad - descent + cfg.baseline_shift * cfg.super_sample


def _scale_advance(adv_hi: float, hi_w: int, cell_w: int) -> int:
    return max(1, min(cell_w, int(round(adv_hi * cell_w / max(1, hi_w)))))


def char_index_bytes(ch: str) -> tuple[int, int]:
    if ord(ch[0]) < 128:
        return 0, ord(ch[0])
    for enc in ("gb2312", "gbk"):
        try:
            gb = ch.encode(enc)
            return gb[0], gb[1]
        except UnicodeEncodeError:
            continue
    return 0, ord(ch[0]) & 0xFF


def count_ink(mask: bytes, cfg: RenderConfig) -> int:
    total = 0
    for row in range(cfg.cell_h):
        for col in range(cfg.cell_w):
            bi = row * cfg.row_bytes + col // 8
            bit = 0x80 >> (col % 8)
            if bi < len(mask) and mask[bi] & bit:
                total += 1
    return total


def pack_alpha_nibbles(gray: Image.Image, levels: int = 16) -> bytes:
    """Pack grayscale to 4-bit alpha nibbles (2 pixels/byte), for STM32 Lcd_Blend565."""
    w, h = gray.size
    out = bytearray()
    top = max(1, levels - 1)
    for y in range(h):
        for x in range(0, w, 2):
            a0 = gray.getpixel((x, y)) * top // 255
            if x + 1 < w:
                a1 = gray.getpixel((x + 1, y)) * top // 255
            else:
                a1 = 0
            out.append((a0 << 4) | (a1 & 0x0F))
    return bytes(out)


def lcd_preview_rgb(
    gray: Image.Image,
    cfg: RenderConfig,
    *,
    levels: int = 16,
    fg: tuple[int, int, int] = (0, 0, 0),
    bg: tuple[int, int, int] = (255, 255, 255),
    ch: str | None = None,
    adv_w: int | None = None,
) -> Image.Image:
    """Simulate STM32 AA draw; ASCII width = per-glyph AdvW."""
    half = ch is not None and is_half_width(ch)
    if half:
        w = adv_w if adv_w is not None else cell_half_w(cfg)
        w = min(w, cfg.cell_w)
    else:
        w = cfg.cell_w
    h = cfg.cell_h
    top = max(1, levels - 1)
    rgb = Image.new("RGB", (w, h), bg)
    px = rgb.load()
    for row in range(h):
        for col in range(w):
            a = gray.getpixel((col, row)) * top // 255
            t = a / top
            px[col, row] = (
                int(fg[0] * t + bg[0] * (1 - t)),
                int(fg[1] * t + bg[1] * (1 - t)),
                int(fg[2] * t + bg[2] * (1 - t)),
            )
    return rgb


def mask_to_image(mask: bytes, cfg: RenderConfig, scale: int = 1, *, smooth: bool = False) -> Image.Image:
    img = Image.new("L", (cfg.cell_w, cfg.cell_h), 0)
    px = img.load()
    for row in range(cfg.cell_h):
        for col in range(cfg.cell_w):
            bi = row * cfg.row_bytes + col // 8
            if mask[bi] & (0x80 >> (col % 8)):
                px[col, row] = 255
    if scale <= 1:
        return img
    resample = Image.Resampling.LANCZOS if smooth else Image.Resampling.NEAREST
    return img.resize((cfg.cell_w * scale, cfg.cell_h * scale), resample)


def _apply_gamma(img: Image.Image, gamma: float) -> Image.Image:
    if abs(gamma - 1.0) < 0.01:
        return img
    inv = 1.0 / max(0.1, gamma)
    lut = [min(255, int((i / 255.0) ** inv * 255.0 + 0.5)) for i in range(256)]
    return img.point(lut)


def _apply_sharpen(img: Image.Image, amount: int, radius: float, threshold: int) -> Image.Image:
    """Unsharp mask on grayscale glyph; amount=0 disables."""
    if amount <= 0:
        return img
    return img.filter(
        ImageFilter.UnsharpMask(
            radius=max(0.1, radius),
            percent=min(500, max(1, amount)),
            threshold=max(0, threshold),
        )
    )


def _otsu_threshold(img: Image.Image) -> int:
    hist = img.histogram()
    total = sum(hist)
    if total == 0:
        return 128
    sum_all = sum(i * h for i, h in enumerate(hist))
    sum_b = 0
    w_b = 0
    best_t = 128
    best_var = -1.0
    for t in range(256):
        w_b += hist[t]
        if w_b == 0:
            continue
        w_f = total - w_b
        if w_f == 0:
            break
        sum_b += t * hist[t]
        m_b = sum_b / w_b
        m_f = (sum_all - sum_b) / w_f
        var = w_b * w_f * (m_b - m_f) ** 2
        if var > best_var:
            best_var = var
            best_t = t
    return best_t


def _gray_to_mask(lo: Image.Image, cfg: RenderConfig) -> bytes:
    w, h = cfg.cell_w, cfg.cell_h
    rb = cfg.row_bytes
    mode = cfg.binarize.lower()

    if mode == "floyd":
        bw = lo.convert("1", dither=Image.Dither.FLOYDSTEINBERG)
        out = bytearray(cfg.msk_bytes)
        px = bw.load()
        for row in range(h):
            for col in range(w):
                if px[col, row]:
                    out[row * rb + col // 8] |= 0x80 >> (col % 8)
        return bytes(out)

    thresh = cfg.threshold
    if mode == "otsu":
        thresh = _otsu_threshold(lo)

    out = bytearray(cfg.msk_bytes)
    lp = lo.load()
    for row in range(h):
        for col in range(w):
            if lp[col, row] >= thresh:
                out[row * rb + col // 8] |= 0x80 >> (col % 8)
    return bytes(out)


def _compose_lo_from_hi(hi: Image.Image, cfg: RenderConfig, hi_h: int, canvas_h: int) -> Image.Image:
    """Downscale cell area; restore descenders clipped by baseline_shift."""
    resample = RESAMPLE.get(cfg.downscale.lower(), Image.Resampling.BOX)
    hi_w = hi.size[0]
    lo = hi.crop((0, 0, hi_w, hi_h)).resize((cfg.cell_w, cfg.cell_h), resample)
    shift = cfg.baseline_shift
    if shift > 0 and canvas_h > hi_h:
        px = hi.load()
        has_tail = any(px[x, y] > 10 for y in range(hi_h, canvas_h) for x in range(hi_w))
        if has_tail:
            tail = hi.crop((0, hi_h, hi_w, canvas_h)).resize((cfg.cell_w, shift), resample)
            lo = lo.copy()
            lo.paste(tail, (0, cfg.cell_h - shift))
    return lo


def render_glyph(ch: str, cfg: RenderConfig) -> GlyphResult:
    if not cfg.font_path or not Path(cfg.font_path).exists():
        raise FileNotFoundError(f"Font not found: {cfg.font_path}")

    half = is_half_width(ch)
    hi_w = cfg.cell_w * cfg.super_sample
    hi_h = cfg.cell_h * cfg.super_sample
    extra_hi = cfg.baseline_shift * cfg.super_sample if cfg.baseline_shift > 0 else 0
    canvas_h = hi_h + extra_hi
    pt = font_point_size(cfg, ch)
    font = ImageFont.truetype(cfg.font_path, pt, index=cfg.font_index)
    baseline_y = _baseline_y_hi(cfg, font, hi_w, hi_h)
    adv_hi = float(font.getlength(ch))

    rgba = Image.new("RGBA", (hi_w, canvas_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(rgba)
    if half:
        ox = 0
    else:
        bbox = draw.textbbox((0, baseline_y), ch, font=font, anchor="ls")
        tw = bbox[2] - bbox[0]
        ox = (hi_w - tw) // 2 - bbox[0]
    draw.text((ox, baseline_y), ch, font=font, anchor="ls", fill=(255, 255, 255, 255))

    hi = rgba.split()[3]
    if cfg.blur_hi > 0.05:
        hi = hi.filter(ImageFilter.GaussianBlur(radius=cfg.blur_hi))

    lo = _compose_lo_from_hi(hi, cfg, hi_h, canvas_h)
    lo = _apply_gamma(lo, cfg.gamma)
    lo = _apply_sharpen(lo, cfg.sharpen_amount, cfg.sharpen_radius, cfg.sharpen_threshold)

    adv_w = _scale_advance(adv_hi, hi_w, cfg.cell_w) if half else cfg.cell_w
    mask = _gray_to_mask(lo, cfg)
    hi_cell = hi.crop((0, 0, hi_w, hi_h))
    return GlyphResult(char=ch, mask=mask, gray=lo, hi=hi_cell, ink=count_ink(mask, cfg), adv_w=adv_w)


def render_all(text: str, cfg: RenderConfig) -> list[GlyphResult]:
    chars = unique_chars(text)
    return [render_glyph(ch, cfg) for ch in chars]


def default_font_candidates() -> list[str]:
    win = Path(r"C:\Windows\Fonts")
    names = (
        "PingFang.ttc",
        "PingFang SC.ttf",
        "msyh.ttc",
        "msyhbd.ttc",
        "simhei.ttf",
        "simsun.ttc",
        "arial.ttf",
    )
    found: list[str] = []
    for name in names:
        p = win / name
        if p.exists():
            found.append(str(p))
    return found
