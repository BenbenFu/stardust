-- ============================================================
-- 撑满(stretch) 修复 2026-07-19e
-- agent 无 DB 写权限，请在 Supabase SQL Editor 手动执行本文件。
-- ============================================================
-- 问题：alignment_mode=stretch 已正确设 text-align:justify + text-align-last:justify，
--   标题/要点（含中文或空格，按词/字拉伸）撑满正常；但日期是纯连续拉丁串 "2026-07-19"，
--   无任何词间空格，浏览器 justify 找不到分词点 → 不拉伸 → 日期撑不开。
-- 修复：text-justify:inter-character 强制按字符间距拉伸，专治无空格连续文本撑满。
--   仅对 date 字段在 stretch 时启用（其他字段保持现状 justify 行为，最小影响）。
-- 配合引擎 BASE_CSS 新增的 .card-<field> { text-justify: var(--typo-<field>-justify, auto); }。
-- ============================================================

UPDATE style_typo_options SET css_template =
 '.gallery-card[data-style-typo-alignment-mode-title="stretch"] { --typo-title-align:justify; --typo-title-align-last:justify; }'
 || '.gallery-card[data-style-typo-alignment-mode-date="stretch"] { --typo-date-align:justify; --typo-date-align-last:justify; --typo-date-justify:inter-character; }'
 || '.gallery-card[data-style-typo-alignment-mode-capsule="stretch"] { --typo-capsule-align:justify; --typo-capsule-align-last:justify; }'
 || '.gallery-card[data-style-typo-alignment-mode-highlights="stretch"] { --typo-highlight-align:justify; --typo-highlight-align-last:justify; }'
WHERE sub_dim='alignment_mode' AND value='stretch';
