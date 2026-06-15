function toElectronAccelerator(hotkey) {
  const raw = String(hotkey || "").trim().toLowerCase();
  if (!raw) return "";

  return raw
    .split("+")
    .map((part) => {
      const token = part.trim().toLowerCase();
      if (!token) return "";
      if (token === "ctrl" || token === "control") return "Ctrl";
      if (token === "alt") return "Alt";
      if (token === "shift") return "Shift";
      if (token === "windows" || token === "win" || token === "meta" || token === "super") return "Super";
      if (token === "enter") return "Enter";
      if (token === "esc" || token === "escape") return "Esc";
      if (token === "space") return "Space";
      if (token === "tab") return "Tab";
      if (token === "delete") return "Delete";
      if (token === "backspace") return "Backspace";
      if (token === "home") return "Home";
      if (token === "end") return "End";
      if (token === "insert") return "Insert";
      if (token === "page up" || token === "pageup") return "PageUp";
      if (token === "page down" || token === "pagedown") return "PageDown";
      if (token === "up") return "Up";
      if (token === "down") return "Down";
      if (token === "left") return "Left";
      if (token === "right") return "Right";
      if (/^f\d+$/.test(token)) return token.toUpperCase();
      if (token.length === 1) return token.toUpperCase();
      return part.trim();
    })
    .filter(Boolean)
    .join("+");
}

module.exports = {
  toElectronAccelerator,
};
