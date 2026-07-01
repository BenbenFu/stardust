// analyze_v2_palettes.js
// 将 v2 的 32 个色板拆成 harmony_palette（归一化到第5阶的 hex）+
// tone_mapping（各槽色阶号），并生成 v3 迁移 SQL

const fs = require('fs');
const path = require('path');

// ============ Ant Design 色阶生成（与 palette-engine.js 一致） ============
function generateAntScale(seedHex) {
  const hex = seedHex.replace('#', '');
  const r = parseInt(hex.substring(0, 2), 16) / 255;
  const g = parseInt(hex.substring(2, 4), 16) / 255;
  const b = parseInt(hex.substring(4, 6), 16) / 255;

  const hsl = rgbToHsl(r, g, b);
  const baseH = hsl.h;
  const baseS = hsl.s;
  const baseL = hsl.l;

  const steps = [];
  for (let i = 1; i <= 10; i++) {
    const t = (i - 1) / 9;
    const targetL = lerp(0.95, 0.05, t);
    const lShift = (baseL - targetL) * 0.85;
    let newL = baseL - lShift;
    newL = Math.max(0.03, Math.min(0.97, newL));
    const sFactor = 1 - Math.abs(t - 0.5) * 0.25;
    let newS = baseS * sFactor;
    newS = Math.max(0.06, Math.min(1.0, newS));
    steps.push(hslToRgb(baseH, newS, newL));
  }
  return steps;
}

function rgbToHsl(r, g, b) {
  const max = Math.max(r, g, b), min = Math.min(r, g, b);
  let h = 0, s = 0, l = (max + min) / 2;
  if (max !== min) {
    const d = max - min;
    s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
    if (max === r) h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
    else if (max === g) h = ((b - r) / d + 2) / 6;
    else h = ((r - g) / d + 4) / 6;
  }
  return { h, s, l };
}

function hslToRgb(h, s, l) {
  let r, g, b;
  if (s === 0) { r = g = b = l; }
  else {
    const hue2rgb = (p, q, t) => {
      if (t < 0) t += 1; if (t > 1) t -= 1;
      if (t < 1/6) return p + (q - p) * 6 * t;
      if (t < 1/2) return q;
      if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
      return p;
    };
    const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    const p = 2 * l - q;
    r = hue2rgb(p, q, h + 1/3);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1/3);
  }
  return [Math.round(r * 255), Math.round(g * 255), Math.round(b * 255)];
}

function rgbToHex(r, g, b) {
  return '#' + [r, g, b].map(c => c.toString(16).padStart(2, '0')).join('');
}

function colorDistance(hex1, hex2) {
  const c1 = parseHex(hex1), c2 = parseHex(hex2);
  return Math.sqrt((c1.r-c2.r)**2 + (c1.g-c2.g)**2 + (c1.b-c2.b)**2);
}

function parseHex(hex) {
  const h = hex.replace('#','');
  return { r: parseInt(h.substring(0, 2),16), g: parseInt(h.substring(2, 4),16), b: parseInt(h.substring(4, 6),16) };
}

function lerp(a, b, t) { return a + (b - a) * t; }

// ============ 色相 seed 列表 ============
const HUE_SEEDS = {
  red:      '#f5222d',
  volcano:  '#fa541c',
  orange:   '#fa8c16',
  gold:     '#faad14',
  yellow:   '#fadb14',
  lime:     '#a0d911',
  green:    '#52c41a',
  cyan:     '#13c2c2',
  blue:     '#1890ff',
  geekblue: '#2f54eb',
  purple:   '#722ed1',
  magenta:  '#eb2f96',
  grey:     '#d9d9d9',
};

// 预计算各色相第5阶色值
const HUE_STEP5 = {};
for (const [name, seed] of Object.entries(HUE_SEEDS)) {
  const scale = generateAntScale(seed);
  HUE_STEP5[name] = rgbToHex(...scale[4]); // step5 = index 4
}

// 预计算各色相完整色阶表（供匹配用）
const HUE_SCALES = {};
for (const [name, seed] of Object.entries(HUE_SEEDS)) {
  HUE_SCALES[name] = generateAntScale(seed);
}

// ============ 读取 v2 SQL，解析 32 条记录 ============
const v2SqlPath = path.join(__dirname, 'palette_options_v2.sql');
const v2Sql = fs.readFileSync(v2SqlPath, 'utf8');

// v2 格式：每条记录一个独立 INSERT
// INSERT INTO "style_palette_options" (cols) VALUES (val1, val2, ...);
const insertRegex = /INSERT INTO "style_palette_options"[\s\S]*?VALUES\s*\(([\s\S]*?)\)\s*;/g;

const records = [];
let m;
while ((m = insertRegex.exec(v2Sql)) !== null) {
  const row = m[1];
  // 简化解析：直接按单引号分割来提取字段
  // 格式：'value', 'label', 'desc', 'static', '#bg', '#text', '#accent', '#muted', 'css_template', 'extra_colors', sort_order
  const strVals = [];
  const strRegex = /'([^']*)'/g;
  let sm;
  while ((sm = strRegex.exec(row)) !== null) {
    strVals.push(sm[1]);
  }
  // 最后一个可能是数字（sort_order）
  const lastComma = row.lastIndexOf(',');
  const lastVal = row.substring(lastComma + 1).trim();
  const sortOrder = parseInt(lastVal.replace(/[^\d]/g, '')) || 0;

  // strVals 顺序：value, label, description, palette_mode, bg, text_color, accent, muted, css_template, extra_colors
  if (strVals.length >= 9) {
    records.push({
      value:        strVals[0],
      label:        strVals[1],
      description:  strVals[2],
      palette_mode:  strVals[3],
      bg:           strVals[4],
      text_color:   strVals[5],
      accent:       strVals[6],
      muted:        strVals[7],
      css_template: strVals[8],
      sort_order:   sortOrder,
    });
  }
}

console.log(`解析到 ${records.length} 条 v2 记录`);

// ============ 反向匹配：对每个色值找到最近的 (色相, 阶数) ============
function matchColor(hex) {
  let bestDist = Infinity, bestHue = null, bestStep = null;
  for (const [hueName, scale] of Object.entries(HUE_SCALES)) {
    for (let step = 1; step <= 10; step++) {
      const [r, g, b] = scale[step - 1];
      const scaleHex = rgbToHex(r, g, b);
      const d = colorDistance(hex, scaleHex);
      if (d < bestDist) {
        bestDist = d;
        bestHue = hueName;
        bestStep = step;
      }
    }
  }
  return { hue: bestHue, step: bestStep, dist: bestDist };
}

// ============ 为每条记录生成归一化色相色值（第5阶）和色阶号 ============
const matched = records.map(rec => {
  const bgMatch    = matchColor(rec.bg);
  const textMatch  = matchColor(rec.text_color);
  const accMatch   = matchColor(rec.accent);
  const mutedMatch = matchColor(rec.muted);

  return {
    value:       rec.value,
    label:       rec.label,
    sort_order:  rec.sort_order,
    bg_step5:    HUE_STEP5[bgMatch.hue],
    text_step5:  HUE_STEP5[textMatch.hue],
    accent_step5: HUE_STEP5[accMatch.hue],
    muted_step5: HUE_STEP5[mutedMatch.hue],
    bg_hue:    bgMatch.hue,
    text_hue:  textMatch.hue,
    accent_hue: accMatch.hue,
    muted_hue: mutedMatch.hue,
    bg_step:    bgMatch.step,
    text_step:  textMatch.step,
    accent_step: accMatch.step,
    muted_step: mutedMatch.step,
  };
});

// ============ 输出匹配结果 ============
console.log('\n===== 反向匹配结果（前8条）=====');
for (let i = 0; i < Math.min(8, matched.length); i++) {
  const h = matched[i];
  console.log(`\n${h.value} (sort:${h.sort_order}):`);
  console.log(`  bg:     ${h.bg_hue}(step${h.bg_step}) → ${h.bg_step5}`);
  console.log(`  text:   ${h.text_hue}(step${h.text_step}) → ${h.text_step5}`);
  console.log(`  accent: ${h.accent_hue}(step${h.accent_step}) → ${h.accent_step5}`);
  console.log(`  muted:  ${h.muted_hue}(step${h.muted_step}) → ${h.muted_step5}`);
}

// 色阶分布统计
const stepCounts = { bg: {}, text: {}, accent: {}, muted: {} };
for (const h of matched) {
  for (const slot of ['bg', 'text', 'accent', 'muted']) {
    const step = h[`${slot}_step`];
    stepCounts[slot][step] = (stepCounts[slot][step] || 0) + 1;
  }
}
console.log('\n===== 色阶分布 =====');
for (const slot of ['bg', 'text', 'accent', 'muted']) {
  const sorted = Object.entries(stepCounts[slot]).sort((a,b) => b[1]-a[1]);
  const top3 = sorted.slice(0,3).map(([s,c]) => `step${s}(${c})`).join(', ');
  console.log(`  ${slot.padEnd(8)} ${top3}`);
}

// ============ 生成 v3 SQL ============
function sqlVal(v) {
  if (v === null || v === undefined) return 'NULL';
  return `'${v}'`;
}

// 按 sort_order 排序，取 harmony 记录
const harmonyRecs = matched.slice().sort((a,b) => a.sort_order - b.sort_order);

let sql = `-- ============================================================
-- palette_v3_migration_v2.sql
-- 三子维度配色方案表（v3 架构）
--
--   harmony_palette: 存归一化第5阶 hex 色值
--   tone_mapping:    存色阶号字符串 '1'~'10'
--   slot_assignment: 存槽位排列 '1'~'4'
--
-- 执行前请先备份：
--   ALTER TABLE style_palette_options RENAME TO style_palette_options_v2;
-- ============================================================

-- 创建 v3 表
DROP TABLE IF EXISTS "style_palette_options";
CREATE TABLE "style_palette_options" (
  value      TEXT PRIMARY KEY,
  label      TEXT NOT NULL,
  sub_dim    TEXT NOT NULL CHECK (sub_dim IN ('harmony_palette','tone_mapping','slot_assignment')),
  bg         TEXT,
  text_color TEXT,
  accent     TEXT,
  muted      TEXT,
  description TEXT,
  sort_order  INTEGER DEFAULT 0
);

-- ============================================================
-- A. harmony_palette（色相组合）— 32 套
--    bg/text_color/accent/muted 存归一化第5阶色值（hex）
--    渲染器：对每个非 NULL 色值调用 generateAntScale(hex) 得到完整色阶表
-- ============================================================
INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, description, sort_order) VALUES
`;

const harmonyLines = harmonyRecs.map((h, i) => {
  const cols = [
    sqlVal(h.value),
    sqlVal(h.label),
    "'harmony_palette'",
    sqlVal(h.bg_step5),
    sqlVal(h.text_step5),
    sqlVal(h.accent_step5),
    sqlVal(h.muted_step5),
    sqlVal(h.value), // description 暂用 value
    h.sort_order,
  ];
  return `(${cols.join(', ')})`;
});

sql += harmonyLines.join(',\n') + ';\n\n';

// B. tone_mapping
sql += `-- ============================================================
-- B. tone_mapping（色阶映射）— 5 种模板
--    bg/text_color/accent/muted 存色阶号（字符串）
-- ============================================================
INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, description, sort_order) VALUES
('light_standard', '浅调标准', 'tone_mapping', '3', '9', '6', '4', '浅背景+深文字+中强调', 10),
('light_soft',     '浅调柔和', 'tone_mapping', '2', '8', '5', '3', '更浅背景+稍浅文字', 20),
('medium_strong', '中调强烈', 'tone_mapping', '5', '1', '8', '3', '中背景+极深文字+强强调', 30),
('dark_standard', '深调标准', 'tone_mapping', '7', '2', '5', '6', '深背景+浅文字（暗调）', 40),
('dark_deep',     '深调深邃', 'tone_mapping', '8', '1', '4', '7', '极深背景+白文字', 50);
\n\n`;

// C. slot_assignment
sql += `-- ============================================================
-- C. slot_assignment（色相槽位排列）— 7 种排列
--    bg/text_color/accent/muted 存排列数字 1~4
--    含义：取 harmony 第几个色相填入此槽
-- ============================================================
INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, description, sort_order) VALUES
('original',     '原序',     'slot_assignment', '1', '2', '3', '4', '色相按原始顺序填槽', 10),
('swap_bg_text', '背景↔文字', 'slot_assignment', '2', '1', '3', '4', '交换bg与text色相', 20),
('swap_bg_acc',  '背景↔强调', 'slot_assignment', '3', '2', '1', '4', '交换bg与accent色相', 30),
('swap_text_acc','文字↔强调', 'slot_assignment', '1', '3', '2', '4', '交换text与accent色相', 40),
('shift_fwd',   '前移循环',  'slot_assignment', '2', '3', '1', '4', 'bg取色相2,text取色相3,accent取色相1', 50),
('shift_bwd',   '后移循环',  'slot_assignment', '3', '1', '2', '4', 'bg取色相3,accent取色相1,text取色相2', 60),
('cross_swap',  '十字互换',  'slot_assignment', '2', '1', '4', '3', 'bg↔text 且 accent↔muted', 70);
\n\n`;

// D. 渲染器说明
sql += `-- ============================================================
-- D. 渲染器对接说明
-- ============================================================
-- style_json.palette = {
--   "harmony_palette": "analogous_blue_purple",
--   "tone_mapping":    "light_standard",
--   "slot_assignment": "original"
-- }
--
-- 渲染流程（JS 伪代码）：
--
--   const harm = await db.query('SELECT * FROM style_palette_options WHERE value = ? AND sub_dim="harmony_palette"', [palette.harmony_palette]);
--   const tone = await db.query('SELECT * FROM style_palette_options WHERE value = ? AND sub_dim="tone_mapping"', [palette.tone_mapping]);
--   const slot = await db.query('SELECT * FROM style_palette_options WHERE value = ? AND sub_dim="slot_assignment"', [palette.slot_assignment]);
--
--   // 为每个非 NULL 的 harmony 色值生成色阶表
--   const scales = {};
--   for (const slotName of ['bg', 'text_color', 'accent', 'muted']) {
--     const hex = harm[slotName];
--     if (hex && !scales[hex]) scales[hex] = generateAntScale(hex);
--   }
--
--   // 计算最终色值
--   const final = {};
--   for (const slotName of ['bg', 'text_color', 'accent', 'muted']) {
--     const sourceIdx = parseInt(slot[slotName]) - 1;  // slot 存的是 1~4
--     // 找到 harmony 中第 sourceIdx 个位置的色值
--     const harmonySlots = ['bg', 'text_color', 'accent', 'muted'];
--     const sourceHex = harm[harmonySlots[sourceIdx]];
--     if (!sourceHex) continue;  // 映射到 NULL 色相，跳过
--     const step = parseInt(tone[slotName]);
--     final[slotName] = scales[sourceHex][step - 1];
--   }
--
--   // 输出 CSS 变量
--   // --card-bg: final.bg; --card-text: final.text; etc.
-- ============================================================
`;

const outPath = path.join(__dirname, 'palette_v3_migration_v2.sql');
fs.writeFileSync(outPath, sql);
console.log(`\nSQL 已写入 ${outPath}`);
