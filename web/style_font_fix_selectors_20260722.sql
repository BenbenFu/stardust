-- ===========================================================
-- 修复 font_family css_template 选择器键与 DB 当前 value 不匹配
-- 根因：style_typo_options.value 已被改为新字体键
--       （FontHei / FontYuan / FontSong / FontKai / FontMono /
--        FontCreative / FontHand / FontCalli / FontCartoon），
--       但 css_template 里的选择器仍写旧键
--       （display_geometric / system_sans / editorial_serif …），
--       导致 .gallery-card[data-style-typo-font-family-title="旧键"]
--       永远无法命中引擎发射出的新键属性，字体规则不生效。
-- 修复：把每行 css_template 中的旧选择器键替换成该行当前的 value。
--       规则内的字体族名（"FontHei" 等）本身已正确，无需动。
-- 说明：用 value 直接替换（用户确认下拉框 value 即这些新键）。
--       表无 option_key 列，旧写法 COALESCE(option_key, value) 会报 42703。
-- 幂等：已替换过的行再执行 replace 无副作用，可重复跑。
-- 执行：Supabase SQL Editor 全选执行；改完务必硬刷新页面重拉 dimensionCache。
-- ===========================================

-- 黑体：display_geometric -> FontHei
UPDATE style_typo_options
SET css_template = replace(css_template, 'display_geometric', value)
WHERE sub_dim='font_family' AND value='FontHei';

-- 圆体：system_sans -> FontYuan
UPDATE style_typo_options
SET css_template = replace(css_template, 'system_sans', value)
WHERE sub_dim='font_family' AND value='FontYuan';

-- 宋体：editorial_serif -> FontSong
UPDATE style_typo_options
SET css_template = replace(css_template, 'editorial_serif', value)
WHERE sub_dim='font_family' AND value='FontSong';

-- 创意：condensed_impact -> FontCreative
UPDATE style_typo_options
SET css_template = replace(css_template, 'condensed_impact', value)
WHERE sub_dim='font_family' AND value='FontCreative';

-- 手写：handwritten_note -> FontHand
UPDATE style_typo_options
SET css_template = replace(css_template, 'handwritten_note', value)
WHERE sub_dim='font_family' AND value='FontHand';

-- 卡通：modern_sans -> FontCartoon
UPDATE style_typo_options
SET css_template = replace(css_template, 'modern_sans', value)
WHERE sub_dim='font_family' AND value='FontCartoon';

-- 等宽：terminal_mono -> FontMono
UPDATE style_typo_options
SET css_template = replace(css_template, 'terminal_mono', value)
WHERE sub_dim='font_family' AND value='FontMono';

-- 楷体：rounded_soft -> FontKai
UPDATE style_typo_options
SET css_template = replace(css_template, 'rounded_soft', value)
WHERE sub_dim='font_family' AND value='FontKai';

-- 书法：slab_serif -> FontCalli
UPDATE style_typo_options
SET css_template = replace(css_template, 'slab_serif', value)
WHERE sub_dim='font_family' AND value='FontCalli';

-- 验证：实际选择器键应全部等于 value（actual_key）
SELECT label, value AS actual_key,
       (regexp_match(css_template, 'data-style-typo-font-family-title="([^"]+)"'))[1] AS selector_key
FROM style_typo_options
WHERE sub_dim='font_family'
ORDER BY label;
