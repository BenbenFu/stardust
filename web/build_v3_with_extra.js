const fs = require('fs');

// Ant Design 色相种子（step5 ≈ seed）
const HUE_SEEDS = {
  red:     '#f4252f',
  orange:  '#f98f1f',
  yellow:  '#f9db1e',
  lime:    '#b4ec25',
  green:   '#69e22e',
  cyan:    '#26e8e8',
  blue:    '#1b91fd',
  geekblue:'#2f54ea',
  purple:  '#7e41d4',
  magenta: '#d946ef',
  pink:    '#e11d48',
  grey:    '#9e9292',
};

// 色相角度映射（HSL hue）
const HUE_ANGLES = {
  red:     0,
  orange:  30,
  yellow:  60,
  lime:    90,
  green:   120,
  cyan:    180,
  blue:    210,
  geekblue:235,
  purple:  270,
  magenta: 300,
  pink:    330,
  grey:    -1, // 特殊：灰度，按亮度判断
};

function hexToHsl(hex) {
  const r = parseInt(hex.slice(1,3),16)/255;
  const g = parseInt(hex.slice(3,5),16)/255;
  const b = parseInt(hex.slice(5,7),16)/255;
  const max = Math.max(r,g,b), min = Math.min(r,g,b);
  let h, s, l = (max+min)/2;
  if (max === min) { h = s = 0; }
  else {
    const d = max - min;
    s = l > 0.5 ? d/(2-max-min) : d/(max+min);
    switch(max) {
      case r: h = ((g-b)/d + (g<b?6:0))/6; break;
      case g: h = ((b-r)/d + 2)/6; break;
      case b: h = ((r-g)/d + 4)/6; break;
    }
  }
  return [h*360, s, l];
}

function findClosestHue(hex) {
  const [h, s, l] = hexToHsl(hex);
  if (s < 0.1) return 'grey'; // 低饱和度 → grey
  let closest = 'blue';
  let minDist = 360;
  for (const [name, angle] of Object.entries(HUE_ANGLES)) {
    if (name === 'grey') continue;
    let dist = Math.abs(h - angle);
    if (dist > 180) dist = 360 - dist;
    if (dist < minDist) { minDist = dist; closest = name; }
  }
  return closest;
}

// 读取 v2 SQL
const v2Sql = fs.readFileSync('palette_options_v2.sql', 'utf8');

// 解析每条记录的 value 和 extra_colors
const records = [];
const r = /INSERT[\s\S]*?VALUES\s*\(([\s\S]*?)\)\s*;/g;
let m;
while ((m = r.exec(v2Sql)) !== null) {
  const parts = [];
  const sr = /'([^']*)'/g;
  let sm;
  while ((sm = sr.exec(m[1])) !== null) parts.push(sm[1]);
  // parts: value, label, description, palette_mode, bg, text_color, accent, muted, css_template, extra_colors, sort_order
  // 但 extra_colors 是 JSON，可能被单引号包裹，需要用不同方式解析
  // 改用：找到 extra_colors 的值（在倒数第二个位置，sort_order 之前）
  const sqlFragment = m[1];
  // 找 JSON 部分：'{"key":"value"}'
  const jsonMatch = sqlFragment.match(/'(\{[^}]*\})'/);
  if (jsonMatch) {
    try {
      const extra = JSON.parse(jsonMatch[1].replace(/'/g, '"'));
      records.push({
        value: parts[0],
        extra_colors: extra,
      });
    } catch(e) {
      // 解析失败，跳过
    }
  }
}

// 更可靠的解析：直接按位置，extra_colors 是第11个单引号字符串（index 10）
// 但 JSON 里有双引号，所以单引号解析会断
// 改用：整个 SQL VALUES 片段，手动提取
records.length = 0; // 重置

const lines = v2Sql.split('\n');
let currentExtra = null;
let currentValue = null;
for (const line of lines) {
  const valMatch = line.match(/^\s*'([^']+)',\s*$/);
  if (valMatch && line.includes("'analogous") || line.includes("'comp") || line.includes("'split") || line.includes("'triadic") || line.includes("'tetradic")) {
    // 这是 value 行
  }
  // 直接搜索 extra_colors 的 JSON 行
  const extraMatch = line.match(/'(\{"[^"]+":"[^"]+"(?:,"[^"]+":"[^"]+")*\})'/);
  if (extraMatch) {
    // 找到了，但引号被转义了
  }
  // 更简单：搜索 '{' 行
  if (line.trim().startsWith("'{" && line.includes('":""#'))) {
    try {
      const jsonStr = line.trim().replace(/^'/, '').replace(/'\);$/, '').replace(/'/g, '"');
      const extra = JSON.parse(jsonStr);
      if (currentValue) {
        records.push({ value: currentValue, extra_colors: extra });
        currentValue = null;
      }
    } catch(e) {}
  }
}

// 最简单可靠的方式：直接用正则提取 extra_colors JSON（v2 格式固定）
const extraPattern = /'(\{[^}]+\})'/g;
// 不行，换个思路

// 直接硬编码 32 条记录的 extra_colors 归一化结果
// 从 v2 SQL 里手动提取每条的 extra_colors，然后归一化

const v2Extras = {
  analogous_blue_purple:  {"accent_2":"#A78BFA","bg_secondary":"#E0E7FF"},
  analogous_green_teal:   {"accent_2":"#34D399","bg_secondary":"#DCFCE7"},
  analogous_orange_yellow:{"accent_2":"#FBBF24","bg_secondary":"#FEF3C7"},
  analogous_red_orange:   {"accent_2":"#FB923C","bg_secondary":"#FECDD3"},
  analogous_blue_teal:    {"accent_2":"#22D3EE","bg_secondary":"#E0F2FE"},
  analogous_purple_pink:  {"accent_2":"#E879F9","bg_secondary":"#F3E8FF"},
  analogous_lime_yellow:  {"accent_2":"#CAE608","bg_secondary":"#ECFCCB"},
  analogous_rose_red:     {"accent_2":"#FE2C55","bg_secondary":"#FFE4E6"},
  comp_navy_cream:        {"bg_secondary":"#132D5E","accent_2":"#E8C44A"},
  comp_hermes_gray:       {"bg_secondary":"#5E5E5E","accent_2":"#FF8C42"},
  comp_neon_black:        {"bg_secondary":"#1A1A1A","accent_2":"#B8E600"},
  comp_klein_white:       {"bg_secondary":"#F0F4FF","accent_2":"#1A4FFF"},
  comp_burgundy_beige:    {"bg_secondary":"#EBD9C4","accent_2":"#8B2D3A"},
  comp_cobalt_sand:       {"bg_secondary":"#E8E0C8","accent_2":"#1A6BDE"},
  comp_forest_coral:      {"bg_secondary":"#DCFCE7","accent_2":"#F97316"},
  comp_charcoal_amber:    {"bg_secondary":"#2D2D2D","accent_2":"#FBBF24"},
  split_red_green_teal:   {"accent_2":"#16A34A","accent_3":"#14B8A6","bg_secondary":"#FECDD3"},
  split_blue_orange:      {"accent_2":"#F97316","accent_3":"#FB923C","bg_secondary":"#E0F2FE"},
  split_yellow_purple:    {"accent_2":"#9333EA","accent_3":"#A855F7","bg_secondary":"#FEF3C7"},
  split_green_magenta:    {"accent_2":"#D946EF","accent_3":"#E879F9","bg_secondary":"#DCFCE7"},
  split_purple_lime:      {"accent_2":"#84CC16","accent_3":"#A855F7","bg_secondary":"#F3E8FF"},
  split_orange_blue:      {"accent_2":"#3B82F6","accent_3":"#0EA5E9","bg_secondary":"#FEF3C7"},
  triadic_red_yellow_blue:     {"accent_2":"#EAB308","accent_3":"#3B82F6","bg_secondary":"#FECDD3"},
  triadic_orange_green_purple: {"accent_2":"#16A34A","accent_3":"#9333EA","bg_secondary":"#FEF3C7"},
  triadic_yellow_blue_red:     {"accent_2":"#3B82F6","accent_3":"#DC2626","bg_secondary":"#FEF3C7"},
  triadic_green_purple_orange: {"accent_2":"#A855F7","accent_3":"#F97316","bg_secondary":"#DCFCE7"},
  triadic_teal_rose_lime:      {"accent_2":"#F43F5E","accent_3":"#84CC16","bg_secondary":"#CCFBF1"},
  triadic_blue_orange_pink:    {"accent_2":"#F97316","accent_3":"#D946EF","bg_secondary":"#E0F2FE"},
  tetradic_red_yellow_blue_green:      {"accent_2":"#EAB308","accent_3":"#3B82F6","accent_4":"#16A34A","bg_secondary":"#FECDD3"},
  tetradic_blue_green_red_orange:      {"accent_2":"#22C55E","accent_3":"#DC2626","accent_4":"#F97316","bg_secondary":"#E0F2FE"},
  tetradic_purple_green_yellow_red:    {"accent_2":"#16A34A","accent_3":"#EAB308","accent_4":"#DC2626","bg_secondary":"#F3E8FF"},
  tetradic_orange_teal_red_blue:       {"accent_2":"#14B8A6","accent_3":"#DC2626","accent_4":"#3B82F6","bg_secondary":"#FEF3C7"},
};

// 归一化：对每个衍生色 hex，找到对应色相，输出 step5 hex
function normalizeExtraColors(extra) {
  const result = {};
  for (const [key, hex] of Object.entries(extra)) {
    const hue = findClosestHue(hex);
    result[key] = HUE_SEEDS[hue] || hex;
  }
  return result;
}

// 生成归一化后的 extra_colors
const normalized = {};
for (const [value, extra] of Object.entries(v2Extras)) {
  normalized[value] = normalizeExtraColors(extra);
}

console.log('=== 归一化后的 extra_colors（harmony_palette 行）===');
for (const [value, extra] of Object.entries(normalized)) {
  console.log(value, JSON.stringify(extra));
}

// 生成 tone_mapping 行的 extra_colors（色阶号）
// 规律：accent_2 通常用和 accent 相同的色阶，bg_secondary 用和 bg 相同的色阶
// 直接存和主四槽相同的色阶号
const toneExtras = {
  light_standard:  {"accent_2":6, "bg_secondary":3},
  light_soft:      {"accent_2":5, "bg_secondary":2},
  medium_strong:   {"accent_2":8, "bg_secondary":5},
  dark_standard:   {"accent_2":5, "bg_secondary":7},
  dark_deep:       {"accent_2":4, "bg_secondary":8},
};

console.log('\n=== tone_mapping 行的 extra_colors ===');
for (const [value, extra] of Object.entries(toneExtras)) {
  console.log(value, JSON.stringify(extra));
}

// 生成完整 SQL
let sql = `-- ============================================================
-- palette_v3_final.sql
-- 三子维度配色方案表（v3 架构，含 extra_colors）
-- ============================================================

DROP TABLE IF EXISTS "style_palette_options";

CREATE TABLE "style_palette_options" (
  value        TEXT PRIMARY KEY,
  label        TEXT NOT NULL,
  sub_dim      TEXT NOT NULL CHECK (sub_dim IN ('harmony_palette','tone_mapping','slot_assignment')),
  bg           TEXT,
  text_color   TEXT,
  accent       TEXT,
  muted        TEXT,
  extra_colors JSONB,
  description  TEXT,
  sort_order   INTEGER DEFAULT 0
);

-- ============================================================
-- A. harmony_palette — 38 套（32 v2 + 6 单色）
--   extra_colors: 衍生色相的 step5 归一化 hex
-- ============================================================

INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, extra_colors, description, sort_order) VALUES
`;

// harmony_palette 数据（含 extra_colors）
const harmony = [
  { v:'analogous_blue_purple',  l:'蓝紫邻近', bg:'#1b91fd',tc:'#1b91fd',ac:'#7e41d4',mu:'#7e41d4', extra: normalized['analogous_blue_purple'],  d:'蓝+紫邻近色，冷静科技感', sort:100 },
  { v:'analogous_green_teal',  l:'绿青邻近', bg:'#69e22e',tc:'#26e8e8',ac:'#26e8e8',mu:'#26e8e8', extra: normalized['analogous_green_teal'],  d:'绿+青邻近色，自然清新', sort:101 },
  { v:'analogous_orange_yellow',l:'橙黄邻近', bg:'#f9db1e',tc:'#f95620',ac:'#f98f1f',mu:'#f9db1e', extra: normalized['analogous_orange_yellow'], d:'橙+黄邻近色，温暖活力', sort:102 },
  { v:'analogous_red_orange', l:'红橙邻近', bg:'#f4252f',tc:'#f4252f',ac:'#f95620',mu:'#f98f1f', extra: normalized['analogous_red_orange'], l:'红橙邻近', d:'红+橙邻近色，热烈醒目', sort:103 },
  { v:'analogous_blue_teal',  l:'蓝青邻近', bg:'#1b91fd',tc:'#1b91fd',ac:'#1b91fd',mu:'#1b91fd', extra: normalized['analogous_blue_teal'],  d:'蓝+青邻近色，清爽现代', sort:104 },
  { v:'analogous_purple_pink', l:'紫粉邻近', bg:'#2f54ea',tc:'#2f54ea',ac:'#7e41d4',mu:'#7e41d4', extra: normalized['analogous_purple_pink'], d:'紫+粉邻近色，浪漫梦幻', sort:105 },
  { v:'analogous_lime_yellow', l:'青柠黄邻近',bg:'#b4ec25',tc:'#69e22e',ac:'#b4ec25',mu:'#b4ec25', extra: normalized['analogous_lime_yellow'], d:'青柠+黄邻近色，明亮活泼', sort:106 },
  { v:'analogous_rose_red',    l:'玫瑰红邻近',d:'玫瑰+红邻近色，精致优雅', bg:'#f4252f',tc:'#f4252f',ac:'#f4252f',mu:'#f4252f', extra: normalized['analogous_rose_red'], sort:107 },
  // 互补8种
  { v:'comp_navy_cream',  l:'藏青奶黄撞色',d:'藏青+奶黄互补撞色，沉稳中带暖调', bg:'#1b91fd',tc:'#b4ec25',ac:'#f9b01e',mu:'#1b91fd', extra: normalized['comp_navy_cream'], sort:200 },
  { v:'comp_hermes_gray', l:'爱马仕橙灰撞色',d:'爱马仕橙+高级灰，经典奢侈品质感', bg:'#9e9292',tc:'#9e9292',ac:'#f95620',mu:'#9e9292', extra: normalized['comp_hermes_gray'], sort:201 },
  { v:'comp_neon_black', l:'荧光黄黑撞色',d:'荧光黄+纯黑，赛博朋克/电竞风格', bg:'#9e9292',tc:'#b4ec25',ac:'#b4ec25',mu:'#9e9292', extra: normalized['comp_neon_black'], sort:202 },
  { v:'comp_klein_white',l:'克莱因蓝白撞色',d:'克莱因蓝+纯白，极简现代艺术感', bg:'#9e9292',tc:'#2f54ea',ac:'#2f54ea',mu:'#2f54ea', extra: normalized['comp_klein_white'], sort:203 },
  { v:'comp_burgundy_beige',l:'勃艮第米色撞色',d:'勃艮第酒红+米色，复古优雅', bg:'#f98f1f',tc:'#f4252f',ac:'#f4252f',mu:'#f98f1f', extra: normalized['comp_burgundy_beige'], sort:204 },
  { v:'comp_cobalt_sand',l:'钴蓝沙色撞色',d:'钴蓝+沙色，地中海/度假风格', bg:'#f9b01e',tc:'#1b91fd',ac:'#1b91fd',mu:'#f9b01e', extra: normalized['comp_cobalt_sand'], sort:205 },
  { v:'comp_forest_coral',l:'深林珊瑚撞色',d:'深林绿+珊瑚红，自然对比', bg:'#69e22e',tc:'#26e8e8',ac:'#f95620',mu:'#26e8e8', extra: normalized['comp_forest_coral'], sort:206 },
  { v:'comp_charcoal_amber',l:'炭灰琥珀撞色',d:'炭灰+琥珀，现代暗色主题', bg:'#9e9292',tc:'#f9db1e',ac:'#f9b01e',mu:'#9e9292', extra: normalized['comp_charcoal_amber'], sort:207 },
  // 分裂互补6种
  { v:'split_red_green_teal',     l:'红+绿+青分裂互补',d:'主红+分裂互补绿+青', bg:'#f4252f',tc:'#f4252f',ac:'#f4252f',mu:'#26e8e8', extra: normalized['split_red_green_teal'], sort:300 },
  { v:'split_blue_orange',       l:'蓝+橙分裂互补',  d:'主蓝+分裂互补橙', bg:'#1b91fd',tc:'#1b91fd',ac:'#1b91fd',mu:'#f98f1f', extra: normalized['split_blue_orange'], sort:301 },
  { v:'split_yellow_purple',     l:'黄+紫分裂互补',  d:'主黄+分裂互补紫', bg:'#f9db1e',tc:'#f95620',ac:'#f9b01e',mu:'#7e41d4', extra: normalized['split_yellow_purple'], sort:302 },
  { v:'split_green_magenta',     l:'绿+品红分裂互补',d:'主绿+分裂互补品红', bg:'#69e22e',tc:'#26e8e8',ac:'#26e8e8',mu:'#7e41d4', extra: normalized['split_green_magenta'], sort:303 },
  { v:'split_purple_lime',       l:'紫+青柠分裂互补',d:'主紫+分裂互补青柠', bg:'#2f54ea',tc:'#2f54ea',ac:'#7e41d4',mu:'#b4ec25', extra: normalized['split_purple_lime'], sort:304 },
  { v:'split_orange_blue',       l:'橙+蓝分裂互补',  d:'主橙+分裂互补蓝', bg:'#f9db1e',tc:'#f95620',ac:'#f98f1f',mu:'#1b91fd', extra: normalized['split_orange_blue'], sort:305 },
  // 三角色6种
  { v:'triadic_red_yellow_blue',     l:'红黄蓝三角色',    d:'经典三原色三角', bg:'#f4252f',tc:'#f4252f',ac:'#f4252f',mu:'#f9db1e', extra: normalized['triadic_red_yellow_blue'], sort:400 },
  { v:'triadic_orange_green_purple',l:'橙绿紫三角色',   d:'橙+绿+紫三角', bg:'#f9db1e',tc:'#f95620',ac:'#f98f1f',mu:'#26e8e8', extra: normalized['triadic_orange_green_purple'], sort:401 },
  { v:'triadic_yellow_blue_red',     l:'黄蓝红三角色',    d:'黄+蓝+红三角', bg:'#f9db1e',tc:'#f95620',ac:'#f9b01e',mu:'#f4252f', extra: normalized['triadic_yellow_blue_red'], sort:402 },
  { v:'triadic_green_purple_orange',l:'绿紫橙三角色',   d:'绿+紫+橙三角', bg:'#69e22e',tc:'#26e8e8',ac:'#26e8e8',mu:'#7e41d4', extra: normalized['triadic_green_purple_orange'], sort:403 },
  { v:'triadic_teal_rose_lime',      l:'青玫瑰青柠三角色', d:'青+玫瑰+青柠三角', bg:'#69e22e',tc:'#26e8e8',ac:'#26e8e8',mu:'#f4252f', extra: normalized['triadic_teal_rose_lime'], sort:404 },
  { v:'triadic_blue_orange_pink',    l:'蓝橙粉三角色',    d:'蓝+橙+粉三角', bg:'#1b91fd',tc:'#1b91fd',ac:'#1b91fd',mu:'#f98f1f', extra: normalized['triadic_blue_orange_pink'], sort:405 },
  // 四方色4种
  { v:'tetradic_red_yellow_blue_green',    l:'红黄蓝绿四方色',d:'矩形配色：红+黄+蓝+绿', bg:'#f4252f',tc:'#f4252f',ac:'#f4252f',mu:'#69e22e', extra: normalized['tetradic_red_yellow_blue_green'], sort:500 },
  { v:'tetradic_blue_green_red_orange',    l:'蓝绿红橙四方色',d:'矩形配色：蓝+绿+红+橙', bg:'#1b91fd',tc:'#1b91fd',ac:'#1b91fd',mu:'#f98f1f', extra: normalized['tetradic_blue_green_red_orange'], sort:501 },
  { v:'tetradic_purple_green_yellow_red',  l:'紫绿黄红四方色',d:'矩形配色：紫+绿+黄+红', bg:'#2f54ea',tc:'#2f54ea',ac:'#7e41d4',mu:'#69e22e', extra: normalized['tetradic_purple_green_yellow_red'], sort:502 },
  { v:'tetradic_orange_teal_red_blue',    l:'橙青红蓝四方色',d:'矩形配色：橙+青+红+蓝', bg:'#f9db1e',tc:'#f95620',ac:'#f98f1f',mu:'#1b91fd', extra: normalized['tetradic_orange_teal_red_blue'], sort:503 },
  // 单色6种
  { v:'mono_blue',   l:'纯蓝', d:'单色蓝，全槽同色相', bg:'#1b91fd',tc:'#1b91fd',ac:'#1b91fd',mu:'#1b91fd', extra: null, sort:1100 },
  { v:'mono_purple', l:'纯紫', d:'单色紫，全槽同色相', bg:'#7e41d4',tc:'#7e41d4',ac:'#7e41d4',mu:'#7e41d4', extra: null, sort:1101 },
  { v:'mono_green',  l:'纯绿', d:'单色绿，全槽同色相', bg:'#69e22e',tc:'#69e22e',ac:'#69e22e',mu:'#69e22e', extra: null, sort:1102 },
  { v:'mono_red',    l:'纯红', d:'单色红，全槽同色相', bg:'#f4252f',tc:'#f4252f',ac:'#f4252f',mu:'#f4252f', extra: null, sort:1103 },
  { v:'mono_orange', l:'纯橙', d:'单色橙，全槽同色相', bg:'#f98f1f',tc:'#f98f1f',ac:'#f98f1f',mu:'#f98f1f', extra: null, sort:1104 },
  { v:'mono_grey',   l:'纯灰', d:'单色灰，全槽同色相', bg:'#9e9292',tc:'#9e9292',ac:'#9e9292',mu:'#9e9292', extra: null, sort:1105 },
];

function j(v) { return v === null ? 'NULL' : `'${JSON.stringify(v).replace(/'/g, "''")}'`; }

sql += harmony.map(h =>
  `('${h.v}', '${h.l}', 'harmony_palette', '${h.bg}', '${h.tc}', '${h.ac}', '${h.mu}', ${j(h.extra)}, '${h.d}', ${h.sort})`
).join(',\n') + ';\n\n';

// B. tone_mapping
sql += `-- ============================================================
-- B. tone_mapping — 5 种色阶映射模板
--   extra_colors: 衍生色的色阶号（与主四槽保持一致）
-- ============================================================

INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, extra_colors, description, sort_order) VALUES
('light_standard', '浅调标准', 'tone_mapping', '3', '9', '6', '4', '{"accent_2":6,"bg_secondary":3}', '浅背景+深文字+中强调', 10),
('light_soft', '浅调柔和', 'tone_mapping', '2', '8', '5', '3', '{"accent_2":5,"bg_secondary":2}', '更浅背景+稍浅文字', 20),
('medium_strong', '中调强烈', 'tone_mapping', '5', '1', '8', '3', '{"accent_2":8,"bg_secondary":5}', '中背景+极深文字+强强调', 30),
('dark_standard', '深调标准', 'tone_mapping', '7', '2', '5', '6', '{"accent_2":5,"bg_secondary":7}', '深背景+浅文字（暗调）', 40),
('dark_deep', '深调深邃', 'tone_mapping', '8', '1', '4', '7', '{"accent_2":4,"bg_secondary":8}', '极深背景+白文字', 50);\n\n`;

// C. slot_assignment
sql += `-- ============================================================
-- C. slot_assignment — 7 种槽位排列
--   extra_colors: NULL（排列不影响衍生色）
-- ============================================================

INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, extra_colors, description, sort_order) VALUES
('original',   '原序',    'slot_assignment', '1', '2', '3', '4', NULL, '色相按原始顺序填槽', 10),
('swap_bg_text','背景↔文字', 'slot_assignment', '2', '1', '3', '4', NULL, '交换bg与text色相', 20),
('swap_bg_acc','背景↔强调', 'slot_assignment', '3', '2', '1', '4', NULL, '交换bg与accent色相', 30),
('swap_text_acc','文字↔强调','slot_assignment', '1', '3', '2', '4', NULL, '交换text与accent色相', 40),
('shift_fwd',  '前移循环',  'slot_assignment', '2', '3', '1', '4', NULL, 'bg取色相2,text取色相3,accent取色相1', 50),
('shift_bwd',  '后移循环',  'slot_assignment', '3', '1', '2', '4', NULL, 'bg取色相3,accent取色相1,text取色相2', 60),
('cross_swap', '十字互换',  'slot_assignment', '2', '1', '4', '3', NULL, 'bg↔text 且 accent↔muted', 70);\n\n `;

sql += `-- ============================================================
-- D. 渲染器对接说明
-- ============================================================
-- style_json.palette = {
--   "harmony_palette": "analogous_blue_purple",
--   "tone_mapping":    "light_standard",
--   "slot_assignment": "original"
-- }
--
-- 渲染流程：
--   1. 查 harmony_palette → bg/text_color/accent/muted 存的是第5阶归一化色值
--   2. 对每个非NULL色值调用 generateAntScale(hex) → 得到10阶色阶表
--   3. 查 tone_mapping → 得到各槽色阶号，同时 extra_colors 有衍生色的色阶号
--   4. 查 slot_assignment → 得到槽位排列，计算最终色值
--   5. 输出 CSS 变量 --card-bg: [final_bg]
--   6. extra_colors 的衍生色也按相同流程计算，输出 --card-accent-2: [final_accent_2] 等
-- ============================================================
`;

fs.writeFileSync('palette_v3_final.sql', sql);
console.log('\n已生成 palette_v3_final.sql');
console.log('harmony:', harmony.length, '条');
console.log('tone: 5 条');
console.log('slot: 7 条');
console.log('总计:', harmony.length + 5 + 7, '条');
