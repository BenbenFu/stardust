-- 回退：删除 cross_alignment_mode 维度全部选项（与 apply SQL 一一对应）
DELETE FROM style_typo_options
WHERE sub_dim = 'cross_alignment_mode'
  AND value IN ('start', 'center', 'end');
