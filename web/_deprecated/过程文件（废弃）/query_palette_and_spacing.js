/**
 * query_palette_and_spacing.js — 查 palette harmony 值 + spacing_scale css_template
 */

const SUPABASE_URL = 'https://opyeahbzibuupmkmjpkr.supabase.co';
const API_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjk3MDcsImV4cCI6MjA5MzYwNTcwN30.7kCHwI7lKy1jH5BjI4gOKqw2vEUxpsjRJar_94j4Srk';

async function queryPalette() {
  // 查 palette 表的 harmony_palette 值
  const url = `${SUPABASE_URL}/rest/v1/style_palette_options?sub_dim=eq.harmony_palette&select=value,bg,text_color,accent,muted&order=value.asc`;
  const res = await fetch(url, {
    headers: {
      'apikey': API_KEY,
      'Authorization': `Bearer ${API_KEY}`,
    }
  });
  if (!res.ok) {
    console.error('Palette query failed:', res.status, await res.text());
    return;
  }
  const data = await res.json();
  console.log('=== harmony_palette values ===');
  data.forEach(r => {
    console.log(`  ${r.value}  (bg=${r.bg}, text=${r.text_color}, accent=${r.accent}, muted=${r.muted})`);
  });
}

async function querySpacing() {
  // 查 layout 表的 spacing_scale css_template
  const url = `${SUPABASE_URL}/rest/v1/style_layout_options?sub_dim=eq.spacing_scale&select=value,css_template&order=value.asc`;
  const res = await fetch(url, {
    headers: {
      'apikey': API_KEY,
      'Authorization': `Bearer ${API_KEY}`,
    }
  });
  if (!res.ok) {
    console.error('Spacing query failed:', res.status, await res.text());
    return;
  }
  const data = await res.json();
  console.log('\n=== spacing_scale values ===');
  data.forEach(r => {
    console.log(`  ${r.value}:  css_template=${JSON.stringify(r.css_template)}`);
  });
}

async function main() {
  await queryPalette();
  await querySpacing();
}

main();
