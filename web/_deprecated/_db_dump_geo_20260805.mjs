import { writeFileSync } from 'fs';
const HOST = 'opyeahbzibuupmkmjpkr.supabase.co';
const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjk3MDcsImV4cCI6MjA5MzYwNTcwN30.7kCHwI7lKy1jH5BjI4gOKqw2vEUxpsjRJar_94j4Srk';
const subdims = ['bg_pattern', 'floating_deco', 'corner_badge', 'edge_deco'];
const url = `https://${HOST}/rest/v1/style_element_options?select=id,sub_dim,value,css_template&sub_dim=in.(${subdims.join(',')})&order=id`;
const res = await fetch(url, { headers: { apikey: KEY, Authorization: 'Bearer ' + KEY } });
if (!res.ok) { console.error('HTTP', res.status, await res.text()); process.exit(1); }
const rows = await res.json();
writeFileSync('web/_db_dump_geo_20260805.json', JSON.stringify(rows, null, 2));
console.log('rows:', rows.length);
for (const r of rows) {
  const t = r.css_template || '';
  const hasSize = /(background-size|--el-(bg|float)-size|--el-(bg|float)-\d-size)/.test(t);
  const hasGeoTile = /(radial-gradient|repeating-linear-gradient|linear-gradient)/.test(t);
  console.log(r.id, '|', r.sub_dim, '|', r.value, '| len=', t.length, '| size?', hasSize, '| grad?', hasGeoTile);
}
