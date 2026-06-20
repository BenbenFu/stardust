-- ============================================================
-- backfill_css_template_minimal.sql
-- 只回填「新增选项」的 css_template（现有选项继续走 CARD_ENGINE_CSS，不动）
-- 执行方式: 在 Supabase SQL Editor 中运行
-- 前提: 已执行 add_css_template_column.sql（加 css_template 字段）
-- ============================================================

-- ===== 1. fitzgerald 色板 =====
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="fitzgerald"] { --card-bg:#faf6ee; --card-text:#1a1a1a; --card-accent:#c4a962; --card-muted:#8a8a7a; --card-accent-rgb:196,169,98; --card-bg-rgb:250,246,238; }' WHERE value = 'fitzgerald';

-- ===== 2. typo.title_deco: italic_center =====
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="italic_center"] .card-title { font-style:italic; text-align:center; letter-spacing:3px; font-size:14px; }' WHERE sub_dim = 'title_deco' AND value = 'italic_center';

-- ===== 3. border.shadow: double_ring =====
UPDATE style_border_options SET css_template = '.gallery-card[data-shadow="double_ring"] { box-shadow:0 0 0 2px var(--card-accent),0 0 0 4px var(--card-bg,#fff),0 0 0 6px var(--card-accent) !important; }' WHERE sub_dim = 'shadow' AND value = 'double_ring';

-- ===== 4. deco.separator: gold_thin_line =====
UPDATE style_deco_options SET css_template = '.gallery-card .hl-sep.sep-gold_thin_line { border-top:1px solid var(--card-accent); margin:8px 20px; opacity:0.6; height:0; overflow:hidden; text-indent:-9999px; white-space:nowrap; }' WHERE sub_dim = 'separator' AND value = 'gold_thin_line';

-- ===== 5. deco.pseudo_label: art_deco_diamond =====
UPDATE style_deco_options SET css_template = '.gallery-card[data-pseudo-label="art_deco_diamond"]::before { content:"\25C6 \25C7 \25C6 \25C7 \25C6"; display:block; text-align:center; font-size:8px; letter-spacing:4px; color:var(--card-accent); padding:4px 0; border-top:1px solid var(--card-accent); border-bottom:1px solid var(--card-accent); pointer-events:none; } .gallery-card[data-pseudo-label="art_deco_diamond"]::after { content:"\25C6 \25C7 \25C6 \25C7 \25C6"; display:block; text-align:center; font-size:8px; letter-spacing:4px; color:var(--card-accent); padding:4px 0; border-top:1px solid var(--card-accent); pointer-events:none; }' WHERE sub_dim = 'pseudo_label' AND value = 'art_deco_diamond';

-- ===== 验证 =====
-- SELECT value, css_template FROM style_palette_options WHERE css_template IS NOT NULL;
-- SELECT sub_dim, value, css_template FROM style_typo_options WHERE css_template IS NOT NULL;
-- SELECT sub_dim, value, css_template FROM style_border_options WHERE css_template IS NOT NULL;
-- SELECT sub_dim, value, css_template FROM style_deco_options WHERE css_template IS NOT NULL;
