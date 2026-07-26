-- ============================================================================
-- starfield (id=48, bg_pattern) 修复 SQL
-- 作者：Agent（2026-07-24）
-- 问题：原 css_template 的 14 槽主合成里，corner/edge/float 四组的槽位被
--       硬编码成字面 `none`，而非 `var(--el-<组>-<n>, none)`。
--       后果：同卡开 starfield + floating_circle（或其它背景装饰）时，两条
--       同特异性 background-image 规则按注入顺序后者胜，写死 none 那条把同开的
--       浮动圆/角标整组抹掉或冻结 → 浮动圆消失/无法随 floating_deco_pos 移动。
-- 修复：主合成 14 槽全部改为 var() 引用（保留原 --el-bg-1..4 星空定义不动）。
-- 执行人：用户（Agent 无 DB 写权限）。执行后硬刷新预览页确认。
-- ============================================================================

update style_element_options set css_template = '.gallery-card[data-style-element-bg="starfield"]{
  --el-bg-1:radial-gradient(2px 2px at 12% 18%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 78% 12%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 42% 38%,var(--card-text) 50%,transparent 100%),radial-gradient(2px 2px at 90% 28%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 22% 55%,var(--card-text) 50%,transparent 100%),radial-gradient(2px 2px at 58% 72%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 6% 82%,var(--card-text) 50%,transparent 100%),radial-gradient(1.5px 1.5px at 95% 65%,var(--card-text) 50%,transparent 100%),radial-gradient(2px 2px at 35% 90%,var(--card-text) 50%,transparent 100%);
  --el-bg-size-1:211px 173px;--el-bg-pos-1:0 0;--el-bg-rep-1:repeat;
  --el-bg-2:radial-gradient(1.2px 1.2px at 25% 8%,var(--card-text) 50%,transparent 100%),radial-gradient(1px 1px at 63% 30%,var(--card-text) 50%,transparent 100%),radial-gradient(1.2px 1.2px at 88% 48%,var(--card-text) 50%,transparent 100%),radial-gradient(1px 1px at 15% 60%,var(--card-text) 50%,transparent 100%),radial-gradient(1.2px 1.2px at 48% 78%,var(--card-text) 50%,transparent 100%),radial-gradient(1px 1px at 72% 92%,var(--card-text) 50%,transparent 100%),radial-gradient(1.2px 1.2px at 5% 35%,var(--card-text) 50%,transparent 100%);
  --el-bg-size-2:167px 199px;--el-bg-pos-2:47px 23px;--el-bg-rep-2:repeat;
  --el-bg-3:radial-gradient(.8px .8px at 40% 15%,var(--card-text) 50%,transparent 100%),radial-gradient(.6px .6px at 82% 40%,var(--card-text) 50%,transparent 100%),radial-gradient(.8px .8px at 18% 70%,var(--card-text) 50%,transparent 100%),radial-gradient(.6px .6px at 55% 85%,var(--card-text) 50%,transparent 100%),radial-gradient(.8px .8px at 92% 10%,var(--card-text) 50%,transparent 100%),radial-gradient(.4px .4px at 8% 25%,var(--card-text) 50%,transparent 100%),radial-gradient(.3px .3px at 52% 5%,var(--card-text) 50%,transparent 100%),radial-gradient(.4px .4px at 75% 55%,var(--card-text) 50%,transparent 100%),radial-gradient(.3px .3px at 28% 82%,var(--card-text) 50%,transparent 100%);
  --el-bg-size-3:137px 151px;--el-bg-pos-3:71px 59px;--el-bg-rep-3:repeat;
  --el-bg-4:radial-gradient(.5px .5px at 30% 50%,var(--card-text) 50%,transparent 100%),radial-gradient(.4px .4px at 70% 20%,var(--card-text) 50%,transparent 100%),radial-gradient(.5px .5px at 50% 80%,var(--card-text) 50%,transparent 100%),radial-gradient(ellipse 200px 120px at 18% 78%,color-mix(in srgb,var(--card-muted) 5%,transparent) 0%,transparent 50%),radial-gradient(ellipse 160px 90px at 82% 22%,color-mix(in srgb,var(--card-muted) 4%,transparent) 0%,transparent 50%);
  --el-bg-size-4:100% 100%;--el-bg-pos-4:0 0;--el-bg-rep-4:no-repeat;
  background-image:
    var(--el-corner-1, none), var(--el-corner-2, none),
    var(--el-edge-1, none), var(--el-edge-2, none), var(--el-edge-3, none), var(--el-edge-4, none),
    var(--el-bg-1, none), var(--el-bg-2, none), var(--el-bg-3, none), var(--el-bg-4, none),
    var(--el-float-1, none), var(--el-float-2, none), var(--el-float-3, none), var(--el-float-4, none);
  background-size:
    var(--el-corner-size-1, auto), var(--el-corner-size-2, auto),
    var(--el-edge-size-1, auto), var(--el-edge-size-2, auto), var(--el-edge-size-3, auto), var(--el-edge-size-4, auto),
    var(--el-bg-size-1, auto), var(--el-bg-size-2, auto), var(--el-bg-size-3, auto), var(--el-bg-size-4, auto),
    var(--el-float-size-1, auto), var(--el-float-size-2, auto), var(--el-float-size-3, auto), var(--el-float-size-4, auto);
  background-position:
    var(--el-corner-pos-1, 0 0), var(--el-corner-pos-2, 0 0),
    var(--el-edge-pos-1, 0 0), var(--el-edge-pos-2, 0 0), var(--el-edge-pos-3, 0 0), var(--el-edge-pos-4, 0 0),
    var(--el-bg-pos-1, 0 0), var(--el-bg-pos-2, 0 0), var(--el-bg-pos-3, 0 0), var(--el-bg-pos-4, 0 0),
    var(--el-float-pos-1, 0 0), var(--el-float-pos-2, 0 0), var(--el-float-pos-3, 0 0), var(--el-float-pos-4, 0 0);
  background-repeat:
    var(--el-corner-rep-1, no-repeat), var(--el-corner-rep-2, no-repeat),
    var(--el-edge-rep-1, no-repeat), var(--el-edge-rep-2, no-repeat), var(--el-edge-rep-3, no-repeat), var(--el-edge-rep-4, no-repeat),
    var(--el-bg-rep-1, no-repeat), var(--el-bg-rep-2, no-repeat), var(--el-bg-rep-3, no-repeat), var(--el-bg-rep-4, no-repeat),
    var(--el-float-rep-1, no-repeat), var(--el-float-rep-2, no-repeat), var(--el-float-rep-3, no-repeat), var(--el-float-rep-4, no-repeat);
}'
where id = 48;
