-- ============================================================
-- bugfix_element_push_20260713.sql
-- 目标: 让所有「顶栏(header_deco)」与「侧栏(side_accent)」选项
--   1) 明显可见(加粗色条, 不再 2~3px 几乎看不见)
--   2) 强制推开内容(padding + !important 兜底, 任何情况下都能推开卡片)
-- 说明: anon REST 为只读, 请在 Supabase SQL Editor 执行本文件。
--       执行后需硬刷新(github pages 有 CDN 缓存)。
-- ============================================================

-- ---------- side_accent (侧栏) ----------

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-side="solid_side_bar"] {
  border-left: 8px solid var(--card-accent, #3b82f6) !important;
  padding-left: 16px !important;
}'
WHERE sub_dim = 'side_accent' AND value = 'solid_side_bar';

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-side="gradient_side_bar"] {
  position: relative;
  padding-left: 16px !important;
}
.gallery-card[data-style-element-side="gradient_side_bar"]::before {
  content: "";
  position: absolute;
  left: 0; top: 0; bottom: 0;
  width: 8px;
  background: linear-gradient(to bottom, var(--card-accent, #3b82f6), var(--card-muted, #999)) !important;
}'
WHERE sub_dim = 'side_accent' AND value = 'gradient_side_bar';

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-side="solid_side_bar_right"] {
  border-right: 8px solid var(--card-accent, #3b82f6) !important;
  padding-right: 16px !important;
}'
WHERE sub_dim = 'side_accent' AND value = 'solid_side_bar_right';

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-side="gradient_side_bar_right"] {
  position: relative;
  padding-right: 16px !important;
}
.gallery-card[data-style-element-side="gradient_side_bar_right"]::after {
  content: "";
  position: absolute;
  right: 0; top: 0; bottom: 0;
  width: 8px;
  background: linear-gradient(to bottom, var(--card-accent, #3b82f6), transparent) !important;
}'
WHERE sub_dim = 'side_accent' AND value = 'gradient_side_bar_right';

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-side="line_number_column"] {
  counter-reset: line-no;
  padding-left: 44px !important;
  position: relative;
}
.gallery-card[data-style-element-side="line_number_column"]::before {
  content: "";
  position: absolute;
  left: 0; top: 0; bottom: 0;
  width: 40px;
  background: color-mix(in srgb, var(--card-accent, #3b82f6) 18%, var(--card-bg, #fff) 82%) !important;
  border-right: 2px solid var(--card-accent, #3b82f6) !important;
}
.gallery-card[data-style-element-side="line_number_column"] .card-highlight-item {
  counter-increment: line-no;
  position: relative;
}
.gallery-card[data-style-element-side="line_number_column"] .card-highlight-item::before {
  content: counter(line-no);
  position: absolute;
  left: -42px;
  width: 30px;
  text-align: right;
  color: var(--card-accent, #3b82f6);
  font-size: 0.75em;
  font-family: monospace;
  user-select: none;
}'
WHERE sub_dim = 'side_accent' AND value = 'line_number_column';

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-side="notebook_binding"] {
  padding-left: 34px !important;
  position: relative;
}
.gallery-card[data-style-element-side="notebook_binding"]::before {
  content: "● ● ● ●";
  position: absolute;
  left: 4px; top: 0; bottom: 0;
  writing-mode: vertical-rl;
  font-size: 11px;
  letter-spacing: 8px;
  color: var(--card-accent, #3b82f6) !important;
  pointer-events: none;
}'
WHERE sub_dim = 'side_accent' AND value = 'notebook_binding';

-- ---------- header_deco (顶栏) ----------

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-header="thin_accent_bar"] {
  border-top: 6px solid var(--card-accent, #3b82f6) !important;
  padding-top: 14px !important;
}'
WHERE sub_dim = 'header_deco' AND value = 'thin_accent_bar';

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-header="thick_ribbon"] {
  border-top: 10px solid var(--card-accent, #3b82f6) !important;
  padding-top: 16px !important;
}'
WHERE sub_dim = 'header_deco' AND value = 'thick_ribbon';

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-header="gradient_strip"] {
  border-top: 8px solid transparent !important;
  border-image: linear-gradient(to right, var(--card-accent, #3b82f6), var(--card-muted, #999)) 1 !important;
  padding-top: 16px !important;
}'
WHERE sub_dim = 'header_deco' AND value = 'gradient_strip';

UPDATE style_element_options
SET css_template = '.gallery-card[data-style-element-header="blink_cursor_bar"] {
  border-top: 6px solid var(--card-accent, #3b82f6) !important;
  padding-top: 14px !important;
}
.gallery-card[data-style-element-header="blink_cursor_bar"][data-anim="blink"] {
  animation: header-blink 1s infinite steps(2);
}
@keyframes header-blink {
  0%, 100% { border-top-color: var(--card-accent, #3b82f6); }
  50% { border-top-color: transparent; }
}'
WHERE sub_dim = 'header_deco' AND value = 'blink_cursor_bar';

-- ============================================================
-- 校验: 确认已更新行数 (应 = 10)
-- ============================================================
SELECT sub_dim, value, left(css_template, 40) AS tpl_preview
FROM style_element_options
WHERE sub_dim IN ('header_deco','side_accent')
  AND value <> 'none'
ORDER BY sub_dim, value;
