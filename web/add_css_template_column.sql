-- ============================================================
-- add_css_template_column.sql
-- 给 7 张维度选项表添加 css_template 字段
-- 执行方式: 在 Supabase SQL Editor 中运行
-- ============================================================

ALTER TABLE style_layout_options ADD COLUMN IF NOT EXISTS css_template TEXT;
ALTER TABLE style_palette_options ADD COLUMN IF NOT EXISTS css_template TEXT;
ALTER TABLE style_typo_options   ADD COLUMN IF NOT EXISTS css_template TEXT;
ALTER TABLE style_border_options ADD COLUMN IF NOT EXISTS css_template TEXT;
ALTER TABLE style_deco_options   ADD COLUMN IF NOT EXISTS css_template TEXT;
ALTER TABLE style_effect_options ADD COLUMN IF NOT EXISTS css_template TEXT;
ALTER TABLE style_elements_options ADD COLUMN IF NOT EXISTS css_template TEXT;

-- 确认字段已添加
SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE column_name = 'css_template'
  AND table_name IN (
    'style_layout_options','style_palette_options','style_typo_options',
    'style_border_options','style_deco_options','style_effect_options','style_elements_options'
  )
ORDER BY table_name;
