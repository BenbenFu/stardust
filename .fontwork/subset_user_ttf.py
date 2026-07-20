# -*- coding: utf-8 -*-
"""把用户下载的三个 TTF 子集化(GB2312)为 woff2，覆盖进 圆体/楷体/等宽。
运行: <venv>/python.exe subset_user_ttf.py
依赖: fonttools, brotli
"""
import os, codecs
from fontTools.ttLib import TTFont
from fontTools.subset import Subsetter, Options

ROOT = r"C:\Users\13188\Desktop\esp32-diary-display-wifi\web\font"
WORK = r"C:\Users\13188\Desktop\esp32-diary-display-wifi\.fontwork"

# (源 TTF, 目标分类文件夹)
JOBS = [
    (os.path.join(ROOT, "站酷快乐体.ttf"), os.path.join(ROOT, "圆体")),
    (os.path.join(ROOT, "LXGWWenKai-Regular.ttf"), os.path.join(ROOT, "楷体")),
    (os.path.join(ROOT, "SarasaGothicSC-Regular.ttf"), os.path.join(ROOT, "等宽")),
]

def gb2312_text():
    chars = set()
    # 完整 GB2312 双字节空间 -> Unicode
    for hi in range(0xA1, 0xF8):
        for lo in range(0xA1, 0xFF):
            try:
                chars.add(bytes([hi, lo]).decode("gb2312"))
            except Exception:
                pass
    # 显式补 Basic Latin（GB2312 的 A1 区已是全角，这里加半角 ASCII 以防万一）
    for c in range(0x20, 0x7F):
        chars.add(chr(c))
    # 常用标点/符号兜底
    for ch in "·—…“”‘’《》【】、，。：；！？（）%#&@*+=/\\|~`^<>":
        chars.add(ch)
    return "".join(sorted(chars))

def subset_ttf(src, dst_dir, text):
    out = os.path.join(dst_dir, "regular.woff2")
    opts = Options()
    opts.flavor = "woff2"
    opts.desubroutinize = True
    opts.no_hinting = True
    opts.recalc_bounds = True
    opts.drop_tables += ["DSIG"]
    ss = Subsetter(options=opts)
    ss.populate(text=text)
    f = TTFont(src)
    ss.subset(f)
    f.save(out)
    # 校验
    f2 = TTFont(out)
    cmap = f2.getBestCmap()
    cjk = [c for c in cmap if 0x4E00 <= c <= 0x9FFF]
    print("  -> %s : %d bytes, CJKglyphs=%d" % (out, os.path.getsize(out), len(cjk)))
    return out

def main():
    text = gb2312_text()
    print("GB2312 字符集大小: %d" % len(text))
    for src, dst in JOBS:
        if not os.path.exists(src):
            print("[SKIP] 源缺失: %s" % src)
            continue
        print("[处理] %s -> %s" % (os.path.basename(src), os.path.basename(dst)))
        subset_ttf(src, dst, text)
    print("完成。")

if __name__ == "__main__":
    main()
