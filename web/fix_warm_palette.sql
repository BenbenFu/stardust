-- 修复 parse_style_pool.py 产生的错误 palette 名
-- 'warm' 不是合法的 palette key, 修正为 'novel_warm'
UPDATE "STYLE_POOL" SET style_json = jsonb_set(style_json, '{palette}', '"novel_warm"') WHERE style_json->>'palette' = 'warm';
