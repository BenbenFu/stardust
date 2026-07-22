# -*- coding: utf-8 -*-
"""
将 9 个完整字体（_sources/ 下的 regular.woff2）子集化到
「common_chars.txt 中的真实常用汉字(G) + ASCII + 常用标点」并去掉 hinting。

子集依据 common_chars.txt（GB2312 一级字表 3755 字 = 国家《现代汉语常用字表》常用字），
可随时手动编辑该 txt 来增删裁剪范围。

每个字体在独立子进程中处理，避免内存累积 OOM。
直接运行: python runner.py  (循环 subprocess 调自己)
单字体:   python runner.py hei
"""
import sys
import os
import subprocess
from fontTools.subset import Subsetter
from fontTools.ttLib import TTFont

BASE = os.path.dirname(os.path.abspath(__file__))

# 根名 -> _sources/中文子目录/regular.woff2（完整字体源，本地保留、不入库）
SRC_MAP = {
    'hei': '_sources/黑体/regular.woff2',
    'song': '_sources/宋体/regular.woff2',
    'yuan': '_sources/圆体/regular.woff2',
    'kai': '_sources/楷体/regular.woff2',
    'mono': '_sources/等宽/regular.woff2',
    'creative': '_sources/创意/regular.woff2',
    'hand': '_sources/手写/regular.woff2',
    'calli': '_sources/书法/regular.woff2',
    'cartoon': '_sources/卡通/regular.woff2',
}
FONT_LIST = list(SRC_MAP.keys())

PUNCT = ('，。！？、；：""' + "'" + '（）《》【】…—～·〈〉「」『』'
         '〔〕〖〗％＆＃＠＄＊＋－＝／＼｜')

CHAR_FILE = os.path.join(BASE, 'common_chars.txt')


def build_text():
    chars = set()
    for i in range(32, 127):
        chars.add(chr(i))
    for c in PUNCT:
        chars.add(c)
    # 真实常用汉字：从 common_chars.txt 读取（每一行一个字）
    if os.path.exists(CHAR_FILE):
        with open(CHAR_FILE, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if line:
                    chars.add(line[0])
    else:
        raise SystemExit(f'缺少 {CHAR_FILE}，无法裁剪')
    return ''.join(sorted(chars))


def process(name):
    src_rel = SRC_MAP[name]
    src = os.path.join(BASE, src_rel)
    if not os.path.exists(src):
        print(f'{name}: 源字体缺失 {src_rel}，跳过', flush=True)
        return
    text = build_text()
    old = os.path.getsize(src)
    f = TTFont(src)
    ss = Subsetter()
    ss.options.hinting = False        # CJK 屏幕显示不需要 hinting，可减体积
    ss.options.desubroutinize = True
    ss.populate(text=text)
    ss.subset(f)
    f.flavor = 'woff2'
    out = os.path.join(BASE, name + '.woff2')
    tmp = out + '.sub.tmp'
    f.save(tmp)
    f.close()
    os.replace(tmp, out)
    new = os.path.getsize(out)
    print(f'{name}: {old/1024:.0f}KB -> {new/1024:.0f}KB '
          f'({100*(1-new/old):.0f}% 减小)', flush=True)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        process(sys.argv[1])
    else:
        py = sys.executable
        for name in FONT_LIST:
            r = subprocess.run([py, __file__, name],
                               capture_output=True, text=True)
            out = (r.stdout or r.stderr).strip()
            print(out)
        print('ALL DONE', flush=True)
