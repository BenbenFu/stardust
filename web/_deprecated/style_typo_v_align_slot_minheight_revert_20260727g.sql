-- ============================================================
-- 回退 20260727g：移除 v_align center/end/stretch 模板中追加的槽位 min-height 规则
-- ------------------------------------------------------------
-- 仅删掉本迭代追加的 .card-slot[data-field="..."]{min-height:32px} 片段，
-- 不影响各模板原有的 .fx-wrap / .card-X 规则。
-- 注意：本回退只还原 DB；引擎侧的 data-field 属性与移除全局 min-height 需另行
--       git revert 对应 style-engine.js 提交（或手动还原），并重新硬刷新三入口。
-- ============================================================

UPDATE style_typo_options
SET css_template = regexp_replace(
  css_template,
  ' \.gallery-card\[data-style-typo-v-align-(title|date|capsule|highlights)="(center|end|stretch)"\] \.card-slot\[data-field="(title|date|capsule|highlights)"\]\{min-height:32px\}',
  '', 'g')
WHERE sub_dim='v_align' AND value IN ('center','end','stretch');
