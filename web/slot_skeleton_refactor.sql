-- slot_skeleton_refactor.sql
-- 日期: 2026-07-06
-- 描述: Grid 层纯骨架化 — 从字段名改为抽象槽位 slot-a/b/c/d
--
-- 核心架构变更:
-- 1. 所有 grid 模板的 grid-template-areas 从 date/title/highlights/capsule 改为 slot-a/b/c/d
-- 2. 默认 slot 映射: a=date, b=title, c=highlights, d=capsule
-- 3. style_json 新增 layout.slot_assignment 字段 (字段→槽位映射)
-- 4. 渲染器全权计算 writing-mode (从 flow_vertical + slot_assignment 推导)
-- 5. flow 降级为预设: horizontal=全不勾 / vertical=全勾 / mixed=勾一个
-- 6. flow_vertical 的 css_template 清空 (渲染器通过 inline style 处理)
-- 7. BASE_CSS: .card-slot-a/b/c/d 提供 grid-area + writing-mode
--    .card-date/title/highlights/capsule 仅保留样式属性
--
-- 涉及文件:
--   web/style-engine.js — BASE_CSS + ATTR_MAP + buildCardHtml + renderStyleJson
--   web/capsule-preview.html — 4个slot下拉栏 + flow预设联动
--   DB: 17条grid + 3条flow + 4条flow_vertical = 24条PATCH

-- ============================================================
-- 1. Grid 模板: 17 条 — 字段名改为 slot-a/b/c/d
-- ============================================================

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="single"] { grid-template-columns: 1fr; grid-template-areas: "slot-a" "slot-b" "slot-c" "slot-d"; }'
WHERE sub_dim = 'grid' AND value = 'single';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_equal"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-a slot-a" "slot-c slot-b" "slot-c slot-d"; }'
WHERE sub_dim = 'grid' AND value = '2col_equal';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_left_wide"] { grid-template-columns: 2fr 1fr; grid-template-areas: "slot-a slot-a" "slot-c slot-b" "slot-c slot-d"; }'
WHERE sub_dim = 'grid' AND value = '2col_left_wide';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_right_wide"] { grid-template-columns: 1fr 2fr; grid-template-areas: "slot-a slot-a" "slot-b slot-c" "slot-d slot-c"; }'
WHERE sub_dim = 'grid' AND value = '2col_right_wide';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_left_narrow"] { grid-template-columns: 1fr 3fr; grid-template-areas: "slot-a slot-a" "slot-b slot-c" "slot-d slot-c"; }'
WHERE sub_dim = 'grid' AND value = '2col_left_narrow';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_right_narrow"] { grid-template-columns: 3fr 1fr; grid-template-areas: "slot-a slot-a" "slot-c slot-b" "slot-c slot-d"; }'
WHERE sub_dim = 'grid' AND value = '2col_right_narrow';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="3col_equal"] { grid-template-columns: 1fr 1fr 1fr; grid-template-areas: "slot-a slot-b slot-d" "slot-c slot-c slot-c"; }'
WHERE sub_dim = 'grid' AND value = '3col_equal';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="3col_left_focus"] { grid-template-columns: 2fr 1fr 1fr; grid-template-areas: "slot-b slot-b slot-b" "slot-c slot-a slot-d"; }'
WHERE sub_dim = 'grid' AND value = '3col_left_focus';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="3col_right_focus"] { grid-template-columns: 1fr 1fr 2fr; grid-template-areas: "slot-b slot-b slot-b" "slot-a slot-d slot-c"; }'
WHERE sub_dim = 'grid' AND value = '3col_right_focus';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="sidebar_left"] { grid-template-columns: 100px 1fr; grid-template-areas: "slot-a slot-b" "slot-d slot-c"; }'
WHERE sub_dim = 'grid' AND value = 'sidebar_left';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="sidebar_right"] { grid-template-columns: 1fr 100px; grid-template-areas: "slot-b slot-a" "slot-c slot-d"; }'
WHERE sub_dim = 'grid' AND value = 'sidebar_right';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="sidebar_both"] { grid-template-columns: 80px 1fr 80px; grid-template-areas: "slot-a slot-b slot-d" "slot-a slot-c slot-d"; }'
WHERE sub_dim = 'grid' AND value = 'sidebar_both';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="top_split"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-a slot-d" "slot-b slot-b" "slot-c slot-c"; }'
WHERE sub_dim = 'grid' AND value = 'top_split';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="bottom_split"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-b slot-b" "slot-c slot-c" "slot-a slot-d"; }'
WHERE sub_dim = 'grid' AND value = 'bottom_split';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="hero"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-b slot-b" "slot-a slot-d" "slot-c slot-c"; }'
WHERE sub_dim = 'grid' AND value = 'hero';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="inverted"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-c slot-c" "slot-b slot-b" "slot-a slot-d"; }'
WHERE sub_dim = 'grid' AND value = 'inverted';

UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="timeline"] { grid-template-columns: 60px 1fr; grid-template-areas: "slot-a slot-b" "slot-a slot-c" "slot-a slot-d"; border-left: 2px solid var(--card-accent, #ccc); padding-left: 12px; }'
WHERE sub_dim = 'grid' AND value = 'timeline';

-- ============================================================
-- 2. Flow 记录: 3 条 — slot-based --wm-a/b/c/d (作为 fallback)
-- ============================================================

UPDATE style_layout_options
SET css_template = '[data-style-layout-flow="horizontal"]{--wm-a:horizontal-tb;--wm-b:horizontal-tb;--wm-c:horizontal-tb;--wm-d:horizontal-tb;}'
WHERE sub_dim = 'flow' AND value = 'horizontal';

UPDATE style_layout_options
SET css_template = '[data-style-layout-flow="vertical"]{--wm-a:vertical-rl;--wm-b:vertical-rl;--wm-c:vertical-rl;--wm-d:vertical-rl;writing-mode:vertical-rl;max-height:400px;overflow:hidden;}'
WHERE sub_dim = 'flow' AND value = 'vertical';

UPDATE style_layout_options
SET css_template = '[data-style-layout-flow="mixed"]{--wm-a:horizontal-tb;--wm-b:horizontal-tb;--wm-c:horizontal-tb;--wm-d:horizontal-tb;}'
WHERE sub_dim = 'flow' AND value = 'mixed';

-- ============================================================
-- 3. flow_vertical 记录: 4 条 — 清空 css_template (渲染器全权处理)
-- ============================================================

UPDATE style_layout_options SET css_template = '' WHERE sub_dim = 'flow_vertical' AND value = 'date';
UPDATE style_layout_options SET css_template = '' WHERE sub_dim = 'flow_vertical' AND value = 'title';
UPDATE style_layout_options SET css_template = '' WHERE sub_dim = 'flow_vertical' AND value = 'highlights';
UPDATE style_layout_options SET css_template = '' WHERE sub_dim = 'flow_vertical' AND value = 'capsule';
