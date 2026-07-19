-- ============================================================
-- 对齐修复 2026-07-19f：移除 inline_align 模板里的 justify-items
-- agent 无 DB 写权限，请在 Supabase SQL Editor 手动执行本文件。
-- ============================================================
-- 根因：20260719d 的 inline_align 模板顺手加了 `justify-items:start/center/end/stretch`。
--   .card-content--slots 是 grid 容器，justify-items 会让它的子项（即 .card-title /
--   .card-date 等字段元素）在单元格内**收缩为内容宽度**。元素本身没有多余空间，
--   text-align 就推不动 —— 于是「行内对齐一旦设定就吃掉字段级对齐」。
--   用户观察到的「行内对齐把字段对齐全覆盖、字段改了没用」正是这个现象。
--
-- 语义澄清（三级对齐）：
--   block_align   → .card-content--slots { align-items }      （块/纵向盒子对齐，保留，不动）
--   inline_align  → .card-content--slots { text-align }        （行内/文字对齐，应只走 text-align 继承）
--   alignment_mode→ .card-<field>      { text-align }          （字段级，默认 inherit 跟随行内）
--   justify-items 属于「盒子级横向对齐」，是 block 维度的事，不该由 inline_align 控制。
--
-- 修复：仅保留 --typo-inline-align / --typo-inline-align-last（text-align 落点），
--   删除全部 justify-items。grid 子项默认 justify-items:stretch（占满整行），
--   text-align 有空间作用，字段级即可独立覆盖行内对齐。
-- ============================================================

UPDATE style_layout_options SET css_template =
  '.gallery-card[data-style-layout-inline-align="left"] .card-content--slots { --typo-inline-align:left; --typo-inline-align-last:auto; }'
WHERE sub_dim='inline_align' AND value='left';

UPDATE style_layout_options SET css_template =
  '.gallery-card[data-style-layout-inline-align="center"] .card-content--slots { --typo-inline-align:center; --typo-inline-align-last:auto; }'
WHERE sub_dim='inline_align' AND value='center';

UPDATE style_layout_options SET css_template =
  '.gallery-card[data-style-layout-inline-align="right"] .card-content--slots { --typo-inline-align:right; --typo-inline-align-last:auto; }'
WHERE sub_dim='inline_align' AND value='right';

UPDATE style_layout_options SET css_template =
  '.gallery-card[data-style-layout-inline-align="stretch"] .card-content--slots { --typo-inline-align:justify; --typo-inline-align-last:justify; }'
WHERE sub_dim='inline_align' AND value='stretch';
