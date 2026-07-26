-- ============================================================
-- 修正 h_align「撑满 stretch」：让竖排 / 横排都能真正撑满
-- ------------------------------------------------------------
-- 问题（已用 node 渲染验证）：
--   原 20260727c 模板只对水平文字(.card-X:not(.is-vertical))补 text-align:justify，
--   竖排字段只剩 margin:0；而竖排槽位 .card-slot-vertical 的 align-items:flex-start
--   让 .fx-wrap 取内容宽，margin:0 与 start(margin-right:auto) 停在同一左侧位置
--   → 竖排下 stretch 与 start 完全不可区分 → 用户感知"撑满没作用"。
--   另外 injectDynamicStyles 是把 dimensionCache.typo 每行 css_template 全量注入，
--   故链路无 bug，纯属定义导致盒模型下不可见。
-- 修正：
--   · .fx-wrap{width:100%}  → 盒撑满槽宽（竖排列占满卡宽，区别于 start/center/end 的内容宽 reposition）
--   · .card-X:not(.is-vertical){text-align:justify; text-align-last:justify; text-justify:inter-character}
--        → 横排(水平文字)两端对齐；⚠️ 必须 text-align-last:justify：单行/最后一行默认不 justify，
--          漏掉则短文字散不开、与栏级 left 不可区分（用户实测：center/right 能覆盖 left，唯独 stretch 不能）。
--        → 限定 :not(.is-vertical)：竖排撑满由 v_align 单独管，避免 width:100% 把竖排窄框错误拉宽。
-- 仅改 h_align stretch 一行；v_align stretch 见 20260727e（flex-grow + is-vertical justify）。
-- ============================================================

UPDATE style_typo_options
SET css_template = '.gallery-card[data-style-typo-h-align-title="stretch"] .fx-wrap[data-fx="title"]{margin-left:0;margin-right:0;width:100%} .gallery-card[data-style-typo-h-align-title="stretch"] .card-title:not(.is-vertical){text-align:justify;text-align-last:justify;text-justify:inter-character} .gallery-card[data-style-typo-h-align-date="stretch"] .fx-wrap[data-fx="date"]{margin-left:0;margin-right:0;width:100%} .gallery-card[data-style-typo-h-align-date="stretch"] .card-date:not(.is-vertical){text-align:justify;text-align-last:justify;text-justify:inter-character} .gallery-card[data-style-typo-h-align-capsule="stretch"] .fx-wrap[data-fx="capsule"]{margin-left:0;margin-right:0;width:100%} .gallery-card[data-style-typo-h-align-capsule="stretch"] .card-capsule:not(.is-vertical){text-align:justify;text-align-last:justify;text-justify:inter-character} .gallery-card[data-style-typo-h-align-highlights="stretch"] .fx-wrap[data-fx="highlights"]{margin-left:0;margin-right:0;width:100%} .gallery-card[data-style-typo-h-align-highlights="stretch"] .card-highlights:not(.is-vertical){text-align:justify;text-align-last:justify;text-justify:inter-character}'
WHERE sub_dim='h_align' AND value='stretch';
