# 卡片 style_json 设计拼装手册（Agent 专用）

> 读者：所有需要「不用读数据库、不用读渲染器源码」就能直接设计卡片样式的 Agent。
> 目标：拿到一个设计主题 → 从现有组件里挑 → 拼出一份合法的 `style_json` → （可选）存入 `STYLE_POOL` → （若现有组件不够）提交入库请求待人审核。
> 设计基调：**优先复用现有组件**；**大胆、求新、与主题强匹配**，不要保守求稳。

---

## 0. 三句话讲清原理（不用读代码也能懂）

1. **卡片 = 日记数据 + `style_json` + 数据库里的 `css_template`。** 渲染引擎 `style-engine.js` 把 `style_json` 翻译成一堆 `data-*` 属性挂到卡片 DOM 上，再从数据库维度表里查出对应的 CSS 片段注入页面。样式**零硬编码**，全由数据库驱动。
2. **你（agent）只产 `style_json`，不写 CSS。** 每个 `style_json` 字段的取值，必须是数据库某张「维度选项表」里**已存在的 `value`**（见第 3 节）。引擎只认这些 `value`，认不到就忽略。
3. **想用数据库里没有的效果？** 不要自己写 CSS 塞进 `style_json`。按第 6 节提交一份「入库请求 SQL」，等用户审核、由用户在 Supabase 执行后，新组件就进库了，之后所有人都能用。

渲染链路一句话：`style_json → renderStyleJson() → data-* 属性 + CSS 变量 → buildCardHtml() → <a class="gallery-card"> → injectDynamicStyles() 注入 DB css_template`。

---

## 1. style_json 权威结构（引擎认的就是这个）

下面是引擎实际读取的**完整 schema**（与 `style-engine.js` 的 `DEFAULT_STYLE_JSON` 一致）。**缺省的 key 一律按默认值处理**，所以你只写要改的字段即可。

```jsonc
{
  "palette": {
    "harmony": "mono_grey",          // 色相组合（必选，见 §3.1）
    "tone": "light_standard",        // 明暗调性（见 §3.1）
    "slot": "original"               // 四色槽位映射（见 §3.1）
    // 注：引擎读取的 key 是 harmony/tone/slot；数据库 style_palette_options 表对应 sub_dim 为
    //      harmony_palette / tone_mapping / slot_assignment，三者 value 必须一一对应（见 §3.1）。
  },
  "layout": {
    "grid": "single",                // 网格结构（见 §3.2）
    "flow": "horizontal",            // 书写方向 horizontal/vertical/mixed
    "flow_vertical": [],             // mixed 流下哪些字段竖排：["title","date",...]
    "slot_assignment": {             // 四槽 a/b/c/d → 字段
      "a": "date", "b": "title", "c": "highlights", "d": "capsule"
    },
    "density": "normal",             // sparse/normal/dense
    "block_align": "left",           // 块级对齐 start/center/end/stretch
    "inline_align": "left",          // 行内对齐 left/center/right/stretch
    "spacing_scale": "md"            // 全局间距基准 xs/sm/md/lg/xl
  },
  "typo": {
    "font_family": { "title":"system_sans", "date":"system_sans", "capsule":"system_sans", "highlights":"system_sans" },
    "weight_gradient": "balanced",   // 字重梯度
    "size_scale": "petite",          // 字号梯度
    "alignment_mode": { "title":"inherit", "date":"inherit", "capsule":"inherit", "highlights":"inherit" },
                                       // 字段级对齐：inherit/left/center/right/stretch
    "spacing_tightness": { "title":"normal", "date":"normal", "capsule":"normal", "highlights":"normal" },
    "text_decoration": { "title":[], "date":[], "capsule":[], "highlights":[] }  // 数组，可多选
  },
  "border": {
    "radius_size": "none",           // 圆角
    "border_width": "none",          // 线宽
    "border_style": "solid",         // 线型
    "border_shadow": "none"          // 阴影
  },
  "deco": {
    "bubble_style": "none",          // 气泡（作用于 highlights）
    "tag_style": "none",             // 标签（作用于计数徽标）
    "avatar_style": "none",          // 头像
    "avatar_pos": "side",            // side / top
    "boxes": [],                     // Deco Box 嵌套列表（见 §3.6）★★★★核心拼装件
    "box_radius": 8,                 // 所有 box 统一圆角(px)
    "box_gap": 12,                   // 嵌套 box 间距(px)
    "action_style": "none"           // 操作栏（赞/评/转）
  },
  "element": {
    "header_deco": "none",           // 顶栏装饰条
    "header_text": "",               // 顶栏自定义文字内容
    "header_width": 6,               // 顶栏粗细(px)
    "header_text_family": "",        // 顶栏文字字体
    "header_text_size": "",          // 顶栏文字字号(如 "10px")
    "header_text_align": "",         // 顶栏文字对齐 left/center/right/stretch
    "side_accent": "none",           // 侧栏装饰条
    "side_text": "",                 // 侧栏自定义文字内容
    "side_width": 8,                 // 侧栏粗细(px)
    "side_position": "left",         // left / right
    "side_text_family": "", "side_text_size": "", "side_text_align": "",
    "band_inset": true,              // true=色条内缩留白 / false=色条贴边满边
    "divider": "none",               // 分隔线
    "corner_badge": "none",          // 角标
    "bg_pattern": "none",            // 背景纹理
    "edge_deco": "none",             // 边缘装饰
    "floating_deco": "none"          // 悬浮装饰
  },
  "effect": {
    "filter_self":  { "title":"none", "date":"none", "capsule":"none", "highlights":"none" }, // 元素自身滤镜
    "filter_backdrop": { "title":"none", "date":"none", "capsule":"none", "highlights":"none" }, // 毛玻璃
    "transform":    { "title":"none", "date":"none", "capsule":"none", "highlights":"none" },   // 几何变换
    "animation":    { "title":"none", "date":"none", "capsule":"none", "highlights":"none" }    // 动画
  },
  "container_group": "none",         // 旧版单值（整卡 override，向后兼容）
  "container_groups": []             // 新版数组（见 §3.8），compose 进 highlights
}
```

**两个关键约定（写错不报错但会不对）：**
- **per-element 维度**（typo 的 `font_family`/`alignment_mode`/`spacing_tightness`/`text_decoration`，以及 effect 全部四项）：value 可以是一个**字符串**（四字段同值）或一个**对象** `{title,date,capsule,highlights}`（逐字段不同）。要统一就写字符串，要差异化就写对象。
- `text_decoration` 是**数组可多选**，如 `["prefix_bar","gradient_text"]`。
- `alignment_mode` 默认 `inherit` = 跟随 `layout.inline_align`；只有想让某字段**单独**改方向时才显式写 `left/center/right/stretch`。

---

## 2. 字段与槽位模型（先懂骨架再拼皮）

卡片有四个核心字段：**date / title / highlights / capsule**。它们通过 `layout.slot_assignment` 摆进 `a/b/c/d` 四个网格槽。

> **capsule 是什么？** `capsule` 槽渲染的是日记的**扭蛋机风格名**（`d.capsuleName`，来自项目里 12 台扭蛋机之一，是"今天抽到了哪个扭蛋主题"的身份标签）。它不是正文、也不是日期，而是卡面上那枚代表风格主题的小标识。设计时就把它当成**一个与 title/date 同级的短文本槽**来排版/包裹/对齐即可——很适合用 `weight_gradient: capsule_heavy` 或给 `capsule` 单独设 `alignment_mode` 让它跳出来。

- 改 `slot_assignment` 就能重排四字段的位置（配合 `layout.grid` 的网格模板生效）。
- `highlights` 是数组，渲染成多条；其余是单值。
- **Deco Box / effect / 字段级 typo** 都针对这四个字段（或 `global` 整卡）作用，详见各节。
- 容器组（`container_groups`）只作用在 highlights 作用域（highlight_N / avatar / like / share / comment），不会重复渲染四个主槽。

---

## 3. 组件总览（可选 value 清单 —— 这就是你的「素材库」）

> 每个条目 `value='xxx' | 中文标签 | 效果`。你写 `style_json` 时直接填 `value` 字符串即可。
> 带 ★ 的是高频、最值得优先尝试的拼装件。

### 3.1 配色 palette（sub_dim: harmony_palette / tone_mapping / slot_assignment）

`palette.harmony` 决定色相；`tone` 决定明暗；`slot` 决定四个语义色（bg/text/accent/muted）怎么排。

> 数据库对应：style_json 的 `harmony` / `tone` / `slot` 三个 key，value 必须分别落在 `style_palette_options` 表的 `harmony_palette` / `tone_mapping` / `slot_assignment` 三个 sub_dim 里（下面列出的是这些 sub_dim 的全部可用 value）。

**harmony（色相组合，共 38 个，DB sub_dim=harmony_palette，全部可用值）：**
- 邻近色 analogous（8）：`analogous_blue_purple` 蓝紫、`analogous_blue_teal` 蓝青、`analogous_green_teal` 绿青、`analogous_lime_yellow` 青柠黄、`analogous_orange_yellow` 橙黄、`analogous_purple_pink` 紫粉、`analogous_red_orange` 红橙、`analogous_rose_red` 玫瑰红
- 撞色 complementary（8）：`comp_burgundy_beige` 勃艮第米色、`comp_charcoal_amber` 炭灰琥珀、`comp_cobalt_sand` 钴蓝沙、`comp_forest_coral` 深林珊瑚、`comp_hermes_gray` 爱马仕橙灰、`comp_klein_white` 克莱因蓝白、`comp_navy_cream` 藏青奶黄、`comp_neon_black` 荧光黄黑
- 分裂互补 split（6）：`split_blue_orange` 蓝+橙、`split_green_magenta` 绿+品红、`split_orange_blue` 橙+蓝、`split_purple_lime` 紫+青柠、`split_red_green_teal` 红+绿+青、`split_yellow_purple` 黄+紫
- 三角色 triadic（6）：`triadic_blue_orange_pink` 蓝橙粉、`triadic_green_purple_orange` 绿紫橙、`triadic_orange_green_purple` 橙绿紫、`triadic_red_yellow_blue` 红黄蓝、`triadic_teal_rose_lime` 青玫瑰青柠、`triadic_yellow_blue_red` 黄蓝红
- 四方色 tetradic（4）：`tetradic_blue_green_red_orange` 蓝绿红橙、`tetradic_orange_teal_red_blue` 橙青红蓝、`tetradic_purple_green_yellow_red` 紫绿黄红、`tetradic_red_yellow_blue_green` 红黄蓝绿
- 单色 mono（6）：`mono_blue` 纯蓝、`mono_green` 纯绿、`mono_grey` 纯灰、`mono_orange` 纯橙、`mono_purple` 纯紫、`mono_red` 纯红

**tone（明暗，6 个）：** `raw_seed` 原色直出 / `light_standard` 浅调标准 / `light_soft` 浅调柔和 / `medium_strong` 中调强烈 / `dark_standard` 深调标准 / `dark_deep` 深调深邃

**slot（四色排布，7 个）：** `original` 原序 / `swap_bg_text` 背景↔文字 / `swap_bg_acc` 背景↔强调 / `swap_text_acc` 文字↔强调 / `shift_fwd` 前移 / `shift_bwd` 后移 / `cross_swap` 十字互换

> 配色算法：harmony 行取种子色 → 每个色生成 10 阶 Ant Design 色阶 → tone 取各阶索引 → slot 重排。所以同一 harmony 换 tone/slot 就能得到完全不同的明暗与对比。

### 3.2 布局 layout

- **grid（网格结构，17 个）**：`single` 单栏堆叠★ / `2col_equal` 双栏等宽 / `2col_left_wide` 左宽 / `2col_right_wide` 右宽 / `2col_left_narrow` 左窄侧栏 / `2col_right_narrow` 右窄侧栏 / `3col_equal` 三栏等宽 / `3col_left_focus` 左聚焦 / `3col_right_focus` 右聚焦 / `sidebar_left` 左侧栏 / `sidebar_right` 右侧栏 / `sidebar_both` 双侧栏 / `top_split` 顶部分栏 / `bottom_split` 底部分栏 / `hero` Hero 布局★ / `inverted` 倒置 / `timeline` 时间线★（自带左侧轴线）
- **flow（书写方向）**：`horizontal` 横排 / `vertical` 竖排 / `mixed` 标题竖正文横（配 `flow_vertical` 指定哪些字段竖排）
- **density（密度）**：`sparse` 稀疏 / `normal` 标准 / `dense` 紧凑
- **block_align（块级对齐）**：`start` / `center` / `end` / `stretch`
- **inline_align（行内对齐，全局默认，字段可覆盖）**：`left` / `center` / `right` / `stretch`（两端对齐）
- **spacing_scale（全局间距基准）**：`xs` / `sm` / `md` / `lg` / `xl`

### 3.3 排版 typo（per-element）

- **font_family（9 个）**：`system_sans` 系统无衬线★ / `editorial_serif` 报刊衬线（文化感）/ `modern_sans` 现代无衬线（科技）/ `terminal_mono` 终端等宽（极客）/ `rounded_soft` 圆润柔和 / `display_geometric` 展示几何（冲击）/ `condensed_impact` 窄体冲击 / `slab_serif` 粗衬工业 / `handwritten_note` 手写笔记（仅标题）
- **weight_gradient（字重梯度，6 个）**：`high_contrast` 高对比 / `balanced` 均衡★ / `soft` 柔和 / `neutral` 极简中性 / `capsule_heavy` 标签突出 / `bold_heavy` 粗体厚重（海报）
- **size_scale（字号梯度，5 个）**：`headline_impact` 大标题冲击 / `balanced_read` 均衡阅读 / `compact_dense` 紧凑密集 / `petite` 精致小巧★ / `large_comfort` 大字号舒适
- **alignment_mode（字段级对齐，5 个）**：`inherit` 跟随行内（默认）/ `left` / `center` / `right` / `stretch` 撑满（日期无空格串用 `inter-character` 也能撑）
- **spacing_tightness（字距行距，4 个）**：`loose` 宽松 / `normal` 标准 / `tight` 紧凑 / `dense` 极密
- **text_decoration（文字装饰，可多选，16 个，含 none / 15 可用）**：`none` 无装饰 / `underline_solid` 实线下划线 / `underline_wavy` 波浪 / `underline_dashed` 虚线 / `strikethrough` 删除线 / `prefix_dot` 前置圆点 / `prefix_bar` 前置竖线★ / `prefix_number` 前置编号 / `capsule_tag` 标签造型 / `capsule_badge` 徽章 / `uppercase` 大写 / `italic` 斜体 / `gradient_text` 渐变文字★ / `text_stroke` 描边 / `text_glow` 发光 / `text_3d` 3D 文字

### 3.4 边框 border

- **radius_size（圆角，7 个，含 none / 6 可用）**：`none` 直角 / `xs`(2) / `sm`(4) / `md`(8)★ / `lg`(12) / `xl`(20) / `full`(9999 胶囊)
- **border_width（线宽，5 个，含 none / 4 可用）**：`none` / `hairline`(0.5) / `thin`(1) / `medium`(2) / `thick`(4)
- **border_style（线型，4 个）**：`solid` / `dashed` / `dotted` / `double`
- **border_shadow（阴影，5 个，含 none / 4 可用）**：`none` / `soft` 柔和浮起 / `soft_small` 微阴影 / `inset` 内嵌 / `hard_offset` 硬偏移（复古印刷）

### 3.5 装饰 deco

- **bubble_style（气泡，作用于 highlights，5 个，含 none / 4 可用）**：`none` / `wechat_left` 微信左气泡 / `wechat_right` 微信右气泡 / `imessage_rounded` iMessage 圆润 / `quote_bubble` 引用气泡
- **tag_style（标签，作用于计数徽标，8 个，含 none / 7 可用）**：`none` / `capsule_fill` 胶囊实心 / `capsule_outline` 胶囊描边 / `badge_circle` 圆形徽章 / `stamp_dashed` 邮戳虚线 / `corner_cut` 切角 / `mini_badge` 迷你数字徽章 / `dot_label` 圆点状态
- **avatar_style（头像，6 个，含 none / 5 可用）**：`none` / `circle_solid` 实心圆 / `circle_outline` 描边圆 / `square_rounded` 圆角方 / `initial_label` 首字母 / `square_solid` 直角方
- **action_style（操作栏，7 个，含 none / 6 可用）**：`none` / `icon_text_btn` 图标文字 / `icon_only_btn` 纯图标 / `text_link` 文字链接 / `solid_btn` 实心 / `ghost_btn` 幽灵 / `icon_text_vertical` 竖排
- **boxes（Deco Box 嵌套列表，★核心，见 §3.6）**

### 3.6 ★ Deco Box（最灵活的拼装件）

`deco.boxes` 是一个有序数组，每个盒子 = 对字段/内容的**嵌套包裹层**，可多层叠加：

```jsonc
"boxes": [
  { "style": "gradient_linear", "target": "highlights" },
  { "style": "glass_standard",  "target": "highlights" },
  { "style": "float_card",      "target": "title" },
  { "style": "outline_border",  "target": "global", "coincide": true }
]
```

- `style` ∈ 下列 box 类型；`target` ∈ `global`(整卡) / `title` / `date` / `capsule` / `highlights`；可选 `coincide:true` 让盒子与内层边缘完全重合（padding:0）。
- **同一区域可叠多个盒子**（如渐变+毛玻璃+液态玻璃并存），数组顺序 = 由外到内。
- `deco.box_radius` / `deco.box_gap` 统一控制所有盒子的圆角与间距。

**box_style 可选值（14 个，含 none / 13 可用）：**
`solid_fill` 实心填充块 / `outline_border` 描边边框块 / `left_bar_quote` 左色条引用块 / `code_dark` 代码深色块 / `dashed_cutout` 虚线剪切块 / `sticky_note` 基础便签 / `tape_note` 胶带便签 / `float_card` 悬浮卡片 / `glass_standard` 标准毛玻璃 / `liquid_glass` 液态玻璃 / `gradient_linear` 双色线性渐变 / `gradient_flow` 三色流光 / `gradient_radial` 径向光晕 / `none` 无块容器

> 想让某个字段"浮起来"→ `float_card`；想"玻璃感"→ `glass_standard`/`liquid_glass`（配合 effect 的 `backdrop_blur` 更绝）；想"手账拼贴"→ `sticky_note`/`tape_note`；想"代码感"→ `code_dark`。

### 3.7 元素装饰 element（整卡级装饰）

- **header_deco（顶栏条，7 个，含 none / 6 可用）**：`none` / `solid` 细 accent 线 / `gradient` 渐变色带 / `blink` 闪烁光标（终端）★ / `diagonal` 斜纹 / `breathing` 呼吸 / `scanline` 扫描线
- **side_accent（侧栏条，8 个，含 none / 7 可用）**：`none` / `solid` accent 实心 / `gradient` 渐变 / `line_number_column` 行号栏（代码风）★ / `notebook_binding` 活页装订孔 / `diagonal` 斜纹 / `breathing` 呼吸 / `scanline` 扫描
- **divider（分隔线，6 个，含 none / 5 可用）**：`none` / `thin_solid` 细实线 / `double_line` 双线 / `dotted_line` 点线 / `gradient_line` 渐变线 / `char_asterisk` 星号字符
- **corner_badge（角标，5 个，含 none / 4 可用）**：`none` / `circle_stamp` 圆形印章 / `page_fold` 折角 / `corner_ribbon` 角标丝带 / `dot_status` 状态圆点
- **bg_pattern（背景纹理，6 个，含 none / 5 可用）**：`none` / `dot_grid` 点阵 / `fine_grid` 方格 / `horizontal_lines` 横线（日记纸）★ / `gradient_overlay` 渐变遮罩 / `terminal_scanlines` 扫描线（CRT）★
- **edge_deco（边缘，5 个，含 none / 4 可用）**：`none` / `stamp_perforation` 邮票齿孔 / `bracket_frame` 方括号框 / `notched_corner` 切角 / `tape_stripe` 胶带纹
- **floating_deco（悬浮装饰，5 个，含 none / 4 可用）**：`none` / `floating_circle` 悬浮圆 / `scatter_dots` 散点阵 / `art_deco_diamond` Art Deco 菱形 / `tamagotchi_label` TAMAGOTCHI 字样
- **自定义文字**：`header_text` / `side_text` 填内容；`*_text_family`/`*_text_size`/`*_text_align` 控制排印（顶栏 align ∈ left/center/right/stretch；侧栏 align ∈ top/center/bottom/stretch）。
- **band_inset**：`true` 色条内缩留白（精致）/ `false` 色条贴边满边（硬朗通长）。`header_width`/`side_width` 控制条粗细(px)。

#### 3.7.1 element 装饰的兼容性规则与标准入库写法（2026-07-23 重构定稿）

> 背景：前两天制卡实践中，谜语卡等「多装饰同卡」频繁出现「装饰互相覆盖 / 消失 / 显示位置错乱」。根因有两类——(a) 多个装饰争抢 `.gallery-card` 仅有的 `::before`/`::after` 两个伪元素；(b) 多个背景类装饰各自声明完整 `background-image`，而一张卡只有一条 `background-image` 能赢。本次重构用「共享 14 槽画布 + 固定伪元素分配」彻底解决，四个装饰子维度可独立显示、可任意叠加。

**① 渲染机制（一句话）**
四个装饰子维度各发射一个**独立**属性到卡片根：`.gallery-card[data-style-element-corner=...]`、`...-bg=...`、`...-edge=...`、`...-float=...`。四个属性互不互斥，**可同时开启**。

**② 三种实现方式分类表（设计/入库必读）**

| 子维度 | value | 实现方式 | 伪元素占用 | 画布槽位 |
|---|---|---|---|---|
| corner_badge | circle_stamp | css_background | — | corner-1 |
| corner_badge | page_fold | css_background | — | corner-1,2 |
| corner_badge | dot_status | css_background | — | corner-1 |
| corner_badge | corner_ribbon | pseudo_after（文字） | `::after` | — |
| bg_pattern | dot_grid / fine_grid / horizontal_lines / gradient_overlay / terminal_scanlines | css_background | — | bg-1..4 |
| edge_deco | bracket_frame | css_background | — | edge-1..4 |
| edge_deco | tape_stripe | css_background | — | edge-1 |
| edge_deco | stamp_perforation | css_mask（四边 radial-gradient 镂空齿孔） | — | — |
| edge_deco | notched_corner | css_clip（clip-path） | — | — |
| floating_deco | floating_circle | css_background | — | float-1 |
| floating_deco | scatter_dots | css_background | — | float-1,2 |
| floating_deco | tamagotchi_label | pseudo_before（文字） | `::before` | — |
| floating_deco | art_deco_diamond | pseudo_both（文字） | `::before`+`::after` | — |

> 实现方式取值含义：`css_background`=用背景图层（走画布）；`pseudo_before`/`pseudo_after`/`pseudo_both`=用卡片伪元素（文字类）；`css_border`/`css_clip`=用正交属性（不抢背景也不抢伪元素）；`css_mask`=用 `mask` 镂空卡形（如 `stamp_perforation` 四边挖半圆齿孔，齿孔为透明、透出页面底色，符合邮票质感，且不与背景画布/伪元素冲突）。

**③ 背景类装饰的「共享 14 槽画布」机制（为什么能叠加）**
卡片根固定一块 14 槽背景画布，槽位顺序不可改：

```
角标 corner-1,2 | 边缘 edge-1,2,3,4 | 背景纹 bg-1,2,3,4 | 浮动 float-1,2,3,4
```

每个**背景类**装饰的 `css_template` 由两部分组成，且在所有背景装饰里**逐字一致**：
- 本装饰只写自己占用的槽位变量（如 `dot_grid` 只写 `--el-bg-1` 及其 `-size/-pos/-rep`）；
- 末尾统一带一段「固定 14 槽主合成」块（声明 `background-image/-size/-position/-repeat`，全部用 `var(--el-*, none)` 引用各槽位，缺省 `none`）。

多背景装饰同卡时，各自只贡献自己的槽位变量，主合成引用**全部**变量；CSS 自定义属性跨匹配规则解析天然叠加，**互不覆盖**。因此角标 + 背景纹 + 边缘 + 浮动 四类背景装饰可任意共存（如谜语卡：折角 + 点阵 + 方括号 + 浮动圆 同显）。

> ⚠️ **入库铁律**：背景类装饰**严禁**自己写 `background-image` / `background` 简写 / `!important`——那会覆盖主合成、吞掉其它背景装饰。槽位变量也禁止跨组写（如 bg 装饰不能写 `--el-corner-*`）。
>
> 🚨 **选择器铁律（2026-07-23 踩坑）**：`css_template` 里的选择器**必须带前导点** `.gallery-card[...]`。写成 `gallery-card[...]`（漏 `.`）会被浏览器当成「标签名为 gallery-card 的元素」，**永远命中不了 class**，整条规则静默失效——表现为该装饰完全不显示，且不会报错、极难排查。文本/正交类装饰（丝带/标签/菱形/齿孔/切角）尤其容易被漏点。
>
> 🚨 **伪元素 content 铁律**：文本类装饰的 `content` 用**固定字面量**（`content: "NEW"` / `content: "\25C6..."`），**禁止**两参 `attr(name, fallback)`——该语法在 `content` 上不被浏览器支持（且引擎未发射对应属性），会导致伪元素不生成。
>
> 🚨 **overflow 铁律**：卡片根 `.gallery-card` 有 `overflow: hidden`。探出卡外的装饰（如旋转 45° 贴角落的丝带）会被裁掉——丝带类应锚定在**卡内**右上角（`top/right` 取正值），而非 `right:0` 配 `translate` 外推。

**④ 伪元素分配表 + 兼容性矩阵（文本类装饰）**
卡片伪元素只有 `::before` 与 `::after` 两个。文本类装饰固定占用如下，不可越界：

| 伪元素 | 授权给 | 用途 |
|---|---|---|
| `::before` | tamagotchi_label、art_deco_diamond（顶条） | 顶部文字 |
| `::after` | corner_ribbon、art_deco_diamond（底条） | 角标丝带 / 底部文字 |

兼容性矩阵（只列文本类互相组合；背景类与文本类天然正交，永远 ✅）：

| | corner_ribbon (::after) | tamagotchi_label (::before) | art_deco_diamond (::before+::after) |
|---|---|---|---|
| corner_ribbon | — | ✅ 可同用 | ❌ `::after` 冲突 |
| tamagotchi_label | ✅ | — | ❌ `::before` 冲突 |
| art_deco_diamond | ❌ | ❌ | — |

> 说明：每个子维度同一时刻只有一个 value（一个属性一个值），所以「同一子维度内」不会有两个装饰争抢同一伪元素。冲突只发生在「不同子维度都选了文本类装饰」这一种情况——即上表三种 ❌。设计卡时避开即可；若需要菱形+丝带同卡，请把丝带改用背景类方案（如新增一个 `css_background` 的角标装饰）。

**⑤ 安全上限（经验值）**
- 背景类装饰（corner/bg/edge/float 中走画布的部分）：**数量不限**，可全开。
- 文本类装饰（corner_ribbon / tamagotchi_label / art_deco_diamond）：受限于 2 个伪元素，按 ④ 矩阵最多同开 2 个（且 art_deco_diamond 独占双伪元素时只可 1 个）。
- 单卡装饰总数建议 ≤ 5（指 corner/bg/edge/float 四类 + 文本装饰合计）；结构性装饰 header_deco/side_accent/divider 不计入此上限。旧版谜语卡 8+ 装饰崩溃的根因是伪元素/背景互相覆盖，新架构已解除背景类瓶颈，唯一硬约束就是上面的伪元素 2 槽。

**⑥ 标准入库写法（CSS 规范）**

可调用的调色槽（由 palette 维度注入，**装饰只引用这四色，禁止硬编码颜色**）：
`--card-bg` / `--card-text` / `--card-accent` / `--card-muted`。

槽位变量命名（背景类专用）：`--el-{corner|edge|bg|float}-{1..4}`，每组配 `-size-*`(如 `14px 14px`)、`-pos-*`(如 `top 6px right 6px`)、`-rep-*`(`no-repeat`/`repeat`)。

- **背景类模板**（必须带主合成块，变量只写本组）：
```css
.gallery-card[data-style-element-bg="your_value"] {
  --el-bg-1: radial-gradient(circle, var(--card-muted) 1px, transparent 1.6px);
  --el-bg-size-1: 16px 16px;
  --el-bg-pos-1: 0 0;
  --el-bg-rep-1: repeat;
  /* —— 固定 14 槽主合成（角标2 / 边缘4 / 背景纹4 / 浮动4），顺序不可改 —— */
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
```
- **伪元素类模板**（文本类，按 ④ 占用指定伪元素）：
```css
.gallery-card[data-style-element-float="tamagotchi_label"]::before {
  content: "TAMAGOTCHI";
  position: absolute; top: 5px; left: 50%; transform: translateX(-50%);
  font-size: 10px; letter-spacing: 1px; color: var(--card-accent);
  font-family: monospace; pointer-events: none; z-index: 3;
}
```
规则：`position:absolute`（卡片已 `position:relative`）；`z-index:3` 确保浮于内容之上；`pointer-events:none` 避免挡点击；**不要**在伪元素类装饰里写 `background-image`（会污染画布）；`content` 为空图形可用 `content:""` 但优先用背景类方案。
- **box/clip/orthogonal 类模板**（正交，不抢背景/伪元素）：
```css
/* stamp_perforation：mask 四边镂空齿孔（真正的邮票齿孔，非虚线/非描边） */
/* ⚠️ 每张遮罩必须用 100% 维度瓦片铺满整卡，否则只覆盖 13px 边缘条，
   mask-composite:intersect 会把整卡内部判为「未覆盖=透明」→ 卡片整体消失。 */
.gallery-card[data-style-element-edge="stamp_perforation"] {
  --sp-r: 4px; --sp-g: 13px;   /* 齿孔半径 / 间距 */
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
}
.gallery-card[data-style-element-edge="notched_corner"] {
  clip-path: polygon(0 0, calc(100% - 14px) 0, 100% 14px, 100% 100%, 0 100%);
}
```

> 入库 SQL 模板见 §6（把 `<dim>` 换成 `element`，`sub_dim` 取上表子维度之一）。新增装饰前先用本地验证页 `web/element_compat_test.html` 打开核对「独立显示 / 四者叠加 / 文本类与背景类共存」三种效果再提 SQL。

**⑦ 位置参数（锚点定位）—— 同一装饰贴任意角/边，无需另建 DB 条目**

设计初衷：角标/浮动/切角默认钉在某个角（如丝带默认右上）。若想要「同一个丝带在左上角」，旧方案要再建一条 DB 条目；新方案在 `style_json.element` 加一个位置字段，引擎据此注入 CSS 变量，一份模板覆盖 8 锚点。

**8 锚点词汇表**：四角（top-left / top-right / bottom-left / bottom-right）+ 四边居中（top-center / right-center / bottom-center / left-center）。

**字段**（缺省 `'native'` = 沿用模板原生位置）：
- `corner_badge_pos`、`floating_deco_pos`：取值 = 8 锚点之一。
- `edge_deco_pos`：仅四角（只有 `notched_corner` 这类「切哪个角」有意义；整周/整框型边缘忽略）。

**引擎行为**（`style-engine.js` 的 `renderStyleJson` / `buildDataAttrs`）：
- 角标 / 浮动：把锚点翻译成 inline CSS 变量挂到 `.gallery-card` 根——`--el-{corner|float}-anchor-pos`（background-position 串）、`--el-{subdim}-pos-top/right/bottom/left`、`--el-{subdim}-pos-tf`（居中补偿 transform）。
- 边缘（clip）：发射 `data-style-element-edge-anchor="<corner>"` 属性（仅四角）。
- 角标（方向性）：`page_fold` 翻角发射 `data-style-element-corner-anchor="<anchor>"` 属性（仅四角有意义；四边居中回落原生），模板用属性选择器切 `--pf-angle` 翻转渐变。

**模板消费写法（三类）**：
- 背景型（circle_stamp / dot_status / floating_circle / scatter_dots）：位置变量改写为 `var()` 兜底——
  `--el-corner-pos-1: var(--el-corner-anchor-pos, top 6px right 6px);`
- 伪元素型（corner_ribbon ::after / tamagotchi_label ::before）：`top/right/bottom/left/transform` 全部走变量，原生兜底；丝带自带 `rotate(45deg)` 固有旋转，居中锚点会注入 `translateX(-50%)` 叠加后仍保持旋转——
  ```css
  top: var(--el-corner-pos-top, 12px); right: var(--el-corner-pos-right, 12px);
  bottom: var(--el-corner-pos-bottom, auto); left: var(--el-corner-pos-left, auto);
  transform: var(--el-corner-pos-tf, none) rotate(45deg);
  ```
- clip 型（notched_corner）：用 `data-style-element-edge-anchor` 属性选择器枚举四角 clip-path 变体（默认无属性 = 右上切角）。

**偏移量「设计期固定」**：引擎只决定锚点（贴哪角），离角多远由各模板的 `var()` 兜底值决定（移动后统一 12px，方向随锚点翻转）。若某装饰要不同的离角距离，改它自己的模板兜底值即可——无需引擎改动，也无需运行时滑块。

**原生锁 / 方向性元素**：`art_deco_diamond`（顶/底满宽条带，无「角」概念）不参与位置切换，保持原生。`page_fold`（dog-ear 翻角）是方向性元素——移到对角需翻转渐变角度，故**不走通用位置变量**，而用专属的 `data-style-element-corner-anchor` 四角属性选择器（渐变角度抽成 `--pf-angle` 变量，top-left=315deg / bottom-left=45deg / bottom-right=135deg，原生无 anchor=右上 225deg）。翻角只能贴角，四边居中锚点对其无意义、回落原生。

**前端**：capsule-preview 在角标 / 边缘 / 浮动三处各提供一个「位置」下拉（角标+浮动 8 锚点，边缘 4 角）。

### 3.8 特效 effect（per-element，四字段各自独立）

四项都按 `{title,date,capsule,highlights}` 设值，可字符串统配或对象分设。

- **filter_self（元素自身滤镜，11 个，含 none / 10 可用）**：`none` / `blur_sm` 轻模糊 / `blur_md` 中模糊 / `drop_shadow_soft` 柔投影 / `drop_shadow_hard` 硬投影 / `grayscale` 灰度 / `sepia` 棕褐 / `brightness_high` 高亮 / `contrast_high` 高对比 / `saturate_high` 高饱和 / `hue_rotate_90` 色相偏移
- **filter_backdrop（毛玻璃，3 个）**：`backdrop_blur_sm`(8px) / `backdrop_blur_md`(16px) / `backdrop_blur_lg`(32px)。**与 filter_self 可同时生效**（DOM 分层化解冲突）。
- **transform（几何变换，7 个，含 none / 6 可用）**：`none` / `rotate_left_sm` 左微旋(-2°) / `rotate_right_sm` 右微旋(3°) / `scale_up_sm` 微放大 / `scale_down_sm` 微缩 / `translate_up_sm` 上移 / `skew_left_sm` 左斜切
- **animation（动画，8 个，含 none / 7 可用）**：`none` / `fade_in` 淡入 / `slide_up_in` 上滑 / `pulse_slow` 呼吸 / `float_slow` 漂浮 / `spin_slow` 旋转 / `bounce_small` 弹跳 / `glow_pulse` 发光呼吸

### 3.9 容器组 container_groups（社交/评论/拼贴专用）

`container_groups` 是数组，把若干「横向带模板」compose 进 highlights 区（**不替换四个主槽**：date/title/capsule 仍在四槽骨架上；容器组只承包 highlights 作用域的字段——`highlight_N` / `avatar` / `like` / `share` / `comment`）。

```jsonc
"container_groups": ["cg_chat_message_left", "cg_chat_message_right"]
```

#### repeat_mode 两种模式 + 渲染顺序

每个容器组在数据库里有 `repeat_mode`（`per_line` / `once`）。引擎把数组拆成三组来渲染：

- **per_line 组**：按数组顺序排成一个**循环队列**，每条 highlight 行由队列里的「下一个」组承包。
- **once 组**：整段只渲染一次；**出现在第一个 per_line 之前** → 渲染在对话/列表**最前**；**出现在第一个 per_line 之后** → 渲染在**最后**。
- 分隔线 `element.divider` 会在所有顶层带之间插入 `.hl-sep` 兄弟元素。

**完整交替渲染示例**（微信左右气泡）：下面两个组都是 `per_line`，`diary.highlights = ["在吗？","周末去爬山不？","带上相机"]`，渲染结果自上而下每行一条带：

```
┌─ 带①  cg_chat_message_left  ───────────────┐
│  [avatar]  气泡(wechat_left): 在吗？          │
└─────────────────────────────────────────────┘
┌─ 带②  cg_chat_message_right ───────────────┐
│  气泡(wechat_right): 周末去爬山不？      [avatar]│
└─────────────────────────────────────────────┘
┌─ 带③  cg_chat_message_left  ───────────────┐   ← 回到队列头，循环
│  [avatar]  气泡(wechat_left): 带上相机        │
└─────────────────────────────────────────────┘
```
（奇数行引擎自动加 `.cg-band--alt` 类，DB 的 css_template 可据此做左右翻转/微调。）

**once 与 per_line 混排示例**：`["cg_social_header"(once), "cg_chat_message_left"(per_line), "cg_social_interact_bar"(once)]` →

```
[ cg_social_header        once  ]   ← 首个 per_line 之前 → 最前
[ cg_chat_message_left    per_line ×N 行 ]   ← 逐行循环
[ cg_social_interact_bar  once  ]   ← 首个 per_line 之后 → 最后
```
若数组里**没有** per_line 组（如 `["cg_social_header","cg_social_interact_bar","cg_sticky_three"]`），则所有 once 组按数组顺序直接堆叠。

#### ★ 边界：Deco Box（deco.boxes）与容器组不能互相穿透

这是设计时常踩的坑，两套装饰系统必须分清：

| 系统 | 作用对象 | 装饰写在哪里 | 你能在 style_json 里改吗 |
|---|---|---|---|
| `deco.boxes[].target` | 四个主槽字段（`date`/`title`/`capsule`/`highlights`）+ `global` 整卡 | 你的 `style_json.deco.boxes` | ✅ 直接写 |
| 容器组内部 slot 装饰 | 容器组格子（cg_content / cg_avatar / cg_actions …） | **数据库容器组行的 `slot_deco_map`** | ❌ 只能选已有的 CG，或提 SQL 新增（见 §6.4） |

- **`deco.boxes[].target` 只能是 `global` / `date` / `title` / `capsule` / `highlights` 之一**，引擎不会把盒子套到容器组的某个 slot 上。换句话说：容器组里的气泡/头像/操作按钮长什么样，由该容器组在数据库里预设好，不是你 style_json 能逐槽指定的。
- 容器组每格的装饰由该 CG 行的 `slot_deco_map` 用 `deco:<子维度>.<value>` 语法指定。例如 `cg_chat_message_left` 的 `cg_content` 槽固定 = `deco:bubble_style.wechat_left`、`cg_avatar` 槽固定 = `deco:avatar_style.circle_solid`；还可用 `group:<group_code>` 嵌套另一个容器组（如 `cg_social_full_card` 的页脚槽 = `group:cg_social_interact_bar`）。
- **想控制容器组内部装饰？** 两条路：① 挑一个 `slot_deco_map` 已经符合需求的容器组；② 现有都不合适 → 按 §6.4 提交新容器组定义（含你想要的 `slot_deco_map`/`field_slot_map`/`extra_css`），审核进库后即可引用。
- 补充：legacy 单值 `container_group`（非数组）走整卡 override 分支，那个模式下 slot 字段会经过 `wrapField`、所以能吃到 `deco.boxes`——**但新模型 `container_groups` 数组不走这条路**，请统一用数组模型。

#### 现有容器组清单（9 个可用，另有 `none` 占位）

| group_code | repeat_mode | 内部结构 / slot 装饰（`slot_deco_map` 摘要） |
|---|---|---|
| `cg_chat_message_left` | per_line | 左对话框：cg_content=wechat_left 气泡 / cg_avatar=circle_solid 头像 |
| `cg_chat_message_right` | per_line | 右对话框：cg_content=wechat_right 气泡 / cg_avatar=circle_solid 头像 |
| `cg_comment_item` | per_line | 评论行：cg_main(标题+正文) / cg_avatar=circle_outline / cg_actions=text_link 操作 |
| `cg_comment_sub` | per_line | 楼中楼：cg_main(标题+正文) / cg_avatar=circle_solid |
| `cg_social_full_card` | once | 整卡：页眉(组 cg_social_header) + 内容盒(none) + 页脚(组 cg_social_interact_bar 赞评转) |
| `cg_social_header` | once | 社媒头部：cg_info(日期+标题) / cg_avatar=circle_solid |
| `cg_social_interact_bar` | once | 赞/评/转三件套：三槽各 = icon_text_btn |
| `cg_sticky_two` | once | 双便签：note1=tape_note / note2=sticky_note（highlight_1/2） |
| `cg_sticky_three` | once | 三便签：note1=sticky_note / note2=tape_note / note3=sticky_note（highlight_1/2/3） |

> 选 CG 看 `repeat_mode`：要"逐行重复 / 左右交替"用 per_line 组；要"整段一次性呈现"（社媒卡、便签墙）用 once 组。多个 per_line 组按数组顺序逐行轮转；多个 once 组按数组顺序堆叠（受首个 per_line 位置影响前后）。

---

## 4. 设计工作流（照着做就行）

1. **定主题**：先想清楚这张卡要什么气质（赛博/文学/社媒/杂志/手账/代码…）。
2. **选配色**：从 §3.1 挑 harmony，再定 tone/slot。这是基调，先定。
3. **定骨架**：从 §3.2 挑 `grid`；要不要竖排 `flow`；要不要 `container_groups` 做聊天/评论。
4. **挑皮**：布局定好后，逐维度从 §3.3~§3.9 挑组件。
   - 求新提示：多试试 **Deco Box 叠加**（§3.6）+ **毛玻璃/渐变** + **背景纹理** + **顶/侧栏装饰** 的组合，这是最容易出"惊艳且不撞车"效果的地方。
5. **差异化字段**：用 per-element 维度让某个字段跳出（如标题用 `display_geometric`+`bold_heavy`，正文用 `editorial_serif`）。
6. **只写要改的字段**，其余交给默认。
7. **（可选）存库**：把成型的 `style_json` 作为一条 `STYLE_POOL` 记录，方便复用与 Gallery 展示（见 §5）。
8. **（组件不够时）提交入库请求**：见 §6。

---

## 5. 存入 STYLE_POOL（让设计可被复用/展示）

`STYLE_POOL` 表字段：`name`(唯一名) / `category`(分类) / `desc` / `style_json`(JSONB) / `active`。
分类建议沿用现有体系：`code/tech/work/life/social/creative/format/media/misc/fiction/roleplay`。

> ⚠️ **重要**：`STYLE_POOL` 里现有 334 条中**大量是旧版 schema**（用 `layout.top/body/side`、`deco.title`、`palette` 字符串等），**不被当前引擎识别**。新设计请严格用本手册第 1 节的 v2 schema，否则前端不渲染。入库前请自查 `style_json` 的 key 是否与 §1 完全对应。

插入示例（agent 产出 SQL，用户执行）：
```sql
insert into "STYLE_POOL" (name, category, desc, style_json, active)
values ('赛博终端_霓虹', 'tech',
  '黑底荧光+扫描线+行号栏，硬核终端风',
  '{"palette":{"harmony":"comp_neon_black","tone":"dark_deep","slot":"original"},"layout":{"grid":"single","density":"dense"},"typo":{"font_family":"terminal_mono","weight_gradient":"bold_heavy","size_scale":"compact_dense"},"border":{"radius_size":"none","border_width":"thin","border_style":"solid","border_shadow":"none"},"deco":{"boxes":[{"style":"gradient_linear","target":"highlights"}],"box_radius":0},"element":{"header_deco":"blink","side_accent":"line_number_column","bg_pattern":"terminal_scanlines","band_inset":false},"effect":{"filter_backdrop":{"title":"backdrop_blur_md","date":"none","capsule":"none","highlights":"none"},"animation":{"title":"none","date":"none","capsule":"none","highlights":"none"}}}'::jsonb,
  true);
```

---

## 6. 入库请求机制（现有组件不够时）

你**没有数据库写权限**，所以不能自己 INSERT。流程是：**你产出一份带说明的 SQL → 用户审核 → 用户在 Supabase SQL Editor 执行 → 组件进库，全员可用。**

### 6.1 何时该提请求
- 主题需要一种现有 `value` 里没有的视觉（如某种全新渐变、某种新气泡形状、某种新角标）。
- 你需要一个新的「容器组」结构（带特定 `field_slot_map`/`extra_css`）。
- 你发现某个现有组件的 css_template 有明显改进空间（提 fix SQL）。

### 6.2 维度组件入库 SQL 模板
```sql
-- 例：新增一个 Deco Box 类型「霓虹边框块」
insert into style_deco_options (sub_dim, value, label, description, css_template, sort_order, is_enabled)
values ('box_style', 'neon_outline',
  '霓虹描边块',
  '外发光描边，赛博朋克风内容块',
  '[data-style-deco-box="neon_outline"]{border:1.5px solid var(--card-accent);box-shadow:0 0 8px var(--card-accent),0 0 16px color-mix(in srgb,var(--card-accent) 60%,transparent);border-radius:var(--border-radius,8px);padding:10px 12px;}',
  (select coalesce(max(sort_order),0)+1 from style_deco_options where sub_dim='box_style'),
  true);
```
> 通用模板（把 `<dim>` 换成 layout/typo/border/deco/effect/element）：
> `insert into style_<dim>_options (sub_dim, value, label, description, css_template, sort_order, is_enabled) values ('<sub_dim>','<value>','<中文标签>','<效果描述>','<完整CSS>', <sort_order>, true);`

### 6.3 配色入库 SQL 模板（harmony_palette 需给种子色）
```sql
insert into style_palette_options (value, label, sub_dim, bg, text_color, accent, muted, extra_colors, description, sort_order)
values ('analogous_teal_violet','青紫邻近','harmony_palette',
  '#0D9488','#A78BFA','#0D9488','#A78BFA',
  '{"accent_2":"#C084FC","bg_secondary":"#134E4A"}',
  '青色到紫色的邻近过渡',
  (select coalesce(max(sort_order),0)+1 from style_palette_options where sub_dim='harmony_palette'));
```

### 6.4 容器组入库 SQL 模板（较复杂，给 key 字段即可）
```sql
insert into style_container_group_options
  (group_code, group_name, category, description, layout_ref, repeat_mode,
   field_slot_map, slot_deco_map, layout_slot_map, extra_css, sort_order, is_enabled)
values ('cg_my_layout','我的布局','creative','说明',
  '2col_equal','once',
  '{"highlights":"slot_a","avatar":"slot_b"}'::jsonb,
  '{"slot_a":"deco:bubble_style.wechat_left"}'::jsonb,
  '{"slot_a":1,"slot_b":2}'::jsonb,
  '.container-group.cg_my_layout{...}',
  (select coalesce(max(sort_order),0)+1 from style_container_group_options), true);
```

### 6.5 请求礼仪
- `value` 用 **snake_case**，标签用中文，描述一句话说清效果。
- 一条请求集中说清：用在哪个维度/子维度、解决什么主题、CSS 片段是什么。
- 不要一次塞几十条；theme 驱动、少而精。
- 用户审核通过并执行后，组件即生效，你后续设计就能直接引用。

---

## 7. 约束与坑（务必看，避免白干）

1. **只引用已存在的 `value`。** 拼错/捏造的 value 引擎直接忽略，卡片变默认样，你以为生效了其实没。不确定先查本手册 §3 或 `SELECT value FROM style_<dim>_options WHERE sub_dim='...'`。
2. **agent 无 DB 写权限**：所有新增/修改都只能产出 SQL 交用户执行（见 §6）。
3. **per-element 维度**写成对象 `{title,date,capsule,highlights}` 才有逐字段差异；写字符串 = 四字段同值。
4. **对齐三层级**（易混）：`layout.block_align`(块) → `layout.inline_align`(行内，全局默认) → `typo.alignment_mode`(字段级，默认 `inherit` 跟随行内)。想让某字段单独改方向，只动 `alignment_mode` 那一个字段。
5. **Deco Box 叠加顺序** = 数组由外到内；`coincide:true` 才与内层边缘重合。
6. **容器组只渲染 highlights 作用域**（highlight_N/avatar/like/share/comment），不会重渲染 date/title/capsule 四槽。整卡级需求用 `boxes` 的 `target:'global'` 而非容器组。
7. **毛玻璃需要 backdrop-filter 支持**；`filter_self` 与 `filter_backdrop` 已解耦可并存，放心叠。
8. **缓存**：前端改了 DB 模板会自动在下次加载时重拉，**你设计 style_json 不需要 bump `?v=`**（那是改引擎代码才要的）。
9. **STYLE_POOL 旧条目多为旧 schema**，新设计必须遵循本手册 §1 的 v2 结构，否则不渲染。
10. **设计要大胆**：本手册鼓励你为匹配主题大胆组合（毛玻璃+扫描线+高对比撞色+几何字体等）。保守求稳=浪费这套系统的能力。但「大胆」建立在**复用现有组件**之上，不是自己写 CSS 硬塞。

---

## 8. 现成设计示例（直接抄，再改）

### 例 A · 赛博朋克终端（硬核/代码/暗黑）
```jsonc
{
  "palette": {"harmony":"comp_neon_black","tone":"dark_deep","slot":"original"},
  "layout": {"grid":"single","density":"dense","flow":"horizontal"},
  "typo": {"font_family":"terminal_mono","weight_gradient":"bold_heavy","size_scale":"compact_dense",
           "alignment_mode":{"title":"left","date":"left","capsule":"left","highlights":"left"}},
  "border": {"radius_size":"none","border_width":"thin","border_style":"solid","border_shadow":"none"},
  "deco": {"boxes":[{"style":"gradient_linear","target":"highlights"},{"style":"glass_standard","target":"highlights"}],"box_radius":0,"box_gap":8},
  "element": {"header_deco":"blink","side_accent":"line_number_column","bg_pattern":"terminal_scanlines","band_inset":false,"corner_badge":"dot_status"},
  "effect": {"filter_backdrop":{"title":"backdrop_blur_md","date":"none","capsule":"none","highlights":"backdrop_blur_sm"},
             "animation":{"title":"none","date":"none","capsule":"none","highlights":"none"}}
}
```

### 例 B · 文学手账（温柔/日记/拼贴）
```jsonc
{
  "palette": {"harmony":"analogous_green_teal","tone":"light_soft","slot":"original"},
  "layout": {"grid":"single","density":"normal"},
  "typo": {"font_family":"editorial_serif","weight_gradient":"soft","size_scale":"balanced_read",
           "alignment_mode":{"title":"center","date":"inherit","capsule":"inherit","highlights":"inherit"},
           "text_decoration":{"title":["prefix_bar"],"highlights":["gradient_text"]}},
  "border": {"radius_size":"sm","border_width":"hairline","border_style":"solid","border_shadow":"soft_small"},
  "deco": {"boxes":[{"style":"tape_note","target":"highlights"},{"style":"sticky_note","target":"title"}],"box_radius":0},
  "element": {"header_deco":"solid","side_accent":"notebook_binding","bg_pattern":"horizontal_lines","band_inset":true,"corner_badge":"page_fold"},
  "effect": {"transform":{"title":"rotate_left_sm","date":"none","capsule":"none","highlights":"none"},
             "animation":{"title":"none","date":"none","capsule":"none","highlights":"none"}}
}
```

### 例 C · 社媒聊天（微信/IM）
```jsonc
{
  "palette": {"harmony":"analogous_blue_purple","tone":"light_standard","slot":"original"},
  "layout": {"grid":"single","density":"normal"},
  "typo": {"font_family":"system_sans","weight_gradient":"balanced","size_scale":"petite"},
  "border": {"radius_size":"lg","border_width":"none","border_style":"solid","border_shadow":"soft"},
  "deco": {"avatar_style":"circle_solid","avatar_pos":"side","bubble_style":"wechat_left"},
  "element": {"header_deco":"gradient","band_inset":true},
  "container_groups": ["cg_chat_message_left","cg_chat_message_right"]
}
```

### 例 D · 杂志封面（冲击/展示）
```jsonc
{
  "palette": {"harmony":"split_yellow_purple","tone":"medium_strong","slot":"swap_bg_acc"},
  "layout": {"grid":"hero","density":"sparse"},
  "typo": {"font_family":{"title":"display_geometric","date":"modern_sans","capsule":"modern_sans","highlights":"editorial_serif"},
           "weight_gradient":"bold_heavy","size_scale":"headline_impact",
           "text_decoration":{"title":["text_stroke"],"highlights":["prefix_bar"]}},
  "border": {"radius_size":"lg","border_width":"medium","border_style":"solid","border_shadow":"hard_offset"},
  "deco": {"boxes":[{"style":"gradient_flow","target":"global"},{"style":"float_card","target":"title"}],"box_radius":16},
  "element": {"header_deco":"solid","floating_deco":"art_deco_diamond","edge_deco":"notched_corner","band_inset":false},
  "effect": {"transform":{"title":"skew_left_sm","date":"none","capsule":"none","highlights":"none"},
             "animation":{"title":"none","date":"none","capsule":"none","highlights":"none"}}
}
```

### 例 E · 竖排时间轴诗笺（东方/手账/竖写）★ 新增竖排示例

前面四个例子都是横排（flow=horizontal）。这个示例展示**竖排**写法：用 `flow:"vertical"`（或 mixed + `flow_vertical`）切换 writing-mode，配合 `grid:"timeline"` 得到竖向时间轴观感。竖排时文字自上而下、从右向左阅读。

```jsonc
{
  "palette": {"harmony":"analogous_rose_red","tone":"light_soft","slot":"original"},
  "layout": {"grid":"timeline","flow":"vertical","density":"sparse",
             "slot_assignment":{"a":"date","b":"title","c":"highlights","d":"capsule"}},
  "typo": {"font_family":{"title":"editorial_serif","date":"handwritten_note","capsule":"system_sans","highlights":"editorial_serif"},
           "weight_gradient":"soft","size_scale":"large_comfort",
           "alignment_mode":{"title":"center","date":"center","capsule":"center","highlights":"left"},
           "text_decoration":{"title":["prefix_bar"],"date":["italic"]}},
  "border": {"radius_size":"md","border_width":"hairline","border_style":"solid","border_shadow":"soft_small"},
  "deco": {"boxes":[{"style":"sticky_note","target":"highlights"}],"box_radius":0},
  "element": {"header_deco":"gradient","side_accent":"solid","bg_pattern":"horizontal_lines","band_inset":true,"corner_badge":"page_fold"},
  "effect": {"transform":{"title":"none","date":"none","capsule":"none","highlights":"none"},
             "animation":{"title":"none","date":"none","capsule":"none","highlights":"fade_in"}}
}
```

> 想要"横排为主、个别字段竖排"的混排效果：把 `flow` 改回 `"mixed"`，再用 `"flow_vertical":["title"]` 这类数组指定哪些字段竖排即可，其余字段保持横向。竖排方向由引擎统一处理，你只需选对 `grid`（timeline/sidebar_left/sidebar_right 对竖向更友好）。

---

## 9. data-attr 速查（调试用，一般不用管）

引擎把每个 `style_json` 字段映射成 DOM 上的 `data-*` 属性，再由 DB css_template 的选择器命中。常用映射：
`layout.grid→data-style-layout-grid`、`layout.inline_align→data-style-layout-inline-align`、`typo.font_family.title→data-style-typo-font-family-title`、`typo.alignment_mode.title→data-style-typo-alignment-mode-title`、`border.radius_size→data-border-radius`、`deco.bubble_style→data-style-deco-bubble`、`deco.boxes→[data-style-deco-box="X"]`、`element.header_deco→data-style-element-header`、`element.side_accent→data-style-element-side`、`effect.filter_self.title→data-style-effect-filter-title`、`effect.filter_backdrop.title→data-style-effect-backdrop-title`。

> 完整映射见 `style-engine.js` 的 `ATTR_MAP`。你设计时不需关心这些——只要 `value` 在 §3 列表里，引擎与 DB 会自动接上。

---

*本手册由 Agent 基于 `style-engine.js`、`gallery.html`/`gallery-cards.js` 源码与数据库九张维度表（style_layout/typo/border/deco/effect/element/palette_options、style_container_group_options、STYLE_POOL）实测生成。组件清单与数据库实时一致；若数据库新增组件，请以数据库为准并同步更新本手册。*
