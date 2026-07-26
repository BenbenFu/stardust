-- ============================================================
-- 跨轴对齐 cross_alignment_mode（方案 A：逐字段块轴独立控制）
-- 目标：竖排字段缺一个「水平方向」独立对齐控制，本维度补齐。
--   横排字段：块轴=竖直（等价于 block_align 的逐字段覆盖）
--   竖排字段：块轴=水平（即此前缺失的水平独立控制）
-- 物理方向随 writing-mode 自动翻转（CSS margin-block 逻辑属性）。
-- 落地机制：DB css_template 在字段包裹层 .fx-wrap[data-fx="<field>"] 上设置 margin-block:auto。
--   .card-slot-x 已由引擎 BASE_CSS 改为 flex 列容器（display:flex;flex-direction:column），
--   故 .fx-wrap 作为 flex item 的 margin-block:auto 可沿块轴定位。
-- 与 alignment_mode（行内轴 / text-align）互不冲突、互不重叠。
-- ============================================================

INSERT INTO style_typo_options (sub_dim, value, label, description, gradient, css_template, sort_order) VALUES
('cross_alignment_mode', 'start', '靠起点 start',
 '字段沿块轴靠起点：横排=顶部 / 竖排=右侧',
 '{"date":"start","title":"start","capsule":"start","highlight":"start"}',
 '.gallery-card[data-style-typo-cross-alignment-mode-title="start"] .fx-wrap[data-fx="title"]{margin-block-end:auto}
.gallery-card[data-style-typo-cross-alignment-mode-date="start"] .fx-wrap[data-fx="date"]{margin-block-end:auto}
.gallery-card[data-style-typo-cross-alignment-mode-capsule="start"] .fx-wrap[data-fx="capsule"]{margin-block-end:auto}
.gallery-card[data-style-typo-cross-alignment-mode-highlights="start"] .fx-wrap[data-fx="highlights"]{margin-block-end:auto}', 201),
('cross_alignment_mode', 'center', '居中 center',
 '字段沿块轴居中：横排=竖直居中 / 竖排=水平居中',
 '{"date":"center","title":"center","capsule":"center","highlight":"center"}',
 '.gallery-card[data-style-typo-cross-alignment-mode-title="center"] .fx-wrap[data-fx="title"]{margin-block:auto}
.gallery-card[data-style-typo-cross-alignment-mode-date="center"] .fx-wrap[data-fx="date"]{margin-block:auto}
.gallery-card[data-style-typo-cross-alignment-mode-capsule="center"] .fx-wrap[data-fx="capsule"]{margin-block:auto}
.gallery-card[data-style-typo-cross-alignment-mode-highlights="center"] .fx-wrap[data-fx="highlights"]{margin-block:auto}', 202),
('cross_alignment_mode', 'end', '靠终点 end',
 '字段沿块轴靠终点：横排=底部 / 竖排=左侧',
 '{"date":"end","title":"end","capsule":"end","highlight":"end"}',
 '.gallery-card[data-style-typo-cross-alignment-mode-title="end"] .fx-wrap[data-fx="title"]{margin-block-start:auto}
.gallery-card[data-style-typo-cross-alignment-mode-date="end"] .fx-wrap[data-fx="date"]{margin-block-start:auto}
.gallery-card[data-style-typo-cross-alignment-mode-capsule="end"] .fx-wrap[data-fx="capsule"]{margin-block-start:auto}
.gallery-card[data-style-typo-cross-alignment-mode-highlights="end"] .fx-wrap[data-fx="highlights"]{margin-block-start:auto}', 203);
