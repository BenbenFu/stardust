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

const BASE_CSS = `/* style-engine v2.0 — base structural CSS */
.gallery-card {
  display: grid; position: relative; overflow: hidden;
  break-inside: avoid; margin-bottom: 16px;
  cursor: pointer; text-decoration: none;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  grid-template-areas: "date" "title" "highlights" "capsule";
}
.card-date   { grid-area: date; }
.card-title  { grid-area: title; word-break: break-word; }
.card-highlights { grid-area: highlights; }
.card-highlight-item { display: block; }
.card-capsule { grid-area: capsule; }
.hl-sep { display: inline; }
.cg-slot { display: block; }

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
  'deco_box_style':      { attr: 'data-style-deco-box' },
  'deco_action_style':   { attr: 'data-style-deco-action' },
  // element
  'element_header_deco': { attr: 'data-style-element-header' },
  'element_side_accent': { attr: 'data-style-element-side' },
  'element_divider':     { attr: 'data-style-element-divider' },
  'element_corner_badge':{ attr: 'data-style-element-corner' },
  'element_bg_pattern':  { attr: 'data-style-element-bg' },
  'element_edge_deco':   { attr: 'data-style-element-edge' },
  'element_floating_deco':{ attr: 'data-style-element-float' },
  // effect (filter_self & filter_backdrop share same attr, backdrop priority)
  'effect_filter_self':     { attr: 'data-style-effect-filter' },
  'effect_filter_backdrop': { attr: 'data-style-effect-filter' },
  'effect_transform':   { attr: 'data-style-effect-transform' },
  'effect_animation':   { attr: 'data-style-effect-animation' },
  // typo — per-element sub_dims
  'typo_font_family':       { attr: 'data-style-typo-font-family', perElement: true,
    elements: ['title','date','capsule','highlights'] },
  'typo_weight_gradient':   { attr: 'data-style-typo-weight-gradient' },
  'typo_size_scale':        { attr: 'data-style-typo-size-scale' },
  'typo_alignment_mode':    { attr: 'data-style-typo-alignment-mode' },
  'typo_spacing_tightness': { attr: 'data-style-typo-spacing-tightness', perElement: true,
    elements: ['title','date','capsule','highlights'] },
  'typo_text_decoration':   { attr: 'data-style-typo-text-decoration', perElement: true,
    elements: ['title','date','capsule','highlights'] },
};

// ============================================================
// Section 3: DEFAULT_STYLE_JSON — 全默认值
// ============================================================

export const DEFAULT_STYLE_JSON = {
  palette: { harmony: 'neutral_grey', tone: 'light_standard', slot: 'original' },
  layout: { grid: 'single', flow: 'vertical', density: 'normal',
    block_align: 'left', inline_align: 'left', spacing_scale: 'standard' },
  typo: {
    font_family: { title:'system_sans', date:'system_sans', capsule:'system_sans', highlights:'system_sans' },
    weight_gradient: 'balanced', size_scale: 'balanced_read', alignment_mode: 'left_flow',
    spacing_tightness: { title:'normal', date:'normal', capsule:'normal', highlights:'normal' },
    text_decoration: { title:'none', date:'none', capsule:'none', highlights:'none' }
  },
  border: { radius_size:'none', border_width:'none', border_style:'solid', border_shadow:'none' },
  deco: { bubble_style:'none', tag_style:'none', avatar_style:'none', box_style:'none', action_style:'none' },
  element: { header_deco:'none', side_accent:'none', divider:'none', corner_badge:'none',
    bg_pattern:'none', edge_deco:'none', floating_deco:'none' },
  effect: { filter_self:'none', filter_backdrop:'none', transform:'none', animation:'none' },
  container_group: 'none'
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

  // 精确匹配 option_key === harmony
  let row = paletteOptions.find(r => r.option_key === harmony);
  // 回退：option_key 包含 harmony
  if (!row) {
    row = paletteOptions.find(r => {
      const k = r.option_key || '';
      return k.includes(harmony) && (!tone || k.includes(tone)) && (!slot || k.includes(slot));
    });
  }
  if (!row) return defaultColors();

  // 解析 option_value
  let colors;
  try {
    colors = typeof row.option_value === 'string'
      ? JSON.parse(row.option_value)
      : (row.option_value || {});
  } catch { return defaultColors(); }

  const bg     = colors.bg     || '#ffffff';
  const text   = colors.text   || '#1a1a1a';
  const accent = colors.accent || '#3b82f6';
  const muted  = colors.muted  || '#e5e5e5';
  const extra  = colors.extra_colors || {};

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
  const hasBackdrop = styleJson.effect
    && styleJson.effect.filter_backdrop
    && styleJson.effect.filter_backdrop !== 'none';

  // palette: 生成 data-style-palette="harmony_value" 属性
  if (styleJson.palette && styleJson.palette.harmony) {
    attrs['data-style-palette'] = escapeAttr(styleJson.palette.harmony);
  }

  for (const [dim, subDims] of Object.entries(styleJson)) {
    if (dim === 'palette' || dim === 'container_group') continue;
    if (!subDims || typeof subDims !== 'object') continue;

    for (const [subDim, value] of Object.entries(subDims)) {
      if (value == null || value === 'none') continue;

      const mapKey = dim + '_' + subDim;
      const mapping = ATTR_MAP[mapKey];
      if (!mapping) continue;

      // filter_self: backdrop 优先，self 仅在不设 backdrop 时生效
      if (dim === 'effect' && subDim === 'filter_self' && hasBackdrop) continue;

      if (mapping.perElement && typeof value === 'object') {
        for (const el of mapping.elements) {
          const elVal = value[el];
          if (elVal == null || elVal === 'none') continue;
          attrs[mapping.attr + '-' + el] = escapeAttr(elVal);
        }
      } else {
        attrs[mapping.attr] = escapeAttr(String(value));
      }
    }
  }

  const parts = Object.entries(attrs).map(([k, v]) => k + '="' + v + '"');
  return parts.length ? ' ' + parts.join(' ') : '';
}

// ============================================================
// Section 7: buildHighlightsHtml — 渲染 highlights 列表
// ============================================================

function buildHighlightsHtml(highlights) {
  if (!highlights || !highlights.length) return '';
  let h = '<div class="card-highlights">';
  for (let i = 0; i < highlights.length; i++) {
    h += '<div class="card-highlight-item">' + escapeHtml(highlights[i]);
    if (i < highlights.length - 1) {
      h += '<span class="hl-sep" data-sep="pipe"></span>';
    }
    h += '</div>';
  }
  h += '</div>';
  return h;
}

// ============================================================
// Section 8: buildCardHtml — 构建卡片 HTML
// 两种模式：container_group="none" 标准grid / 其他值嵌套slot
// ============================================================

function buildCardHtml(styleJson, diary, dataAttrs, paletteStyle, allOptions) {
  const d = diary || {};
  const date = escapeHtml(d.date || '----/--/--');
  const title = escapeHtml(d.title || '');
  const capsule = escapeHtml(d.capsuleName || '');
  const highlights = d.highlights || [];
  const dateRaw = d.dateRaw || '';
  const id = d.id || '';

  const containerGroup = (styleJson && styleJson.container_group) || 'none';

  if (containerGroup === 'none') {
    // --- 标准 grid 模式 ---
    let html = '<a class="gallery-card"' + dataAttrs
      + ' style="' + paletteStyle + '"'
      + ' href="diary.html?date=' + escapeAttr(dateRaw) + '" target="_blank"'
      + ' title="' + escapeAttr(d.title || '') + '"'
      + ' data-id="' + escapeAttr(String(id)) + '"'
      + '>';
    if (date)       html += '<div class="card-date">' + date + '</div>';
    if (title)      html += '<div class="card-title">' + title + '</div>';
    if (highlights.length) html += buildHighlightsHtml(highlights);
    if (capsule)    html += '<div class="card-capsule">' + capsule + '</div>';
    html += '</a>';
    return html;
  }

  // --- container_group 嵌套 slot 模式 ---
  const cgOptions = (allOptions && allOptions.container_group) || [];
  const cgRow = cgOptions.find(r => r.option_key === containerGroup);
  if (!cgRow) {
    // 回退标准模式
    return buildCardHtml(
      { ...styleJson, container_group: 'none' }, diary, dataAttrs, paletteStyle, allOptions
    );
  }

  // 解析 slot 映射
  let fieldSlotMap = {}, slotDecoMap = {}, layoutSlotMap = {};
  try {
    fieldSlotMap  = typeof cgRow.field_slot_map  === 'string' ? JSON.parse(cgRow.field_slot_map)  : (cgRow.field_slot_map  || {});
    slotDecoMap   = typeof cgRow.slot_deco_map   === 'string' ? JSON.parse(cgRow.slot_deco_map)   : (cgRow.slot_deco_map   || {});
    layoutSlotMap = typeof cgRow.layout_slot_map === 'string' ? JSON.parse(cgRow.layout_slot_map) : (cgRow.layout_slot_map || {});
  } catch { /* 回退 */ }

  if (!Object.keys(fieldSlotMap).length) {
    return buildCardHtml(
      { ...styleJson, container_group: 'none' }, diary, dataAttrs, paletteStyle, allOptions
    );
  }

  // 分组字段到 slot
  const slotFields = {};
  for (const [field, slotId] of Object.entries(fieldSlotMap)) {
    if (!slotFields[slotId]) slotFields[slotId] = [];
    slotFields[slotId].push(field);
  }

  // 单字段 HTML
  const fieldHtml = (field) => {
    switch (field) {
      case 'date': return date ? '<div class="card-date">' + date + '</div>' : '';
      case 'title': return title ? '<div class="card-title">' + title + '</div>' : '';
      case 'highlights': return buildHighlightsHtml(highlights);
      case 'capsule': return capsule ? '<div class="card-capsule">' + capsule + '</div>' : '';
      default: return '';
    }
  };

  // slot 排序
  const slotOrder = Object.keys(layoutSlotMap).length
    ? Object.keys(layoutSlotMap)
    : Object.keys(slotFields);

  let html = '<a class="gallery-card"' + dataAttrs
    + ' style="' + paletteStyle + '"'
    + ' href="diary.html?date=' + escapeAttr(dateRaw) + '" target="_blank"'
    + ' title="' + escapeAttr(d.title || '') + '"'
    + ' data-id="' + escapeAttr(String(id)) + '"'
    + '>';

  for (const slotId of slotOrder) {
    const deco = slotDecoMap[slotId] || {};
    const slotAttr = Object.entries(deco)
      .map(([k, v]) => 'data-style-deco-' + k + '="' + escapeAttr(v) + '"')
      .join(' ');
    const area = layoutSlotMap[slotId] || slotId;
    const content = (slotFields[slotId] || []).map(fieldHtml).filter(Boolean).join('');

    if (content) {
      html += '<div class="cg-slot" style="grid-area:' + area + '"'
        + (slotAttr ? ' ' + slotAttr : '') + '>' + content + '</div>';
    }
  }
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

  // 2. 构建 inline 样式（CSS 变量）
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
  const paletteStyle = paletteCssVars.join(';');

  // 3. 构建 data-* 属性
  const dataAttrs = buildDataAttrs(sj);

  // 4. 构建 HTML
  return buildCardHtml(sj, diary, dataAttrs, paletteStyle, allOptions);
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
      if (r && r.css_template && r.css_template.trim()) {
        css += r.css_template.trim() + '\n';
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

  // container_group.extra_css
  if (allOptions.container_group) {
    collect(allOptions.container_group);
    // 也会收集 container_group 行自身的 css_template
  }

  if (!css) return;

  // 行级去重
  const lines = css.split('\n');
  const seen = new Set();
  const deduped = [];
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed && !seen.has(trimmed)) {
      seen.add(trimmed);
      deduped.push(line);
    }
  }
  css = deduped.join('\n');

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
