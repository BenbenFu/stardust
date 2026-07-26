-- ============================================================
-- 修正 v_align「撑满 stretch」：让竖排 / 横排都能真正沿槽高撑满
-- ------------------------------------------------------------
-- 问题（已定位，与 20260727d 的 h_align 同类根因）：
--   原 20260727c 模板只对 .fx-wrap 补 flex-grow:1。在竖排槽位（.card-slot-vertical，
--   flex-direction:column，主轴=高度）下，flex-grow:1 确实把 .fx-wrap 撑满槽高，
--   但内层 .card-XXX.is-vertical 文字元素仍是「内容高」且停在盒顶 → 竖排短文字
--   （capsule/title）与 v_align=start 完全不可区分 → 用户感知"撑满没作用"。
--   根因：.fx-wrap 撑高了，但文字元素没跟着撑高、也没两端对齐，故字距不散开。
-- 修正（纯 DB 驱动，不改引擎/预览页，无需 bump 引擎版本）：
--   · .fx-wrap[data-fx]{flex-grow:1; display:flex; flex-direction:column}
--        → 字段盒撑满槽高（主轴=高度，横竖排通用；竖排下盒仍按 align-items:flex-start 取内容宽，
--          不破坏 h_align 的水平定位）。
--   · .card-X{flex:1 1 auto; width:100%}
--        → 文字元素撑满盒高（横竖排通用，盒填槽高但文字顶对齐）。
--   · .card-X.is-vertical{text-align:justify; text-align-last:justify; text-justify:inter-character}
--        → 仅竖排：text-align 沿列高(内联轴)两端对齐，短文字字距沿列高散开 → 真正"撑满"。
--          ⚠️ 必须补 text-align-last:justify：竖排短字段整段只有「一行/最后一行」，
--             text-align:justify 默认跳过最后一行，漏掉它字距就不会散开（演示页曾因此两卡一致）。
--          （横排不挂此规则，避免 v_align 顺手把横排文字也两端对齐，那是 h_align 的职责。）
--   · 兼容 deco box 嵌套：对中间 .fx-wrap[data-style-deco-box] 也透传 flex 链，
--        使带框字段同样能撑满（无框字段本就命中，无副作用）。
-- 验证：改后硬刷新(Ctrl+Shift+R)重拉 dimensionCache；竖排短字段选「字段-垂直对齐-撑满」
--       应与长字段同高、字距沿列散开；横排多行字段两端对齐行宽。
-- 回退：style_typo_v_align_stretch_revert2_20260727e.sql
-- ============================================================

UPDATE style_typo_options
SET css_template = '.gallery-card[data-style-typo-v-align-title="stretch"] .fx-wrap[data-fx="title"]{margin-top:0;margin-bottom:0;flex-grow:1;display:flex;flex-direction:column} .gallery-card[data-style-typo-v-align-title="stretch"] .fx-wrap[data-fx="title"] .fx-wrap[data-style-deco-box]{flex:1 1 auto;display:flex;flex-direction:column} .gallery-card[data-style-typo-v-align-title="stretch"] .card-title{flex:1 1 auto;width:100%} .gallery-card[data-style-typo-v-align-title="stretch"] .card-title.is-vertical{text-align:justify;text-align-last:justify;text-justify:inter-character} .gallery-card[data-style-typo-v-align-date="stretch"] .fx-wrap[data-fx="date"]{margin-top:0;margin-bottom:0;flex-grow:1;display:flex;flex-direction:column} .gallery-card[data-style-typo-v-align-date="stretch"] .fx-wrap[data-fx="date"] .fx-wrap[data-style-deco-box]{flex:1 1 auto;display:flex;flex-direction:column} .gallery-card[data-style-typo-v-align-date="stretch"] .card-date{flex:1 1 auto;width:100%} .gallery-card[data-style-typo-v-align-date="stretch"] .card-date.is-vertical{text-align:justify;text-align-last:justify;text-justify:inter-character} .gallery-card[data-style-typo-v-align-capsule="stretch"] .fx-wrap[data-fx="capsule"]{margin-top:0;margin-bottom:0;flex-grow:1;display:flex;flex-direction:column} .gallery-card[data-style-typo-v-align-capsule="stretch"] .fx-wrap[data-fx="capsule"] .fx-wrap[data-style-deco-box]{flex:1 1 auto;display:flex;flex-direction:column} .gallery-card[data-style-typo-v-align-capsule="stretch"] .card-capsule{flex:1 1 auto;width:100%} .gallery-card[data-style-typo-v-align-capsule="stretch"] .card-capsule.is-vertical{text-align:justify;text-align-last:justify;text-justify:inter-character} .gallery-card[data-style-typo-v-align-highlights="stretch"] .fx-wrap[data-fx="highlights"]{margin-top:0;margin-bottom:0;flex-grow:1;display:flex;flex-direction:column} .gallery-card[data-style-typo-v-align-highlights="stretch"] .fx-wrap[data-fx="highlights"] .fx-wrap[data-style-deco-box]{flex:1 1 auto;display:flex;flex-direction:column} .gallery-card[data-style-typo-v-align-highlights="stretch"] .card-highlights{flex:1 1 auto;width:100%} .gallery-card[data-style-typo-v-align-highlights="stretch"] .card-highlights.is-vertical{text-align:justify;text-align-last:justify;text-justify:inter-character}'
WHERE sub_dim='v_align' AND value='stretch';
