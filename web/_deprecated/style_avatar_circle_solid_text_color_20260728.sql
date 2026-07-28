UPDATE style_deco_options
SET css_template = regexp_replace(
  css_template,
  '(background: var\(--card-accent, #ccc\);)',
  E'\\1\n  color: var(--card-bg, #fff);',
  'g'
)
WHERE css_template LIKE '%data-style-deco-avatar=%'
  AND css_template LIKE '%background: var(--card-accent, #ccc)%'
  AND css_template NOT LIKE '%color: var(--card-bg%';

-- 回退
-- UPDATE style_deco_options SET css_template = regexp_replace(css_template, '\s*color: var\(--card-bg, #fff\);\s*\n', '', 'g') WHERE css_template LIKE '%color: var(--card-bg%';
