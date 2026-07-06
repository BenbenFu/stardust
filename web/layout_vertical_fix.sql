-- layout_vertical_fix.sql
-- 日期: 2026-07-06 (v2 修订)
-- 描述: 修复 vertical flow 布局 + 2col grid 模板调整
--
-- 问题1: flow=vertical 用 display:flex 覆盖 grid → 所有 grid 模板失效，竖排卡片只有一种格式
-- 问题2: 2col grid 把 highlights 放整行 → highlights 不在双栏内，用户要 highlights 在宽栏内
--
-- 修复1: flow=vertical 改用 writing-mode:vertical-rl 设在 grid 容器上
--        CSS 规范: 容器 writing-mode=vertical-rl 时，grid 行/列方向自动转置
--        不同 grid 模板会产生不同布局，不再用 flex 覆盖
-- 修复2: 2col grid 模板改为 highlights 跨 2 行占宽栏，title+capsule 在窄栏堆叠

-- ============================================================
-- 修复1: flow=vertical → writing-mode 转置 grid
-- ============================================================

UPDATE style_layout_options
SET css_template = '[data-style-layout-flow="vertical"]{--wm-date:vertical-rl;--wm-title:vertical-rl;--wm-highlights:vertical-rl;--wm-capsule:vertical-rl;writing-mode:vertical-rl;max-height:400px;overflow:hidden;}'
WHERE sub_dim = 'flow' AND value = 'vertical';

-- ============================================================
-- 修复2: 2col grid 模板 — highlights 在宽栏跨2行, title+capsule 在窄栏堆叠
-- 旧: "date date" "title capsule" "highlights highlights" (highlights 整行)
-- 新: "date date" "highlights title" "highlights capsule" (highlights 跨2行占宽栏)
-- ============================================================

-- 2col_equal: highlights 在左栏(1fr), title+capsule 在右栏(1fr)
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_equal"] { grid-template-columns: 1fr 1fr; grid-template-areas: "date date" "highlights title" "highlights capsule"; }'
WHERE sub_dim = 'grid' AND value = '2col_equal';

-- 2col_left_wide: highlights 在左宽栏(2fr), title+capsule 在右窄栏(1fr)
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_left_wide"] { grid-template-columns: 2fr 1fr; grid-template-areas: "date date" "highlights title" "highlights capsule"; }'
WHERE sub_dim = 'grid' AND value = '2col_left_wide';

-- 2col_right_wide: highlights 在右宽栏(2fr), title+capsule 在左窄栏(1fr)
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_right_wide"] { grid-template-columns: 1fr 2fr; grid-template-areas: "date date" "title highlights" "capsule highlights"; }'
WHERE sub_dim = 'grid' AND value = '2col_right_wide';

-- 2col_left_narrow: highlights 在右宽栏(3fr), title+capsule 在左窄栏(1fr)
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_left_narrow"] { grid-template-columns: 1fr 3fr; grid-template-areas: "date date" "title highlights" "capsule highlights"; }'
WHERE sub_dim = 'grid' AND value = '2col_left_narrow';

-- 2col_right_narrow: highlights 在左宽栏(3fr), title+capsule 在右窄栏(1fr)
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_right_narrow"] { grid-template-columns: 3fr 1fr; grid-template-areas: "date date" "highlights title" "highlights capsule"; }'
WHERE sub_dim = 'grid' AND value = '2col_right_narrow';
