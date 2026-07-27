-- ============================================================
-- 字段级双轴对齐：补回「撑满 stretch」选项
-- ------------------------------------------------------------
-- 背景：20260727a 重建 h_align / v_align 时只建了 start/center/end，
--       漏掉了旧的「撑满 / 两端对齐」选项（横向=text-align:justify，
--       纵向=盒填满槽高）。现按同构 DB 驱动方式补回，无需改引擎/预览页。
-- 作用域：data-attr 由引擎按 perElement 发射为
--   data-style-typo-h-align-<field> / data-style-typo-v-align-<field>（挂在 .gallery-card 根）
-- 落点：.fx-wrap[data-fx="<field>"]（字段包裹层，flex item）
--      + .card-<field>:not(.is-vertical)（仅水平文字，撑满行宽）
-- 幂等：用 WHERE NOT EXISTS，重复执行不会插重复行。
-- ============================================================

-- ---------- h_align：字段水平撑满 ----------
INSERT INTO style_typo_options (sub_dim, value, label, description, gradient, css_template, sort_order)
SELECT 'h_align', 'stretch', '撑满 stretch',
 '字段水平撑满：盒填满槽宽 + 横排文字两端对齐(justify)；竖排=整列占满卡宽',
 '{"date":"inherit","title":"inherit","capsule":"inherit","highlights":"inherit"}',
 '.gallery-card[data-style-typo-h-align-title="stretch"] .fx-wrap[data-fx="title"]{margin-left:0;margin-right:0} .gallery-card[data-style-typo-h-align-title="stretch"] .card-title:not(.is-vertical){text-align:justify} .gallery-card[data-style-typo-h-align-date="stretch"] .fx-wrap[data-fx="date"]{margin-left:0;margin-right:0} .gallery-card[data-style-typo-h-align-date="stretch"] .card-date:not(.is-vertical){text-align:justify} .gallery-card[data-style-typo-h-align-capsule="stretch"] .fx-wrap[data-fx="capsule"]{margin-left:0;margin-right:0} .gallery-card[data-style-typo-h-align-capsule="stretch"] .card-capsule:not(.is-vertical){text-align:justify} .gallery-card[data-style-typo-h-align-highlights="stretch"] .fx-wrap[data-fx="highlights"]{margin-left:0;margin-right:0} .gallery-card[data-style-typo-h-align-highlights="stretch"] .card-highlights:not(.is-vertical){text-align:justify}',
 214
WHERE NOT EXISTS (SELECT 1 FROM style_typo_options WHERE sub_dim='h_align' AND value='stretch');

-- ---------- v_align：字段垂直撑满 ----------
INSERT INTO style_typo_options (sub_dim, value, label, description, gradient, css_template, sort_order)
SELECT 'v_align', 'stretch', '撑满 stretch',
 '字段垂直撑满：盒填满整个槽高（flex-grow:1，横竖排通用）',
 '{"date":"inherit","title":"inherit","capsule":"inherit","highlights":"inherit"}',
 '.gallery-card[data-style-typo-v-align-title="stretch"] .fx-wrap[data-fx="title"]{margin-top:0;margin-bottom:0;flex-grow:1} .gallery-card[data-style-typo-v-align-date="stretch"] .fx-wrap[data-fx="date"]{margin-top:0;margin-bottom:0;flex-grow:1} .gallery-card[data-style-typo-v-align-capsule="stretch"] .fx-wrap[data-fx="capsule"]{margin-top:0;margin-bottom:0;flex-grow:1} .gallery-card[data-style-typo-v-align-highlights="stretch"] .fx-wrap[data-fx="highlights"]{margin-top:0;margin-bottom:0;flex-grow:1}',
 224
WHERE NOT EXISTS (SELECT 1 FROM style_typo_options WHERE sub_dim='v_align' AND value='stretch');
