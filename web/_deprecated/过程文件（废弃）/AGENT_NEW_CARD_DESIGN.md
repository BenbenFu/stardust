# AGENT_NEW_CARD_DESIGN -- 新卡片样式设计 Agent

## 你的任务

收到用户的设计请求后，为 Gallery Card 系统设计一张新卡片样式，或为单个维度新增选项类型。最终输出：
1. **style_json** — 描述卡片各维度参数
2. **SQL 文件** — 为新选项生成 7 张维度表的 INSERT 语句（带 css_template）

**你可以自由组合已有选项，也可以创造全新选项。** 只有 CSS 中引入的"数据库中不存在的选项"才生成 INSERT。

---

## 设计方法：四层差异化设计法

每张卡片必须在以下 4 个维度做出**明确的专属决策**。同一张卡至少 2 个维度与默认通用模板不同。

| 层 | 核心作用 | 可选方向 |
|---|---|---|
| **基底材质层** | 奠定整体质感 | 纯色平涂、渐变、纸张肌理、网点印刷、屏幕发光、织物纹理、金属哑光、玻璃半透 |
| **排版骨架层** | 决定结构逻辑 | 标准纵向流、左右分栏、轴式排布、分块卡片、居中诗行、竖排右起、对角错落 |
| **装饰符号层** | 强化媒介属性 | 前缀体系、分隔体系、边角装饰 |
| **细节节奏层** | 控制阅读节奏 | 行高松紧、字距大小、段落间距、字号层级、圆角、投影 |

**设计原则：**
- **骨架优先于装饰** — 先定排版骨架，再补装饰细节
- **克制装饰数量** — 装饰元素不超过 3 种
- **一卡一媒介** — 每张卡片对应一个明确的真实媒介参照（便签纸 / CRT 终端 / 电报稿 / 报纸 等）

---

## 设计约束

### DOM 骨架（不可变）

卡片 CSS 被注入以下结构，**不能增删任何元素**：

```html
<a class="gallery-card" href="diary.html?date=...">
    <div class="card-title">日记标题</div>
    <div class="card-date">YYYY/MM/DD</div>

    <!-- 有精华句时，每条之间夹一个 hl-sep -->
    <p class="card-highlight-item">精华句 1</p>
    <div class="hl-sep"></div>
    <p class="card-highlight-item">精华句 2</p>

    <!-- 无精华句时 -->
    <div class="card-no-highlight">[ NO_HIGHLIGHTS ]</div>

    <div class="card-style">扭蛋名</div>
</a>
```

可用选择器：`.gallery-card` / `.card-title` / `.card-date` / `.card-highlight-item` / `.hl-sep` / `.card-style` / `.card-no-highlight`

全部可用 `::before` / `::after` / `:first-child` / `:last-child` / `:nth-child(n)` / `:first-letter` 等伪元素和伪类。

### 工程红线（硬标准，一票否决）

1. **不改 DOM** — 不增删元素、不改 HTML 属性、不改标签类型
2. **容器禁止 `position: fixed` / `absolute`** — 子元素和伪元素可在 `position: relative` 容器内用 absolute
3. **不写 `[data-cs="xxx"]` 前缀** — 系统自动注入作用域
4. **子元素设非透明背景时，容器必须同时设实色背景** — 基类默认 `background: transparent`
5. **全属性禁止 emoji** — 用纯文本符号或 CSS 几何图形替代
6. **禁止 hover 改变文档流尺寸** — 用 `transform`/`opacity`/`box-shadow` 替代

### 设计质量标准

1. **辨识度** — 遮挡文字后仅凭版式/配色/质感可识别媒介类型
2. **自洽性** — 视觉风格与主题语义匹配，不违和
3. **可读性** — 正文对比度 >= 4.5:1，字号 >= 10px
4. **差异化** — 与已有卡片对比，排版骨架/基底材质/装饰体系至少 1 项不同

---

## 数据库结构速览

7 张维度表，全部通过 `css_template` 字段存 CSS 规则：

| 表 | 子维度/元素 | UNIQUE 约束 |
|---|---|---|
| style_palette_options | (无子维度) | value |
| style_layout_options | top / body / bottom / side / overlay | (sub_dim, value) |
| style_typo_options | family / title_size / title_deco | (sub_dim, value) |
| style_border_options | style / radius / shadow | (sub_dim, value) |
| style_deco_options | bg_pattern / separator / pseudo_label | (sub_dim, value) |
| style_effect_options | animation / filter / transform | (sub_dim, value) |
| style_elements_options | date / capsule / title / highlights / no_highlight | (element, value) |

---

## 设计工作流

### 阶段 1: 理解需求

从用户描述中提取：
- **主题/气质** — 这张卡片为谁设计？什么情绪？（严肃/活泼/复古/现代/温暖/冷峻）
- **媒介锚定** — 对标什么真实媒介？（便签纸 / 电报稿 / 终端屏幕 / 旧书页 / ...）
- **特殊需求** — 有什么必须有的视觉元素？

### 阶段 2: 基底材质层设计

选择色板。先查现有 palette 是否匹配，否则新建。

新建色板需确定四色：
- **bg**: 卡片背景色
- **text**: 主文字色
- **accent**: 强调色（边框、分隔符、装饰）
- **muted**: 辅助色（日期、次要信息）

**媒介锚定多样性约束**：同一语义集群（如 tech/code 类）的卡片，禁止全部锚定同一媒介。从候选池中分散选取。

### 阶段 3: 排版骨架层设计

决定 layout 五个子维度：

**layout.top** — 卡片顶部区域用什么？
- `none` — 无特殊顶部
- `label` — 居中标签文字
- `status_bar` — 闪烁状态条
- `warning_bar` — 警告横条
- `doc_header` — 文档头（编号 + 规范名）
- `email_header` — 邮件头（发件人 + 日期）
- `user_bar` — 用户栏（头像 + 用户名）
- `dark_bar` — 反色标题条（深底浅字）
- `role_panel` — 角色面板（头像+名字+日期+进度条）

**layout.body** — 主体内容区结构？
- `standard` — title → date → highlights
- `code_area` — 行号栏 + function 前缀
- `ascii_zone` — ASCII 字符画区
- `sticky_note` — 标题浮出便利贴

**layout.bottom** — 底部标签样式？
- `style_tag` — `.card-style` 标签
- `tag_bar` — 分栏日期
- `none` — 隐藏

**layout.side** — 侧边元素？
- `none` — 无
- `line_numbers` — 行号栏
- `holes` — 活页孔

**layout.overlay** — 覆盖层？
- `none` — 无
- `seal` — 印章
- `stamp` — 戳记
- `tape` — 胶带条纹
- `scanline` — 扫描线
- `dump` — hex dump
- `censored` — 打码遮挡

**层间依赖约束：**
- `layout.top = role_panel` → `layout.bottom = none`
- `layout.side = line_numbers` → `layout.body = code_area`
- `layout.side = holes` → `layout.bottom = tag_bar`
- `layout.overlay = scanline` → `effect.animation = blink`

### 阶段 4: 字体与标题层设计

**typo.family** — `mono` / `consolas` / `serif` / `cursive`

**typo.title_size** — 11~18px（标准 13px）

**typo.title_deco** — 标题装饰：
`none` / `border_bottom` / `underline` / `wavy_underline` / `uppercase_center` / `center_border_bottom` / `center_bg_highlight` / `function_prefix` / `inverted_bar` / `left_border` / `mirror` / `sticky_note`

### 阶段 5: 边框与阴影层设计

**border.style** — `solid` / `none` / `thin_solid` / `thick_solid` / `heavy_solid` / `double` / `dotted` / `dashed` / `left_accent` / `solid_outline`

**border.radius** — `0` 或 `8`

**border.shadow** — `none` / `soft` / `inset` / `soft_small`

### 阶段 6: 装饰层设计

**deco.bg_pattern** — 背景纹理：`none` / `tape_stripe` / `perf_line` / `scanline` / `lines` / `grid`

**deco.separator** — 句间分隔符：`none` / `asterisk` / `dash` / `dots` / `plus` / `bang` / `hex` / `code_comment` / `tilde` / `triple_star` / `question` 等

**deco.pseudo_label** — 伪元素标签：`none` / `tamagotchi` / `question_mark` / `gaomi_header`

### 阶段 7: 效果与元素层设计

**effect.animation** — `none` / `blink` / `scanline_jitter`

**effect.filter** — `none` / `blur`

**effect.transform** — `none` / `slight_tilt` / `mirror`

**elements 变体：**
- **date**: `default` / `vertical` / `stamp` / `big_number` / `right_align` / `hidden`
- **capsule** (.card-style): `default` / `rounded` / `outline` / `underline` / `bubble` / `hidden`
- **title**: `default` / `gradient` / `strikethrough` / `outline_text` / `uppercase`
- **highlights** (.card-highlight-item): `default` / `bullet_dot` / `numbered` / `dash_prefix` / `no_prefix` / `tag_style`

---

## css_template 编写规范

### 选择器使用 data-* 属性

新选项的 CSS 必须通过 `data-*` 属性选择器隔离：

```text
.gallery-card[data-palette="xxx"]         → 色板
.gallery-card[data-layout-top="xxx"]      → layout 子维度
.gallery-card[data-border-style="xxx"]      → 边框样式
.gallery-card[data-shadow="xxx"]           → 阴影
.gallery-card[data-separator="xxx"]        → 分隔符
.gallery-card[data-pseudo-label="xxx"]     → 伪标签
.gallery-card[data-bg-pattern="xxx"]       → 背景图案
.gallery-card[data-capsule-variant="xxx"]  → 胶囊变体
.gallery-card[data-hl-variant="xxx"]       → 精华句变体
.gallery-card[data-no-hl-variant="xxx"]    → 无精华变体
.gallery-card[data-date-variant="xxx"]     → 日期变体
.gallery-card[data-title-variant="xxx"]    → 标题变体
```

### 颜色变量

始终使用 CSS 变量：
- `--card-bg` / `--card-text` / `--card-accent` / `--card-muted`
- `--card-accent-rgb` / `--card-bg-rgb`（用于 `rgba()`）

### 伪元素中文转义

伪元素 `content` 中的中文必须用 Unicode 转义：
```css
content: "\9ad8 \5bc6 \4e1c \5317 \4e61";  /* "高 密 东 北 乡" */
```

### 格式规范

- 缩进 2 空格
- 选择器后空格 + `{` 独占一行
- 每个声明独占一行，末尾分号
- 颜色 hex 小写
- 多规则之间空一行

---

## 输出格式

### 一、设计说明

简要描述设计思路：媒介锚定、核心视觉特征、与现有卡片的差异点。

### 二、style_json

```json
{
  "palette": "...",
  "layout": {
    "top": "...",
    "body": "...",
    "bottom": "...",
    "side": "...",
    "overlay": "..."
  },
  "typo": {
    "family": "...",
    "title_size": 13,
    "title_deco": "..."
  },
  "border": {
    "style": "...",
    "radius": "0",
    "shadow": "..."
  },
  "deco": {
    "bg_pattern": "...",
    "separator": "...",
    "pseudo_label": "..."
  },
  "effect": {
    "animation": "...",
    "filter": "...",
    "transform": "..."
  },
  "elements": {
    "date": "...",
    "capsule": "...",
    "title": "...",
    "highlights": "..."
  }
}
```

### 三、SQL 文件

完整的 `.sql` 文件，包含：
1. 文件头注释（设计说明）
2. 按表分组的 INSERT 语句（只生成新选项）
3. 每段 INSERT 带 `ON CONFLICT ... DO UPDATE`（幂等安全）
4. **STYLE_POOL INSERT**（★ 必须 — 否则 Gallery 页无法找到样式）
5. 末尾验证查询（可选）

SQL 模板：

```sql
-- ============================================================
-- 卡片名 / 主题名
-- 设计说明：...
-- ============================================================

-- 一、配色方案
INSERT INTO style_palette_options
    (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'palette_value',
    '中文标签',
    '#bg',
    '#text',
    '#accent',
    '#muted',
    '描述',
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

-- 二、xxx 维度新选项
INSERT INTO style_xxx_options
    (sub_dim, value, label, description, sort_order, css_template)
VALUES (
    'sub_dim_name',
    'option_value',
    '中文标签',
    '描述',
    99,
    'CSS rules here'
)
ON CONFLICT (sub_dim, value) DO UPDATE SET
    label        = EXCLUDED.label,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;

-- 验证查询（可选）
-- SELECT value, label FROM style_palette_options WHERE value = 'palette_value';

-- ============================================================
-- STYLE_POOL 条目（★ 必须 — Gallery 路由入口）
-- name 必须由用户指定，禁止 agent 自行编造！
-- 原因：name 必须与 DIARIES.capsule 的值**完全一致**（含空格、大小写）。
-- 典型案例：`API 响应`（带空格）≠ `API响应`（无空格）
--   → ON CONFLICT(name) 匹配失败 → 插入新行而非更新。
-- 前置要求：STYLE_POOL.name 必须有唯一约束，否则 ON CONFLICT (name) 报 42P10 错误。
-- 生成前必须先向用户确认：STYLE_POOL.name 应该叫什么？
-- 前置要求：STYLE_POOL.name 必须有唯一约束，否则 ON CONFLICT (name) 报 42P10 错误。
--   若尚未创建，先在 Supabase SQL Editor 执行：
--   ALTER TABLE "STYLE_POOL" ADD CONSTRAINT style_pool_name_unique UNIQUE (name);
-- ============================================================
INSERT INTO "STYLE_POOL" (name, category, "desc", style_json, active)
VALUES (
    '← 此处由用户指定，严禁 agent 自行编造',
    'category',
    '简短描述',
    '{"palette":"...","layout":{...},...}',
    true
)
ON CONFLICT (name) DO UPDATE SET
    category    = EXCLUDED.category,
    "desc"      = EXCLUDED."desc",
    style_json  = EXCLUDED.style_json,
    active      = EXCLUDED.active;
```

---

## 示例：用户说 "帮我设计一张电报风格的卡片"

### 理解需求
- 主题气质：紧急、正式、复古通讯
- 媒介锚定：老式电报稿（Telegram）
- 核心特征：黄/米色电报纸、大写标题、"STOP" 分隔符、打字机字体

### 设计决策

| 维度 | 选项 | 说明 |
|---|---|---|
| palette | telegram_yellow（新建） | 电报黄底色 #f4e4bc |
| layout.top | none | 无顶部组件 |
| layout.body | standard | 标准纵向流 |
| layout.bottom | style_tag | 已有选项 |
| layout.side | none | 无 |
| layout.overlay | none | 无 |
| typo.family | mono | 打字机字体 |
| typo.title_size | 13 | 标准 |
| typo.title_deco | uppercase_center | 已有：大写居中（电报标题惯例） |
| border.style | thin_solid | 已有 |
| border.radius | 0 | 已有 |
| border.shadow | none | 已有 |
| deco.bg_pattern | none | 无纹理 |
| deco.separator | stop_word（新建） | "— STOP —" 分隔符 |
| deco.pseudo_label | none | 已有 |
| effect | all none | 已有 |
| elements | all default | 已有 |

需要新建的选项：`telegram_yellow`（palette）、`stop_word`（separator）

已有选项直接引用 → 不生成 INSERT。

### 输出

style_json + 只含 3 条 INSERT 的 SQL 文件（2 维度 + 1 STYLE_POOL）。

---

## 仅新增单个维度选项

用户可能说 "给 highlights 加一个竖线前缀变体" 或 "新增一个紫色配色"。

此时：
1. 确认该维度现有选项列表（避免重复）
2. 设计新选项的 css_template
3. 输出单条 INSERT（不必输出完整 style_json）

示例 — 新增紫色配色：

```sql
INSERT INTO style_palette_options
    (value, label, bg, text_color, accent, muted, description, sort_order, css_template)
VALUES (
    'purple_haze',
    '紫雾',
    '#2d1b3d',
    '#e0d0f0',
    '#9b6dff',
    '#7a6b8a',
    '深紫底色 + 淡紫文字，迷幻气质',
    99,
    '.gallery-card[data-palette="purple_haze"] { --card-bg:#2d1b3d; --card-text:#e0d0f0; --card-accent:#9b6dff; --card-muted:#7a6b8a; --card-accent-rgb:155,109,255; --card-bg-rgb:45,27,61; }'
)
ON CONFLICT (value) DO UPDATE SET
    bg           = EXCLUDED.bg,
    text_color   = EXCLUDED.text_color,
    accent       = EXCLUDED.accent,
    muted        = EXCLUDED.muted,
    description  = EXCLUDED.description,
    css_template = EXCLUDED.css_template;
```

---

## 注意事项

1. **先查现有选项** — 用本文档内置的速查表，避免重复 INSERT
2. **css_template 必须包含完整选择器** — 用 `data-*` 属性选择器，不要省略
3. **伪元素中文用 Unicode 转义** — 防止编码问题
4. **sort_order 用 99+** — 新选项排末尾，后续可手动调整
5. **保持 style_json 格式一致** — 所有字段都要填，值用小写下划线命名
6. **ON CONFLICT 确保幂等** — 重复执行不会报错
