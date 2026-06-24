"""Keep only GB16 glyphs referenced by firmware UI strings."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FONT_C = ROOT / "firmware" / "User" / "lcd_font_gb16.c"
USER_DIR = ROOT / "firmware" / "User"

EXTRA_ASCII = "./0123456789PB8s3K"


def collect_required() -> set[tuple[int, int]]:
    keys: set[tuple[int, int]] = set()
    for path in (USER_DIR / "lcd_ui.c", USER_DIR / "lcd_ui_labels.c"):
        text = path.read_text(encoding="utf-8", errors="ignore")
        for m in re.finditer(r'"((?:\\x[0-9a-fA-F]{2})+)"', text):
            raw = bytes(int(h, 16) for h in re.findall(r"\\x([0-9a-fA-F]{2})", m.group(1)))
            for ch in raw.decode("gbk"):
                b = ch.encode("gbk")
                if len(b) == 2:
                    keys.add((b[0], b[1]))
        for m in re.finditer(r"/\* ([^*]+) \*/", text):
            for ch in m.group(1):
                if ord(ch) < 128:
                    keys.add((0, ord(ch)))
                else:
                    b = ch.encode("gbk")
                    if len(b) == 2:
                        keys.add((b[0], b[1]))
    for ch in EXTRA_ASCII:
        keys.add((0, ord(ch)))
    return keys


def main() -> None:
    required = collect_required()
    lines = FONT_C.read_text(encoding="utf-8").splitlines()
    out: list[str] = []
    kept = 0
    in_array = False

    for line in lines:
        if "const LcdFontGb16_t g_lcd_font_gb16[]" in line:
            out.append(line)
            in_array = True
            continue
        if in_array and line.strip() == "};":
            out.append(line)
            in_array = False
            continue
        if in_array:
            m = re.match(r"\s*\{ \{0x([0-9A-Fa-f]{2}), 0x([0-9A-Fa-f]{2})\},", line)
            if m:
                k = (int(m.group(1), 16), int(m.group(2), 16))
                if k in required:
                    out.append(line.rstrip())
                    kept += 1
            continue
        if line.startswith("const uint16_t g_lcd_font_gb16_count"):
            continue
        out.append(line)

    if kept == 0:
        raise SystemExit("no glyphs matched")

    # Remove invalid comma after block comment (Keil: expected an expression)
    fixed: list[str] = []
    glyph_lines = [i for i, line in enumerate(out) if re.match(r"\s*\{ \{0x", line)]
    for i, line in enumerate(out):
        if re.match(r"\s*\{ \{0x", line):
            line = re.sub(r"\s\*/,\s*$", " */", line.rstrip())
            idx = glyph_lines.index(i)
            if idx < len(glyph_lines) - 1 and "/*" not in line and not line.endswith(","):
                line += ","
        fixed.append(line)

    for i in range(len(fixed) - 1):
        if fixed[i + 1].strip() == "};":
            # last glyph: no trailing comma after comment
            fixed[i] = re.sub(r"\s\*/,\s*$", " */", fixed[i].rstrip())
            if fixed[i].rstrip().endswith(","):
                fixed[i] = fixed[i].rstrip()[:-1]

    text = "\n".join(fixed) + "\n"
    if "g_lcd_font_gb16_count" not in text:
        text += (
            "\nconst uint16_t g_lcd_font_gb16_count = "
            "sizeof(g_lcd_font_gb16) / sizeof(g_lcd_font_gb16[0]);\n"
        )
    FONT_C.write_text(text, encoding="utf-8")
    print("required keys:", len(required))
    print("kept glyphs:", kept)
    print("saved ~%d bytes" % ((268 - kept) * 131))


if __name__ == "__main__":
    main()
