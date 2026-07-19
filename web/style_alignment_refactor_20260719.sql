-- ============================================================
-- 对齐重构 2026-07-19
-- agent 无 DB 写权限，请在 Supabase SQL Editor 手动执行本文件。
-- ============================================================
-- 变更点：
-- 1) typo.alignment_mode：从「5个四字段组合预设」重构为「单字段独立方向」。
--    删除旧预设(left_flow/centered_formal/title_center/mixed_natural/capsule_right)，
--    改为 left/center/right/stretch 四方向；每个值的 css_template 按字段后缀
--    (.card-title/.card-date/.card-capsule/.card-highlights) 分别设 --typo-<field>-align。
--    stretch 额外设 --typo-<field>-align-last:justify，配合 BASE_CSS 新增的
--    text-align-last:var(--typo-<field>-align-last,auto)，实现「单行也撑满」。
-- 2) layout.inline_align：原模板把 text-align 写在 .card-content--slots 容器上，
--    被四字段自身的 text-align 规则覆盖而整体失效（表现为始终左对齐）。
--    改为在 .gallery-card 上写 --typo-<field>-align 变量（与字段级 typo.alignment_mode
--    同一机制：全局为默认、字段级可覆盖，因 layout 表先于 typo 表注入故字段级胜出）；
--    justify 额外加 align-last 实现撑满。justify-items 保留以兼容未来块宽调整。
-- 说明：block_align 的 stretch 本次不动（用户决定稍后处理）。
-- ============================================================

-- ---------- 1. alignment_mode 重构 ----------
DELETE FROM style_typo_options
WHERE sub_dim = 'alignment_mode'
  AND value IN ('left_flow','centered_formal','title_center','mixed_natural','capsule_right');

INSERT INTO style_typo_options (sub_dim, value, label, description, gradient, css_template, sort_order) VALUES
('alignment_mode', 'left', '左对齐 left', '字段内容靠左',
 '{"date":"left","title":"left","capsule":"left","highlight":"left"}',
 '.gallery-card[data-style-typo-alignment-mode-title="left"] { --typo-title-align:left; }
.gallery-card[data-style-typo-alignment-mode-date="left"] { --typo-date-align:left; }
.gallery-card[data-style-typo-alignment-mode-capsule="left"] { --typo-capsule-align:left; }
.gallery-card[data-style-typo-alignment-mode-highlights="left"] { --typo-highlight-align:left; }', 101),
('alignment_mode', 'center', '居中 center', '字段内容居中',
 '{"date":"center","title":"center","capsule":"center","highlight":"center"}',
 '.gallery-card[data-style-typo-alignment-mode-title="center"] { --typo-title-align:center; }
.gallery-card[data-style-typo-alignment-mode-date="center"] { --typo-date-align:center; }
.gallery-card[data-style-typo-alignment-mode-capsule="center"] { --typo-capsule-align:center; }
.gallery-card[data-style-typo-alignment-mode-highlights="center"] { --typo-highlight-align:center; }', 102),
('alignment_mode', 'right', '右对齐 right', '字段内容靠右',
 '{"date":"right","title":"right","capsule":"right","highlight":"right"}',
 '.gallery-card[data-style-typo-alignment-mode-title="right"] { --typo-title-align:right; }
.gallery-card[data-style-typo-alignment-mode-date="right"] { --typo-date-align:right; }
.gallery-card[data-style-typo-alignment-mode-capsule="right"] { --typo-capsule-align:right; }
.gallery-card[data-style-typo-alignment-mode-highlights="right"] { --typo-highlight-align:right; }', 103),
('alignment_mode', 'stretch', '撑满 stretch', '字段内容两端对齐，按文字量自动撑满整行',
 '{"date":"stretch","title":"stretch","capsule":"stretch","highlight":"stretch"}',
 '.gallery-card[data-style-typo-alignment-mode-title="stretch"] { --typo-title-align:justify; --typo-title-align-last:justify; }
.gallery-card[data-style-typo-alignment-mode-date="stretch"] { --typo-date-align:justify; --typo-date-align-last:justify; }
.gallery-card[data-style-typo-alignment-mode-capsule="stretch"] { --typo-capsule-align:justify; --typo-capsule-align-last:justify; }
.gallery-card[data-style-typo-alignment-mode-highlights="stretch"] { --typo-highlight-align:justify; --typo-highlight-align-last:justify; }', 104);

-- ---------- 2. inline_align 改为变量驱动 ----------
UPDATE style_layout_options SET css_template =
 '.gallery-card[data-style-layout-inline-align="start"] { --typo-title-align:left; --typo-date-align:left; --typo-capsule-align:left; --typo-highlight-align:left; }
.gallery-card[data-style-layout-inline-align="start"] .card-content--slots { justify-items:start; }'
WHERE sub_dim='inline_align' AND value='start';

UPDATE style_layout_options SET css_template =
 '.gallery-card[data-style-layout-inline-align="center"] { --typo-title-align:center; --typo-date-align:center; --typo-capsule-align:center; --typo-highlight-align:center; }
.gallery-card[data-style-layout-inline-align="center"] .card-content--slots { justify-items:center; }'
WHERE sub_dim='inline_align' AND value='center';

UPDATE style_layout_options SET css_template =
 '.gallery-card[data-style-layout-inline-align="end"] { --typo-title-align:end; --typo-date-align:end; --typo-capsule-align:end; --typo-highlight-align:end; }
.gallery-card[data-style-layout-inline-align="end"] .card-content--slots { justify-items:end; }'
WHERE sub_dim='inline_align' AND value='end';

UPDATE style_layout_options SET css_template =
 '.gallery-card[data-style-layout-inline-align="justify"] { --typo-title-align:justify; --typo-title-align-last:justify; --typo-date-align:justify; --typo-date-align-last:justify; --typo-capsule-align:justify; --typo-capsule-align-last:justify; --typo-highlight-align:justify; --typo-highlight-align-last:justify; }
.gallery-card[data-style-layout-inline-align="justify"] .card-content--slots { justify-items:stretch; }'
WHERE sub_dim='inline_align' AND value='justify';
