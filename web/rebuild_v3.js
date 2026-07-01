// rebuild_v3.js
// 重新生成完整的 palette_v3_final.sql（正确 description + 6 种单色卡）

const fs = require('fs');
const path = require('path');

// 从 v2 SQL 提取 description
const v2Sql = fs.readFileSync(path.join(__dirname, 'palette_options_v2.sql'), 'utf8');
const descMap = {};
const r = /INSERT[\s\S]*?VALUES\s*\(([\s\S]*?)\)\s*;/g;
let m;
while ((m = r.exec(v2Sql)) !== null) {
  const s = [];
  const sr = /'([^']*)'/g;
  let sm;
  while ((sm = sr.exec(m[1])) !== null) s.push(sm[1]);
  if (s.length >= 3) descMap[s[0]] = s[2];
}

// 38 种 harmony_palette
const harmony = [
  // 邻近8种（v2）
  { v: 'analogous_blue_purple',  l: '蓝紫邻近', d: descMap['analogous_blue_purple'],  bg: '#2f54ea', tc: '#2f54ea', ac: '#7e41d4', mu: '#7e41d4', sort: 100 },
  { v: 'analogous_green_teal',  l: '绿青邻近', d: descMap['analogous_green_teal'],  bg: '#69e22e', tc: '#26e8e8', ac: '#26e8e8', mu: '#26e8e8', sort: 101 },
  { v: 'analogous_orange_yellow', l: '橙黄邻近', d: descMap['analogous_orange_yellow'], bg: '#f9db1e', tc: '#f95620', ac: '#f98f1f', mu: '#f9db1e', sort: 102 },
  { v: 'analogous_red_orange', l: '红橙邻近', d: descMap['analogous_red_orange'], bg: '#9e9292', tc: '#9e9292', ac: '#f95620', mu: '#f98f1f', sort: 103 },
  { v: 'analogous_blue_teal',  l: '蓝青邻近', d: descMap['analogous_blue_teal'],  bg: '#1b91fd', tc: '#1b91fd', ac: '#1b91fd', mu: '#1b91fd', sort: 104 },
  { v: 'analogous_purple_pink', l: '紫粉邻近', d: descMap['analogous_purple_pink'], bg: '#2f54ea', tc: '#2f54ea', ac: '#7e41d4', mu: '#7e41d4', sort: 105 },
  { v: 'analogous_lime_yellow', l: '青柠黄邻近', d: descMap['analogous_lime_yellow'], bg: '#b4ec25', tc: '#69e22e', ac: '#b4ec25', mu: '#b4ec25', sort: 106 },
  { v: 'analogous_rose_red',    l: '玫瑰红邻近', d: descMap['analogous_rose_red'],    bg: '#f4252f', tc: '#f4252f', ac: '#f4252f', mu: '#f4252f', sort: 107 },
  // 互补8种
  { v: 'comp_navy_cream',  l: '藏青奶黄撞色', d: descMap['comp_navy_cream'],  bg: '#1b91fd', tc: '#b4ec25', ac: '#f9b01e', mu: '#1b91fd', sort: 200 },
  { v: 'comp_hermes_gray', l: '爱马仕橙灰撞色', d: descMap['comp_hermes_gray'], bg: '#9e9292', tc: '#9e9292', ac: '#f95620', mu: '#9e9292', sort: 201 },
  { v: 'comp_neon_black', l: '荧光黄黑撞色', d: descMap['comp_neon_black'], bg: '#9e9292', tc: '#b4ec25', ac: '#b4ec25', mu: '#9e9292', sort: 202 },
  { v: 'comp_klein_white', l: '克莱因蓝白撞色', d: descMap['comp_klein_white'], bg: '#9e9292', tc: '#2f54ea', ac: '#2f54ea', mu: '#2f54ea', sort: 203 },
  { v: 'comp_burgundy_beige', l: '勃艮第米色撞色', d: descMap['comp_burgundy_beige'], bg: '#f98f1f', tc: '#f4252f', ac: '#f4252f', mu: '#f98f1f', sort: 204 },
  { v: 'comp_cobalt_sand', l: '钴蓝沙色撞色', d: descMap['comp_cobalt_sand'], bg: '#f9b01e', tc: '#1b91fd', ac: '#1b91fd', mu: '#f9b01e', sort: 205 },
  { v: 'comp_forest_coral', l: '深林珊瑚撞色', d: descMap['comp_forest_coral'], bg: '#69e22e', tc: '#26e8e8', ac: '#f95620', mu: '#26e8e8', sort: 206 },
  { v: 'comp_charcoal_amber', l: '炭灰琥珀撞色', d: descMap['comp_charcoal_amber'], bg: '#9e9292', tc: '#f9db1e', ac: '#f9b01e', mu: '#9e9292', sort: 207 },
  // 分裂互补6种
  { v: 'split_red_green_teal',     l: '红+绿+青分裂互补', d: descMap['split_red_green_teal'],     bg: '#9e9292', tc: '#9e9292', ac: '#9e9292', mu: '#26e8e8', sort: 300 },
  { v: 'split_blue_orange',       l: '蓝+橙分裂互补',   d: descMap['split_blue_orange'],       bg: '#1b91fd', tc: '#1b91fd', ac: '#1b91fd', mu: '#f98f1f', sort: 301 },
  { v: 'split_yellow_purple',     l: '黄+紫分裂互补',   d: descMap['split_yellow_purple'],     bg: '#f9db1e', tc: '#f95620', ac: '#f9b01e', mu: '#7e41d4', sort: 302 },
  { v: 'split_green_magenta',     l: '绿+品红分裂互补', d: descMap['split_green_magenta'],     bg: '#69e22e', tc: '#26e8e8', ac: '#26e8e8', mu: '#7e41d4', sort: 303 },
  { v: 'split_purple_lime',       l: '紫+青柠分裂互补', d: descMap['split_purple_lime'],       bg: '#2f54ea', tc: '#2f54ea', ac: '#7e41d4', mu: '#b4ec25', sort: 304 },
  { v: 'split_orange_blue',       l: '橙+蓝分裂互补',   d: descMap['split_orange_blue'],       bg: '#f9db1e', tc: '#f95620', ac: '#f98f1f', mu: '#1b91fd', sort: 305 },
  // 三角色6种
  { v: 'triadic_red_yellow_blue',     l: '红黄蓝三角色',     d: descMap['triadic_red_yellow_blue'],     bg: '#9e9292', tc: '#9e9292', ac: '#9e9292', mu: '#f9db1e', sort: 400 },
  { v: 'triadic_orange_green_purple', l: '橙绿紫三角色',    d: descMap['triadic_orange_green_purple'], bg: '#f9db1e', tc: '#f95620', ac: '#f98f1f', mu: '#26e8e8', sort: 401 },
  { v: 'triadic_yellow_blue_red',     l: '黄蓝红三角色',     d: descMap['triadic_yellow_blue_red'],     bg: '#f9db1e', tc: '#f95620', ac: '#f9b01e', mu: '#9e9292', sort: 402 },
  { v: 'triadic_green_purple_orange', l: '绿紫橙三角色',    d: descMap['triadic_green_purple_orange'], bg: '#69e22e', tc: '#26e8e8', ac: '#26e8e8', mu: '#7e41d4', sort: 403 },
  { v: 'triadic_teal_rose_lime',      l: '青玫瑰青柠三角色',  d: descMap['triadic_teal_rose_lime'],      bg: '#69e22e', tc: '#26e8e8', ac: '#26e8e8', mu: '#f4252f', sort: 404 },
  { v: 'triadic_blue_orange_pink',    l: '蓝橙粉三角色',     d: descMap['triadic_blue_orange_pink'],    bg: '#1b91fd', tc: '#1b91fd', ac: '#1b91fd', mu: '#f98f1f', sort: 405 },
  // 四方色4种
  { v: 'tetradic_red_yellow_blue_green',    l: '红黄蓝绿四方色', d: descMap['tetradic_red_yellow_blue_green'],    bg: '#9e9292', tc: '#9e9292', ac: '#9e9292', mu: '#26e8e8', sort: 500 },
  { v: 'tetradic_blue_green_red_orange',    l: '蓝绿红橙四方色', d: descMap['tetradic_blue_green_red_orange'],    bg: '#1b91fd', tc: '#1b91fd', ac: '#1b91fd', mu: '#f98f1f', sort: 501 },
  { v: 'tetradic_purple_green_yellow_red',  l: '紫绿黄红四方色', d: descMap['tetradic_purple_green_yellow_red'],  bg: '#2f54ea', tc: '#2f54ea', ac: '#7e41d4', mu: '#26e8e8', sort: 502 },
  { v: 'tetradic_orange_teal_red_blue',    l: '橙青红蓝四方色', d: descMap['tetradic_orange_teal_red_blue'],    bg: '#f9db1e', tc: '#f95620', ac: '#f98f1f', mu: '#1b91fd', sort: 503 },
  // 单色6种
  { v: 'mono_blue',   l: '纯蓝', d: '单色蓝，全槽同色相，视觉变化由色阶映射决定', bg: '#1b91fd', tc: '#1b91fd', ac: '#1b91fd', mu: '#1b91fd', sort: 1100 },
  { v: 'mono_purple', l: '纯紫', d: '单色紫，全槽同色相，视觉变化由色阶映射决定', bg: '#7e41d4', tc: '#7e41d4', ac: '#7e41d4', mu: '#7e41d4', sort: 1101 },
  { v: 'mono_green',  l: '纯绿', d: '单色绿，全槽同色相，视觉变化由色阶映射决定', bg: '#69e22e', tc: '#69e22e', ac: '#69e22e', mu: '#69e22e', sort: 1102 },
  { v: 'mono_red',    l: '纯红', d: '单色红，全槽同色相，视觉变化由色阶映射决定', bg: '#f4252f', tc: '#f4252f', ac: '#f4252f', mu: '#f4252f', sort: 1103 },
  { v: 'mono_orange', l: '纯橙', d: '单色橙，全槽同色相，视觉变化由色阶映射决定', bg: '#f98f1f', tc: '#f98f1f', ac: '#f98f1f', mu: '#f98f1f', sort: 1104 },
  { v: 'mono_grey',   l: '纯灰', d: '单色灰，全槽同色相，视觉变化由色阶映射决定', bg: '#9e9292', tc: '#9e9292', ac: '#9e9292', mu: '#9e9292', sort: 1105 },
];

function sqlStr(v) {
  if (v === null || v === undefined) return 'NULL';
  return `'${v.replace(/'/g, "''")}'`;
}

let sql = `-- ============================================================
-- palette_v3_final.sql
-- 三子维度配色方案表（v3 架构，完整版）
--   harmony_palette: 38 套（32 v2 + 6 单色）
--   tone_mapping:    5 种
--   slot_assignment: 7 种
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
-- A. harmony_palette — 38 套
-- ============================================================
INSERT INTO "style_palette_options" (value, label, sub_dim, bg, text_color, accent, muted, description, sort_order) VALUES
`;

sql += harmony.map(h =>
  `(${sqlStr(h.v)}, ${sqlStr(h.l)}, 'harmony_palette', ${sqlStr(h.bg)}, ${sqlStr(h.tc)}, ${sqlStr(h.ac)}, ${sqlStr(h.mu)}, ${sqlStr(h.d)}, ${h.sort})`
).join(',\n') + ';\n\n';

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
-- 渲染流程：
--   1. 查 harmony_palette → bg/text_color/accent/muted 存的是第5阶归一化色值（hex）
--   2. 对每个非NULL色值调用 generateAntScale(hex) → 得到10阶色阶表
--   3. 查 tone_mapping → 得到各槽色阶号（字符串'1'~'10'）
--   4. 查 slot_assignment → 得到槽位排列（'1'~'4'）
--      计算最终色值：
--        final[slot] = generateAntScale( harmony[ slotIndex[slot_assignment[slot]-1 ] )[ tone[slot]-1 ]
--   5. 输出 CSS 变量 --card-bg: final.bg
-- ============================================================
`;

const outPath = path.join(__dirname, 'palette_v3_final.sql');
fs.writeFileSync(outPath, sql);
console.log(`已重新生成 ${outPath}（${harmony.length}+5+7=${harmony.length+12} 条）`);
