-- ============================================================
-- 回退：删除 20260727c 补回的 h_align / v_align「撑满 stretch」选项
-- 仅删本次新增的 stretch 行，不影响 start/center/end。
-- ============================================================
DELETE FROM style_typo_options WHERE sub_dim='h_align' AND value='stretch';
DELETE FROM style_typo_options WHERE sub_dim='v_align' AND value='stretch';
