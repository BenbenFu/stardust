// 查 Supabase 表约束，确认 ON CONFLICT 失败的根因
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';

const SUPABASE_URL = 'https://opyeahbzibuupmkmjpkr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgxODkwNTQsImV4cCI6MjA2Mzc3NTA1NH0.qvV29atPm4L1Q90_5daK7mLSgK57WxDH3C3M9fencE';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const tables = ['style_palette_options', 'style_deco_options', 'STYLE_POOL', 'style_border_options', 'style_elements_options'];

for (const t of tables) {
  // 查主键信息
  const { data, error } = await supabase
    .rpc('get_primary_keys', { table_name: t })
    .maybeSingle();
  
  if (error) {
    console.log(`❌ ${t}: RPC 不可用 (${error.message})`);
  } else {
    console.log(`✅ ${t}: PK =`, data);
  }
}

// 改用 information_schema 查唯一约束
const { data: constraints, error: cError } = await supabase
  .from('information_schema.table_constraints')
  .select('table_name, constraint_type, constraint_name')
  .in('table_name', tables)
  .eq('constraint_type', 'UNIQUE');

if (cError) {
  console.log('❌ 无法查询 information_schema:', cError.message);
} else {
  console.log('\n唯一约束:');
  constraints.forEach(c => console.log(`  ${c.table_name}: ${c.constraint_name} (${c.constraint_type})`));
}
