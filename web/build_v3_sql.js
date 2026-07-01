// build_v3_sql.js
// 用色相角度匹配 + value名称辅助，将 v2 的 32 个色板拆成 v3 三子维度表
// 输出：palette_v3_final.sql

const fs = require('fs');
const path = require('path');

// ============ Ant Design 色阶生成 ============
function generateAntScale(seedHex) {
  const hex = seedHex.replace('#', '');
  const r = parseInt(hex.substring(0, 2), 16) / 255;
  const g = parseInt(hex.substring(2, 4), 16) / 255;
  const b = parseInt(hex.substring(4, 6), 16) / 255;
  const hsl = rgbToHsl(r, g, b);
  const steps = [];
  for (let i = 1; i <= 10; i++) {
    const t = (i - 1) / 9;
    const targetL = lerp(0.95, 0.05, t);
    const lShift = (hsl.l - targetL) * 0.85;
    let newL = hsl.l - lShift;
    newL = Math.max(0.03, Math.min(0.97, newL));
    const sFactor = 1 - Math.abs(t - 0.5) * 0.25;
    let newS = hsl.s * sFactor;
    newS = Math.max(0.06, Math.min(1.0, newS));
    steps.push(hslToRgb(hsl.h, newS, newL));
  }
  return steps;
}
function rgbToHsl(r, g, b) {
  const max = Math.max(r,g,b), min = Math.min(r,g,b);
  let h=0,s=0,l=(max+min)/2;
  if (max!==min) {
    const d=max-min; s=l>0.5?d/(2-max-min):d/(max+min);
    if (max===r) h=((g-b)/d+(g<b?6:0))/6;
    else if (max===g) h=((b-r)/d+2)/6;
    else h=((r-g)/d+4)/6;
  }
  return {h,s,l};
}
function hslToRgb(h,s,l) {
  let r,g,b;
  if (s===0) {r=g=b=l;}
  else {
    const q=l<0.5?l*(1+s):l+s-l*s, p=2*l-q;
    const hue2rgb=(p,q,t)=>{if(t<0)t+=1;if(t>1)t-=1;if(t<1/6)return p+(q-p)*6*t;if(t<1/2)return q;if(t<2/3)return p+(q-p)*(2/3-t)*6;return p;};
    r=hue2rgb(p,q,h+1/3); g=hue2rgb(p,q,h); b=hue2rgb(p,q,h-1/3);
  }
  return [Math.round(r*255),Math.round(g*255),Math.round(b*255)];
}
function rgbToHex(r,g,b) { return '#'+[r,g,b].map(c=>c.toString(16).padStart(2,'0')).join(''); }
function lerp(a,b,t) { return a+(b-a)*t; }
function hexToHsl(hex) {
  const h = hex.replace('#','');
  const r=parseInt(h.substring(0,2),16)/255, g=parseInt(h.substring(2,4),16)/255, b=parseInt(h.substring(4,6),16)/255;
  return rgbToHsl(r,g,b);
}

// ============ 色相 seed 与第5阶色值 ============
const HUE_MAP = {
  red:      {seed:'#f5222d', name:'red'},
  volcano:  {seed:'#fa541c', name:'volcano'},
  orange:   {seed:'#fa8c16', name:'orange'},
  gold:     {seed:'#faad14', name:'gold'},
  yellow:   {seed:'#fadb14', name:'yellow'},
  lime:     {seed:'#a0d911', name:'lime'},
  green:    {seed:'#52c41a', name:'green'},
  cyan:     {seed:'#13c2c2', name:'cyan'},
  blue:     {seed:'#1890ff', name:'blue'},
  geekblue: {seed:'#2f54eb', name:'geekblue'},
  purple:   {seed:'#722ed1', name:'purple'},
  magenta:  {seed:'#eb2f96', name:'magenta'},
  grey:     {seed:'#d9d9d9', name:'grey'},
};
for (const [k,v] of Object.entries(HUE_MAP)) {
  v.scale = generateAntScale(v.seed);
  v.step5 = rgbToHex(...v.scale[4]);
  v.hueAngle = hexToHsl(v.seed).h * 360; // 0~360
}

// ============ 按色相角度匹配（比 RGB 距离更准）============
function matchHueByAngle(hex) {
  const hsl = hexToHsl(hex);
  if (hsl.s < 0.08) return 'grey'; // 低饱和度归 grey
  const angle = hsl.h * 360;
  let bestName = 'grey', bestDist = 999;
  for (const [name, v] of Object.entries(HUE_MAP)) {
    let d = Math.abs(angle - v.hueAngle);
    if (d > 180) d = 360 - d; // 色相环最短距离
    if (d < bestDist) { bestDist = d; bestName = name; }
  }
  return bestName;
}

// ============ 读取 v2 SQL ============
const v2Path = path.join(__dirname, 'palette_options_v2.sql');
const v2Sql = fs.readFileSync(v2Path, 'utf8');

// 解析每条 INSERT（每条一个 INSERT）
const records = [];
const insertRegex = /INSERT INTO "style_palette_options"[\s\S]*?VALUES\s*\(([\s\S]*?)\)\s*;/g;
let m;
while ((m = insertRegex.exec(v2Sql)) !== null) {
  const row = m[1];
  // 提取所有单引号字符串
  const strs = [];
  const sr = /'([^']*)'/g;
  let sm;
  while ((sm = sr.exec(row)) !== null) strs.push(sm[1]);
  // sort_order 在最后，可能带空格
  const lastComma = row.lastIndexOf(',');
  const rest = row.substring(lastComma+1).trim();
  const sortOrder = parseInt(rest.replace(/[^\d]/g,'')) || 0;
  if (strs.length >= 8) {
    records.push({
      value:      strs[0],
      label:      strs[1],
      description: strs[2],
      bg:         strs[4],
      text_color:  strs[5],
      accent:      strs[6],
      muted:       strs[7],
      sort_order:  sortOrder,
    });
  }
}
console.log(`解析到 ${records.length} 条 v2 记录`);

// ============ 为每个色板的 4 个色值找到色相（角度匹配）============
const v3Data = records.map(rec => {
  const bgHue    = matchHueByAngle(rec.bg);
  const textHue  = matchHueByAngle(rec.text_color);
  const accHue   = matchHueByAngle(rec.accent);
  const mutedHue = matchHueByAngle(rec.muted);

  return {
    value:       rec.value,
    label:       rec.label,
    sort_order:  rec.sort_order,
    bg_step5:    HUE_MAP[bgHue].step5,
    text_step5:  HUE_MAP[textHue].step5,
    accent_step5: HUE_MAP[accHue].step5,
    muted_step5: HUE_MAP[mutedHue].step5,
    bg_hue:      bgHue,
    text_hue:    textHue,
    accent_hue:  accHue,
    muted_hue:   mutedHue,
    // 同时保留原色阶号（供参考）
    bg_orig:     rec.bg,
    text_orig:   rec.text_color,
    accent_orig: rec.accent,
    muted_orig:  rec.muted,
  };
});

// ============ 打印匹配结果供确认 ============
console.log('\n===== 色相角度匹配结果（前10条）=====');
for (let i=0; i<Math.min(10,v3Data.length); i++) {
  const d = v3Data[i];
  console.log(`\n${d.value} (sort:${d.sort_order}):`);
  console.log(`  bg:     ${d.bg_hue.padEnd(12)} step5=${d.bg_step5}   (原 ${d.bg_orig})`);
  console.log(`  text:   ${d.text_hue.padEnd(12)} step5=${d.text_step5}   (原 ${d.text_orig})`);
  console.log(`  accent: ${d.accent_hue.padEnd(12)} step5=${d.accent_step5}   (原 ${d.accent_orig})`);
  console.log(`  muted:  ${d.muted_hue.padEnd(12)} step5=${d.muted_step5}   (原 ${d.muted_orig})`);
}

// ============ 生成 v3 SQL ============
function sqlStr(v) {
  if (v===null||v===undefined) return 'NULL';
  return `'${v.replace(/'/g,"''")}'`;
}

const sorted = v3Data.slice().sort((a,b)=>a.sort_order-b.sort_order);

let sql = `-- ============================================================
-- palette_v3_final.sql
-- 三子维度配色方案表（v3 架构）
--
--   harmony_palette: bg/text_color/accent/muted 存归一化第5阶 hex
--   tone_mapping:    bg/text_color/accent/muted 存色阶号字符串 '1'~'10'
--   slot_assignment: bg/text_color/accent/muted 存排列数字 '1'~'4'
--
-- 执行前请先备份 v2 表：
--   ALTER TABLE style_palette_options RENAME TO style_palette_options_v2;
-- ============================================================

DROP TABLE IF EXISTS "style_palette_options";
CREATE TABLE "style_palette_options" (
  value       TEXT PRIMARY KEY,
  label       TEXT NOT NULL,
  sub_dim     TEXT NOT NULL CHECK (sub_dim IN ('harmony_palette','tone_mapping','slot_assignment')),
  bg          TEXT,
  text_color  TEXT,
  accent      TEXT,
  muted       TEXT,
  description TEXT,
  sort_order  INTEGER DEFAULT 0
);

-- ============================================================
-- A. harmony_palette — 32 套，色相归一化到第5阶 hex
-- ============================================================
INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, description, sort_order) VALUES
`;

const lines = sorted.map(d => {
  return `(${sqlStr(d.value)}, ${sqlStr(d.label)}, 'harmony_palette', ${sqlStr(d.bg_step5)}, ${sqlStr(d.text_step5)}, ${sqlStr(d.accent_step5)}, ${sqlStr(d.muted_step5)}, ${sqlStr(d.value)}, ${d.sort_order})`;
});
sql += lines.join(',\n') + ';\n\n';

// B. tone_mapping
sql += `-- ============================================================
-- B. tone_mapping — 5 种色阶映射模板
-- ============================================================
INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, description, sort_order) VALUES
('light_standard', '浅调标准', 'tone_mapping', '3', '9', '6', '4', '浅背景(step3)+深文字(step9)+中强调(step6)+浅辅助(step4)', 10),
('light_soft',     '浅调柔和', 'tone_mapping', '2', '8', '5', '3', '更浅背景+稍浅文字，整体轻柔', 20),
('medium_strong', '中调强烈', 'tone_mapping', '5', '1', '8', '3', '中背景+极深文字+强强调，卡片感强', 30),
('dark_standard', '深调标准', 'tone_mapping', '7', '2', '5', '6', '深背景+浅文字（暗调反转）', 40),
('dark_deep',     '深调深邃', 'tone_mapping', '8', '1', '4', '7', '极深背景+白色文字，神秘感', 50);
\n\n`;

// C. slot_assignment
sql += `-- ============================================================
-- C. slot_assignment — 7 种槽位排列
-- ============================================================
INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, description, sort_order) VALUES
('original',     '原序',     'slot_assignment', '1', '2', '3', '4', '色相按原始顺序填槽，不做重映射', 10),
('swap_bg_text', '背景↔文字', 'slot_assignment', '2', '1', '3', '4', '交换bg与text的色相', 20),
('swap_bg_acc',  '背景↔强调', 'slot_assignment', '3', '2', '1', '4', '交换bg与accent的色相', 30),
('swap_text_acc','文字↔强调', 'slot_assignment', '1', '3', '2', '4', '交换text与accent的色相', 40),
('shift_fwd',    '前移循环',  'slot_assignment', '2', '3', '1', '4', 'bg取色相2,text取色相3,accent取色相1', 50),
('shift_bwd',    '后移循环',  'slot_assignment', '3', '1', '2', '4', 'bg取色相3,accent取色相1,text取色相2', 60),
('cross_swap',   '十字互换',  'slot_assignment', '2', '1', '4', '3', 'bg↔text 且 accent↔muted', 70);
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
--   const harm = DB查询 value=? AND sub_dim='harmony_palette'
--   const tone = DB查询 value=? AND sub_dim='tone_mapping'
--   const slot = DB查询 value=? AND sub_dim='slot_assignment'
--
--   // 1. 为每个非NULL的 harmony 色值生成色阶表
--   const scales = {};
--   for (const slotName of ['bg','text_color','accent','muted']) {
--     const hex = harm[slotName];  // 如 '#1890ff'（blue step5）
--     if (hex && !scales[hex]) scales[hex] = generateAntScale(hex);
--   }
--
--   // 2. 按 slot_assignment 找到每个槽应取的色相
--   //    slot.bg='1' → 取 harmony.bg 的色相
--   //    slot.bg='2' → 取 harmony.text_color 的色相
--   const slotIndex = { bg:0, text_color:1, accent:2, muted:3 };
--
--   // 3. 计算最终色值
--   const final = {};
--   for (const slotName of ['bg','text_color','accent','muted']) {
--     const srcIdx = parseInt(slot[slotName]) - 1;  // 0~3
--     const srcHex = harm[Object.keys(slotIndex)[srcIdx]];
--     if (!srcHex) continue;
--     const step = parseInt(tone[slotName]);
--     final[slotName] = scales[srcHex][step - 1];
--   }
--
--   // 4. 输出 CSS 变量
--   // --card-bg: final.bg;  --card-text: final.text;  etc.
-- ============================================================
`;

const outPath = path.join(__dirname, 'palette_v3_final.sql');
fs.writeFileSync(outPath, sql);
console.log(`\nSQL 已写入 ${outPath}`);

// 检验：输出色相分布统计
const hueCounts = {};
for (const d of v3Data) {
  for (const h of [d.bg_hue, d.text_hue, d.accent_hue, d.muted_hue]) {
    hueCounts[h] = (hueCounts[h]||0) + 1;
  }
}
console.log('\n色相分布（32板×4槽=128个槽位）：');
for (const [hue, cnt] of Object.entries(hueCounts).sort((a,b)=>b[1]-a[1])) {
  console.log(`  ${hue.padEnd(12)} ${cnt}`);
}
