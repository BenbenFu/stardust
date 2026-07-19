-- ============================================================
-- 对齐覆盖关系修正 2026-07-19c
-- agent 无 DB 写权限，请在 Supabase SQL Editor 手动执行本文件。
-- ============================================================
-- 根因：上一版(style_alignment_refactor_20260719.sql)把 全局 inline_align 与 字段级
--       typo.alignment_mode 都写成「同一个变量 --typo-<field>-align，同一个 .gallery-card
--       元素」，二者特异性完全相同，胜负完全由注入顺序决定（脆弱）。实测中字段级未稳定
--       压住全局，表现为「全局行内对齐覆盖字段级」。
-- 修正：改为「回退链」架构——
--   全局 inline_align  → 写 --typo-inline-align（及 --typo-inline-align-last）
--   字段级 alignment_mode → 写 --typo-<field>-align（及 --typo-<field>-align-last）
--   BASE_CSS 四字段：
--     text-align:      var(--typo-<field>-align,      var(--typo-inline-align, left));
--     text-align-last: var(--typo-<field>-align-last, var(--typo-inline-align-last, auto));
--   字段级变量在前 → 永远优先于全局；字段级未设置(默认 left)时回退到全局 inline_align。
--   引擎侧已同步：typo_alignment_mode 默认 'left' 不发射 attr（即继承全局）。
-- ============================================================

-- ---------- 1. inline_align 改名为 --typo-inline-align ----------
UPDATE style_layout_options SET css_template =
 '.gallery-card[data-style-layout-inline-align="start"] { --typo-inline-align:left; --typo-inline-align-last:auto; }
.gallery-card[data-style-layout-inline-align="start"] .card-content--slots { justify-items:start; }'
WHERE sub_dim='inline_align' AND value='start';

UPDATE style_layout_options SET css_template =
 '.gallery-card[data-style-layout-inline-align="center"] { --typo-inline-align:center; --typo-inline-align-last:auto; }
.gallery-card[data-style-layout-inline-align="center"] .card-content--slots { justify-items:center; }'
WHERE sub_dim='inline_align' AND value='center';

UPDATE style_layout_options SET css_template =
 '.gallery-card[data-style-layout-inline-align="end"] { --typo-inline-align:end; --typo-inline-align-last:auto; }
.gallery-card[data-style-layout-inline-align="end"] .card-content--slots { justify-items:end; }'
WHERE sub_dim='inline_align' AND value='end';

UPDATE style_layout_options SET css_template =
 '.gallery-card[data-style-layout-inline-align="justify"] { --typo-inline-align:justify; --typo-inline-align-last:justify; }
.gallery-card[data-style-layout-inline-align="justify"] .card-content--slots { justify-items:stretch; }'
WHERE sub_dim='inline_align' AND value='justify';

-- ---------- 2. alignment_mode：left/center/right 补 align-last:auto（stretch 已含，不变） ----------
UPDATE style_typo_options SET css_template =
 '.gallery-card[data-style-typo-alignment-mode-title="left"] { --typo-title-align:left; --typo-title-align-last:auto; }
.gallery-card[data-style-typo-alignment-mode-date="left"] { --typo-date-align:left; --typo-date-align-last:auto; }
.gallery-card[data-style-typo-alignment-mode-capsule="left"] { --typo-capsule-align:left; --typo-capsule-align-last:auto; }
.gallery-card[data-style-typo-alignment-mode-highlights="left"] { --typo-highlight-align:left; --typo-highlight-align-last:auto; }'
WHERE sub_dim='alignment_mode' AND value='left';

UPDATE style_typo_options SET css_template =
 '.gallery-card[data-style-typo-alignment-mode-title="center"] { --typo-title-align:center; --typo-title-align-last:auto; }
.gallery-card[data-style-typo-alignment-mode-date="center"] { --typo-date-align:center; --typo-date-align-last:auto; }
.gallery-card[data-style-typo-alignment-mode-capsule="center"] { --typo-capsule-align:center; --typo-capsule-align-last:auto; }
.gallery-card[data-style-typo-alignment-mode-highlights="center"] { --typo-highlight-align:center; --typo-highlight-align-last:auto; }'
WHERE sub_dim='alignment_mode' AND value='center';

UPDATE style_typo_options SET css_template =
 '.gallery-card[data-style-typo-alignment-mode-title="right"] { --typo-title-align:right; --typo-title-align-last:auto; }
.gallery-card[data-style-typo-alignment-mode-date="right"] { --typo-date-align:right; --typo-date-align-last:auto; }
.gallery-card[data-style-typo-alignment-mode-capsule="right"] { --typo-capsule-align:right; --typo-capsule-align-last:auto; }
.gallery-card[data-style-typo-alignment-mode-highlights="right"] { --typo-highlight-align:right; --typo-highlight-align-last:auto; }'
WHERE sub_dim='alignment_mode' AND value='right';

-- stretch 行无需改动（已是 --typo-<field>-align:justify; --typo-<field>-align-last:justify;）
