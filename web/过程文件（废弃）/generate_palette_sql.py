import sys

# 从 style-engine.js 手工抄录的 PALETTES 数据
palettes = [
    {"value": "industrial",       "label": "工业灰",         "bg": "transparent",      "text": "#1e2622", "accent": "#1e2622", "muted": "#707a65", "accentRgb": "30,38,34",    "bgRgb": "0,0,0",       "desc": "工业终端默认灰，低饱和冷灰色调", "sort": 10},
    {"value": "repair_yellow",    "label": "维修黄",         "bg": "#d2c89f",         "text": "#403d30", "accent": "#615a42", "muted": "#837b5a", "accentRgb": "97,90,66",     "bgRgb": "210,200,159", "desc": "维修手册风格，暖黄纸张底色",     "sort": 11},
    {"value": "printer_green",    "label": "打印机绿",       "bg": "#e5ebda",         "text": "#1e2622", "accent": "#8a8f7c", "muted": "#8a8f7c", "accentRgb": "138,143,124", "bgRgb": "229,235,218", "desc": "点阵打印机输出风格，淡绿护眼底色", "sort": 12},
    {"value": "bsod_blue",       "label": "蓝屏蓝",         "bg": "#1e2669",         "text": "#cadbb7", "accent": "#4a5d8f", "muted": "#7f86ba", "accentRgb": "74,93,143",    "bgRgb": "30,38,105",   "desc": "Windows 蓝屏死机风格",          "sort": 13},
    {"value": "alert_red",        "label": "警报红",         "bg": "transparent",      "text": "#8f341d", "accent": "#8f341d", "muted": "#8f341d", "accentRgb": "143,52,29",    "bgRgb": "0,0,0",       "desc": "红色警报风格，透明底红字",       "sort": 14},
    {"value": "terminal_black",   "label": "终端黑",         "bg": "#0b0c0a",         "text": "#707a65", "accent": "#1e2622", "muted": "#43473b", "accentRgb": "30,38,34",    "bgRgb": "11,12,10",    "desc": "Linux 终端默认黑白风",         "sort": 15},
    {"value": "vscode_dark",     "label": "VS Code 暗色",   "bg": "#0f1419",         "text": "#cadbb7", "accent": "#3a7d44", "muted": "#858585", "accentRgb": "58,125,68",    "bgRgb": "15,20,25",    "desc": "VS Code 深色主题风格",           "sort": 16},
    {"value": "archive_khaki",   "label": "档案卡其",       "bg": "#f0f2eb",         "text": "#1e2622", "accent": "#8a8f7c", "muted": "#5a6352", "accentRgb": "138,143,124", "bgRgb": "240,242,235", "desc": "档案袋卡片风格，卡其底色",     "sort": 17},
    {"value": "github_light",     "label": "GitHub 亮色",    "bg": "#ffffff",         "text": "#2d333b", "accent": "#d1d9e0", "muted": "#656d76", "accentRgb": "209,217,224", "bgRgb": "255,255,255", "desc": "GitHub 亮色 Issues 风格",       "sort": 18},
    {"value": "diary_cream",     "label": "日记奶油",       "bg": "#faf7e8",         "text": "#4a453d", "accent": "#c9c2b0", "muted": "#9a9385", "accentRgb": "201,194,176", "bgRgb": "250,247,232", "desc": "手账日记风格，奶油暖白底色",   "sort": 19},
    {"value": "twitter_light",    "label": "Twitter 亮色",   "bg": "#ffffff",         "text": "#14171a", "accent": "#e6ecf0", "muted": "#657786", "accentRgb": "230,236,240", "bgRgb": "255,255,255", "desc": "Twitter/X 亮色发帖风格",        "sort": 20},
    {"value": "notebook_white",   "label": "笔记本白",       "bg": "#fffef5",         "text": "#2c2c2c", "accent": "#e0d9c8", "muted": "#8a8273", "accentRgb": "224,217,200", "bgRgb": "255,254,245", "desc": "横线笔记本纸张风格",           "sort": 21},
    {"value": "newspaper",        "label": "报纸灰",         "bg": "#ffffff",         "text": "#000000", "accent": "#cccccc", "muted": "#999999", "accentRgb": "204,204,204", "bgRgb": "255,255,255", "desc": "报纸印刷风格，纯白底黑字",     "sort": 22},
    {"value": "role_parchment",   "label": "羊皮纸",         "bg": "#f5f0e6",         "text": "#3d3529", "accent": "#8b7355", "muted": "#6b5a45", "accentRgb": "139,115,85",  "bgRgb": "245,240,230", "desc": "羊皮纸手稿风格",               "sort": 23},
    {"value": "novel_warm",      "label": "小说暖",         "bg": "#f8f5f0",         "text": "#2a2520", "accent": "#d4ccc4", "muted": "#9a928a", "accentRgb": "212,204,196", "bgRgb": "248,245,240", "desc": "文学小说排版风格，暖白底色",   "sort": 24},
    {"value": "blueprint",        "label": "蓝图纸",         "bg": "#ffffff",         "text": "#1e2622", "accent": "#1e2622", "muted": "#707a65", "accentRgb": "30,38,34",    "bgRgb": "255,255,255", "desc": "工程蓝图纸描白风格",           "sort": 25},
    {"value": "mystery_dark",     "label": "悬疑黑",         "bg": "#2a2a2a",         "text": "#9a9a9a", "accent": "#555555", "muted": "#666666", "accentRgb": "85,85,85",     "bgRgb": "42,42,42",    "desc": "悬疑推理小说风格，深灰底色",   "sort": 26},
    {"value": "fitzgerald",     "label": "菲茨杰拉德",     "bg": "#faf6ee",         "text": "#1a1a1a", "accent": "#c4a962", "muted": "#8a8a7a", "accentRgb": "196,169,98",  "bgRgb": "250,246,238", "desc": "20世纪文学风格，暖象牙底色",    "sort": 27},
]

lines = []
lines.append("-- ============================================================")
lines.append("-- 18 种内置配色板 seed 数据")
lines.append("-- 通过 ON CONFLICT(value) 实现幂等写入")
lines.append("-- 执行前确保 style_palette_options 表已创建，且有 UNIQUE(value) 约束")
lines.append("-- ============================================================")
lines.append("")

for p in palettes:
    v = p["value"]
    label = p["label"]
    bg = p["bg"]
    text = p["text"]
    accent = p["accent"]
    muted = p["muted"]
    ar = p["accentRgb"]
    br = p["bgRgb"]
    desc = p["desc"]
    sort = p["sort"]
    css = f".gallery-card[data-palette=\"{v}\"] {{ --card-bg: {bg}; --card-text: {text}; --card-accent: {accent}; --card-muted: {muted}; --card-accent-rgb: {ar}; --card-bg-rgb: {br}; }}"
    lines.append(f"INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)")
    lines.append(f"VALUES (")
    lines.append(f"    '{v}',")
    lines.append(f"    '{label}',")
    lines.append(f"    '{bg}',")
    lines.append(f"    '{text}',")
    lines.append(f"    '{accent}',")
    lines.append(f"    '{muted}',")
    lines.append(f"    '{desc}',")
    lines.append(f"    {sort},")
    lines.append(f"    '{css.replace(chr(123), '{{').replace(chr(125), '}}')}'")
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

print("已生成 seed_builtin_palettes.sql", file=sys.stderr)
print(f"共 {len(palettes)} 条 INSERT", file=sys.stderr)
