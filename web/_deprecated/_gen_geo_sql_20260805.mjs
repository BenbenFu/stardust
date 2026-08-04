import { readFileSync, writeFileSync } from 'fs';
const rows = JSON.parse(readFileSync('web/_db_dump_geo_20260805.json', 'utf8'));
const byId = Object.fromEntries(rows.map(r => [r.id, r]));
const get = id => byId[id].css_template;

// from -> to 顺序替换（split/join = replaceAll，避免正则误伤）
const plan = {
  23: [ // dot_grid
    ['--el-bg-size-1: 16px 16px;', '--el-bg-size-1: var(--el-geo-gap, 16px) var(--el-geo-gap, 16px);'],
    ['radial-gradient(circle, var(--card-muted, #ccc) 1px, transparent 1.6px)',
     'radial-gradient(circle, var(--card-muted, #ccc) var(--el-geo-thick, 1px), transparent calc(var(--el-geo-thick, 1px) + 0.6px))'],
  ],
  24: [ // fine_grid
    ['linear-gradient(var(--bg-grid-line) 1px, transparent 1px)',
     'linear-gradient(var(--bg-grid-line) var(--el-geo-thick, 1px), transparent var(--el-geo-thick, 1px))'],
    ['linear-gradient(90deg, var(--bg-grid-line) 1px, transparent 1px)',
     'linear-gradient(90deg, var(--bg-grid-line) var(--el-geo-thick, 1px), transparent var(--el-geo-thick, 1px))'],
    ['--el-bg-size-1: 20px 20px; --el-bg-size-2: 20px 20px;',
     '--el-bg-size-1: var(--el-geo-gap, 20px) var(--el-geo-gap, 20px); --el-bg-size-2: var(--el-geo-gap, 20px) var(--el-geo-gap, 20px);'],
  ],
  25: [ // horizontal_lines（间距=gap，线宽=thick）
    ['calc(1.5em - 1px)', 'calc(var(--el-geo-gap, 1.5em) - var(--el-geo-thick, 1px))'],
    [' #ccc) 1.5em)', ' #ccc) var(--el-geo-gap, 1.5em))'],
    ['100% 1.5em', '100% var(--el-geo-gap, 1.5em)'],
  ],
  27: [ // terminal_scanlines（周期=gap，线宽=thick；平铺尺寸同步 gap）
    ['transparent 2px', 'transparent var(--el-geo-thick, 2px)'],
    ['0.06) 2px', '0.06) var(--el-geo-thick, 2px)'],
    ['0.06) 4px', '0.06) var(--el-geo-gap, 4px)'],
    ['--el-bg-size-1: 100% 4px;', '--el-bg-size-1: 100% var(--el-geo-gap, 4px);'],
  ],
  51: [ // grain_noise
    ['--el-bg-size-1: 180px 180px;', '--el-bg-size-1: var(--el-geo-gap, 180px) var(--el-geo-gap, 180px);'],
  ],
  35: [ // scatter_dots (float 槽)
    ['radial-gradient(circle, var(--card-accent, #888) 1.2px, transparent 1.6px)',
     'radial-gradient(circle, var(--card-accent, #888) var(--el-geo-thick, 1.2px), transparent calc(var(--el-geo-thick, 1.2px) + 0.4px))'],
    ['--el-float-size-1: 46px 46px;', '--el-float-size-1: var(--el-geo-gap, 46px) var(--el-geo-gap, 46px);'],
    ['radial-gradient(circle, var(--card-accent, #888) 1px, transparent 1.4px)',
     'radial-gradient(circle, var(--card-accent, #888) var(--el-geo-thick, 1px), transparent calc(var(--el-geo-thick, 1px) + 0.4px))'],
    ['--el-float-size-2: 70px 70px;', '--el-float-size-2: var(--el-geo-gap, 70px) var(--el-geo-gap, 70px);'],
  ],
};

let upd = '', rev = '', changed = [];
for (const [id, repl] of Object.entries(plan)) {
  const orig = get(Number(id));
  let next = orig;
  for (const [from, to] of repl) {
    if (!next.includes(from)) { console.warn('MISS id', id, 'from:', from); }
    next = next.split(from).join(to);
  }
  if (next === orig) { console.warn('NO CHANGE id', id); continue; }
  changed.push(id);
  upd += `UPDATE style_element_options SET css_template = $${next}$$ WHERE id = ${id};\n`;
  rev += `UPDATE style_element_options SET css_template = $${orig}$$ WHERE id = ${id};\n`;
}
writeFileSync('web/style_geo_size_gap_20260805.sql',
  '-- 几何纹理尺寸/间距统一控制：硬编码尺寸/间距 -> 变量引用\n' +
  '-- 引擎按需发射 --el-geo-gap(间距/步长) / --el-geo-thick(尺寸/粗细)；不填则回退各模板原值（非破坏性）。\n' +
  '-- 接入：dot_grid(23) fine_grid(24) horizontal_lines(25) terminal_scanlines(27) grain_noise(51) scatter_dots(35)\n\n' + upd);
writeFileSync('web/style_geo_size_gap_revert_20260805.sql',
  '-- 回退：精准恢复各模板 css_template 原文\n\n' + rev);
console.log('changed ids:', changed.join(','));
