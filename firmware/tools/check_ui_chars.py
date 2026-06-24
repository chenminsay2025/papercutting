order = open(r"h:\PaperCutting-backup-20260618\docs\lcd-fon-order.txt", encoding="utf-8").read()
ui = "下中串他件伸位作你信停其出切到割动压发口器回在好始完就屏已开弹待态成执拟按接未机杆条模止步活激点状用电确离空窗第等纸线组终继绪缩行认调轮运连送通键闲骤"
lines = []
for c in ui:
    if c in order:
        lines.append(f"{c}\t{order.index(c)}\tOK")
    else:
        lines.append(f"{c}\t-\tMISSING")
open(r"h:\PaperCutting-backup-20260618\docs\ui-char-lookup.txt", "w", encoding="utf-8").write("\n".join(lines))
print("hits", sum(1 for c in ui if c in order), "/", len(ui))
