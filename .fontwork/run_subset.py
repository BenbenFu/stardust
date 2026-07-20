import urllib.request, os, sys
from fontTools.ttLib import TTFont
from fontTools.subset import Subsetter, Options

WORK = r"C:\Users\13188\Desktop\esp32-diary-display-wifi\.fontwork"
OUT  = r"C:\Users\13188\Desktop\esp32-diary-display-wifi\web\font"
os.makedirs(WORK, exist_ok=True)
os.makedirs(OUT, exist_ok=True)

UA = {'User-Agent': 'Mozilla/5.0'}

# (category, source_ttf_url, out_family_folder)
GOOGLE = [
    ("黑体", "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/notosanssc/NotoSansSC%5Bwght%5D.ttf", "黑体"),
    ("宋体", "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/notoserifsc/NotoSerifSC%5Bwght%5D.ttf", "宋体"),
    ("圆体", "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/zcoolkuairle/ZCOOLKuaiLe-Regular.ttf", "圆体"),
    ("创意", "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/zcoolqingkehuangyou/ZCOOLQingKeHuangYou-Regular.ttf", "创意"),
    ("手写", "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/zhimangxing/ZhiMangXing-Regular.ttf", "手写"),
    ("书法", "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/mashanzheng/MaShanZheng-Regular.ttf", "书法"),
    ("卡通", "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/liujianmaocao/LiuJianMaoCao-Regular.ttf", "卡通"),
]

def gb2312_text():
    chars = []
    for qu in range(1, 95):
        for wei in range(1, 95):
            try:
                chars.append(bytes([0xA0+qu, 0xA0+wei]).decode('gb2312'))
            except Exception:
                pass
    chars.append(''.join(chr(c) for c in range(0x20, 0x7F)))
    # 常见全角标点
    chars.append(''.join(chr(c) for c in range(0x3000, 0x3040)))
    chars.append(''.join(chr(c) for c in range(0xFF00, 0xFFF0)))
    return ''.join(chars)

TEXT = gb2312_text()

def download(url, dest):
    if os.path.exists(dest) and os.path.getsize(dest) > 1000:
        print("  [cached] %s" % dest); return True
    print("  downloading %s" % url)
    req = urllib.request.Request(url, headers=UA)
    data = urllib.request.urlopen(req, timeout=120).read()
    with open(dest, 'wb') as f:
        f.write(data)
    print("  -> %d bytes" % len(data))
    return True

def subset(src_ttf, dst_woff2):
    opts = Options()
    opts.flavor = 'woff2'
    opts.desubroutinize = True
    opts.no_hinting = True
    opts.recalc_bounds = True
    ss = Subsetter(options=opts)
    ss.populate(text=TEXT)
    font = TTFont(src_ttf)
    ss.subset(font)
    font.save(dst_woff2)
    print("  subset -> %s (%d bytes)" % (dst_woff2, os.path.getsize(dst_woff2)))

for cat, url, folder in GOOGLE:
    print("=== %s ===" % cat)
    ttf = os.path.join(WORK, cat + ".ttf")
    try:
        download(url, ttf)
        dst = os.path.join(OUT, folder, "regular.woff2")
        subset(ttf, dst)
    except Exception as e:
        print("  ERROR %s: %s" % (cat, e))
print("DONE google batch")
