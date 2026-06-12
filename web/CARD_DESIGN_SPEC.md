# Gallery Card CSS 设计规范

## DOM 骨架（不可变）

你的 CSS 会被注入到以下结构，**不能增删任何元素或属性**：

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

## 可用选择器

| 选择器 | 对应元素 |
|---|---|
| `.gallery-card` | 卡片容器（`<a>` 标签） |
| `.card-title` | 日记标题 |
| `.card-date` | 日期字符串 |
| `.card-highlight-item` | 每条精华句（`<p>` 标签） |
| `.hl-sep` | 句间分隔符 |
| `.card-no-highlight` | 无精华时的占位文本 |
| `.card-style` | 扭蛋名标签 |

全部可用 `::before` / `::after` / `:first-child` / `:last-child` / `:nth-child(n)` / `:first-letter` 等标准伪元素和伪类。

## 必须遵守（红线）

1. **不改 DOM** — 不增删元素，不改 HTML 属性，不改标签类型。
2. **`.gallery-card` 容器禁止 `position: fixed` / `absolute`** — 子元素和伪元素可在 `position: relative` 容器内使用 absolute 定位，但不得超出卡片边界改变容器的文档流占位。
3. **禁止修改 `break-inside`** — 此属性控制瀑布流防断裂，改动会导致卡片被列截断。
4. **不写 `[data-cs="xxx"]` 前缀** — 系统自动注入作用域，直接写裸选择器即可。
5. **子元素设非透明背景时，`.gallery-card` 必须同时设实色背景** — 基类默认 `background: transparent`，LCD 薄荷绿底色（`#cadbb7`）会透出。禁止子元素带色块而容器透明（导致撞色）。子元素背景色需与卡片背景色调协调。
6. **全属性禁止 emoji** — `content`、伪元素文本、背景图 base64 等所有 CSS 属性均不得含 emoji 字符。装饰用纯文本符号、CSS 几何图形或渐变实现。
7. **禁止 hover 改变文档流尺寸** — 可用 `transform`、`opacity`、`box-shadow` 做 hover 效果，不可用 `margin`、`padding`、`width`、`height` 突变。

## 设计原则：媒介切片

每张卡片应让人一眼认出"这是什么媒介"。不是"好看的卡片"，是"从某个媒介里撕下来的一页"。

**方法论：** 从扭蛋主题的原生载体出发，还原其排版逻辑和视觉符号。

| 主题 | 媒介参考 |
|---|---|
| 网络用语 | 贴吧/群聊/弹幕/评论区 |
| 代码 | 终端/编辑器/Git diff |
| 剧本 | 舞台脚本/分镜稿 |
| 马尔克斯 | 拉美文学手稿/旧书店 |
| 任意主题 | 找到该主题"原本出现在哪里"，还原那个载体 |

**合格标准：** 遮挡所有文字内容后，仅凭视觉样式即可判断卡片对应的主题品类。

**负面清单（视为不合格）：**
- 仅修改颜色、圆角、字号的通用美化
- 所有主题共用同一结构、仅换色的模板化产出
- 无主题专属装饰、无对应媒介排版逻辑的"安全牌"

## 参考示例（纯基础 DOM，可直接填入 card_css）

**评论区/热评风** — 微博热评，`@博主` 前缀 + 热评等级 + `#话题#`

```css
background: #ffffff;
border: 1px solid #e0e0e0;
border-radius: 6px;
padding: 12px;
font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
}
.card-title { font-size: 13px; color: #333; padding-bottom: 8px; border-bottom: 1px solid #f0f0f0; }
.card-title::before { content: "@热门博主: "; color: #ff8200; font-weight: 600; font-size: 12px; }
.card-date { font-size: 10px; color: #999; align-self: flex-end; }
.card-highlight-item { font-size: 12px; color: #333; padding: 8px 10px; background: #fff8e8; border: 1px solid #ffe0b2; border-radius: 4px; }
.card-highlight-item::before { display: block; font-size: 11px; color: #ff8200; font-weight: 600; margin-bottom: 4px; }
.card-highlight-item:nth-of-type(1)::before { content: "热评第一 · 1.2w赞"; }
.card-highlight-item:nth-of-type(2)::before { content: "热评第二 · 8.6k赞"; }
.card-highlight-item:nth-of-type(3)::before { content: "热评第三 · 5.3k赞"; }
.hl-sep { text-align: center; margin: 2px 0; }
.hl-sep::before { content: "* * *"; font-size: 10px; color: #ccc; letter-spacing: 2px; }
.card-no-highlight { font-size: 11px; color: #bbb; text-align: center; padding: 15px 0; }
.card-no-highlight::before { content: "暂无热门评论"; }
.card-style { font-size: 9px; color: #ff8200; background: #fff1e0; padding: 2px 8px; border-radius: 12px; align-self: flex-start; }
.card-style::before { content: "#"; }
.card-style::after { content: "#"; }
```

**代码编辑器风** — 行号列 + 语法高亮 + `function(){}` 包裹

```css
background: #0f1419;
color: #cadbb7;
border-left: 6px solid #3a7d44;
font-family: "Consolas", "Monaco", monospace;
padding-left: 40px;
}
.card-title { font-size: 13px; color: #7ab8ff; }
.card-title::before { content: "function "; color: #569cd6; }
.card-title::after { content: "() {"; color: #d4d4d4; }
.card-date { font-size: 10px; color: #6a9955; font-style: italic; }
.card-date::before { content: "// "; }
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

## 尺寸参考

卡片在瀑布流中占据 250~400px 宽度（2~3 列）：

| 元素 | 建议字号 | 说明 |
|---|---|---|
| `.card-title` | 12~16px | >16px 标题撑满整行 |
| `.card-highlight-item` | 11~14px | >14px 正文像标题 |
| `.card-date` | 9~11px | 元数据宜小 |
| `.hl-sep` | 8~10px | 分隔符不宜抢眼 |
| `.card-style` | 8~10px | 标签宜小巧 |
| `.card-no-highlight` | 10~12px | 占位文本 |

特殊排版（竖排书法、大字海报、点阵终端）可不受限制，但需保证在 **250px 最小宽度**下内容不溢出、基本可读。

## 基类默认样式

`.gallery-card` 基类已设置以下属性，**可全部覆盖**：

```css
display: flex; flex-direction: column;
box-sizing: border-box;
text-decoration: none;
break-inside: avoid;        /* 禁止修改 */
border: 3px solid var(--pixel-dark);
padding: 10px;
background: transparent;
color: var(--pixel-dark);
transition: transform 0.1s steps(2);
```

`.card-highlight-item::before` 默认 `content: "> "`，需自定义前缀时显式覆盖 `content`。

其余子元素无预设样式。

## 可用 CSS 变量

| 变量名 | 色值 | 用途 |
|---|---|---|
| `--gba-bg` | `#cadbb7` | LCD 薄荷绿页面底色 |
| `--pixel-dark` | `#1e2622` | 主文字色、深色边框 |
| `--pixel-dim` | `#707a65` | 次要文字、弱化分隔线 |
| `--pixel-alert` | `#8f341d` | 工业暗红、强调标识 |
| `--repair-tape` | `#d2c89f` | 黄色便签、复古装饰 |

## 动效约束

- **允许** `transition` 做 hover 过渡，建议 0.2~0.3s
- **允许** `animation` 做弱装饰动画（光标闪烁、扫描线），禁止高频/大幅/循环强动画
- **禁止** hover 改变容器文档流占位尺寸（禁用 `margin`/`padding`/`width`/`height` 突变，用 `transform`/`opacity`/`box-shadow` 替代）

## 填入方式

Supabase → `STYLE_POOL` 表 → `card_css` 列（TEXT 类型），粘贴完整 CSS。`card_css` 为 NULL 时自动使用系统默认的 18 种通用风格。

## 上线自检清单

- [ ] 未修改 DOM 结构、属性、标签类型
- [ ] `.gallery-card` 容器未使用 `fixed` / `absolute` 定位
- [ ] 未修改 `break-inside` 属性
- [ ] 未使用 `[data-cs="xxx"]` 选择器前缀
- [ ] 子元素有非透明背景时，容器已设实色背景
- [ ] 全属性无 emoji 字符
- [ ] hover 未改变容器文档流尺寸
- [ ] 250px 宽度下内容可读不溢出
