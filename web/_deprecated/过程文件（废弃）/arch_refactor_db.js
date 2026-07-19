/**
 * arch_refactor_db.js — 自动化 DB css_template 变更
 *
 * 变更内容：
 * 1. alignment_mode: 全局选择器 → per-element 选择器 (5 rows)
 * 2. text_decoration: = → ~= 选择器 (16 rows)
 * 3. effect.filter_self: 全局 → per-element (10 rows, none 清空)
 * 4. effect.filter_backdrop: 全局 → per-element (3 rows)
 * 5. effect.transform: 全局 → per-element (7 rows, none 清空)
 * 6. effect.animation: 全局 → per-element (8 rows, none 清空)
 * 7. box_target: INSERT 5 new rows
 * 8. box_style: 扩展为含 box_target 复合选择器 (10 rows)
 */

const SB_URL = 'https://opyeahbzibuupmkmjpkr.supabase.co';
const SB_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjk3MDcsImV4cCI6MjA5MzYwNTcwN30.7kCHwI7lKy1jH5BjI4gOKqw2vEUxpsjRJar_94j4Srk';

const ELEMENTS = ['title', 'date', 'capsule', 'highlights'];
const FIELD_CLASS = { title: '.card-title', date: '.card-date', capsule: '.card-capsule', highlights: '.card-highlights' };

async function fetchRows(table, filter) {
  const url = `${SB_URL}/rest/v1/${table}?${filter}&select=*`;
  const res = await fetch(url, { headers: { apikey: SB_KEY, Authorization: `Bearer ${SB_KEY}` } });
  return res.json();
}

async function patchRow(table, filter, body) {
  const url = `${SB_URL}/rest/v1/${table}?${filter}`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      apikey: SB_KEY,
      Authorization: `Bearer ${SB_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal'
    },
    body: JSON.stringify(body)
  });
  return { ok: res.ok, status: res.status };
}

async function insertRows(table, rows) {
  const url = `${SB_URL}/rest/v1/${table}`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      apikey: SB_KEY,
      Authorization: `Bearer ${SB_KEY}`,
      'Content-Type': 'application/json',
      Prefer: 'return=minimal,resolution=merge-duplicates'
    },
    body: JSON.stringify(rows)
  });
  return { ok: res.ok, status: res.status };
}

// ============================================================
// 1. alignment_mode: 全局 → per-element
// ============================================================
function transformAlignmentMode(cssTemplate, value) {
  // 解析当前 CSS 中的 4 个 CSS 变量值
  const varMap = { title: null, date: null, highlights: null, capsule: null };
  const titleMatch = cssTemplate.match(/--typo-title-align:\s*(\w+)/);
  const dateMatch = cssTemplate.match(/--typo-date-align:\s*(\w+)/);
  const highlightMatch = cssTemplate.match(/--typo-highlight-align:\s*(\w+)/);
  const capsuleMatch = cssTemplate.match(/--typo-capsule-align:\s*(\w+)/);

  if (titleMatch) varMap.title = titleMatch[1];
  if (dateMatch) varMap.date = dateMatch[1];
  if (highlightMatch) varMap.highlights = highlightMatch[1];
  if (capsuleMatch) varMap.capsule = capsuleMatch[1];

  const rules = [];
  for (const el of ELEMENTS) {
    const alignVal = varMap[el];
    if (!alignVal) continue;
    // 注意：CSS 变量名是 --typo-highlight-align (singular)，但 data-attr 用 highlights (plural)
    const varName = el === 'highlights' ? '--typo-highlight-align' : `--typo-${el}-align`;
    rules.push(`.gallery-card[data-style-typo-alignment-mode-${el}="${value}"] { ${varName}:${alignVal}; }`);
  }
  return rules.join('\n');
}

// ============================================================
// 2. text_decoration: = → ~= (正则替换)
// ============================================================
function transformTextDecoration(cssTemplate) {
  if (!cssTemplate) return cssTemplate;
  // 将 data-style-typo-text-decoration-ELEMENT=" 替换为 ~="
  return cssTemplate.replace(
    /data-style-typo-text-decoration-(title|date|capsule|highlights)="/g,
    'data-style-typo-text-decoration-$1~="'
  );
}

// ============================================================
// 3-6. effect: 全局 → per-element
// ============================================================
function transformEffectCss(cssTemplate, subDim, value) {
  if (!cssTemplate || value === 'none') return '';

  // 提取 @keyframes 块（如果有）
  const keyframesMatch = cssTemplate.match(/@keyframes\s+[\w-]+\s*\{[^}]*\}/g);
  const keyframes = keyframesMatch ? keyframesMatch.join('\n') + '\n' : '';

  // 提取 CSS 属性（在大括号内）
  // 匹配 .gallery-card[...] { property: value; }
  const ruleMatch = cssTemplate.match(/\.gallery-card\[[^\]]+\]\s*\{([^}]*)\}/);
  if (!ruleMatch) return cssTemplate; // 无法解析，保留原样

  const cssProps = ruleMatch[1].trim();

  // 根据子维度确定选择器模式
  let attrPrefix;
  if (subDim === 'filter_self' || subDim === 'filter_backdrop') {
    attrPrefix = 'data-style-effect-filter';
  } else if (subDim === 'transform') {
    attrPrefix = 'data-style-effect-transform';
  } else if (subDim === 'animation') {
    attrPrefix = 'data-style-effect-animation';
  }

  const rules = [];
  for (const el of ELEMENTS) {
    const selector = `.gallery-card[${attrPrefix}-${el}="${value}"] ${FIELD_CLASS[el]}`;
    rules.push(`${selector} { ${cssProps} }`);
  }

  return keyframes + rules.join('\n');
}

// ============================================================
// 8. box_style: 扩展为含 box_target 的复合选择器
// ============================================================
function transformBoxStyle(cssTemplate, value) {
  if (!cssTemplate) return cssTemplate;

  // 提取当前 CSS 属性
  const ruleMatch = cssTemplate.match(/\.gallery-card\[[^\]]+\]\s*([\s\S]*)/);
  if (!ruleMatch) return cssTemplate;

  // 提取大括号内的 CSS
  const propsMatch = cssTemplate.match(/\{([^}]*)\}/);
  if (!propsMatch) return cssTemplate;

  const cssProps = propsMatch[1].trim();

  // 生成 5 个目标变体
  const rules = [];
  // global
  rules.push(`.gallery-card[data-style-deco-box-target="global"][data-style-deco-box="${value}"] { ${cssProps} }`);
  // per-field
  for (const el of ELEMENTS) {
    rules.push(`.gallery-card[data-style-deco-box-target="${el}"][data-style-deco-box="${value}"] ${FIELD_CLASS[el]} { ${cssProps} }`);
  }

  return rules.join('\n');
}

// ============================================================
// Main
// ============================================================
async function main() {
  let ok = 0, fail = 0;

  // --- 1. alignment_mode ---
  console.log('\n=== 1. alignment_mode ===');
  const amRows = await fetchRows('style_typo_options', 'sub_dim=eq.alignment_mode');
  for (const row of amRows) {
    const newCss = transformAlignmentMode(row.css_template, row.value);
    const r = await patchRow('style_typo_options', `sub_dim=eq.alignment_mode&value=eq.${row.value}`, { css_template: newCss });
    console.log(`  ${row.value}: ${r.ok ? 'OK' : 'FAIL(' + r.status + ')'}`);
    r.ok ? ok++ : fail++;
  }

  // --- 2. text_decoration ---
  console.log('\n=== 2. text_decoration (= → ~=) ===');
  const tdRows = await fetchRows('style_typo_options', 'sub_dim=eq.text_decoration');
  for (const row of tdRows) {
    if (!row.css_template) continue;
    const newCss = transformTextDecoration(row.css_template);
    if (newCss === row.css_template) { console.log(`  ${row.value}: SKIP (no change)`); continue; }
    const r = await patchRow('style_typo_options', `sub_dim=eq.text_decoration&value=eq.${row.value}`, { css_template: newCss });
    console.log(`  ${row.value}: ${r.ok ? 'OK' : 'FAIL(' + r.status + ')'}`);
    r.ok ? ok++ : fail++;
  }

  // --- 3-6. effect ---
  console.log('\n=== 3-6. effect (全局 → per-element) ===');
  const effRows = await fetchRows('style_effect_options', 'order=sub_dim,sort_order');
  for (const row of effRows) {
    const newCss = transformEffectCss(row.css_template, row.sub_dim, row.value);
    const r = await patchRow('style_effect_options', `sub_dim=eq.${row.sub_dim}&value=eq.${row.value}`, { css_template: newCss });
    console.log(`  ${row.sub_dim}/${row.value}: ${r.ok ? 'OK' : 'FAIL(' + r.status + ')'}`);
    r.ok ? ok++ : fail++;
  }

  // --- 7. box_target INSERT ---
  console.log('\n=== 7. box_target INSERT ===');
  const btRows = [
    { sub_dim: 'box_target', value: 'global', label: 'global', description: 'Box applies to entire card', sort_order: 10, css_template: '' },
    { sub_dim: 'box_target', value: 'date', label: 'date', description: 'Box applies to date field', sort_order: 20, css_template: '' },
    { sub_dim: 'box_target', value: 'title', label: 'title', description: 'Box applies to title field', sort_order: 30, css_template: '' },
    { sub_dim: 'box_target', value: 'highlights', label: 'highlights', description: 'Box applies to highlights', sort_order: 40, css_template: '' },
    { sub_dim: 'box_target', value: 'capsule', label: 'capsule', description: 'Box applies to capsule field', sort_order: 50, css_template: '' },
  ];
  const ir = await insertRows('style_deco_options', btRows);
  console.log(`  INSERT 5 rows: ${ir.ok ? 'OK' : 'FAIL(' + ir.status + ')'}`);
  ir.ok ? ok++ : fail++;

  // --- 8. box_style ---
  console.log('\n=== 8. box_style (扩展 box_target) ===');
  const bsRows = await fetchRows('style_deco_options', 'sub_dim=eq.box_style');
  for (const row of bsRows) {
    if (row.value === 'none' || !row.css_template) { console.log(`  ${row.value}: SKIP`); continue; }
    const newCss = transformBoxStyle(row.css_template, row.value);
    const r = await patchRow('style_deco_options', `sub_dim=eq.box_style&value=eq.${row.value}`, { css_template: newCss });
    console.log(`  ${row.value}: ${r.ok ? 'OK' : 'FAIL(' + r.status + ')'}`);
    r.ok ? ok++ : fail++;
  }

  console.log(`\n=== DONE: ${ok} OK, ${fail} FAIL ===`);
}

main().catch(err => { console.error('FATAL:', err); process.exit(1); });
