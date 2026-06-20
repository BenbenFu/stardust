-- ============================================================
-- backfill_css_template.sql
-- 将所有现有选项的 CSS 规则回填到 css_template 字段
-- 执行方式: 在 Supabase SQL Editor 中运行
-- 注意: css_template 存的是完整 CSS 规则字符串（含选择器）
-- ============================================================

-- ===== style_palette_options: 配色板 CSS 变量 =====
-- 每条记录的 css_template 是: .gallery-card[data-palette="xxx"] { --card-bg:...; }
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="' || value || '"] { --card-bg:' || bg || '; --card-text:' || text_color || '; --card-accent:' || accent || '; --card-muted:' || muted || '; --card-accent-rgb:' || COALESCE((SELECT accent_rgb FROM style_palette_options sp2 WHERE sp2.value = style_palette_options.value), '0,0,0') || '; --card-bg-rgb:' || COALESCE((SELECT bg_rgb FROM style_palette_options sp3 WHERE sp3.value = style_palette_options.value), '255,255,255') || '; }'
WHERE css_template IS NULL;

-- 由于上面用了 accent_rgb / bg_rgb 字段（表中可能没有），改用手动写每条记录
-- 先清空重来，用 VALUES 列表精确写入

-- 配色板（17条，含 fitzgerald）
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="industrial"] { --card-bg:transparent; --card-text:#1e2622; --card-accent:#1e2622; --card-muted:#707a65; --card-accent-rgb:30,38,34; --card-bg-rgb:0,0,0; }' WHERE value = 'industrial';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="repair_yellow"] { --card-bg:#d2c89f; --card-text:#403d30; --card-accent:#615a42; --card-muted:#837b5a; --card-accent-rgb:97,90,66; --card-bg-rgb:210,200,159; }' WHERE value = 'repair_yellow';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="printer_green"] { --card-bg:#e5ebda; --card-text:#1e2622; --card-accent:#8a8f7c; --card-muted:#8a8f7c; --card-accent-rgb:138,143,124; --card-bg-rgb:229,235,218; }' WHERE value = 'printer_green';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="bsod_blue"] { --card-bg:#1e2669; --card-text:#cadbb7; --card-accent:#4a5d8f; --card-muted:#7f86ba; --card-accent-rgb:74,93,143; --card-bg-rgb:30,38,105; }' WHERE value = 'bsod_blue';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="alert_red"] { --card-bg:transparent; --card-text:#8f341d; --card-accent:#8f341d; --card-muted:#8f341d; --card-accent-rgb:143,52,29; --card-bg-rgb:0,0,0; }' WHERE value = 'alert_red';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="terminal_black"] { --card-bg:#0b0c0a; --card-text:#707a65; --card-accent:#1e2622; --card-muted:#43473b; --card-accent-rgb:30,38,34; --card-bg-rgb:11,12,10; }' WHERE value = 'terminal_black';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="vscode_dark"] { --card-bg:#0f1419; --card-text:#cadbb7; --card-accent:#3a7d44; --card-muted:#858585; --card-accent-rgb:58,125,68; --card-bg-rgb:15,20,25; }' WHERE value = 'vscode_dark';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="archive_khaki"] { --card-bg:#f0f2eb; --card-text:#1e2622; --card-accent:#8a8f7c; --card-muted:#5a6352; --card-accent-rgb:138,143,124; --card-bg-rgb:240,242,235; }' WHERE value = 'archive_khaki';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="github_light"] { --card-bg:#ffffff; --card-text:#2d333b; --card-accent:#d1d9e0; --card-muted:#656d76; --card-accent-rgb:209,217,224; --card-bg-rgb:255,255,255; }' WHERE value = 'github_light';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="diary_cream"] { --card-bg:#faf7e8; --card-text:#4a453d; --card-accent:#c9c2b0; --card-muted:#9a9385; --card-accent-rgb:201,194,176; --card-bg-rgb:250,247,232; }' WHERE value = 'diary_cream';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="twitter_light"] { --card-bg:#ffffff; --card-text:#14171a; --card-accent:#e6ecf0; --card-muted:#657786; --card-accent-rgb:230,236,240; --card-bg-rgb:255,255,255; }' WHERE value = 'twitter_light';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="notebook_white"] { --card-bg:#fffef5; --card-text:#2c2c2c; --card-accent:#e0d9c8; --card-muted:#8a8273; --card-accent-rgb:224,217,200; --card-bg-rgb:255,254,245; }' WHERE value = 'notebook_white';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="newspaper"] { --card-bg:#ffffff; --card-text:#000000; --card-accent:#cccccc; --card-muted:#999999; --card-accent-rgb:204,204,204; --card-bg-rgb:255,255,255; }' WHERE value = 'newspaper';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="role_parchment"] { --card-bg:#f5f0e6; --card-text:#3d3529; --card-accent:#8b7355; --card-muted:#6b5a45; --card-accent-rgb:139,115,85; --card-bg-rgb:245,240,230; }' WHERE value = 'role_parchment';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="novel_warm"] { --card-bg:#f8f5f0; --card-text:#2a2520; --card-accent:#d4ccc4; --card-muted:#9a928a; --card-accent-rgb:212,204,196; --card-bg-rgb:248,245,240; }' WHERE value = 'novel_warm';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="blueprint"] { --card-bg:#ffffff; --card-text:#1e2622; --card-accent:#1e2622; --card-muted:#707a65; --card-accent-rgb:30,38,34; --card-bg-rgb:255,255,255; }' WHERE value = 'blueprint';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="mystery_dark"] { --card-bg:#2a2a2a; --card-text:#9a9a9a; --card-accent:#555555; --card-muted:#666666; --card-accent-rgb:85,85,85; --card-bg-rgb:42,42,42; }' WHERE value = 'mystery_dark';
UPDATE style_palette_options SET css_template = '.gallery-card[data-palette="fitzgerald"] { --card-bg:#faf6ee; --card-text:#1a1a1a; --card-accent:#c4a962; --card-muted:#8a8a7a; --card-accent-rgb:196,169,98; --card-bg-rgb:250,246,238; }' WHERE value = 'fitzgerald';


-- ===== style_typo_options: 字族 + 标题装饰 =====
-- family 子维度
UPDATE style_typo_options SET css_template = '.gallery-card[data-font="mono"] { --card-font:monospace; } .gallery-card .card-title { font-family:var(--card-font,monospace); }' WHERE sub_dim = 'family' AND value = 'mono';
UPDATE style_typo_options SET css_template = '.gallery-card[data-font="consolas"] { --card-font:"Consolas","Monaco",monospace; } .gallery-card .card-title { font-family:var(--card-font,monospace); }' WHERE sub_dim = 'family' AND value = 'consolas';
UPDATE style_typo_options SET css_template = '.gallery-card[data-font="serif"] { --card-font:serif; } .gallery-card .card-title { font-family:var(--card-font,monospace); }' WHERE sub_dim = 'family' AND value = 'serif';
UPDATE style_typo_options SET css_template = '.gallery-card[data-font="cursive"] { --card-font:cursive; } .gallery-card .card-title { font-family:var(--card-font,monospace); }' WHERE sub_dim = 'family' AND value = 'cursive';

-- title_deco 子维度
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="border_bottom"] .card-title { border-bottom:1px solid var(--card-accent); padding-bottom:4px; }' WHERE sub_dim = 'title_deco' AND value = 'border_bottom';
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="underline"] .card-title { text-decoration:underline; }' WHERE sub_dim = 'title_deco' AND value = 'underline';
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="wavy_underline"] .card-title { text-decoration:underline; text-decoration-style:wavy; text-decoration-color:#8f341d; }' WHERE sub_dim = 'title_deco' AND value = 'wavy_underline';
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="uppercase_center"] .card-title { text-transform:uppercase; text-align:center; letter-spacing:2px; }' WHERE sub_dim = 'title_deco' AND value = 'uppercase_center';
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="center_border_bottom"] .card-title { text-align:center; border-bottom:1px solid var(--card-accent); padding-bottom:4px; }' WHERE sub_dim = 'title_deco' AND value = 'center_border_bottom';
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="center_bg_highlight"] .card-title { text-align:center; background-color:rgba(0,0,0,0.05); padding:2px; }' WHERE sub_dim = 'title_deco' AND value = 'center_bg_highlight';
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="left_border"] .card-title { padding-left:8px; border-left:3px solid var(--card-accent); }' WHERE sub_dim = 'title_deco' AND value = 'left_border';
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="mirror"] .card-title { transform:scaleX(-1); display:inline-block; }' WHERE sub_dim = 'title_deco' AND value = 'mirror';
UPDATE style_typo_options SET css_template = '.gallery-card[data-title-deco="italic_center"] .card-title { font-style:italic; text-align:center; letter-spacing:3px; font-size:14px; }' WHERE sub_dim = 'title_deco' AND value = 'italic_center';
-- sticky_note: 由 body=sticky_note 处理，title_deco 无额外 CSS
-- function_prefix / inverted_bar: 由对应 top/border 处理，无额外 CSS
UPDATE style_typo_options SET css_template = '' WHERE sub_dim = 'title_deco' AND value IN ('none', 'sticky_note', 'function_prefix', 'inverted_bar');


-- ===== style_border_options: 线型 + 圆角 + 阴影 =====
-- style 子维度
UPDATE style_border_options SET css_template = '.gallery-card[data-border="none"] { border-width:0 !important; }' WHERE sub_dim = 'style' AND value = 'none';
UPDATE style_border_options SET css_template = '.gallery-card[data-border="thin_solid"] { border-width:1px !important; border-style:solid; }' WHERE sub_dim = 'style' AND value = 'thin_solid';
UPDATE style_border_options SET css_template = '.gallery-card[data-border="solid"] { border-width:2px !important; border-style:solid; }' WHERE sub_dim = 'style' AND value = 'solid';
UPDATE style_border_options SET css_template = '.gallery-card[data-border="thick_solid"] { border-width:3px !important; border-style:solid; }' WHERE sub_dim = 'style' AND value = 'thick_solid';
UPDATE style_border_options SET css_template = '.gallery-card[data-border="heavy_solid"] { border-width:4px !important; border-style:solid; }' WHERE sub_dim = 'style' AND value = 'heavy_solid';
UPDATE style_border_options SET css_template = '.gallery-card[data-border="double"] { border-width:3px !important; border-style:double; }' WHERE sub_dim = 'style' AND value = 'double';
UPDATE style_border_options SET css_template = '.gallery-card[data-border="dotted"] { border-width:2px !important; border-style:dotted; }' WHERE sub_dim = 'style' AND value = 'dotted';
UPDATE style_border_options SET css_template = '.gallery-card[data-border="dashed"] { border-width:1px !important; border-style:dashed; }' WHERE sub_dim = 'style' AND value = 'dashed';
UPDATE style_border_options SET css_template = '.gallery-card[data-border="left_accent"] { border-width:0 0 0 6px !important; border-left-style:solid; border-color:var(--card-accent); }' WHERE sub_dim = 'style' AND value = 'left_accent';
UPDATE style_border_options SET css_template = '.gallery-card[data-border="solid_outline"] { border-width:2px !important; border-style:solid; outline:1px solid var(--card-accent); outline-offset:0; }' WHERE sub_dim = 'style' AND value = 'solid_outline';

-- radius 子维度
UPDATE style_border_options SET css_template = '.gallery-card[data-radius="0"] { border-radius:0 !important; }' WHERE sub_dim = 'radius' AND value = '0';
UPDATE style_border_options SET css_template = '.gallery-card[data-radius="8"] { border-radius:8px !important; }' WHERE sub_dim = 'radius' AND value = '8';

-- shadow 子维度
UPDATE style_border_options SET css_template = '.gallery-card[data-shadow="none"] { box-shadow:none !important; }' WHERE sub_dim = 'shadow' AND value = 'none';
UPDATE style_border_options SET css_template = '.gallery-card[data-shadow="soft"] { box-shadow:2px 2px 8px rgba(0,0,0,0.2) !important; }' WHERE sub_dim = 'shadow' AND value = 'soft';
UPDATE style_border_options SET css_template = '.gallery-card[data-shadow="inset"] { box-shadow:inset 0 0 10px rgba(0,0,0,0.5) !important; }' WHERE sub_dim = 'shadow' AND value = 'inset';
UPDATE style_border_options SET css_template = '.gallery-card[data-shadow="soft_small"] { box-shadow:0 2px 5px rgba(0,0,0,0.1) !important; }' WHERE sub_dim = 'shadow' AND value = 'soft_small';
UPDATE style_border_options SET css_template = '.gallery-card[data-shadow="double_ring"] { box-shadow:0 0 0 2px var(--card-accent),0 0 0 4px var(--card-bg,#fff),0 0 0 6px var(--card-accent) !important; }' WHERE sub_dim = 'shadow' AND value = 'double_ring';


-- ===== style_deco_options: 背景纹理 + 分隔符 + 伪元素 =====
-- bg_pattern 子维度
UPDATE style_deco_options SET css_template = '.gallery-card[data-bg-pattern="tape_stripe"] { padding-top:25px; } .gallery-card[data-bg-pattern="tape_stripe"]::before { content:""; position:absolute; top:0; left:0; right:0; height:20px; background:linear-gradient(135deg,var(--card-bg) 50%,rgba(var(--card-accent-rgb),0.3) 50%); background-size:15px 15px; pointer-events:none; }' WHERE sub_dim = 'bg_pattern' AND value = 'tape_stripe';
UPDATE style_deco_options SET css_template = '.gallery-card[data-bg-pattern="perf_line"]::before { content:""; position:absolute; top:0; left:6px; right:6px; height:3px; background:repeating-linear-gradient(90deg,var(--card-accent) 0px,var(--card-accent) 2px,transparent 2px,transparent 4px); pointer-events:none; }' WHERE sub_dim = 'bg_pattern' AND value = 'perf_line';
UPDATE style_deco_options SET css_template = '.gallery-card[data-bg-pattern="scanline"]::after { content:""; position:absolute; top:0; left:0; right:0; bottom:0; background:linear-gradient(var(--card-accent) 1px,transparent 1px); background-size:100% 2px; pointer-events:none; opacity:0.15; }' WHERE sub_dim = 'bg_pattern' AND value = 'scanline';
UPDATE style_deco_options SET css_template = '.gallery-card[data-bg-pattern="lines"] { background-image:linear-gradient(var(--card-accent) 1px,transparent 1px) !important; background-size:100% 24px !important; background-position:0 30px; }' WHERE sub_dim = 'bg_pattern' AND value = 'lines';
UPDATE style_deco_options SET css_template = '.gallery-card[data-bg-pattern="grid"] { background-image:linear-gradient(rgba(0,0,0,0.05) 1px,transparent 1px),linear-gradient(90deg,rgba(0,0,0,0.05) 1px,transparent 1px) !important; background-size:20px 20px !important; }' WHERE sub_dim = 'bg_pattern' AND value = 'grid';

-- separator 子维度（gold_thin_line 特殊处理）
UPDATE style_deco_options SET css_template = '.gallery-card .hl-sep { display:block; text-align:center; margin:5px 0; font-family:monospace; font-size:10px; user-select:none; pointer-events:none; opacity:0.3; color:var(--card-muted); }' WHERE sub_dim = 'separator' AND value = 'asterisk';
-- 分隔符的 css_template 其实是「当 separator=xxx 时，hl-sep 元素显示什么内容」
-- 但更合理的设计是: css_template 存选择器 + 规则， separator 比较特殊（是内容不是样式）
-- 简化处理: separator 的 css_template 留空，由 renderStyleJson 硬编码处理内容
-- 只有 gold_thin_line 需要特殊 CSS（细线样式）
UPDATE style_deco_options SET css_template = '.gallery-card .hl-sep.sep-gold_thin_line { border-top:1px solid var(--card-accent); margin:8px 20px; opacity:0.6; height:0; overflow:hidden; text-indent:-9999px; white-space:nowrap; }' WHERE sub_dim = 'separator' AND value = 'gold_thin_line';
UPDATE style_deco_options SET css_template = '' WHERE sub_dim = 'separator' AND value != 'gold_thin_line';

-- pseudo_label 子维度
UPDATE style_deco_options SET css_template = '.gallery-card[data-pseudo-label="tamagotchi"]::before { content:"TAMAGOTCHI"; position:absolute; top:5px; left:50%; transform:translateX(-50%); font-size:10px; color:var(--card-accent); letter-spacing:1px; pointer-events:none; }' WHERE sub_dim = 'pseudo_label' AND value = 'tamagotchi';
UPDATE style_deco_options SET css_template = '.gallery-card[data-pseudo-label="question_mark"]::after { content:"?"; position:absolute; bottom:5px; right:10px; font-size:24px; color:#444; opacity:0.5; pointer-events:none; }' WHERE sub_dim = 'pseudo_label' AND value = 'question_mark';
UPDATE style_deco_options SET css_template = '.gallery-card[data-pseudo-label="art_deco_diamond"]::before { content:"\25C6 \25C7 \25C6 \25C7 \25C6"; display:block; text-align:center; font-size:8px; letter-spacing:4px; color:var(--card-accent); padding:4px 0; border-top:1px solid var(--card-accent); border-bottom:1px solid var(--card-accent); pointer-events:none; } .gallery-card[data-pseudo-label="art_deco_diamond"]::after { content:"\25C6 \25C7 \25C6 \25C7 \25C6"; display:block; text-align:center; font-size:8px; letter-spacing:4px; color:var(--card-accent); padding:4px 0; border-top:1px solid var(--card-accent); pointer-events:none; }' WHERE sub_dim = 'pseudo_label' AND value = 'art_deco_diamond';


-- ===== style_layout_options: top / body / bottom / side / overlay =====
-- top 子维度
UPDATE style_layout_options SET css_template = '.gallery-card[data-top="label"] .top-label { position:absolute; top:5px; left:50%; transform:translateX(-50%); font-size:10px; letter-spacing:1px; pointer-events:none; color:var(--card-accent); }' WHERE sub_dim = 'top' AND value = 'label';
UPDATE style_layout_options SET css_template = '.gallery-card[data-top="status_bar"] .top-status-bar { position:absolute; top:0; left:0; right:0; background-color:var(--card-accent); color:var(--card-bg,#fff); padding:2px 5px; font-size:9px; display:flex; justify-content:space-between; animation:hardware-blink 2s infinite steps(2); }' WHERE sub_dim = 'top' AND value = 'status_bar';
UPDATE style_layout_options SET css_template = '.gallery-card[data-top="warning_bar"] .top-warning-bar { position:absolute; top:0; left:0; right:0; background-color:var(--card-accent); color:#fff; padding:3px 5px; font-size:9px; display:flex; justify-content:space-between; }' WHERE sub_dim = 'top' AND value = 'warning_bar';
UPDATE style_layout_options SET css_template = '.gallery-card[data-top="doc_header"] .top-doc-header { position:absolute; top:0; left:0; right:0; background-color:rgba(var(--card-accent-rgb),0.12); padding:3px 5px; font-size:9px; display:flex; justify-content:space-between; border-bottom:1px solid var(--card-accent); }' WHERE sub_dim = 'top' AND value = 'doc_header';
UPDATE style_layout_options SET css_template = '.gallery-card[data-top="email_header"] .top-email-header { background-color:rgba(var(--card-accent-rgb),0.08); padding:5px; margin:-10px -10px 10px -10px; border-bottom:1px solid rgba(var(--card-accent-rgb),0.4); font-size:11px; display:flex; justify-content:space-between; } .gallery-card[data-top="email_header"] .email-from { font-weight:bold; color:var(--card-accent); } .gallery-card[data-top="email_header"] .email-date { color:var(--card-muted); }' WHERE sub_dim = 'top' AND value = 'email_header';
UPDATE style_layout_options SET css_template = '.gallery-card[data-top="user_bar"] .top-user-bar { display:flex; align-items:center; margin-bottom:10px; } .gallery-card[data-top="user_bar"] .social-avatar { width:32px; height:32px; background-color:rgba(var(--card-accent-rgb),0.5); border:2px solid var(--card-text); margin-right:10px; flex-shrink:0; } .gallery-card[data-top="user_bar"] .user-info { flex:1; min-width:0; } .gallery-card[data-top="user_bar"] .social-username { font-weight:bold; font-size:12px; } .gallery-card[data-top="user_bar"] .social-handle { font-size:10px; color:var(--card-muted); }' WHERE sub_dim = 'top' AND value = 'user_bar';
UPDATE style_layout_options SET css_template = '.gallery-card[data-top="dark_bar"] .card-title { background-color:var(--card-text); color:var(--card-bg,#fff); padding:5px; margin:-10px -10px 10px -10px; text-align:center; font-size:13px; }' WHERE sub_dim = 'top' AND value = 'dark_bar';
UPDATE style_layout_options SET css_template = '.gallery-card[data-top="role_panel"] .top-role-panel { display:flex; align-items:center; margin-bottom:10px; padding-bottom:10px; border-bottom:2px solid var(--card-accent); } .gallery-card[data-top="role_panel"] .role-avatar { width:56px; height:56px; border:2px solid var(--card-accent); margin-right:12px; background-color:rgba(var(--card-accent-rgb),0.25); flex-shrink:0; position:relative; } .gallery-card[data-top="role_panel"] .role-avatar::after { content:"?"; position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); font-size:22px; color:var(--card-accent); } .gallery-card[data-top="role_panel"] .role-info { flex:1; min-width:0; } .gallery-card[data-top="role_panel"] .role-name { font-size:14px; font-weight:bold; letter-spacing:1px; } .gallery-card[data-top="role_panel"] .role-date { font-size:9px; color:var(--card-muted); } .gallery-card[data-top="role_panel"] .role-stat { margin:4px 0 0 0; font-size:10px; color:var(--card-muted); } .gallery-card[data-top="role_panel"] .role-bar { height:7px; background-color:rgba(var(--card-accent-rgb),0.25); margin-top:3px; } .gallery-card[data-top="role_panel"] .role-bar-fill { height:100%; background-color:var(--card-accent); } .gallery-card[data-top="role_panel"] .role-inject { margin-top:4px; font-size:8px; color:var(--card-accent); text-align:right; }' WHERE sub_dim = 'top' AND value = 'role_panel';

-- body 子维度
UPDATE style_layout_options SET css_template = '.gallery-card[data-body="code_area"] { padding-left:40px; } .gallery-card[data-body="code_area"] .card-title::before { content:"function "; color:#569cd6; } .gallery-card[data-body="code_area"] .card-title::after { content:"() {"; color:#d4d4d4; } .gallery-card[data-body="code_area"] .card-date::before { content:"// "; color:var(--card-muted); font-style:italic; }' WHERE sub_dim = 'body' AND value = 'code_area';
UPDATE style_layout_options SET css_template = '.gallery-card[data-body="ascii_zone"] .body-ascii-art { color:var(--card-muted); font-size:10px; line-height:1; margin-bottom:8px; white-space:pre; text-align:center; }' WHERE sub_dim = 'body' AND value = 'ascii_zone';
UPDATE style_layout_options SET css_template = '.gallery-card[data-body="sticky_note"] .card-title { background-color:#ffefb3; padding:2px 8px; margin:-20px auto 15px auto; width:fit-content; box-shadow:2px 2px 3px rgba(0,0,0,0.1); }' WHERE sub_dim = 'body' AND value = 'sticky_note';

-- bottom 子维度
UPDATE style_layout_options SET css_template = '.gallery-card[data-bottom="style_tag"] .card-style { font-family:monospace; font-size:9px; color:var(--card-muted); margin-top:8px; }' WHERE sub_dim = 'bottom' AND value = 'style_tag';
UPDATE style_layout_options SET css_template = '.gallery-card[data-bottom="tag_bar"] .card-footer-h { display:flex; justify-content:space-between; margin-top:8px; padding-top:4px; border-top:1px dashed var(--card-muted); font-size:9px; color:var(--card-muted); }' WHERE sub_dim = 'bottom' AND value = 'tag_bar';

-- side 子维度
UPDATE style_layout_options SET css_template = '.gallery-card[data-side="line_numbers"] { padding-left:40px; } .gallery-card[data-side="line_numbers"] .side-line-numbers { position:absolute; left:5px; top:10px; font-size:10px; color:rgba(var(--card-accent-rgb),0.4); line-height:1.5; text-align:right; width:25px; pointer-events:none; border-right:1px solid rgba(var(--card-accent-rgb),0.3); padding-right:5px; }' WHERE sub_dim = 'side' AND value = 'line_numbers';
UPDATE style_layout_options SET css_template = '.gallery-card[data-side="holes"] .side-holes { position:absolute; top:0; bottom:0; width:6px; background-image:radial-gradient(var(--card-bg,#fff) 40%,transparent 42%); background-size:6px 6px; pointer-events:none; } .gallery-card[data-side="holes"] .side-holes.left { left:0; } .gallery-card[data-side="holes"] .side-holes.right { right:0; }' WHERE sub_dim = 'side' AND value = 'holes';

-- overlay 子维度
UPDATE style_layout_options SET css_template = '.gallery-card[data-overlay="seal"] .overlay-seal { position:absolute; top:35px; right:10px; font-size:8px; border:1px solid var(--card-muted); padding:2px 4px; color:var(--card-muted); pointer-events:none; }' WHERE sub_dim = 'overlay' AND value = 'seal';
UPDATE style_layout_options SET css_template = '.gallery-card[data-overlay="stamp"] .overlay-stamp { position:absolute; top:35%; right:8%; border:2px solid var(--card-accent); color:var(--card-accent); font-size:12px; padding:3px 5px; transform:rotate(-20deg); user-select:none; pointer-events:none; animation:hardware-blink 1s infinite steps(2); }' WHERE sub_dim = 'overlay' AND value = 'stamp';
UPDATE style_layout_options SET css_template = '.gallery-card[data-overlay="tape"] { padding-top:25px; } .gallery-card[data-overlay="tape"] .overlay-tape { position:absolute; top:0; left:0; right:0; height:20px; background:linear-gradient(135deg,var(--card-bg) 50%,rgba(var(--card-accent-rgb),0.3) 50%); background-size:15px 15px; pointer-events:none; } .gallery-card[data-overlay="tape"]::after { content:""; position:absolute; bottom:5px; right:5px; width:30px; height:30px; background-image:radial-gradient(rgba(0,0,0,0.15) 30%,transparent 60%); pointer-events:none; }' WHERE sub_dim = 'overlay' AND value = 'tape';
UPDATE style_layout_options SET css_template = '.gallery-card[data-overlay="scanline"] .overlay-scanline { position:absolute; top:0; left:0; right:0; bottom:0; background:linear-gradient(var(--card-accent) 1px,transparent 1px); background-size:100% 2px; pointer-events:none; opacity:0.15; animation:scanline-jitter 0.1s infinite steps(2); }' WHERE sub_dim = 'overlay' AND value = 'scanline';
UPDATE style_layout_options SET css_template = '.gallery-card[data-overlay="dump"] .overlay-dump { font-size:11px; color:var(--card-bg,#fff); border:1px solid var(--card-muted); padding:5px; margin-top:5px; text-align:right; font-family:monospace; }' WHERE sub_dim = 'overlay' AND value = 'dump';
UPDATE style_layout_options SET css_template = '.gallery-card[data-overlay="censored"] .card-title { position:relative; } .gallery-card[data-overlay="censored"] .card-title::after { content:""; position:absolute; top:0; right:0; width:40%; height:100%; background-color:#000; pointer-events:none; } .gallery-card[data-overlay="censored"] .deco-question-mark { position:absolute; bottom:5px; right:10px; font-size:24px; color:#444; opacity:0.5; pointer-events:none; }' WHERE sub_dim = 'overlay' AND value = 'censored';


-- ===== style_effect_options: animation + filter + transform =====
UPDATE style_effect_options SET css_template = '.gallery-card[data-anim="blink"] .overlay-seal,.gallery-card[data-anim="blink"] .overlay-stamp { animation:hardware-blink 1s infinite steps(2); } .gallery-card[data-anim="scanline_jitter"] .card-title { animation:scanline-jitter 0.5s infinite steps(2); }' WHERE sub_dim = 'animation' AND value != 'none';
UPDATE style_effect_options SET css_template = '@keyframes scanline-jitter { 0% { transform:translateY(0); } 100% { transform:translateY(2px); } } @keyframes hardware-blink { 0%,49% { background-color:var(--card-accent); color:var(--card-bg,#fff); } 50%,100% { background-color:transparent; color:var(--card-accent); } }' WHERE sub_dim = 'animation' AND value = 'blink';  -- keyframes 只需要一次，这里简化存一个
-- 实际上 keyframes 应该单独存或放在通用 CSS 里，这里先简化处理

UPDATE style_effect_options SET css_template = '.gallery-card[data-filter="blur"] { filter:blur(0.3px); }' WHERE sub_dim = 'filter' AND value = 'blur';

UPDATE style_effect_options SET css_template = '.gallery-card[data-transform="slight_tilt"] { transform:rotate(1deg); } .gallery-card[data-transform="mirror"] .card-title { transform:scaleX(-1); display:inline-block; } .gallery-card[data-transform="mirror"] .overlay-dump { transform:scaleY(-1); }' WHERE sub_dim = 'transform' AND value != 'none';


-- ===== 验证: 查看哪些记录还没有 css_template =====
-- SELECT 'layout' as tbl, sub_dim, value FROM style_layout_options WHERE css_template IS NULL OR css_template = ''
-- UNION ALL
-- SELECT 'typo', sub_dim, value FROM style_typo_options WHERE css_template IS NULL OR css_template = ''
-- UNION ALL
-- SELECT 'border', sub_dim, value FROM style_border_options WHERE css_template IS NULL OR css_template = ''
-- UNION ALL
-- SELECT 'deco', sub_dim, value FROM style_deco_options WHERE css_template IS NULL OR css_template = ''
-- ORDER BY tbl, sub_dim, value;
