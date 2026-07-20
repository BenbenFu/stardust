import urllib.request, os, sys, io
from fontTools.ttLib import TTFont
from fontTools.subset import Subsetter, Options
W = r"C:\Users\13188\Desktop\esp32-diary-display-wifi\.fontwork"
OUT = r"C:\Users\13188\Desktop\esp32-diary-display-wifi\web\font"
UA = {'User-Agent': 'Mozilla/5.0'}
def log(*a):
    print(*a, flush=True)
def get_bytes(url, timeout=240):
    log("GET", url)
    req = urllib.request.Request(url, headers=UA)
    return urllib.request.urlopen(req, timeout=timeout).read()
def gb2312_text():
    cs=[]
    for qu in range(1,95):
        for wei in range(1,95):
            try: cs.append(bytes([0xA0+qu,0xA0+wei]).decode('gb2312'))
            except: pass
    cs.append(''.join(chr(c) for c in range(0x20,0x7F)))
    cs.append(''.join(chr(c) for c in range(0x3000,0x3040)))
    cs.append(''.join(chr(c) for c in range(0xFF00,0xFFF0)))
    return ''.join(cs)
TEXT=gb2312_text()
def subset_ttf(src,dst):
    o=Options(); o.flavor='woff2'; o.desubroutinize=True; o.no_hinting=True
    ss=Subsetter(options=o); ss.populate(text=TEXT)
    f=TTFont(src); ss.subset(f); f.save(dst)
    log("  subset ->", dst, os.path.getsize(dst))

# 圆体
log("=== 圆体 ZCOOL KuaiLe ===")
zk=os.path.join(W,"zk.ttf")
ok=False
for url in [
  "https://ghproxy.net/https://raw.githubusercontent.com/google/fonts/main/ofl/zcoolkuairle/ZCOOLKuaiLe-Regular.ttf",
  "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/zcoolkuairle/ZCOOLKuaiLe-Regular.ttf",
  "https://raw.gitmirror.com/google/fonts/main/ofl/zcoolkuairle/ZCOOLKuaiLe-Regular.ttf",
]:
    try:
        d=get_bytes(url); open(zk,'wb').write(d); log("  downloaded", len(d)); ok=True; break
    except Exception as e:
        log("  fail", url, "->", e)
if ok:
    try: subset_ttf(zk, os.path.join(OUT,"圆体","regular.woff2"))
    except Exception as e: log("  圆体 subset err", e)
else:
    log("  圆体: all sources failed")

# 楷体
log("=== 楷体 LXGW WenKai Screen ===")
lx=os.path.join(W,"lxgw.ttf")
try:
    d=get_bytes("https://github.com/lxgw/LxgwWenKai-Screen/releases/download/v1.522/LXGWWenKaiScreen.ttf")
    open(lx,'wb').write(d); log("  downloaded", len(d))
    subset_ttf(lx, os.path.join(OUT,"楷体","regular.woff2"))
except Exception as e:
    import traceback; log("  楷体 err"); traceback.print_exc()

# 等宽
log("=== 等宽 SarasaFixedSC ===")
sa=os.path.join(W,"sarasa.7z")
try:
    d=get_bytes("https://github.com/be5invis/Sarasa-Gothic/releases/download/v1.0.40/SarasaFixedSC-TTF-1.0.40.7z")
    open(sa,'wb').write(d); log("  downloaded", len(d))
    import py7zr
    with py7zr.SevenZipFile(sa,'r') as z:
        names=z.getnames()
        tgt=[n for n in names if n.lower().endswith("sarasa-fixed-sc-regular.ttf")] or [n for n in names if "fixed-sc" in n.lower() and n.lower().endswith(".ttf")]
        log("  target:", tgt)
        if tgt:
            z.extract(path=W, targets=[tgt[0]])
            tp=os.path.join(W, tgt[0]); log("  extracted", tp, os.path.getsize(tp))
            subset_ttf(tp, os.path.join(OUT,"等宽","regular.woff2"))
        else:
            log("  no fixed-sc ttf in archive; entries sample:", names[:10])
except Exception as e:
    import traceback; log("  等宽 err"); traceback.print_exc()
log("DIAG DONE")
