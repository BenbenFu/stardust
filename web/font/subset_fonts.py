#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
字体裁剪脚本
chars.txt只存中文，基础字符集自动补齐
"""
import os
import sys
import tempfile
from pathlib import Path
from fontTools.subset import main as subset_main

# ===== 基础字符集（一次配好，不用动）=====
BASE_CHARS = set()
# ASCII可打印字符（32=空格，33-126=!到~）
for i in range(32, 127):
    BASE_CHARS.add(chr(i))

# 常用中文标点（和裁剪1对齐，不够自己加）
PUNCT = ('，。！？、；：""' + "'" + '（）《》【】…—～·〈〉「」『』〔〕〖〗％＆＃＠＄＊＋－＝／＼｜')
for c in PUNCT:
    BASE_CHARS.add(c)

def get_font_files(directory: Path):
    """获取目录中所有ttf/otf字体文件"""
    return [p for p in directory.iterdir() 
            if p.suffix.lower() in (".ttf", ".otf") and p.is_file()]

def read_chars(chars_file: Path):
    """读取中文字符并去重，只过滤控制字符"""
    with open(chars_file, "r", encoding="utf-8") as f:
        raw = f.read()
    # 只去掉换行回车tab，保留空格（虽然基础集也有兜底）
    filtered = [c for c in raw if c not in ('\n', '\r', '\t')]
    # 去重保持顺序
    seen, result = set(), []
    for c in filtered:
        if c not in seen:
            seen.add(c)
            result.append(c)
    return "".join(result)

def subset_font(input_font: Path, chars: str, output_dir: Path):
    """裁剪单个字体，临时文件规避参数转义问题"""
    base_name = input_font.stem
    output_file = output_dir / f"{base_name}.woff2"

    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", delete=False, suffix=".txt") as tmpf:
        tmpf.write(chars)
        tmp_path = Path(tmpf.name)
    
    try:
        args = [
            str(input_font),
            f"--text-file={tmp_path}",
            f"--output-file={output_file}",
            "--flavor=woff2",
            "--no-hinting",
            "--desubroutinize",
	    "--layout-features=''",
        ]
        subset_main(args)

        if output_file.exists() and output_file.stat().st_size > 100:
            size_mb = output_file.stat().st_size / (1024 * 1024)
            print(f"✓ {input_font.name} -> {output_file.name} ({size_mb:.2f} MB)")
            return True
        else:
            print(f"✗ {input_font.name} - 输出文件异常或过小")
            return False
    except Exception as e:
        print(f"✗ {input_font.name} - {e}")
        return False
    finally:
        if tmp_path.exists():
            tmp_path.unlink()

def main():
    current_dir = Path(__file__).parent
    chars_file = current_dir / "chars.txt"

    if not chars_file.exists():
        print(f"错误: 找不到 {chars_file.resolve()}")
        sys.exit(1)

    chinese_chars = read_chars(chars_file)
    if not chinese_chars:
        print("错误：chars.txt 有效字符为空！")
        sys.exit(1)
    
    # 合并基础字符集 + 中文，去重
    all_chars_set = BASE_CHARS.copy()
    all_chars_set.update(chinese_chars)
    chars = ''.join(sorted(all_chars_set))
    
    print(f"中文字符: {len(chinese_chars)} 个")
    print(f"合并基础字符集后总计: {len(chars)} 个字符")

    font_files = get_font_files(current_dir)
    print(f"找到 {len(font_files)} 个字体文件")
    if not font_files:
        print("当前目录未发现 .ttf/.otf 字体")
        return

    output_dir = current_dir / "output"
    output_dir.mkdir(exist_ok=True)

    success_count = sum(1 for f in font_files if subset_font(f, chars, output_dir))
    print(f"\n完成! 成功 {success_count}/{len(font_files)}")
    print(f"输出目录: {output_dir.resolve()}")

if __name__ == '__main__':
    main()