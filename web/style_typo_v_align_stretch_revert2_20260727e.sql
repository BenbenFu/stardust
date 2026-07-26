-- ============================================================
-- 回退 v_align「撑满 stretch」到 20260727c 基线（仅 flex-grow:1，无字距散开）
-- 对应修复：style_typo_v_align_stretch_fix2_20260727e.sql
-- ============================================================

UPDATE style_typo_options
SET css_template = '.gallery-card[data-style-typo-v-align-title="stretch"] .fx-wrap[data-fx="title"]{margin-top:0;margin-bottom:0;flex-grow:1} .gallery-card[data-style-typo-v-align-date="stretch"] .fx-wrap[data-fx="date"]{margin-top:0;margin-bottom:0;flex-grow:1} .gallery-card[data-style-typo-v-align-capsule="stretch"] .fx-wrap[data-fx="capsule"]{margin-top:0;margin-bottom:0;flex-grow:1} .gallery-card[data-style-typo-v-align-highlights="stretch"] .fx-wrap[data-fx="highlights"]{margin-top:0;margin-bottom:0;flex-grow:1}'
WHERE sub_dim='v_align' AND value='stretch';
