-- style_options_fixes_v1.sql
-- 日期: 2026-07-01
-- 描述: 九张表评审后的修复操作（已通过 REST API 执行，此文件为存档备份）

-- P0-2: 删除 overlay_stack 布局（slots=['bg_layer','fg_layer'] 与四基础元素不兼容）
DELETE FROM style_layout_options WHERE sub_dim = 'grid' AND value = 'overlay_stack';

-- P1-4: filter_backdrop 不需要单独 none
-- 原因: filter_self 和 filter_backdrop 共享 data-style-effect-filter 属性
--       filter_self 的 none 已包含 { filter: none; backdrop-filter: none; }
-- 无需操作

-- P1-5: sub_deco_action 命名一致性
-- 经复查，registry 使用 sub_deco_{name}，deco 表使用 {name}_style，所有 5 个 sub_dim 均遵循同一模式
-- 无需操作

-- P1-6: 添加 container_group none 基准记录
INSERT INTO style_container_group_options
  (group_code, group_name, category, description, layout_ref,
   slot_deco_map, field_slot_map, layout_slot_map, extra_css, sort_order, is_enabled)
VALUES
  ('none', 'none', 'none', 'no container group, use layout grid directly', 'single',
   '{}', '{}', '{}', '', 0, true);

-- P1-7: 添加缺失的 border css_var 记录
-- 注: effect 的 css_var (--effect-blur-sm 等) 是 per-option 变量，不是 per-dimension，不纳入 registry
INSERT INTO style_field_registry
  (field_code, field_name, field_type, description, is_core, sort_order, is_enabled, record_type, parent_code, var_default_value, data_type)
VALUES
  ('var_border_style',  'border style var',  'css_var', 'border style CSS variable', true, 100, true, 'css_var', 'dim_border', 'solid', 'enum'),
  ('var_border_shadow', 'border shadow var', 'css_var', 'border shadow CSS variable', true, 101, true, 'css_var', 'dim_border', 'none',  'shadow');
