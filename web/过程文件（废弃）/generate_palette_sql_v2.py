import sys

palettes = [
    {"v":"industrial",       "l":"工业灰",       "bg":"transparent",      "t":"#1e2622","a":"#1e2622","m":"#707a65","ar":"30,38,34",   "br":"0,0,0",       "d":"工业终端默认灰，低饱和冷灰色调",               "s":10},
    {"v":"repair_yellow",    "l":"维修黄",       "bg":"#d2c89f",         "t":"#403d30","a":"#615a42","m":"#837b5a","ar":"97,90,66",    "br":"210,200,159","d":"维修手册风格，暖黄纸张底色",               "s":11},
    {"v":"printer_green",    "l":"打印机绿",     "bg":"#e5ebda",         "t":"#1e2622","a":"#8a8f7c","m":"#8a8f7c","ar":"138,143,124","br":"229,235,218","d":"点阵打印机输出风格，淡绿护眼底色",           "s":12},
    {"v":"bsod_blue",       "l":"蓝屏蓝",       "bg":"#1e2669",         "t":"#cadbb7","a":"#4a5d8f","m":"#7f86ba","ar":"74,93,143",   "br":"30,38,105",   "d":"Windows 蓝屏死机风格",                    "s":13},
    {"v":"alert_red",        "l":"警报红",       "bg":"transparent",      "t":"#8f341d","a":"#8f341d","m":"#8f341d","ar":"143,52,29",   "br":"0,0,0",       "d":"红色警报风格，透明底红字",                 "s":14},
    {"v":"terminal_black",   "l":"终端黑",       "bg":"#0b0c0a",         "t":"#707a65","a":"#1e2622","m":"#43473b","ar":"30,38,34",    "br":"11,12,10",    "d":"Linux 终端默认黑白风",                   "s":15},
    {"v":"vscode_dark",     "l":"VS Code 暗色",  "bg":"#0f1419",         "t":"#cadbb7","a":"#3a7d44","m":"#858585","ar":"58,125,68",   "br":"15,20,25",    "d":"VS Code 深色主题风格",                  "s":16},
    {"v":"archive_khaki",   "l":"档案卡其",     "bg":"#f0f2eb",         "t":"#1e2622","a":"#8a8f7c","m":"#5a6352","ar":"138,143,124","br":"240,242,235","d":"档案袋卡片风格，卡其底色",                 "s":17},
    {"v":"github_light",     "l":"GitHub 亮色",  "bg":"#ffffff",         "t":"#2d333b","a":"#d1d9e0","m":"#656d76","ar":"209,217,224","br":"255,255,255","d":"GitHub 亮色 Issues 风格",                "s":18},
    {"v":"diary_cream",     "l":"日记奶油",     "bg":"#faf7e8",         "t":"#4a453d","a":"#c9c2b0","m":"#9a9385","ar":"201,194,176","br":"250,247,232","d":"手账日记风格，奶油暖白底色",               "s":19},
    {"v":"twitter_light",    "l":"Twitter 亮色",  "bg":"#ffffff",         "t":"#14171a","a":"#e6ecf0","m":"#657786","ar":"230,236,240","br":"255,255,255","d":"Twitter/X 亮色发帖风格",               "s":20},
    {"v":"notebook_white",   "l":"笔记本白",     "bg":"#fffef5",         "t":"#2c2c2c","a":"#e0d9c8","m":"#8a8273","ar":"224,217,200","br":"255,254,245","d":"横线笔记本纸张风格",                     "s":21},
    {"v":"newspaper",        "l":"报纸灰",       "bg":"#ffffff",         "t":"#000000","a":"#cccccc","m":"#999999","ar":"204,204,204","br":"255,255,255","d":"报纸印刷风格，纯白底黑字",                 "s":22},
    {"v":"role_parchment",   "l":"羊皮纸",       "bg":"#f5f0e6",         "t":"#3d3529","a":"#8b7355","m":"#6b5a45","ar":"139,115,85",  "br":"245,240,230","d":"羊皮纸手稿风格",                       "s":23},
    {"v":"novel_warm",      "l":"小说暖",       "bg":"#f8f5f0",         "t":"#2a2520","a":"#d4ccc4","m":"#9a928a","ar":"212,204,196","br":"248,245,240","d":"文学小说排版风格，暖白底色",               "s":24},
    {"v":"blueprint",        "l":"蓝图纸",       "bg":"#ffffff",         "t":"#1e2622","a":"#1e2622","m":"#707a65","ar":"30,38,34",    "br":"255,255,255","d":"工程蓝图纸描白风格",                     "s":25},
    {"v":"mystery_dark",     "l":"悬疑黑",       "bg":"#2a2a2a",         "t":"#9a9a9a","a":"#555555","m":"#666666","ar":"85,85,85",     "br":"42,42,42",    "d":"悬疑推理小说风格，深灰底色",               "s":26},
    {"v":"fitzgerald",     "l":"菲茨杰拉德",   "bg":"#faf6ee",         "t":"#1a1a1a","a":"#c4a962","m":"#8a8a7a","ar":"196,169,98",  "br":"250,246,238","d":"20世纪文学风格，暖象牙底色",              "s":27},
]

lines = []
lines.append("-- ===========================================================")
lines.append("-- 18 种内置配色板 seed 数据")
lines.append("-- 通过 ON CONFLICT(value) 实现幂等写入")
lines.append("-- ===========================================================")
lines.append("")

for p in palettes:
    v = p["v"]; l = p["l"]; bg = p["bg"]; t = p["t"]; a = p["a"]; m = p["m"]; ar = p["ar"]; br = p["br"]; d = p["d"]; s = p["s"]
    # 注意：Python f-string 中用 {{ 表示 {，}} 表示 }
    css = f'.gallery-card[data-palette="{v}"] {{ --card-bg: {bg}; --card-text: {t}; --card-accent: {a}; --card-muted: {m}; --card-accent-rgb: {ar}; --card-bg-rgb: {br}; }}'
    lines.append(f"INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)")
    lines.append(f"VALUES (")
    lines.append(f"    '{v}',")
    lines.append(f"    '{l}',")
    lines.append(f"    '{bg}',")
    lines.append(f"    '{t}',")
    lines.append(f"    '{a}',")
    lines.append(f"    '{m}',")
    lines.append(f"    '{d}',")
    lines.append(f"    {s},")
    # css_template 值：单引号包裹，内双引号无需转义
    lines.append(f"    '{css}'")
    lines.append(f")")
    lines.append(f"ON CONFLICT (value) DO UPDATE SET")
    lines.append(f"    label        = EXCLUDED.label,")
    lines.append(f"    bg           = EXCLUDED.bg,")
    lines.append(f"    text_color   = EXCLUDED.text_color,")
    lines.append(f"    accent       = EXCLUDED.accent,")
    lines.append(f"    muted        = EXCLUDED.muted,")
    lines.append(f"    description  = EXCLUDED.description,")
    lines.append(f"    css_template = EXCLUDED.css_template;")
    lines.append("")

with open('seed_builtin_palettes.sql', 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))

print("OK，已生成", file=sys.stderr)
print(f"共 {len(palettes)} 条", file=sys.stderr)
