/**
 * palette-engine.js
 * 配色算法库 v1.0 — 独立于渲染器，纯函数
 *
 * 支持 6 种 harmony_mode：
 *   monochromatic / analogous / complementary / split / triadic / tetradic
 *
 * 对外主函数：generatePalette(seedHex, themeMode, harmonyMode, options)
 * 返回：{ bg, text, accent, muted, extra_colors }
 *
 * 依赖：无（纯 JS，不引入任何库）
 */

// ============================================================
// 底层：HSL ↔ Hex 转换
// ============================================================

/**
 * Hex → { h, s, l }   (h: 0-360, s: 0-100, l: 0-100)
 */
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

/**
 * { h, s, l } → "#RRGGBB"
 */
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

// ============================================================
// Ant Design 色阶算法（单色系核心）
// ============================================================

/**
 * 根据 Ant Design 4 色阶算法，从主色 seedHex 生成 10 级色阶
 * 返回数组 index 0-9（0 最浅，9 最深）
 * 参考：@ant-design/colors 开源实现
 */
function generateAntScale(seedHex) {
  const hsl = hexToHSL(seedHex);
  const { h, s, l } = hsl;

  // Ant Design 色阶：在固定明度/饱和度曲线上采样
  // 简化版：直接按 Ant Design 标准明度梯度计算
  const lightnessSteps = [95, 85, 75, 65, 55, 45, 35, 25, 18, 12];
  const saturationAdj = s > 50
    ? [20, 30, 45, 60, 80, 100, 110, 120, 130, 140]
    : [30, 40, 55, 70, 85, 100, 110, 120, 130, 135];

  return lightnessSteps.map((lightness, i) => {
    const sat = Math.min(100, Math.max(6, Math.round(s * saturationAdj[i] / 100)));
    return hslToHex(h, sat, lightness);
  });
}

// ============================================================
// 对比度计算（WCAG AA）
// ============================================================

function hexToLuminance(hex) {
  hex = hex.replace('#', '');
  if (hex.length === 3) {
    hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
  }
  const r = parseInt(hex.substring(0, 2), 16) / 255;
  const g = parseInt(hex.substring(2, 4), 16) / 255;
  const b = parseInt(hex.substring(4, 6), 16) / 255;
  const toLinear = c => c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  return 0.2126 * toLinear(r) + 0.7152 * toLinear(g) + 0.0722 * toLinear(b);
}

function contrastRatio(hex1, hex2) {
  const l1 = hexToLuminance(hex1);
  const l2 = hexToLuminance(hex2);
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

/**
 * 确保 text 在 bg 上有 ≥ 4.5:1 对比度
 * 通过调整 text 明度实现
 */
function ensureContrast(textHex, bgHex, minRatio = 4.5) {
  if (contrastRatio(textHex, bgHex) >= minRatio) return textHex;
  const bgL = hexToLuminance(bgHex);
  const hsl = hexToHSL(textHex);
  if (bgL > 0.4) {
    // 浅底，调暗文字
    for (let l = hsl.l; l >= 8; l -= 4) {
      const candidate = hslToHex(hsl.h, hsl.s, l);
      if (contrastRatio(candidate, bgHex) >= minRatio) return candidate;
    }
    return '#000000';
  } else {
    // 深底，调亮文字
    for (let l = hsl.l; l <= 92; l += 4) {
      const candidate = hslToHex(hsl.h, hsl.s, l);
      if (contrastRatio(candidate, bgHex) >= minRatio) return candidate;
    }
    return '#FFFFFF';
  }
}

// ============================================================
// 主算法：按 harmony_mode 生成完整配色方案
// ============================================================

/**
 * 主函数：生成完整四色 + extra_colors
 *
 * bg/text 色阶规则（避开 0-2 最浅和 9 最深的极端值）：
 *   light: bg=scale[3](浅带色相), text=scale[8](深)
 *   dark:  bg=scale[7](深带色相), text=scale[2](浅)
 *   accent 始终用 scale[5]（标准强调色）
 *   muted:  light=scale[4], dark=scale[6]
 *
 * @param {string} seedAccent  - 主色种子 "#RRGGBB"
 * @param {string} themeMode   - 'light' | 'dark'
 * @param {string} harmonyMode - 'monochromatic'|'analogous'|'complementary'|'split'|'triadic'|'tetradic'
 * @param {object} [options]
 *   - bgCustom: 手动指定 bg（覆盖算法）
 *   - textCustom: 手动指定 text（覆盖算法）
 *   - accentCustom: 手动指定 accent（覆盖算法）
 * @returns {{ bg, text, accent, muted, extra_colors }}
 */
function generatePalette(seedAccent, themeMode, harmonyMode, options = {}) {
  const seed = hexToHSL(seedAccent);
  const isDark = themeMode === 'dark';

  let result = { bg: null, text: null, accent: seedAccent, muted: null, extra_colors: {} };

  // 公共：从 Ant Scale 取固定色阶
  function pickFromScale(scale) {
    if (isDark) {
      return {
        bg:    options.bgCustom     || scale[7],
        text:   options.textCustom   || ensureContrast(scale[2], scale[7]),
        accent: options.accentCustom || scale[5],
        muted:  scale[6],
        extra: {
          bg_secondary: scale[8],
          accent_2: scale[4],
          accent_3: scale[3]
        }
      };
    } else {
      return {
        bg:    options.bgCustom     || scale[3],
        text:   options.textCustom   || ensureContrast(scale[8], scale[3]),
        accent: options.accentCustom || scale[5],
        muted:  scale[4],
        extra: {
          bg_secondary: scale[2],
          accent_2: scale[6],
          accent_3: scale[7]
        }
      };
    }
  }

  // ---------- monochromatic ----------
  if (harmonyMode === 'monochromatic') {
    const scale = generateAntScale(seedAccent);
    const picked = pickFromScale(scale);
    Object.assign(result, picked);
    result.extra_colors = picked.extra;
  }

  // ---------- analogous ----------
  else if (harmonyMode === 'analogous') {
    // 用 seed 的色相生成带色相的 bg（不是全白/全黑）
    const baseScale = generateAntScale(seedAccent);
    const c1 = hslToHex(seed.h - 30, seed.s, seed.l);  // 邻近色 1
    const c3 = hslToHex(seed.h + 30, seed.s, seed.l);  // 邻近色 2

    const picked = pickFromScale(baseScale);
    Object.assign(result, picked);
    result.muted = c1;
    result.extra_colors = {
      ...picked.extra,
      color_1: c1,
      color_2: c3
    };
  }

  // ---------- complementary ----------
  else if (harmonyMode === 'complementary') {
    const comp = rotateHue(seed, 180);
    const compHex = hslToHex(comp.h, comp.s, comp.l);
    // 用互补色中较浅的那个生成背景色阶
    const bgSeed = isDark ? seedAccent : compHex;
    const bgScale = generateAntScale(bgSeed);
    const picked = pickFromScale(bgScale);
    Object.assign(result, picked);
    result.accent = seedAccent;
    result.extra_colors = {
      ...picked.extra,
      complement: compHex
    };
  }

  // ---------- split complementary ----------
  else if (harmonyMode === 'split') {
    const s1 = rotateHue(seed, 150);
    const s2 = rotateHue(seed, 210);
    const s1Hex = hslToHex(s1.h, s1.s, s1.l);
    const s2Hex = hslToHex(s2.h, s2.s, s2.l);

    const bgScale = generateAntScale(seedAccent);
    const picked = pickFromScale(bgScale);
    Object.assign(result, picked);
    result.extra_colors = {
      ...picked.extra,
      color_1: s1Hex,
      color_2: s2Hex
    };
  }

  // ---------- triadic ----------
  else if (harmonyMode === 'triadic') {
    const t1 = rotateHue(seed, 120);
    const t2 = rotateHue(seed, 240);
    const t1Hex = hslToHex(t1.h, t1.s, t1.l);
    const t2Hex = hslToHex(t2.h, t2.s, t2.l);

    const bgScale = generateAntScale(seedAccent);
    const picked = pickFromScale(bgScale);
    Object.assign(result, picked);
    result.extra_colors = {
      ...picked.extra,
      color_1: t1Hex,
      color_2: t2Hex
    };
  }

  // ---------- tetradic ----------
  else if (harmonyMode === 'tetradic') {
    const t1 = rotateHue(seed, 90);
    const t2 = rotateHue(seed, 180);
    const t3 = rotateHue(seed, 270);
    const t1Hex = hslToHex(t1.h, t1.s, t1.l);
    const t2Hex = hslToHex(t2.h, t2.s, t2.l);
    const t3Hex = hslToHex(t3.h, t3.s, t3.l);

    const bgScale = generateAntScale(seedAccent);
    const picked = pickFromScale(bgScale);
    Object.assign(result, picked);
    result.extra_colors = {
      ...picked.extra,
      color_1: t1Hex,
      color_2: t2Hex,
      color_3: t3Hex
    };
  }

  // 最终对比度校验
  result.text   = ensureContrast(result.text,   result.bg);
  result.accent = ensureContrast(result.accent, result.bg, 3);
  result.muted  = ensureContrast(result.muted,  result.bg, 3);

  return result;
}

// ============================================================
// resolvePaletteFromDB — 从 DB 静态色板选项解析颜色
// ============================================================

/**
 * 从 style_palette_options 表数据中查找匹配的色板并返回颜色
 * @param {Object} paletteConfig — { harmony, tone, slot }
 * @param {Array}  paletteOptions — style_palette_options 全表行数组
 * @returns {{ bg, text, accent, muted, extra_colors, accentRgb, bgRgb }}
 */
export function resolvePaletteFromDB(paletteConfig, paletteOptions) {
  const defaultColors = () => ({
    bg: '#ffffff', text: '#1a1a1a', accent: '#3b82f6', muted: '#e5e5e5',
    extra_colors: {}, accentRgb: '59,130,246', bgRgb: '255,255,255'
  });

  if (!paletteConfig || !paletteOptions || !paletteOptions.length) return defaultColors();

  const { harmony, tone, slot } = paletteConfig;
  if (!harmony) return defaultColors();

  // 精确匹配 option_key === harmony
  let row = paletteOptions.find(r => r.option_key === harmony);
  // 回退：option_key 包含 harmony + tone + slot
  if (!row) {
    row = paletteOptions.find(r => {
      const k = r.option_key || '';
      return k.includes(harmony) && (!tone || k.includes(tone)) && (!slot || k.includes(slot));
    });
  }
  if (!row) return defaultColors();

  // 解析 option_value JSON
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

  // hex → rgb 辅助
  const hexToRgb = (hex) => {
    hex = hex.replace('#', '');
    if (hex.length === 3) hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
    const r = parseInt(hex.substring(0,2), 16);
    const g = parseInt(hex.substring(2,4), 16);
    const b = parseInt(hex.substring(4,6), 16);
    if (isNaN(r) || isNaN(g) || isNaN(b)) return '128,128,128';
    return r + ',' + g + ',' + b;
  };

  return {
    bg, text, accent, muted,
    extra_colors: extra,
    accentRgb: hexToRgb(accent),
    bgRgb: hexToRgb(bg)
  };
}

// ============================================================
// ES Module 导出
// ============================================================
export { hexToHSL, hslToHex, generateAntScale, contrastRatio, ensureContrast, generatePalette, resolvePaletteFromDB };
