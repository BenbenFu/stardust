// === STYLE ENGINE: data-属性驱动卡片渲染引擎 ===
// 替换 per-card CSS，全部用通用 CSS + data 属性驱动
// 用法: import { renderStyleJson, PALETTES, STYLE_PRESETS } from './style-engine.js'

// ============================================================
// 一、PALETTES — 17 组配色板
// ============================================================

export const PALETTES = {
    industrial:       { bg: 'transparent',      text: '#1e2622', accent: '#1e2622', muted: '#707a65', accentRgb: '30,38,34',   bgRgb: '0,0,0' },
    repair_yellow:    { bg: '#d2c89f',         text: '#403d30', accent: '#615a42', muted: '#837b5a', accentRgb: '97,90,66',    bgRgb: '210,200,159' },
    printer_green:    { bg: '#e5ebda',         text: '#1e2622', accent: '#8a8f7c', muted: '#8a8f7c', accentRgb: '138,143,124', bgRgb: '229,235,218' },
    bsod_blue:       { bg: '#1e2669',         text: '#cadbb7', accent: '#4a5d8f', muted: '#7f86ba', accentRgb: '74,93,143',   bgRgb: '30,38,105' },
    alert_red:        { bg: 'transparent',       text: '#8f341d', accent: '#8f341d', muted: '#8f341d', accentRgb: '143,52,29',   bgRgb: '0,0,0' },
    terminal_black:   { bg: '#0b0c0a',         text: '#707a65', accent: '#1e2622', muted: '#43473b', accentRgb: '30,38,34',   bgRgb: '11,12,10' },
    vscode_dark:     { bg: '#0f1419',         text: '#cadbb7', accent: '#3a7d44', muted: '#858585', accentRgb: '58,125,68',   bgRgb: '15,20,25' },
    archive_khaki:   { bg: '#f0f2eb',         text: '#1e2622', accent: '#8a8f7c', muted: '#5a6352', accentRgb: '138,143,124', bgRgb: '240,242,235' },
    github_light:     { bg: '#ffffff',         text: '#2d333b', accent: '#d1d9e0', muted: '#656d76', accentRgb: '209,217,224', bgRgb: '255,255,255' },
    diary_cream:     { bg: '#faf7e8',         text: '#4a453d', accent: '#c9c2b0', muted: '#9a9385', accentRgb: '201,194,176', bgRgb: '250,247,232' },
    twitter_light:    { bg: '#ffffff',         text: '#14171a', accent: '#e6ecf0', muted: '#657786', accentRgb: '230,236,240', bgRgb: '255,255,255' },
    notebook_white:   { bg: '#fffef5',         text: '#2c2c2c', accent: '#e0d9c8', muted: '#8a8273', accentRgb: '224,217,200', bgRgb: '255,254,245' },
    newspaper:        { bg: '#ffffff',         text: '#000000', accent: '#cccccc', muted: '#999999', accentRgb: '204,204,204', bgRgb: '255,255,255' },
    role_parchment:   { bg: '#f5f0e6',         text: '#3d3529', accent: '#8b7355', muted: '#6b5a45', accentRgb: '139,115,85',  bgRgb: '245,240,230' },
    novel_warm:      { bg: '#f8f5f0',         text: '#2a2520', accent: '#d4ccc4', muted: '#9a928a', accentRgb: '212,204,196', bgRgb: '248,245,240' },
    blueprint:        { bg: '#ffffff',         text: '#1e2622', accent: '#1e2622', muted: '#707a65', accentRgb: '30,38,34',   bgRgb: '255,255,255' },
    mystery_dark:     { bg: '#2a2a2a',         text: '#9a9a9a', accent: '#555555', muted: '#666666', accentRgb: '85,85,85',    bgRgb: '42,42,42' },
    warm:            { bg: '#f8f5f0',         text: '#2a2520', accent: '#d4ccc4', muted: '#9a928a', accentRgb: '212,204,196', bgRgb: '248,245,240' },  // alias for novel_warm
};

// ============================================================
// 二、SEPARATORS — 12 种句间分隔符
// ============================================================

export const SEPARATORS = {
    asterisk:      '*  *  *',
    dash:          '- - - -',
    dots:          '· · · · ·',
    dots_sparse:   '·  ·  ·',
    plus:          '+ + + + +',
    bang:          '! ! ! ! !',
    hex:           '0x0  0x0',
    code_comment:  '/* ---- */',
    tilde:         '~ ~ ~ ~ ~',
    triple_star:   '* * *',
    question:      '? ? ? ? ?',
    none:          '',
};

// ============================================================
// 三、CARD_ENGINE_CSS — 通用渲染 CSS（data-属性驱动）
// ============================================================

export const CARD_ENGINE_CSS = `
/* === 1. 基础卡片 === */
.gallery-card {
    margin-bottom: 20px;
    break-inside: avoid;
    padding: 10px;
    position: relative;
    display: flex;
    flex-direction: column;
    text-decoration: none;
    cursor: pointer;
    transition: transform 0.1s steps(2);
    background-color: var(--card-bg, transparent);
    color: var(--card-text, #1e2622);
    border-style: solid;
    border-color: var(--card-accent, #1e2622);
    border-width: 2px;
    border-radius: 0;
    box-shadow: none;
    transform: none;
    filter: none;
}
.gallery-card:hover {
    transform: translate(-2px, -2px) !important;
    box-shadow: 4px 4px 0 var(--card-accent, #1e2622);
}

/* === 2. 配色板（17 组）=== */
.gallery-card[data-palette="industrial"]       { --card-bg: transparent; --card-text: #1e2622; --card-accent: #1e2622; --card-muted: #707a65; --card-accent-rgb: 30,38,34; --card-bg-rgb: 0,0,0; }
.gallery-card[data-palette="repair_yellow"]    { --card-bg: #d2c89f; --card-text: #403d30; --card-accent: #615a42; --card-muted: #837b5a; --card-accent-rgb: 97,90,66; --card-bg-rgb: 210,200,159; }
.gallery-card[data-palette="printer_green"]    { --card-bg: #e5ebda; --card-text: #1e2622; --card-accent: #8a8f7c; --card-muted: #8a8f7c; --card-accent-rgb: 138,143,124; --card-bg-rgb: 229,235,218; }
.gallery-card[data-palette="bsod_blue"]       { --card-bg: #1e2669; --card-text: #cadbb7; --card-accent: #4a5d8f; --card-muted: #7f86ba; --card-accent-rgb: 74,93,143; --card-bg-rgb: 30,38,105; }
.gallery-card[data-palette="alert_red"]        { --card-bg: transparent; --card-text: #8f341d; --card-accent: #8f341d; --card-muted: #8f341d; --card-accent-rgb: 143,52,29; --card-bg-rgb: 0,0,0; }
.gallery-card[data-palette="terminal_black"]   { --card-bg: #0b0c0a; --card-text: #707a65; --card-accent: #1e2622; --card-muted: #43473b; --card-accent-rgb: 30,38,34; --card-bg-rgb: 11,12,10; }
.gallery-card[data-palette="vscode_dark"]     { --card-bg: #0f1419; --card-text: #cadbb7; --card-accent: #3a7d44; --card-muted: #858585; --card-accent-rgb: 58,125,68; --card-bg-rgb: 15,20,25; }
.gallery-card[data-palette="archive_khaki"]   { --card-bg: #f0f2eb; --card-text: #1e2622; --card-accent: #8a8f7c; --card-muted: #5a6352; --card-accent-rgb: 138,143,124; --card-bg-rgb: 240,242,235; }
.gallery-card[data-palette="github_light"]     { --card-bg: #ffffff; --card-text: #2d333b; --card-accent: #d1d9e0; --card-muted: #656d76; --card-accent-rgb: 209,217,224; --card-bg-rgb: 255,255,255; }
.gallery-card[data-palette="diary_cream"]     { --card-bg: #faf7e8; --card-text: #4a453d; --card-accent: #c9c2b0; --card-muted: #9a9385; --card-accent-rgb: 201,194,176; --card-bg-rgb: 250,247,232; }
.gallery-card[data-palette="twitter_light"]    { --card-bg: #ffffff; --card-text: #14171a; --card-accent: #e6ecf0; --card-muted: #657786; --card-accent-rgb: 230,236,240; --card-bg-rgb: 255,255,255; }
.gallery-card[data-palette="notebook_white"]   { --card-bg: #fffef5; --card-text: #2c2c2c; --card-accent: #e0d9c8; --card-muted: #8a8273; --card-accent-rgb: 224,217,200; --card-bg-rgb: 255,254,245; }
.gallery-card[data-palette="newspaper"]        { --card-bg: #ffffff; --card-text: #000000; --card-accent: #cccccc; --card-muted: #999999; --card-accent-rgb: 204,204,204; --card-bg-rgb: 255,255,255; }
.gallery-card[data-palette="role_parchment"]   { --card-bg: #f5f0e6; --card-text: #3d3529; --card-accent: #8b7355; --card-muted: #6b5a45; --card-accent-rgb: 139,115,85; --card-bg-rgb: 245,240,230; }
.gallery-card[data-palette="novel_warm"]      { --card-bg: #f8f5f0; --card-text: #2a2520; --card-accent: #d4ccc4; --card-muted: #9a928a; --card-accent-rgb: 212,204,196; --card-bg-rgb: 248,245,240; }
.gallery-card[data-palette="blueprint"]        { --card-bg: #ffffff; --card-text: #1e2622; --card-accent: #1e2622; --card-muted: #707a65; --card-accent-rgb: 30,38,34; --card-bg-rgb: 255,255,255; }
.gallery-card[data-palette="mystery_dark"]     { --card-bg: #2a2a2a; --card-text: #9a9a9a; --card-accent: #555555; --card-muted: #666666; --card-accent-rgb: 85,85,85; --card-bg-rgb: 42,42,42; }

/* === 3. layout.top（9 种）=== */

/* top: label */
.gallery-card[data-top="label"] .top-label {
    position: absolute; top: 5px; left: 50%;
    transform: translateX(-50%);
    font-size: 10px; letter-spacing: 1px;
    pointer-events: none; color: var(--card-accent);
}

/* top: status_bar */
.gallery-card[data-top="status_bar"] .top-status-bar {
    position: absolute; top: 0; left: 0; right: 0;
    background-color: var(--card-accent); color: var(--card-bg, #fff);
    padding: 2px 5px; font-size: 9px;
    display: flex; justify-content: space-between;
    animation: hardware-blink 2s infinite steps(2);
}

/* top: warning_bar */
.gallery-card[data-top="warning_bar"] .top-warning-bar {
    position: absolute; top: 0; left: 0; right: 0;
    background-color: var(--card-accent); color: #fff;
    padding: 3px 5px; font-size: 9px;
    display: flex; justify-content: space-between;
}

/* top: doc_header */
.gallery-card[data-top="doc_header"] .top-doc-header {
    position: absolute; top: 0; left: 0; right: 0;
    background-color: rgba(var(--card-accent-rgb), 0.12);
    padding: 3px 5px; font-size: 9px;
    display: flex; justify-content: space-between;
    border-bottom: 1px solid var(--card-accent);
}

/* top: email_header */
.gallery-card[data-top="email_header"] .top-email-header {
    background-color: rgba(var(--card-accent-rgb), 0.08);
    padding: 5px; margin: -10px -10px 10px -10px;
    border-bottom: 1px solid rgba(var(--card-accent-rgb), 0.4);
    font-size: 11px; display: flex; justify-content: space-between;
}
.gallery-card[data-top="email_header"] .email-from { font-weight: bold; color: var(--card-accent); }
.gallery-card[data-top="email_header"] .email-date { color: var(--card-muted); }

/* top: user_bar */
.gallery-card[data-top="user_bar"] .top-user-bar {
    display: flex; align-items: center; margin-bottom: 10px;
}
.gallery-card[data-top="user_bar"] .social-avatar {
    width: 32px; height: 32px; background-color: rgba(var(--card-accent-rgb), 0.5);
    border: 2px solid var(--card-text); margin-right: 10px; flex-shrink: 0;
}
.gallery-card[data-top="user_bar"] .user-info { flex: 1; min-width: 0; }
.gallery-card[data-top="user_bar"] .social-username { font-weight: bold; font-size: 12px; }
.gallery-card[data-top="user_bar"] .social-handle { font-size: 10px; color: var(--card-muted); }

/* top: dark_bar — 反色标题条 */
.gallery-card[data-top="dark_bar"] .card-title {
    background-color: var(--card-text); color: var(--card-bg, #fff);
    padding: 5px; margin: -10px -10px 10px -10px;
    text-align: center; font-size: 13px;
}

/* top: role_panel */
.gallery-card[data-top="role_panel"] .top-role-panel {
    display: flex; align-items: center; margin-bottom: 10px;
    padding-bottom: 10px; border-bottom: 2px solid var(--card-accent);
}
.gallery-card[data-top="role_panel"] .role-avatar {
    width: 56px; height: 56px; border: 2px solid var(--card-accent);
    margin-right: 12px; background-color: rgba(var(--card-accent-rgb), 0.25);
    flex-shrink: 0; position: relative;
}
.gallery-card[data-top="role_panel"] .role-avatar::after {
    content: "?"; position: absolute; top: 50%; left: 50%;
    transform: translate(-50%, -50%); font-size: 22px; color: var(--card-accent);
}
.gallery-card[data-top="role_panel"] .role-info { flex: 1; min-width: 0; }
.gallery-card[data-top="role_panel"] .role-name {
    font-size: 14px; font-weight: bold; letter-spacing: 1px;
}
.gallery-card[data-top="role_panel"] .role-date { font-size: 9px; color: var(--card-muted); }
.gallery-card[data-top="role_panel"] .role-stat {
    margin: 4px 0 0 0; font-size: 10px; color: var(--card-muted);
}
.gallery-card[data-top="role_panel"] .role-bar {
    height: 7px; background-color: rgba(var(--card-accent-rgb), 0.25);
    margin-top: 3px;
}
.gallery-card[data-top="role_panel"] .role-bar-fill {
    height: 100%; background-color: var(--card-accent);
}
.gallery-card[data-top="role_panel"] .role-inject {
    margin-top: 4px; font-size: 8px; color: var(--card-accent); text-align: right;
}

/* === 4. layout.body（5 种）=== */

/* body: standard — 默认，无需额外规则 */

/* body: code_area */
.gallery-card[data-body="code_area"] { padding-left: 40px; }
.gallery-card[data-body="code_area"] .card-title::before { content: "function "; color: #569cd6; }
.gallery-card[data-body="code_area"] .card-title::after { content: "() {"; color: #d4d4d4; }
.gallery-card[data-body="code_area"] .card-date::before { content: "// "; color: var(--card-muted); font-style: italic; }

/* body: ascii_zone */
.gallery-card[data-body="ascii_zone"] .body-ascii-art {
    color: var(--card-muted); font-size: 10px; line-height: 1;
    margin-bottom: 8px; white-space: pre; text-align: center;
}

/* body: sticky_note */
.gallery-card[data-body="sticky_note"] .card-title {
    background-color: #ffefb3; padding: 2px 8px;
    margin: -20px auto 15px auto; width: fit-content;
    box-shadow: 2px 2px 3px rgba(0,0,0,0.1);
}

/* === 5. layout.bottom（3 种）=== */

/* bottom: style_tag */
.gallery-card[data-bottom="style_tag"] .card-style {
    font-family: monospace; font-size: 9px; color: var(--card-muted);
    margin-top: 8px;
}

/* bottom: tag_bar */
.gallery-card[data-bottom="tag_bar"] .card-footer-h {
    display: flex; justify-content: space-between;
    margin-top: 8px; padding-top: 4px;
    border-top: 1px dashed var(--card-muted);
    font-size: 9px; color: var(--card-muted);
}

/* bottom: none — 无需额外规则 */

/* === 6. layout.side（3 种）=== */

/* side: line_numbers */
.gallery-card[data-side="line_numbers"] { padding-left: 40px; }
.gallery-card[data-side="line_numbers"] .side-line-numbers {
    position: absolute; left: 5px; top: 10px;
    font-size: 10px; color: rgba(var(--card-accent-rgb), 0.4);
    line-height: 1.5; text-align: right; width: 25px;
    pointer-events: none;
    border-right: 1px solid rgba(var(--card-accent-rgb), 0.3);
    padding-right: 5px;
}

/* side: holes */
.gallery-card[data-side="holes"] .side-holes {
    position: absolute; top: 0; bottom: 0; width: 6px;
    background-image: radial-gradient(var(--card-bg, #fff) 40%, transparent 42%);
    background-size: 6px 6px; pointer-events: none;
}
.gallery-card[data-side="holes"] .side-holes.left  { left: 0; }
.gallery-card[data-side="holes"] .side-holes.right { right: 0; }

/* === 7. layout.overlay（7 种）=== */

/* overlay: seal */
.gallery-card[data-overlay="seal"] .overlay-seal {
    position: absolute; top: 35px; right: 10px;
    font-size: 8px; border: 1px solid var(--card-muted);
    padding: 2px 4px; color: var(--card-muted);
    pointer-events: none;
}

/* overlay: stamp */
.gallery-card[data-overlay="stamp"] .overlay-stamp {
    position: absolute; top: 35%; right: 8%;
    border: 2px solid var(--card-accent); color: var(--card-accent);
    font-size: 12px; padding: 3px 5px; transform: rotate(-20deg);
    user-select: none; pointer-events: none;
    animation: hardware-blink 1s infinite steps(2);
}

/* overlay: tape — 斜纹胶带 */
.gallery-card[data-overlay="tape"] { padding-top: 25px; }
.gallery-card[data-overlay="tape"] .overlay-tape {
    position: absolute; top: 0; left: 0; right: 0;
    height: 20px;
    background: linear-gradient(135deg, var(--card-bg) 50%, rgba(var(--card-accent-rgb), 0.3) 50%);
    background-size: 15px 15px;
    pointer-events: none;
}
.gallery-card[data-overlay="tape"]::after {
    content: ""; position: absolute; bottom: 5px; right: 5px;
    width: 30px; height: 30px;
    background-image: radial-gradient(rgba(0,0,0,0.15) 30%, transparent 60%);
    pointer-events: none;
}

/* overlay: scanline */
.gallery-card[data-overlay="scanline"] .overlay-scanline {
    position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    background: linear-gradient(var(--card-accent) 1px, transparent 1px);
    background-size: 100% 2px;
    pointer-events: none; opacity: 0.15;
    animation: scanline-jitter 0.1s infinite steps(2);
}

/* overlay: dump */
.gallery-card[data-overlay="dump"] .overlay-dump {
    font-size: 11px; color: var(--card-bg, #fff);
    border: 1px solid var(--card-muted); padding: 5px;
    margin-top: 5px; text-align: right;
    font-family: monospace;
}

/* overlay: censored */
.gallery-card[data-overlay="censored"] .card-title {
    position: relative;
}
.gallery-card[data-overlay="censored"] .card-title::after {
    content: ""; position: absolute; top: 0; right: 0;
    width: 40%; height: 100%; background-color: #000;
    pointer-events: none;
}
.gallery-card[data-overlay="censored"] .deco-question-mark {
    position: absolute; bottom: 5px; right: 10px;
    font-size: 24px; color: #444; opacity: 0.5;
    pointer-events: none;
}

/* === 8. typo（4 family + 12 deco）=== */

/* family */
.gallery-card[data-font="mono"]    { --card-font: monospace; }
.gallery-card[data-font="consolas"] { --card-font: "Consolas", "Monaco", monospace; }
.gallery-card[data-font="serif"]    { --card-font: serif; }
.gallery-card[data-font="cursive"]  { --card-font: cursive; }
.gallery-card .card-title { font-family: var(--card-font, monospace); }

/* title_deco: border_bottom */
.gallery-card[data-title-deco="border_bottom"] .card-title {
    border-bottom: 1px solid var(--card-accent); padding-bottom: 4px;
}

/* title_deco: underline */
.gallery-card[data-title-deco="underline"] .card-title {
    text-decoration: underline;
}

/* title_deco: wavy_underline */
.gallery-card[data-title-deco="wavy_underline"] .card-title {
    text-decoration: underline; text-decoration-style: wavy;
    text-decoration-color: #8f341d;
}

/* title_deco: uppercase_center */
.gallery-card[data-title-deco="uppercase_center"] .card-title {
    text-transform: uppercase; text-align: center; letter-spacing: 2px;
}

/* title_deco: center_border_bottom */
.gallery-card[data-title-deco="center_border_bottom"] .card-title {
    text-align: center; border-bottom: 1px solid var(--card-accent); padding-bottom: 4px;
}

/* title_deco: center_bg_highlight */
.gallery-card[data-title-deco="center_bg_highlight"] .card-title {
    text-align: center; background-color: rgba(0,0,0,0.05); padding: 2px;
}

/* title_deco: function_prefix — 见 code_area */

/* title_deco: inverted_bar — 见 dark_bar */

/* title_deco: left_border */
.gallery-card[data-title-deco="left_border"] .card-title {
    padding-left: 8px; border-left: 3px solid var(--card-accent);
}

/* title_deco: mirror */
.gallery-card[data-title-deco="mirror"] .card-title {
    transform: scaleX(-1); display: inline-block;
}

/* title_deco: sticky_note — 见 sticky_note body */

/* === 9. border（10 style + 2 radius + 4 shadow）=== */

/* border.style */
.gallery-card[data-border="none"]       { border-width: 0 !important; }
.gallery-card[data-border="thin_solid"]  { border-width: 1px !important; border-style: solid; }
.gallery-card[data-border="solid"]       { border-width: 2px !important; border-style: solid; }
.gallery-card[data-border="thick_solid"] { border-width: 3px !important; border-style: solid; }
.gallery-card[data-border="heavy_solid"]  { border-width: 4px !important; border-style: solid; }
.gallery-card[data-border="double"]       { border-width: 3px !important; border-style: double; }
.gallery-card[data-border="dotted"]       { border-width: 2px !important; border-style: dotted; }
.gallery-card[data-border="dashed"]       { border-width: 1px !important; border-style: dashed; }
.gallery-card[data-border="left_accent"]  { border-width: 0 0 0 6px !important; border-left-style: solid; border-color: var(--card-accent); }
.gallery-card[data-border="solid_outline"] {
    border-width: 2px !important; border-style: solid;
    outline: 1px solid var(--card-accent); outline-offset: 0;
}

/* border.radius */
.gallery-card[data-radius="0"]  { border-radius: 0 !important; }
.gallery-card[data-radius="8"]  { border-radius: 8px !important; }

/* border.shadow */
.gallery-card[data-shadow="none"]       { box-shadow: none !important; }
.gallery-card[data-shadow="soft"]        { box-shadow: 2px 2px 8px rgba(0,0,0,0.2) !important; }
.gallery-card[data-shadow="inset"]       { box-shadow: inset 0 0 10px rgba(0,0,0,0.5) !important; }
.gallery-card[data-shadow="soft_small"]  { box-shadow: 0 2px 5px rgba(0,0,0,0.1) !important; }

/* === 10. deco（6 pattern + 12 separator + 3 label）=== */

/* bg_pattern */
.gallery-card[data-bg-pattern="tape_stripe"] {
    padding-top: 25px;
}
.gallery-card[data-bg-pattern="tape_stripe"]::before {
    content: ""; position: absolute; top: 0; left: 0; right: 0;
    height: 20px;
    background: linear-gradient(135deg, var(--card-bg) 50%, rgba(var(--card-accent-rgb), 0.3) 50%);
    background-size: 15px 15px; pointer-events: none;
}

.gallery-card[data-bg-pattern="perf_line"]::before {
    content: ""; position: absolute; top: 0; left: 6px; right: 6px;
    height: 3px;
    background: repeating-linear-gradient(90deg, var(--card-accent) 0px, var(--card-accent) 2px, transparent 2px, transparent 4px);
    pointer-events: none;
}

.gallery-card[data-bg-pattern="scanline"]::after {
    content: ""; position: absolute; top: 0; left: 0; right: 0; bottom: 0;
    background: linear-gradient(var(--card-accent) 1px, transparent 1px);
    background-size: 100% 2px;
    pointer-events: none; opacity: 0.15;
}

.gallery-card[data-bg-pattern="lines"] {
    background-image: linear-gradient(var(--card-accent) 1px, transparent 1px) !important;
    background-size: 100% 24px !important;
    background-position: 0 30px;
}

.gallery-card[data-bg-pattern="grid"] {
    background-image:
        linear-gradient(rgba(0,0,0,0.05) 1px, transparent 1px),
        linear-gradient(90deg, rgba(0,0,0,0.05) 1px, transparent 1px) !important;
    background-size: 20px 20px !important;
}

/* separator */
.gallery-card .hl-sep {
    display: block; text-align: center; margin: 5px 0;
    font-family: monospace; font-size: 10px;
    user-select: none; pointer-events: none; opacity: 0.3;
    color: var(--card-muted);
}

/* pseudo_label */
.gallery-card[data-pseudo-label="tamagotchi"]::before {
    content: "TAMAGOTCHI"; position: absolute; top: 5px; left: 50%;
    transform: translateX(-50%); font-size: 10px;
    color: var(--card-accent); letter-spacing: 1px; pointer-events: none;
}
.gallery-card[data-pseudo-label="question_mark"]::after {
    content: "?"; position: absolute; bottom: 5px; right: 10px;
    font-size: 24px; color: #444; opacity: 0.5; pointer-events: none;
}

/* === 11. effect（3 animation + 2 filter + 3 transform）=== */

/* animation */
.gallery-card[data-anim="blink"] .overlay-seal,
.gallery-card[data-anim="blink"] .overlay-stamp {
    animation: hardware-blink 1s infinite steps(2);
}
.gallery-card[data-anim="scanline_jitter"] .card-title {
    animation: scanline-jitter 0.5s infinite steps(2);
}

/* filter */
.gallery-card[data-filter="blur"] { filter: blur(0.3px); }

/* transform */
.gallery-card[data-transform="slight_tilt"] { transform: rotate(1deg); }
.gallery-card[data-transform="mirror"] .card-title { transform: scaleX(-1); display: inline-block; }
.gallery-card[data-transform="mirror"] .overlay-dump { transform: scaleY(-1); }

/* === 12. 动画 keyframes === */
@keyframes scanline-jitter {
    0%   { transform: translateY(0); }
    100% { transform: translateY(2px); }
}
@keyframes hardware-blink {
    0%, 49%   { background-color: var(--card-accent); color: var(--card-bg, #fff); }
    50%, 100%  { background-color: transparent; color: var(--card-accent); }
}

/* === 通用卡片子元素 === */
.gallery-card .card-title {
    font-size: 13px; font-weight: bold;
    margin: 0 0 8px 0; word-break: break-all;
}
.gallery-card .card-date {
    font-family: monospace; font-size: 10px; color: var(--card-muted);
}
.gallery-card .card-highlight-item {
    font-family: monospace; font-size: 12px; line-height: 1.5;
    margin: 0 0 3px 0; text-align: justify; word-break: break-all;
}
.gallery-card .card-highlight-item::before { content: "> "; color: var(--card-muted); }
.gallery-card .card-highlight-item:last-child { margin-bottom: 0; }
.gallery-card .card-no-highlight {
    font-family: monospace; font-size: 10px;
    color: var(--card-muted); font-style: italic; margin: 0;
}
.gallery-card .card-meta {
    font-size: 10px; color: var(--card-muted);
    border-bottom: 1px dashed var(--card-muted);
    padding-bottom: 4px; margin-bottom: 8px;
    display: flex; justify-content: space-between; flex-shrink: 0;
}
.gallery-card .card-style {
    font-family: monospace; font-size: 9px;
    color: var(--card-muted); margin-top: 8px;
}
.gallery-card .card-footer-h {
    display: flex; justify-content: space-between;
    margin-top: 8px; padding-top: 4px;
    font-size: 9px; color: var(--card-muted);
}
.ascii-art {
    color: var(--card-muted); font-size: 10px;
    line-height: 1; margin-bottom: 8px;
    white-space: pre; text-align: center;
}
`;

// ============================================================
// 四、STYLE_PRESETS — 18 种预设（完整 style_json）
// ============================================================

export const STYLE_PRESETS = {
    default: {
        layout:  { top: 'none',        body: 'standard',     bottom: 'style_tag', side: 'none',    overlay: 'none' },
        palette: 'industrial',
        typo:    { family: 'mono',     title_size: 13,      title_deco: 'border_bottom' },
        border:  { style: 'solid',     width: 2,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'asterisk',  pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    repair: {
        layout:  { top: 'none',        body: 'standard',     bottom: 'style_tag', side: 'none',    overlay: 'tape' },
        palette: 'repair_yellow',
        typo:    { family: 'cursive',   title_size: 14,      title_deco: 'underline' },
        border:  { style: 'solid',     width: 2,             radius: '0',        shadow: 'soft' },
        deco:    { bg_pattern: 'tape_stripe', separator: 'dash', pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'slight_tilt' },
    },
    print: {
        layout:  { top: 'none',        body: 'standard',     bottom: 'tag_bar',   side: 'holes',   overlay: 'none' },
        palette: 'printer_green',
        typo:    { family: 'mono',     title_size: 12,      title_deco: 'uppercase_center' },
        border:  { style: 'none',      width: 0,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'perf_line', separator: 'dots', pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    overheat: {
        layout:  { top: 'status_bar',  body: 'standard',     bottom: 'style_tag', side: 'none',    overlay: 'scanline' },
        palette: 'bsod_blue',
        typo:    { family: 'mono',     title_size: 13,      title_deco: 'none' },
        border:  { style: 'solid_outline', width: 2,          radius: '0',        shadow: 'inset' },
        deco:    { bg_pattern: 'scanline', separator: 'none', pseudo_label: 'none' },
        effect:  { animation: 'scanline_jitter', filter: 'none', transform: 'none' },
    },
    tamagotchi: {
        layout:  { top: 'label',       body: 'ascii_zone',   bottom: 'style_tag', side: 'none',    overlay: 'none' },
        palette: 'industrial',
        typo:    { family: 'mono',     title_size: 11,      title_deco: 'center_bg_highlight' },
        border:  { style: 'heavy_solid', width: 4,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'plus',     pseudo_label: 'tamagotchi' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'api-debt': {
        layout:  { top: 'warning_bar', body: 'standard',     bottom: 'style_tag', side: 'none',    overlay: 'stamp' },
        palette: 'alert_red',
        typo:    { family: 'mono',     title_size: 13,      title_deco: 'center' },
        border:  { style: 'solid',     width: 2,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'bang',    pseudo_label: 'none' },
        effect:  { animation: 'blink', filter: 'none',       transform: 'none' },
    },
    panic: {
        layout:  { top: 'none',        body: 'standard',     bottom: 'style_tag', side: 'none',    overlay: 'dump' },
        palette: 'terminal_black',
        typo:    { family: 'mono',     title_size: 13,      title_deco: 'mirror' },
        border:  { style: 'thin_solid', width: 1,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'hex',     pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'mirror' },
    },
    'code-forge': {
        layout:  { top: 'none',        body: 'code_area',    bottom: 'style_tag', side: 'line_numbers', overlay: 'none' },
        palette: 'vscode_dark',
        typo:    { family: 'consolas',  title_size: 13,      title_deco: 'function_prefix' },
        border:  { style: 'left_accent', width: 6,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'code_comment', pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'tech-archive': {
        layout:  { top: 'doc_header',  body: 'standard',     bottom: 'tag_bar',   side: 'none',    overlay: 'seal' },
        palette: 'archive_khaki',
        typo:    { family: 'mono',     title_size: 13,      title_deco: 'uppercase_center' },
        border:  { style: 'thin_solid', width: 1,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'none',    pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'work-bench': {
        layout:  { top: 'email_header', body: 'standard',     bottom: 'style_tag', side: 'none',    overlay: 'none' },
        palette: 'github_light',
        typo:    { family: 'mono',     title_size: 13,      title_deco: 'none' },
        border:  { style: 'thin_solid', width: 1,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'none',    pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'life-logbook': {
        layout:  { top: 'none',        body: 'sticky_note',  bottom: 'style_tag', side: 'none',    overlay: 'none' },
        palette: 'diary_cream',
        typo:    { family: 'cursive',   title_size: 13,      title_deco: 'sticky_note' },
        border:  { style: 'dotted',    width: 2,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'tilde',   pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'slight_tilt' },
    },
    'social-broadcast': {
        layout:  { top: 'user_bar',    body: 'standard',     bottom: 'style_tag', side: 'none',    overlay: 'none' },
        palette: 'twitter_light',
        typo:    { family: 'mono',     title_size: 13,      title_deco: 'none' },
        border:  { style: 'thin_solid', width: 1,             radius: '8',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'dots_sparse', pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'creative-engine': {
        layout:  { top: 'none',        body: 'standard',     bottom: 'style_tag', side: 'none',    overlay: 'none' },
        palette: 'notebook_white',
        typo:    { family: 'serif',     title_size: 14,      title_deco: 'wavy_underline' },
        border:  { style: 'solid',     width: 2,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'lines', separator: 'none',    pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'media-stream': {
        layout:  { top: 'none',        body: 'standard',     bottom: 'tag_bar',   side: 'none',    overlay: 'none' },
        palette: 'newspaper',
        typo:    { family: 'mono',     title_size: 15,      title_deco: 'center_border_bottom' },
        border:  { style: 'thin_solid', width: 1,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'none',    pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'role-engine': {
        layout:  { top: 'role_panel',  body: 'standard',     bottom: 'none',      side: 'none',    overlay: 'none' },
        palette: 'role_parchment',
        typo:    { family: 'mono',     title_size: 12,      title_deco: 'left_border' },
        border:  { style: 'double',    width: 3,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'none',    pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'fiction-realm': {
        layout:  { top: 'none',        body: 'standard',     bottom: 'tag_bar',   side: 'none',    overlay: 'none' },
        palette: 'novel_warm',
        typo:    { family: 'serif',     title_size: 16,      title_deco: 'center_border_bottom' },
        border:  { style: 'none',      width: 0,             radius: '0',        shadow: 'soft_small' },
        deco:    { bg_pattern: 'none', separator: 'triple_star', pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'format-deck': {
        layout:  { top: 'dark_bar',    body: 'standard',     bottom: 'tag_bar',   side: 'none',    overlay: 'none' },
        palette: 'blueprint',
        typo:    { family: 'mono',     title_size: 13,      title_deco: 'inverted_bar' },
        border:  { style: 'solid',     width: 2,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'grid', separator: 'none',    pseudo_label: 'none' },
        effect:  { animation: 'none',  filter: 'none',       transform: 'none' },
    },
    'misc-mystery': {
        layout:  { top: 'none',        body: 'standard',     bottom: 'style_tag', side: 'none',    overlay: 'censored' },
        palette: 'mystery_dark',
        typo:    { family: 'mono',     title_size: 13,      title_deco: 'none' },
        border:  { style: 'dashed',    width: 1,             radius: '0',        shadow: 'none' },
        deco:    { bg_pattern: 'none', separator: 'question', pseudo_label: 'question_mark' },
        effect:  { animation: 'none',  filter: 'blur',       transform: 'none' },
    },
};

// ============================================================
// 五、ASCII 宠物池
// ============================================================

const asciiPets = [
    ' /\\_/\\\n( o.o )\n > ^ <\n',
    '  ___\n (>.<)\n (___)\n',
    ' /\\_/\\\n( -.- )\n(\")(\")\n',
    '  __\n (--)\n/(  )\\\n',
];

// ============================================================
// 六、工具函数
// ============================================================

function numericId(id) {
    if (typeof id === 'number') return id;
    if (typeof id === 'string') {
        let hash = 0;
        for (let i = 0; i < id.length; i++) {
            hash = ((hash << 5) - hash) + id.charCodeAt(i);
            hash |= 0;
        }
        return Math.abs(hash);
    }
    return 0;
}

function escapeHtml(str) {
    if (typeof window !== 'undefined' && window.document) {
        const div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }
    return String(str)
        .replace(/&/g, '&amp;')
        .replace(/[<]/g, '&lt;')
        .replace(/[>]/g, '&gt;')
        .replace(/"/g, '&quot;');
}

// ============================================================
// 七、renderStyleJson() — 主渲染函数
// 输入: styleJson (Object) + diary (Object: { id, title, date, dateRaw, highlights, capsuleName })
// 输出: 完整 <a class="gallery-card">...</a> HTML 字符串
// ============================================================

export function renderStyleJson(styleJson, diary) {
    const sj = styleJson || STYLE_PRESETS['default'];
    const d = diary || {};
    const nid = numericId(d.id);
    const highlights = d.highlights || [];
    const dateRaw = d.dateRaw || d.date || '';
    const dateDisplay = d.date || '----/--/--';
    const styleName = d.capsuleName || '';
    const sep = (sj.deco && SEPARATORS[sj.deco.separator]) || '';

    // 构建 data-* 属性字符串
    const p = sj.palette || 'industrial';
    const l = sj.layout || {};
    const ty = sj.typo || {};
    const bo = sj.border || {};
    const dc = sj.deco || {};
    const ef = sj.effect || {};

    let attrs = '';
    attrs += ` data-palette="${p}"`;
    attrs += ` data-top="${l.top || 'none'}"`;
    attrs += ` data-body="${l.body || 'standard'}"`;
    attrs += ` data-bottom="${l.bottom || 'style_tag'}"`;
    attrs += ` data-side="${l.side || 'none'}"`;
    attrs += ` data-overlay="${l.overlay || 'none'}"`;
    attrs += ` data-font="${ty.family || 'mono'}"`;
    attrs += ` data-title-deco="${ty.title_deco || 'none'}"`;
    attrs += ` data-border="${bo.style || 'solid'}"`;
    attrs += ` data-radius="${bo.radius || '0'}"`;
    attrs += ` data-shadow="${bo.shadow || 'none'}"`;
    attrs += ` data-bg-pattern="${dc.bg_pattern || 'none'}"`;
    attrs += ` data-pseudo-label="${dc.pseudo_label || 'none'}"`;
    attrs += ` data-anim="${ef.animation || 'none'}"`;
    attrs += ` data-filter="${ef.filter || 'none'}"`;
    attrs += ` data-transform="${ef.transform || 'none'}"`;

    let html = `<a class="gallery-card"${attrs} href="diary.html?date=${dateRaw}" target="_blank" title="${escapeHtml(d.title || '')}" data-id="${d.id || ''}" data-title="${escapeHtml(d.title || '')}" data-date="${d.date || ''}" data-date-raw="${dateRaw}" data-highlights="${escapeHtml(JSON.stringify(highlights))}">`;

    // --- 侧边元素（side）---
    if (l.side === 'line_numbers') {
        let nums = '';
        for (let i = 1; i <= 12; i++) nums += i + '\n';
        html += `<div class="side-line-numbers">${nums.trim()}</div>`;
    }
    if (l.side === 'holes') {
        html += '<div class="side-holes left"></div><div class="side-holes right"></div>';
    }

    // --- 顶部组件（top）---
    switch (l.top) {
        case 'label':
            html += `<div class="top-label">TAMAGOTCHI</div>`;
            break;
        case 'status_bar':
            html += `<div class="top-status-bar"><span>WARNING: OVERHEAT</span><span>${escapeHtml(styleName)}</span></div>`;
            break;
        case 'warning_bar':
            html += `<div class="top-warning-bar"><span>API DEBT</span><span>${escapeHtml(styleName)}</span></div>`;
            break;
        case 'doc_header':
            html += `<div class="top-doc-header"><span>RFC-${d.id || '----'}</span><span>STARDUST-SPEC</span></div>`;
            html += '<div class="overlay-seal">APPROVED</div>';
            break;
        case 'email_header':
            html += `<div class="top-email-header"><span class="email-from">stardust@unit01.internal</span><span class="email-date">${dateDisplay} · ${escapeHtml(styleName)}</span></div>`;
            break;
        case 'user_bar':
            html += `<div class="top-user-bar"><div class="social-avatar"></div><div class="user-info"><div class="social-username">星尘单元01</div><div class="social-handle">@stardust_unit01 · ${escapeHtml(styleName)}</div></div></div>`;
            break;
        case 'dark_bar':
            // 标题在 CSS 中处理（反色条）
            break;
        case 'role_panel': {
            const injectLabels = ['人格注入', '相似度', '文风匹配', '灵魂复现', '意识同步'];
            const label = injectLabels[nid % injectLabels.length];
            const pct = 30 + (nid % 71);
            html += `<div class="top-role-panel"><div class="role-avatar"></div><div class="role-info">`;
            html += `<div class="role-name">${escapeHtml(styleName)}</div>`;
            html += `<div class="role-date">${dateDisplay}</div>`;
            html += `<div class="role-stat">${label}<div class="role-bar"><div class="role-bar-fill" style="width:${pct}%"></div></div></div>`;
            html += `<div class="role-inject">${pct}% · #${nid % 10000}号实验体</div></div></div>`;
            break;
        }
        default:
            break;
    }

    // --- 覆盖层（overlay，absolute 定位）---
    switch (l.overlay) {
        case 'seal':
            // 已在 doc_header 中处理
            break;
        case 'stamp':
            html += '<div class="overlay-stamp">[!] API_DEBT</div>';
            break;
        case 'tape':
            html += '<div class="overlay-tape"></div>';
            break;
        case 'scanline':
            html += '<div class="overlay-scanline"></div>';
            break;
        case 'dump':
            html += `<div class="overlay-dump">EIP: 0x${nid.toString(16).toUpperCase().padStart(8, '0')}<br>EBX: 0xDEADBEEF<br>KERNEL_PANIC: DUMPING...</div>`;
            break;
        case 'censored':
            html += '<div class="deco-question-mark">?</div>';
            break;
        default:
            break;
    }

    // --- 主体内容（body）---
    switch (l.body) {
        case 'ascii_zone': {
            const pet = asciiPets[nid % asciiPets.length];
            html += `<div class="card-title">${escapeHtml(d.title || '')}</div>`;
            html += `<div class="card-date">${dateDisplay}</div>`;
            html += `<div class="body-ascii-art">${escapeHtml(pet)}</div>`;
            break;
        }
        case 'code_area':
            html += `<div class="card-title">${escapeHtml(d.title || '')}</div>`;
            html += `<div class="card-date">${dateDisplay}</div>`;
            break;
        case 'sticky_note':
            // title 样式由 CSS title_deco: sticky_note 处理
            html += `<div class="card-title">${escapeHtml(d.title || '')}</div>`;
            html += `<div class="card-date">${dateDisplay}</div>`;
            break;
        default: // standard
            // role_panel 时标题带 left_border，不重复日期
            if (l.top !== 'role_panel') {
                html += `<div class="card-title">${escapeHtml(d.title || '')}</div>`;
                html += `<div class="card-date">${dateDisplay}</div>`;
            } else {
                html += `<div class="card-title">${escapeHtml(d.title || '')}</div>`;
            }
            break;
    }

    // --- 特有装饰（高亮前）---
    if (l.body === 'ascii_zone') {
        // 已在上面处理
    }
    if (l.overlay === 'stamp') {
        // 已在上面处理
    }

    // --- 精华句 + 分隔符 ---
    if (highlights.length > 0) {
        highlights.forEach((h, i) => {
            if (i > 0 && sep) {
                html += `<div class="hl-sep">${escapeHtml(sep)}</div>`;
            }
            html += `<p class="card-highlight-item">${escapeHtml(h)}</p>`;
        });
    } else {
        html += '<p class="card-no-highlight">[ NO_HIGHLIGHTS ]</p>';
    }

    // --- 特有装饰（高亮后）---
    if (sj.palette === 'terminal_black' && l.overlay === 'dump') {
        // panic: dump 已在 overlay 中
    }

    // --- 底部标签（bottom）---
    switch (l.bottom) {
        case 'style_tag':
            if (l.top !== 'role_panel') {
                html += `<div class="card-style">${escapeHtml(styleName)}</div>`;
            }
            break;
        case 'tag_bar':
            html += `<div class="card-footer-h"><span>${dateDisplay}</span><span>${escapeHtml(styleName)}</span></div>`;
            break;
        case 'none':
            // 无底部标签
            break;
        default:
            break;
    }

    html += '</a>';
    return html;
}

// ============================================================
// 八、validateStyleJson() — 校验函数
// 返回: { valid: boolean, errors: string[], warnings: string[] }
// ============================================================

const ENUM_LAYOUT_TOP    = ['none', 'label', 'status_bar', 'warning_bar', 'doc_header', 'email_header', 'user_bar', 'dark_bar', 'role_panel'];
const ENUM_LAYOUT_BODY   = ['standard', 'code_area', 'ascii_zone', 'sticky_note', 'role_panel_body'];
const ENUM_LAYOUT_BOTTOM = ['style_tag', 'tag_bar', 'none'];
const ENUM_LAYOUT_SIDE   = ['none', 'line_numbers', 'holes'];
const ENUM_LAYOUT_OVERLAY= ['none', 'seal', 'stamp', 'tape', 'scanline', 'dump', 'censored'];
const ENUM_PALETTE       = Object.keys(PALETTES);
const ENUM_TYPO_FAMILY   = ['mono', 'consolas', 'serif', 'cursive'];
const ENUM_TYPO_DECO     = ['none', 'border_bottom', 'underline', 'wavy_underline', 'uppercase_center', 'center_border_bottom', 'center_bg_highlight', 'function_prefix', 'inverted_bar', 'left_border', 'mirror', 'sticky_note'];
const ENUM_BORDER_STYLE  = ['none', 'thin_solid', 'solid', 'thick_solid', 'heavy_solid', 'double', 'dotted', 'dashed', 'left_accent', 'solid_outline'];
const ENUM_BORDER_RADIUS = ['0', '8'];
const ENUM_BORDER_SHADOW = ['none', 'soft', 'inset', 'soft_small'];
const ENUM_DECO_PATTERN  = ['none', 'tape_stripe', 'perf_line', 'scanline', 'lines', 'grid'];
const ENUM_DECO_SEP      = ['asterisk', 'dash', 'dots', 'dots_sparse', 'plus', 'bang', 'hex', 'code_comment', 'tilde', 'triple_star', 'question', 'none'];
const ENUM_DECO_LABEL    = ['none', 'tamagotchi', 'question_mark'];
const ENUM_EFFECT_ANIM   = ['none', 'blink', 'scanline_jitter'];
const ENUM_EFFECT_FILTER  = ['none', 'blur'];
const ENUM_EFFECT_TRANS   = ['none', 'slight_tilt', 'mirror'];

function _inList(val, list) {
    return list.includes(val);
}

export function validateStyleJson(styleJson) {
    const errors = [];
    const warnings = [];
    if (!styleJson || typeof styleJson !== 'object') {
        errors.push('styleJson 必须是对象');
        return { valid: false, errors, warnings };
    }

    const l = styleJson.layout || {};
    const ty = styleJson.typo || {};
    const bo = styleJson.border || {};
    const dc = styleJson.deco || {};
    const ef = styleJson.effect || {};

    // 枚举值合法性
    if (!_inList(l.top, ENUM_LAYOUT_TOP))     errors.push(`layout.top 值非法: ${l.top}`);
    if (!_inList(l.body, ENUM_LAYOUT_BODY))    errors.push(`layout.body 值非法: ${l.body}`);
    if (!_inList(l.bottom, ENUM_LAYOUT_BOTTOM)) errors.push(`layout.bottom 值非法: ${l.bottom}`);
    if (!_inList(l.side, ENUM_LAYOUT_SIDE))    errors.push(`layout.side 值非法: ${l.side}`);
    if (!_inList(l.overlay, ENUM_LAYOUT_OVERLAY)) errors.push(`layout.overlay 值非法: ${l.overlay}`);
    if (!_inList(styleJson.palette, ENUM_PALETTE)) errors.push(`palette 值非法: ${styleJson.palette}`);
    if (!_inList(ty.family, ENUM_TYPO_FAMILY)) errors.push(`typo.family 值非法: ${ty.family}`);
    if (!_inList(ty.title_deco, ENUM_TYPO_DECO)) errors.push(`typo.title_deco 值非法: ${ty.title_deco}`);
    if (!_inList(bo.style, ENUM_BORDER_STYLE)) errors.push(`border.style 值非法: ${bo.style}`);
    if (!_inList(bo.radius, ENUM_BORDER_RADIUS)) errors.push(`border.radius 值非法: ${bo.radius}`);
    if (!_inList(bo.shadow, ENUM_BORDER_SHADOW)) errors.push(`border.shadow 值非法: ${bo.shadow}`);
    if (!_inList(dc.bg_pattern, ENUM_DECO_PATTERN)) errors.push(`deco.bg_pattern 值非法: ${dc.bg_pattern}`);
    if (!_inList(dc.separator, ENUM_DECO_SEP)) errors.push(`deco.separator 值非法: ${dc.separator}`);
    if (!_inList(dc.pseudo_label, ENUM_DECO_LABEL)) errors.push(`deco.pseudo_label 值非法: ${dc.pseudo_label}`);
    if (!_inList(ef.animation, ENUM_EFFECT_ANIM)) errors.push(`effect.animation 值非法: ${ef.animation}`);
    if (!_inList(ef.filter, ENUM_EFFECT_FILTER)) errors.push(`effect.filter 值非法: ${ef.filter}`);
    if (!_inList(ef.transform, ENUM_EFFECT_TRANS)) errors.push(`effect.transform 值非法: ${ef.transform}`);

    // 强依赖
    if (l.side === 'line_numbers' && l.body !== 'code_area') {
        errors.push('side=line_numbers 时 body 必须为 code_area');
    }
    if (l.side === 'holes' && l.bottom !== 'tag_bar') {
        errors.push('side=holes 时 bottom 必须为 tag_bar');
    }
    if (l.top === 'role_panel' && l.bottom !== 'none') {
        errors.push('top=role_panel 时 bottom 必须为 none');
    }
    if (l.overlay === 'scanline' && ef.animation === 'none') {
        errors.push('overlay=scanline 时 animation 不能为 none');
    }

    // 弱建议
    if (styleJson.palette === 'vscode_dark' && ty.family !== 'consolas') {
        warnings.push('palette=vscode_dark 建议 typo.family 使用 consolas');
    }
    if (styleJson.palette === 'industrial' && bo.style !== 'solid') {
        warnings.push('palette=industrial 建议 border.style 使用 solid');
    }

    return { valid: errors.length === 0, errors, warnings };
}

// ============================================================
// 九、registerPalette() — 动态注册自定义色板
// ============================================================

export function registerPalette(name, colors) {
    // colors = { bg, text, accent, muted, accentRgb, bgRgb }
    if (PALETTES[name]) return;

    // 自动计算 RGB 通道（hex → "r,g,b"）
    if (!colors.accentRgb && colors.accent && colors.accent.startsWith('#') && colors.accent.length >= 7) {
        const r = parseInt(colors.accent.slice(1, 3), 16);
        const g = parseInt(colors.accent.slice(3, 5), 16);
        const b = parseInt(colors.accent.slice(5, 7), 16);
        colors.accentRgb = `${r},${g},${b}`;
    }
    if (!colors.bgRgb && colors.bg && colors.bg.startsWith('#') && colors.bg.length >= 7) {
        const r = parseInt(colors.bg.slice(1, 3), 16);
        const g = parseInt(colors.bg.slice(3, 5), 16);
        const b = parseInt(colors.bg.slice(5, 7), 16);
        colors.bgRgb = `${r},${g},${b}`;
    }
    // 兜底
    if (!colors.accentRgb) colors.accentRgb = '0,0,0';
    if (!colors.bgRgb) colors.bgRgb = '255,255,255';

    PALETTES[name] = colors;

    if (typeof document === 'undefined') return;

    const rule = `.gallery-card[data-palette="${name}"] { --card-bg:${colors.bg}; --card-text:${colors.text}; --card-accent:${colors.accent}; --card-muted:${colors.muted}; --card-accent-rgb: ${colors.accentRgb}; --card-bg-rgb: ${colors.bgRgb}; }`;
    let styleEl = document.getElementById('card-engine-dynamic-palettes');
    if (!styleEl) {
        styleEl = document.createElement('style');
        styleEl.id = 'card-engine-dynamic-palettes';
        document.head.appendChild(styleEl);
    }
    styleEl.textContent += '\n' + rule;
}

// ============================================================
// 十、injectCardEngineCss() — 将 CARD_ENGINE_CSS 注入文档
// ============================================================

export function injectCardEngineCss() {
    if (typeof document === 'undefined') return;
    if (document.getElementById('card-engine-css')) return;
    const styleEl = document.createElement('style');
    styleEl.id = 'card-engine-css';
    styleEl.textContent = CARD_ENGINE_CSS;
    document.head.appendChild(styleEl);
}
