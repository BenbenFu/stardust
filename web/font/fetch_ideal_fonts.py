#!/usr/bin/env python3
# ============================================================
# fetch_ideal_fonts.py — 把 3 个占位字体换成「理想字体」
# ------------------------------------------------------------
# 适用：在【你自己的机器】上运行（沙箱/CI 可能因网络封锁 GitHub
#       发布二进制而失败；本机通常可正常下载）。
# 作用：下载 ZCOOL KuaiLe(圆体) / LXGW WenKai(楷体) /
#       SarasaFixedSC(等宽)，子集化到 GB2312 woff2，写入对应
#       文件夹，并自动自增 fonts.css 的 ?v= 版本号防缓存。
#
# 依赖安装（一次性）：
#   pip install fonttools brotli py7zr
#
# 运行：
#   python fetch_ideal_fonts.py
# ============================================================
import os, re, urllib.request, io

HERE = os.path.dirname(os.path.abspath(__file__))
OUT  = HERE  # web/font/ 本身

UA = {'User-Agent': 'Mozilla/5.0'}

def get(url, timeout=300):
    print("GET", url)
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout).read()

def gb2312_text():
    cs = []
    for qu in range(1, 95):
        for wei in range(1, 95):
            try: cs.append(bytes([0xA0+qu, 0xA0+wei]).decode('gb2312'))
            except Exception: pass
    cs.append(''.join(chr(c) for c in range(0x20, 0x7F)))
    cs.append(''.join(chr(c) for c in range(0x3000, 0x3040)))
    cs.append(''.join(chr(c) for c in range(0xFF00, 0xFFF0)))
    return ''.join(cs)
TEXT = gb2312_text()

def subset(src, dst):
    from fontTools.ttLib import TTFont
    from fontTools.subset import Subsetter, Options
    o = Options(); o.flavor='woff2'; o.desubroutinize=True; o.no_hinting=True
    ss = Subsetter(options=o); ss.populate(text=TEXT)
    f = TTFont(src); ss.subset(f); f.save(dst)
    print("  ->", dst, os.path.getsize(dst), "bytes")

def bump_version():
    css = os.path.join(OUT, "fonts.css")
    s = open(css, encoding='utf-8').read()
    m = re.search(r'\?v=(\w+)', s)
    if m:
        old = m.group(1)
        # 递增最后一段（如 20260720b -> 20260720c）
        base = re.match(r'(.*[^\d])?(\d+)([a-z]?)$', old)
        if base:
            pre, num, suf = base.group(1) or '', base.group(2), base.group(3) or 'a'
            nxt = chr(ord(suf)+1) if suf else 'b'
            new = pre + num + nxt
        else:
            new = old + 'x'
        s2 = s.replace('?v='+old, '?v='+new)
        open(css, 'w', encoding='utf-8').write(s2)
        print("fonts.css version bumped:", old, "->", new)
    else:
        print("未找到版本号，跳过 bump（手动硬刷新即可）")

# ---- 1) 圆体: ZCOOL KuaiLe ----
print("\n=== 圆体: ZCOOL KuaiLe ===")
try:
    d = get("https://raw.githubusercontent.com/google/fonts/main/ofl/zcoolkuairle/ZCOOLKuaiLe-Regular.ttf")
    tmp = os.path.join(OUT, "_zk.ttf"); open(tmp,'wb').write(d)
    subset(tmp, os.path.join(OUT, "圆体", "regular.woff2"))
    os.remove(tmp)
except Exception as e:
    print("圆体下载失败（检查网络/代理）:", e)

# ---- 2) 楷体: LXGW WenKai Screen ----
print("\n=== 楷体: LXGW WenKai (Screen) ===")
try:
    d = get("https://github.com/lxgw/LxgwWenKai-Screen/releases/download/v1.522/LXGWWenKaiScreen.ttf")
    tmp = os.path.join(OUT, "_lxgw.ttf"); open(tmp,'wb').write(d)
    subset(tmp, os.path.join(OUT, "楷体", "regular.woff2"))
    os.remove(tmp)
except Exception as e:
    print("楷体下载失败（检查网络/代理）:", e)

# ---- 3) 等宽: SarasaFixedSC ----
print("\n=== 等宽: SarasaFixedSC (等距更纱黑体) ===")
try:
    d = get("https://github.com/be5invis/Sarasa-Gothic/releases/download/v1.0.40/SarasaFixedSC-TTF-1.0.40.7z")
    zp = os.path.join(OUT, "_sarasa.7z"); open(zp,'wb').write(d)
    import py7zr
    with py7zr.SevenZipFile(zp, 'r') as z:
        names = z.getnames()
        tgt = [n for n in names if n.lower().endswith("sarasa-fixed-sc-regular.ttf")] \
           or [n for n in names if "fixed-sc" in n.lower() and n.lower().endswith(".ttf")]
        if not tgt:
            raise RuntimeError("压缩包内未找到 sarasa-fixed-sc-regular.ttf，实际条目：" + str(names[:10]))
        z.extract(path=OUT, targets=[tgt[0]])
        tp = os.path.join(OUT, tgt[0])
        subset(tp, os.path.join(OUT, "等宽", "regular.woff2"))
        os.remove(tp); os.remove(zp)
except Exception as e:
    print("等宽下载/解压失败（检查网络/代理，或手动下载后子集化）:", e)

bump_version()
print("\n完成。请硬刷新预览页/画廊页（Ctrl+Shift+R）查看效果。")
