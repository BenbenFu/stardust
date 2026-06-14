# style_json 分层拆解参考

将现有 18 种卡片的视觉特征逐层拆解，提炼各层的可选值域，为 `style_json` schema 提供数据依据。

---

## 一、各层定义

| 层 | 控制什么 | 子维度 |
|---|---|---|
| **layout** (排版) | DOM 骨架、元素结构 | top / body / bottom / side / overlay |
| **palette** (配色) | 四色系统 | bg / text / accent / muted |
| **typo** (字体) | 字体族、标题风格 | family / title_size / title_deco |
| **border** (边框) | 边框、圆角、阴影 | style / radius / shadow |
| **deco** (装饰) | 图案、分隔符、伪元素标签 | bg_pattern / separator / pseudo_label |
| **effect** (效果) | 动画、滤镜、变换 | animation / filter / transform |

---

## 二、18 种卡片逐卡拆解

### 1. default (标准工业屏)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | standard |
| layout.bottom | style_tag |
| layout.side | none |
| layout.overlay | none |
| palette.bg | transparent (rgba(0,0,0,0.03)) |
| palette.text | var(--pixel-dark) #1e2622 |
| palette.accent | var(--pixel-dark) #1e2622 |
| palette.muted | var(--pixel-dim) #707a65 |
| typo.family | mono |
| typo.title_size | 13 |
| typo.title_deco | border_bottom |
| border.style | 2px solid var(--pixel-dark) |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "*  *  *" |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 2. repair (维修便签)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | standard |
| layout.bottom | style_tag (absolute top-left) |
| layout.side | none |
| layout.overlay | tape_top + stamp_bottom |
| palette.bg | var(--repair-tape) #d2c89f |
| palette.text | #403d30 |
| palette.accent | #615a42 |
| palette.muted | #837b5a |
| typo.family | cursive |
| typo.title_size | 14 |
| typo.title_deco | underline |
| border.style | default (inherited from base, color override #615a42) |
| border.radius | 0 |
| border.shadow | soft (2px 2px 8px rgba(0,0,0,0.2)) |
| deco.bg_pattern | tape_stripe (::before 斜条纹) |
| deco.separator | "- - - - -" |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | rotate(1deg) |

### 3. print (针式打印)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | standard |
| layout.bottom | tag_bar (card-footer-h) |
| layout.side | holes (left + right perforation) |
| layout.overlay | none |
| palette.bg | #e5ebda |
| palette.text | var(--pixel-dark) #1e2622 |
| palette.accent | #8a8f7c |
| palette.muted | #8a8f7c |
| typo.family | mono |
| typo.title_size | 12 |
| typo.title_deco | uppercase + center + letter_spacing |
| border.style | none |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | perf_line (::before 顶部断线) |
| deco.separator | "· · · · ·" |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 4. overheat (过热终端)

| 层 | 值 |
|---|---|
| layout.top | status_bar (blinking WARNING) |
| layout.body | standard |
| layout.bottom | style_tag |
| layout.side | none |
| layout.overlay | scanline_full (::after 全卡扫描线) |
| palette.bg | #1e2669 |
| palette.text | var(--gba-bg) #cadbb7 |
| palette.accent | #4a5d8f |
| palette.muted | #7f86ba |
| typo.family | mono |
| typo.title_size | 13 |
| typo.title_deco | none (animated scanline jitter) |
| border.style | base border + outline 1px #4a5d8f |
| border.radius | 0 |
| border.shadow | inset (0 0 10px rgba(0,0,0,0.5)) |
| deco.bg_pattern | scanline (::after horizontal lines) |
| deco.separator | "" (border-top line instead) |
| deco.pseudo_label | none |
| effect.animation | blink (status_bar) + scanline_jitter (title) |
| effect.filter | none |
| effect.transform | none |

### 5. tamagotchi (电子宠物)

| 层 | 值 |
|---|---|
| layout.top | label ("TAMAGOTCHI" top-center) |
| layout.body | ascii_zone (title + date + ascii_art + highlights) |
| layout.bottom | style_tag |
| layout.side | none |
| layout.overlay | none |
| palette.bg | transparent |
| palette.text | var(--pixel-dark) #1e2622 |
| palette.accent | var(--pixel-dark) #1e2622 |
| palette.muted | var(--pixel-dim) #707a65 |
| typo.family | monospace |
| typo.title_size | 11 |
| typo.title_deco | center + bg_highlight (rgba(0,0,0,0.05)) |
| border.style | 4px solid var(--pixel-dark) |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "+ + + + +" |
| deco.pseudo_label | "TAMAGOTCHI" (top-center) |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 6. api-debt (欠费警告)

| 层 | 值 |
|---|---|
| layout.top | warning_bar (red API DEBT bar) |
| layout.body | standard |
| layout.bottom | style_tag |
| layout.side | none |
| layout.overlay | stamp (rotated [!] API_DEBT, blinking) |
| palette.bg | transparent |
| palette.text | var(--pixel-alert) #8f341d |
| palette.accent | var(--pixel-alert) #8f341d |
| palette.muted | var(--pixel-alert) #8f341d |
| typo.family | mono |
| typo.title_size | 13 |
| typo.title_deco | center |
| border.style | base border, color var(--pixel-alert) |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "! ! ! ! !" |
| deco.pseudo_label | none |
| effect.animation | blink (api-seal) |
| effect.filter | none |
| effect.transform | none |

### 7. panic (故障日志)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | standard |
| layout.bottom | style_tag |
| layout.side | none |
| layout.overlay | dump (inverted hex dump at bottom) |
| palette.bg | #0b0c0a |
| palette.text | var(--pixel-dim) #707a65 |
| palette.accent | var(--pixel-dark) #1e2622 |
| palette.muted | #43473b |
| typo.family | mono |
| typo.title_size | 13 |
| typo.title_deco | mirror (scaleX(-1) + letter-spacing) |
| border.style | 1px solid var(--pixel-dark) |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "0x0 0x0" |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | scaleX(-1) (title), scaleY(-1) (dump) |

### 8. code-forge (代码编程)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | code_area (line_numbers + function/title prefix) |
| layout.bottom | style_tag (with "// STYLE: " prefix) |
| layout.side | line_numbers (1-12 numbered gutter) |
| layout.overlay | none |
| palette.bg | #0f1419 |
| palette.text | #cadbb7 |
| palette.accent | #3a7d44 |
| palette.muted | #858585 |
| typo.family | consolas_mono |
| typo.title_size | 13 |
| typo.title_deco | function_prefix ("function " + "() {") |
| border.style | border-left 6px solid #3a7d44 |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "/* ---- */" |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 9. tech-archive (技术文档)

| 层 | 值 |
|---|---|
| layout.top | doc_header (RFC-ID / STARDUST-SPEC) |
| layout.body | standard |
| layout.bottom | tag_bar (card-footer-h) |
| layout.side | none |
| layout.overlay | seal ("APPROVED" top-right) |
| palette.bg | #f0f2eb |
| palette.text | #1e2622 |
| palette.accent | #8a8f7c |
| palette.muted | #5a6352 |
| typo.family | mono |
| typo.title_size | 13 |
| typo.title_deco | uppercase + center |
| border.style | 1px solid #8a8f7c |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "" (none) |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 10. work-bench (工作办公)

| 层 | 值 |
|---|---|
| layout.top | email_header (from + date) |
| layout.body | standard |
| layout.bottom | style_tag (with top border) |
| layout.side | none |
| layout.overlay | none |
| palette.bg | #ffffff |
| palette.text | #2d333b |
| palette.accent | #d1d9e0 |
| palette.muted | #656d76 |
| typo.family | mono |
| typo.title_size | 13 |
| typo.title_deco | none |
| border.style | 1px solid #d1d9e0 |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "" (none) |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 11. life-logbook (生活记录)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | sticky_note (title as floating note) |
| layout.bottom | style_tag (absolute bottom-right, blue tape) |
| layout.side | none |
| layout.overlay | none |
| palette.bg | #faf7e8 |
| palette.text | #4a453d |
| palette.accent | #c9c2b0 |
| palette.muted | #9a9385 |
| typo.family | cursive (date only) |
| typo.title_size | 13 |
| typo.title_deco | sticky_note (bg #ffefb3 + shadow + rotate) |
| border.style | 2px dotted #c9c2b0 |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "~ ~ ~ ~ ~" |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | rotate(-0.5deg) |

### 12. social-broadcast (社交网络)

| 层 | 值 |
|---|---|
| layout.top | user_bar (avatar + name + handle) |
| layout.body | standard |
| layout.bottom | style_tag |
| layout.side | none |
| layout.overlay | none |
| palette.bg | #ffffff |
| palette.text | #14171a |
| palette.accent | #e6ecf0 |
| palette.muted | #657786 |
| typo.family | mono |
| typo.title_size | 13 |
| typo.title_deco | none |
| border.style | 1px solid #e6ecf0 |
| border.radius | 8 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "·  ·  ·" |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 13. creative-engine (创意写作)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | standard |
| layout.bottom | style_tag (absolute bottom-left, italic) |
| layout.side | none |
| layout.overlay | none |
| palette.bg | #fffef5 |
| palette.text | #2c2c2c |
| palette.accent | #e0d9c8 |
| palette.muted | #8a8273 |
| typo.family | serif |
| typo.title_size | 14 |
| typo.title_deco | wavy_underline (color #8f341d) |
| border.style | 2px solid #e0d9c8 |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | lines (horizontal ruled lines) |
| deco.separator | "" (none) |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 14. media-stream (媒体通稿)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | standard |
| layout.bottom | tag_bar (card-footer-h) |
| layout.side | none |
| layout.overlay | none |
| palette.bg | #ffffff |
| palette.text | #000000 |
| palette.accent | #cccccc |
| palette.muted | #999999 |
| typo.family | mono |
| typo.title_size | 15 |
| typo.title_deco | center + bold_border_bottom |
| border.style | 1px solid #cccccc |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "" (none) |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 15. role-engine (角色扮演)

| 层 | 值 |
|---|---|
| layout.top | role_panel (avatar + name + date + stat bar + inject label) |
| layout.body | standard (title with left border, no date) |
| layout.bottom | none |
| layout.side | none |
| layout.overlay | none |
| palette.bg | #f5f0e6 |
| palette.text | #3d3529 |
| palette.accent | #8b7355 |
| palette.muted | #6b5a45 |
| typo.family | mono |
| typo.title_size | 12 |
| typo.title_deco | left_border (3px solid #8b7355) |
| border.style | 3px double #8b7355 |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "" (none) |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 16. fiction-realm (小说叙事)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | standard |
| layout.bottom | tag_bar (card-footer-h) |
| layout.side | none |
| layout.overlay | none |
| palette.bg | #f8f5f0 |
| palette.text | #2a2520 |
| palette.accent | #d4ccc4 |
| palette.muted | #9a928a |
| typo.family | serif |
| typo.title_size | 16 |
| typo.title_deco | center + border_bottom + serif |
| border.style | none |
| border.radius | 0 |
| border.shadow | soft (0 2px 5px rgba(0,0,0,0.1)) |
| deco.bg_pattern | none |
| deco.separator | "* * *" |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 17. format-deck (格式规范)

| 层 | 值 |
|---|---|
| layout.top | dark_bar (inverted title bar spanning full width) |
| layout.body | standard |
| layout.bottom | tag_bar (card-footer-h) |
| layout.side | none |
| layout.overlay | none |
| palette.bg | #ffffff |
| palette.text | #1e2622 |
| palette.accent | #1e2622 |
| palette.muted | #707a65 |
| typo.family | mono |
| typo.title_size | 13 |
| typo.title_deco | inverted_bar (dark bg, light text, full-width) |
| border.style | 2px solid #1e2622 |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | grid (cross-hatch 20px) |
| deco.separator | "" (none) |
| deco.pseudo_label | none |
| effect.animation | none |
| effect.filter | none |
| effect.transform | none |

### 18. misc-mystery (未知分类)

| 层 | 值 |
|---|---|
| layout.top | none |
| layout.body | standard |
| layout.bottom | style_tag (absolute bottom-left, 0.5 opacity) |
| layout.side | none |
| layout.overlay | censored (title 40% black block) + question_mark (bottom-right "?") |
| palette.bg | #2a2a2a |
| palette.text | #9a9a9a |
| palette.accent | #555555 |
| palette.muted | #666666 |
| typo.family | mono |
| typo.title_size | 13 |
| typo.title_deco | none |
| border.style | 1px dashed #555555 |
| border.radius | 0 |
| border.shadow | none |
| deco.bg_pattern | none |
| deco.separator | "? ? ? ? ?" |
| deco.pseudo_label | "?" (bottom-right, large, faded) |
| effect.animation | none |
| effect.filter | blur(0.3px) |
| effect.transform | none |

---

## 三、各层选项归纳

### layout.top (顶部区域)

| 选项 | 使用者 | 说明 |
|---|---|---|
| none | default, repair, print, panic, life-logbook, creative-engine, fiction-realm, media-stream, misc-mystery | 无特殊顶部组件 |
| label | tamagotchi | 居中标签文字 |
| status_bar | overheat | 闪烁状态条 |
| warning_bar | api-debt | 静态警告条 |
| doc_header | tech-archive | 文档头(RFC号 + 规范名) |
| email_header | work-bench | 邮件头(发件人 + 日期) |
| user_bar | social-broadcast | 社交用户栏(头像 + 用户名 + handle) |
| dark_bar | format-deck | 反色标题条(深底浅字) |
| role_panel | role-engine | 角色面板(头像 + 名字 + 日期 + 进度条 + 注入标签) |

### layout.body (主体区域)

| 选项 | 使用者 | 说明 |
|---|---|---|
| standard | 大部分 | title → date → highlights |
| code_area | code-forge | 行号栏 + function前缀 + //注释前缀 |
| ascii_zone | tamagotchi | ASCII 字符画区域 |
| role_panel | role-engine | 已在 top 中处理，body 为 standard + left_border_title |
| sticky_note | life-logbook | 标题浮出为便利贴样式 |

### layout.bottom (底部区域)

| 选项 | 使用者 | 说明 |
|---|---|---|
| style_tag | default, repair, overheat, api-debt, panic, code-forge, work-bench, social-broadcast, life-logbook, creative-engine, tamagotchi, misc-mystery | .card-style 标签 |
| tag_bar | print, tech-archive, media-stream, fiction-realm, format-deck | .card-footer-h 分栏 |
| none | role-engine | 隐藏/无底部标签 |

### layout.side (侧边区域)

| 选项 | 使用者 | 说明 |
|---|---|---|
| none | 大部分 | 无侧边元素 |
| line_numbers | code-forge | 左侧行号栏(1-12) |
| holes | print | 左右两侧齿孔 |

### layout.overlay (覆盖层)

| 选项 | 使用者 | 说明 |
|---|---|---|
| none | 大部分 | 无覆盖层 |
| seal | tech-archive | "APPROVED" 印章(边框+文字) |
| stamp | api-debt | 旋转 + 闪烁的 "[!] API_DEBT" |
| tape | repair | 顶部斜纹胶带 + 底部圆形印 |
| scanline | overheat | 全卡扫描线 + 标题抖动 |
| dump | panic | 底部反转 hex dump |
| censored | misc-mystery | 标题 40% 遮挡 + 底部大号 "?" |

### palette (配色)

现有 14 组独立色板：

| 色板名 | bg | text | accent | muted | 使用者 |
|---|---|---|---|---|---|
| industrial | transparent/#1e2622 | #1e2622 | #1e2622 | #707a65 | default |
| repair_yellow | #d2c89f | #403d30 | #615a42 | #837b5a | repair |
| printer_green | #e5ebda | #1e2622 | #8a8f7c | #8a8f7c | print |
| bsod_blue | #1e2669 | #cadbb7 | #4a5d8f | #7f86ba | overheat |
| alert_red | transparent | #8f341d | #8f341d | #8f341d | api-debt |
| terminal_black | #0b0c0a | #707a65 | #1e2622 | #43473b | panic |
| vscode_dark | #0f1419 | #cadbb7 | #3a7d44 | #858585 | code-forge |
| archive_khaki | #f0f2eb | #1e2622 | #8a8f7c | #5a6352 | tech-archive |
| github_light | #ffffff | #2d333b | #d1d9e0 | #656d76 | work-bench |
| diary_cream | #faf7e8 | #4a453d | #c9c2b0 | #9a9385 | life-logbook |
| twitter_light | #ffffff | #14171a | #e6ecf0 | #657786 | social-broadcast |
| notebook_white | #fffef5 | #2c2c2c | #e0d9c8 | #8a8273 | creative-engine |
| newspaper | #ffffff | #000000 | #cccccc | #999999 | media-stream |
| role_parchment | #f5f0e6 | #3d3529 | #8b7355 | #6b5a45 | role-engine |
| novel_warm | #f8f5f0 | #2a2520 | #d4ccc4 | #9a928a | fiction-realm |
| blueprint | #ffffff | #1e2622 | #1e2622 | #707a65 | format-deck |
| mystery_dark | #2a2a2a | #9a9a9a | #555555 | #666666 | misc-mystery |

注：tamagotchi 使用系统默认色(var(--pixel-dark)等)，与 default 相同，归入 industrial 色板。

### typo.family (字体族)

| 选项 | 使用者 |
|---|---|
| mono | default, overheat, api-debt, panic, code-forge, tech-archive, work-bench, social-broadcast, media-stream, role-engine, format-deck, misc-mystery |
| consolas_mono | code-forge (指定 Consolas/Monaco) |
| serif | creative-engine, fiction-realm |
| cursive | repair, life-logbook(日期) |

### typo.title_deco (标题装饰)

| 选项 | 使用者 | 说明 |
|---|---|---|
| none | work-bench, social-broadcast, misc-mystery | 无装饰 |
| border_bottom | default | 底部边框 |
| underline | repair | 下划线 |
| wavy_underline | creative-engine | 波浪下划线 |
| uppercase + center | print, tech-archive | 大写居中 |
| center + border_bottom | fiction-realm, media-stream | 居中 + 底线 |
| center + bg_highlight | tamagotchi | 居中 + 背景高亮 |
| function_prefix | code-forge | "function " + "() {" 包裹 |
| inverted_bar | format-deck | 反色条 |
| left_border | role-engine | 左侧彩色竖线 |
| mirror | panic | scaleX(-1) 反转 |
| sticky_note | life-logbook | 浮出便利贴(背景色+阴影+旋转) |

### border.style (边框样式)

| 选项 | 使用者 |
|---|---|
| 2px solid | default, life-logbook, format-deck |
| 1px solid | panic, tech-archive, work-bench, media-stream, social-broadcast |
| 3px solid (base) | tamagotchi |
| none | print |
| default_color_override | repair, api-debt |
| border-left_accent | code-forge (6px solid #3a7d44) |
| 3px double | role-engine |
| 2px dotted | life-logbook |
| 1px dashed | misc-mystery |
| none + shadow | fiction-realm |

### border.radius (圆角)

| 选项 | 使用者 |
|---|---|
| 0 | 17 种 |
| 8px | social-broadcast |

### border.shadow (阴影)

| 选项 | 使用者 |
|---|---|
| none | 大部分 |
| soft | repair (2px 2px 8px) |
| inset | overheat (0 0 10px) |
| soft_small | fiction-realm (0 2px 5px) |

### deco.bg_pattern (背景图案)

| 选项 | 使用者 | 说明 |
|---|---|---|
| none | 大部分 | 无图案 |
| tape_stripe | repair | ::before 斜纹胶带 |
| perf_line | print | ::before 顶部断线 |
| scanline | overheat | ::after 水平扫描线 |
| lines | creative-engine | 横线纸(line-height 对齐) |
| grid | format-deck | 交叉网格(20px) |

### deco.separator (句间分隔符)

| 选项 | 值 |
|---|---|
| asterisk | "*  *  *" |
| dash | "- - - - -" |
| dots | "· · · · ·" |
| dots_sparse | "·  ·  ·" |
| plus | "+ + + + +" |
| bang | "! ! ! ! !" |
| hex | "0x0 0x0" |
| code_comment | "/* ---- */" |
| tilde | "~ ~ ~ ~ ~" |
| triple_star | "* * *" |
| question | "? ? ? ? ?" |
| none | "" |

### deco.pseudo_label (伪元素标签)

| 选项 | 使用者 | 内容 |
|---|---|---|
| none | 大部分 | 无 |
| tamagotchi | tamagotchi | "TAMAGOTCHI" |
| question_mark | misc-mystery | "?" (大号、右下角) |

### effect.animation (动画)

| 选项 | 使用者 | 说明 |
|---|---|---|
| none | 大部分 | 无动画 |
| blink | overheat(status_bar), api-debt(seal) | 闪烁 |
| scanline_jitter | overheat(title) | 扫描线抖动 |

### effect.filter (滤镜)

| 选项 | 使用者 | 说明 |
|---|---|---|
| none | 大部分 | 无滤镜 |
| blur | misc-mystery | blur(0.3px) |

### effect.transform (变换)

| 选项 | 使用者 | 说明 |
|---|---|---|
| none | 大部分 | 无变换 |
| slight_tilt | repair (1deg), life-logbook (-0.5deg) | 轻微倾斜 |
| mirror | panic (scaleX(-1) title, scaleY(-1) dump) | 镜像反转 |

---

## 四、层间依赖分析

### 强依赖（组合受限）

| 约束 | 原因 |
|---|---|
| layout.top = role_panel → layout.bottom = none | 角色面板已包含完整信息，底部标签冗余 |
| layout.side = line_numbers → layout.body = code_area | 行号只有代码区才需要 |
| layout.side = holes → layout.bottom = tag_bar | 打印纸底部需分栏日期 |
| layout.overlay = scanline → effect.animation = blink | 扫描线必然伴随闪烁 |

### 弱依赖（推荐搭配）

| 约束 | 原因 |
|---|---|
| palette = vscode_dark → typo.family = consolas_mono | 深色代码主题用等宽字体更合理 |
| palette = industrial → border.style = 2px solid | 工业屏标配实线边框 |
| layout.top = dark_bar → typo.title_deco = inverted_bar | 反色条头部与反色标题是一体设计 |

### 无依赖（完全自由组合）

- palette × deco.separator — 色板和分隔符文字无关
- palette × deco.bg_pattern — 色板和背景图案无关(但图案颜色可能受 muted 影响)
- typo.family × layout.top — 字体和顶部组件无关
- border.radius × deco.separator — 圆角和分隔符无关
- effect.transform × palette — 变换和色板无关

---

## 五、组合计数

| 层 | 选项数 |
|---|---|
| layout.top | 9 |
| layout.body | 5 |
| layout.bottom | 3 |
| layout.side | 3 |
| layout.overlay | 7 |
| palette | 17 |
| typo.family | 4 |
| typo.title_deco | 12 |
| border.style | 9 |
| border.radius | 2 |
| border.shadow | 4 |
| deco.bg_pattern | 6 |
| deco.separator | 12 |
| deco.pseudo_label | 3 |
| effect.animation | 3 |
| effect.filter | 2 |
| effect.transform | 3 |

理论组合：9×5×3×3×7 × 17 × 4×12 × 9×2×4 × 6×12×3 × 3×2×3 = 天文数字

但受强依赖约束，实际有效组合远小于理论值。这正是层式设计的优势——不需要遍历所有组合，只需按约束筛选合法组合即可。

---

## 六、与现有 18 种的回填验证

| 卡片 | layout.top | layout.body | layout.bottom | layout.side | layout.overlay | palette |
|---|---|---|---|---|---|---|
| default | none | standard | style_tag | none | none | industrial |
| repair | none | standard | style_tag | none | tape | repair_yellow |
| print | none | standard | tag_bar | holes | none | printer_green |
| overheat | status_bar | standard | style_tag | none | scanline | bsod_blue |
| tamagotchi | label | ascii_zone | style_tag | none | none | industrial |
| api-debt | warning_bar | standard | style_tag | none | stamp | alert_red |
| panic | none | standard | style_tag | none | dump | terminal_black |
| code-forge | none | code_area | style_tag | line_numbers | none | vscode_dark |
| tech-archive | doc_header | standard | tag_bar | none | seal | archive_khaki |
| work-bench | email_header | standard | style_tag | none | none | github_light |
| life-logbook | none | sticky_note | style_tag | none | none | diary_cream |
| social-broadcast | user_bar | standard | style_tag | none | none | twitter_light |
| creative-engine | none | standard | style_tag | none | none | notebook_white |
| media-stream | none | standard | tag_bar | none | none | newspaper |
| role-engine | role_panel | standard | none | none | none | role_parchment |
| fiction-realm | none | standard | tag_bar | none | none | novel_warm |
| format-deck | dark_bar | standard | tag_bar | none | none | blueprint |
| misc-mystery | none | standard | style_tag | none | censored | mystery_dark |

| 卡片 | typo.family | typo.title_deco | border.style | border.radius | border.shadow |
|---|---|---|---|---|---|
| default | mono | border_bottom | 2px solid | 0 | none |
| repair | cursive | underline | color_override | 0 | soft |
| print | mono | uppercase_center | none | 0 | none |
| overheat | mono | none | solid+outline | 0 | inset |
| tamagotchi | mono | center_bg_highlight | 4px solid | 0 | none |
| api-debt | mono | center | color_override | 0 | none |
| panic | mono | mirror | 1px solid | 0 | none |
| code-forge | consolas | function_prefix | left_accent | 0 | none |
| tech-archive | mono | uppercase_center | 1px solid | 0 | none |
| work-bench | mono | none | 1px solid | 0 | none |
| life-logbook | cursive | sticky_note | 2px dotted | 0 | none |
| social-broadcast | mono | none | 1px solid | 8 | none |
| creative-engine | serif | wavy_underline | 2px solid | 0 | none |
| media-stream | mono | center_border_bottom | 1px solid | 0 | none |
| role-engine | mono | left_border | 3px double | 0 | none |
| fiction-realm | serif | center_border_bottom | none | 0 | soft |
| format-deck | mono | inverted_bar | 2px solid | 0 | none |
| misc-mystery | mono | none | 1px dashed | 0 | none |

| 卡片 | deco.bg_pattern | deco.separator | deco.pseudo_label | effect.animation | effect.filter | effect.transform |
|---|---|---|---|---|---|---|
| default | none | asterisk | none | none | none | none |
| repair | tape_stripe | dash | none | none | none | slight_tilt |
| print | perf_line | dots | none | none | none | none |
| overheat | scanline | none | none | blink | none | none |
| tamagotchi | none | plus | TAMAGOTCHI | none | none | none |
| api-debt | none | bang | none | blink | none | none |
| panic | none | hex | none | none | none | mirror |
| code-forge | none | code_comment | none | none | none | none |
| tech-archive | none | none | none | none | none | none |
| work-bench | none | none | none | none | none | none |
| life-logbook | none | tilde | none | none | none | slight_tilt |
| social-broadcast | none | dots_sparse | none | none | none | none |
| creative-engine | lines | none | none | none | none | none |
| media-stream | none | none | none | none | none | none |
| role-engine | none | none | none | none | none | none |
| fiction-realm | none | triple_star | none | none | none | none |
| format-deck | grid | none | none | none | none | none |
| misc-mystery | none | question | question_mark | none | blur | none |

---

全部 18 种卡片均可无遗漏地回填到这套分层 schema 中，验证完毕。
