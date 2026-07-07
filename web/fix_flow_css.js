/**
 * fix_flow_css.js — 清空 3 条 flow 的 css_template
 *
 * 问题: flow='vertical' 的 CSS 模板强制设置 --wm-*:vertical-rl + writing-mode:vertical-rl
 *       导致即使 flow_vertical checkbox 全未勾选，卡片仍然全部竖排
 * 修复: flow 现在只是 UI 预设标签，writing-mode 由 renderStyleJson 从 flow_vertical 全权计算
 *       清空所有 3 条 flow 的 css_template
 */

const SUPABASE_URL = 'https://opyeahbzibuupmkmjpkr.supabase.co';
const API_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjk3MDcsImV4cCI6MjA5MzYwNTcwN30.7kCHwI7lKy1jH5BjI4gOKqw2vEUxpsjRJar_94j4Srk';

async function patchRecord(value) {
  const url = `${SUPABASE_URL}/rest/v1/style_layout_options?sub_dim=eq.flow&value=eq.${value}`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      'apikey': API_KEY,
      'Authorization': `Bearer ${API_KEY}`,
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    },
    body: JSON.stringify({ css_template: '' }),
  });
  const ok = res.status === 204;
  console.log(`  ${ok ? 'OK' : 'FAIL'} (${res.status}) flow/${value} → css_template=''`);
  return ok;
}

async function main() {
  const flowValues = ['horizontal', 'vertical', 'mixed'];
  console.log('=== 清空 3 条 flow css_template ===\n');
  for (const v of flowValues) {
    await patchRecord(v);
  }
  console.log('\nDone.');
}

main().catch(e => { console.error(e); process.exit(1); });
