/**
 * style-engine.js — v2.0 DB驱动渲染器
 *
 * 九张表驱动架构：palette/layout/typo/border/deco/element/effect/container_group
 * 完全由 DB 选项表中的 css_template 驱动样式，零硬编码
 *
 * 对外接口：
 *   renderStyleJson(styleJson, diary, allOptions) → HTML string
 *   injectBaseCss() → 注入最小化基础样式
 *   injectDynamicStyles(allOptions) → 注入 DB css_template
 *   DEFAULT_STYLE_JSON → 全默认 style_json
 */

// ============================================================
// Section 1: BASE_CSS — 最小化基础结构样式
// 所有视觉效果由 DB css_template 的 data-attr 选择器提供
// ============================================================

const BASE_CSS = `/* style-engine v2.2 — band-based card layout */
.gallery-card {
  display: flex; flex-direction: column; position: relative; overflow: hidden;
  padding: 0;
  break-inside: avoid; margin-bottom: var(--spacing-md, 16px);
  cursor: pointer; text-decoration: none;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  background: var(--card-bg, transparent);
  color: var(--card-text, inherit);
  border-width: var(--border-width, 0);
  border-style: var(--border-style, none);
  border-color: var(--card-accent, transparent);
}
/* 内容包裹层：slot skeleton 或 container-group 都放在这里。
   四边统一 = --density-pad（DB 密度模板提供，缺省 12px）：
   · 无色条卡片：作为内容↔边缘的呼吸间距；
   · 带色条卡片：作为色条↔内容的间距。
   density 完全不被色条吞掉。色条本身满边/通长，覆盖 density-pad 区域。 */
.card-content { flex: 1 1 auto; min-width: 0; min-height: 0; display: flex; flex-direction: column;
  padding: var(--density-pad, 12px); position: relative; }
.card-content--slots { display: grid; gap: var(--spacing-sm, var(--layout-gap, 8px));
  grid-template-areas: "slot-a" "slot-b" "slot-c" "slot-d";
  /* 行内对齐（表格对齐级）：写在容器上，被各字段继承；字段级可单独覆盖。
     对应 Word 的三级对齐：栏对齐(block) → 表格对齐(inline) → 表格内文字对齐(field)。 */
  text-align: var(--typo-inline-align, left);
  text-align-last: var(--typo-inline-align-last, auto); }
.card-slot-a { grid-area: slot-a; writing-mode: var(--wm-a, horizontal-tb); }
.card-slot-b { grid-area: slot-b; writing-mode: var(--wm-b, horizontal-tb); }
.card-slot-c { grid-area: slot-c; writing-mode: var(--wm-c, horizontal-tb); }
.card-slot-d { grid-area: slot-d; writing-mode: var(--wm-d, horizontal-tb); }
.card-date   { color: var(--card-muted, inherit);
  font-weight: var(--typo-date-weight, 400);
  font-size: calc(0.8rem * var(--typo-date-scale, 0.85));
  text-align: var(--typo-date-align, inherit);
  text-align-last: var(--typo-date-align-last, inherit);
  text-justify: var(--typo-date-justify, auto); }
.card-title  { word-break: break-word; overflow-wrap: break-word;
  font-weight: var(--typo-title-weight, 600);
  font-size: calc(1rem * var(--typo-title-scale, 1.5));
  text-align: var(--typo-title-align, inherit);
  text-align-last: var(--typo-title-align-last, inherit);
  text-justify: var(--typo-title-justify, auto); }
.card-highlights { overflow-wrap: break-word; word-break: break-word;
  font-weight: var(--typo-highlight-weight, 400);
  font-size: calc(0.85rem * var(--typo-highlight-scale, 1.0));
  text-align: var(--typo-highlight-align, inherit);
  text-align-last: var(--typo-highlight-align-last, inherit);
  text-justify: var(--typo-highlight-justify, auto); }
.card-highlight-item { display: block; }
.card-capsule { color: var(--card-accent, inherit);
  font-weight: var(--typo-capsule-weight, 500);
  font-size: calc(0.8rem * var(--typo-capsule-scale, 0.9));
  text-align: var(--typo-capsule-align, inherit);
  text-align-last: var(--typo-capsule-align-last, inherit);
  text-justify: var(--typo-capsule-justify, auto); }
.hl-sep { display: inline; }
/* ===== Highlights block 列表（扁平有序，仿 deco.boxes；容器组带在 Phase 2 复用此结构） =====
   仅提供布局骨架；头像圆形 / 气泡边框 / 分隔线样式由 DB css_template 经 data-attr 驱动。 */
.hl-block { display: flex; flex-direction: column; min-width: 0; }
.hl-block--avatar-side { flex-direction: row; align-items: flex-start; gap: 8px; }
.hl-block--avatar-top  { flex-direction: column; align-items: flex-start; }
/* 头像 class 必须 = .card-avatar（命中 DB .gallery-card[data-style-deco-avatar] .card-avatar 模板）；
   base 提供 initials 居中，DB 模板仅覆盖 bg/border/radius。 */
.card-avatar { display: flex; align-items: center; justify-content: center; overflow: hidden;
  font-size: 0.8em; font-weight: 700; flex-shrink: 0; line-height: 1; }
/* 顶部头像：明显位于内容正上方并居中，与侧边(小圆在左)形成强区分 */
.hl-block--avatar-top .card-avatar { align-self: center; margin-bottom: 6px; }
/* 分隔线复用 DB 期望的 .hl-sep（命中 .gallery-card[data-style-element-divider] .hl-sep）；
   作为 block 间兄弟元素，绝不进气泡内部。 */
.hl-sep { display: inline; }
.hl-action-bar { display: flex; gap: 12px; margin-top: 6px; align-items: center; flex-wrap: wrap; }
.container-group { display: grid; gap: 6px; padding: 4px; position: relative; z-index: 1; }
.container-group > div { min-width: 0; }
/* highlights 带栈内相邻容器组带之间留间距（legacy 整卡 override 不受影响：其在 .card-content 下而非 .card-highlights 下） */
.card-highlights > .container-group { margin-bottom: 6px; }
.card-highlights > .container-group:last-child { margin-bottom: 0; }
/* per_line 奇数行：用于聊天左右交替等，默认仅标记类，具体翻转留待 CSS/DB 细化 */
.cg-band--alt { /* line alternation hook */ }

/* ===== Deco Box：每盒子是对字段/内容的嵌套 .fx-wrap 包裹层 ===== */
/* 选择器通用 [data-style-deco-box="X"]（由 DB css_template 提供 border/bg/shadow/radius/padding），
   同时兼容容器组 slot 上的同款 attr。外层 .fx-wrap[data-fx] 仅承载 backdrop-filter。 */
.fx-wrap { position: relative; }
/* 全局盒子包裹层：需向下传递 flex 链，保持卡片高度撑满（仅在有 global 盒子时插入） */
.fx-wrap.gx-global { display: flex; flex-direction: column; flex: 1 1 auto; min-width: 0; min-height: 0; }

/* ===== Header band（顶栏装饰条 / 文字） ===== */
/* 满边/通长：width:100% 覆盖 density-pad 区域；band_inset 控制离卡片上/左/右边缘的内缩量
   （取消勾选=0 贴边满边，勾选=12px 内缩留白）。底侧不再留白，由内容区的 density-pad 提供色条↔内容间距。 */
.card-header-band {
  flex: 0 0 auto; width: 100%;
  height: var(--header-band-size, 6px);
  min-height: var(--header-band-size, 6px);
  background: transparent;
  display: flex; align-items: center; overflow: hidden; position: relative;
  margin: var(--band-inset, 0px) var(--band-inset, 0px) 0 var(--band-inset, 0px);
}
.card-header-band--has-text {
  height: auto; min-height: var(--header-band-size, 6px); padding: 2px 0;
}
.card-header-text {
  font-size: 0.6rem; line-height: 1.3;
  color: var(--card-muted, inherit);
  padding: 0 8px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
  letter-spacing: 0.08em;
}

/* ===== Main row: side band + content ===== */
.card-main { display: flex; flex: 1 1 auto; min-height: 0; min-width: 0; }
/* 侧栏满边/通长：纵向撑满 card-main（即卡片高度，减去顶栏）；band_inset 控制离卡片上/下边缘的内缩。
   card-edge 一侧（左或右）的内缩由 .card-side-band-left / -right 控制。 */
.card-side-band {
  flex: 0 0 auto; width: var(--side-band-size, 8px); min-width: var(--side-band-size, 8px);
  background: transparent; display: flex; align-items: center; justify-content: center;
  overflow: hidden; position: relative; writing-mode: vertical-rl;
  margin-top: var(--band-inset, 0px); margin-bottom: var(--band-inset, 0px);
}
.card-side-band-left  { margin-left:  var(--band-inset, 0px); }
.card-side-band-right { margin-right: var(--band-inset, 0px); }
.card-side-band--has-text { width: auto; min-width: var(--side-band-size, 8px); padding: 0 4px; }
.card-side-text {
  font-size: 0.55rem; line-height: 1.3; color: var(--card-muted, inherit);
  letter-spacing: 0.05em; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; padding: 6px 0;
}

@keyframes hardware-blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.3; }
}
@keyframes scanline-jitter {
  0%, 100% { transform: translateY(0); }
  10% { transform: translateY(-1px); }
  20% { transform: translateY(1px); }
  30% { transform: translateY(0); }
}
@keyframes band-blink { 0%, 100% { opacity: 1; } 50% { opacity: 0.25; } }
@keyframes band-breathing { 0%, 100% { opacity: 0.55; } 50% { opacity: 1; } }
@keyframes band-scanline { 0% { background-position: 0 -100%; } 100% { background-position: 0 100%; } }
.gallery-card:hover { transform: translateY(-2px); }`;

// ============================================================
// Section 2: ATTR_MAP — data-attr 映射配置
// 格式: dim_subdim → { attr, perElement?, elements? }
// ============================================================

const ATTR_MAP = {
  // layout
  'layout_grid':         { attr: 'data-style-layout-grid' },
  'layout_flow':         { attr: 'data-style-layout-flow' },
  'layout_density':      { attr: 'data-style-layout-density' },
  'layout_block_align':  { attr: 'data-style-layout-block-align' },
  'layout_inline_align': { attr: 'data-style-layout-inline-align' },
  'layout_spacing_scale':{ attr: 'data-style-layout-spacing-scale' },
  // border
  'border_radius_size':  { attr: 'data-border-radius' },
  'border_border_width': { attr: 'data-border-width' },
  'border_border_style': { attr: 'data-border-style' },
  'border_border_shadow':{ attr: 'data-border-shadow' },
  // deco
  'deco_bubble_style':   { attr: 'data-style-deco-bubble' },
  'deco_tag_style':      { attr: 'data-style-deco-tag' },
  'deco_avatar_style':   { attr: 'data-style-deco-avatar' },
  'deco_action_style':   { attr: 'data-style-deco-action' },
  // element
  'element_header_deco': { attr: 'data-style-element-header' },
  'element_side_accent': { attr: 'data-style-element-side' },
  'element_divider':     { attr: 'data-style-element-divider' },
  'element_corner_badge':{ attr: 'data-style-element-corner' },
  'element_bg_pattern':  { attr: 'data-style-element-bg' },
  'element_edge_deco':   { attr: 'data-style-element-edge' },
  'element_floating_deco':{ attr: 'data-style-element-float' },
  // effect — filter_self(元素自身) 与 filter_backdrop(毛玻璃) 解耦为两个独立 attr
  // 两者可同时生效：self 作用于内层字段元素(filter)，backdrop 作用于外层 .fx-wrap(backdrop-filter)
  'effect_filter_self':     { attr: 'data-style-effect-filter', perElement: true,
    elements: ['title','date','capsule','highlights'] },
  'effect_filter_backdrop': { attr: 'data-style-effect-backdrop', perElement: true,
    elements: ['title','date','capsule','highlights'] },
  'effect_transform':   { attr: 'data-style-effect-transform', perElement: true,
    elements: ['title','date','capsule','highlights'] },
  'effect_animation':   { attr: 'data-style-effect-animation', perElement: true,
    elements: ['title','date','capsule','highlights'] },
  // typo — per-element sub_dims
  'typo_font_family':       { attr: 'data-style-typo-font-family', perElement: true,
    elements: ['title','date','capsule','highlights'] },
  'typo_weight_gradient':   { attr: 'data-style-typo-weight-gradient' },
  'typo_size_scale':        { attr: 'data-style-typo-size-scale' },
  'typo_alignment_mode':    { attr: 'data-style-typo-alignment-mode', perElement: true,
    elements: ['title','date','capsule','highlights'] },
  'typo_spacing_tightness': { attr: 'data-style-typo-spacing-tightness', perElement: true,
    elements: ['title','date','capsule','highlights'] },
  'typo_text_decoration':   { attr: 'data-style-typo-text-decoration', perElement: true,
    multiSelect: true, elements: ['title','date','capsule','highlights'] },
};

// ============================================================
// Section 2.5: 容器组带渲染辅助（Phase 2）
// 模块级定义，供 legacy override 分支与 highlights 带栈共用。
// ============================================================

const CG_LAYOUT_CSS = {
  single: 'display:flex;flex-direction:column',
  '2col_left_narrow': 'display:grid;grid-template-columns:auto 1fr',
  '2col_right_narrow': 'display:grid;grid-template-columns:1fr auto',
  '2col_equal': 'display:grid;grid-template-columns:1fr 1fr',
  '3col_equal': 'display:grid;grid-template-columns:1fr 1fr 1fr',
};

const DECO_SUBDIM_ATTR = {
  bubble_style: 'data-style-deco-bubble',
  tag_style: 'data-style-deco-tag',
  avatar_style: 'data-style-deco-avatar',
  box_style: 'data-style-deco-box',
  action_style: 'data-style-deco-action',
};

function parseSlotDeco(decoVal) {
  if (!decoVal || decoVal === 'none') return '';
  if (decoVal.startsWith('deco:')) {
    const parts = decoVal.slice(5).split('.');
    const subDim = parts[0], val = parts.slice(1).join('.');
    const attr = DECO_SUBDIM_ATTR[subDim];
    return attr ? attr + '="' + escapeAttr(val) + '"' : '';
  }
  return '';
}

// highlights 作用域内可渲染的字段集合（排除 date/title/capsule，避免与四槽骨架重复渲染）
const CG_HL_FIELDS = new Set([
  'highlights', 'highlight_1', 'highlight_2', 'highlight_3', 'highlight_4', 'highlight_5',
  'avatar', 'like_count', 'share_count', 'comment_count'
]);

function normalizeContainerGroups(styleJson) {
  const cg = styleJson && styleJson.container_groups;
  if (Array.isArray(cg)) return cg.filter(c => c && c !== 'none');
  return [];
}

// ============================================================
// Section 3: DEFAULT_STYLE_JSON — 全默认值
// ============================================================

export const DEFAULT_STYLE_JSON = {
  palette: { harmony: 'mono_grey', tone: 'light_standard', slot: 'original' },
  layout: { grid: 'single', flow: 'horizontal', flow_vertical: [],
    slot_assignment: { a: 'date', b: 'title', c: 'highlights', d: 'capsule' },
    density: 'normal',
    block_align: 'left', inline_align: 'left', spacing_scale: 'md' },
  typo: {
    font_family: { title:'system_sans', date:'system_sans', capsule:'system_sans', highlights:'system_sans' },
    weight_gradient: 'balanced', size_scale: 'petite',
    alignment_mode: { title:'inherit', date:'inherit', capsule:'inherit', highlights:'inherit' },
    spacing_tightness: { title:'normal', date:'normal', capsule:'normal', highlights:'normal' },
    text_decoration: { title:[], date:[], capsule:[], highlights:[] }
  },
  border: { radius_size:'none', border_width:'none', border_style:'solid', border_shadow:'none' },
  deco: { bubble_style:'none', tag_style:'none', avatar_style:'none', avatar_pos:'side', boxes:[], box_radius:8, box_gap:12, action_style:'none' },
  element: { header_deco:'none', header_text:'', header_width:6,
    side_accent:'none', side_text:'', side_width:8, side_position:'left',
    band_inset:true,
    divider:'none', corner_badge:'none',
    bg_pattern:'none', edge_deco:'none', floating_deco:'none' },
  effect: {
    filter_self: { title:'none', date:'none', capsule:'none', highlights:'none' },
    filter_backdrop: { title:'none', date:'none', capsule:'none', highlights:'none' },
    transform: { title:'none', date:'none', capsule:'none', highlights:'none' },
    animation: { title:'none', date:'none', capsule:'none', highlights:'none' } },
  container_group: 'none',
  container_groups: []
};

// ============================================================
// Section 4: 工具函数
// ============================================================

function escapeHtml(s) {
  if (s == null) return '';
  return String(s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

function escapeAttr(s) {
  return String(s).replace(/"/g, '&quot;');
}

function hexToRgb(hex) {
  hex = hex.replace('#', '');
  if (hex.length === 3) hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
  const r = parseInt(hex.substring(0,2), 16);
  const g = parseInt(hex.substring(2,4), 16);
  const b = parseInt(hex.substring(4,6), 16);
  if (isNaN(r) || isNaN(g) || isNaN(b)) return '128,128,128';
  return r + ',' + g + ',' + b;
}

// ============================================================
// Ant Design 色阶算法（用于 tone/slot 变换）
// ============================================================

function hexToHSL(hex) {
  hex = hex.replace('#', '');
  if (hex.length === 3) {
    hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
  }
  const r = parseInt(hex.substring(0, 2), 16) / 255;
  const g = parseInt(hex.substring(2, 4), 16) / 255;
  const b = parseInt(hex.substring(4, 6), 16) / 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  let h = 0, s = 0, l = (max + min) / 2;
  if (max !== min) {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    switch (max) {
      case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break;
      case g: h = ((b - r) / d + 2) / 6; break;
      case b: h = ((r - g) / d + 4) / 6; break;
    }
  }
  return {
    h: Math.round(h * 360),
    s: Math.round(s * 100),
    l: Math.round(l * 100)
  };
}

function hslToHex(h, s, l) {
  h = ((h % 360) + 360) % 360;
  s = Math.max(0, Math.min(100, s)) / 100;
  l = Math.max(0, Math.min(100, l)) / 100;
  const a = s * Math.min(l, 1 - l);
  const f = n => {
    const k = (n + h / 30) % 12;
    const color = l - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
    return Math.round(255 * color).toString(16).padStart(2, '0');
  };
  return '#' + f(0) + f(8) + f(4);
}

function generateAntScale(seedHex) {
  const { h, s, l } = hexToHSL(seedHex);
  // 相对偏移曲线：index 4 (step 5) 的偏移=0, 系数=100% → 恒等于种子原色
  const lOffsets = [40, 30, 20, 10,   0, -10, -20, -30, -40, -50];
  const sFactors = [20, 30, 45, 60, 100, 110, 120, 130, 140, 150];
  return lOffsets.map((offset, i) => {
    const targetL = Math.max(2, Math.min(98, l + offset));
    const sat     = Math.min(100, Math.max(6, Math.round(s * sFactors[i] / 100)));
    return hslToHex(h, sat, targetL);
  });
}

function defaultColors() {
  return {
    bg: '#ffffff', text: '#1a1a1a', accent: '#3b82f6', muted: '#e5e5e5',
    extra_colors: {}, accentRgb: '59,130,246', bgRgb: '255,255,255'
  };
}

// ============================================================
// Section 5: resolvePaletteColors — 从 DB 静态色板解析颜色
// ============================================================

function resolvePaletteColors(paletteConfig, paletteOptions) {
  if (!paletteConfig || !paletteOptions || !paletteOptions.length) return defaultColors();

  const { harmony, tone, slot } = paletteConfig;
  if (!harmony) return defaultColors();

  // 1. 找 harmony_palette 行 → 取种子色
  const harmonyRow = paletteOptions.find(r => r.value === harmony && r.sub_dim === 'harmony_palette');
  if (!harmonyRow) {
    console.warn('[resolvePaletteColors] harmony_palette not found:', harmony);
    return defaultColors();
  }

  // 2. 对 harmony_palette 的每个颜色列各自生成10阶色阶（支持多色相）
  const scaleBg     = generateAntScale(harmonyRow.bg         || '#3b82f6');
  const scaleText   = generateAntScale(harmonyRow.text_color || harmonyRow.bg || '#1a1a1a');
  const scaleAccent = generateAntScale(harmonyRow.accent     || harmonyRow.bg || '#3b82f6');
  const scaleMuted  = generateAntScale(harmonyRow.muted      || harmonyRow.bg || '#e5e5e5');

  // 3. 找 tone_mapping 行，根据索引值从各自色阶取色
  const toneValue = tone || 'light_standard';
  const toneRow = paletteOptions.find(r => r.value === toneValue && r.sub_dim === 'tone_mapping');
  if (!toneRow) {
    console.warn('[resolvePaletteColors] tone_mapping not found:', toneValue, '- using default scale indices');
  }

  const getIdx = (row, col, fallback) => {
    const v = row ? parseInt(row[col]) : fallback;
    return Math.max(0, Math.min(9, isNaN(v) ? fallback : v));
  };

  const bgIdx     = getIdx(toneRow, 'bg',         3);
  const textIdx   = getIdx(toneRow, 'text_color', 8);
  const accentIdx = getIdx(toneRow, 'accent',    5);
  const mutedIdx  = getIdx(toneRow, 'muted',     4);

  let colors = [
    scaleBg[bgIdx],
    scaleText[textIdx],
    scaleAccent[accentIdx],
    scaleMuted[mutedIdx]
  ];

  // 4. 找 slot_assignment 行，重新排列4个颜色
  const slotValue = slot || 'original';
  const slotRow = paletteOptions.find(r => r.value === slotValue && r.sub_dim === 'slot_assignment');
  if (slotRow) {
    const slotBgIdx     = getIdx(slotRow, 'bg',         1) - 1;
    const slotTextIdx   = getIdx(slotRow, 'text_color', 2) - 1;
    const slotAccentIdx = getIdx(slotRow, 'accent',    3) - 1;
    const slotMutedIdx  = getIdx(slotRow, 'muted',     4) - 1;
    colors = [
      colors[Math.max(0, Math.min(3, slotBgIdx))],
      colors[Math.max(0, Math.min(3, slotTextIdx))],
      colors[Math.max(0, Math.min(3, slotAccentIdx))],
      colors[Math.max(0, Math.min(3, slotMutedIdx))]
    ];
  }

  const [bg, text, accent, muted] = colors;

  // 5. 处理 extra_colors
  // 新格式：harmony 行的 extra_colors 存目标原色（如 "#93C5FD"），直接使用
  // 兼容旧格式：tone 行的 extra_colors 存索引数字，从对应色阶取色
  let extra = {};
  const ecSource = (harmonyRow.extra_colors && harmonyRow.extra_colors !== null)
    ? harmonyRow.extra_colors
    : (toneRow && toneRow.extra_colors ? toneRow.extra_colors : null);
  if (ecSource) {
    try {
      const ec = typeof ecSource === 'string' ? JSON.parse(ecSource) : ecSource;
      for (const [k, v] of Object.entries(ec)) {
        if (typeof v === 'string' && v.startsWith('#')) {
          // 新格式：直接是目标原色，生成色阶后取 index 4（种子色本身）
          extra[k] = generateAntScale(v)[4];
        } else {
          // 旧格式兼容：数字索引，从对应色阶取色
          const idx = Math.max(0, Math.min(9, typeof v === 'number' ? v : parseInt(v)));
          const lk = k.toLowerCase();
          const scale = lk.includes('text')   ? scaleText
                      : lk.includes('accent') ? scaleAccent
                      : lk.includes('muted')  ? scaleMuted
                      : scaleBg;
          extra[k] = scale[idx];
        }
      }
    } catch (e) {
      console.warn('[resolvePaletteColors] extra_colors parse error:', e);
    }
  }

  return {
    bg, text, accent, muted,
    extra_colors: extra,
    accentRgb: hexToRgb(accent),
    bgRgb: hexToRgb(bg)
  };
}

// ============================================================
// Section 6: buildDataAttrs — 从 styleJson 构建 data-* 属性串
// ============================================================

function buildDataAttrs(styleJson) {
  if (!styleJson) return '';

  const attrs = {};

  // palette: 生成 data-style-palette="harmony_value" 属性
  if (styleJson.palette && styleJson.palette.harmony) {
    attrs['data-style-palette'] = escapeAttr(styleJson.palette.harmony);
  }

  // --- General loop for all other dims ---
  // effect.filter_self / effect_filter_backdrop 已通过 ATTR_MAP(perElement) 各自发射独立 attr：
  //   self  → data-style-effect-filter-<el>  （作用于内层字段元素 .card-XXX 的 filter）
  //   backdrop → data-style-effect-backdrop-<el>（作用于外层 .fx-wrap[data-fx=el] 的 backdrop-filter）
  // 两者不再互斥，可同时生效（DOM 分层化解浏览器层叠上下文冲突）。
  for (const [dim, subDims] of Object.entries(styleJson)) {
    if (dim === 'palette' || dim === 'container_group') continue;
    if (!subDims || typeof subDims !== 'object') continue;

      for (const [subDim, value] of Object.entries(subDims)) {
      // Skip header_text / side_text / header_width / side_width / side_position / band_inset
      // 以及自定义文字独立排版键（family/size/align）—— 均为 content / 内联样式字段，非 data-attr 维度
      if (subDim === 'header_text' || subDim === 'side_text'
        || subDim === 'header_width' || subDim === 'side_width' || subDim === 'side_position'
        || subDim === 'band_inset'
        || subDim === 'header_text_family' || subDim === 'header_text_size' || subDim === 'header_text_align'
        || subDim === 'side_text_family' || subDim === 'side_text_size' || subDim === 'side_text_align') continue;

      if (value == null || value === 'none') continue;

      const mapKey = dim + '_' + subDim;
      const mapping = ATTR_MAP[mapKey];
      if (!mapping) continue;

      if (mapping.perElement) {
        // Per-element: normalize string → object (backward compat)
        const perElVal = (typeof value === 'object' && !Array.isArray(value)) ? value
          : (() => { const m = {}; mapping.elements.forEach(e => m[e] = value); return m; })();
        for (const el of mapping.elements) {
          const elVal = perElVal[el];
          if (elVal == null || elVal === 'none') continue;
          // 字段级 alignment_mode 默认 'inherit' = 跟随行内对齐，不发射 attr（由容器统一控制）
          if (mapKey === 'typo_alignment_mode' && elVal === 'inherit') continue;
          if (Array.isArray(elVal)) {
            if (elVal.length === 0) continue;
            attrs[mapping.attr + '-' + el] = escapeAttr(elVal.join(' '));
          } else {
            attrs[mapping.attr + '-' + el] = escapeAttr(elVal);
          }
        }
      } else if (Array.isArray(value)) {
        // Global multi-select: ['a', 'b']
        if (value.length === 0) continue;
        attrs[mapping.attr] = escapeAttr(value.join(' '));
      } else if (typeof value === 'object' && value !== null && !mapping.perElement) {
        // Backward compat: value is object but mapping is global — skip (shouldn't normally happen)
        continue;
      } else {
        // Global string (backward compat)
        attrs[mapping.attr] = escapeAttr(String(value));
      }
    }
  }

  const parts = Object.entries(attrs).map(([k, v]) => k + '="' + v + '"');
  return parts.length ? ' ' + parts.join(' ') : '';
}

// ============================================================
// Section 7: buildHighlightsInner — 渲染 highlights 列表内容(无外层div)
// ============================================================

function buildHighlightsInner(highlights) {
  if (!highlights || !highlights.length) return '';
  let h = '';
  for (let i = 0; i < highlights.length; i++) {
    h += '<div class="card-highlight-item">' + escapeHtml(highlights[i]);
    if (i < highlights.length - 1) {
      h += '<span class="hl-sep" data-sep="pipe"></span>';
    }
    h += '</div>';
  }
  return h;
}

function buildHighlightsHtml(highlights) {
  if (!highlights || !highlights.length) return '';
  return '<div class="card-highlights">' + buildHighlightsInner(highlights) + '</div>';
}

// ============================================================
// buildHighlightsLayout — highlights 区渲染分派
//  · container_groups 数组非空 → 容器组带栈（compose，堆叠进 highlights，不吞四槽）
//  · 否则 → 默认 per_line 块列表（全局 deco 的 bubble/tag/avatar/action 逐块生效）
// 关键 DOM class 对齐 DB css_template 选择器（见 buildDefaultHighlights / renderCgBand）。
// 分隔线为 block 间兄弟元素 .hl-sep（绝不在气泡内部）→ 解决「气泡+分隔线冲突」。
// ============================================================

function buildHighlightsLayout(styleJson, diary, allOptions) {
  const cgCodes = normalizeContainerGroups(styleJson);
  if (cgCodes.length) {
    const bands = buildContainerGroupBands(styleJson, diary, allOptions, cgCodes);
    if (bands) return bands;
  }
  return buildDefaultHighlights(styleJson, diary, allOptions);
}

// 默认(无容器组) per_line 块列表：每条 highlight 一行；全局 deco 的 bubble/tag/avatar(+avatar_pos)/action 逐块生效。
// 分隔线渲染为 block 间兄弟 .hl-sep（解决气泡+分隔线冲突）；操作区带挂在 highlights 下方。
function buildDefaultHighlights(styleJson, diary, allOptions) {
  const d = diary || {};
  const highlights = Array.isArray(d.highlights) ? d.highlights : [];
  const deco = (styleJson && styleJson.deco) || {};
  const el = (styleJson && styleJson.element) || {};

  const bubble = (deco.bubble_style && deco.bubble_style !== 'none') ? deco.bubble_style : '';
  const tag = (deco.tag_style && deco.tag_style !== 'none') ? deco.tag_style : '';
  const avatarStyle = (deco.avatar_style && deco.avatar_style !== 'none') ? deco.avatar_style : '';
  const avatarPos = deco.avatar_pos || 'side';
  const actionStyle = (deco.action_style && deco.action_style !== 'none') ? deco.action_style : '';
  const divider = (el.divider && el.divider !== 'none') ? el.divider : '';

  if (!highlights.length && !actionStyle) return '';

  let html = '';
  // 文本块：每条 highlight 一行；全局 deco 的 bubble/tag/avatar 逐块生效
  for (let i = 0; i < highlights.length; i++) {
    const text = escapeHtml(highlights[i]);
    const decoAttr = (bubble ? ' data-style-deco-bubble="' + escapeAttr(bubble) + '"' : '')
                   + (tag ? ' data-style-deco-tag="' + escapeAttr(tag) + '"' : '');
    const inner = '<div class="card-highlight-item">' + text + '</div>';
    let cls = 'hl-block';
    let blockInner = inner;
    // 顶部头像：仅首个 block 显示（整段 highlights 单次头像）；侧边头像：每条 block 都显示（聊天/roleplay 多行头像）
    if (avatarStyle && (avatarPos !== 'top' || i === 0)) {
      const av = '<div class="card-avatar cg-avatar-text" data-style-deco-avatar="' + escapeAttr(avatarStyle) + '">'
        + escapeHtml(d.avatar || 'BF') + '</div>';
      cls += (avatarPos === 'top') ? ' hl-block--avatar-top' : ' hl-block--avatar-side';
      blockInner = av + inner;   // 头像在文本之前（top=上方 / side=左侧），由 CSS 决定方向
    }
    html += '<div class="' + cls + '"' + decoAttr + '>' + blockInner + '</div>';
    // 分隔线 = block 间兄弟元素 .hl-sep（绝不在气泡内部）→ 命中 DB 模板
    if (divider && i < highlights.length - 1) {
      html += '<div class="hl-sep"></div>';
    }
  }

  // 操作区带（once）：默认挂在 highlights 下方；每项 = .card-action-item（命中 DB 模板）；
  // tag 嵌套进操作项作为计数徽标 .card-style（命中 DB tag 模板，实现「标签嵌套在操区里」）
  if (actionStyle) {
    const item = (cls2, label, val) => {
      const badge = tag ? '<span class="card-style">' + escapeHtml(String(val)) + '</span>' : '';
      return '<span class="card-action-item ' + cls2 + '">' + label + badge + '</span>';
    };
    html += '<div class="hl-action-bar" data-style-deco-action="' + escapeAttr(actionStyle) + '">'
      + item('cg-like', '\u8d5e', d.like_count || '0')
      + item('cg-comment', '\u8bc4', d.comment_count || '0')
      + item('cg-share', '\u8f6c', d.share_count || '0')
      + '</div>';
  }
  return html;
}

// 容器组带栈：container_groups 数组 → 在 highlights 内按序堆叠的横向带（compose，非 override）。
// 单条 CG = 一条带模板；repeat_mode:
//   · 'per_line' → 每条 highlight 重复一次该带（聊天/评论：头像+气泡逐行）；
//   · 'once'     → 整段仅渲染一次（操作栏/便利贴：highlight_1/2/3 或 like/share/comment）。
// 仅渲染 highlights 作用域字段（highlight_N/avatar/like/share/comment），date/title/capsule 由四槽骨架渲染，避免重复。
// 容器组带栈（compose，堆叠进 highlights，不替换四槽）。
// 单条 CG 的 repeat_mode：
//   · 'per_line' → 参与「逐行循环」：所有 per_line CG 按数组顺序排成一个循环，
//     每条 highlight 行由循环里的下一个 CG 承包（左/右交替对话即 [left, right] 两个 per_line CG 轮流）。
//     单独一个 per_line CG 则仍是它自己逐行重复（向后兼容）。
//   · 'once'     → 整段仅渲染一次；出现在首个 per_line 之前→渲染在对话前，之后→渲染在对话后。
// 分隔线（element.divider）：在所有顶层带之间插入 .hl-sep 兄弟元素，命中 DB [data-style-element-divider] .hl-sep，
//   解决「容器组模式下分隔线无法使用」的问题（与默认块列表的分隔线 DOM 契约一致）。
function buildContainerGroupBands(styleJson, diary, allOptions, cgCodes) {
  const d = diary || {};
  const highlights = Array.isArray(d.highlights) ? d.highlights : [];
  const cgOptions = (allOptions && allOptions.container_group) || [];
  const el = (styleJson && styleJson.element) || {};
  const divider = (el.divider && el.divider !== 'none') ? el.divider : '';

  const perLine = [], onceBefore = [], onceAfter = [];
  let seenPerLine = false;
  for (const code of cgCodes) {
    const cgRow = cgOptions.find(r => r.group_code === code);
    if (!cgRow) continue;
    if (cgRow.repeat_mode === 'per_line') { perLine.push(cgRow); seenPerLine = true; }
    else if (!seenPerLine) onceBefore.push(cgRow);
    else onceAfter.push(cgRow);
  }
  if (!perLine.length && !onceBefore.length && !onceAfter.length) return '';

  const bandParts = [];
  for (const row of onceBefore) bandParts.push(renderCgBand(row, highlights, -1, d));
  const n = highlights.length || 1;
  for (let i = 0; i < n; i++) {
    bandParts.push(renderCgBand(perLine[i % perLine.length], highlights, i, d));
  }
  for (const row of onceAfter) bandParts.push(renderCgBand(row, highlights, -1, d));
  if (!bandParts.length) return '';

  if (divider) {
    let html = '';
    for (let i = 0; i < bandParts.length; i++) {
      html += bandParts[i];
      if (i < bandParts.length - 1) html += '<div class="hl-sep"></div>';
    }
    return html;
  }
  return bandParts.join('');
}

// 渲染单条容器组带：复用 DB 的 field_slot_map / slot_deco_map / layout_slot_map（cell 模型）。
// slot 包裹层 class = slotId.replace(/_/g,'-')（与 DB extra_css 的 .cg-xxx 选择器一致）；
// slot_deco_map 的 deco:xxx.yyy → 对应 data-style-deco-*，命中 DB css_template。
function renderCgBand(cgRow, highlights, lineIdx, diary) {
  const d = diary || {};
  let fieldSlotMap = {}, slotDecoMap = {}, layoutSlotMap = {};
  try {
    fieldSlotMap  = typeof cgRow.field_slot_map  === 'string' ? JSON.parse(cgRow.field_slot_map)  : (cgRow.field_slot_map  || {});
    slotDecoMap   = typeof cgRow.slot_deco_map   === 'string' ? JSON.parse(cgRow.slot_deco_map)   : (cgRow.slot_deco_map   || {});
    layoutSlotMap = typeof cgRow.layout_slot_map === 'string' ? JSON.parse(cgRow.layout_slot_map) : (cgRow.layout_slot_map || {});
  } catch { /* 回退空 */ }

  // 仅保留 highlights 作用域字段（排除 date/title/capsule，避免与四槽骨架重复渲染）
  const slotFields = {};
  for (const [field, slotId] of Object.entries(fieldSlotMap)) {
    if (!CG_HL_FIELDS.has(field)) continue;
    if (!slotFields[slotId]) slotFields[slotId] = [];
    slotFields[slotId].push(field);
  }
  if (!Object.keys(slotFields).length) return '';

  const fieldHtml = (field) => {
    switch (field) {
      case 'highlights': {
        const txt = (lineIdx >= 0) ? (highlights[lineIdx] || '') : highlights.join('\n');
        return txt ? '<div class="card-highlight-item">' + escapeHtml(txt) + '</div>' : '';
      }
      case 'highlight_1': return highlights[0] ? '<div class="card-highlight-item">' + escapeHtml(highlights[0]) + '</div>' : '';
      case 'highlight_2': return highlights[1] ? '<div class="card-highlight-item">' + escapeHtml(highlights[1]) + '</div>' : '';
      case 'highlight_3': return highlights[2] ? '<div class="card-highlight-item">' + escapeHtml(highlights[2]) + '</div>' : '';
      case 'highlight_4': return highlights[3] ? '<div class="card-highlight-item">' + escapeHtml(highlights[3]) + '</div>' : '';
      case 'highlight_5': return highlights[4] ? '<div class="card-highlight-item">' + escapeHtml(highlights[4]) + '</div>' : '';
      case 'avatar':
        return '<div class="card-avatar cg-avatar-text">' + escapeHtml(d.avatar || 'BF') + '</div>';
      case 'like_count':
        return '<span class="card-action-item cg-like">' + escapeHtml(String(d.like_count || '0')) + ' \u8d5e</span>';
      case 'share_count':
        return '<span class="card-action-item cg-share">' + escapeHtml(String(d.share_count || '0')) + ' \u8f6c</span>';
      case 'comment_count':
        return '<span class="card-action-item cg-comment">' + escapeHtml(String(d.comment_count || '0')) + ' \u8bc4</span>';
      default: return '';
    }
  };

  const cgLayoutCss = CG_LAYOUT_CSS[cgRow.layout_ref] || CG_LAYOUT_CSS.single;
  const slotOrder = Object.keys(layoutSlotMap).length
    ? Object.keys(layoutSlotMap).sort((a, b) => (layoutSlotMap[a] || 0) - (layoutSlotMap[b] || 0))
    : Object.keys(slotFields);

  let cgHtml = '<div class="container-group ' + escapeAttr(cgRow.group_code) + ' cg-band'
    + (lineIdx >= 0 ? ' cg-band--line-' + lineIdx + (lineIdx % 2 === 1 ? ' cg-band--alt' : '') : '')
    + '" style="' + cgLayoutCss + '">';

  for (const slotId of slotOrder) {
    const decoVal = slotDecoMap[slotId] || 'none';
    const slotAttr = parseSlotDeco(decoVal);
    const colIdx = layoutSlotMap[slotId];
    const content = (slotFields[slotId] || []).map(f => fieldHtml(f)).join('');
    if (content) {
      let slotStyle = '';
      if (cgRow.layout_ref !== 'single' && colIdx !== undefined) {
        slotStyle = 'grid-column:' + (colIdx + 1);
      }
      cgHtml += '<div class="' + escapeAttr(slotId.replace(/_/g, '-')) + '"'
        + (slotStyle ? ' style="' + slotStyle + '"' : '')
        + (slotAttr ? ' ' + slotAttr : '') + '>'
        + content + '</div>';
    }
  }
  cgHtml += '</div>';
  return cgHtml;
}

// ============================================================
// buildTextStyle — 生成自定义文字（顶栏/侧栏）的内联样式串
// isHeader=true（顶栏）：水平文字，align ∈ left/center/right/stretch，靠 display:block;width:100% + text-align 生效
// isHeader=false（侧栏）：竖排文字，对齐方向是沿侧栏的「纵向位置」(top/center/bottom)，
//   由外层 .card-side-band 的 justify-content 控制（见 buildCardHtml）；此处仅处理 stretch(撑满)→ height:100% + 纵向 justify
// ============================================================
function buildTextStyle(family, size, align, isHeader) {
  // 注意：font-family 不再在此内联注入。DB 原始值（如 'terminal_mono'）不是合法 CSS 字体名，
  // 内联会导致浏览器回退到默认衬线体（宋体）。字体改由 buildCardHtml 在 .card-header-text /
  // .card-side-text 上写 data-style-typo-font-family-headertext / -sidetext 属性，
  // 经 style_typo_options.font_family 的 css_template 驱动（与四字段同源）。
  // 此处 family 参数保留仅为兼容调用点，不再使用。
  const parts = [];
  if (size)   parts.push('font-size:' + size);
  if (isHeader) {
    // 顶栏：水平文字，对齐 = 水平方向。stretch 用 inter-character 让单行/单词也能撑满宽度
    if (align === 'stretch')      parts.push('display:block;width:100%;text-align:justify;text-align-last:justify;text-justify:inter-character');
    else if (align)               parts.push('display:block;width:100%;text-align:' + align);
  } else {
    // 侧栏：竖排文字(writing-mode:vertical-rl)。stretch 需纵向撑满：
    // 行内轴为纵向，inter-character 让单行竖排文字也能沿高度方向铺开。
    // top/center/bottom 由外层 band 的 justify-content 控制，此处不处理。
    if (align === 'stretch')      parts.push('height:100%;text-align:justify;text-align-last:justify;text-justify:inter-character');
  }
  return parts.length ? parts.join(';') + ';' : '';
}

// ============================================================
// Section 8: buildCardHtml — 构建卡片 HTML
// 两种模式：container_group="none" 标准grid / 其他值嵌套slot
// ============================================================

function buildCardHtml(styleJson, diary, dataAttrs, paletteStyle, allOptions, verticalFields) {
  const d = diary || {};
  const date = escapeHtml(d.date || '----/--/--');
  const title = escapeHtml(d.title || '');
  const capsule = escapeHtml(d.capsuleName || '');
  const highlights = d.highlights || [];
  const dateRaw = d.dateRaw || '';
  const id = d.id || '';

  // 容器组双模型：
  //  · legacy 单值字符串(非'none') → 走原 override 分支（整卡替换，兼容旧卡，不破坏既有视觉）；
  //  · 新模型 container_groups 数组 → 在 highlights 带栈内 compose（由 buildHighlightsLayout 处理），
  //    四槽(date/title/capsule/highlights)骨架常驻，容器组横向带仅堆叠进 highlights。
  const legacyCg = (styleJson && styleJson.container_group);
  const hasLegacyCg = typeof legacyCg === 'string' && legacyCg !== 'none';

  // 装饰条与自定义文字完全解耦：
  // - 外观由卡片上的 data-style-element-header / data-style-element-side 属性驱动（DB css_template 渲染到 .card-header-band / .card-side-band）
  // - 粗细由 element.header_width / side_width 决定（写入 --header-band-size / --side-band-size CSS 变量）
  // - 位置 side_position 决定侧栏在左 / 右
  // - 自定义文字仅在填写时才出现，且渲染在 band 内部、与色带重合
  const elCfg = (styleJson && styleJson.element) || {};
  const headerDeco   = elCfg.header_deco   || 'none';
  const sideAccent   = elCfg.side_accent   || 'none';
  const headerText   = elCfg.header_text   || '';
  const sideText     = elCfg.side_text     || '';
  const sidePosition = elCfg.side_position  || 'left';
  // 自定义文字（顶栏 / 侧栏）独立排版：字体 / 字号 / 对齐
  const headerTextFamily = elCfg.header_text_family || '';
  const headerTextSize   = elCfg.header_text_size   || '';
  const headerTextAlign  = elCfg.header_text_align  || '';
  const sideTextFamily   = elCfg.side_text_family   || '';
  const sideTextSize     = elCfg.side_text_size     || '';
  const sideTextAlign    = elCfg.side_text_align    || '';

  // ---- 计算 body（slot skeleton 或 container-group）----
  let bodyHtml = '';
  let contentIsSlots = false;

  // --- Deco Box 多盒嵌套包裹层 ---
  // 扁平列表 deco.boxes = [{ style, target }, ...]；兼容旧单值 deco.box_style/box_target
  // 每个盒子渲染为一个嵌套的 .fx-wrap[data-style-deco-box="X"] 包裹层：
  //   · 直接套在字段/内容外，border/padding 自然作用到内容（恢复「之前」贴合度，不再忽远忽近）
  //   · 多个盒子 = 多层嵌套，可任意叠加（渐变/毛玻璃/液态玻璃同字段并存）
  //   · 选择器通用 [data-style-deco-box="X"]（同时兼容容器组 slot 上的同款 attr，无需改引擎）
  const decoBoxes = (styleJson && styleJson.deco && Array.isArray(styleJson.deco.boxes))
    ? styleJson.deco.boxes.slice() : [];
  if (styleJson && styleJson.deco && styleJson.deco.box_style && styleJson.deco.box_style !== 'none') {
    decoBoxes.push({ style: styleJson.deco.box_style, target: styleJson.deco.box_target || 'global' });
  }
  // 返回某 target 下的盒子对象(按数组顺序)，供包裹层渲染读取 style/target/coincide
  function boxObjsFor(target) {
    return decoBoxes.filter(b => b && b.style && b.style !== 'none' && b.target === target);
  }
  // 字段包裹：最外层 .fx-wrap[data-fx=field] 承载 backdrop-filter；
  // 其内按数组顺序(外→内)嵌套各盒子包裹层（数组 [B0,B1] → B0 在外、B1 贴内容）。
  // 每个盒子包裹层可单独设 coincide=true 强制 padding:0 → 与内层边缘完全重合(无框、无间距)。
  function wrapField(field, innerHtml) {
    const boxes = boxObjsFor(field);
    let html = innerHtml;
    for (let i = boxes.length - 1; i >= 0; i--) {
      const b = boxes[i];
      const pad = (b.coincide === true) ? 'padding:0;' : 'padding: var(--box-gap, 12px);';
      html = '<div class="fx-wrap" data-style-deco-box="' + escapeAttr(b.style) + '" style="border-radius: var(--deco-radius, 8px); ' + pad + '">' + html + '</div>';
    }
    return '<div class="fx-wrap" data-fx="' + field + '">' + html + '</div>';
  }

  if (!hasLegacyCg) {
    // --- slot skeleton 模式 ---
    const slotAssignment = (styleJson && styleJson.layout && styleJson.layout.slot_assignment)
      || { a: 'date', b: 'title', c: 'highlights', d: 'capsule' };

    const fieldContent = {
      date: date || '',
      title: title || '',
      highlights: buildHighlightsLayout(styleJson, diary, allOptions),
      capsule: capsule || ''
    };
    const fieldClass = {
      date: 'card-date', title: 'card-title',
      highlights: 'card-highlights', capsule: 'card-capsule'
    };

    let slotHtml = '';
    for (const slot of ['a', 'b', 'c', 'd']) {
      const field = slotAssignment[slot];
      if (!field || !fieldContent[field]) continue;
      // 内层字段元素(.card-XXX)承载 filter_self；外层 .fx-wrap[data-fx=field] 承载 backdrop-filter + box 叠放层
      const innerField = '<div class="' + fieldClass[field] + '">' + fieldContent[field] + '</div>';
      slotHtml += '<div class="card-slot-' + slot + '">' + wrapField(field, innerField) + '</div>';
    }
    bodyHtml = slotHtml;
    contentIsSlots = true;
  } else {
    // --- container_group 嵌套 slot 模式（legacy 单值 override）---
    const cgOptions = (allOptions && allOptions.container_group) || [];
    const cgRow = cgOptions.find(r => r.group_code === legacyCg);
    if (!cgRow) {
      return buildCardHtml(
        { ...styleJson, container_group: 'none' }, diary, dataAttrs, paletteStyle, allOptions, verticalFields
      );
    }

    let fieldSlotMap = {}, slotDecoMap = {}, layoutSlotMap = {};
    try {
      fieldSlotMap  = typeof cgRow.field_slot_map  === 'string' ? JSON.parse(cgRow.field_slot_map)  : (cgRow.field_slot_map  || {});
      slotDecoMap   = typeof cgRow.slot_deco_map   === 'string' ? JSON.parse(cgRow.slot_deco_map)   : (cgRow.slot_deco_map   || {});
      layoutSlotMap = typeof cgRow.layout_slot_map === 'string' ? JSON.parse(cgRow.layout_slot_map) : (cgRow.layout_slot_map || {});
    } catch { /* 回退 */ }

    if (!Object.keys(fieldSlotMap).length) {
      return buildCardHtml(
        { ...styleJson, container_group: 'none' }, diary, dataAttrs, paletteStyle, allOptions, verticalFields
      );
    }

    const slotFields = {};
    for (const [field, slotId] of Object.entries(fieldSlotMap)) {
      if (!slotFields[slotId]) slotFields[slotId] = [];
      slotFields[slotId].push(field);
    }

    const fieldHtml = (field) => {
      switch (field) {
        case 'date': return date ? '<div class="card-date">' + date + '</div>' : '';
        case 'title': return title ? '<div class="card-title">' + title + '</div>' : '';
        case 'highlights': return buildHighlightsHtml(highlights);
        case 'capsule': return capsule ? '<div class="card-capsule">' + capsule + '</div>' : '';
        case 'avatar': return '<div class="cg-avatar-text">' + escapeHtml(d.avatar || 'BF') + '</div>';
        case 'like_count': return '<span class="cg-like">' + escapeHtml(String(d.like_count || '0')) + ' \u8d5e</span>';
        case 'share_count': return '<span class="cg-share">' + escapeHtml(String(d.share_count || '0')) + ' \u8f6c</span>';
        case 'comment_count': return '<span class="cg-comment">' + escapeHtml(String(d.comment_count || '0')) + ' \u8bc4</span>';
        default:
          if (field.startsWith('highlight_')) {
            const idx = parseInt(field.slice(-1)) - 1;
            return highlights[idx] ? '<div class="card-highlights">' + escapeHtml(highlights[idx]) + '</div>' : '';
          }
          return '';
      }
    };

    const cgLayoutCss = CG_LAYOUT_CSS[cgRow.layout_ref] || CG_LAYOUT_CSS.single;

    const slotOrder = Object.keys(layoutSlotMap).length
      ? Object.keys(layoutSlotMap).sort((a, b) => (layoutSlotMap[a] || 0) - (layoutSlotMap[b] || 0))
      : Object.keys(slotFields);

    let cgHtml = '<div class="container-group ' + escapeAttr(cgRow.group_code) + '" style="' + cgLayoutCss + '">';

    for (const slotId of slotOrder) {
      const decoVal = slotDecoMap[slotId] || 'none';
      const slotAttr = parseSlotDeco(decoVal);
      const colIdx = layoutSlotMap[slotId];
      const content = (slotFields[slotId] || []).map(f => {
        const h = fieldHtml(f);
        return h ? wrapField(f, h) : '';
      }).join('');

      if (content || decoVal.startsWith('group:')) {
        const fieldsInSlot = slotFields[slotId] || [];
        const hasVertical = verticalFields && verticalFields.length
          && fieldsInSlot.some(f => verticalFields.includes(f));
        let slotStyle = '';
        if (cgRow.layout_ref === 'single') {
          slotStyle = hasVertical ? 'writing-mode:vertical-rl' : '';
        } else if (colIdx !== undefined) {
          slotStyle = 'grid-column:' + (colIdx + 1);
          if (hasVertical) slotStyle += ';writing-mode:vertical-rl';
        }
        cgHtml += '<div class="' + escapeAttr(slotId.replace(/_/g, '-')) + '"'
          + (slotStyle ? ' style="' + slotStyle + '"' : '')
          + (slotAttr ? ' ' + slotAttr : '') + '>'
          + (content || '') + '</div>';
      }
    }

    cgHtml += '</div>';
    bodyHtml = cgHtml;
    contentIsSlots = false;
  }

  // ---- 组装卡片：顶栏 + 主体(含侧栏) ----
  const showHeader = headerDeco !== 'none' || !!headerText;
  const showSide   = sideAccent !== 'none' || !!sideText;

  let html = '<a class="gallery-card"' + dataAttrs
    + ' style="' + paletteStyle + '"'
    + ' href="diary.html?date=' + escapeAttr(dateRaw) + '" target="_blank"'
    + ' title="' + escapeAttr(d.title || '') + '"'
    + ' data-id="' + escapeAttr(String(id)) + '"'
    + '>';

  // 顶栏装饰条
  let headerBandHtml = '';
  if (showHeader) {
    const headerTextStyle = buildTextStyle(headerTextFamily, headerTextSize, headerTextAlign, true);
    headerBandHtml = '<div class="card-header-band' + (headerText ? ' card-header-band--has-text' : '') + '">';
    if (headerText) headerBandHtml += '<span class="card-header-text"'
      + (headerTextStyle ? ' style="' + headerTextStyle + '"' : '')
      + (headerTextFamily ? ' data-style-typo-font-family-headertext="' + escapeAttr(headerTextFamily) + '"' : '')
      + '>'
      + escapeHtml(headerText) + '</span>';
    headerBandHtml += '</div>';
  }

  const contentHtml = '<div class="card-content' + (contentIsSlots ? ' card-content--slots' : '') + '">'
    + bodyHtml + '</div>';

  // 侧栏竖排文字（对齐语义：沿侧栏纵向位置；兼容旧数据 left/right → top/bottom）
  let sideHtml = '';
  if (showSide) {
    let sideAlign = sideTextAlign;
    if (sideAlign === 'left')  sideAlign = 'top';
    if (sideAlign === 'right') sideAlign = 'bottom';
    let sideBandAlignStyle = '';
    if (sideText && sideAlign) {
      if (sideAlign === 'top')         sideBandAlignStyle = 'justify-content:flex-start;';
      else if (sideAlign === 'bottom') sideBandAlignStyle = 'justify-content:flex-end;';
    }
    const sideTextStyle = buildTextStyle(sideTextFamily, sideTextSize, sideAlign, false);
    const sideInner = sideText
      ? '<span class="card-side-text"'
        + (sideTextStyle ? ' style="' + sideTextStyle + '"' : '')
        + (sideTextFamily ? ' data-style-typo-font-family-sidetext="' + escapeAttr(sideTextFamily) + '"' : '') + '>'
        + escapeHtml(sideText) + '</span>'
      : '';
    sideHtml = '<div class="card-side-band card-side-band-' + sidePosition
      + (sideText ? ' card-side-band--has-text' : '') + '"'
      + (sideBandAlignStyle ? ' style="' + sideBandAlignStyle + '"' : '') + '">' + sideInner + '</div>';
  }

  // 卡片主体
  let cardMainHtml = showSide
    ? (sidePosition === 'right'
        ? '<div class="card-main">' + contentHtml + sideHtml + '</div>'
        : '<div class="card-main">' + sideHtml + contentHtml + '</div>')
    : '<div class="card-main">' + contentHtml + '</div>';

  // 全局盒子（target='global'）：嵌套包裹「整个卡片内容(含顶栏+主体)」恢复整卡生效语义；
  // 仅在确有 global 盒子时插入包裹层，避免无盒时改变 DOM/布局。
  let cardInner = headerBandHtml + cardMainHtml;
  const globalBoxes = boxObjsFor('global');
  if (globalBoxes.length) {
    for (let i = globalBoxes.length - 1; i >= 0; i--) {
      const b = globalBoxes[i];
      const pad = (b.coincide === true) ? 'padding:0;' : 'padding: var(--box-gap, 12px);';
      cardInner = '<div class="fx-wrap gx-global" data-style-deco-box="' + escapeAttr(b.style) + '" style="border-radius: var(--deco-radius, 8px); ' + pad + '">' + cardInner + '</div>';
    }
  }
  html += cardInner;

  html += '</a>';
  return html;
}

// ============================================================
// Section 9: renderStyleJson — 主渲染入口
// ============================================================

/**
 * @param {Object} styleJson — 七维度样式配置
 * @param {Object} diary — { id, title, date, dateRaw, highlights, capsuleName }
 * @param {Object} allOptions — { palette, layout, typo, border, deco, effect, element, container_group }
 * @returns {string} 完整 <a class="gallery-card">...</a> HTML
 */
export function renderStyleJson(styleJson, diary, allOptions) {
  const sj = styleJson || DEFAULT_STYLE_JSON;

  // 1. 解析色板颜色
  const paletteOptions = (allOptions && allOptions.palette) || [];
  const colors = resolvePaletteColors(sj.palette, paletteOptions);

  // 2. 构建 inline 样式（CSS变量 + 直接属性，确保无css_template时也能显示）
  const paletteCssVars = [
    '--card-bg:'     + colors.bg,
    '--card-text:'   + colors.text,
    '--card-accent:' + colors.accent,
    '--card-muted:'  + colors.muted
  ];
  // extra_colors
  if (colors.extra_colors) {
    for (const [k, v] of Object.entries(colors.extra_colors)) {
      paletteCssVars.push('--card-' + k + ':' + v);
    }
  }
  paletteCssVars.push('--card-accent-rgb:' + colors.accentRgb,
    '--card-bg-rgb:' + colors.bgRgb);

  // 装饰条粗细（解耦于外观名，由前端 width 参数 + DB 模板共同决定）
  const elBand = sj.element || {};
  const parsePx = (v, fb) => {
    const n = (typeof v === 'number') ? v : parseInt(v, 10);
    return (isNaN(n) || n <= 0) ? fb : n;
  };
  paletteCssVars.push(
    '--header-band-size:' + parsePx(elBand.header_width, 6) + 'px',
    '--side-band-size:' + parsePx(elBand.side_width, 8) + 'px'
  );

  // ---- 间距模型 v3：色条满边(通长) + density 仅作用于内容 ----
  // · 色条(band)默认【满边/通长】：覆盖 density-pad 区域，两端不再留空。
  //   band_inset 勾选框控制色条离卡片边缘的内缩量：取消=0(贴边满边) / 勾选=12px(内缩留白)。
  //   色条元素只在存在时才渲染，因此无需在 JS 区分是否有色条——内缩边距由 CSS 作用在色条元素自身上。
  // · 内容区(.card-content)四边统一 = --density-pad（由 DB 密度模板提供，缺省 12px）：
  //   既作为"无色条卡片↔边缘"的呼吸间距，也作为"色条↔内容"的间距。density 完全不被色条吞掉。
  // · --density-pad 由 layout 维度 density 模板写入 .gallery-card，内容区继承；此处仅负责 --band-inset。
  const bandInset = elBand.band_inset === false ? false : true;
  const bi = bandInset ? '12px' : '0px';
  paletteCssVars.push('--band-inset:' + bi);
  // Deco Box 统一半径：所有 box 包裹层用同一半径，消除方/圆混叠产生的角部 sliver/bite 瑕疵
  const decoRadius = (sj.deco && typeof sj.deco.box_radius === 'number') ? sj.deco.box_radius : 8;
  paletteCssVars.push('--deco-radius:' + decoRadius + 'px');
  // Deco Box 统一盒间距：嵌套时所有 box 包裹层用同一间距(覆盖各 box 自身 DB padding)，重合时归零。
  const decoGap = (sj.deco && typeof sj.deco.box_gap === 'number') ? sj.deco.box_gap : 12;
  paletteCssVars.push('--box-gap:' + decoGap + 'px');
  // 全局 box 存在时，把卡片外框圆角同步为 --deco-radius(=最外层全局 box 圆角)，
  // 消除「卡片方 / box 圆」或反过来的错位(卡片 overflow:hidden 会裁切不匹配的夹角)。
  const hasGlobalBox = Array.isArray(sj.deco && sj.deco.boxes)
    && sj.deco.boxes.some(b => b && b.style && b.style !== 'none' && b.target === 'global');
  if (hasGlobalBox) paletteCssVars.push('border-radius: var(--deco-radius, 8px)');
  // 注：--density-pad 来自 DB density css_template（.gallery-card[data-style-layout-density]）。
  //     若 DB 未配置则回退 12px（见 BASE_CSS 中 var(--density-pad, 12px)）。

  // 3. 计算 per-slot writing-mode (从 flow_vertical + slot_assignment)
  const layout = sj.layout || {};
  const slotAssignment = layout.slot_assignment
    || { a: 'date', b: 'title', c: 'highlights', d: 'capsule' };
  const verticalFields = Array.isArray(layout.flow_vertical) ? layout.flow_vertical : [];

  for (const slot of ['a', 'b', 'c', 'd']) {
    const field = slotAssignment[slot];
    if (field && verticalFields.includes(field)) {
      paletteCssVars.push('--wm-' + slot + ':vertical-rl');
    }
  }
  // 全部竖排时，容器加 writing-mode:vertical-rl 转置 grid
  if (verticalFields.length >= 4) {
    paletteCssVars.push('writing-mode:vertical-rl', 'max-height:400px', 'overflow:hidden');
  }
  const fullStyle = paletteCssVars.join(';');

  // 4. 构建 data-* 属性
  const dataAttrs = buildDataAttrs(sj);

  // 5. 构建 HTML
  return buildCardHtml(sj, diary, dataAttrs, fullStyle, allOptions, verticalFields);
}

// ============================================================
// Section 10: injectBaseCss — 注入 BASE_CSS
// ============================================================

/**
 * 将 BASE_CSS 注入 <head>，id="card-engine-css"
 * 幂等：已注入则跳过
 */
export function injectBaseCss() {
  if (typeof document === 'undefined') return;
  if (document.getElementById('card-engine-css')) return;
  const styleEl = document.createElement('style');
  styleEl.id = 'card-engine-css';
  styleEl.textContent = BASE_CSS;
  document.head.appendChild(styleEl);
}

// ============================================================
// Section 11: injectDynamicStyles — 注入 DB css_template
// ============================================================

/**
 * 从 DB 维度选项表的 css_template 字段收集 CSS 并注入
 * @param {Object} allOptions — 各维度表行数组，含 container_group.extra_css
 */
export function injectDynamicStyles(allOptions) {
  if (typeof document === 'undefined') return;
  if (!allOptions) return;

  let css = '';

  const collect = (rows) => {
    if (!Array.isArray(rows)) return;
    rows.forEach(r => {
      if (!r) return;
      const cssText = r.css_template || r.extra_css;
      if (cssText && cssText.trim()) {
        css += cssText.trim() + '\n';
      }
    });
  };

  // 七张核心表
  collect(allOptions.palette);
  collect(allOptions.layout);
  collect(allOptions.typo);
  collect(allOptions.border);
  collect(allOptions.deco);
  collect(allOptions.effect);
  collect(allOptions.element);

  // container_group
  if (allOptions.container_group) {
    collect(allOptions.container_group);
  }

  if (!css) return;

  let styleEl = document.getElementById('card-engine-dynamic-css');
  if (styleEl) {
    styleEl.textContent = css;
  } else {
    styleEl = document.createElement('style');
    styleEl.id = 'card-engine-dynamic-css';
    document.head.appendChild(styleEl);
    styleEl.textContent = css;
  }
}
