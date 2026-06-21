// 查 STYLE_POOL 里陀思妥耶夫斯基的 style_json
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';

const SUPABASE_URL = 'https://opyeahbzibuupmkmjpkr.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgxODkwNTQsImV4cCI6MjA2Mzc3NTA1NH0.qvV29atPm4L1Q90_5daK7mLSgK57WxDH3C3M9fencE';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const { data, error } = await supabase
  .from('STYLE_POOL')
  .select('name, style_json')
  .eq('name', '陀思妥耶夫斯基')
  .single();

if (error) {
  console.error('Error:', error);
} else {
  console.log('name:', data.name);
  console.log('style_json:', JSON.stringify(data.style_json, null, 2));
}
