-- ============================================================
-- style_container_group_repeat_mode_20260718.sql
-- 日期: 2026-07-18
-- 目的: 为 Phase 2「容器组 compose（堆叠进 highlights 带栈）」补 repeat_mode 列
--       并给现有 CG 行设定合理默认值。
-- 说明: agent 无 DB 写权限，请在 Supabase SQL Editor 手动执行。
--       执行后无需改前端缓存（前端仅读取该列，gallery 拉取的是实时数据）。
-- ============================================================

-- 1) 新增 repeat_mode 列（'once' = 整段渲染一次；'per_line' = 每条 highlight 重复一次）
--    注：Postgres 11+ 支持 ADD COLUMN ... DEFAULT，历史行会自动填充 'once'。
ALTER TABLE style_container_group_options
  ADD COLUMN IF NOT EXISTS repeat_mode text NOT NULL DEFAULT 'once';

-- 2) 为现有 CG 行设定 repeat_mode（按各自语义）
--    · 聊天/评论类逐行出现 → per_line
--    · 操作栏/便利贴/整卡头尾 → once

-- 聊天消息（左/右）：每条 highlight 一行（头像 + 气泡）
UPDATE style_container_group_options SET repeat_mode = 'per_line' WHERE group_code = 'cg_chat_message_left';
UPDATE style_container_group_options SET repeat_mode = 'per_line' WHERE group_code = 'cg_chat_message_right';

-- 评论行（单条 / 含赞）：每条 highlight 一行
UPDATE style_container_group_options SET repeat_mode = 'per_line' WHERE group_code = 'cg_comment_sub';
UPDATE style_container_group_options SET repeat_mode = 'per_line' WHERE group_code = 'cg_comment_item';

-- 互动操作栏（赞/评/转）：整段仅一次
UPDATE style_container_group_options SET repeat_mode = 'once' WHERE group_code = 'cg_social_interact_bar';

-- 便利贴拼贴（双/三）：highlight_1/2/3 一次性并列
UPDATE style_container_group_options SET repeat_mode = 'once' WHERE group_code = 'cg_sticky_two';
UPDATE style_container_group_options SET repeat_mode = 'once' WHERE group_code = 'cg_sticky_three';

-- 整卡头/尾（社交头、整卡）：整卡级，once
UPDATE style_container_group_options SET repeat_mode = 'once' WHERE group_code = 'cg_social_header';
UPDATE style_container_group_options SET repeat_mode = 'once' WHERE group_code = 'cg_social_full_card';

-- 基准 none 行
UPDATE style_container_group_options SET repeat_mode = 'once' WHERE group_code = 'none';

-- 3) 校验
-- SELECT group_code, group_name, layout_ref, repeat_mode
-- FROM style_container_group_options ORDER BY sort_order;
