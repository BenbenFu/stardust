-- ============================================================
-- fitzgerald_card_data.sql
-- 菲茨杰拉德卡片：新增配色 + 各维度新选项
-- 执行前确认 style_dimension_options 表已创建
-- ============================================================

-- ===== 1. 新增配色方案 fitzgerald =====
INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order) VALUES
('fitzgerald', '菲茨杰拉德', '#faf6ee', '#1a1a1a', '#c4a962', '#8a8a7a', '盖茨比派对请柬 · 象牙卡纸 + 双圈金边', 18)
ON CONFLICT (value) DO NOTHING;

-- ===== 2. typo.title_deco 新增 italic_center =====
INSERT INTO style_typo_options (sub_dim, value, label, description, sort_order) VALUES
('title_deco', 'italic_center', '斜体居中', '标题斜体 + 居中 + 宽字距（FITZGERALD）', 13)
ON CONFLICT (sub_dim, value) DO NOTHING;

-- ===== 3. border.style 新增 thin_solid（金色由 palete accent 驱动）=====
-- 注意：原 CSS 为 1px solid #c4a962，颜色应从 palete.accent 取色
-- border.style 只记录线型，颜色由渲染引擎根据 palete 填入
INSERT INTO style_border_options (sub_dim, value, label, description, sort_order) VALUES
('style', 'thin_solid', '细实线 1px', '1px solid（颜色由色板 accent 驱动）', 11)
ON CONFLICT (sub_dim, value) DO NOTHING;

-- ===== 4. border.shadow 新增 double_ring =====
INSERT INTO style_border_options (sub_dim, value, label, description, sort_order) VALUES
('shadow', 'double_ring', '双圈金边', '双层 box-shadow 模拟双圈金边（FITZGERALD）', 5)
ON CONFLICT (sub_dim, value) DO NOTHING;

-- ===== 5. deco.separator 新增 gold_thin_line =====
INSERT INTO style_deco_options (sub_dim, value, label, description, sort_order) VALUES
('separator', 'gold_thin_line', '金色细线', '两侧缩进金色细线 border-top（FITZGERALD）', 13)
ON CONFLICT (sub_dim, value) DO NOTHING;

-- ===== 6. deco.pseudo_label 新增 art_deco_diamond =====
INSERT INTO style_deco_options (sub_dim, value, label, description, sort_order) VALUES
('pseudo_label', 'art_deco_diamond', '装饰艺术◇', '顶部/底部 Art Deco 菱形纹 ◆（FITZGERALD）', 3)
ON CONFLICT (sub_dim, value) DO NOTHING;

-- ===== 7. 验证插入结果 =====
-- select * from style_palette_options where value = 'fitzgerald';
-- select * from style_typo_options where sub_dim = 'title_deco' and value = 'italic_center';
-- select * from style_border_options where value in ('thin_solid', 'double_ring');
-- select * from style_deco_options where value in ('gold_thin_line', 'art_deco_diamond');
