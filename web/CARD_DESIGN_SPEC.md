# Gallery Card CSS 设计规范

## 唯一红线

你的 CSS 会被注入到以下 HTML 结构中，**DOM 不可变**：

```html
<a class="gallery-card" data-cs="扭蛋名" href="diary.html?date=日期" target="_blank">
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

**必须遵守：**

1. **不改 DOM** — 不能加/删元素，不能改 HTML 属性，不能改标签类型
2. **不破坏瀑布流** — 不要设 `position: fixed`/`absolute`（`relative` 可以），不要动 `break-inside`
3. **不写 `[data-cs="xxx"]` 前缀** — 系统自动注入作用域，你写的每个选择器都会自动隔离
4. **文字背景不要脱离卡片背景单独存在** — 基类默认透明，LCD 薄荷绿底色（`#cadbb7`）会透出。如果给 `.card-highlight-item` 设了白色/粉色等背景，但 `.gallery-card` 透明，绿底与文字背景撞色会很刺眼。要么同时设卡片背景，要么让文字背景色调与绿底协调。
5. **不使用 emoji** — `content` 中用纯文本符号或 CSS 几何图形替代。
6. **贴合主题，不要打安全牌** — 卡片应该让人一眼认出"这是什么"。从扭蛋主题的媒介特质出发，而不是从"好看的颜色"出发。不是"漂亮的卡片"，是"从某个媒介里撕下来的一页"。

## 参考示例

以下是三条已渲染在 gallery 的卡片 CSS。这些使用了系统类型自带的额外 DOM（`.social-avatar` 等），`card_css` 只有 6 个基础选择器，但思路和技巧通用。

**代码编辑器（code-forge）** — 行号 + 语法高亮 + function 包裹

```css
background-color: #0f1419; color: #cadbb7;
border-left: 6px solid #3a7d44;
font-family: "Consolas", "Monaco", monospace;
padding-left: 40px;
}
.card-date { font-size: 10px; color: #6a9955; font-style: italic; }
.card-date::before { content: "// "; }
.card-title { font-size: 13px; color: #7ab8ff; }
.card-title::before { content: "function "; color: #569cd6; }
.card-title::after { content: "() {"; color: #d4d4d4; }
.card-style { font-size: 9px; color: #858585; text-align: right; }
.card-style::before { content: "// STYLE: "; }
::before {
  content: "1\A 2\A 3\A 4\A 5\A 6\A 7\A 8\A 9\A 10";
  position: absolute; left: 5px; top: 10px;
  font-size: 10px; color: #3a4036; line-height: 1.5;
  text-align: right; width: 25px; pointer-events: none;
  border-right: 1px solid #2a3027; padding-right: 5px;
}
```

**手账本（life-logbook）** — 胶带标题 + 旋转贴纸

```css
background-color: #faf7e8; color: #4a453d;
border: 2px dotted #c9c2b0;
transform: rotate(-0.5deg); padding: 15px;
}
.card-title {
  background-color: #ffefb3; padding: 2px 8px;
  margin: -20px auto 15px auto; width: fit-content;
  font-size: 13px; transform: rotate(-2deg);
  box-shadow: 2px 2px 3px rgba(0,0,0,0.1);
}
.card-date { font-size: 10px; color: #9a9385; font-family: cursive; text-align: right; }
.card-style {
  position: absolute; bottom: 10px; right: 10px;
  width: 40px; height: 20px; background-color: #bae1ff;
  font-size: 8px; text-align: center; line-height: 20px; transform: rotate(3deg);
}
```

**机密档案（misc-mystery）** — 黑条遮挡 + 模糊 + 问号

```css
background-color: #2a2a2a; color: #9a9a9a;
border: 1px dashed #555555;
filter: blur(0.3px);
}
.card-title { font-size: 13px; position: relative; }
.card-title::after {
  content: ""; position: absolute; top: 0; right: 0;
  width: 40%; height: 100%; background-color: #000000;
}
.card-date { font-size: 9px; color: #666666; filter: blur(1px); text-align: right; }
.card-style { position: absolute; bottom: 5px; left: 10px; font-size: 8px; color: #444; opacity: 0.5; }
::after { content: "?"; position: absolute; bottom: 5px; right: 10px; font-size: 24px; color: #444; opacity: 0.5; pointer-events: none; }
```

## 可用选择器一览

| 选择器 | 对应内容 |
|---|---|
| `.gallery-card` | 卡片容器 |
| `.card-title` | 日记标题 |
| `.card-date` | 日期字符串 |
| `.card-highlight-item` | 每条精华句 |
| `.hl-sep` | 句间分隔符 |
| `.card-no-highlight` | 无精华时的占位文本 |
| `.card-style` | 扭蛋名标签 |

所有选择器都可用 `::before` / `::after` / `:first-child` / `:last-child` / `:nth-child(n)` / `:first-letter` 等标准伪元素和伪类。

## 尺寸参考

卡片在瀑布流中占据 250~400px 宽度（2~3 列），文字不宜过大。建议范围：

| 元素 | 建议字号 | 超出观测 |
|---|---|---|
| `.card-title` | 12~16px | >16px 标题撑满整行，视觉压迫 |
| `.card-highlight-item` | 11~14px | >14px 正文像标题，卡片过高 |
| `.card-date` | 9~11px | 元数据宜小 |
| `.hl-sep` | 8~10px | 分隔符不宜抢眼 |
| `.card-style` | 8~10px | 标签宜小巧 |
| `.card-no-highlight` | 10~12px | 占位文本 |

非红线，只是参考——如果你的设计恰好需要打破这些值（比如竖排书法、极简留白），完全可以。

## 默认样式（可全部覆盖）

`.gallery-card` 基类自带：

```css
display: flex; flex-direction: column;
border: 3px solid var(--pixel-dark);
padding: 10px;
background: transparent;
color: var(--pixel-dark);
```

`.card-highlight-item::before` 默认 `content: "> "`，如需自定义前缀必须显式覆盖 `content`。

其余子元素无预设样式。

## 可用 CSS 变量

`--gba-bg` / `--pixel-dark` / `--pixel-dim` / `--pixel-alert` / `--repair-tape`

## 填入方式

Supabase → `STYLE_POOL` 表 → `card_css` 列（TEXT 类型），粘贴完整 CSS。为 NULL 时自动使用系统默认的 18 种通用风格。
