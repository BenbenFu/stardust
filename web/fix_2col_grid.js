/**
 * fix_2col_grid.js — 修复 5 个 2col_* 双栏 grid 模板
 *
 * 问题: 2col_* 模板使用跨行布局 (如 "slot-a slot-a" "slot-c slot-b" "slot-c slot-d")
 *       导致一栏有两个 slot 堆叠，另一栏一个 slot 跨行
 * 修复: 全部改为简单 2x2 网格 "slot-a slot-b" "slot-c slot-d"
 *       仅靠列宽比例区分变体
 */

const SUPABASE_URL = 'https://opyeahbzibuupmkmjpkr.supabase.co';
const API_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjk3MDcsImV4cCI6MjA5MzYwNTcwN30.7kCHwI7lKy1jH5BjI4gOKqw2vEUxpsjRJar_94j4Srk';

async function patchRecord(value, subDim, cssTemplate) {
  const url = `${SUPABASE_URL}/rest/v1/style_layout_options?sub_dim=eq.${subDim}&value=eq.${value}`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      'apikey': API_KEY,
      'Authorization': `Bearer ${API_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal'
    },
    body: JSON.stringify({ css_template: cssTemplate })
  });
  const status = res.status;
  if (status === 204) {
    console.log(`  [OK] ${subDim}/${value} -> ${status}`);
  } else {
    const text = await res.text();
    console.error(`  [FAIL] ${subDim}/${value} -> ${status}: ${text}`);
  }
  return status;
}

// 5 个 2col_* 模板: 全部改为 2x2 网格, 仅列宽不同
const templates = [
  ['2col_equal',       '.gallery-card[data-style-layout-grid="2col_equal"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
  ['2col_left_wide',   '.gallery-card[data-style-layout-grid="2col_left_wide"] { grid-template-columns: 2fr 1fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
  ['2col_right_wide',  '.gallery-card[data-style-layout-grid="2col_right_wide"] { grid-template-columns: 1fr 2fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
  ['2col_left_narrow', '.gallery-card[data-style-layout-grid="2col_left_narrow"] { grid-template-columns: 1fr 3fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
  ['2col_right_narrow','.gallery-card[data-style-layout-grid="2col_right_narrow"] { grid-template-columns: 3fr 1fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
];

async function main() {
  console.log('=== 修复 5 个 2col_* 双栏 grid 模板 (2x2 网格) ===');
  for (const [value, css] of templates) {
    await patchRecord(value, 'grid', css);
  }
  console.log('\n=== 完成 ===');
}

main().catch(e => console.error('FATAL:', e));
