-- layout_vertical_fix.sql
-- 日期: 2026-07-05
-- 描述: 修复 vertical flow 布局 + 2col grid 模板调整
-- 问题1: flow=vertical 时 grid 仍纵向堆叠 → 卡片极长，竖排文字无法换列
-- 问题2: 2col grid 固定 highlights+capsule 承担双栏 → highlights 在窄栏难看，title 无法进双栏
-- 修复1: flow=vertical CSS 加入 flex 覆盖 grid，横向排列 + max-height 限制高度
-- 修复2: 2col grid 模板改为 highlights 占整行(最宽)，title+capsule 承担双栏

-- ============================================================
-- 修复1: flow=vertical → flex 横向排列
-- ============================================================

UPDATE style_layout_options
SET css_template = '[data-style-layout-flow="vertical"]{--wm-date:vertical-rl;--wm-title:vertical-rl;--wm-highlights:vertical-rl;--wm-capsule:vertical-rl;display:flex;flex-direction:row-reverse;align-items:stretch;max-height:400px;gap:8px;padding:12px;}[data-style-layout-flow="vertical"]>.card-date,[data-style-layout-flow="vertical"]>.card-title,[data-style-layout-flow="vertical"]>.card-capsule{flex:0 0 auto;max-height:100%;overflow:hidden;}[data-style-layout-flow="vertical"]>.card-highlights{flex:1 1 auto;min-width:0;max-height:100%;overflow:hidden;}'
WHERE sub_dim = 'flow' AND value = 'vertical';

-- ============================================================
-- 修复2: 2col grid 模板 — highlights 归整行, title 进双栏
-- 旧: "date date" "title title" "highlights capsule"
-- 新: "date date" "title capsule" "highlights highlights"
-- ============================================================

-- 2col_equal: title+capsule 等宽双栏, highlights 整行
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_equal"] { grid-template-columns: 1fr 1fr; grid-template-areas: "date date" "title capsule" "highlights highlights"; }'
WHERE sub_dim = 'grid' AND value = '2col_equal';

-- 2col_left_wide: title 在宽栏(2fr), capsule 窄栏(1fr)
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_left_wide"] { grid-template-columns: 2fr 1fr; grid-template-areas: "date date" "title capsule" "highlights highlights"; }'
WHERE sub_dim = 'grid' AND value = '2col_left_wide';

-- 2col_right_wide: capsule 窄栏(1fr), title 在宽栏(2fr)
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_right_wide"] { grid-template-columns: 1fr 2fr; grid-template-areas: "date date" "capsule title" "highlights highlights"; }'
WHERE sub_dim = 'grid' AND value = '2col_right_wide';

-- 2col_left_narrow: capsule 窄栏(1fr), title 在宽栏(3fr)
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_left_narrow"] { grid-template-columns: 1fr 3fr; grid-template-areas: "date date" "capsule title" "highlights highlights"; }'
WHERE sub_dim = 'grid' AND value = '2col_left_narrow';

-- 2col_right_narrow: title 在宽栏(3fr), capsule 窄栏(1fr)
UPDATE style_layout_options
SET css_template = '.gallery-card[data-style-layout-grid="2col_right_narrow"] { grid-template-columns: 3fr 1fr; grid-template-areas: "date date" "title capsule" "highlights highlights"; }'
WHERE sub_dim = 'grid' AND value = '2col_right_narrow';
