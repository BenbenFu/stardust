#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
解析 STYLE_POOL_rows.csv，提取含 card_css 的记录，
将 CSS 反向解析为 style_json 格式，输出 SQL UPDATE 语句。
"""

import csv
import json
import re
import sys

# ============================================================
# 1. 读取 CSV
# ============================================================
INPUT = r'C:\Users\13188\Desktop\esp32-diary-display-wifi\web\STYLE_POOL_rows.csv'

rows = []
with open(INPUT, 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    for row in reader:
        rows.append(row)

print(f"共读取 {len(rows)} 条记录")

# ============================================================
# 2. 提取含 card_css 的记录
# ============================================================
HAS_CSS = [r for r in rows if r.get('card_css', '').strip()]

print(f"其中 {len(HAS_CSS)} 条含 card_css：")
for r in HAS_CSS:
    print(f"  id={r['id']}  name={r['name']}")

# ============================================================
# 3. CSS → style_json 反向解析
# ============================================================

# PALETTE 颜色 → palette key 映射（与 style-engine.js 的 PALETTES 对应）
COLOR_TO_PALETTE = {
    '#1e1e1e': 'industrial',
    '#ffffff': 'industrial',  # 白底变体
    '#007acc': 'industrial',
    '#1e293b': 'industrial',  # SQL 深蓝灰
    '#fdf8ec': 'warm',
    '#fffdf7': 'warm',
    '#fff9e6': 'warm',
    '#f5f1e6': 'warm',
    '#f5f7fa': 'industrial',
    '#0b0e11': 'industrial',
    '#f5f5f5': 'industrial',
}

def detect_palette(css):
    """根据 CSS 中的背景色判断 palette（准确版）"""
    # 收集所有 background/border 颜色
    colors = re.findall(r'background(?:-color)?:\s*([#\w][^\s;]*)', css, re.I)
    border_colors = re.findall(r'border(?:-color)?:\s*([#\w][^\s;]*)', css, re.I)
    all_colors = colors + border_colors

    # 判定规则：采样第一个颜色，判断明暗
    for c in all_colors:
        c = c.strip().lower()
        # 深色背景 → industrial
        if c in ('#1e1e1e', '#0b0e11', '#1e293b', '#1e2622', '#121212', '#0d1117'):
            return 'industrial'
        if c.startswith('#') and len(c) == 7:
            try:
                r = int(c[1:3], 16)
                g = int(c[3:5], 16)
                b = int(c[5:7], 16)
                brightness = (r + g + b) / 3
                if brightness < 60:
                    return 'industrial'
                else:
                    return 'warm'
            except:
                pass
        if 'rgba(0,' in css or 'rgba(30,' in css:
            # 深色半透明 → industrial
            if 'rgba(0,0,0' in css or 'rgba(30,38,34' in css:
                return 'industrial'
            return 'warm'

    #  fallback：检查是否有明显深色特征
    if 'inset' in css and '0 0 30px' in css:
        return 'industrial'  # 深色 inset shadow 特征
    if '#ffffff' in css or '#fff' in css:
        return 'warm'
    return 'warm'  # 默认暖白


def detect_layout(css, name):
    """根据 CSS 伪元素和内容判断 layout"""
    has_before_gallery = 'gallery-card::before' in css
    has_after_gallery = 'gallery-card::after' in css
    has_title_before = '.card-title::before' in css
    has_title_after = '.card-title::after' in css
    has_date_before = '.card-date::before' in css
    has_hl_before = '.card-highlight-item::before' in css
    has_hl_after = '.card-highlight-item::after' in css
    has_hl_sep = '.hl-sep' in css
    has_no_highlight = '.card-no-highlight' in css
    has_style_before = '.card-style::before' in css

    # 判断 top：只检查 ::before 的 content，而非整个 CSS
    top = 'title_only'
    if has_before_gallery:
        # 提取 ::before 的 content 值
        before_content = ''
        m = re.search(r'gallery-card::before\s*\{[^}]*content:\s*["\']([^"\']*)["\']', css, re.I)
        if m:
            before_content = m.group(1).lower()

        # 只根据 ::before 内容判断是否像代码
        code_indicators = ['#include', '<?xml', '.diary', '> const', 'select ', 'insert ',
                           'delete ', 'update ', 'query time', 'no. ', '编号', '日常事务']
        # 保守判断：content 里包含代码特征才认为是 code_header
        if before_content:
            if any(kw in before_content.lower() for kw in ['#include', '<?xml', '.diary', '> const', '-- ']):
                top = 'code_header'
            elif before_content and len(before_content) > 3:
                # 有 ::before 但没有明显代码特征 → 可能是 banner 类
                top = 'title_only'
        else:
            # ::before 存在但没提取到 content → 检查 CSS 注释里的线索
            if 'include' in css.lower() and '#include' in css:
                top = 'code_header'
            elif '<?xml' in css:
                top = 'code_header'

    # 判断 body
    if has_hl_before and has_hl_after:
        body = 'highlight_list'
    elif has_no_highlight:
        body = 'highlight_list'
    else:
        body = 'highlight_list'

    # 判断 bottom
    if has_style_before:
        bottom = 'meta_line'
    else:
        bottom = 'meta_line'

    # 判断 side
    side = 'none'
    if 'margin-left: 48px' in css or 'avatar' in css:
        side = 'avatar_left'

    # 判断 overlay
    overlay = 'none'
    if has_after_gallery:
        overlay = 'none'

    return {'top': top, 'body': body, 'bottom': bottom, 'side': side, 'overlay': overlay}


def detect_typo(css):
    """根据 CSS 检测字体设置"""
    if 'Consolas' in css or 'monospace' in css:
        if 'FangSong' in css or 'SimSun' in css:
            return {'title': 'serif', 'date': 'mono', 'body': 'serif'}
        return {'title': 'mono', 'date': 'mono', 'body': 'mono'}
    if 'PingFang' in css or 'Microsoft YaHei' in css:
        return {'title': 'sans', 'date': 'sans', 'body': 'sans'}
    if 'STKaiti' in css or 'KaiTi' in css:
        return {'title': 'serif', 'date': 'serif', 'body': 'serif'}
    return {'title': 'default', 'date': 'default', 'body': 'default'}


def detect_border(css):
    """检测边框样式"""
    if 'border:' in css or 'border:' in css:
        if '1px solid' in css:
            style = 'solid'
        elif 'outline:' in css:
            style = 'double'
        else:
            style = 'none'
    else:
        style = 'none'

    accent = 'border-color' in css or 'var(--card-accent)' in css
    return {'style': style, 'accent': accent}


def detect_deco(css, name):
    """检测装饰元素"""
    title_deco = 'none'
    if 'card-title::before' in css or 'card-title::after' in css:
        title_deco = 'prefix_suffix'

    separator = 'none'
    if '.hl-sep::before' in css or '.hl-sep' in css:
        if 'display: none' not in css or '.hl-sep { display: none' not in css:
            separator = 'text_line'

    footer = 'none'
    if '.card-style::before' in css:
        footer = 'capsule_name'

    return {'title': title_deco, 'separator': separator, 'footer': footer}


def detect_effect(css):
    """检测悬停和动画效果"""
    hover = 'none'
    if ':hover' in css:
        if 'box-shadow' in css and 'hover' in css:
            hover = 'lift'
        else:
            hover = 'none'

    animation = 'none'
    if 'transform: rotate' in css:
        animation = 'tilt'
    if 'clip-path' in css:
        animation = 'ecg_wave'

    return {'hover': hover, 'animation': animation}


def css_to_style_json(css, name, category):
    """将 CSS 字符串转换为 style_json 字典"""
    palette = detect_palette(css)
    layout = detect_layout(css, name)
    typo = detect_typo(css)
    border = detect_border(css)
    deco = detect_deco(css, name)
    effect = detect_effect(css)

    return {
        'layout': layout,
        'palette': palette,
        'typo': typo,
        'border': border,
        'deco': deco,
        'effect': effect,
        '_comment': f'由 {name} 的 card_css 反向解析生成'
    }


# ============================================================
# 4. 生成 style_json 并输出 SQL
# ============================================================
print("\n" + "=" * 60)
print("生成 style_json：")
print("=" * 60)

sql_lines = []
for row in HAS_CSS:
    rid = row['id']
    name = row['name']
    css = row['card_css'].strip()

    if not css:
        continue

    style_json = css_to_style_json(css, name, row.get('category', ''))

    # 输出预览
    print(f"\n--- id={rid}  {name} ---")
    print(json.dumps(style_json, ensure_ascii=False, indent=2))

    # 生成 SQL
    json_str = json.dumps(style_json, ensure_ascii=False)
    # SQL 中的单引号需要转义
    json_str_sql = json_str.replace("'", "''")
    sql = f"UPDATE STYLE_POOL SET style_json = '{json_str_sql}'::jsonb WHERE id = {rid};"
    sql_lines.append(sql)

# 输出 SQL 文件
OUTPUT_SQL = r'C:\Users\13188\Desktop\esp32-diary-display-wifi\web\update_style_json.sql'
with open(OUTPUT_SQL, 'w', encoding='utf-8') as f:
    f.write('-- 由 parse_style_pool.py 自动生成\n')
    f.write('-- 将 card_css 反向解析为 style_json\n\n')
    for sql in sql_lines:
        f.write(sql + '\n')

print(f"\nSQL 已写入：{OUTPUT_SQL}")
print(f"共 {len(sql_lines)} 条 UPDATE 语句")
