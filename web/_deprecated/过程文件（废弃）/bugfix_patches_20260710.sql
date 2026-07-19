-- ============================================================
-- Bug fix patches — 2026-07-10
-- Fix 7: container_group field_slot_map "highlight" -> "highlights"
-- Fix 9: weight_gradient 拉大字重差异
-- Fix 10: border_shadow 增强阴影可见度
-- ============================================================

-- Fix 7: 统一 field_slot_map 字段名 (5 rows affected)
-- cg_comment_sub, cg_chat_message_left, cg_chat_message_right, cg_social_full_card, cg_comment_item
UPDATE style_container_group_options
SET field_slot_map = REPLACE(field_slot_map::text, '"highlight"', '"highlights"')::jsonb
WHERE field_slot_map::text LIKE '%"highlight"%' AND group_code != 'none';

-- Fix 9: weight_gradient — 拉大 high_contrast 和 bold_heavy 的字重差异
UPDATE style_typo_options
SET css_template = '.gallery-card[data-style-typo-weight-gradient="high_contrast"] {
  --typo-title-weight: 900;
  --typo-date-weight: 300;
  --typo-highlight-weight: 400;
  --typo-capsule-weight: 700;
}'
WHERE sub_dim = 'weight_gradient' AND value = 'high_contrast';

UPDATE style_typo_options
SET css_template = '.gallery-card[data-style-typo-weight-gradient="bold_heavy"] {
  --typo-title-weight: 900;
  --typo-date-weight: 500;
  --typo-highlight-weight: 600;
  --typo-capsule-weight: 800;
}'
WHERE sub_dim = 'weight_gradient' AND value = 'bold_heavy';

-- Fix 10: border_shadow — 增强阴影可见度
UPDATE style_border_options
SET css_template = '.gallery-card[data-border-shadow="soft"] {
  box-shadow: 0 4px 12px rgba(0,0,0,0.35), 0 2px 4px rgba(0,0,0,0.15);
}'
WHERE sub_dim = 'border_shadow' AND value = 'soft';

UPDATE style_border_options
SET css_template = '.gallery-card[data-border-shadow="soft_small"] {
  box-shadow: 0 2px 6px rgba(0,0,0,0.25), 0 1px 2px rgba(0,0,0,0.1);
}'
WHERE sub_dim = 'border_shadow' AND value = 'soft_small';
