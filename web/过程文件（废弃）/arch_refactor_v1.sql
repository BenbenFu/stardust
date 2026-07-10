-- arch_refactor_v1.sql
-- Architecture Refactoring v1 — Per-element alignment_mode/effect, multi-select text_decoration, box_target
--
-- Changes:
-- 1. typo.alignment_mode: global CSS -> per-element CSS (data-style-typo-alignment-mode-TITLE, etc.)
-- 2. typo.text_decoration: = selector -> ~= selector (multi-select word matching)
-- 3. effect.filter_self/filter_backdrop/transform/animation: global CSS -> per-element CSS
-- 4. deco.box_target: new sub_dim with 5 rows
-- 5. deco.box_style: CSS expanded to include box_target compound selectors
--
-- Prerequisites: Run verification SELECTs first to confirm current DB state.
-- All statements are idempotent (ON CONFLICT DO UPDATE / safe to re-run).

-- ============================================================
-- VERIFICATION: Check current state before migration
-- ============================================================

-- SELECT sub_dim, option_key, css_template FROM style_typo_options WHERE sub_dim = 'alignment_mode' ORDER BY sort_order;
-- SELECT sub_dim, option_key, css_template FROM style_typo_options WHERE sub_dim = 'text_decoration' ORDER BY sort_order;
-- SELECT sub_dim, option_key, css_template FROM style_effect_options ORDER BY sub_dim, sort_order;
-- SELECT sub_dim, option_key, css_template FROM style_deco_options WHERE sub_dim = 'box_style' ORDER BY sort_order;

-- ============================================================
-- 1. alignment_mode: Global -> Per-element CSS
-- ============================================================
-- Transforms:
--   .gallery-card[data-style-typo-alignment-mode="left_flow"] { --typo-title-align:left; --typo-date-align:left; --typo-highlight-align:left; --typo-capsule-align:left; }
-- Into:
--   .gallery-card[data-style-typo-alignment-mode-title="left_flow"] { --typo-title-align:left; }
--   .gallery-card[data-style-typo-alignment-mode-date="left_flow"] { --typo-date-align:left; }
--   .gallery-card[data-style-typo-alignment-mode-capsule="left_flow"] { --typo-capsule-align:left; }
--   .gallery-card[data-style-typo-alignment-mode-highlights="left_flow"] { --typo-highlight-align:left; }

-- left_flow
UPDATE style_typo_options SET css_template =
  '.gallery-card[data-style-typo-alignment-mode-title="left_flow"] { --typo-title-align:left; }
   .gallery-card[data-style-typo-alignment-mode-date="left_flow"] { --typo-date-align:left; }
   .gallery-card[data-style-typo-alignment-mode-capsule="left_flow"] { --typo-capsule-align:left; }
   .gallery-card[data-style-typo-alignment-mode-highlights="left_flow"] { --typo-highlight-align:left; }'
WHERE sub_dim = 'alignment_mode' AND option_key = 'left_flow';

-- centered_formal
UPDATE style_typo_options SET css_template =
  '.gallery-card[data-style-typo-alignment-mode-title="centered_formal"] { --typo-title-align:center; }
   .gallery-card[data-style-typo-alignment-mode-date="centered_formal"] { --typo-date-align:center; }
   .gallery-card[data-style-typo-alignment-mode-capsule="centered_formal"] { --typo-capsule-align:center; }
   .gallery-card[data-style-typo-alignment-mode-highlights="centered_formal"] { --typo-highlight-align:center; }'
WHERE sub_dim = 'alignment_mode' AND option_key = 'centered_formal';

-- right_flow
UPDATE style_typo_options SET css_template =
  '.gallery-card[data-style-typo-alignment-mode-title="right_flow"] { --typo-title-align:right; }
   .gallery-card[data-style-typo-alignment-mode-date="right_flow"] { --typo-date-align:right; }
   .gallery-card[data-style-typo-alignment-mode-capsule="right_flow"] { --typo-capsule-align:right; }
   .gallery-card[data-style-typo-alignment-mode-highlights="right_flow"] { --typo-highlight-align:right; }'
WHERE sub_dim = 'alignment_mode' AND option_key = 'right_flow';

-- justify
UPDATE style_typo_options SET css_template =
  '.gallery-card[data-style-typo-alignment-mode-title="justify"] { --typo-title-align:justify; }
   .gallery-card[data-style-typo-alignment-mode-date="justify"] { --typo-date-align:justify; }
   .gallery-card[data-style-typo-alignment-mode-capsule="justify"] { --typo-capsule-align:justify; }
   .gallery-card[data-style-typo-alignment-mode-highlights="justify"] { --typo-highlight-align:justify; }'
WHERE sub_dim = 'alignment_mode' AND option_key = 'justify';

-- justify_center
UPDATE style_typo_options SET css_template =
  '.gallery-card[data-style-typo-alignment-mode-title="justify_center"] { --typo-title-align:justify; }
   .gallery-card[data-style-typo-alignment-mode-date="justify_center"] { --typo-date-align:center; }
   .gallery-card[data-style-typo-alignment-mode-capsule="justify_center"] { --typo-capsule-align:justify; }
   .gallery-card[data-style-typo-alignment-mode-highlights="justify_center"] { --typo-highlight-align:justify; }'
WHERE sub_dim = 'alignment_mode' AND option_key = 'justify_center';

-- ============================================================
-- 2. text_decoration: = selector -> ~= selector
-- ============================================================
-- Changes all [data-style-typo-text-decoration-ELEMENT="VALUE"] to [data-style-typo-text-decoration-ELEMENT~="VALUE"]
-- This enables multi-select: multiple values space-joined in the data attr, ~= matches any word.

-- Generic approach: replace =" with ~=" only within text-decoration selectors
-- Since the css_template contains the full selector, we use regexp_replace
UPDATE style_typo_options
SET css_template = regexp_replace(
  css_template,
  'data-style-typo-text-decoration-(title|date|capsule|highlights)="',
  'data-style-typo-text-decoration-\1~="',
  'g'
)
WHERE sub_dim = 'text_decoration'
  AND css_template IS NOT NULL
  AND css_template != '';

-- ============================================================
-- 3. effect: Global -> Per-element CSS
-- ============================================================
-- Transforms:
--   .gallery-card[data-style-effect-filter="blur"] { filter: blur(4px); }
-- Into:
--   .gallery-card[data-style-effect-filter-title="blur"] .card-title { filter: blur(4px); }
--   .gallery-card[data-style-effect-filter-date="blur"] .card-date { filter: blur(4px); }
--   .gallery-card[data-style-effect-filter-capsule="blur"] .card-capsule { filter: blur(4px); }
--   .gallery-card[data-style-effect-filter-highlights="blur"] .card-highlights { filter: blur(4px); }

-- ---- filter_self ----
-- blur
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-filter-title="blur"] .card-title { filter: blur(4px); }
   .gallery-card[data-style-effect-filter-date="blur"] .card-date { filter: blur(4px); }
   .gallery-card[data-style-effect-filter-capsule="blur"] .card-capsule { filter: blur(4px); }
   .gallery-card[data-style-effect-filter-highlights="blur"] .card-highlights { filter: blur(4px); }'
WHERE sub_dim = 'filter_self' AND option_key = 'blur';

-- grayscale
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-filter-title="grayscale"] .card-title { filter: grayscale(1); }
   .gallery-card[data-style-effect-filter-date="grayscale"] .card-date { filter: grayscale(1); }
   .gallery-card[data-style-effect-filter-capsule="grayscale"] .card-capsule { filter: grayscale(1); }
   .gallery-card[data-style-effect-filter-highlights="grayscale"] .card-highlights { filter: grayscale(1); }'
WHERE sub_dim = 'filter_self' AND option_key = 'grayscale';

-- sepia
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-filter-title="sepia"] .card-title { filter: sepia(0.8); }
   .gallery-card[data-style-effect-filter-date="sepia"] .card-date { filter: sepia(0.8); }
   .gallery-card[data-style-effect-filter-capsule="sepia"] .card-capsule { filter: sepia(0.8); }
   .gallery-card[data-style-effect-filter-highlights="sepia"] .card-highlights { filter: sepia(0.8); }'
WHERE sub_dim = 'filter_self' AND option_key = 'sepia';

-- ---- filter_backdrop ----
-- blur_backdrop
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-filter-title="blur_backdrop"] .card-title { backdrop-filter: blur(8px); }
   .gallery-card[data-style-effect-filter-date="blur_backdrop"] .card-date { backdrop-filter: blur(8px); }
   .gallery-card[data-style-effect-filter-capsule="blur_backdrop"] .card-capsule { backdrop-filter: blur(8px); }
   .gallery-card[data-style-effect-filter-highlights="blur_backdrop"] .card-highlights { backdrop-filter: blur(8px); }'
WHERE sub_dim = 'filter_backdrop' AND option_key = 'blur_backdrop';

-- frosted
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-filter-title="frosted"] .card-title { backdrop-filter: blur(8px) saturate(1.5); }
   .gallery-card[data-style-effect-filter-date="frosted"] .card-date { backdrop-filter: blur(8px) saturate(1.5); }
   .gallery-card[data-style-effect-filter-capsule="frosted"] .card-capsule { backdrop-filter: blur(8px) saturate(1.5); }
   .gallery-card[data-style-effect-filter-highlights="frosted"] .card-highlights { backdrop-filter: blur(8px) saturate(1.5); }'
WHERE sub_dim = 'filter_backdrop' AND option_key = 'frosted';

-- ---- transform ----
-- slight_tilt
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-transform-title="slight_tilt"] .card-title { transform: rotate(-1deg); }
   .gallery-card[data-style-effect-transform-date="slight_tilt"] .card-date { transform: rotate(-1deg); }
   .gallery-card[data-style-effect-transform-capsule="slight_tilt"] .card-capsule { transform: rotate(-1deg); }
   .gallery-card[data-style-effect-transform-highlights="slight_tilt"] .card-highlights { transform: rotate(-1deg); }'
WHERE sub_dim = 'transform' AND option_key = 'slight_tilt';

-- mirror
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-transform-title="mirror"] .card-title { transform: scaleX(-1); }
   .gallery-card[data-style-effect-transform-date="mirror"] .card-date { transform: scaleX(-1); }
   .gallery-card[data-style-effect-transform-capsule="mirror"] .card-capsule { transform: scaleX(-1); }
   .gallery-card[data-style-effect-transform-highlights="mirror"] .card-highlights { transform: scaleX(-1); }'
WHERE sub_dim = 'transform' AND option_key = 'mirror';

-- lift
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-transform-title="lift"] .card-title { transform: translateY(-2px); }
   .gallery-card[data-style-effect-transform-date="lift"] .card-date { transform: translateY(-2px); }
   .gallery-card[data-style-effect-transform-capsule="lift"] .card-capsule { transform: translateY(-2px); }
   .gallery-card[data-style-effect-transform-highlights="lift"] .card-highlights { transform: translateY(-2px); }'
WHERE sub_dim = 'transform' AND option_key = 'lift';

-- ---- animation ----
-- blink
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-animation-title="blink"] .card-title { animation: hardware-blink 1.5s infinite; }
   .gallery-card[data-style-effect-animation-date="blink"] .card-date { animation: hardware-blink 1.5s infinite; }
   .gallery-card[data-style-effect-animation-capsule="blink"] .card-capsule { animation: hardware-blink 1.5s infinite; }
   .gallery-card[data-style-effect-animation-highlights="blink"] .card-highlights { animation: hardware-blink 1.5s infinite; }'
WHERE sub_dim = 'animation' AND option_key = 'blink';

-- scanline_jitter
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-animation-title="scanline_jitter"] .card-title { animation: scanline-jitter 0.3s infinite; }
   .gallery-card[data-style-effect-animation-date="scanline_jitter"] .card-date { animation: scanline-jitter 0.3s infinite; }
   .gallery-card[data-style-effect-animation-capsule="scanline_jitter"] .card-capsule { animation: scanline-jitter 0.3s infinite; }
   .gallery-card[data-style-effect-animation-highlights="scanline_jitter"] .card-highlights { animation: scanline-jitter 0.3s infinite; }'
WHERE sub_dim = 'animation' AND option_key = 'scanline_jitter';

-- glow_pulse
UPDATE style_effect_options SET css_template =
  '.gallery-card[data-style-effect-animation-title="glow_pulse"] .card-title { animation: hardware-blink 2s infinite; text-shadow: 0 0 4px var(--card-accent, #3b82f6); }
   .gallery-card[data-style-effect-animation-date="glow_pulse"] .card-date { animation: hardware-blink 2s infinite; }
   .gallery-card[data-style-effect-animation-capsule="glow_pulse"] .card-capsule { animation: hardware-blink 2s infinite; }
   .gallery-card[data-style-effect-animation-highlights="glow_pulse"] .card-highlights { animation: hardware-blink 2s infinite; }'
WHERE sub_dim = 'animation' AND option_key = 'glow_pulse';

-- ============================================================
-- 4. box_target: New sub_dim rows in style_deco_options
-- ============================================================

INSERT INTO style_deco_options (sub_dim, option_key, label, description, sort_order, css_template)
VALUES
  ('box_target', 'global',     'global',    'Box applies to entire card',      10, ''),
  ('box_target', 'date',       'date',      'Box applies to date field',       20, ''),
  ('box_target', 'title',      'title',     'Box applies to title field',      30, ''),
  ('box_target', 'highlights', 'highlights','Box applies to highlights',       40, ''),
  ('box_target', 'capsule',    'capsule',   'Box applies to capsule field',    50, '')
ON CONFLICT (sub_dim, option_key) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description;

-- ============================================================
-- 5. box_style: Expand CSS to include box_target compound selectors
-- ============================================================
-- Each box_style option now has 5 variants (one per target).
-- The css_template uses both [data-style-deco-box-target="X"] and [data-style-deco-box="VALUE"] in compound selectors.

-- rounded
UPDATE style_deco_options SET css_template =
  '.gallery-card[data-style-deco-box-target="global"][data-style-deco-box="rounded"] { border-radius: 8px; }
   .gallery-card[data-style-deco-box-target="title"][data-style-deco-box="rounded"] .card-title { border-radius: 8px; }
   .gallery-card[data-style-deco-box-target="date"][data-style-deco-box="rounded"] .card-date { border-radius: 8px; }
   .gallery-card[data-style-deco-box-target="highlights"][data-style-deco-box="rounded"] .card-highlights { border-radius: 8px; }
   .gallery-card[data-style-deco-box-target="capsule"][data-style-deco-box="rounded"] .card-capsule { border-radius: 8px; }'
WHERE sub_dim = 'box_style' AND option_key = 'rounded';

-- border_box
UPDATE style_deco_options SET css_template =
  '.gallery-card[data-style-deco-box-target="global"][data-style-deco-box="border_box"] { border: 1px solid var(--card-accent, #ccc); padding: 8px; }
   .gallery-card[data-style-deco-box-target="title"][data-style-deco-box="border_box"] .card-title { border: 1px solid var(--card-accent, #ccc); padding: 4px 8px; }
   .gallery-card[data-style-deco-box-target="date"][data-style-deco-box="border_box"] .card-date { border: 1px solid var(--card-accent, #ccc); padding: 2px 6px; }
   .gallery-card[data-style-deco-box-target="highlights"][data-style-deco-box="border_box"] .card-highlights { border: 1px solid var(--card-accent, #ccc); padding: 4px 8px; }
   .gallery-card[data-style-deco-box-target="capsule"][data-style-deco-box="border_box"] .card-capsule { border: 1px solid var(--card-accent, #ccc); padding: 2px 6px; }'
WHERE sub_dim = 'box_style' AND option_key = 'border_box';

-- bg_fill
UPDATE style_deco_options SET css_template =
  '.gallery-card[data-style-deco-box-target="global"][data-style-deco-box="bg_fill"] { background: var(--card-muted, #e5e5e5); }
   .gallery-card[data-style-deco-box-target="title"][data-style-deco-box="bg_fill"] .card-title { background: var(--card-muted, #e5e5e5); padding: 4px 8px; }
   .gallery-card[data-style-deco-box-target="date"][data-style-deco-box="bg_fill"] .card-date { background: var(--card-muted, #e5e5e5); padding: 2px 6px; }
   .gallery-card[data-style-deco-box-target="highlights"][data-style-deco-box="bg_fill"] .card-highlights { background: var(--card-muted, #e5e5e5); padding: 4px 8px; }
   .gallery-card[data-style-deco-box-target="capsule"][data-style-deco-box="bg_fill"] .card-capsule { background: var(--card-muted, #e5e5e5); padding: 2px 6px; }'
WHERE sub_dim = 'box_style' AND option_key = 'bg_fill';

-- shadow_box
UPDATE style_deco_options SET css_template =
  '.gallery-card[data-style-deco-box-target="global"][data-style-deco-box="shadow_box"] { box-shadow: 2px 2px 6px rgba(0,0,0,0.15); }
   .gallery-card[data-style-deco-box-target="title"][data-style-deco-box="shadow_box"] .card-title { box-shadow: 2px 2px 6px rgba(0,0,0,0.15); padding: 4px 8px; }
   .gallery-card[data-style-deco-box-target="date"][data-style-deco-box="shadow_box"] .card-date { box-shadow: 1px 1px 4px rgba(0,0,0,0.15); padding: 2px 6px; }
   .gallery-card[data-style-deco-box-target="highlights"][data-style-deco-box="shadow_box"] .card-highlights { box-shadow: 2px 2px 6px rgba(0,0,0,0.15); padding: 4px 8px; }
   .gallery-card[data-style-deco-box-target="capsule"][data-style-deco-box="shadow_box"] .card-capsule { box-shadow: 1px 1px 4px rgba(0,0,0,0.15); padding: 2px 6px; }'
WHERE sub_dim = 'box_style' AND option_key = 'shadow_box';

-- ============================================================
-- 6. header_deco / side_accent: CSS updates for new DOM elements
-- ============================================================
-- The renderer now outputs <div class="card-header-text"> and <div class="card-side-text">
-- when header_deco/side_accent is set and header_text/side_text is non-empty.
-- Existing CSS that uses ::before/::after pseudo-elements can remain.
-- New CSS targeting the actual DOM elements can be added per option.

-- NOTE: These updates are optional. Existing pseudo-element CSS still works.
-- Only add .card-header-text / .card-side-text targeting if the option
-- should style the text content rather than (or in addition to) pseudo-elements.

-- Example (uncomment and adapt per option as needed):
-- UPDATE style_element_options SET css_template = css_template || E'\n'
--   || '.gallery-card[data-style-element-header="label_bar"] .card-header-text { display: block; font-size: 10px; letter-spacing: 2px; text-align: center; border-bottom: 1px solid var(--card-accent, #ccc); padding-bottom: 4px; margin-bottom: 6px; }'
-- WHERE sub_dim = 'header_deco' AND option_key = 'label_bar';

-- ============================================================
-- VERIFICATION: Check results after migration
-- ============================================================

-- SELECT sub_dim, option_key, left(css_template, 120) as css_preview FROM style_typo_options WHERE sub_dim = 'alignment_mode' ORDER BY sort_order;
-- SELECT sub_dim, option_key, left(css_template, 120) as css_preview FROM style_typo_options WHERE sub_dim = 'text_decoration' ORDER BY sort_order;
-- SELECT sub_dim, option_key, left(css_template, 120) as css_preview FROM style_effect_options ORDER BY sub_dim, sort_order;
-- SELECT sub_dim, option_key, css_template FROM style_deco_options WHERE sub_dim = 'box_target' ORDER BY sort_order;
-- SELECT sub_dim, option_key, left(css_template, 120) as css_preview FROM style_deco_options WHERE sub_dim = 'box_style' ORDER BY sort_order;

-- ============================================================
-- NOTES:
-- 1. The alignment_mode UPDATEs use option_key. If your DB uses 'value' column
--    instead of 'option_key', replace option_key with value in the WHERE clauses.
-- 2. The text_decoration regexp_replace handles all 4 element suffixes in one pass.
-- 3. If there are additional alignment_mode/effect/box_style options not covered
--    above, add similar UPDATE statements with the appropriate per-element CSS.
-- 4. The 'none' option for filter_self/filter_backdrop/transform/animation does
--    NOT need per-element CSS — the renderer skips 'none' values (no data attr generated).
-- ============================================================
