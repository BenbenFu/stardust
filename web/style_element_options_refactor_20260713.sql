-- ============================================================================
-- style_element_options_refactor_20260713.sql  (聚焦版：仅 style_element_options)
-- 顶/侧栏装饰条「维度表」迁移：外观名与宽度解耦
--
-- 本文件 = 原 style_element_bands_refactor_20260713.sql 的 Part B + Part C。
-- 明确【不包含】：
--   - Part A: style_layout_options 重定向（layout 维度，独立表，按需另跑）
--   - Part D: STYLE_POOL.style_json 数据迁移（按需求本次不修改 STYLE_POOL）
--
-- 背景：
--   旧引擎把 header/side 装饰条用 .gallery-card 的 border 伪装，且外观名里硬编了
--   宽度（thin_accent_bar=2px / thick_ribbon=6px / blink_cursor_bar=20px），侧栏还分了
--   _right 变体。新引擎（style-engine.js v2.2）改为真实 DOM 元素 .card-header-band /
--   .card-side-band，宽度由 element.header_width / side_width 控制、侧栏左右由
--   element.side_position 控制，故 option 名须改为纯外观名。
--
-- 运行后效果：
--   - style_element_options 的 header_deco / side_accent 选项重命名为 solid / gradient /
--     blink / diagonal / breathing / scanline，并保留功能型 line_number_column /
--     notebook_binding（改写为 band 选择器）。
--   - 现有 STYLE_POOL 卡片若仍引用旧名（thin_accent_bar 等），本次【不改其数据】，
--     这些卡片不会显色；在 capsule-preview 重新选择顶/侧栏样式即可恢复。
--
-- 幂等性：UPDATE/DELETE 命中旧值才生效；INSERT 用 WHERE NOT EXISTS 包裹，可重复执行。
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Part B: header_deco 重命名 + 新增纯外观名
-- ----------------------------------------------------------------------------

-- thin_accent_bar → solid（外观纯色条；宽度改由 header_width 控制）
UPDATE style_element_options
SET value = 'solid', sort_order = 2,
    css_template = '.gallery-card[data-style-element-header="solid"] .card-header-band { background: var(--card-accent, #ccc); }'
WHERE sub_dim = 'header_deco' AND value = 'thin_accent_bar';

-- thick_ribbon 合并进 solid（旧 6px 宽度由 STYLE_POOL 后续迁移补 header_width=6 保留）
DELETE FROM style_element_options WHERE sub_dim = 'header_deco' AND value = 'thick_ribbon';

-- gradient_strip → gradient
UPDATE style_element_options
SET value = 'gradient', sort_order = 3,
    css_template = '.gallery-card[data-style-element-header="gradient"] .card-header-band { background: linear-gradient(to right, var(--card-accent, #ccc), var(--card-muted, #999)); }'
WHERE sub_dim = 'header_deco' AND value = 'gradient_strip';

-- blink_cursor_bar → blink（旧 20px 高度由 STYLE_POOL 后续迁移补 header_width=20 保留）
UPDATE style_element_options
SET value = 'blink', sort_order = 4,
    css_template = '.gallery-card[data-style-element-header="blink"] .card-header-band { background: var(--card-accent, #ccc); animation: band-blink 1s infinite step-end; }'
WHERE sub_dim = 'header_deco' AND value = 'blink_cursor_bar';

-- 新增：diagonal / breathing / scanline（纯外观，宽度仍由 header_width 决定）
INSERT INTO style_element_options (sub_dim, value, label, mount_anchor, layout_mode, css_template, sort_order, is_enabled)
SELECT 'header_deco', 'diagonal',  'Diagonal 斜纹',   'top', 'placeholder', '.gallery-card[data-style-element-header="diagonal"] .card-header-band { background: repeating-linear-gradient(45deg, var(--card-accent, #ccc) 0 6px, transparent 6px 12px); }', 5, true
WHERE NOT EXISTS (SELECT 1 FROM style_element_options WHERE sub_dim = 'header_deco' AND value = 'diagonal');

INSERT INTO style_element_options (sub_dim, value, label, mount_anchor, layout_mode, css_template, sort_order, is_enabled)
SELECT 'header_deco', 'breathing', 'Breathing 呼吸', 'top', 'placeholder', '.gallery-card[data-style-element-header="breathing"] .card-header-band { background: var(--card-accent, #ccc); animation: band-breathing 2.4s ease-in-out infinite; }', 6, true
WHERE NOT EXISTS (SELECT 1 FROM style_element_options WHERE sub_dim = 'header_deco' AND value = 'breathing');

INSERT INTO style_element_options (sub_dim, value, label, mount_anchor, layout_mode, css_template, sort_order, is_enabled)
SELECT 'header_deco', 'scanline',  'Scanline 扫描',  'top', 'placeholder', '.gallery-card[data-style-element-header="scanline"] .card-header-band { background: linear-gradient(to bottom, transparent, var(--card-accent, #ccc), transparent); background-size: 100% 200%; animation: band-scanline 1.6s linear infinite; }', 7, true
WHERE NOT EXISTS (SELECT 1 FROM style_element_options WHERE sub_dim = 'header_deco' AND value = 'scanline');

-- ----------------------------------------------------------------------------
-- Part C: side_accent 重命名 + 新增纯外观名（保留功能型，改写为 band）
-- ----------------------------------------------------------------------------

-- 先删 right 变体（合并进 solid / gradient，位置由 STYLE_POOL.side_position='right' 表达）
DELETE FROM style_element_options WHERE sub_dim = 'side_accent' AND value IN ('solid_side_bar_right', 'gradient_side_bar_right');

-- solid_side_bar → solid
UPDATE style_element_options
SET value = 'solid', sort_order = 2,
    css_template = '.gallery-card[data-style-element-side="solid"] .card-side-band { background: var(--card-accent, #ccc); }'
WHERE sub_dim = 'side_accent' AND value = 'solid_side_bar';

-- gradient_side_bar → gradient
UPDATE style_element_options
SET value = 'gradient', sort_order = 3,
    css_template = '.gallery-card[data-style-element-side="gradient"] .card-side-band { background: linear-gradient(to bottom, var(--card-accent, #ccc), transparent); }'
WHERE sub_dim = 'side_accent' AND value = 'gradient_side_bar';

-- line_number_column：保留功能语义，改写到 side-band 作为代码行号槽（行号落在 .card-highlight-item 上）
UPDATE style_element_options
SET sort_order = 4,
    css_template = '.gallery-card[data-style-element-side="line_number_column"] .card-side-band { background: color-mix(in srgb, var(--card-bg, #fff) 90%, var(--card-text, #000) 10%); border-right: 1px solid var(--card-muted, #bbb); } .gallery-card[data-style-element-side="line_number_column"] { counter-reset: line-no; } .gallery-card[data-style-element-side="line_number_column"] .card-highlight-item { counter-increment: line-no; position: relative; } .gallery-card[data-style-element-side="line_number_column"] .card-highlight-item::before { content: counter(line-no); position: absolute; left: calc(-1 * var(--side-band-size, 8px) - 2px); width: calc(var(--side-band-size, 8px) - 4px); text-align: right; color: var(--card-muted, #999); font-size: 0.75em; font-family: monospace; user-select: none; }'
WHERE sub_dim = 'side_accent' AND value = 'line_number_column';

-- notebook_binding：保留功能语义，改写到 side-band 作为装订孔
UPDATE style_element_options
SET sort_order = 5,
    css_template = '.gallery-card[data-style-element-side="notebook_binding"] .card-side-band { background-color: var(--card-muted, #bbb); background-image: radial-gradient(circle at center, var(--card-bg, #fff) 2px, transparent 2.5px); background-size: 100% 16px; background-repeat: repeat-y; }'
WHERE sub_dim = 'side_accent' AND value = 'notebook_binding';

-- 新增：diagonal / breathing / scanline（纯外观，宽度仍由 side_width 决定）
INSERT INTO style_element_options (sub_dim, value, label, mount_anchor, layout_mode, css_template, sort_order, is_enabled)
SELECT 'side_accent', 'diagonal',  'Diagonal 斜纹',   'left', 'placeholder', '.gallery-card[data-style-element-side="diagonal"] .card-side-band { background: repeating-linear-gradient(45deg, var(--card-accent, #ccc) 0 6px, transparent 6px 12px); }', 6, true
WHERE NOT EXISTS (SELECT 1 FROM style_element_options WHERE sub_dim = 'side_accent' AND value = 'diagonal');

INSERT INTO style_element_options (sub_dim, value, label, mount_anchor, layout_mode, css_template, sort_order, is_enabled)
SELECT 'side_accent', 'breathing', 'Breathing 呼吸', 'left', 'placeholder', '.gallery-card[data-style-element-side="breathing"] .card-side-band { background: var(--card-accent, #ccc); animation: band-breathing 2.4s ease-in-out infinite; }', 7, true
WHERE NOT EXISTS (SELECT 1 FROM style_element_options WHERE sub_dim = 'side_accent' AND value = 'breathing');

INSERT INTO style_element_options (sub_dim, value, label, mount_anchor, layout_mode, css_template, sort_order, is_enabled)
SELECT 'side_accent', 'scanline',  'Scanline 扫描',  'left', 'placeholder', '.gallery-card[data-style-element-side="scanline"] .card-side-band { background: linear-gradient(to right, transparent, var(--card-accent, #ccc), transparent); background-size: 200% 100%; animation: band-scanline 1.6s linear infinite; }', 8, true
WHERE NOT EXISTS (SELECT 1 FROM style_element_options WHERE sub_dim = 'side_accent' AND value = 'scanline');

-- ----------------------------------------------------------------------------
-- 验证（取消注释查看结果）
-- ----------------------------------------------------------------------------
-- SELECT sub_dim, value, sort_order, is_enabled, css_template
-- FROM style_element_options
-- WHERE sub_dim IN ('header_deco','side_accent')
-- ORDER BY sub_dim, sort_order;
