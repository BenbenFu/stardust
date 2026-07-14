-- ============================================================================
-- style_layout_redirect_fix_20260713.sql
-- 修正版 Part A：把 layout 维度模板选择器从重 .gallery-card 重定向到 band/content 容器
--
-- 背景（问题 2）：
--   原 style_element_bands_refactor_20260713.sql 的 Part A 用 regexp_replace 做重定向，
--   但因为旧模板选择器格式差异（前置选择器 / 空格 / 换行 / 多选择器并列）正则没命中，
--   导致所有 grid / block_align / inline_align / density 模板仍挂在 .gallery-card 上。
--   而 .gallery-card 现在是纵向 flex 容器（排列顶栏 + 内容区），display:flex 与
--   display:grid 冲突，grid 规则完全不生效，内容回退成块级垂直堆叠（只有 single 看起来正常）。
--
-- 本脚本用「精确整行 UPDATE」替代正则，100% 命中。可重复执行（WHERE 条件精确）。
--
-- 重定向目标：
--   grid / block_align / inline_align  → .gallery-card[...] .card-content--slots
--     （.card-content--slots 是真正的 grid 容器，slot-a..d 是它的子元素）
--   density  → 仅保留 --layout-gap，删除 padding
--     （padding/留白交给 style-engine 的 --band-inset 机制，由 capsule-preview 的
--       「Band Inset 留白」勾选框控制：勾选=内容内缩12px，取消=贴边0px；band 始终贴边）
-- ============================================================================

-- ----------------------------------------------------------------------------
-- grid：slot 网格现在在 .card-content--slots 上
-- ----------------------------------------------------------------------------
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

-- ----------------------------------------------------------------------------
-- block_align：slot 在网格内的垂直对齐 → .card-content--slots
-- ----------------------------------------------------------------------------
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-block-align="center"] .card-content--slots { align-items: center; }' WHERE sub_dim='block_align' AND value='center';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-block-align="end"] .card-content--slots { align-items: end; }' WHERE sub_dim='block_align' AND value='end';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-block-align="start"] .card-content--slots { align-items: start; }' WHERE sub_dim='block_align' AND value='start';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-block-align="stretch"] .card-content--slots { align-items: stretch; }' WHERE sub_dim='block_align' AND value='stretch';

-- ----------------------------------------------------------------------------
-- inline_align：slot 内水平对齐 → .card-content--slots
-- ----------------------------------------------------------------------------
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-inline-align="center"] .card-content--slots { justify-items: center; text-align: center; }' WHERE sub_dim='inline_align' AND value='center';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-inline-align="end"] .card-content--slots { justify-items: end; text-align: end; }' WHERE sub_dim='inline_align' AND value='end';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-inline-align="justify"] .card-content--slots { justify-items: stretch; text-align: justify; }' WHERE sub_dim='inline_align' AND value='justify';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-inline-align="start"] .card-content--slots { justify-items: start; text-align: start; }' WHERE sub_dim='inline_align' AND value='start';

-- ----------------------------------------------------------------------------
-- density：删除 padding（留白交给 --band-inset），仅保留 --layout-gap
-- ----------------------------------------------------------------------------
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-density="dense"] { --layout-gap: 4px; }' WHERE sub_dim='density' AND value='dense';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-density="normal"] { --layout-gap: 8px; }' WHERE sub_dim='density' AND value='normal';
UPDATE style_layout_options SET css_template = '.gallery-card[data-style-layout-density="sparse"] { --layout-gap: 16px; }' WHERE sub_dim='density' AND value='sparse';

-- ============================================================================
-- 安全网（问题 1）：把已知仍存多行 \r\n 的 element 模板归一为单行 canonical 形式
-- 用户已在管理界面手工修复；此处幂等重设，确保无残留换行/多余空格。
-- ============================================================================
UPDATE style_element_options SET css_template = '.gallery-card[data-style-element-header="solid"] .card-header-band { background: var(--card-accent, #ccc); }' WHERE sub_dim='header_deco' AND value='solid';
UPDATE style_element_options SET css_template = '.gallery-card[data-style-element-side="line_number_column"] .card-side-band { background: color-mix(in srgb, var(--card-bg, #fff) 90%, var(--card-text, #000) 10%); border-right: 1px solid var(--card-muted, #bbb); } .gallery-card[data-style-element-side="line_number_column"] { counter-reset: line-no; } .gallery-card[data-style-element-side="line_number_column"] .card-highlight-item { counter-increment: line-no; position: relative; } .gallery-card[data-style-element-side="line_number_column"] .card-highlight-item::before { content: counter(line-no); position: absolute; left: calc(-1 * var(--side-band-size, 8px) - 2px); width: calc(var(--side-band-size, 8px) - 4px); text-align: right; color: var(--card-muted, #999); font-size: 0.75em; font-family: monospace; user-select: none; }' WHERE sub_dim='side_accent' AND value='line_number_column';
UPDATE style_element_options SET css_template = '.gallery-card[data-style-element-side="notebook_binding"] .card-side-band { background-color: var(--card-muted, #bbb); background-image: radial-gradient(circle at center, var(--card-bg, #fff) 2px, transparent 2.5px); background-size: 100% 16px; background-repeat: repeat-y; }' WHERE sub_dim='side_accent' AND value='notebook_binding';

-- ============================================================================
-- 验证（取消注释查看）
-- ============================================================================
-- SELECT sub_dim, value, css_template FROM style_layout_options
-- WHERE sub_dim IN ('grid','block_align','inline_align','density') ORDER BY sub_dim, value;
