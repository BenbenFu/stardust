# 维度选项表 · 完整使用说明

> 本文档说明 7 张维度选项表各自的作用、前端「新增」按钮的使用方式，以及如何在 Supabase 后端直接操作。

---

## 一、7 张表总览

| 表名 | 对应维度 | 说明 |
|------|---------|------|
| `style_layout_options` | layout（布局骨架） | 控制卡片各区域的布局组件 |
| `style_palette_options` | palette（配色方案） | 控制卡片的整体配色 |
| `style_typo_options` | typo（排版规则） | 控制字体/字号/字重 |
| `style_border_options` | border（边框材质） | 控制卡片边框样式 |
| `style_elements_options` | elements（元素变体） | 控制各 UI 元素的视觉变体 |
| `style_deco_options` | deco（装饰层） | 控制背景纹理/贴纸等装饰 |
| `style_effect_options` | effect（动效层） | 控制扫描线/动画/过渡等动效 |

---

## 二、逐表说明

### 1. `style_layout_options` — 布局骨架

**作用**：决定卡片各个区域（top/body/bottom/side/overlay）使用哪种布局组件。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `value` | text (PK) | 存储值，如 `date-centered` |
| `label` | text | 显示名，如 `日期居中` |
| `col` | text | 所属区域：`top` / `body` / `bottom` / `side` / `overlay` |
| `description` | text | 说明文字（可选） |

**前端对应**：左侧面板 → `[粗] 布局骨架 LAYOUT` 下的 5 个下拉框（Top / Body / Bottom / Side / Overlay），每个下拉框只显示 `col` 值对应的行。

**示例数据**：
```sql
-- Top 区域的可选值
select value, label from style_layout_options where col = 'top';
-- 返回: date-left, date-centered, title-only, ...
```

---

### 2. `style_palette_options` — 配色方案

**作用**：定义卡片的配色方案（背景色/主文字色/强调色/次要色）。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `value` | text (PK) | 色板名，如 `gba-green` |
| `label` | text | 显示名，如 `GBA 绿` |
| `bg` | text | 背景色，如 `#cadbb7` 或 `transparent` |
| `text_color` | text | 主文字色，如 `#1e2622` |
| `accent` | text | 强调色，如 `#3a7d44` |
| `muted` | text | 次要文字色，如 `#707a65` |
| `description` | text | 说明文字（可选） |

**前端对应**：左侧面板 → `[中] 配色方案 PALETTE` 下的色板选择区域（网格展示，非下拉框）。

**特殊说明**：新增色板后，前端会自动调用 `registerPalette()` 将色板的 CSS 规则注入页面，无需手动操作。

---

### 3. `style_typo_options` — 排版规则

**作用**：控制卡片文字的字体、字号、字重。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `value` | text (PK) | 存储值 |
| `label` | text | 显示名 |
| `description` | text | 说明文字（可选） |

**前端对应**：左侧面板 → `[中] 排版规则 TYPOGRAPHY` 下的 3 个下拉框：
- **字体**（对应 `font` key）：如 `mono`（等宽）/ `sans`（无衬线）
- **字号**（对应 `size` key）：如 `sm` / `md` / `lg`
- **字重**（对应 `weight` key）：如 `normal` / `bold`

这三组选项来自同一张表（`style_typo_options`），通过前端逻辑区分（字体/字号/字重的 value 命名规则不同，用前缀或命名约定区分）。

---

### 4. `style_border_options` — 边框材质

**作用**：控制卡片边框的视觉样式。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `value` | text (PK) | 存储值，如 `pixel-dashed` |
| `label` | text | 显示名，如 `像素虚线` |
| `description` | text | 说明文字（可选） |

**前端对应**：左侧面板 → `[中] 边框材质 BORDER` 下的 1 个下拉框。

---

### 5. `style_elements_options` — 元素变体

**作用**：控制卡片中各个 UI 元素（日期/胶囊/标题/高亮）的视觉变体。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `value` | text (PK) | 存储值，如 `date-pixel` |
| `label` | text | 显示名，如 `像素日期` |
| `element` | text | 所属元素：`date` / `capsule` / `title` / `highlights` |
| `description` | text | 说明文字（可选） |

**前端对应**：左侧面板 → `[细] 元素变体 ELEMENTS` 下的 4 个下拉框：
- **日期变体**（对应 `dateVariant` key）：`element = 'date'` 的行
- **胶囊变体**（对应 `capsuleVariant` key）：`element = 'capsule'` 的行
- **标题变体**（对应 `titleVariant` key）：`element = 'title'` 的行
- **高亮变体**（对应 `highlightsVariant` key）：`element = 'highlights'` 的行

**重要**：新增元素变体时，必须在弹窗中正确设置「所属元素」（`element` 字段），否则该选项不会出现在任何下拉框中。

---

### 6. `style_deco_options` — 装饰层

**作用**：控制卡片的背景纹理、贴纸等装饰效果。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `value` | text (PK) | 存储值，如 `grid` |
| `label` | text | 显示名，如 `像素网格` |
| `description` | text | 说明文字（可选） |

**前端对应**：左侧面板 → `[细] 装饰层 DECORATION` 下的 2 个下拉框：
- **背景纹理**（对应 `bgPattern` key）
- **贴纸装饰**（对应 `sticker` key）

---

### 7. `style_effect_options` — 动效层

**作用**：控制卡片的扫描线、动画、过渡等动态效果。

**字段**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `value` | text (PK) | 存储值，如 `scanline-h` |
| `label` | text | 显示名，如 `水平扫描线` |
| `description` | text | 说明文字（可选） |

**前端对应**：左侧面板 → `[细] 动效层 EFFECTS` 下的 3 个下拉框：
- **扫描线**（对应 `scanline` key）
- **动画**（对应 `anim` key）
- **过渡**（对应 `transition` key）

---

## 三、前端「新增」按钮使用方式

### 操作步骤

1. 打开 `capsule-preview.html`（需通过 HTTP 服务器访问，不能直接双击用 `file://` 协议打开）
2. 等待页面加载完成（状态栏显示「已连接 DB」或类似提示）
3. 展开对应的维度面板（点击面板 header，▼ 表示展开）
4. 点击面板 header 右侧的 **「+新增」** 按钮
5. 在弹出的模态框中填写：
   - **value**：存储值，英文小写，如 `my_new_option`
   - **label**：显示名，中文，如 `我的新选项`
   - **description**：说明文字（可选）
   - 如果是「配色方案」，还需填写 `bg` / `text_color` / `accent` / `muted` 四个颜色字段
   - 如果是「元素变体」，还需填写 `element` 字段（date/capsule/title/highlights）
6. 点击 **「保存」**
7. 保存成功后，下拉框会自动刷新，新选项立即出现在列表中

### 各维度「新增」按钮位置

| 面板 | 按钮位置 | 弹窗额外字段 |
|------|---------|--------------|
| `[粗] 布局骨架 LAYOUT` | header 右侧 | 无（需注意的是新增的选项会应用到所有 `col` 区域，需在 DB 中手动设置 `col` 值） |
| `[中] 配色方案 PALETTE` | header 右侧 | `bg` / `text_color` / `accent` / `muted` |
| `[中] 排版规则 TYPOGRAPHY` | header 右侧 | 无（`font`/`size`/`weight` 共用同一张表，新增时会同时出现在三个下拉框中，需通过命名约定区分） |
| `[中] 边框材质 BORDER` | header 右侧 | 无 |
| `[细] 元素变体 ELEMENTS` | header 右侧 | `element`（日期/胶囊/标题/高亮） |
| `[细] 装饰层 DECORATION` | header 右侧 | 无（`bgPattern`/`sticker` 共用同一张表） |
| `[细] 动效层 EFFECTS` | header 右侧 | 无（`scanline`/`anim`/`transition` 共用同一张表） |

---

## 四、在 Supabase 后端直接操作

### 4.1 新增选项（INSERT）

```sql
-- 例1：新增一个布局选项（Top 区域，日期居左）
insert into style_layout_options (value, label, col, description)
values ('date-left-v2', '日期居左 v2', 'top', '日期在左侧的新版布局');

-- 例2：新增一个色板
insert into style_palette_options (value, label, bg, text_color, accent, muted, description)
values (
  'my-theme',
  '我的主题',
  '#1a1a2e',
  '#e0e0e0',
  '#00d4ff',
  '#888888',
  '自定义深色主题'
);

-- 例3：新增一个元素变体（日期元素）
insert into style_elements_options (value, label, element, description)
values ('date-minimal', '极简日期', 'date', '只显示月日的极简样式');

-- 例4：新增一个装饰选项
insert into style_deco_options (value, label, description)
values ('snow', '飘雪', '背景飘雪动画');

-- 例5：新增一个动效选项
insert into style_effect_options (value, label, description)
values ('glow-pulse', '发光脉冲', '标题发光脉冲动画');
```

### 4.2 修改选项（UPDATE）

```sql
-- 修改色板的配色
update style_palette_options
set bg = '#2a2a3e', accent = '#ff6b6b'
where value = 'my-theme';

-- 修改选项的显示名
update style_layout_options
set label = '日期居中（新）'
where value = 'date-centered';
```

### 4.3 删除选项（DELETE）

```sql
-- 删除某个布局选项（谨慎！已引用此 value 的胶囊样式会失效）
delete from style_layout_options
where value = 'date-left-v2';
```

> ⚠️ **警告**：删除选项前，请确认没有 `STYLE_POOL` 表中的胶囊正在使用该选项（即 `style_json` 中的对应字段等于被删除的 `value`）。建议先查询：
> ```sql
> select name, style_json->'layout'->>'top' from STYLE_POOL
> where style_json->'layout'->>'top' = 'date-left-v2';
> ```

### 4.4 查询当前所有选项

```sql
-- 查看所有色板
select value, label, bg, text_color, accent, muted
from style_palette_options
order by value;

-- 查看某个区域（如 top）的所有布局选项
select value, label, description
from style_layout_options
where col = 'top'
order by value;

-- 查看某个元素（如 date）的所有变体
select value, label, description
from style_elements_options
where element = 'date'
order by value;
```

---

## 五、前端动态加载逻辑说明

前端页面加载时，会执行以下流程：

```
init()
  ├─ checkAuth()           → 认证 Supabase
  ├─ injectCardEngineCss() → 注入卡片渲染 CSS
  ├─ loadDimensionOptions() → 从 7 张表读取所有选项，存入 dimensionCache
  ├─ applyDimensionOptionsToUI() → 将 dimensionCache 填充到各下拉框
  ├─ refreshPaletteGrid()  → 刷新色板网格（同时从 DB 和 PALETTES 常量加载）
  ├─ 填充预设下拉框
  └─ loadPool()            → 加载胶囊列表
```

**`dimensionCache` 结构**：
```js
{
  style_layout_options:   [{ value, label, col, description }, ...],
  style_palette_options:  [{ value, label, bg, text_color, accent, muted, description }, ...],
  style_typo_options:    [{ value, label, description }, ...],
  style_border_options:   [{ value, label, description }, ...],
  style_elements_options: [{ value, label, element, description }, ...],
  style_deco_options:     [{ value, label, description }, ...],
  style_effect_options:   [{ value, label, description }, ...],
}
```

---

## 六、常见问题诊断

### 问题 1：「新增」按钮点击无效果

**可能原因 1**：页面通过 `file://` 协议打开，模块脚本因 CORS 限制无法加载。

**排查**：打开浏览器开发者工具（F12）→ Console 标签页，查看是否有以下报错：
```
Failed to load module script: ... cross-origin requests are not supported
```

**解决**：通过 HTTP 服务器访问页面，例如：
```bash
cd web/
python3 -m http.server 8080
# 然后访问 http://localhost:8080/capsule-preview.html
```

---

**可能原因 2**：JS 模块加载失败（如 `style-engine.js` 缺少导出）。

**排查**：打开浏览器开发者工具 → Console 标签页，查看是否有以下报错：
```
TypeError: Failed to resolve module specifier './style-engine.js'
The requested module './style-engine.js' does not provide an export named 'registerPalette'
```

**解决**：确认 `style-engine.js` 中存在以下导出：
```js
export function registerPalette(name, colors) { ... }
export function injectCardEngineCss() { ... }
```

---

**可能原因 3**：Supabase 认证失败，导致 `init()` 中的后续代码未执行（但事件绑定在 `init()` 之前，应该不受影响）。

**排查**：打开浏览器开发者工具 → Console 标签页，输入：
```js
document.querySelectorAll('.btn-add-opt').length
```
如果返回 `0`，说明按钮元素不存在（HTML 未正确加载）。如果返回 `7`，说明按钮存在，再检查事件绑定：
```js
// 点击第一个新增按钮，看是否有反应
document.querySelectorAll('.btn-add-opt')[0].click();
```

---

### 问题 2：新增选项后下拉框未刷新

**原因**：`saveNewOption()` 在保存成功后会调用 `loadDimensionOptions()` 重新从 DB 加载，然后调用 `applyDimensionOptionsToUI()` 刷新下拉框。如果这个过程有报错，下拉框不会刷新。

**排查**：打开浏览器开发者工具 → Console 标签页，新增选项时查看是否有红色错误。

---

### 问题 3：新增色板后色板网格未更新

**原因**：`refreshPaletteGrid()` 需要从 DB 重新加载。保存成功后应自动调用此函数。

**手动刷新**：打开浏览器开发者工具 → Console 标签页，输入：
```js
refreshPaletteGrid();
```

---

## 七、文件清单

| 文件 | 作用 |
|------|------|
| `web/style_dimension_options.sql` | 建表 + 种子数据 |
| `web/capsule-preview.html` | 可视化 style_json 编辑器（含新增按钮逻辑） |
| `web/style-engine.js` | 卡片渲染引擎（含 `registerPalette()` / `injectCardEngineCss()`） |
| `web/script.js` | Supabase 客户端初始化 |
| `web/TABLES_GUIDE.md` | 本文档 |
