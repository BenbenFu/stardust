-- ============================================================
-- 悬浮圆(floating_circle, id=34) 脱离 14 槽共享画布
-- 目标：消除「星空 × 悬浮圆」层叠争用（6 圆平铺 / 无法移动）
-- 做法：不再写 --el-float-1（不污染 .gallery-card 的 background-image 画布），
--       改为在始终挂载的 .card-deco-layer::before 上绘制，完全独立于 bg_pattern。
--       锚点变量 --el-float-pos-top/right/bottom/left/tf 已由引擎发射（无需改引擎）。
-- 幂等：重跑无害。执行后硬刷新预览页（Ctrl+Shift+R）重拉 dimensionCache。
-- 回退：见 element_revert_reorder_20260725.sql（id=34 还原到 14 槽形态）。
-- agent 无 DB 写权限，需在 Supabase SQL Editor 粘贴执行。
-- ============================================================

UPDATE style_element_options SET css_template = '.gallery-card[data-style-element-float="floating_circle"] .card-deco-layer::before {
  content: "";
  position: absolute;
  width: 140px;
  height: 140px;
  background: radial-gradient(circle, color-mix(in srgb, var(--card-accent, #888) 10%, transparent) 0 70px, transparent 72px);
  /* 锚点：用户选位置时引擎注入 --el-float-pos-*；未选则兜底到卡内右下角 */
  top: var(--el-float-pos-top, auto);
  right: var(--el-float-pos-right, 8px);
  bottom: var(--el-float-pos-bottom, 8px);
  left: var(--el-float-pos-left, auto);
  transform: var(--el-float-pos-tf, none);
  z-index: 4;
  pointer-events: none;
}' WHERE id = 34;
