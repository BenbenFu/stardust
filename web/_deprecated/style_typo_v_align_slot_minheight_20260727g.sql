-- ============================================================
-- 字段级 v_align 垂直余量「按需化」（2026-07-27g）
-- ------------------------------------------------------------
-- 配套引擎变更：style-engine.js ?v=20260727g
--   · 槽位 div 新增 data-field="<field>" 属性（DB 模板落点用）
--   · 移除 BASE_CSS 中 .card-slot-a/b/c/d 的全局 min-height:32px
-- 目的：
--   短字段(date/capsule)默认顶对齐(=v_align start/inherit)时，不再把 32px 余量变成「下方空白」；
--   仅当字段显式选了 center / end / stretch 时，才给该字段所在槽位补 min-height:32px，
--   从而 v_align 非默认选项仍有垂直余量可分配（功能不丢），默认零余量→紧凑。
-- 落点：.card-slot[data-field="<field>"] —— 引擎按 slot_assignment 在对应槽位写 data-field，
--       不写死 slot-a/b/c/d，故换槽位映射也正确。
-- 幂等：guard 检测 css_template 是否已含 card-slot[data-field，防重复追加。
-- 回退：style_typo_v_align_slot_minheight_revert_20260727g.sql
-- ============================================================

UPDATE style_typo_options
SET css_template = css_template
  || ' .gallery-card[data-style-typo-v-align-title="center"] .card-slot[data-field="title"]{min-height:32px}'
  || ' .gallery-card[data-style-typo-v-align-date="center"] .card-slot[data-field="date"]{min-height:32px}'
  || ' .gallery-card[data-style-typo-v-align-capsule="center"] .card-slot[data-field="capsule"]{min-height:32px}'
  || ' .gallery-card[data-style-typo-v-align-highlights="center"] .card-slot[data-field="highlights"]{min-height:32px}'
WHERE sub_dim='v_align' AND value='center'
  AND css_template NOT LIKE '%card-slot[data-field%';

UPDATE style_typo_options
SET css_template = css_template
  || ' .gallery-card[data-style-typo-v-align-title="end"] .card-slot[data-field="title"]{min-height:32px}'
  || ' .gallery-card[data-style-typo-v-align-date="end"] .card-slot[data-field="date"]{min-height:32px}'
  || ' .gallery-card[data-style-typo-v-align-capsule="end"] .card-slot[data-field="capsule"]{min-height:32px}'
  || ' .gallery-card[data-style-typo-v-align-highlights="end"] .card-slot[data-field="highlights"]{min-height:32px}'
WHERE sub_dim='v_align' AND value='end'
  AND css_template NOT LIKE '%card-slot[data-field%';

UPDATE style_typo_options
SET css_template = css_template
  || ' .gallery-card[data-style-typo-v-align-title="stretch"] .card-slot[data-field="title"]{min-height:32px}'
  || ' .gallery-card[data-style-typo-v-align-date="stretch"] .card-slot[data-field="date"]{min-height:32px}'
  || ' .gallery-card[data-style-typo-v-align-capsule="stretch"] .card-slot[data-field="capsule"]{min-height:32px}'
  || ' .gallery-card[data-style-typo-v-align-highlights="stretch"] .card-slot[data-field="highlights"]{min-height:32px}'
WHERE sub_dim='v_align' AND value='stretch'
  AND css_template NOT LIKE '%card-slot[data-field%';
