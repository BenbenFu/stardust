-- ============================================================
-- 对齐设计回退 2026-07-19d
-- agent 无 DB 写权限，请在 Supabase SQL Editor 手动执行本文件。
-- ============================================================
-- 核心改动：把「行内对齐(inline_align)」从「写在 .gallery-card 上、并改写
--   --typo-<field>-align（与字段级抢同一批变量）」回退为「写在 .card-content--slots
--   容器上」，由 CSS 继承传递给各字段；字段级 alignment_mode 仍写各自
--   --typo-<field>-align，默认 inherit（不发射）即跟随行内。
--
-- 三级对齐模型（对应 Word 栏对齐→表格对齐→表格内文字对齐）：
--   block_align   → .card-content--slots { align-items }        （块/纵向）
--   inline_align  → .card-content--slots { text-align }         （行内/横向，容器级，被字段继承）
--   alignment_mode→ .card-<field>      { text-align }           （字段级，默认 inherit 跟随行内，显式设置覆盖）
--
-- 注：alignment_mode 的 left/center/right/stretch 四条模板保持原样
--   （写 --typo-<field>-align 到 .gallery-card，字段元素经 BASE_CSS 回退链读取），
--   本次仅新增 inherit 默认项，并改写 inline_align 模板的落点。
-- ============================================================

-- ---------- 1. inline_align：落点从 .gallery-card 改到 .card-content--slots ----------
-- 旧词表 start/center/end/justify 统一为 left/center/right/stretch，与字段级及 DEFAULT 对齐。
UPDATE style_layout_options SET value='left', sort_order=101,
  css_template = '.gallery-card[data-style-layout-inline-align="left"] .card-content--slots { --typo-inline-align:left; --typo-inline-align-last:auto; justify-items:start; }'
WHERE sub_dim='inline_align' AND value='start';

UPDATE style_layout_options SET value='center', sort_order=102,
  css_template = '.gallery-card[data-style-layout-inline-align="center"] .card-content--slots { --typo-inline-align:center; --typo-inline-align-last:auto; justify-items:center; }'
WHERE sub_dim='inline_align' AND value='center';

UPDATE style_layout_options SET value='right', sort_order=103,
  css_template = '.gallery-card[data-style-layout-inline-align="right"] .card-content--slots { --typo-inline-align:right; --typo-inline-align-last:auto; justify-items:end; }'
WHERE sub_dim='inline_align' AND value='end';

UPDATE style_layout_options SET value='stretch', sort_order=104,
  css_template = '.gallery-card[data-style-layout-inline-align="stretch"] .card-content--slots { --typo-inline-align:justify; --typo-inline-align-last:justify; justify-items:stretch; }'
WHERE sub_dim='inline_align' AND value='justify';

-- ---------- 2. alignment_mode：新增 inherit（跟随行内，默认） ----------
-- 引擎对 inherit 不发射 attr，.card-<field> 经 BASE_CSS 回退链继承容器 text-align。
INSERT INTO style_typo_options (sub_dim, value, label, description, gradient, css_template, sort_order) VALUES
('alignment_mode', 'inherit', '跟随行内(默认)', '字段对齐继承行内对齐，由容器统一控制',
 '{"date":"inherit","title":"inherit","capsule":"inherit","highlight":"inherit"}',
 '', 100)
ON CONFLICT (sub_dim, value) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  gradient = EXCLUDED.gradient,
  css_template = EXCLUDED.css_template,
  sort_order = EXCLUDED.sort_order;

-- 说明：left/center/right/stretch 四条模板维持不变（写 --typo-<field>-align 到 .gallery-card）。
-- 若此前手动改过其模板导致落点异常，可用下方标准化覆盖（按需取消注释）：
-- UPDATE style_typo_options SET css_template =
--  '.gallery-card[data-style-typo-alignment-mode-title="left"] { --typo-title-align:left; --typo-title-align-last:auto; }
--   .gallery-card[data-style-typo-alignment-mode-date="left"] { --typo-date-align:left; --typo-date-align-last:auto; }
--   .gallery-card[data-style-typo-alignment-mode-capsule="left"] { --typo-capsule-align:left; --typo-capsule-align-last:auto; }
--   .gallery-card[data-style-typo-alignment-mode-highlights="left"] { --typo-highlight-align:left; --typo-highlight-align-last:auto; }'
-- WHERE sub_dim='alignment_mode' AND value='left';
