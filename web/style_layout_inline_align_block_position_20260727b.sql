-- 栏·水平对齐 (inline_align) 盒级横向定位修复 2026-07-27b
-- ============================================================
-- 根因：2026-07-19f 为规避「justify-items 与字段级 h_align 争用槽宽」，曾把 inline_align 模板里的
--       justify-items 全部删除，仅保留 --typo-inline-align（即 text-align）。
--       后果：横排下 text-align 还能动文字 → 看似有效；竖排下 text-align 翻转为竖向文字对齐 →
--       栏·水平对齐完全不动列，用户感知「选项无效 / 只有字段级水平对齐能移动竖排文字」。
-- 本修复：把 justify-items 加回 inline_align 模板，使「栏·水平对齐」真正移动整列（块级横向位置）。
--   映射原则（避免回归，关键）：
--     · left   → justify-items:stretch + text-align:left    （默认：块撑满、不动列，与原行为一致；
--                字段级 h_align 仍可用，因为槽宽=卡宽有横向余量）
--     · center → justify-items:center  + text-align:center  （整列水平居中 → 可见变化）
--     · right  → justify-items:end     + text-align:right   （整列靠右 → 可见变化）
--     · justify/stretch → justify-items:stretch + text-align:justify
--   依赖引擎 BASE_CSS .card-content--slots 已加 grid-template-columns:1fr（引擎 20260727b），
--   保证列有横向余量，justify-items 的 start/center/end 才生效。
-- 数据驱动：仅更新 style_layout_options(sub_dim='inline_align') 的 css_template，不写死在引擎。
-- 幂等：按现有 css_template 里的 --typo-inline-align 推回 justify-items 方向，attr 选择器用行内真实 value。

UPDATE style_layout_options
SET css_template =
  '.gallery-card[data-style-layout-inline-align="' || value || '"] .card-content--slots { '
  || (CASE
        WHEN css_template LIKE '%--typo-inline-align:justify%'
             THEN 'justify-items:stretch; --typo-inline-align:justify; --typo-inline-align-last:justify;'
        WHEN css_template LIKE '%--typo-inline-align:center%'
             THEN 'justify-items:center; --typo-inline-align:center; --typo-inline-align-last:auto;'
        WHEN css_template LIKE '%--typo-inline-align:right%'
             THEN 'justify-items:end; --typo-inline-align:right; --typo-inline-align-last:auto;'
        ELSE 'justify-items:stretch; --typo-inline-align:left; --typo-inline-align-last:auto;'
      END)
  || ' }'
WHERE sub_dim = 'inline_align';
