-- 几何纹理尺寸/间距统一控制：硬编码尺寸/间距 -> 变量引用
-- 引擎按需发射 --el-geo-gap(间距/步长) / --el-geo-thick(尺寸/粗细)；不填则回退各模板原值（非破坏性）。
-- 接入：dot_grid(23) fine_grid(24) horizontal_lines(25) terminal_scanlines(27) grain_noise(51) scatter_dots(35)

UPDATE style_element_options SET css_template = $$.gallery-card[data-style-element-bg="dot_grid"] {
  --el-bg-1: radial-gradient(circle, var(--card-muted, #ccc) var(--el-geo-thick, 1px), transparent calc(var(--el-geo-thick, 1px) + 0.6px));
  --el-bg-size-1: var(--el-geo-gap, 16px) var(--el-geo-gap, 16px);
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;
  /* —— 装饰图层画布：固定 14 槽（角标2 / 边缘4 / 背景纹4 / 浮动4），顺序不可改 —— */
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
}$$ WHERE id = 23;
UPDATE style_element_options SET css_template = $$.gallery-card[data-style-element-bg="fine_grid"] {
  --bg-grid-line: color-mix(in srgb, var(--card-muted, #ccc) 14%, transparent);
  --el-bg-1: linear-gradient(var(--bg-grid-line) var(--el-geo-thick, 1px), transparent var(--el-geo-thick, 1px));
  --el-bg-2: linear-gradient(90deg, var(--bg-grid-line) var(--el-geo-thick, 1px), transparent var(--el-geo-thick, 1px));
  --el-bg-size-1: var(--el-geo-gap, 20px) var(--el-geo-gap, 20px); --el-bg-size-2: var(--el-geo-gap, 20px) var(--el-geo-gap, 20px);
  --el-bg-pos-1: 0 0; --el-bg-pos-2: 0 0;
  --el-bg-rep-1: repeat; --el-bg-rep-2: repeat;
  /* —— 装饰图层画布：固定 14 槽（角标2 / 边缘4 / 背景纹4 / 浮动4），顺序不可改 —— */
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
}$$ WHERE id = 24;
UPDATE style_element_options SET css_template = $$.gallery-card[data-style-element-bg="horizontal_lines"] {
  --el-bg-1: repeating-linear-gradient(to bottom, transparent, transparent calc(var(--el-geo-gap, 1.5em) - var(--el-geo-thick, 1px)), var(--card-muted, #ccc) calc(var(--el-geo-gap, 1.5em) - var(--el-geo-thick, 1px)), var(--card-muted, #ccc) var(--el-geo-gap, 1.5em));
  --el-bg-size-1: 100% var(--el-geo-gap, 1.5em);
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;
  /* —— 装饰图层画布：固定 14 槽（角标2 / 边缘4 / 背景纹4 / 浮动4），顺序不可改 —— */
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
}$$ WHERE id = 25;
UPDATE style_element_options SET css_template = $$.gallery-card[data-style-element-bg="terminal_scanlines"] {
  --el-bg-1: repeating-linear-gradient(to bottom, transparent, transparent var(--el-geo-thick, 2px), rgba(0,0,0,0.06) var(--el-geo-thick, 2px), rgba(0,0,0,0.06) var(--el-geo-gap, 4px));
  --el-bg-size-1: 100% var(--el-geo-gap, 4px);
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;
  /* —— 装饰图层画布：固定 14 槽（角标2 / 边缘4 / 背景纹4 / 浮动4），顺序不可改 —— */
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
}$$ WHERE id = 27;
UPDATE style_element_options SET css_template = $$.gallery-card[data-style-element-float="scatter_dots"] {
  --el-float-1: radial-gradient(circle, var(--card-accent, #888) var(--el-geo-thick, 1.2px), transparent calc(var(--el-geo-thick, 1.2px) + 0.4px));
  --el-float-size-1: var(--el-geo-gap, 46px) var(--el-geo-gap, 46px);
  --el-float-pos-1: var(--el-float-anchor-pos, top 4px right 6px);
  --el-float-rep-1: repeat;
  --el-float-2: radial-gradient(circle, var(--card-accent, #888) var(--el-geo-thick, 1px), transparent calc(var(--el-geo-thick, 1px) + 0.4px));
  --el-float-size-2: var(--el-geo-gap, 70px) var(--el-geo-gap, 70px);
  --el-float-pos-2: var(--el-float-anchor-pos, top 30px left 10px);
  --el-float-rep-2: repeat;
  /* —— 装饰图层画布：固定 14 槽（角标2 / 边缘4 / 背景纹4 / 浮动4），顺序不可改 —— */
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
}$$ WHERE id = 35;
UPDATE style_element_options SET css_template = $$
.gallery-card[data-style-element-bg="grain_noise"] {
  --el-bg-1: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='180' height='180'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='turbulence' baseFrequency='0.9' numOctaves='3' stitchTiles='stitch'/%3E%3CfeColorMatrix type='saturate' values='0'/%3E%3CfeComponentTransfer%3E%3CfeFuncR type='linear' slope='2.2' intercept='-0.6'/%3E%3CfeFuncG type='linear' slope='2.2' intercept='-0.6'/%3E%3CfeFuncB type='linear' slope='2.2' intercept='-0.6'/%3E%3C/feComponentTransfer%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.2'/%3E%3C/svg%3E");
  --el-bg-size-1: var(--el-geo-gap, 180px) var(--el-geo-gap, 180px);
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;
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
}
$$ WHERE id = 51;
