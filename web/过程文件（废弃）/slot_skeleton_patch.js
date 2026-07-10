/**
 * slot_skeleton_patch.js — Grid 层纯骨架化 + flow/flow_vertical 清理
 *
 * 默认 slot 映射: a=date, b=title, c=highlights, d=capsule
 * 所有 grid-template-areas 从字段名改为 slot-a/b/c/d
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

// ============================================================
// 1. Grid 模板: 17 条 — 字段名改为 slot-a/b/c/d
// 默认映射: a=date, b=title, c=highlights, d=capsule
// ============================================================

const gridTemplates = [
  // single
  ['single', '.gallery-card[data-style-layout-grid="single"] { grid-template-columns: 1fr; grid-template-areas: "slot-a" "slot-b" "slot-c" "slot-d"; }'],
  // 2col_* — 全部 2x2 网格, 仅列宽不同
  ['2col_equal', '.gallery-card[data-style-layout-grid="2col_equal"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
  ['2col_left_wide', '.gallery-card[data-style-layout-grid="2col_left_wide"] { grid-template-columns: 2fr 1fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
  ['2col_right_wide', '.gallery-card[data-style-layout-grid="2col_right_wide"] { grid-template-columns: 1fr 2fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
  ['2col_left_narrow', '.gallery-card[data-style-layout-grid="2col_left_narrow"] { grid-template-columns: 1fr 3fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
  ['2col_right_narrow', '.gallery-card[data-style-layout-grid="2col_right_narrow"] { grid-template-columns: 3fr 1fr; grid-template-areas: "slot-a slot-b" "slot-c slot-d"; }'],
  // 3col_equal
  ['3col_equal', '.gallery-card[data-style-layout-grid="3col_equal"] { grid-template-columns: 1fr 1fr 1fr; grid-template-areas: "slot-a slot-b slot-d" "slot-c slot-c slot-c"; }'],
  // 3col_left_focus
  ['3col_left_focus', '.gallery-card[data-style-layout-grid="3col_left_focus"] { grid-template-columns: 2fr 1fr 1fr; grid-template-areas: "slot-b slot-b slot-b" "slot-c slot-a slot-d"; }'],
  // 3col_right_focus
  ['3col_right_focus', '.gallery-card[data-style-layout-grid="3col_right_focus"] { grid-template-columns: 1fr 1fr 2fr; grid-template-areas: "slot-b slot-b slot-b" "slot-a slot-d slot-c"; }'],
  // sidebar_left
  ['sidebar_left', '.gallery-card[data-style-layout-grid="sidebar_left"] { grid-template-columns: 100px 1fr; grid-template-areas: "slot-a slot-b" "slot-d slot-c"; }'],
  // sidebar_right
  ['sidebar_right', '.gallery-card[data-style-layout-grid="sidebar_right"] { grid-template-columns: 1fr 100px; grid-template-areas: "slot-b slot-a" "slot-c slot-d"; }'],
  // sidebar_both
  ['sidebar_both', '.gallery-card[data-style-layout-grid="sidebar_both"] { grid-template-columns: 80px 1fr 80px; grid-template-areas: "slot-a slot-b slot-d" "slot-a slot-c slot-d"; }'],
  // top_split
  ['top_split', '.gallery-card[data-style-layout-grid="top_split"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-a slot-d" "slot-b slot-b" "slot-c slot-c"; }'],
  // bottom_split
  ['bottom_split', '.gallery-card[data-style-layout-grid="bottom_split"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-b slot-b" "slot-c slot-c" "slot-a slot-d"; }'],
  // hero
  ['hero', '.gallery-card[data-style-layout-grid="hero"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-b slot-b" "slot-a slot-d" "slot-c slot-c"; }'],
  // inverted
  ['inverted', '.gallery-card[data-style-layout-grid="inverted"] { grid-template-columns: 1fr 1fr; grid-template-areas: "slot-c slot-c" "slot-b slot-b" "slot-a slot-d"; }'],
  // timeline
  ['timeline', '.gallery-card[data-style-layout-grid="timeline"] { grid-template-columns: 60px 1fr; grid-template-areas: "slot-a slot-b" "slot-a slot-c" "slot-a slot-d"; border-left: 2px solid var(--card-accent, #ccc); padding-left: 12px; }'],
];

// ============================================================
// 2. Flow 记录: 3 条 — 清空 css_template (flow 降级为 UI 预设标签, writing-mode 由 renderStyleJson 全权计算)
// ============================================================

const flowTemplates = [
  ['horizontal', ''],
  ['vertical', ''],
  ['mixed', ''],
];

// ============================================================
// 3. flow_vertical 记录: 4 条 — 清空 css_template (渲染器全权处理)
// ============================================================

const flowVerticalTemplates = [
  ['date', ''],
  ['title', ''],
  ['highlights', ''],
  ['capsule', ''],
];

// ============================================================
// 执行
// ============================================================

async function main() {
  console.log('=== Grid 模板 (17 条) ===');
  for (const [value, css] of gridTemplates) {
    await patchRecord(value, 'grid', css);
  }

  console.log('\n=== Flow 记录 (3 条) ===');
  for (const [value, css] of flowTemplates) {
    await patchRecord(value, 'flow', css);
  }

  console.log('\n=== flow_vertical 记录 (4 条) — 清空 css_template ===');
  for (const [value, css] of flowVerticalTemplates) {
    await patchRecord(value, 'flow_vertical', css);
  }

  console.log('\n=== 全部完成 ===');
}

main().catch(e => console.error('FATAL:', e));
