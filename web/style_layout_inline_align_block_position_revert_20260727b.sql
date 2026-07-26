-- 回退 2026-07-27b：移除 inline_align 模板里本次加的 justify-items，恢复为纯 text-align 状态。
-- 仅删除 'justify-items:...; ' 片段；保留 --typo-inline-align（text-align）不动。

UPDATE style_layout_options
SET css_template = REPLACE(REPLACE(REPLACE(REPLACE(css_template,
    'justify-items:stretch; ', ''),
    'justify-items:center; ', ''),
    'justify-items:end; ', ''),
    'justify-items:start; ', '')
WHERE sub_dim = 'inline_align' AND css_template LIKE '%justify-items:%';
