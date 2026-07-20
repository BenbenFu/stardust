import urllib.request, os, io
from fontTools.ttLib import TTFont
from fontTools.subset import Subsetter, Options

W = r"C:\Users\13188\Desktop\esp32-diary-display-wifi\.fontwork"
OUT = r"C:\Users\13188\Desktop\esp32-diary-display-wifi\web\font"
os.makedirs(W, exist_ok=True)
UA = {'User-Agent': 'Mozilla/5.0'}

def get_bytes(url, timeout=180):
    print("GET", url)
    req = urllib.request.Request(url, headers=UA)
    return urllib.request.urlopen(req, timeout=timeout).read()

def gb2312_text():
    chars = []
    for qu in range(1, 95):
        for wei in range(1, 95):
            try:
                chars.append(bytes([0xA0+qu, 0xA0+wei]).decode('gb2312'))
            except Exception:
                pass
    chars.append(''.join(chr(c) for c in range(0x20, 0x7F)))
    chars.append(''.join(chr(c) for c in range(0x3000, 0x3040)))
    chars.append(''.join(chr(c) for c in range(0xFF00, 0xFFF0)))
    return ''.join(chars)
TEXT = gb2312_text()

def subset_ttf(src, dst):
    opts = Options(); opts.flavor='woff2'; opts.desubroutinize=True; opts.no_hinting=True
    ss = Subsetter(options=opts); ss.populate(text=TEXT)
    f = TTFont(src); ss.subset(f); f.save(dst)
    print("  ->", dst, os.path.getsize(dst), "bytes")

def place(src_woff2, cat):
    dst = os.path.join(OUT, cat, "regular.woff2")
    with open(src_woff2,'rb') as a, open(dst,'wb') as b:
        b.write(a.read())
    print("placed", cat, os.path.getsize(dst), "bytes")

# 1) fontsource woff2 (already subsetted) -> direct copy
FS = "https://cdn.jsdelivr.net/npm/@fontsource"
fs_map = {
    "宋体": ("noto-serif-sc", "noto-serif-sc-chinese-simplified-400-normal.woff2"),
    "创意": ("zcool-qingke-huangyou", "zcool-qingke-huangyou-chinese-simplified-400-normal.woff2"),
    "手写": ("zhi-mang-xing", "zhi-mang-xing-chinese-simplified-400-normal.woff2"),
    "书法": ("ma-shan-zheng", "ma-shan-zheng-chinese-simplified-400-normal.woff2"),
    "卡通": ("liu-jian-mao-cao", "liu-jian-mao-cao-chinese-simplified-400-normal.woff2"),
}
for cat,(pkg,fn) in fs_map.items():
    try:
        data = get_bytes(f"{FS}/{pkg}/files/{fn}")
        tmp = os.path.join(W, cat+".woff2")
        open(tmp,'wb').write(data)
        place(tmp, cat)
    except Exception as e:
        print("FS ERR %s: %s" % (cat, e))

# 2) 圆体 ZCOOL KuaiLe — ghproxy raw github, fallback jsdelivr gh
zk_url = "https://ghproxy.net/https://raw.githubusercontent.com/google/fonts/main/ofl/zcoolkuairle/ZCOOLKuaiLe-Regular.ttf"
zk_ttf = os.path.join(W, "zk.ttf")
try:
    data = get_bytes(zk_url)
    open(zk_ttf,'wb').write(data)
    print("圆体 TTF downloaded", len(data))
    subset_ttf(zk_ttf, os.path.join(OUT,"圆体","regular.woff2"))
except Exception as e:
    print("圆体 ghproxy ERR", e)
    try:
        data = get_bytes("https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/zcoolkuairle/ZCOOLKuaiLe-Regular.ttf")
        open(zk_ttf,'wb').write(data)
        subset_ttf(zk_ttf, os.path.join(OUT,"圆体","regular.woff2"))
    except Exception as e2:
        print("圆体 fallback ERR", e2)

# 3) 楷体 LXGW WenKai Screen TTF -> subset
lxgw_url = "https://github.com/lxgw/LxgwWenKai-Screen/releases/download/v1.522/LXGWWenKaiScreen.ttf"
lxgw_ttf = os.path.join(W, "lxgw.ttf")
try:
    data = get_bytes(lxgw_url)
    open(lxgw_ttf,'wb').write(data)
    print("楷体 TTF downloaded", len(data))
    subset_ttf(lxgw_ttf, os.path.join(OUT,"楷体","regular.woff2"))
except Exception as e:
    print("楷体 ERR", e)

# 4) 等宽 SarasaFixedSC 7z -> extract -> subset
sar_url = "https://github.com/be5invis/Sarasa-Gothic/releases/download/v1.0.40/SarasaFixedSC-TTF-1.0.40.7z"
sar_7z = os.path.join(W, "sarasa.7z")
try:
    data = get_bytes(sar_url)
    open(sar_7z,'wb').write(data)
    print("Sarasa 7z downloaded", len(data))
    import py7zr
    with py7zr.SevenZipFile(sar_7z, 'r') as z:
        names = z.getnames()
        target = [n for n in names if n.lower().endswith("sarasa-fixed-sc-regular.ttf")]
        print("archive entries matching:", target)
        if not target:
            target = [n for n in names if "fixed-sc" in n.lower() and n.lower().endswith(".ttf")]
        if target:
            z.extract(path=W, targets=[target[0]])
            ttf_path = os.path.join(W, target[0])
            print("extracted", ttf_path, os.path.getsize(ttf_path))
            subset_ttf(ttf_path, os.path.join(OUT,"等宽","regular.woff2"))
        else:
            print("Sarasa: no fixed-sc ttf found in archive")
except Exception as e:
    import traceback; traceback.print_exc()
    print("等宽 ERR", e)

print("ALL DONE")
