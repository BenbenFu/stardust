-- ============================================================================
-- style_element_bands_refactor_20260713.sql
-- 装饰条架构重构：从「border 伪装装饰条」改为「真实 band 元素」
--
-- 背景：
--   旧引擎把 header/side 装饰条用 .gallery-card 的 border-top/border-left 伪装，
--   且外观名里硬编了宽度（thin_accent_bar=2px, thick_ribbon=6px, blink_cursor_bar=20px），
--   侧栏左右还分成了 solid_side_bar / solid_side_bar_right 两套。
--   新引擎（style-engine.js v2.2）改用真实 DOM 元素：
--     .card-header-band  （顶栏）
--     .card-side-band    （侧栏，左/右由 element.side_position 决定）
--   装饰条「外观」与「宽度」彻底解耦：
--     - 外观由 DB css_template 命中 .card-header-band / .card-side-band 决定
--     - 宽度由 element.header_width / side_width 写入 CSS 变量
--       --header-band-size / --side-band-size 决定
--   因此旧 option 名必须全量重命名为纯外观名。
--
-- 本脚本分四部分：
--   A. 重定向 layout 维度模板（grid / block_align / inline_align / density）
--      选择器从 .gallery-card 改到 .card-content--slots / .card-content
--      （因为 .gallery-card 现在是 flex column 容器，slot grid 移到了 .card-content--slots）
--   B. header_deco 选项重命名 + 新增纯外观名
--   C. side_accent 选项重命名 + 新增纯外观名（保留 line_number_column / notebook_binding，改写为 band）
--   D. 迁移 STYLE_POOL.style_json（旧值映射 + 补 header_width / side_width / side_position）
--
-- 执行顺序：A → B → C → D（C 中先删 right 变体再改名，避免唯一约束冲突）
-- 幂等性：可重复执行；已迁移过的行 CASE 会落到 ELSE 分支保持原值。
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Part A: 重定向 layout 维度模板选择器到 band / content 容器
-- 说明：早期版本用 regexp_replace 做重定向，因旧模板选择器格式差异（前置选择器 /
--   空格 / 换行 / 多选择器并列）正则未命中，导致重定向失败。此处改为「精确整行
--   UPDATE」，100% 命中。完整版本见 style_layout_redirect_fix_20260713.sql。
-- ----------------------------------------------------------------------------

-- grid：slot 网格现在在 .card-content--slots 上
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="2col_equal"] .card-content--slots { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }' WHERE sub_dim='grid' AND value='2col_equal';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="2col_left_narrow"] .card-content--slots { grid-template-columns: 1fr 3fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }' WHERE sub_dim='grid' AND value='2col_left_narrow';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="2col_left_wide"] .card-content--slots { grid-template-columns: 2fr 1fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }' WHERE sub_dim='grid' AND value='2col_left_wide';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="2col_right_narrow"] .card-content--slots { grid-template-columns: 3fr 1fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }' WHERE sub_dim='grid' AND value='2col_right_narrow';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="2col_right_wide"] .card-content--slots { grid-template-columns: 1fr 2fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }' WHERE sub_dim='grid' AND value='2col_right_wide';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="3col_equal"] .card-content--slots { grid-template-columns: 1fr 1fr 1fr; grid-template-areas: "slot-a slot-b slot-d" "slot-c slot-c slot-c"; }' WHERE sub_dim='grid' AND value='3col_equal';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="3col_left_focus"] .card-content--slots { grid-template-columns: 2fr 1fr 1fr; grid-template-areas: "slot-b slot-b slot-b" "slot-c slot-a slot-d"; }' WHERE sub_dim='grid' AND value='3col_left_focus';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="3col_right_focus"] .card-content--slots { grid-template-columns: 1fr 1fr 2fr; grid-template-areas: "slot-b slot-b slot-b" "slot-a slot-d slot-c"; }' WHERE sub_dim='grid' AND value='3col_right_focus';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="bottom_split"] .card-content--slots { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-b slot-b" "slot-c slot-c" "slot-a slot-d"; }' WHERE sub_dim='grid' AND value='bottom_split';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="hero"] .card-content--slots { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-b slot-b" "slot-a slot-d" "slot-c slot-c"; }' WHERE sub_dim='grid' AND value='hero';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="inverted"] .card-content--slots { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-c slot-c" "slot-b slot-b" "slot-a slot-d"; }' WHERE sub_dim='grid' AND value='inverted';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="sidebar_both"] .card-content--slots { grid-template-columns: 80px 1fr 80px; grid-template-areas: "slot-a slot-b slot-d" "slot-a slot-c slot-d"; }' WHERE sub_dim='grid' AND value='sidebar_both';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="sidebar_left"] .card-content--slots { grid-template-columns: 100px 1fr; grid-template-areas: "slot-a slot-b" "slot-d slot-c"; }' WHERE sub_dim='grid' AND value='sidebar_left';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="sidebar_right"] .card-content--slots { grid-template-columns: 1fr 100px; grid-template-areas: "slot-b slot-a" "slot-c slot-d"; }' WHERE sub_dim='grid' AND value='sidebar_right';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="single"] .card-content--slots { grid-template-columns: 1fr; grid-template-areas: "slot-a" "slot-b" "slot-c" "slot-d"; }' WHERE sub_dim='grid' AND value='single';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="timeline"] .card-content--slots { grid-template-columns: 60px 1fr; grid-template-areas: "slot-a slot-b" "slot-a slot-c" "slot-a slot-d"; border-left: 2px solid var(--card-accent, #ccc); padding-left: 12px; }' WHERE sub_dim='grid' AND value='timeline';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-grid="top_split"] .card-content--slots { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-a slot-d" "slot-b slot-b" "slot-c slot-c"; }' WHERE sub_dim='grid' AND value='top_split';

-- block_align：slot 在网格内的垂直对齐 → .card-content--slots
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-block-align="center"] .card-content--slots { align-items: center; }' WHERE sub_dim='block_align' AND value='center';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-block-align="end"] .card-content--slots { align-items: end; }' WHERE sub_dim='block_align' AND value='end';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-block-align="start"] .card-content--slots { align-items: start; }' WHERE sub_dim='block_align' AND value='start';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-block-align="stretch"] .card-content--slots { align-items: stretch; }' WHERE sub_dim='block_align' AND value='stretch';

-- inline_align：slot 内水平对齐 → .card-content--slots
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-inline-align="center"] .card-content--slots { justify-items: center; text-align: center; }' WHERE sub_dim='inline_align' AND value='center';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-inline-align="end"] .card-content--slots { justify-items: end; text-align: end; }' WHERE sub_dim='inline_align' AND value='end';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-inline-align="justify"] .card-content--slots { justify-items: stretch; text-align: justify; }' WHERE sub_dim='inline_align' AND value='justify';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-inline-align="start"] .card-content--slots { justify-items: start; text-align: start; }' WHERE sub_dim='inline_align' AND value='start';

-- density：设置 --density-pad（呼吸间距）+ --layout-gap；真正的 padding 由引擎按 band_inset/density 模型计算
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-density="dense"] { --density-pad: 8px; --layout-gap: 4px; }' WHERE sub_dim='density' AND value='dense';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-density="normal"] { --density-pad: 12px; --layout-gap: 8px; }' WHERE sub_dim='density' AND value='normal';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-density="sparse"] { --density-pad: 16px; --layout-gap: 16px; }' WHERE sub_dim='density' AND value='sparse';

-- ----------------------------------------------------------------------------
-- Part B: header_deco 重命名 + 新增纯外观名
-- ----------------------------------------------------------------------------

-- thin_accent_bar → solid（外观纯色条；宽度改由 header_width 控制）
UPDATE style_element_options
SET value = 'solid', sort_order = 2,
    css_template = '.gallery-card[data-style-element-header="solid"] .card-header-band { background: var(--card-accent, #ccc); }'
WHERE sub_dim = 'header_deco' AND value = 'thin_accent_bar';

-- thick_ribbon 合并进 solid（旧 6px 宽度由 STYLE_POOL 迁移补 header_width=6 保留）
DELETE FROM style_element_options WHERE sub_dim = 'header_deco' AND value = 'thick_ribbon';

-- gradient_strip → gradient
UPDATE style_element_options
SET value = 'gradient', sort_order = 3,
    css_template = '.gallery-card[data-style-element-header="gradient"] .card-header-band { background: linear-gradient(to right, var(--card-accent, #ccc), var(--card-muted, #999)); }'
WHERE sub_dim = 'header_deco' AND value = 'gradient_strip';

-- blink_cursor_bar → blink（旧 20px 高度由 STYLE_POOL 迁移补 header_width=20 保留）
UPDATE style_element_options
SET value = 'blink', sort_order = 4,
    css_template = '.gallery-card[data-style-element-header="blink"] .card-header-band { background: var(--card-accent, #ccc); animation: band-blink 1s infinite step-end; }'
WHERE sub_dim = 'header_deco' AND value = 'blink_cursor_bar';

-- 新增：diagonal / breathing / scanline（纯外观，宽度仍由 header_width 决定）
-- 用 WHERE NOT EXISTS 包裹，可重复执行（与聚焦版 style_element_options_refactor_20260713.sql 不冲突）
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
-- 用 WHERE NOT EXISTS 包裹，可重复执行（与聚焦版 style_element_options_refactor_20260713.sql 不冲突）
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
-- Part D: 迁移 STYLE_POOL.style_json
--   - 旧 header_deco / side_accent 值映射到新纯外观名
--   - 补 header_width / side_width（按旧宽度尽量保留视觉）/ side_position
-- ----------------------------------------------------------------------------

UPDATE "STYLE_POOL"
SET style_json = jsonb_set(
  jsonb_set(
    jsonb_set(
      jsonb_set(
        jsonb_set(style_json,
          '{element,header_deco}',
          CASE (style_json->'element'->>'header_deco')
            WHEN 'thin_accent_bar'  THEN '"solid"'::jsonb
            WHEN 'thick_ribbon'    THEN '"solid"'::jsonb
            WHEN 'gradient_strip'   THEN '"gradient"'::jsonb
            WHEN 'blink_cursor_bar' THEN '"blink"'::jsonb
            ELSE COALESCE(style_json->'element'->'header_deco', '"none"'::jsonb)
          END),
        '{element,header_width}',
        CASE (style_json->'element'->>'header_deco')
          WHEN 'thin_accent_bar'  THEN '2'::jsonb
          WHEN 'thick_ribbon'    THEN '6'::jsonb
          WHEN 'gradient_strip'   THEN '4'::jsonb
          WHEN 'blink_cursor_bar' THEN '20'::jsonb
          ELSE COALESCE(style_json->'element'->'header_width', '6'::jsonb)
        END),
      '{element,side_accent}',
      CASE (style_json->'element'->>'side_accent')
        WHEN 'solid_side_bar'        THEN '"solid"'::jsonb
        WHEN 'gradient_side_bar'     THEN '"gradient"'::jsonb
        WHEN 'solid_side_bar_right'  THEN '"solid"'::jsonb
        WHEN 'gradient_side_bar_right' THEN '"gradient"'::jsonb
        WHEN 'line_number_column'    THEN '"line_number_column"'::jsonb
        WHEN 'notebook_binding'      THEN '"notebook_binding"'::jsonb
        ELSE COALESCE(style_json->'element'->'side_accent', '"none"'::jsonb)
      END),
    '{element,side_width}',
    CASE (style_json->'element'->>'side_accent')
      WHEN 'solid_side_bar'         THEN '3'::jsonb
      WHEN 'gradient_side_bar'      THEN '3'::jsonb
      WHEN 'solid_side_bar_right'   THEN '3'::jsonb
      WHEN 'gradient_side_bar_right' THEN '3'::jsonb
      WHEN 'line_number_column'     THEN '36'::jsonb
      WHEN 'notebook_binding'       THEN '28'::jsonb
      ELSE COALESCE(style_json->'element'->'side_width', '8'::jsonb)
    END),
  '{element,side_position}',
  CASE (style_json->'element'->>'side_accent')
    WHEN 'solid_side_bar_right'   THEN '"right"'::jsonb
    WHEN 'gradient_side_bar_right' THEN '"right"'::jsonb
    ELSE COALESCE(style_json->'element'->'side_position', '"left"'::jsonb)
  END)
WHERE style_json->'element' IS NOT NULL
  AND (
    style_json->'element'->>'header_deco' IN ('thin_accent_bar','thick_ribbon','gradient_strip','blink_cursor_bar')
    OR style_json->'element'->>'side_accent' IN ('solid_side_bar','gradient_side_bar','solid_side_bar_right','gradient_side_bar_right','line_number_column','notebook_binding')
    OR style_json->'element'->>'header_width' IS NULL
    OR style_json->'element'->>'side_width'  IS NULL
    OR style_json->'element'->>'side_position' IS NULL
  );

-- ----------------------------------------------------------------------------
-- 验证（取消注释查看结果）
-- ----------------------------------------------------------------------------
-- SELECT id, name,
--        style_json->'element'->>'header_deco'   AS header_deco,
--        style_json->'element'->>'header_width'  AS header_width,
--        style_json->'element'->>'side_accent'   AS side_accent,
--        style_json->'element'->>'side_width'    AS side_width,
--        style_json->'element'->>'side_position' AS side_position
-- FROM "STYLE_POOL"
-- WHERE style_json->'element' IS NOT NULL
-- ORDER BY id LIMIT 20;
--
-- SELECT sub_dim, value, sort_order, css_template
-- FROM style_element_options
-- WHERE sub_dim IN ('header_deco','side_accent') ORDER BY sub_dim, sort_order;
