-- ============================================================
-- Deco Box 多盒层化 + Effect 滤镜分层  ·  真实库驱动生成
-- 生成时间: 2026-07-15  (基于 style_deco_options / style_effect_options 实库)
-- 注意: agent 无 DB 写权限, 请在 Supabase SQL Editor 手动执行本文件。
-- ============================================================

-- 执行前校验: 确认当前 box_style / filter_backdrop 行
SELECT id, sub_dim, value, left(css_template, 40) AS tpl_head FROM style_deco_options WHERE sub_dim = 'box_style' ORDER BY sort_order;
SELECT id, sub_dim, value, left(css_template, 40) AS tpl_head FROM style_effect_options WHERE sub_dim = 'filter_backdrop' ORDER BY sort_order;

-- ============================================================
-- 1) box_style: 旧模板挂在 .gallery-card[data-style-deco-box-target=..]
--    新引擎改为独立 .deco-box 元素(绝对定位覆盖目标区域), 不发射 box_target。
--    改写: 选择器统一为 .deco-box[data-style-deco-box="VALUE"], 去掉 position:relative。
-- ============================================================
-- (跳过 none: css_template 为空)
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="solid_fill"] { background: color-mix(in srgb, var(--card-bg, #fff) 90%, var(--card-accent, #ccc) 10%); border-radius: var(--border-radius, 4px); padding: 10px 12px; }' WHERE id = 18; -- box_style=solid_fill
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="outline_border"] { border: var(--border-width, 1px) solid var(--card-accent, #ccc); border-radius: var(--border-radius, 4px); padding: 10px 12px; }' WHERE id = 19; -- box_style=outline_border
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="left_bar_quote"] { padding-left: 12px; margin-left: 4px; border-left: 3px solid var(--card-accent, #ccc); }' WHERE id = 20; -- box_style=left_bar_quote
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="code_dark"] { background: var(--card-text, #1e1e1e); color: var(--card-bg, #f8f8f8); border-radius: var(--border-radius, 4px); padding: 10px 14px; font-family: "JetBrains Mono", "Fira Code", monospace; font-size: 0.88em; }' WHERE id = 21; -- box_style=code_dark
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="dashed_cutout"] { border: 2px dashed var(--card-muted, #bbb); border-radius: var(--border-radius, 2px); padding: 10px 12px; background: transparent; }' WHERE id = 22; -- box_style=dashed_cutout
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="sticky_note"] { background: color-mix(in srgb, var(--card-bg, #fff) 88%, var(--card-accent, #ccc) 12%); box-shadow: 0 2px 6px rgba(0,0,0,0.08); padding: 12px 14px; border-radius: 0; }' WHERE id = 23; -- box_style=sticky_note
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="tape_note"] { background: color-mix(in srgb, var(--card-bg, #fff) 90%, var(--card-accent, #ccc) 10%); box-shadow: 0 3px 10px rgba(0,0,0,0.12); padding: 14px 14px 12px; border-radius: 0; }' WHERE id = 24; -- box_style=tape_note
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="float_card"] { background: var(--card-bg, #fff); box-shadow: 0 4px 12px rgba(0,0,0,0.08); border-radius: var(--border-radius, 8px); padding: 12px 14px; }' WHERE id = 25; -- box_style=float_card
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="glass_standard"] { background: color-mix(in srgb, var(--card-bg, #fff) 70%, transparent); border: 1px solid color-mix(in srgb, var(--card-bg, #fff) 80%, transparent); border-radius: var(--border-radius, 8px); backdrop-filter: var(--effect-backdrop-blur-md, blur(16px)); -webkit-backdrop-filter: var(--effect-backdrop-blur-md, blur(16px)); box-shadow: 0 4px 12px rgba(0,0,0,0.08); padding: 12px 14px; }' WHERE id = 33; -- box_style=glass_standard
UPDATE style_deco_options SET css_template = '.deco-box[data-style-deco-box="liquid_glass"] { background: color-mix(in srgb, var(--card-bg, #fff) 50%, transparent); border: 1px solid color-mix(in srgb, var(--card-bg, #fff) 90%, transparent); border-radius: var(--border-radius, 12px); backdrop-filter: var(--effect-backdrop-blur-lg, blur(32px)) saturate(180%); -webkit-backdrop-filter: var(--effect-backdrop-blur-lg, blur(32px)) saturate(180%); box-shadow: 0 8px 24px rgba(0,0,0,0.12), inset 0 1px 0 rgba(255,255,255,0.3); padding: 14px 16px; }' WHERE id = 34; -- box_style=liquid_glass

-- ============================================================
-- 2) filter_backdrop: 旧模板挂在 .gallery-card[...] .card-XXX (backdrop 在字段上, 被 filter 吞)
--    新引擎: backdrop 独立 attr data-style-effect-backdrop-<el> 发射在 .gallery-card, 
--    且字段外包 .fx-wrap[data-fx=el]; 故选择器改为 .fx-wrap[data-fx=el] 承载 backdrop-filter。
--    并补 -webkit-backdrop-filter (Safari)。self(filter) 模板无需改动。
-- ============================================================
UPDATE style_effect_options SET css_template = '.gallery-card[data-style-effect-backdrop-title="backdrop_blur_sm"] .fx-wrap[data-fx="title"] { backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }
.gallery-card[data-style-effect-backdrop-date="backdrop_blur_sm"] .fx-wrap[data-fx="date"] { backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }
.gallery-card[data-style-effect-backdrop-capsule="backdrop_blur_sm"] .fx-wrap[data-fx="capsule"] { backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }
.gallery-card[data-style-effect-backdrop-highlights="backdrop_blur_sm"] .fx-wrap[data-fx="highlights"] { backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }' WHERE id = 4; -- filter_backdrop=backdrop_blur_sm
UPDATE style_effect_options SET css_template = '.gallery-card[data-style-effect-backdrop-title="backdrop_blur_md"] .fx-wrap[data-fx="title"] { backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); }
.gallery-card[data-style-effect-backdrop-date="backdrop_blur_md"] .fx-wrap[data-fx="date"] { backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); }
.gallery-card[data-style-effect-backdrop-capsule="backdrop_blur_md"] .fx-wrap[data-fx="capsule"] { backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); }
.gallery-card[data-style-effect-backdrop-highlights="backdrop_blur_md"] .fx-wrap[data-fx="highlights"] { backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px); }' WHERE id = 5; -- filter_backdrop=backdrop_blur_md
UPDATE style_effect_options SET css_template = '.gallery-card[data-style-effect-backdrop-title="backdrop_blur_lg"] .fx-wrap[data-fx="title"] { backdrop-filter: blur(32px); -webkit-backdrop-filter: blur(32px); }
.gallery-card[data-style-effect-backdrop-date="backdrop_blur_lg"] .fx-wrap[data-fx="date"] { backdrop-filter: blur(32px); -webkit-backdrop-filter: blur(32px); }
.gallery-card[data-style-effect-backdrop-capsule="backdrop_blur_lg"] .fx-wrap[data-fx="capsule"] { backdrop-filter: blur(32px); -webkit-backdrop-filter: blur(32px); }
.gallery-card[data-style-effect-backdrop-highlights="backdrop_blur_lg"] .fx-wrap[data-fx="highlights"] { backdrop-filter: blur(32px); -webkit-backdrop-filter: blur(32px); }' WHERE id = 6; -- filter_backdrop=backdrop_blur_lg

-- ============================================================
-- 3) 新增渐变类 box_style (库里原本没有; 满足「渐变+毛玻璃+液态玻璃 同时叠加」场景)
--    用 NOT EXISTS 防止重复执行。label/description 为中文。
-- ============================================================
INSERT INTO style_deco_options (sub_dim, value, label, description, structure_params, css_template, sort_order, is_enabled)
SELECT 'box_style', 'gradient_linear', '双色线性渐变', 'accent 到透明的 135° 线性渐变, 作为字段/整卡背景上的渐变叠层', NULL, '.deco-box[data-style-deco-box="gradient_linear"] { background: linear-gradient(135deg, color-mix(in srgb, var(--card-accent, #ccc) 55%, transparent) 0%, transparent 100%); border-radius: var(--border-radius, 8px); }', 12, true
WHERE NOT EXISTS (SELECT 1 FROM style_deco_options WHERE sub_dim = 'box_style' AND value = 'gradient_linear');
INSERT INTO style_deco_options (sub_dim, value, label, description, structure_params, css_template, sort_order, is_enabled)
SELECT 'box_style', 'gradient_flow', '三色流光渐变', 'accent / accent2 / 透明 的三段流光渐变, 增强层次', NULL, '.deco-box[data-style-deco-box="gradient_flow"] { background: linear-gradient(120deg, color-mix(in srgb, var(--card-accent, #ccc) 50%, transparent) 0%, color-mix(in srgb, var(--card-accent2, #999) 35%, transparent) 50%, transparent 100%); border-radius: var(--border-radius, 8px); }', 13, true
WHERE NOT EXISTS (SELECT 1 FROM style_deco_options WHERE sub_dim = 'box_style' AND value = 'gradient_flow');
INSERT INTO style_deco_options (sub_dim, value, label, description, structure_params, css_template, sort_order, is_enabled)
SELECT 'box_style', 'gradient_radial', '径向光晕', '左上角 accent 径向光晕, 向边缘透明消散', NULL, '.deco-box[data-style-deco-box="gradient_radial"] { background: radial-gradient(circle at 28% 18%, color-mix(in srgb, var(--card-accent, #ccc) 55%, transparent) 0%, transparent 70%); border-radius: var(--border-radius, 8px); }', 14, true
WHERE NOT EXISTS (SELECT 1 FROM style_deco_options WHERE sub_dim = 'box_style' AND value = 'gradient_radial');

-- 执行后校验: box 应全部指向 .deco-box[data-style-deco-box=...]; backdrop 应指向 .fx-wrap
SELECT value, css_template FROM style_deco_options WHERE sub_dim = 'box_style' AND value <> 'none' ORDER BY sort_order;
SELECT value, css_template FROM style_effect_options WHERE sub_dim = 'filter_backdrop' ORDER BY sort_order;
