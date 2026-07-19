# 容器组问题 Handoff（新对话启动用）

> 本文件用于在「新对话」中快速恢复上下文，避免携带超长历史对话。
> 最后更新：2026-07-17。配套长期记忆见 `.workbuddy/memory/MEMORY.md`。

---

## 1. 项目一句话背景

ESP32-S3 电子墨水屏日记项目（esp-claw / 星屑）的**卡片样式渲染系统**：完全数据驱动，DB 九张维度表（`field_registry / container_group / effect / layout / border / palette / typo / deco / element`）的 `css_template`（data-attr 选择器）决定样式，前端 `style-engine.js` 解析 `style_json` 生成卡片 HTML。用户是嵌入式固件开发者，对 UI 细节极敏感、偏好非破坏性调整。

## 2. 已完成进度（截至 2026-07-17）

| 维度 | 状态 | 备注 |
|---|---|---|
| layout / palette / typo / border / effect / element | 已落地 | 数据驱动渲染正常 |
| Deco Box（多盒嵌套包裹层） | **已闭环并验证** | 统一圆角 `box_radius` + per-box 重合 `coincide` + 盒间距 `box_gap`，用户 07-17 确认「全部生效」 |
| Effect 滤镜分层 | 已落地 | `.fx-wrap` 承载 `backdrop-filter`，self/backdrop 双 attr 并存 |
| 容器组 container_group | **未实现（下一个重点）** | 见第 3 节 |

- **当前版本串**：`?v=20260716f`（三入口 + 二级引用 `gallery-cards.js` 全部统一）。
- **Deco Box SQL** 已执行并归档至 `web/_deprecated/style_deco_box_multilayer_20260715.sql`。

## 3. 容器组问题定义（核心待办）

**目标**：让一张卡片能套用「容器组(container_group)」——一组预置的结构化装饰/布局组合，覆盖在内容之上或作为内容容器。

**当前架构位置**：
- DB 九维表已含 `container_group` 表。
- 编辑器「容器」标签页目前仅做 `container_group` **单选 + 结构预览**，引擎渲染链路尚未真正把 container_group 套用到卡片。

**两个已知障碍（用户 07-15 明确延后，至今未动）**：
1. **覆盖内容区导致内容不可见**：选择容器组后它会覆盖卡片内容区，原卡片内容（date/title/highlights/capsule）无法正常显示。
2. **无法组装多个容器组**：当前模型只支持单选一个容器组，用户需要「给一张卡片叠多个容器组」的能力未实现。

## 4. 与 Deco Box 的关系（重要，避免重复造轮子）

Deco Box 已实现「对字段/内容的**嵌套包裹层**」机制：
- 字段盒：`字段外 .fx-wrap[data-fx=字段]` 内，按 `deco.boxes` 数组顺序(外→内)嵌套 N 个 `.fx-wrap[data-style-deco-box=风格]`。
- 全局盒 `target='global'`：嵌套包裹**整个卡片内容**（含顶栏+主体），`.fx-wrap.gx-global`。
- DB 用通用选择器 `[data-style-deco-box="<value>"]`，同时匹配嵌套 `.fx-wrap`、`.fx-wrap.gx-global`、以及容器组 slot 上由 `parseSlotDeco` 生成的同款 attr。
- **教训**：Deco Box 初版用绝对定位 `.deco-box` 空层 → 塌缩不可见 + padding 贴边忽远忽近，已废弃改为嵌套包裹层。容器组应复用这套 `.fx-wrap` 机制，不要另起绝对定位层。

## 5. 关键文件

- `web/style-engine.js` — 核心渲染引擎（`renderStyleJson` / `buildCardHtml` / `parseSlotDeco` / `wrapField`）。
- `web/capsule-preview.html` — style_json 可视化编辑器（含「容器」标签页，?v=20260716f）。
- `web/gallery.html` + `web/gallery-cards.js` — 卡片瀑布流（?v=20260716f）。
- `web/_deprecated/` — 所有已执行 SQL 归档（含 box 多盒层化 SQL）。
- `web/过程文件（废弃）/` — 早期 Agent 文档与脚本（`AGENT_CSS_TO_SQL.md` / `AGENT_NEW_CARD_DESIGN.md` 等），历史参考。

## 6. 用户偏好与协作约定

- 先咨询后修改，非破坏性；代码精简；**排斥 emoji**；偏好中文、结构化、编号列举。
- 偏好逐维度独立设计样式参数，反感多维度混合。
- git 回退用 `git revert`，**拒绝 `git reset --hard`**。
- **缓存陷阱**：改 `style-engine.js` 后必须同步 bump 所有入口（含二级 `gallery-cards.js` 引用）的 `?v=`。
- agent 无 DB UPDATE 权限，SQL 修正只能产出 `.sql` 由用户在 Supabase 手动执行，执行后归档 `_deprecated`。

## 7. 建议的新对话切入点

1. 先与用户**明确「容器组」产品语义**：是①**内容容器**（把卡片内容放进去，类似全局 box 但可选多个）还是②**装饰覆盖层**（叠在内容上方）？——这决定架构走向。
2. 据此决定：扩展现有 `deco.boxes` 模型（复用 `.fx-wrap` 包裹层）还是新建 `container_groups` 列表字段。
3. 针对障碍 1（覆盖内容）：参考全局 box 的 `.fx-wrap.gx-global` 包裹层做法，让容器组「包裹内容」而非「覆盖内容」。
4. 针对障碍 2（多容器组）：参考 `deco.boxes` 的扁平有序列表模型，支持多个容器组按序嵌套。
5. **务必先出方案再写代码**，让用户确认思路后再动手。
