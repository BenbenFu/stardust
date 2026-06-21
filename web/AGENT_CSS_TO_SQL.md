# AGENT_CSS_TO_SQL -- CSS 转 style_json + 样式字段 SQL

## 你的任务

收到一段 Gallery Card CSS 后，完成两件事：
1. 拆解 CSS 为 7 层 style_json
2. 为 CSS 中**新的设计选项**生成对应维度表的 INSERT SQL（带 css_template）

**注意：只有 CSS 中引入的选项在现有 DB 中不存在时，才生成 INSERT。** 已存在的选项只需在 style_json 中引用其 value 即可。

---

## 输入格式

用户会提供一段 CSS，可能带一段文字说明设计的主题/气质。CSS 通常涉及选择器：

```text
.gallery-card           -- 卡片容器
.card-title             -- 日记标题
.card-date              -- 日期
.card-highlight-item    -- 精华句
.hl-sep                 -- 句间分隔符
.card-no-highlight      -- 无精华占位
.card-style             -- 扭蛋名标签
```

全部可用 `::before` / `::after` 伪元素。

---

## 数据库结构（7 张维度表）

### 表 1: style_palette_options

| 列 | 类型 | 说明 |
|---|---|---|
| value | TEXT UNIQUE | style_json.palette 的值 |
| label | TEXT | 中文显示名 |
| bg | TEXT | 背景色 |
| text_color | TEXT | 主文字色 |
| accent | TEXT | 强调色 |
| muted | TEXT | 次要文字色 |
| description | TEXT | 一句话说明 |
| sort_order | INT | 排序号 |
| css_template | TEXT | 该色板的 CSS 变量注入规则 |

### 表 2-6: style_layout_options / style_typo_options / style_border_options / style_deco_options / style_effect_options

这些表结构相同：

| 列 | 类型 | 说明 |
|---|---|---|
| sub_dim | TEXT | 子维度名（见下方枚举） |
| value | TEXT | 选项值 |
| label | TEXT | 中文显示名 |
| description | TEXT | 说明 |
| sort_order | INT | 排序号 |
| css_template | TEXT | 该选项对应的 CSS 规则 |

UNIQUE(sub_dim, value)

### 表 7: style_elements_options

| 列 | 类型 | 说明 |
|---|---|---|
| element | TEXT | 元素名（date / capsule / title / highlights / no_highlight） |
| value | TEXT | 选项值 |
| label | TEXT | 中文显示名 |
| description | TEXT | 说明 |
| sort_order | INT | 排序号 |
| css_template | TEXT | 该元素变体的 CSS 规则 |

UNIQUE(element, value)

---

## 子维度枚举

### layout 子维度
- **sub_dim**: top / body / bottom / side / overlay

### typo 子维度
- **sub_dim**: family / title_size / title_deco

### border 子维度
- **sub_dim**: style / radius / shadow

### deco 子维度
- **sub_dim**: bg_pattern / separator / pseudo_label

### effect 子维度
- **sub_dim**: animation / filter / transform

### elements 元素
- **element**: date / capsule / title / highlights / no_highlight

---

## 现有选项速查表（不要重复生成！）

只生成 **CSS 中引入但下表中不存在的** 新选项。

### palette (value → label)
```
industrial             → 工业屏
repair_yellow          → 维修便签
printer_green          → 针式打印
bsod_blue              → 过热终端
alert_red              → 欠费警告
terminal_black         → 故障日志
vscode_dark            → 代码编程
archive_khaki          → 技术文档
github_light           → 工作办公
diary_cream            → 生活记录
twitter_light          → 社交网络
notebook_white         → 创意写作
newspaper              → 媒体通稿
role_parchment         → 角色扮演
novel_warm             → 小说叙事
blueprint              → 格式规范
mystery_dark           → 未知分类
warm                   → 暖色
moyan_earth            → 高密乡土
```

### layout.top (value)
`none, label, status_bar, warning_bar, doc_header, email_header, user_bar, dark_bar, role_panel`

### layout.body (value)
`standard, code_area, ascii_zone, sticky_note`

### layout.bottom (value)
`style_tag, tag_bar, none`

### layout.side (value)
`none, line_numbers, holes`

### layout.overlay (value)
`none, seal, stamp, tape, scanline, dump, censored`

### typo.family (value)
`mono, consolas, serif, cursive`

### typo.title_deco (value)
`none, border_bottom, underline, wavy_underline, uppercase_center, center_border_bottom, center_bg_highlight, function_prefix, inverted_bar, left_border, mirror, sticky_note`

### border.style (value)
`solid, none, thin_solid, thick_solid, heavy_solid, double, dotted, dashed, left_accent, solid_outline`

### border.radius (value)
`0, 8`

### border.shadow (value)
`none, soft, inset, soft_small, rural_paper`

### deco.bg_pattern (value)
`none, tape_stripe, perf_line, scanline, lines, grid`

### deco.separator (value)
`none, asterisk, dash, dots, dots_sparse, plus, bang, hex, code_comment, tilde, triple_star, question, dot_triple`

### deco.pseudo_label (value)
`none, tamagotchi, question_mark, gaomi_header`

### effect.animation (value)
`none, blink, scanline_jitter`

### effect.filter (value)
`none, blur`

### effect.transform (value)
`none, slight_tilt, mirror`

### elements.date (value)
`default, vertical, stamp, big_number, right_align, hidden`

### elements.capsule (value)
`default, rounded, outline, underline, bubble, hidden, red_double_line`

### elements.title (value)
`default, gradient, strikethrough, outline_text, uppercase`

### elements.highlights (value)
`default, bullet_dot, numbered, dash_prefix, no_prefix, tag_style, left_border_red`

### elements.no_highlight (value)
（暂无基础选项，`gaomi_empty` 已存在）

---

## 工作流程

### Step 1: 提取色板 (palette)

从 `.gallery-card` 的 `background` / `color` / 强调色中提取四色：
- **bg**: 卡片背景色
- **text_color**: 主文字色（通常 `.card-title` / `.card-highlight-item` 的 `color`）
- **accent**: 强调色（边框 / 分隔符 / 装饰色）
- **muted**: 辅助色（`.card-date` / `.hl-sep` 等次要元素的颜色）

如果四色组合与现有 palette 完全匹配 → 直接引用。不匹配 → 新建。

### Step 2: 拆解 layout

分析 CSS 中是否有以下特征：
- **top**: `.card-title` 之上是否有 `::before` 伪元素生成顶部区域？
  - 有标签文字 → `label`
  - 闪烁状态条 → `status_bar`
  - 文档头 → `doc_header`
  - 无 → `none`
- **body**: 内容是标准纵向流还是有特殊结构？
  - 标准 title→date→highlights → `standard`
  - 有行号 → `code_area`
  - 有 ASCII 艺术区 → `ascii_zone`
  - 标题浮出便利贴 → `sticky_note`
- **bottom**: `.card-style` 如何呈现？
  - 普通标签 → `style_tag`
  - 分栏 → `tag_bar`
  - 隐藏 → `none`
- **side**: 有侧边元素吗？→ `line_numbers` / `holes` / `none`
- **overlay**: 有覆盖层吗？→ `seal` / `stamp` / `tape` / `scanline` / `dump` / `censored` / `none`

### Step 3: 拆解 typo

- **family**: 从 `font-family` 推断 → `mono` / `consolas` / `serif` / `cursive`
- **title_size**: 从 `.card-title` 的 `font-size` 提取（数字字符串）
- **title_deco**: 分析标题装饰 → 底边线 / 下划线 / 波浪线 / 大写居中 / 函数前缀 / 反色条 / 左色条 / 镜像 / 便签 / 无

### Step 4: 拆解 border

- **style**: `solid` / `none` / `thin_solid` / `thick_solid` / `heavy_solid` / `double` / `dotted` / `dashed` / `left_accent` / `solid_outline`
- **radius**: `0` 或 `8`
- **shadow**: `none` / `soft` / `inset` / `soft_small` — 如果 CSS 中有特殊的 inset + hover 组合，可能是新选项

### Step 5: 拆解 deco

- **bg_pattern**: 背景有纹理吗？→ `tape_stripe` / `perf_line` / `scanline` / `lines` / `grid` / `none`
- **separator**: `.hl-sep` 的内容字符是什么？
- **pseudo_label**: 有 `::before` / `::after` 伪元素生成特殊标签吗？

### Step 6: 拆解 effect

- **animation**: `none` / `blink` / `scanline_jitter`
- **filter**: `none` / `blur`
- **transform**: `none` / `slight_tilt` / `mirror`

### Step 7: 拆解 elements

- **date**: 日期样式变体 → `default` / `vertical` / `stamp` / `big_number` / `right_align` / `hidden`
- **capsule**: `.card-style` 样式 → `default` / `rounded` / `outline` / `underline` / `bubble` / `hidden`
- **title**: 标题额外效果 → `default` / `gradient` / `strikethrough` / `outline_text` / `uppercase`
- **highlights**: 精华句前缀样式 → `default` / `bullet_dot` / `numbered` / `dash_prefix` / `no_prefix` / `tag_style`
- **no_highlight**: 无精华占位样式

---

## 输出格式

### 第一部分: style_json

```json
{
  "palette": "value_name",
  "layout": {
    "top": "none",
    "body": "standard",
    "bottom": "style_tag",
    "side": "none",
    "overlay": "none"
  },
  "typo": {
    "family": "mono",
    "title_size": 13,
    "title_deco": "none"
  },
  "border": {
    "style": "thin_solid",
    "radius": "0",
    "shadow": "none"
  },
  "deco": {
    "bg_pattern": "none",
    "separator": "none",
    "pseudo_label": "none"
  },
  "effect": {
    "animation": "none",
    "filter": "none",
    "transform": "none"
  },
  "elements": {
    "date": "default",
    "capsule": "default",
    "title": "default",
    "highlights": "default"
  }
}
```

### 第二部分: SQL INSERT

只为 **新选项**（不在现有速查表中的）生成 INSERT。每个 INSERT 用 `ON CONFLICT ... DO UPDATE`，幂等安全。

#### 色板 INSERT 模板

```sql
INSERT INTO style_palette_options
    (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'palette_value',
    '中文标签',
    '#bg',
    '#text',
    '#accent',
    '#muted',
    '简短描述（含主题名）',
    99,
    '.gallery-card[data-palette="palette_value"] { --card-bg:#bg; --card-text:#text; --card-accent:#accent; --card-muted:#muted; --card-accent-rgb:R,G,B; --card-bg-rgb:R,G,B; }'
)
ON CONFLICT (value) DO UPDATE SET
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;
```

#### 非色板维度 INSERT 模板

```sql
INSERT INTO style_xxx_options
    (sub_dim, value, label, description, sort_order, css_template)
VALUES (
    'sub_dim_name',
    'option_value',
    '中文标签',
    '描述（含主题名）',
    99,
    '/* 使用 data-* 属性选择器的 CSS 规则 */'
)
ON CONFLICT (sub_dim, value) DO UPDATE SET
    label        = EXCLUDED.label,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;
```

#### elements 表 INSERT 模板

```sql
INSERT INTO style_elements_options
    (element, value, label, description, sort_order, css_template)
VALUES (
    'element_name',
    'option_value',
    '中文标签',
    '描述（含主题名）',
    99,
    '/* 使用 data-* 属性选择器的 CSS 规则 */'
)
ON CONFLICT (element, value) DO UPDATE SET
    label        = EXCLUDED.label,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;
```

---

## css_template 编写规范

### 选择器规则

使用 `data-*` 属性选择器隔离作用域：

| 维度 | 选择器格式 |
|---|---|
| palette | `.gallery-card[data-palette="value"]` |
| layout | `.gallery-card[data-layout-top="value"]` 等 |
| typo | `.gallery-card[data-typo-family="value"]` |
| border style | `.gallery-card[data-border-style="value"]` |
| border shadow | `.gallery-card[data-shadow="value"]` |
| deco separator | `.gallery-card[data-separator="value"]` |
| deco pseudo_label | `.gallery-card[data-pseudo-label="value"]` |
| deco bg_pattern | `.gallery-card[data-bg-pattern="value"]` |
| elements capsule | `.gallery-card[data-capsule-variant="value"]` |
| elements highlights | `.gallery-card[data-hl-variant="value"]` |
| elements no_highlight | `.gallery-card[data-no-hl-variant="value"]` |
| elements date | `.gallery-card[data-date-variant="value"]` |
| elements title | `.gallery-card[data-title-variant="value"]` |

### 颜色变量

始终使用 CSS 变量而非硬编码色值。可用变量：
- `--card-bg` / `--card-text` / `--card-accent` / `--card-muted`
- `--card-accent-rgb` / `--card-bg-rgb`（用于 `rgba()` ）
- `--pixel-dark` / `--pixel-dim` / `--pixel-alert` / `--gba-bg`（全局令牌）

### DOM 约束

只操作以下 6 个选择器，不能增删元素：
- `.gallery-card` / `.card-title` / `.card-date`
- `.card-highlight-item` / `.hl-sep` / `.card-style` / `.card-no-highlight`

### 工程红线（检查项）

- 不出现 `position: fixed`
- 不出现 emoji 字符
- 伪元素中的中文用 Unicode 转义（`\4f60 \597d` 而非 `你好`），避免编码问题
- hover 不改变文档流尺寸

### 格式规范

- 缩进 2 空格
- 选择器后空格 + `{` 独占一行
- 每个声明独占一行，末尾分号
- 颜色统一 hex 小写
- 小数点保留前导零

---

## 示例：莫言卡片

### 输入（CSS 片段）

```css
.gallery-card { background: #efe0c4; color: #3d2010; }
.gallery-card::before { content: "高 密 东 北 乡"; display: block; font-size: 10px; letter-spacing: 5px; color: #6b4a3a; border-bottom: 2px solid #9b2d1e; }
.card-highlight-item { padding-left: 8px; border-left: 2px solid #9b2d1e; font-size: 11px; }
.card-highlight-item::before { content: none; }
.hl-sep { color: #9b2d1e; }
.hl-sep::before { content: "\B7  \B7  \B7"; }
.card-style { font-size: 9px; color: #9b2d1e; text-align: center; letter-spacing: 3px; border-top: 2px solid #9b2d1e; border-bottom: 2px solid #9b2d1e; }
.card-no-highlight { font-size: 10px; color: #8b6b5a; text-align: center; }
.card-no-highlight::before { content: "[ 今 日 无 事 ]"; }
```

### 输出（style_json）

```json
{
  "palette": "moyan_earth",
  "layout":  { "top": "none", "body": "standard", "bottom": "style_tag", "side": "none", "overlay": "none" },
  "typo":    { "family": "serif", "title_size": 16, "title_deco": "none" },
  "border":  { "style": "thin_solid", "radius": "0", "shadow": "rural_paper" },
  "deco":    { "bg_pattern": "none", "separator": "dot_triple", "pseudo_label": "gaomi_header" },
  "effect":  { "animation": "none", "filter": "none", "transform": "none" },
  "elements": { "date": "default", "capsule": "red_double_line", "title": "default", "highlights": "left_border_red" }
}
```

### 输出（SQL — 仅新选项）

生成了 7 条 INSERT，分属：
- `style_palette_options`: moyan_earth（新色板）
- `style_border_options`: rural_paper（新阴影）
- `style_deco_options`: gaomi_header（新伪标签）、dot_triple（新分隔符）
- `style_elements_options`: left_border_red（新精华变体）、red_double_line（新胶囊变体）、gaomi_empty（新无精华变体）

layout 层的 `none` / `standard` / `style_tag` 都是已有选项 → 不生成 INSERT。
