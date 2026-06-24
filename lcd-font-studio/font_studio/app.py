"""LCD Font Studio — Tkinter GUI."""
from __future__ import annotations

import json
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

from PIL import Image, ImageTk

from .core import (
    QUALITY_PRESETS,
    GlyphResult,
    RenderConfig,
    crop_glyph_display,
    default_font_candidates,
    is_half_width,
    lcd_preview_rgb,
    render_all,
    render_glyph,
    unique_chars,
)
from .export import (
    export_binary,
    export_char_order,
    export_cutppaper_c,
    export_header_stub,
    export_index_map,
    export_png_sheet,
    export_text_dump,
)


class FontStudioApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("LCD Font Studio — 1-bit 字模生成")
        self.minsize(960, 640)
        self.geometry("1100x720")

        self._glyphs: list[GlyphResult] = []
        self._preview_tk: ImageTk.PhotoImage | None = None
        self._gray_tk: ImageTk.PhotoImage | None = None
        self._debounce_id: str | None = None

        self._build_ui()
        self._load_defaults()

    def _build_ui(self) -> None:
        root = ttk.Frame(self, padding=8)
        root.pack(fill=tk.BOTH, expand=True)

        left = ttk.Frame(root)
        left.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 8))

        right = ttk.Frame(root)
        right.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self._build_font_panel(left)
        self._build_params_panel(left)
        self._build_chars_panel(left)
        self._build_export_panel(left)

        self._build_preview_panel(right)
        self._build_list_panel(right)

        self.status = tk.StringVar(value="就绪")
        ttk.Label(self, textvariable=self.status, anchor=tk.W).pack(
            fill=tk.X, padx=8, pady=(0, 6)
        )

    def _build_font_panel(self, parent: ttk.Frame) -> None:
        box = ttk.LabelFrame(parent, text="字体", padding=6)
        box.pack(fill=tk.X, pady=(0, 8))

        self.font_path = tk.StringVar()
        row = ttk.Frame(box)
        row.pack(fill=tk.X)
        ttk.Entry(row, textvariable=self.font_path, width=36).pack(side=tk.LEFT, fill=tk.X, expand=True)
        ttk.Button(row, text="浏览…", command=self._pick_font).pack(side=tk.LEFT, padx=(4, 0))

        row2 = ttk.Frame(box)
        row2.pack(fill=tk.X, pady=(6, 0))
        ttk.Label(row2, text="TTC 索引").pack(side=tk.LEFT)
        self.font_index = tk.IntVar(value=0)
        ttk.Spinbox(row2, from_=0, to=15, textvariable=self.font_index, width=5).pack(
            side=tk.LEFT, padx=(4, 12)
        )
        ttk.Button(row2, text="系统字体", command=self._pick_system_font).pack(side=tk.LEFT)

    def _build_params_panel(self, parent: ttk.Frame) -> None:
        box = ttk.LabelFrame(parent, text="点阵参数", padding=6)
        box.pack(fill=tk.X, pady=(0, 8))

        self.cell_w = tk.IntVar(value=16)
        self.cell_h = tk.IntVar(value=16)
        self.super_sample = tk.IntVar(value=6)
        self.threshold = tk.IntVar(value=128)
        self.ascii_shrink = tk.IntVar(value=6)
        self.cjk_shrink = tk.IntVar(value=6)
        self.gamma = tk.DoubleVar(value=1.15)
        self.blur_hi = tk.DoubleVar(value=1.0)
        self.sharpen_amount = tk.IntVar(value=0)
        self.sharpen_radius = tk.DoubleVar(value=0.8)
        self.sharpen_threshold = tk.IntVar(value=3)
        self.downscale = tk.StringVar(value="box")
        self.binarize = tk.StringVar(value="threshold")
        self.aa_levels = tk.IntVar(value=16)
        self.preview_scale = tk.IntVar(value=8)

        preset_row = ttk.Frame(box)
        preset_row.pack(fill=tk.X, pady=(0, 6))
        ttk.Label(preset_row, text="画质预设").pack(side=tk.LEFT)
        for name in QUALITY_PRESETS:
            ttk.Button(
                preset_row, text=name, width=8,
                command=lambda n=name: self._apply_quality_preset(n),
            ).pack(side=tk.LEFT, padx=(4, 0))

        ttk.Label(
            box,
            text="共用 TTF 基线：q/g 下伸、r/f/x 同线；中文同基线（与字体查看器一致）",
            foreground="#555",
        ).pack(anchor=tk.W, pady=(4, 0))

        grid = ttk.Frame(box)
        grid.pack(fill=tk.X)

        fields = [
            ("宽 (px)", self.cell_w, 8, 64),
            ("高 (px)", self.cell_h, 8, 64),
            ("超采样", self.super_sample, 2, 10),
            ("阈值", self.threshold, 1, 255),
            ("半宽微调", self.ascii_shrink, 0, 32),
            ("全宽微调", self.cjk_shrink, 0, 32),
        ]
        for i, (label, var, lo, hi) in enumerate(fields):
            r, c = divmod(i, 2)
            f = ttk.Frame(grid)
            f.grid(row=r, column=c, sticky=tk.W, padx=(0, 12), pady=2)
            ttk.Label(f, text=label, width=10).pack(side=tk.LEFT)
            sp = ttk.Spinbox(f, from_=lo, to=hi, textvariable=var, width=6, command=self._schedule_preview)
            sp.pack(side=tk.LEFT)
            var.trace_add("write", lambda *_: self._schedule_preview())

        adv = ttk.Frame(box)
        adv.pack(fill=tk.X, pady=(4, 0))
        ttk.Label(adv, text="Gamma").pack(side=tk.LEFT)
        ttk.Spinbox(adv, from_=0.8, to=2.0, increment=0.05, textvariable=self.gamma, width=6).pack(
            side=tk.LEFT, padx=(4, 12)
        )
        self.gamma.trace_add("write", lambda *_: self._schedule_preview())
        ttk.Label(adv, text="高斯模糊").pack(side=tk.LEFT)
        ttk.Spinbox(adv, from_=0.0, to=3.0, increment=0.1, textvariable=self.blur_hi, width=6).pack(
            side=tk.LEFT, padx=(4, 12)
        )
        self.blur_hi.trace_add("write", lambda *_: self._schedule_preview())

        sharp = ttk.LabelFrame(box, text="锐化 (Unsharp Mask)", padding=4)
        sharp.pack(fill=tk.X, pady=(6, 0))
        row_s = ttk.Frame(sharp)
        row_s.pack(fill=tk.X)
        ttk.Label(row_s, text="强度 %").pack(side=tk.LEFT)
        ttk.Spinbox(row_s, from_=0, to=500, textvariable=self.sharpen_amount, width=6).pack(
            side=tk.LEFT, padx=(4, 12)
        )
        self.sharpen_amount.trace_add("write", lambda *_: self._schedule_preview())
        ttk.Label(row_s, text="半径").pack(side=tk.LEFT)
        ttk.Spinbox(row_s, from_=0.1, to=3.0, increment=0.1, textvariable=self.sharpen_radius, width=5).pack(
            side=tk.LEFT, padx=(4, 12)
        )
        self.sharpen_radius.trace_add("write", lambda *_: self._schedule_preview())
        ttk.Label(row_s, text="阈值").pack(side=tk.LEFT)
        ttk.Spinbox(row_s, from_=0, to=32, textvariable=self.sharpen_threshold, width=5).pack(
            side=tk.LEFT, padx=(4, 0)
        )
        self.sharpen_threshold.trace_add("write", lambda *_: self._schedule_preview())
        ttk.Label(
            sharp,
            text="强度 0=关；120–200 常用。半径越小笔画越利；阈值越大背景越干净",
            foreground="#555",
        ).pack(anchor=tk.W, pady=(4, 0))

        adv2 = ttk.Frame(box)
        adv2.pack(fill=tk.X, pady=(4, 0))
        ttk.Label(adv2, text="缩小算法").pack(side=tk.LEFT)
        ttk.Combobox(
            adv2, textvariable=self.downscale, values=("box", "lanczos", "bicubic"),
            width=10, state="readonly",
        ).pack(side=tk.LEFT, padx=(4, 12))
        self.downscale.trace_add("write", lambda *_: self._schedule_preview())
        ttk.Label(adv2, text="二值化").pack(side=tk.LEFT)
        ttk.Combobox(
            adv2, textvariable=self.binarize,
            values=("threshold", "otsu", "floyd"),
            width=10, state="readonly",
        ).pack(side=tk.LEFT, padx=(4, 0))
        self.binarize.trace_add("write", lambda *_: self._schedule_preview())

        ttk.Label(
            box,
            text="导出写入 STM32 的是 16 级灰度字库；预览模拟 LCD 混合（非平滑插值）",
            foreground="#555",
        ).pack(anchor=tk.W, pady=(6, 0))

    def _build_chars_panel(self, parent: ttk.Frame) -> None:
        box = ttk.LabelFrame(parent, text="字符集", padding=6)
        box.pack(fill=tk.BOTH, expand=True, pady=(0, 8))

        btns = ttk.Frame(box)
        btns.pack(fill=tk.X, pady=(0, 4))
        ttk.Button(btns, text="从文件加载…", command=self._load_chars_file).pack(side=tk.LEFT)
        ttk.Button(btns, text="去重统计", command=self._show_char_stats).pack(side=tk.LEFT, padx=(4, 0))

        self.chars_text = tk.Text(box, width=40, height=12, wrap=tk.WORD, font=("Consolas", 10))
        self.chars_text.pack(fill=tk.BOTH, expand=True)
        self.chars_text.bind("<<Modified>>", self._on_chars_modified)

        ttk.Button(box, text="生成全部字模", command=self._generate_all).pack(fill=tk.X, pady=(6, 0))

    def _build_export_panel(self, parent: ttk.Frame) -> None:
        box = ttk.LabelFrame(parent, text="导出", padding=6)
        box.pack(fill=tk.X)

        ttk.Button(box, text="导出 CutPPaper 字库包…", command=self._export_cutppaper).pack(fill=tk.X)
        ttk.Button(box, text="导出 PNG 预览图…", command=self._export_png).pack(fill=tk.X, pady=(4, 0))
        ttk.Button(box, text="导出二进制 + 索引…", command=self._export_binary_pack).pack(fill=tk.X, pady=(4, 0))
        ttk.Button(box, text="保存/加载预设…", command=self._preset_menu).pack(fill=tk.X, pady=(8, 0))

    def _build_preview_panel(self, parent: ttk.Frame) -> None:
        box = ttk.LabelFrame(parent, text="预览", padding=6)
        box.pack(fill=tk.X, pady=(0, 8))

        top = ttk.Frame(box)
        top.pack(fill=tk.X)
        ttk.Label(top, text="字符").pack(side=tk.LEFT)
        self.preview_char = tk.StringVar(value="切")
        ent = ttk.Entry(top, textvariable=self.preview_char, width=4, font=("Microsoft YaHei", 14))
        ent.pack(side=tk.LEFT, padx=(4, 12))
        ent.bind("<KeyRelease>", lambda _e: self._schedule_preview())

        ttk.Label(top, text="放大").pack(side=tk.LEFT)
        sc = ttk.Spinbox(
            top, from_=2, to=16, textvariable=self.preview_scale, width=5, command=self._update_preview
        )
        sc.pack(side=tk.LEFT, padx=(4, 0))
        self.preview_scale.trace_add("write", lambda *_: self._update_preview())

        panes = ttk.Frame(box)
        panes.pack(fill=tk.X, pady=(8, 0))

        col1 = ttk.Frame(panes)
        col1.pack(side=tk.LEFT, padx=(0, 16))
        ttk.Label(col1, text="LCD 效果（半宽字按 AdvW 显示）").pack()
        self.preview_label = ttk.Label(col1)
        self.preview_label.pack()

        col2 = ttk.Frame(panes)
        col2.pack(side=tk.LEFT)
        ttk.Label(col2, text="灰度源（半宽字裁切左半边）").pack()
        self.gray_label = ttk.Label(col2)
        self.gray_label.pack()

        self.preview_info = tk.StringVar(value="")
        ttk.Label(box, textvariable=self.preview_info, foreground="#333").pack(anchor=tk.W, pady=(6, 0))

    def _build_list_panel(self, parent: ttk.Frame) -> None:
        box = ttk.LabelFrame(parent, text="已生成字模", padding=6)
        box.pack(fill=tk.BOTH, expand=True)

        cols = ("idx", "char", "ink", "adv", "gb")
        self.tree = ttk.Treeview(box, columns=cols, show="headings", height=16)
        self.tree.heading("idx", text="#")
        self.tree.heading("char", text="字")
        self.tree.heading("ink", text="墨点")
        self.tree.heading("adv", text="AdvW")
        self.tree.heading("gb", text="GB2312")
        self.tree.column("idx", width=40, anchor=tk.CENTER)
        self.tree.column("char", width=50, anchor=tk.CENTER)
        self.tree.column("ink", width=50, anchor=tk.CENTER)
        self.tree.column("adv", width=44, anchor=tk.CENTER)
        self.tree.column("gb", width=72, anchor=tk.CENTER)
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.tree.bind("<<TreeviewSelect>>", self._on_tree_select)

        sb = ttk.Scrollbar(box, orient=tk.VERTICAL, command=self.tree.yview)
        sb.pack(side=tk.RIGHT, fill=tk.Y)
        self.tree.configure(yscrollcommand=sb.set)

    def _cfg(self) -> RenderConfig:
        try:
            gamma = float(self.gamma.get())
        except tk.TclError:
            gamma = 1.15
        try:
            blur_hi = float(self.blur_hi.get())
        except tk.TclError:
            blur_hi = 1.0
        try:
            sharpen_radius = float(self.sharpen_radius.get())
        except tk.TclError:
            sharpen_radius = 0.8
        return RenderConfig(
            cell_w=max(4, int(self.cell_w.get() or 16)),
            cell_h=max(4, int(self.cell_h.get() or 16)),
            super_sample=max(2, int(self.super_sample.get() or 6)),
            threshold=max(1, min(255, int(self.threshold.get() or 128))),
            font_path=self.font_path.get().strip(),
            font_index=int(self.font_index.get() or 0),
            ascii_shrink=int(self.ascii_shrink.get() or 8),
            cjk_shrink=int(self.cjk_shrink.get() or 6),
            gamma=max(0.5, min(3.0, gamma)),
            blur_hi=max(0.0, min(5.0, blur_hi)),
            sharpen_amount=max(0, min(500, int(self.sharpen_amount.get() or 0))),
            sharpen_radius=max(0.1, min(3.0, sharpen_radius)),
            sharpen_threshold=max(0, min(32, int(self.sharpen_threshold.get() or 3))),
            downscale=self.downscale.get() or "box",
            binarize=self.binarize.get() or "threshold",
        )

    def _apply_quality_preset(self, name: str) -> None:
        p = QUALITY_PRESETS.get(name)
        if not p:
            return
        self.super_sample.set(p["super_sample"])
        self.threshold.set(p["threshold"])
        self.gamma.set(p["gamma"])
        self.blur_hi.set(p["blur_hi"])
        self.sharpen_amount.set(p.get("sharpen_amount", 0))
        self.sharpen_radius.set(p.get("sharpen_radius", 0.8))
        self.sharpen_threshold.set(p.get("sharpen_threshold", 3))
        self.downscale.set(p["downscale"])
        self.binarize.set(p["binarize"])
        self._schedule_preview()
        self.status.set(f"已应用画质预设: {name}")

    def _load_defaults(self) -> None:
        cands = default_font_candidates()
        if cands:
            self.font_path.set(cands[0])
        sample = "切纸机状态压纸未连接已停止缩出杆复位串口在线离线终点步骤PaperCuttingPB83s"
        self.chars_text.insert("1.0", sample)
        self.chars_text.edit_modified(False)
        self._schedule_preview()

    def _pick_font(self) -> None:
        path = filedialog.askopenfilename(
            title="选择字体",
            filetypes=[
                ("字体", "*.ttf *.ttc *.otf"),
                ("All", "*.*"),
            ],
        )
        if path:
            self.font_path.set(path)
            self._schedule_preview()

    def _pick_system_font(self) -> None:
        cands = default_font_candidates()
        if not cands:
            messagebox.showwarning("字体", "未在 C:\\Windows\\Fonts 找到常用字体")
            return
        win = tk.Toplevel(self)
        win.title("选择系统字体")
        win.geometry("420x280")
        lb = tk.Listbox(win, font=("Consolas", 10))
        lb.pack(fill=tk.BOTH, expand=True, padx=8, pady=8)
        for p in cands:
            lb.insert(tk.END, p)

        def ok() -> None:
            sel = lb.curselection()
            if sel:
                self.font_path.set(lb.get(sel[0]))
                self._schedule_preview()
            win.destroy()

        ttk.Button(win, text="确定", command=ok).pack(pady=(0, 8))

    def _load_chars_file(self) -> None:
        path = filedialog.askopenfilename(
            title="加载字符列表",
            filetypes=[("文本", "*.txt"), ("All", "*.*")],
        )
        if not path:
            return
        raw = Path(path).read_bytes()
        for enc in ("utf-8-sig", "utf-8", "gbk", "gb2312"):
            try:
                text = raw.decode(enc)
                break
            except UnicodeDecodeError:
                continue
        else:
            messagebox.showerror("编码", "无法识别文件编码")
            return
        self.chars_text.delete("1.0", tk.END)
        self.chars_text.insert("1.0", text.strip())
        self.chars_text.edit_modified(False)

    def _on_chars_modified(self, _event: tk.Event | None = None) -> None:
        if self.chars_text.edit_modified():
            self.chars_text.edit_modified(False)

    def _char_text(self) -> str:
        return self.chars_text.get("1.0", tk.END).strip()

    def _show_char_stats(self) -> None:
        text = self._char_text()
        uniq = unique_chars(text)
        messagebox.showinfo(
            "字符统计",
            f"总字符数: {len(text.replace(chr(10), '').replace(chr(13), ''))}\n"
            f"去重后: {len(uniq)}\n"
            f"ASCII: {sum(1 for c in uniq if ord(c) < 128)}\n"
            f"中文等: {len(uniq) - sum(1 for c in uniq if ord(c) < 128)}",
        )

    def _schedule_preview(self) -> None:
        if self._debounce_id:
            self.after_cancel(self._debounce_id)
        self._debounce_id = self.after(200, self._update_preview)

    def _update_preview(self) -> None:
        self._debounce_id = None
        ch = self.preview_char.get()
        if not ch:
            return
        ch = ch[0]
        self.preview_char.set(ch)
        try:
            cfg = self._cfg()
            g = render_glyph(ch, cfg)
            scale = max(2, int(self.preview_scale.get() or 8))
            levels = max(0, int(self.aa_levels.get() or 16))
            if levels > 0:
                lcd_rgb = lcd_preview_rgb(g.gray, cfg, levels=levels, ch=ch, adv_w=g.adv_w)
            else:
                from .core import mask_to_image

                bit = mask_to_image(g.mask, cfg, 1)
                lcd_rgb = Image.new("RGB", (bit.width, bit.height), (255, 255, 255))
                lcd_rgb.paste(bit.convert("RGB"))
                if is_half_width(ch):
                    lcd_rgb = crop_glyph_display(lcd_rgb.convert("L"), cfg, ch, g.adv_w).convert("RGB")
            lcd_rgb = lcd_rgb.resize(
                (lcd_rgb.width * scale, lcd_rgb.height * scale), Image.Resampling.NEAREST
            )
            self._preview_tk = ImageTk.PhotoImage(lcd_rgb)
            self.preview_label.configure(image=self._preview_tk)

            gray_disp = crop_glyph_display(g.gray, cfg, ch, g.adv_w)
            gray = gray_disp.resize(
                (gray_disp.width * scale, gray_disp.height * scale), Image.Resampling.NEAREST
            )
            self._gray_tk = ImageTk.PhotoImage(gray.convert("RGB"))
            self.gray_label.configure(image=self._gray_tk)

            hw = "半宽占位" if is_half_width(ch) else "全宽"
            self.preview_info.set(
                f"{hw}  AdvW={g.adv_w}px  墨点={g.ink}  AA={levels}级  锐化={cfg.sharpen_amount}%"
            )
            self.status.set(f"预览: {ch!r}")
        except Exception as exc:
            self.preview_info.set(str(exc))
            self.status.set("预览失败")

    def _generate_all(self) -> None:
        text = self._char_text()
        if not text:
            messagebox.showwarning("字符集", "请先输入或加载字符")
            return
        try:
            cfg = self._cfg()
            self.status.set("正在生成…")
            self.update_idletasks()
            self._glyphs = render_all(text, cfg)
            self._refresh_tree()
            self.status.set(f"已生成 {len(self._glyphs)} 个字模")
        except Exception as exc:
            messagebox.showerror("生成失败", str(exc))
            self.status.set("生成失败")

    def _refresh_tree(self) -> None:
        from .core import char_index_bytes

        self.tree.delete(*self.tree.get_children())
        for i, g in enumerate(self._glyphs):
            idx = char_index_bytes(g.char)
            gb = f"{idx[0]:02X}{idx[1]:02X}" if ord(g.char[0]) >= 128 else f"ASCII:{idx[1]:02X}"
            self.tree.insert("", tk.END, iid=str(i), values=(i, g.char, g.ink, g.adv_w, gb))

    def _on_tree_select(self, _event: tk.Event | None = None) -> None:
        sel = self.tree.selection()
        if not sel:
            return
        i = int(sel[0])
        if 0 <= i < len(self._glyphs):
            self.preview_char.set(self._glyphs[i].char)
            self._update_preview()

    def _ensure_glyphs(self) -> bool:
        if self._glyphs:
            return True
        self._generate_all()
        return bool(self._glyphs)

    def _export_cutppaper(self) -> None:
        if not self._ensure_glyphs():
            return
        folder = filedialog.askdirectory(title="选择导出目录")
        if not folder:
            return
        out = Path(folder)
        cfg = self._cfg()
        font_label = Path(cfg.font_path).name
        aa = max(0, int(self.aa_levels.get() or 16))
        export_cutppaper_c(self._glyphs, cfg, out / "lcd_font_gb16.c", font_label, aa_levels=aa)
        export_header_stub(cfg, out / "lcd_font_gb16.h", aa_levels=aa)
        export_index_map(self._glyphs, out / "lcd-font-index-map.txt")
        export_char_order(self._glyphs, out / "lcd-font-order.txt")
        export_text_dump(self._glyphs, cfg, out / "lcd-font-preview.txt")
        messagebox.showinfo(
            "导出完成",
            f"已写入 {out}\n\n"
            "• lcd_font_gb16.c / .h\n"
            "• lcd-font-index-map.txt\n"
            "• lcd-font-order.txt\n"
            "• lcd-font-preview.txt\n\n"
            "复制 .c/.h 到 CutPPaper 的 firmware/User/ 后 Keil Rebuild。",
        )
        self.status.set(f"已导出到 {out}")

    def _export_png(self) -> None:
        if not self._ensure_glyphs():
            return
        path = filedialog.asksaveasfilename(
            title="保存 PNG",
            defaultextension=".png",
            filetypes=[("PNG", "*.png")],
        )
        if not path:
            return
        export_png_sheet(self._glyphs, self._cfg(), Path(path))
        self.status.set(f"PNG → {path}")

    def _export_binary_pack(self) -> None:
        if not self._ensure_glyphs():
            return
        folder = filedialog.askdirectory(title="选择导出目录")
        if not folder:
            return
        out = Path(folder)
        export_binary(self._glyphs, out / "glyphs.bin")
        export_index_map(self._glyphs, out / "lcd-font-index-map.txt")
        export_char_order(self._glyphs, out / "lcd-font-order.txt")
        messagebox.showinfo("导出完成", f"glyphs.bin + 索引 → {out}")
        self.status.set(f"二进制已导出到 {out}")

    def _preset_menu(self) -> None:
        menu = tk.Menu(self, tearoff=0)
        menu.add_command(label="保存预设…", command=self._save_preset)
        menu.add_command(label="加载预设…", command=self._load_preset)
        menu.tk_popup(self.winfo_pointerx(), self.winfo_pointery())

    def _preset_dict(self) -> dict:
        return {
            "font_path": self.font_path.get(),
            "font_index": self.font_index.get(),
            "cell_w": self.cell_w.get(),
            "cell_h": self.cell_h.get(),
            "super_sample": self.super_sample.get(),
            "threshold": self.threshold.get(),
            "ascii_shrink": self.ascii_shrink.get(),
            "cjk_shrink": self.cjk_shrink.get(),
            "gamma": self.gamma.get(),
            "blur_hi": self.blur_hi.get(),
            "sharpen_amount": self.sharpen_amount.get(),
            "sharpen_radius": self.sharpen_radius.get(),
            "sharpen_threshold": self.sharpen_threshold.get(),
            "downscale": self.downscale.get(),
            "binarize": self.binarize.get(),
            "aa_levels": self.aa_levels.get(),
            "chars": self._char_text(),
        }

    def _save_preset(self) -> None:
        path = filedialog.asksaveasfilename(
            title="保存预设",
            defaultextension=".json",
            filetypes=[("JSON", "*.json")],
        )
        if not path:
            return
        Path(path).write_text(json.dumps(self._preset_dict(), ensure_ascii=False, indent=2), encoding="utf-8")
        self.status.set(f"预设已保存 → {path}")

    def _load_preset(self) -> None:
        path = filedialog.askopenfilename(
            title="加载预设",
            filetypes=[("JSON", "*.json")],
        )
        if not path:
            return
        data = json.loads(Path(path).read_text(encoding="utf-8"))
        self.font_path.set(data.get("font_path", ""))
        self.font_index.set(data.get("font_index", 0))
        self.cell_w.set(data.get("cell_w", 16))
        self.cell_h.set(data.get("cell_h", 16))
        self.super_sample.set(data.get("super_sample", 6))
        self.threshold.set(data.get("threshold", 128))
        self.ascii_shrink.set(data.get("ascii_shrink", 6))
        self.cjk_shrink.set(data.get("cjk_shrink", 6))
        self.gamma.set(data.get("gamma", 1.15))
        self.blur_hi.set(data.get("blur_hi", 1.0))
        self.sharpen_amount.set(data.get("sharpen_amount", 0))
        self.sharpen_radius.set(data.get("sharpen_radius", 0.8))
        self.sharpen_threshold.set(data.get("sharpen_threshold", 3))
        self.downscale.set(data.get("downscale", "box"))
        self.binarize.set(data.get("binarize", "threshold"))
        self.aa_levels.set(data.get("aa_levels", 16))
        self.chars_text.delete("1.0", tk.END)
        self.chars_text.insert("1.0", data.get("chars", ""))
        self._glyphs = []
        self.tree.delete(*self.tree.get_children())
        self._schedule_preview()
        self.status.set(f"预设已加载 ← {path}")


def run_app() -> None:
    app = FontStudioApp()
    app.mainloop()
