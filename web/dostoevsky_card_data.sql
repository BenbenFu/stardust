-- ============================================================
-- 陀思妥耶夫斯基卡片 — 维度选项数据
-- 主题：地下室手记的笔记本散页
-- 新增 palette / border shadow / deco pseudo_label / deco separator
--       elements date / elements capsule / elements highlights
--       + STYLE_POOL 条目（Gallery 路由入口）
-- ============================================================

-- 1. 色板: dostoevsky_notebook（草纸底色, 俄式暗沉墨色）
INSERT INTO style_palette_options
    (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'dostoevsky_notebook',
    '地下室手记',
    '#e5dcc8',
    '#1a1410',
    '#8b7b6b',
    '#6b5b4a',
    '陀思妥耶夫斯基 — 地下室手记的笔记本散页',
    200,
    '.gallery-card[data-palette="dostoevsky_notebook"] { --card-bg: #e5dcc8; --card-text: #1a1410; --card-accent: #8b7b6b; --card-muted: #6b5b4a; --card-accent-rgb: 139,123,107; --card-bg-rgb: 229,220,200; padding: 14px 10px 12px 16px; text-align: left; }'
)
ON CONFLICT (value) DO UPDATE SET
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

-- 2. 边框阴影: notebook_inset（墨迹内晕 + hover 下沉）
INSERT INTO style_border_options
    (sub_dim, value, label, description, sort_order, css_template)
VALUES (
    'shadow',
    'notebook_inset',
    '笔记晕影',
    '陀思妥耶夫斯基 — 墨迹内晕阴影，hover 下沉',
    200,
    '.gallery-card[data-shadow="notebook_inset"] { box-shadow: inset 0 0 40px rgba(80,60,40,0.1), 0 1px 3px rgba(0,0,0,0.15); } .gallery-card[data-shadow="notebook_inset"]:hover { box-shadow: 2px 2px 0 #5c4a3a, inset 0 0 50px rgba(80,60,40,0.15), 0 2px 6px rgba(0,0,0,0.18); transform: translate(-1px, -1px); }'
)
ON CONFLICT (sub_dim, value) DO UPDATE SET
    label        = EXCLUDED.label,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

-- 3. 装饰伪标签: dostoevsky_header（——  手  记  ——）
INSERT INTO style_deco_options
    (sub_dim, value, label, description, sort_order, css_template)
VALUES (
    'pseudo_label',
    'dostoevsky_header',
    '手记卷头',
    '陀思妥耶夫斯基 — 手记标题横线卷头',
    200,
    '.gallery-card[data-pseudo-label="dostoevsky_header"]::before { content: "\2014\2014  手  记  \2014\2014"; display: block; font-size: 10px; letter-spacing: 3px; color: #5c4a3a; text-align: center; font-style: italic; margin-bottom: 10px; }'
)
ON CONFLICT (sub_dim, value) DO UPDATE SET
    label        = EXCLUDED.label,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

-- 4. 装饰分隔符: period_ellipsis（.  .  . 断裂省略号）
-- 内容由 CSS ::after 提供，无需修改 style-engine.js SEPARATORS
INSERT INTO style_deco_options
    (sub_dim, value, label, description, sort_order, css_template)
VALUES (
    'separator',
    'period_ellipsis',
    '断裂省略',
    '陀思妥耶夫斯基 — 句号间隔断裂省略号',
    200,
    '.gallery-card[data-sep="period_ellipsis"] .hl-sep::after { content: ".  .  ."; } .gallery-card[data-palette="dostoevsky_notebook"] .hl-sep { font-size: 11px; color: #8b7b6b; margin: 3px 0; line-height: 1; letter-spacing: 4px; }'
)
ON CONFLICT (sub_dim, value) DO UPDATE SET
    label        = EXCLUDED.label,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

-- 5. 元素日期: dostoevsky_date（右对齐、斜体、方括号包裹）
INSERT INTO style_elements_options
    (element, value, label, description, sort_order, css_template)
VALUES (
    'date',
    'dostoevsky_date',
    '页边注日期',
    '陀思妥耶夫斯基 — 右对齐斜体 [日期] 格式',
    200,
    '.gallery-card[data-date-variant="dostoevsky_date"] .card-date { font-size: 9px; color: var(--card-muted); font-style: italic; text-align: right; margin-bottom: 10px; } .gallery-card[data-date-variant="dostoevsky_date"] .card-date::before { content: "["; } .gallery-card[data-date-variant="dostoevsky_date"] .card-date::after { content: "]"; }'
)
ON CONFLICT (element, value) DO UPDATE SET
    label        = EXCLUDED.label,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

-- 6. 元素扭蛋标签: dostoevsky_capsule（右对齐虚线页脚）
INSERT INTO style_elements_options
    (element, value, label, description, sort_order, css_template)
VALUES (
    'capsule',
    'dostoevsky_capsule',
    '虚线页脚',
    '陀思妥耶夫斯基 — 右对齐斜体虚线页脚标签',
    200,
    '.gallery-card[data-capsule-variant="dostoevsky_capsule"] .card-style { font-size: 8px; color: var(--card-muted); font-style: italic; text-align: right; margin-top: 10px; padding-top: 6px; border-top: 1px dashed var(--card-accent); } .gallery-card[data-capsule-variant="dostoevsky_capsule"] .card-style::before { content: "\2014\2014 "; }'
)
ON CONFLICT (element, value) DO UPDATE SET
    label        = EXCLUDED.label,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

-- 7. 元素精华句: dostoevsky_highlights（无前缀密集 + 删除线占位）
INSERT INTO style_elements_options
    (element, value, label, description, sort_order, css_template)
VALUES (
    'highlights',
    'dostoevsky_highlights',
    '密集无前缀',
    '陀思妥耶夫斯基 — 无前缀紧凑段落 + 删除线"今日无言"占位',
    200,
    '.gallery-card[data-hl-variant="dostoevsky_highlights"] .card-highlight-item { font-size: 11px; line-height: 1.5; margin-bottom: 0; text-align: left; } .gallery-card[data-hl-variant="dostoevsky_highlights"] .card-highlight-item::before { content: none; } .gallery-card[data-hl-variant="dostoevsky_highlights"] .card-no-highlight { font-size: 10px; color: var(--card-accent); font-style: italic; text-align: center; margin: 8px 0; text-decoration: line-through; } .gallery-card[data-hl-variant="dostoevsky_highlights"] .card-no-highlight::before { content: "[ 今日无言 ]"; }'
)
ON CONFLICT (element, value) DO UPDATE SET
    label        = EXCLUDED.label,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

-- ============================================================
-- 8. STYLE_POOL 条目（Gallery 页路由入口）★ 关键
-- Gallery 通过 styleMap[diary.capsule] 查找对应的 style_json
-- 没有这条记录 → gallery 找不到样式 → fallback 到 overheat
-- diary.capsule 字段必须与此 name 一致才能匹配
-- 注意：name 必须与 diary agent 写入 DIARIES.capsule 的值一致
--       这里是中文名 "陀思妥耶夫斯基"，而非英文 slug
-- ============================================================
INSERT INTO "STYLE_POOL" (name, category, "desc", style_json, active)
VALUES (
    '陀思妥耶夫斯基',
    'fiction',
    '陀思妥耶夫斯基 — 地下室手记的笔记本散页风格',
    '{"palette":"dostoevsky_notebook","layout":{"top":"none","body":"standard","bottom":"style_tag","side":"none","overlay":"none"},"typo":{"family":"serif","title_size":13,"title_deco":"none"},"border":{"style":"thin_solid","width":1,"radius":"0","shadow":"notebook_inset"},"deco":{"bg_pattern":"none","separator":"period_ellipsis","pseudo_label":"dostoevsky_header"},"effect":{"animation":"none","filter":"none","transform":"none"},"elements":{"date":{"variant":"dostoevsky_date"},"capsule":{"variant":"dostoevsky_capsule"},"title":{"variant":"default"},"highlights":{"variant":"dostoevsky_highlights"}}}',
    true
)
ON CONFLICT (name) DO UPDATE SET
    category    = EXCLUDED.category,
    "desc"      = EXCLUDED."desc",
    style_json  = EXCLUDED.style_json,
    active      = EXCLUDED.active;
