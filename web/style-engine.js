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

const BASE_CSS = `/* style-engine v2.1 — slot skeleton base CSS */
.gallery-card {
  display: grid; position: relative; overflow: hidden;
  break-inside: avoid; margin-bottom: var(--spacing-md, 16px);
  gap: var(--layout-gap, var(--spacing-sm, 8px));
  cursor: pointer; text-decoration: none;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
  grid-template-areas: "slot-a" "slot-b" "slot-c" "slot-d";
}
.card-slot-a { grid-area: slot-a; writing-mode: var(--wm-a, horizontal-tb); }
.card-slot-b { grid-area: slot-b; writing-mode: var(--wm-b, horizontal-tb); }
.card-slot-c { grid-area: slot-c; writing-mode: var(--wm-c, horizontal-tb); }
.card-slot-d { grid-area: slot-d; writing-mode: var(--wm-d, horizontal-tb); }
.card-date   { color: var(--card-muted, inherit); }
.card-title  { word-break: break-word; overflow-wrap: break-word; }
.card-highlights { overflow-wrap: break-word; word-break: break-word; }
.card-highlight-item { display: block; }
.card-capsule { color: var(--card-accent, inherit); }
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
  palette: { harmony: 'mono_grey', tone: 'light_standard', slot: 'original' },
  layout: { grid: 'single', flow: 'horizontal', flow_vertical: [],
    slot_assignment: { a: 'date', b: 'title', c: 'highlights', d: 'capsule' },
    density: 'normal',
    block_align: 'left', inline_align: 'left', spacing_scale: 'md' },
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

  const containerGroup = (styleJson && styleJson.container_group) || 'none';

  if (containerGroup === 'none') {
    // --- slot skeleton 模式 ---
    const slotAssignment = (styleJson && styleJson.layout && styleJson.layout.slot_assignment)
      || { a: 'date', b: 'title', c: 'highlights', d: 'capsule' };

    // 字段内容 (不含外层 div)
    const fieldContent = {
      date: date || '',
      title: title || '',
      highlights: highlights.length ? buildHighlightsInner(highlights) : '',
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
      slotHtml += '<div class="card-slot-' + slot + ' ' + fieldClass[field] + '">'
        + fieldContent[field] + '</div>';
    }

    let html = '<a class="gallery-card"' + dataAttrs
      + ' style="' + paletteStyle + '"'
      + ' href="diary.html?date=' + escapeAttr(dateRaw) + '" target="_blank"'
      + ' title="' + escapeAttr(d.title || '') + '"'
      + ' data-id="' + escapeAttr(String(id)) + '"'
      + '>' + slotHtml + '</a>';
    return html;
  }

  // --- container_group 嵌套 slot 模式 ---
  const cgOptions = (allOptions && allOptions.container_group) || [];
  const cgRow = cgOptions.find(r => r.option_key === containerGroup);
  if (!cgRow) {
    // 回退标准模式
    return buildCardHtml(
      { ...styleJson, container_group: 'none' }, diary, dataAttrs, paletteStyle, allOptions, verticalFields
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
      { ...styleJson, container_group: 'none' }, diary, dataAttrs, paletteStyle, allOptions, verticalFields
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
      const fieldsInSlot = slotFields[slotId] || [];
      const hasVertical = verticalFields && verticalFields.length
        && fieldsInSlot.some(f => verticalFields.includes(f));
      let slotStyle = 'grid-area:' + area;
      if (hasVertical) slotStyle += ';writing-mode:vertical-rl';
      html += '<div class="cg-slot" style="' + slotStyle + '"'
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

  // 2. 构建 inline 样式（CSS变量 + 直接属性，确保无css_template时也能显示）
  const paletteCssVars = [
    'background:' + colors.bg,
    'color:' + colors.text,
    'border-color:' + colors.accent,
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

  // container_group
  if (allOptions.container_group) {
    collect(allOptions.container_group);
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
