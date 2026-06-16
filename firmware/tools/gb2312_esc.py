#!/usr/bin/env python3
strings = [
    "缩回位", "未到位", "停止", "缩回", "伸出", "在线", "离线",
    "在缩回终点", "未在缩回位", "切纸", "杆位", "电机", "串口", "你好", "屏就绪",
]
for s in strings:
    b = s.encode("gb2312")
    esc = "".join("\\x%02X" % x for x in b)
    print(f"{s}: \"{esc}\"")
