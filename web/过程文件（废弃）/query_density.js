/**
 * query_density.js — 查 density css_template
 */

const SUPABASE_URL = 'https://opyeahbzibuupmkmjpkr.supabase.co';
const API_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjk3MDcsImV4cCI6MjA5MzYwNTcwN30.7kCHwI7lKy1jH5BjI4gOKqw2vEUxpsjRJar_94j4Srk';

async function queryDensity() {
  const url = `${SUPABASE_URL}/rest/v1/style_layout_options?sub_dim=eq.density&select=value,css_template&order=value.asc`;
  const res = await fetch(url, {
    headers: {
      'apikey': API_KEY,
      'Authorization': `Bearer ${API_KEY}`,
    }
  });
  if (!res.ok) {
    console.error('Density query failed:', res.status, await res.text());
    return;
  }
  const data = await res.json();
  console.log('=== density values ===');
  data.forEach(r => {
    console.log(`  ${r.value}:  css_template=${JSON.stringify(r.css_template)}`);
  });
}

queryDensity();
