-- ============================================================
-- 字体映射扩展：自定义顶栏/侧栏文字 (header_text / side_text)
-- 旧问题：引擎把 DB 原始值(如 'terminal_mono')当 font-family 内联注入，
--         浏览器不识别 -> 回退宋体。
-- 修复：引擎改为在 .card-header-text / .card-side-text 写
--       data-style-typo-font-family-headertext / -sidetext，
--       由本 SQL 扩展后的 css_template 提供真实字体栈（与四字段同源）。
-- 执行：Supabase SQL Editor 全选执行（agent 无写权限）。
-- ============================================================

UPDATE style_typo_options SET css_template = '.gallery-card[data-style-typo-font-family-title="rounded_soft"] .card-title { font-family: "Nunito", "PingFang SC", "Hiragino Sans GB", sans-serif; }
.gallery-card[data-style-typo-font-family-date="rounded_soft"] .card-date { font-family: "Nunito", "PingFang SC", "Hiragino Sans GB", sans-serif; }
.gallery-card[data-style-typo-font-family-highlights="rounded_soft"] .card-highlight-item { font-family: "Nunito", "PingFang SC", "Hiragino Sans GB", sans-serif; }
.gallery-card[data-style-typo-font-family-capsule="rounded_soft"] .card-capsule { font-family: "Nunito", "PingFang SC", "Hiragino Sans GB", sans-serif; }
.gallery-card[data-style-typo-font-family-headertext="rounded_soft"] .card-header-text { font-family: "Nunito", "PingFang SC", "Hiragino Sans GB", sans-serif; }
.gallery-card[data-style-typo-font-family-sidetext="rounded_soft"] .card-side-text { font-family: "Nunito", "PingFang SC", "Hiragino Sans GB", sans-serif; }' WHERE sub_dim='font_family' AND value='rounded_soft';

UPDATE style_typo_options SET css_template = '.gallery-card[data-style-typo-font-family-title="display_geometric"] .card-title { font-family: "Montserrat", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-date="display_geometric"] .card-date { font-family: "Montserrat", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-highlights="display_geometric"] .card-highlight-item { font-family: "Montserrat", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-capsule="display_geometric"] .card-capsule { font-family: "Montserrat", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-headertext="display_geometric"] .card-header-text { font-family: "Montserrat", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-sidetext="display_geometric"] .card-side-text { font-family: "Montserrat", "PingFang SC", "Microsoft YaHei", sans-serif; }' WHERE sub_dim='font_family' AND value='display_geometric';

UPDATE style_typo_options SET css_template = '.gallery-card[data-style-typo-font-family-title="condensed_impact"] .card-title { font-family: "Oswald", "PingFang SC", "Microsoft YaHei", sans-serif; font-stretch: condensed; }
.gallery-card[data-style-typo-font-family-date="condensed_impact"] .card-date { font-family: "Oswald", "PingFang SC", "Microsoft YaHei", sans-serif; font-stretch: condensed; }
.gallery-card[data-style-typo-font-family-highlights="condensed_impact"] .card-highlight-item { font-family: "Oswald", "PingFang SC", "Microsoft YaHei", sans-serif; font-stretch: condensed; }
.gallery-card[data-style-typo-font-family-capsule="condensed_impact"] .card-capsule { font-family: "Oswald", "PingFang SC", "Microsoft YaHei", sans-serif; font-stretch: condensed; }
.gallery-card[data-style-typo-font-family-headertext="condensed_impact"] .card-header-text { font-family: "Oswald", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-sidetext="condensed_impact"] .card-side-text { font-family: "Oswald", "PingFang SC", "Microsoft YaHei", sans-serif; }' WHERE sub_dim='font_family' AND value='condensed_impact';

UPDATE style_typo_options SET css_template = '.gallery-card[data-style-typo-font-family-title="slab_serif"] .card-title { font-family: "Roboto Slab", "Noto Serif SC", "Source Han Serif SC", serif; }
.gallery-card[data-style-typo-font-family-date="slab_serif"] .card-date { font-family: "Roboto Slab", "Noto Serif SC", "Source Han Serif SC", serif; }
.gallery-card[data-style-typo-font-family-highlights="slab_serif"] .card-highlight-item { font-family: "Roboto Slab", "Noto Serif SC", "Source Han Serif SC", serif; }
.gallery-card[data-style-typo-font-family-capsule="slab_serif"] .card-capsule { font-family: "Roboto Slab", "Noto Serif SC", "Source Han Serif SC", serif; }
.gallery-card[data-style-typo-font-family-headertext="slab_serif"] .card-header-text { font-family: "Roboto Slab", "Noto Serif SC", "Source Han Serif SC", serif; }
.gallery-card[data-style-typo-font-family-sidetext="slab_serif"] .card-side-text { font-family: "Roboto Slab", "Noto Serif SC", "Source Han Serif SC", serif; }' WHERE sub_dim='font_family' AND value='slab_serif';

UPDATE style_typo_options SET css_template = '.gallery-card[data-style-typo-font-family-title="modern_sans"] .card-title { font-family: "Inter", "SF Pro Display", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-date="modern_sans"] .card-date { font-family: "Inter", "SF Pro Display", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-highlights="modern_sans"] .card-highlight-item { font-family: "Inter", "SF Pro Display", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-capsule="modern_sans"] .card-capsule { font-family: "Inter", "SF Pro Display", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-headertext="modern_sans"] .card-header-text { font-family: "Inter", "SF Pro Display", "PingFang SC", "Microsoft YaHei", sans-serif; }
.gallery-card[data-style-typo-font-family-sidetext="modern_sans"] .card-side-text { font-family: "Inter", "SF Pro Display", "PingFang SC", "Microsoft YaHei", sans-serif; }' WHERE sub_dim='font_family' AND value='modern_sans';

UPDATE style_typo_options SET css_template = '.gallery-card[data-style-typo-font-family-title="handwritten_note"] .card-title { font-family: "Ma Shan Zheng", "ZCOOL XiaoWei", cursive; }
.gallery-card[data-style-typo-font-family-headertext="handwritten_note"] .card-header-text { font-family: "Ma Shan Zheng", "ZCOOL XiaoWei", cursive; }
.gallery-card[data-style-typo-font-family-sidetext="handwritten_note"] .card-side-text { font-family: "Ma Shan Zheng", "ZCOOL XiaoWei", cursive; }' WHERE sub_dim='font_family' AND value='handwritten_note';

UPDATE style_typo_options SET css_template = '.gallery-card[data-style-typo-font-family-title="terminal_mono"] .card-title { font-family: "JetBrains Mono", "Fira Code", "Source Code Pro", "Courier New", monospace; }
.gallery-card[data-style-typo-font-family-date="terminal_mono"] .card-date { font-family: "JetBrains Mono", "Fira Code", "Source Code Pro", "Courier New", monospace; }
.gallery-card[data-style-typo-font-family-highlights="terminal_mono"] .card-highlight-item { font-family: "JetBrains Mono", "Fira Code", "Source Code Pro", "Courier New", monospace; }
.gallery-card[data-style-typo-font-family-capsule="terminal_mono"] .card-capsule { font-family: "JetBrains Mono", "Fira Code", "Source Code Pro", "Courier New", monospace; }
.gallery-card[data-style-typo-font-family-headertext="terminal_mono"] .card-header-text { font-family: "JetBrains Mono", "Fira Code", "Source Code Pro", "Courier New", monospace; }
.gallery-card[data-style-typo-font-family-sidetext="terminal_mono"] .card-side-text { font-family: "JetBrains Mono", "Fira Code", "Source Code Pro", "Courier New", monospace; }' WHERE sub_dim='font_family' AND value='terminal_mono';

UPDATE style_typo_options SET css_template = '.gallery-card[data-style-typo-font-family-title="system_sans"] .card-title { font-family: system-ui, -apple-system, "Segoe UI", sans-serif; }
.gallery-card[data-style-typo-font-family-date="system_sans"] .card-date { font-family: system-ui, -apple-system, "Segoe UI", sans-serif; }
.gallery-card[data-style-typo-font-family-highlights="system_sans"] .card-highlight-item { font-family: system-ui, -apple-system, "Segoe UI", sans-serif; }
.gallery-card[data-style-typo-font-family-capsule="system_sans"] .card-capsule { font-family: system-ui, -apple-system, "Segoe UI", sans-serif; }
.gallery-card[data-style-typo-font-family-headertext="system_sans"] .card-header-text { font-family: system-ui, -apple-system, "Segoe UI", sans-serif; }
.gallery-card[data-style-typo-font-family-sidetext="system_sans"] .card-side-text { font-family: system-ui, -apple-system, "Segoe UI", sans-serif; }' WHERE sub_dim='font_family' AND value='system_sans';

UPDATE style_typo_options SET css_template = '.gallery-card[data-style-typo-font-family-title="editorial_serif"] .card-title { font-family: "Noto Serif SC", "Source Han Serif SC", "Songti SC", serif; }
.gallery-card[data-style-typo-font-family-date="editorial_serif"] .card-date { font-family: "Noto Serif SC", "Source Han Serif SC", "Songti SC", serif; }
.gallery-card[data-style-typo-font-family-highlights="editorial_serif"] .card-highlight-item { font-family: "Noto Serif SC", "Source Han Serif SC", "Songti SC", serif; }
.gallery-card[data-style-typo-font-family-capsule="editorial_serif"] .card-capsule { font-family: "Noto Serif SC", "Source Han Serif SC", "Songti SC", serif; }
.gallery-card[data-style-typo-font-family-headertext="editorial_serif"] .card-header-text { font-family: "Noto Serif SC", "Source Han Serif SC", "Songti SC", serif; }
.gallery-card[data-style-typo-font-family-sidetext="editorial_serif"] .card-side-text { font-family: "Noto Serif SC", "Source Han Serif SC", "Songti SC", serif; }' WHERE sub_dim='font_family' AND value='editorial_serif';