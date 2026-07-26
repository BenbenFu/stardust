-- ============================================================
-- 剥离 element 模板里的"14 槽复合层"(background-image/size/position/repeat)
-- 唯一权威复合层改由引擎 BASE_CSS 注入（见 web/style-engine.js v=20260725b）。
-- 此后每个模板只声明自己的 --el-* 变量，多装饰同卡时各自填槽、永不争抢 background-image。
-- 幂等：重跑无害。执行后硬刷新预览页（Ctrl+Shift+R）。
-- ============================================================

-- id=23  bg_pattern  dot_grid
update style_element_options set css_template = '.gallery-card[data-style-element-bg="dot_grid"] {
  --el-bg-1: radial-gradient(circle, var(--card-muted, #ccc) 1px, transparent 1.6px);
  --el-bg-size-1: 16px 16px;
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;
}' where id = 23;

-- id=27  bg_pattern  terminal_scanlines
update style_element_options set css_template = '.gallery-card[data-style-element-bg="terminal_scanlines"] {
  --el-bg-1: repeating-linear-gradient(to bottom, transparent, transparent 2px, rgba(0,0,0,0.06) 2px, rgba(0,0,0,0.06) 4px);
  --el-bg-size-1: 100% 4px;
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;
}' where id = 27;

-- id=18  corner_badge  circle_stamp
update style_element_options set css_template = '.gallery-card[data-style-element-corner="circle_stamp"] {
  --el-corner-1: radial-gradient(circle, var(--card-accent, #888) 50%, transparent 52%);
  --el-corner-size-1: 14px 14px;
  --el-corner-pos-1: var(--el-corner-anchor-pos, top 6px right 6px);
  --el-corner-rep-1: no-repeat;
}' where id = 18;

-- id=24  bg_pattern  fine_grid
update style_element_options set css_template = '.gallery-card[data-style-element-bg="fine_grid"] {
  --bg-grid-line: color-mix(in srgb, var(--card-muted, #ccc) 14%, transparent);
  --el-bg-1: linear-gradient(var(--bg-grid-line) 1px, transparent 1px);
  --el-bg-2: linear-gradient(90deg, var(--bg-grid-line) 1px, transparent 1px);
  --el-bg-size-1: 20px 20px; --el-bg-size-2: 20px 20px;
  --el-bg-pos-1: 0 0; --el-bg-pos-2: 0 0;
  --el-bg-rep-1: repeat; --el-bg-rep-2: repeat;
}' where id = 24;

-- id=25  bg_pattern  horizontal_lines
update style_element_options set css_template = '.gallery-card[data-style-element-bg="horizontal_lines"] {
  --el-bg-1: repeating-linear-gradient(to bottom, transparent, transparent calc(1.5em - 1px), var(--card-muted, #ccc) calc(1.5em - 1px), var(--card-muted, #ccc) 1.5em);
  --el-bg-size-1: 100% 1.5em;
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;
}' where id = 25;

-- id=30  edge_deco  bracket_frame
update style_element_options set css_template = '.gallery-card[data-style-element-edge="bracket_frame"] {
  --el-edge-1: linear-gradient(var(--card-accent, #888), var(--card-accent, #888));
  --el-edge-2: linear-gradient(var(--card-accent, #888), var(--card-accent, #888));
  --el-edge-3: linear-gradient(var(--card-accent, #888), var(--card-accent, #888));
  --el-edge-4: linear-gradient(var(--card-accent, #888), var(--card-accent, #888));
  --el-edge-size-1: 12px 2px; --el-edge-size-2: 2px 12px; --el-edge-size-3: 12px 2px; --el-edge-size-4: 2px 12px;
  --el-edge-pos-1: 6px 6px; --el-edge-pos-2: 6px 6px; --el-edge-pos-3: bottom 6px right 6px; --el-edge-pos-4: bottom 6px right 6px;
  --el-edge-rep-1: no-repeat; --el-edge-rep-2: no-repeat; --el-edge-rep-3: no-repeat; --el-edge-rep-4: no-repeat;
}' where id = 30;

-- id=32  edge_deco  tape_stripe
update style_element_options set css_template = '.gallery-card[data-style-element-edge="tape_stripe"] {
  --el-edge-1: repeating-linear-gradient(45deg, transparent, transparent 8px, color-mix(in srgb, var(--card-muted, #ccc) 28%, transparent) 8px, color-mix(in srgb, var(--card-muted, #ccc) 28%, transparent) 10px);
  --el-edge-size-1: auto;
  --el-edge-pos-1: 0 0;
  --el-edge-rep-1: repeat;
}' where id = 32;

-- id=21  corner_badge  dot_status
update style_element_options set css_template = '.gallery-card[data-style-element-corner="dot_status"] {
  --el-corner-1: radial-gradient(circle, var(--card-bg, #fff) 0 3px, var(--card-accent, #888) 3px 5px, transparent 5px);
  --el-corner-size-1: 11px 11px;
  --el-corner-pos-1: var(--el-corner-anchor-pos, top 6px right 6px);
  --el-corner-rep-1: no-repeat;
}' where id = 21;

-- id=26  bg_pattern  gradient_overlay
update style_element_options set css_template = '.gallery-card[data-style-element-bg="gradient_overlay"] {
  --el-bg-1: linear-gradient(to bottom, transparent 55%, color-mix(in srgb, var(--card-bg, #fff) 65%, var(--card-muted, #ccc) 35%) 100%);
  --el-bg-size-1: 100% 100%;
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: no-repeat;
}' where id = 26;

-- id=19  corner_badge  page_fold
update style_element_options set css_template = '.gallery-card[data-style-element-corner="page_fold"] {
  --pf-angle: 225deg;
  --el-corner-1: linear-gradient(var(--pf-angle), var(--card-muted, #ccc) 0 18px, transparent 18px);
  --el-corner-size-1: 18px 18px;
  --el-corner-pos-1: top right;
  --el-corner-rep-1: no-repeat;
  --el-corner-2: linear-gradient(var(--pf-angle), transparent 0 16px, var(--card-text, #222) 16px 18px, transparent 18px);
  --el-corner-size-2: 18px 18px;
  --el-corner-pos-2: top right;
  --el-corner-rep-2: no-repeat;
}

.gallery-card[data-style-element-corner="page_fold"][data-style-element-corner-anchor="top-left"] {
  --pf-angle: 135deg; --el-corner-pos-1: top left; --el-corner-pos-2: top left;
}
.gallery-card[data-style-element-corner="page_fold"][data-style-element-corner-anchor="bottom-left"] {
  --pf-angle: 45deg; --el-corner-pos-1: bottom left; --el-corner-pos-2: bottom left;
}
.gallery-card[data-style-element-corner="page_fold"][data-style-element-corner-anchor="bottom-right"] {
  --pf-angle: 315deg; --el-corner-pos-1: bottom right; --el-corner-pos-2: bottom right;
}' where id = 19;

-- id=35  floating_deco  scatter_dots
update style_element_options set css_template = '.gallery-card[data-style-element-float="scatter_dots"] {
  --el-float-1: radial-gradient(circle, var(--card-accent, #888) 1.2px, transparent 1.6px);
  --el-float-size-1: 46px 46px;
  --el-float-pos-1: var(--el-float-anchor-pos, top 4px right 6px);
  --el-float-rep-1: repeat;
  --el-float-2: radial-gradient(circle, var(--card-accent, #888) 1px, transparent 1.4px);
  --el-float-size-2: 70px 70px;
  --el-float-pos-2: var(--el-float-anchor-pos, top 30px left 10px);
  --el-float-rep-2: repeat;
}' where id = 35;

-- id=48  bg_pattern  starfield
update style_element_options set css_template = '.gallery-card[data-style-element-bg="starfield"]{
  --el-bg-1:radial-gradient(2px 2px at 12% 18%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 78% 12%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 42% 38%,var(--card-text) 50%,transparent 100%),radial-gradient(2px 2px at 90% 28%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 22% 55%,var(--card-text) 50%,transparent 100%),radial-gradient(2px 2px at 58% 72%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 6% 82%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 95% 65%,var(--card-text) 50%,transparent 100%),radial-gradient(2px 2px at 35% 90%,var(--card-text) 50%,transparent 100%);
  --el-bg-size-1:211px 173px;--el-bg-pos-1:0 0;--el-bg-rep-1:repeat;
  --el-bg-2:radial-gradient(1.2px 1.2px at 25% 8%,var(--card-text) 50%,transparent 100%),radial-gradient(1px 1px at 63% 30%,var(--card-text) 50%,transparent 100%),radial-gradient(1.2px 1.2px at 88% 48%,var(--card-text) 50%,transparent 100%),radial-gradient(1px 1px at 15% 60%,var(--card-text) 50%,transparent 100%),radial-gradient(1.2px 1.2px at 48% 78%,var(--card-text) 50%,transparent 100%),radial-gradient(1px 1px at 72% 92%,var(--card-text) 50%,transparent 100%),radial-gradient(1.2px 1.2px at 5% 35%,var(--card-text) 50%,transparent 100%);
  --el-bg-size-2:167px 199px;--el-bg-pos-2:47px 23px;--el-bg-rep-2:repeat;
  --el-bg-3:radial-gradient(.8px .8px at 40% 15%,var(--card-text) 50%,transparent 100%),radial-gradient(.6px .6px at 82% 40%,var(--card-text) 50%,transparent 100%),radial-gradient(.8px .8px at 18% 70%,var(--card-text) 50%,transparent 100%),radial-gradient(.6px .6px at 55% 85%,var(--card-text) 50%,transparent 100%),radial-gradient(.8px .8px at 92% 10%,var(--card-text) 50%,transparent 100%),radial-gradient(.4px .4px at 8% 25%,var(--card-text) 50%,transparent 100%),radial-gradient(.3px .3px at 52% 5%,var(--card-text) 50%,transparent 100%),radial-gradient(.4px .4px at 75% 55%,var(--card-text) 50%,transparent 100%),radial-gradient(.3px .3px at 28% 82%,var(--card-text) 50%,transparent 100%);
  --el-bg-size-3:137px 151px;--el-bg-pos-3:71px 59px;--el-bg-rep-3:repeat;
  --el-bg-4:radial-gradient(.5px .5px at 30% 50%,var(--card-text) 50%,transparent 100%),radial-gradient(.4px .4px at 70% 20%,var(--card-text) 50%,transparent 100%),radial-gradient(.5px .5px at 50% 80%,var(--card-text) 50%,transparent 100%),radial-gradient(ellipse 200px 120px at 18% 78%,color-mix(in srgb,var(--card-muted) 5%,transparent) 0%,transparent 50%),radial-gradient(ellipse 160px 90px at 82% 22%,color-mix(in srgb,var(--card-muted) 4%,transparent) 0%,transparent 50%);
  --el-bg-size-4:100% 100%;--el-bg-pos-4:0 0;--el-bg-rep-4:no-repeat;
}' where id = 48;

-- floating_circle 默认修正：直径 90px / 38% / 卡内锚点（避免过大覆盖整卡）
update style_element_options set css_template = '.gallery-card[data-style-element-float="floating_circle"] {
  --el-float-1: radial-gradient(circle, color-mix(in srgb, var(--card-accent, #888) 38%, transparent) 0 44px, transparent 46px);
  --el-float-size-1: 90px 90px;
  --el-float-pos-1: var(--el-float-anchor-pos, bottom 10px right 10px);
  --el-float-rep-1: no-repeat;
}' where id = 34;
