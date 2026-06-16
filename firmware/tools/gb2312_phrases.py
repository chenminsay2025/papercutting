#!/usr/bin/env python3
phrases = [
    "切纸机状态", "压纸", "压纸中", "未压纸", "连接", "已连接", "未连接",
    "电机", "停止", "缩回", "伸出",
]
for p in phrases:
    b = p.encode("gb2312")
    esc = "".join("\\x%02X" % x for x in b)
    print(f"{p}: \"{esc}\"")
