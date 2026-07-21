# -*- coding: utf-8 -*-
"""
将 9 个 woff2 子集化到「GB2312 一级字前 2000 个 + ASCII + 常用标点」并去掉 hinting。
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

FONT_LIST = ['hei', 'song', 'yuan', 'kai', 'mono', 'creative', 'hand', 'calli', 'cartoon']


def build_text():
    chars = set()
    for i in range(32, 127):
        chars.add(chr(i))
    punct = ('，。！？、；：""' + "'" + '（）《》【】…—～·〈〉「」『』'
             '〔〕〖〗％＆＃＠＄＊＋－＝／＼｜')
    for c in punct:
        chars.add(c)
    # GB2312 一级字（3755）取前 2000
    gb = []
    for q in range(16, 56):
        for w in range(1, 95):
            try:
                gb.append(bytes([0xA0 + q, 0xA0 + w]).decode('gb2312'))
            except Exception:
                pass
    for c in gb[:2000]:
        chars.add(c)
    return ''.join(sorted(chars))


def process(name):
    text = build_text()
    src = os.path.join(BASE, name + '.woff2')
    old = os.path.getsize(src)
    f = TTFont(src)
    ss = Subsetter()
    ss.options.hinting = False        # CJK 屏幕显示不需要 hinting，可减体积
    ss.options.desubroutinize = True
    ss.populate(text=text)
    ss.subset(f)
    f.flavor = 'woff2'
    tmp = os.path.join(BASE, name + '.sub.woff2')
    f.save(tmp)
    f.close()
    os.replace(tmp, src)
    new = os.path.getsize(src)
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
