# -*- coding: utf-8 -*-
"""
生成 element 维度兼容性重构产物：
  1) style_element_refactor_20260723.sql  —— 幂等 UPDATE（按 id），交给用户执行（agent 无 DB 写权限）
  2) element_compat_test.html             —— 自包含可视化验证页（CSS 与 SQL 完全一致，供用户肉眼确认）

核心机制：
  - 背景类装饰（角标/背景纹/边缘/浮动）只写各自的 --el-* 槽位变量，
    主合成块(14 槽)在每个背景元素里完全一致 → CSS 变量跨规则解析天然叠加，互不覆盖。
  - 文本类装饰（corner_ribbon / tamagotchi_label / art_deco_diamond）走专属伪元素，固定分配。
  - box/clip 类（stamp_perforation / notched_corner）正交，零冲突。
"""

# ---- 固定 14 槽主合成（角标2 / 边缘4 / 背景纹4 / 浮动4），顺序不可改 ----
COMPOSITE = """  /* —— 装饰图层画布：固定 14 槽（角标2 / 边缘4 / 背景纹4 / 浮动4），顺序不可改 —— */
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
"""

def bg(attr, value, vars_block):
    return (".gallery-card[data-style-element-%s=\"%s\"] {\n" % (attr, value)
            + vars_block.rstrip("\n") + "\n"
            + COMPOSITE.rstrip("\n") + "\n"
            + "}")

# ====== 角标 corner (attr=corner) ======
E_circle_stamp = bg("corner", "circle_stamp", """  --el-corner-1: radial-gradient(circle, var(--card-accent, #888) 50%, transparent 52%);
  --el-corner-size-1: 14px 14px;
  --el-corner-pos-1: var(--el-corner-anchor-pos, top 6px right 6px);
  --el-corner-rep-1: no-repeat;""")

# page_fold —— 经典 dog-ear（翻起的页角 + 折痕阴影），走角标 corner-1,2 双槽
# corner-1 = 翻角页背(muted 三角)；corner-2 = 沿折痕的深色细线(crease shadow)
E_page_fold = bg("corner", "page_fold", """  --el-corner-1: linear-gradient(225deg, var(--card-muted, #ccc) 0 18px, transparent 18px);
  --el-corner-size-1: 18px 18px;
  --el-corner-pos-1: top right;
  --el-corner-rep-1: no-repeat;
  --el-corner-2: linear-gradient(225deg, transparent 0 16px, var(--card-text, #222) 16px 18px, transparent 18px);
  --el-corner-size-2: 18px 18px;
  --el-corner-pos-2: top right;
  --el-corner-rep-2: no-repeat;""")

E_dot_status = bg("corner", "dot_status", """  --el-corner-1: radial-gradient(circle, var(--card-bg, #fff) 0 3px, var(--card-accent, #888) 3px 5px, transparent 5px);
  --el-corner-size-1: 11px 11px;
  --el-corner-pos-1: var(--el-corner-anchor-pos, top 6px right 6px);
  --el-corner-rep-1: no-repeat;""")

# corner_ribbon —— 文本类，走 ::after（不写背景）
# 注意：① 选择器必须带前导 . ；② content 用固定字面量（两参 attr() 在 content 上不被支持，引擎也未发射该属性）
#      ③ 卡片根 overflow:hidden 会裁掉探出角落的丝带，故锚定在卡内右上角(完全可见)
#      ④ 位置走引擎发射的 --el-corner-pos-* 变量（8 锚点），原生兜底 = 右上角 12px；rotate(45deg) 为其固有设计，
#         引擎居中锚点(如 top-center)会注入 translateX(-50%) 作 --el-corner-pos-tf，叠加后仍保持旋转丝带。
E_corner_ribbon = """
.gallery-card[data-style-element-corner="corner_ribbon"]::after {
  content: "NEW";
  position: absolute;
  top: var(--el-corner-pos-top, 12px);
  right: var(--el-corner-pos-right, 12px);
  bottom: var(--el-corner-pos-bottom, auto);
  left: var(--el-corner-pos-left, auto);
  transform: var(--el-corner-pos-tf, none) rotate(45deg);
  background: var(--card-accent, #888); color: var(--card-bg, #fff);
  font-size: 8px; font-weight: 700; letter-spacing: 0.1em;
  padding: 2px 10px;
  transform-origin: center; pointer-events: none; z-index: 4;
  border-radius: 2px; box-shadow: 0 1px 3px rgba(0,0,0,0.25);
}"""

# ====== 背景纹 bg (attr=bg) ======
E_dot_grid = bg("bg", "dot_grid", """  --el-bg-1: radial-gradient(circle, var(--card-muted, #ccc) 1px, transparent 1.6px);
  --el-bg-size-1: 16px 16px;
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;""")

E_fine_grid = bg("bg", "fine_grid", """  --bg-grid-line: color-mix(in srgb, var(--card-muted, #ccc) 14%, transparent);
  --el-bg-1: linear-gradient(var(--bg-grid-line) 1px, transparent 1px);
  --el-bg-2: linear-gradient(90deg, var(--bg-grid-line) 1px, transparent 1px);
  --el-bg-size-1: 20px 20px; --el-bg-size-2: 20px 20px;
  --el-bg-pos-1: 0 0; --el-bg-pos-2: 0 0;
  --el-bg-rep-1: repeat; --el-bg-rep-2: repeat;""")

E_horizontal_lines = bg("bg", "horizontal_lines", """  --el-bg-1: repeating-linear-gradient(to bottom, transparent, transparent calc(1.5em - 1px), var(--card-muted, #ccc) calc(1.5em - 1px), var(--card-muted, #ccc) 1.5em);
  --el-bg-size-1: 100% 1.5em;
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;""")

E_gradient_overlay = bg("bg", "gradient_overlay", """  --el-bg-1: linear-gradient(to bottom, transparent 55%, color-mix(in srgb, var(--card-bg, #fff) 65%, var(--card-muted, #ccc) 35%) 100%);
  --el-bg-size-1: 100% 100%;
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: no-repeat;""")

E_terminal_scanlines = bg("bg", "terminal_scanlines", """  --el-bg-1: repeating-linear-gradient(to bottom, transparent, transparent 2px, rgba(0,0,0,0.06) 2px, rgba(0,0,0,0.06) 4px);
  --el-bg-size-1: 100% 4px;
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;""")

# ====== 边缘 edge (attr=edge) ======
E_bracket_frame = bg("edge", "bracket_frame", """  --el-edge-1: linear-gradient(var(--card-accent, #888), var(--card-accent, #888));
  --el-edge-2: linear-gradient(var(--card-accent, #888), var(--card-accent, #888));
  --el-edge-3: linear-gradient(var(--card-accent, #888), var(--card-accent, #888));
  --el-edge-4: linear-gradient(var(--card-accent, #888), var(--card-accent, #888));
  --el-edge-size-1: 12px 2px; --el-edge-size-2: 2px 12px; --el-edge-size-3: 12px 2px; --el-edge-size-4: 2px 12px;
  --el-edge-pos-1: 6px 6px; --el-edge-pos-2: 6px 6px; --el-edge-pos-3: bottom 6px right 6px; --el-edge-pos-4: bottom 6px right 6px;
  --el-edge-rep-1: no-repeat; --el-edge-rep-2: no-repeat; --el-edge-rep-3: no-repeat; --el-edge-rep-4: no-repeat;""")

E_tape_stripe = bg("edge", "tape_stripe", """  --el-edge-1: repeating-linear-gradient(45deg, transparent, transparent 8px, color-mix(in srgb, var(--card-muted, #ccc) 28%, transparent) 8px, color-mix(in srgb, var(--card-muted, #ccc) 28%, transparent) 10px);
  --el-edge-size-1: auto;
  --el-edge-pos-1: 0 0;
  --el-edge-rep-1: repeat;""")

# stamp_perforation —— mask 类，四边 radial-gradient 镂空齿孔（真正的邮票齿孔，非虚线）
# ⚠️ 关键修复：每张遮罩(上/下/左/右)必须用 100% 维度的瓦片铺满整卡（上/下 = 宽 13px×高 100%；
#   左/右 = 宽 100%×高 13px），否则遮罩只覆盖 13px 边缘条，mask-composite:intersect 会把整卡内部
#   判为「未覆盖=透明」→ 卡片整体消失。铺满后，仅边缘半圆孔透出底色，内部保持不透明。
# 不走背景画布、不抢伪元素；齿孔为透明(透出页面底色)，符合邮票质感
E_stamp_perforation = """
.gallery-card[data-style-element-edge="stamp_perforation"] {
  --sp-r: 4px;   /* 齿孔半径 */
  --sp-g: 13px;  /* 齿孔间距 */
  -webkit-mask:
    radial-gradient(circle var(--sp-r) at 50% 0,    #0000 96%, #000) repeat-x 0 0 / var(--sp-g) 100%,
    radial-gradient(circle var(--sp-r) at 50% 100%, #0000 96%, #000) repeat-x 0 0 / var(--sp-g) 100%,
    radial-gradient(circle var(--sp-r) at 0 50%,    #0000 96%, #000) repeat-y 0 0 / 100% var(--sp-g),
    radial-gradient(circle var(--sp-r) at 100% 50%, #0000 96%, #000) repeat-y 0 0 / 100% var(--sp-g);
  -webkit-mask-composite: source-in, source-in, source-in;
          mask:
    radial-gradient(circle var(--sp-r) at 50% 0,    #0000 96%, #000) repeat-x 0 0 / var(--sp-g) 100%,
    radial-gradient(circle var(--sp-r) at 50% 100%, #0000 96%, #000) repeat-x 0 0 / var(--sp-g) 100%,
    radial-gradient(circle var(--sp-r) at 0 50%,    #0000 96%, #000) repeat-y 0 0 / 100% var(--sp-g),
    radial-gradient(circle var(--sp-r) at 100% 50%, #0000 96%, #000) repeat-y 0 0 / 100% var(--sp-g);
          mask-composite: intersect;
}"""

# notched_corner —— clip 类（不写背景）
# 位置走引擎发射的 data-style-element-edge-anchor（仅四角有意义；整周/整框型边缘忽略）。
# 默认(无 anchor 属性) = 右上角切角；引擎按 edge_deco_pos 注入 top-left/bottom-left/bottom-right 变体。
E_notched_corner = """
.gallery-card[data-style-element-edge="notched_corner"] {
  clip-path: polygon(0 0, calc(100% - 16px) 0, 100% 16px, 100% 100%, 0 100%);
}
.gallery-card[data-style-element-edge="notched_corner"][data-style-element-edge-anchor="top-left"] {
  clip-path: polygon(16px 0, 100% 0, 100% 100%, 0 100%, 0 16px);
}
.gallery-card[data-style-element-edge="notched_corner"][data-style-element-edge-anchor="bottom-left"] {
  clip-path: polygon(0 0, 100% 0, 100% 100%, 16px 100%, 0 calc(100% - 16px));
}
.gallery-card[data-style-element-edge="notched_corner"][data-style-element-edge-anchor="bottom-right"] {
  clip-path: polygon(0 0, 100% 0, 100% calc(100% - 16px), calc(100% - 16px) 100%, 0 100%);
}"""

# ====== 浮动 float (attr=float) ======
E_floating_circle = bg("float", "floating_circle", """  --el-float-1: radial-gradient(circle, color-mix(in srgb, var(--card-accent, #888) 10%, transparent) 0 70px, transparent 72px);
  --el-float-size-1: 140px 140px;
  --el-float-pos-1: var(--el-float-anchor-pos, bottom -10px right -10px);
  --el-float-rep-1: no-repeat;""")

E_scatter_dots = bg("float", "scatter_dots", """  --el-float-1: radial-gradient(circle, var(--card-accent, #888) 1.2px, transparent 1.6px);
  --el-float-size-1: 46px 46px;
  --el-float-pos-1: var(--el-float-anchor-pos, top 4px right 6px);
  --el-float-rep-1: repeat;
  --el-float-2: radial-gradient(circle, var(--card-accent, #888) 1px, transparent 1.4px);
  --el-float-size-2: 70px 70px;
  --el-float-pos-2: var(--el-float-anchor-pos, top 30px left 10px);
  --el-float-rep-2: repeat;""")

# tamagotchi_label —— 文本类 ::before（不写背景）
# 位置走引擎发射的 --el-float-pos-* 变量（8 锚点），原生兜底 = 顶边居中(top 6px / left 50% / translateX(-50%))。
E_tamagotchi_label = """
.gallery-card[data-style-element-float="tamagotchi_label"]::before {
  content: "TAMAGOTCHI";
  position: absolute;
  top: var(--el-float-pos-top, 6px);
  left: var(--el-float-pos-left, 50%);
  right: var(--el-float-pos-right, auto);
  bottom: var(--el-float-pos-bottom, auto);
  transform: var(--el-float-pos-tf, translateX(-50%));
  font-size: 10px; letter-spacing: 1px; color: var(--card-accent, #888);
  font-family: monospace; pointer-events: none; z-index: 4;
}"""

# art_deco_diamond —— 文本类 ::before + ::after（不写背景）
E_art_deco_diamond = """
.gallery-card[data-style-element-float="art_deco_diamond"]::before {
  content: "\\25C6 \\25C7 \\25C6 \\25C7 \\25C6";
  position: absolute; top: 0; left: 0; right: 0; text-align: center;
  font-size: 8px; letter-spacing: 4px; color: var(--card-accent, #888);
  padding: 4px 0; border-top: 1px solid var(--card-accent, #888);
  border-bottom: 1px solid var(--card-accent, #888);
  pointer-events: none; z-index: 3; box-sizing: border-box;
}
.gallery-card[data-style-element-float="art_deco_diamond"]::after {
  content: "\\25C6 \\25C7 \\25C6 \\25C7 \\25C6";
  position: absolute; bottom: 0; left: 0; right: 0; text-align: center;
  font-size: 8px; letter-spacing: 4px; color: var(--card-accent, #888);
  padding: 4px 0; border-top: 1px solid var(--card-accent, #888);
  pointer-events: none; z-index: 3; box-sizing: border-box;
}"""

# ====== 汇总：id -> 新 css_template ======
ROWS = {
    18: E_circle_stamp,
    19: E_page_fold,
    21: E_dot_status,
    20: E_corner_ribbon,
    23: E_dot_grid,
    24: E_fine_grid,
    25: E_horizontal_lines,
    26: E_gradient_overlay,
    27: E_terminal_scanlines,
    30: E_bracket_frame,
    32: E_tape_stripe,
    29: E_stamp_perforation,
    31: E_notched_corner,
    34: E_floating_circle,
    35: E_scatter_dots,
    37: E_tamagotchi_label,
    36: E_art_deco_diamond,
}

# 完整 element CSS（供测试页与手册使用，顺序同 ROWS）
ELEMENT_CSS = "\n".join(ELEMENT_CSS_line for ELEMENT_CSS_line in [
    E_circle_stamp, E_page_fold, E_dot_status, E_corner_ribbon,
    E_dot_grid, E_fine_grid, E_horizontal_lines, E_gradient_overlay, E_terminal_scanlines,
    E_bracket_frame, E_tape_stripe, E_stamp_perforation, E_notched_corner,
    E_floating_circle, E_scatter_dots, E_tamagotchi_label, E_art_deco_diamond,
])

# ---- 生成 SQL ----
sql = "-- ============================================================\n"
sql += "-- element 维度兼容性重构（角标/背景纹/边缘/浮动 四可叠加）\n"
sql += "-- 生成时间 2026-07-23  |  幂等：按主键 id UPDATE\n"
sql += "-- 执行方式：在 Supabase SQL Editor 粘贴执行；agent 无写权限，需人工执行\n"
sql += "-- ============================================================\n\n"
for _id, css in ROWS.items():
    # SQL 单引号字符串：CSS 内无单引号，安全；换行直接保留
    sql += "UPDATE style_element_options SET css_template = '%s' WHERE id = %d;\n" % (css, _id)
sql += "\n-- 校验：SELECT id, sub_dim, value FROM style_element_options WHERE id IN (%s) ORDER BY id;\n" % (
    ", ".join(str(i) for i in sorted(ROWS)))

with open("style_element_refactor_20260723.sql", "w", encoding="utf-8") as f:
    f.write(sql)
print("SQL written:", len(sql), "bytes")

# ---- 生成可视化验证页 ----
html = """<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>element 兼容性重构 · 可视化验证</title>
<style>
:root { --demo-w: 300px; }
body { font-family: -apple-system, "PingFang SC", "Microsoft YaHei", sans-serif;
  background:#f4f4f5; color:#222; margin:0; padding:24px; }
h1 { font-size:18px; } h2 { font-size:14px; margin-top:28px; color:#555; }
.grid { display:flex; flex-wrap:wrap; gap:18px; margin-top:12px; }
.cap { font-size:11px; color:#888; margin-top:6px; max-width:var(--demo-w); }

/* ===== 卡片骨架（与 style-engine BASE_CSS 对齐） ===== */
.gallery-card {
  display:flex; flex-direction:column; position:relative; overflow:hidden;
  width:var(--demo-w); height:200px; padding:0;
  background: var(--card-bg, transparent); color: var(--card-text, inherit);
  border-width: var(--border-width, 0); border-style: var(--border-style, none);
  border-color: var(--card-accent, transparent); box-sizing:border-box;
}
.card-header-band { height:6px; }
.card-content { flex:1 1 auto; padding:12px; display:flex; flex-direction:column; gap:6px; }
.card-title { font-weight:600; font-size:18px; color:var(--card-text); }
.card-date { color:var(--card-muted); font-size:11px; }
.card-highlights { font-size:12px; color:var(--card-text); opacity:.85; }

/* ===== 重构后的 element CSS（与 SQL 完全一致） ===== */
%s
</style>
</head>
<body>
<h1>element 维度兼容性重构 · 可视化验证</h1>
<p style="font-size:12px;color:#777">每张卡设定 --card-bg/--card-text/--card-accent/--card-muted 四个调色槽。背景类装饰走共享 14 槽画布，文本类走专属伪元素。</p>

<h2>A. 四装饰全部独立（单元素）</h2>
<div class="grid">
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#e0563f;--card-muted:#bbb" data-style-element-corner="circle_stamp"><div class="card-content"><div class="card-title">角标·圆印</div></div></div><div class="cap">corner=circle_stamp</div></div>
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#3f7fe0;--card-muted:#bbb" data-style-element-bg="dot_grid"><div class="card-content"><div class="card-title">背景·点阵</div></div></div><div class="cap">bg=dot_grid</div></div>
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#2fa84f;--card-muted:#bbb" data-style-element-edge="bracket_frame"><div class="card-content"><div class="card-title">边缘·方括号</div></div></div><div class="cap">edge=bracket_frame</div></div>
  <div><div class="gallery-card" style="--card-bg:#ffd9a0;--card-text:#5a3a12;--card-accent:#c0392b;--card-muted:#c9a06a" data-style-element-edge="stamp_perforation"><div class="card-content"><div class="card-title">边缘·齿孔</div></div></div><div class="cap">edge=stamp_perforation（四边镂空，独立）</div></div>
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#c0392b;--card-muted:#bbb" data-style-element-float="floating_circle"><div class="card-content"><div class="card-title">浮动·圆</div></div></div><div class="cap">float=floating_circle</div></div>
</div>

<h2>B. 四装饰全叠加（角标+背景纹+边缘+浮动 同时）</h2>
<div class="grid">
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#e0563f;--card-muted:#bbb" data-style-element-corner="page_fold" data-style-element-bg="dot_grid" data-style-element-edge="bracket_frame" data-style-element-float="floating_circle"><div class="card-content"><div class="card-title">谜语卡·叠加</div><div class="card-highlights">折角+点阵+方括号+浮动圆，四者共存</div></div></div><div class="cap">corner=page_fold + bg=dot_grid + edge=bracket_frame + float=floating_circle</div></div>
  <div><div class="gallery-card" style="--card-bg:#fdf6e3;--card-text:#3a2e1a;--card-accent:#b58900;--card-muted:#cbb994" data-style-element-corner="dot_status" data-style-element-bg="horizontal_lines" data-style-element-edge="tape_stripe" data-style-element-float="scatter_dots"><div class="card-content"><div class="card-title">便签·叠加</div><div class="card-highlights">点状角标+横线+胶带纹+散点</div></div></div><div class="cap">corner=dot_status + bg=horizontal_lines + edge=tape_stripe + float=scatter_dots</div></div>
</div>

<h2>C. 文本装饰（专属伪元素）与背景装饰共存</h2>
<div class="grid">
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#c0392b;--card-muted:#bbb" data-style-element-corner="corner_ribbon" data-style-element-bg="fine_grid"><div class="card-content"><div class="card-title">特惠卡</div><div class="card-highlights">丝带(::after) + 精细方格背景</div></div></div><div class="cap">corner=corner_ribbon ::after + bg=fine_grid</div></div>
  <div><div class="gallery-card" style="--card-bg:#1a1a2e;--card-text:#eee;--card-accent:#ffcf3f;--card-muted:#888" data-style-element-float="tamagotchi_label" data-style-element-bg="terminal_scanlines"><div class="card-content"><div class="card-title">复古终端</div><div class="card-highlights">TAMAGOTCHI(::before) + 扫描线</div></div></div><div class="cap">float=tamagotchi_label ::before + bg=terminal_scanlines</div></div>
  <div><div class="gallery-card" style="--card-bg:#fff8f0;--card-text:#333;--card-accent:#a0522d;--card-muted:#d3b8a0" data-style-element-float="art_deco_diamond" data-style-element-edge="stamp_perforation"><div class="card-content"><div class="card-title">Art Deco</div><div class="card-highlights">菱形(::before+::after) + 邮票齿孔</div></div></div><div class="cap">float=art_deco_diamond 双伪元素 + edge=stamp_perforation</div></div>
</div>

<h2>D. 边缘类正交（clip / outline 不抢背景与伪元素）</h2>
<div class="grid">
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#e0563f;--card-muted:#bbb" data-style-element-edge="notched_corner" data-style-element-bg="gradient_overlay"><div class="card-content"><div class="card-title">切角</div><div class="card-highlights">clip-path + 渐变叠层</div></div></div><div class="cap">edge=notched_corner + bg=gradient_overlay</div></div>
</div>

<h2>E. 位置锚点演示（同一装饰贴不同角，无需另建条目）</h2>
<p style="font-size:12px;color:#777">下面 4 张卡都是 <b>同一个 corner_ribbon</b>，仅靠引擎注入的 --el-corner-* 位置变量切换到四角；切角卡演示 data-style-element-edge-anchor 切到左下角。</p>
<div class="grid">
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#c0392b;--card-muted:#bbb" data-style-element-corner="corner_ribbon"><div class="card-content"><div class="card-title">丝带·右上(原生)</div></div></div><div class="cap">corner=corner_ribbon（无变量，原生右上）</div></div>
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#c0392b;--card-muted:#bbb; --el-corner-anchor-pos: top 12px left 12px; --el-corner-pos-top:12px; --el-corner-pos-left:12px; --el-corner-pos-right:auto; --el-corner-pos-bottom:auto; --el-corner-pos-tf:none" data-style-element-corner="corner_ribbon"><div class="card-content"><div class="card-title">丝带·左上</div></div></div><div class="cap">corner=corner_ribbon（注入左上变量）</div></div>
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#c0392b;--card-muted:#bbb; --el-corner-anchor-pos: bottom 12px left 12px; --el-corner-pos-bottom:12px; --el-corner-pos-left:12px; --el-corner-pos-top:auto; --el-corner-pos-right:auto; --el-corner-pos-tf:none" data-style-element-corner="corner_ribbon"><div class="card-content"><div class="card-title">丝带·左下</div></div></div><div class="cap">corner=corner_ribbon（注入左下变量）</div></div>
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#c0392b;--card-muted:#bbb; --el-corner-anchor-pos: bottom 12px right 12px; --el-corner-pos-bottom:12px; --el-corner-pos-right:12px; --el-corner-pos-top:auto; --el-corner-pos-left:auto; --el-corner-pos-tf:none" data-style-element-corner="corner_ribbon"><div class="card-content"><div class="card-title">丝带·右下</div></div></div><div class="cap">corner=corner_ribbon（注入右下变量）</div></div>
  <div><div class="gallery-card" style="--card-bg:#fff;--card-text:#222;--card-accent:#e0563f;--card-muted:#bbb" data-style-element-edge="notched_corner" data-style-element-edge-anchor="bottom-left"><div class="card-content"><div class="card-title">切角·左下</div><div class="card-highlights">data-style-element-edge-anchor=bottom-left</div></div></div><div class="cap">edge=notched_corner（锚点切到左下角）</div></div>
</div>
</body>
</html>
""" % ELEMENT_CSS

with open("element_compat_test.html", "w", encoding="utf-8") as f:
    f.write(html)
print("HTML written:", len(html), "bytes")
print("Rows updated:", len(ROWS))
