-- ===========================================================
-- 18 种内置配色板 seed 数据
-- 通过 ON CONFLICT(value) 实现幂等写入
-- ===========================================================

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'industrial',
    '工业灰',
    'transparent',
    '#1e2622',
    '#1e2622',
    '#707a65',
    '工业终端默认灰，低饱和冷灰色调',
    10,
    '.gallery-card[data-palette="industrial"] { --card-bg: transparent; --card-text: #1e2622; --card-accent: #1e2622; --card-muted: #707a65; --card-accent-rgb: 30,38,34; --card-bg-rgb: 0,0,0; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'repair_yellow',
    '维修黄',
    '#d2c89f',
    '#403d30',
    '#615a42',
    '#837b5a',
    '维修手册风格，暖黄纸张底色',
    11,
    '.gallery-card[data-palette="repair_yellow"] { --card-bg: #d2c89f; --card-text: #403d30; --card-accent: #615a42; --card-muted: #837b5a; --card-accent-rgb: 97,90,66; --card-bg-rgb: 210,200,159; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'printer_green',
    '打印机绿',
    '#e5ebda',
    '#1e2622',
    '#8a8f7c',
    '#8a8f7c',
    '点阵打印机输出风格，淡绿护眼底色',
    12,
    '.gallery-card[data-palette="printer_green"] { --card-bg: #e5ebda; --card-text: #1e2622; --card-accent: #8a8f7c; --card-muted: #8a8f7c; --card-accent-rgb: 138,143,124; --card-bg-rgb: 229,235,218; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'bsod_blue',
    '蓝屏蓝',
    '#1e2669',
    '#cadbb7',
    '#4a5d8f',
    '#7f86ba',
    'Windows 蓝屏死机风格',
    13,
    '.gallery-card[data-palette="bsod_blue"] { --card-bg: #1e2669; --card-text: #cadbb7; --card-accent: #4a5d8f; --card-muted: #7f86ba; --card-accent-rgb: 74,93,143; --card-bg-rgb: 30,38,105; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'alert_red',
    '警报红',
    'transparent',
    '#8f341d',
    '#8f341d',
    '#8f341d',
    '红色警报风格，透明底红字',
    14,
    '.gallery-card[data-palette="alert_red"] { --card-bg: transparent; --card-text: #8f341d; --card-accent: #8f341d; --card-muted: #8f341d; --card-accent-rgb: 143,52,29; --card-bg-rgb: 0,0,0; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'terminal_black',
    '终端黑',
    '#0b0c0a',
    '#707a65',
    '#1e2622',
    '#43473b',
    'Linux 终端默认黑白风',
    15,
    '.gallery-card[data-palette="terminal_black"] { --card-bg: #0b0c0a; --card-text: #707a65; --card-accent: #1e2622; --card-muted: #43473b; --card-accent-rgb: 30,38,34; --card-bg-rgb: 11,12,10; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'vscode_dark',
    'VS Code 暗色',
    '#0f1419',
    '#cadbb7',
    '#3a7d44',
    '#858585',
    'VS Code 深色主题风格',
    16,
    '.gallery-card[data-palette="vscode_dark"] { --card-bg: #0f1419; --card-text: #cadbb7; --card-accent: #3a7d44; --card-muted: #858585; --card-accent-rgb: 58,125,68; --card-bg-rgb: 15,20,25; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'archive_khaki',
    '档案卡其',
    '#f0f2eb',
    '#1e2622',
    '#8a8f7c',
    '#5a6352',
    '档案袋卡片风格，卡其底色',
    17,
    '.gallery-card[data-palette="archive_khaki"] { --card-bg: #f0f2eb; --card-text: #1e2622; --card-accent: #8a8f7c; --card-muted: #5a6352; --card-accent-rgb: 138,143,124; --card-bg-rgb: 240,242,235; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'github_light',
    'GitHub 亮色',
    '#ffffff',
    '#2d333b',
    '#d1d9e0',
    '#656d76',
    'GitHub 亮色 Issues 风格',
    18,
    '.gallery-card[data-palette="github_light"] { --card-bg: #ffffff; --card-text: #2d333b; --card-accent: #d1d9e0; --card-muted: #656d76; --card-accent-rgb: 209,217,224; --card-bg-rgb: 255,255,255; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'diary_cream',
    '日记奶油',
    '#faf7e8',
    '#4a453d',
    '#c9c2b0',
    '#9a9385',
    '手账日记风格，奶油暖白底色',
    19,
    '.gallery-card[data-palette="diary_cream"] { --card-bg: #faf7e8; --card-text: #4a453d; --card-accent: #c9c2b0; --card-muted: #9a9385; --card-accent-rgb: 201,194,176; --card-bg-rgb: 250,247,232; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'twitter_light',
    'Twitter 亮色',
    '#ffffff',
    '#14171a',
    '#e6ecf0',
    '#657786',
    'Twitter/X 亮色发帖风格',
    20,
    '.gallery-card[data-palette="twitter_light"] { --card-bg: #ffffff; --card-text: #14171a; --card-accent: #e6ecf0; --card-muted: #657786; --card-accent-rgb: 230,236,240; --card-bg-rgb: 255,255,255; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'notebook_white',
    '笔记本白',
    '#fffef5',
    '#2c2c2c',
    '#e0d9c8',
    '#8a8273',
    '横线笔记本纸张风格',
    21,
    '.gallery-card[data-palette="notebook_white"] { --card-bg: #fffef5; --card-text: #2c2c2c; --card-accent: #e0d9c8; --card-muted: #8a8273; --card-accent-rgb: 224,217,200; --card-bg-rgb: 255,254,245; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'newspaper',
    '报纸灰',
    '#ffffff',
    '#000000',
    '#cccccc',
    '#999999',
    '报纸印刷风格，纯白底黑字',
    22,
    '.gallery-card[data-palette="newspaper"] { --card-bg: #ffffff; --card-text: #000000; --card-accent: #cccccc; --card-muted: #999999; --card-accent-rgb: 204,204,204; --card-bg-rgb: 255,255,255; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'role_parchment',
    '羊皮纸',
    '#f5f0e6',
    '#3d3529',
    '#8b7355',
    '#6b5a45',
    '羊皮纸手稿风格',
    23,
    '.gallery-card[data-palette="role_parchment"] { --card-bg: #f5f0e6; --card-text: #3d3529; --card-accent: #8b7355; --card-muted: #6b5a45; --card-accent-rgb: 139,115,85; --card-bg-rgb: 245,240,230; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'novel_warm',
    '小说暖',
    '#f8f5f0',
    '#2a2520',
    '#d4ccc4',
    '#9a928a',
    '文学小说排版风格，暖白底色',
    24,
    '.gallery-card[data-palette="novel_warm"] { --card-bg: #f8f5f0; --card-text: #2a2520; --card-accent: #d4ccc4; --card-muted: #9a928a; --card-accent-rgb: 212,204,196; --card-bg-rgb: 248,245,240; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'blueprint',
    '蓝图纸',
    '#ffffff',
    '#1e2622',
    '#1e2622',
    '#707a65',
    '工程蓝图纸描白风格',
    25,
    '.gallery-card[data-palette="blueprint"] { --card-bg: #ffffff; --card-text: #1e2622; --card-accent: #1e2622; --card-muted: #707a65; --card-accent-rgb: 30,38,34; --card-bg-rgb: 255,255,255; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'mystery_dark',
    '悬疑黑',
    '#2a2a2a',
    '#9a9a9a',
    '#555555',
    '#666666',
    '悬疑推理小说风格，深灰底色',
    26,
    '.gallery-card[data-palette="mystery_dark"] { --card-bg: #2a2a2a; --card-text: #9a9a9a; --card-accent: #555555; --card-muted: #666666; --card-accent-rgb: 85,85,85; --card-bg-rgb: 42,42,42; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'fitzgerald',
    '菲茨杰拉德',
    '#faf6ee',
    '#1a1a1a',
    '#c4a962',
    '#8a8a7a',
    '20世纪文学风格，暖象牙底色',
    27,
    '.gallery-card[data-palette="fitzgerald"] { --card-bg: #faf6ee; --card-text: #1a1a1a; --card-accent: #c4a962; --card-muted: #8a8a7a; --card-accent-rgb: 196,169,98; --card-bg-rgb: 250,246,238; }'
)
ON CONFLICT (value) DO UPDATE SET
    label        = EXCLUDED.label,
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;
