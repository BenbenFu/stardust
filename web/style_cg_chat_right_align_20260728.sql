-- ============================================================
-- 容器组·右侧单条消息（cg_chat_message_right）气泡对齐修复
-- 日期：2026-07-28
-- 问题：右带布局 2col_right_narrow = grid-template-columns: 1fr auto，
--       消息槽 .cg-content 在 1fr 列内默认贴列起点（左侧），
--       被 max-width:80% 截短后剩余 20% 空隙留在右侧（紧贴头像处出现间隙），
--       视觉上「消息顶在卡片左缘，右边反而空一截」。
-- 修复：.cg-content 补 justify-self:end，把气泡推到列尾贴近右头像；
--       气泡内部文字对齐不受影响（仍由 typo/deco 模板控制）。
-- 幂等：直接整体覆盖 extra_css（该行 extra_css 仅含以下两条规则）。
-- ============================================================

UPDATE style_container_group_options
SET extra_css = '.container-group.cg_chat_message_right .cg-avatar { align-self: flex-start; }
     .container-group.cg_chat_message_right .cg-content { max-width: 80%; justify-self: end; }'
WHERE group_code = 'cg_chat_message_right';

-- ============================================================
-- 回退（还原到修复前）
-- ============================================================
-- UPDATE style_container_group_options
-- SET extra_css = '.container-group.cg_chat_message_right .cg-avatar { align-self: flex-start; }
--      .container-group.cg_chat_message_right .cg-content { max-width: 80%; }'
-- WHERE group_code = 'cg_chat_message_right';
