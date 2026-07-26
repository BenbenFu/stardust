-- ============================================================================
-- floating_circle (id=34, floating_deco) 可见性修复 SQL
-- 作者：Agent（2026-07-25）
-- 根因（已用真实 DB 模板核对）：
--   用户报告"混合星空后变成 6 个平铺悬浮圆"。真实情况是：
--     · starfield(id=48) 的星点本身就是圆形 radial-gradient，靠 repeat 平铺
--       → 用户看到的"6 个圆"其实是星空星点，不是浮动圆；
--     · floating_circle(id=34) 只写 --el-float-1，且透明度仅 10%
--       → 几乎不可见，所以同开时只看见星点、误以为浮动圆被平铺。
--   此前误判为"composite 写死 none"（那只会让圆消失，不会平铺），
--   对应的 starfield_fix_20260724.sql 已执行但对该症状无改善——现澄清。
-- 修复：仅把 --el-float-1 的透明度 10% → 40%，size 140 → 150，使浮动圆清晰可辨，
--       与星空星点明确区分；其余 14 槽 composite 原样不动。
-- 透明值可在 30%–50% 间自定（越大越实）。
-- 执行人：用户（Agent 无 DB 写权限）。执行后硬刷新预览页确认。
-- ============================================================================

update style_element_options set css_template = '.gallery-card[data-style-element-float="floating_circle"]{
  --el-float-1: radial-gradient(circle, color-mix(in srgb, var(--card-accent, #888) 40%, transparent) 0 70px, transparent 72px);
  --el-float-size-1: 150px 150px;
  --el-float-pos-1: var(--el-float-anchor-pos, bottom -10px right -10px);
  --el-float-rep-1: no-repeat;
  background-image:var(--el-corner-1,none),var(--el-corner-2,none),var(--el-edge-1,none),var(--el-edge-2,none),var(--el-edge-3,none),var(--el-edge-4,none),var(--el-bg-1,none),var(--el-bg-2,none),var(--el-bg-3,none),var(--el-bg-4,none),var(--el-float-1,none),var(--el-float-2,none),var(--el-float-3,none),var(--el-float-4,none);
  background-size:var(--el-corner-size-1,auto),var(--el-corner-size-2,auto),var(--el-edge-size-1,auto),var(--el-edge-size-2,auto),var(--el-edge-size-3,auto),var(--el-edge-size-4,auto),var(--el-bg-size-1,auto),var(--el-bg-size-2,auto),var(--el-bg-size-3,auto),var(--el-bg-size-4,auto),var(--el-float-size-1,auto),var(--el-float-size-2,auto),var(--el-float-size-3,auto),var(--el-float-size-4,auto);
  background-position:var(--el-corner-pos-1,0 0),var(--el-corner-pos-2,0 0),var(--el-edge-pos-1,0 0),var(--el-edge-pos-2,0 0),var(--el-edge-pos-3,0 0),var(--el-edge-pos-4,0 0),var(--el-bg-pos-1,0 0),var(--el-bg-pos-2,0 0),var(--el-bg-pos-3,0 0),var(--el-bg-pos-4,0 0),var(--el-float-pos-1,0 0),var(--el-float-pos-2,0 0),var(--el-float-pos-3,0 0),var(--el-float-pos-4,0 0);
  background-repeat:var(--el-corner-rep-1,no-repeat),var(--el-corner-rep-2,no-repeat),var(--el-edge-rep-1,no-repeat),var(--el-edge-rep-2,no-repeat),var(--el-edge-rep-3,no-repeat),var(--el-edge-rep-4,no-repeat),var(--el-bg-rep-1,no-repeat),var(--el-bg-rep-2,no-repeat),var(--el-bg-rep-3,no-repeat),var(--el-bg-rep-4,no-repeat),var(--el-float-rep-1,no-repeat),var(--el-float-rep-2,no-repeat),var(--el-float-rep-3,no-repeat),var(--el-float-rep-4,no-repeat);
}'
where id = 34;
