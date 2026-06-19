-- ============================================================
-- style_dimension_options.sql
-- 维度选项数据化：将 capsule-preview.html 中的硬编码选项迁入 DB
-- 执行后需改造 capsule-preview.html 为动态加载
-- ============================================================

-- ===== 1. LAYOUT 维度（5 个子维度）=====
CREATE TABLE IF NOT EXISTS style_layout_options (
    id          SERIAL PRIMARY KEY,
    sub_dim     TEXT NOT NULL,       -- top / body / bottom / side / overlay
    value       TEXT NOT NULL,       -- 选项值
    label       TEXT NOT NULL,       -- 显示名（中文）
    description TEXT,                -- 说明
    sort_order  INT DEFAULT 0,      -- 排序用
    created_at  TIMESTAMP DEFAULT NOW(),
    UNIQUE(sub_dim, value)
);

-- layout.top
INSERT INTO style_layout_options (sub_dim, value, label, description, sort_order) VALUES
('top', 'none',          '无',           '无特殊顶部组件', 1),
('top', 'label',         '悬浮标签',     '居中标签文字（TAMAGOTCHI）', 2),
('top', 'status_bar',    '警告状态栏',   '闪烁状态条（OVERHEAT）', 3),
('top', 'warning_bar',   '警告横条',     '静态警告条（API-DEBT）', 4),
('top', 'doc_header',    '文档头',       'RFC号 + 规范名（TECH-ARCHIVE）', 5),
('top', 'email_header',  '邮件头',       '发件人 + 日期（WORK-BENCH）', 6),
('top', 'user_bar',      '用户栏',       '头像 + 用户名 + handle（SOCIAL-BROADCAST）', 7),
('top', 'dark_bar',      '反色标题条',   '深底浅字全宽条（FORMAT-DECK）', 8),
('top', 'role_panel',    '角色面板',     '头像 + 名字 + 日期 + 进度条（ROLE-ENGINE）', 9);

-- layout.body
INSERT INTO style_layout_options (sub_dim, value, label, description, sort_order) VALUES
('body', 'standard',     '标准',         'title → date → highlights', 1),
('body', 'code_area',    '代码区',       '行号栏 + function前缀 + 注释前缀', 2),
('body', 'ascii_zone',   'ASCII 宠物',   'ASCII 字符画区域（TAMAGOTCHI）', 3),
('body', 'sticky_note',  '便签',         '标题浮出为便利贴样式', 4);

-- layout.bottom
INSERT INTO style_layout_options (sub_dim, value, label, description, sort_order) VALUES
('bottom', 'style_tag', '样式标签',     '.card-style 标签', 1),
('bottom', 'tag_bar',   '标签横条',     '.card-footer-h 分栏', 2),
('bottom', 'none',      '无',           '隐藏/无底部标签', 3);

-- layout.side
INSERT INTO style_layout_options (sub_dim, value, label, description, sort_order) VALUES
('side', 'none',         '无',           '无侧边元素', 1),
('side', 'line_numbers', '行号',         '左侧行号栏 1-12（CODE-FORGE）', 2),
('side', 'holes',        '活页孔',       '左右两侧齿孔（PRINT）', 3);

-- layout.overlay
INSERT INTO style_layout_options (sub_dim, value, label, description, sort_order) VALUES
('overlay', 'none',       '无',           '无覆盖层', 1),
('overlay', 'seal',       '批准印章',     'APPROVED 印章（TECH-ARCHIVE）', 2),
('overlay', 'stamp',      'API_DEBT 戳', '旋转 + 闪烁 [!]（API-DEBT）', 3),
('overlay', 'tape',       '胶带条纹',     '顶部斜纹胶带 + 底部圆形印（REPAIR）', 4),
('overlay', 'scanline',   '扫描线',       '全卡扫描线 + 标题抖动（OVERHEAT）', 5),
('overlay', 'dump',       'Kernel Dump',  '底部反转 hex dump（PANIC）', 6),
('overlay', 'censored',   '打码遮挡',    '标题 40% 遮挡 + 底部 "?"（MISC-MYSTERY）', 7);


-- ===== 2. PALETTE 维度（色板预设）=====
CREATE TABLE IF NOT EXISTS style_palette_options (
    id           SERIAL PRIMARY KEY,
    value        TEXT UNIQUE NOT NULL,  -- 色板名（也是 style_json.palette 的值）
    label        TEXT NOT NULL,         -- 显示名
    bg           TEXT NOT NULL,         -- 背景色
    text_color   TEXT NOT NULL,         -- 主文字色
    accent       TEXT NOT NULL,         -- 强调色
    muted        TEXT NOT NULL,         -- 次要文字色
    description  TEXT,
    sort_order   INT DEFAULT 0,
    created_at   TIMESTAMP DEFAULT NOW()
);

INSERT INTO style_palette_options (value, label, bg, text_color, accent, muted, description, sort_order) VALUES
('industrial',       '工业屏',       'transparent',      '#1e2622', '#1e2622', '#707a65', '默认工业风（DEFAULT/TAMAGOTCHI）', 1),
('repair_yellow',    '维修便签',     '#d2c89f',         '#403d30',  '#615a42',  '#837b5a',  '黄色胶带风格（REPAIR）', 2),
('printer_green',    '针式打印',     '#e5ebda',         '#1e2622', '#8a8f7c',  '#8a8f7c',  '绿色打印纸（PRINT）', 3),
('bsod_blue',        '过热终端',     '#1e2669',         '#cadbb7', '#4a5d8f',  '#7f86ba',  '蓝屏风格（OVERHEAT）', 4),
('alert_red',         '欠费警告',     'transparent',      '#8f341d', '#8f341d',  '#8f341d',  '红色警报（API-DEBT）', 5),
('terminal_black',    '故障日志',     '#0b0c0a',        '#707a65', '#1e2622',  '#43473b',  '黑色终端（PANIC）', 6),
('vscode_dark',       '代码编程',     '#0f1419',        '#cadbb7', '#3a7d44',  '#858585',  'VSCode 暗色（CODE-FORGE）', 7),
('archive_khaki',     '技术文档',     '#f0f2eb',        '#1e2622', '#8a8f7c',  '#5a6352',  '归档卡其（TECH-ARCHIVE）', 8),
('github_light',       '工作办公',     '#ffffff',         '#2d333b', '#d1d9e0',  '#656d76',  'GitHub 浅色（WORK-BENCH）', 9),
('diary_cream',       '生活记录',     '#faf7e8',        '#4a453d', '#c9c2b0',  '#9a9385',  '奶油便签（LIFE-LOGBOOK）', 10),
('twitter_light',      '社交网络',     '#ffffff',         '#14171a', '#e6ecf0',  '#657786',  'Twitter 浅色（SOCIAL-BROADCAST）', 11),
('notebook_white',     '创意写作',     '#fffef5',        '#2c2c2c', '#e0d9c8',  '#8a8273',  '笔记本白（CREATIVE-ENGINE）', 12),
('newspaper',         '媒体通稿',     '#ffffff',         '#000000', '#cccccc',  '#999999',  '报纸（MEDIA-STREAM）', 13),
('role_parchment',    '角色扮演',     '#f5f0e6',        '#3d3529', '#8b7355',  '#6b5a45',  '羊皮纸（ROLE-ENGINE）', 14),
('novel_warm',        '小说叙事',     '#f8f5f0',        '#2a2520', '#d4ccc4',  '#9a928a',  '小说暖色（FICTION-REALM）', 15),
('blueprint',          '格式规范',     '#ffffff',         '#1e2622', '#1e2622',  '#707a65',  '蓝图白（FORMAT-DECK）', 16),
('mystery_dark',      '未知分类',     '#2a2a2a',        '#9a9a9a', '#555555',  '#666666',  '神秘暗色（MISC-MYSTERY）', 17);


-- ===== 3. TYPO 维度（3 个子维度）=====
CREATE TABLE IF NOT EXISTS style_typo_options (
    id          SERIAL PRIMARY KEY,
    sub_dim     TEXT NOT NULL,       -- family / title_size / title_deco
    value       TEXT NOT NULL,
    label       TEXT NOT NULL,
    description TEXT,
    sort_order  INT DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    UNIQUE(sub_dim, value)
);

-- typo.family
INSERT INTO style_typo_options (sub_dim, value, label, description, sort_order) VALUES
('family', 'mono',        '等宽',     'Courier New / monospace', 1),
('family', 'consolas',    'Consolas',  'Consolas / Monaco 代码字体', 2),
('family', 'serif',       '衬线',     'Georgia / serif 文学字体', 3),
('family', 'cursive',     '手写',     '手写风格（REPAIR/LIFE-LOGBOOK 日期）', 4);

-- typo.title_size（保留，但前端仍可用自由输入覆盖）
INSERT INTO style_typo_options (sub_dim, value, label, description, sort_order) VALUES
('title_size', '11', '11px', '小标题', 1),
('title_size', '12', '12px', '标准小', 2),
('title_size', '13', '13px', '标准（默认）', 3),
('title_size', '14', '14px', '中等', 4),
('title_size', '15', '15px', '大', 5),
('title_size', '16', '16px', '特大（小说）', 6),
('title_size', '18', '18px', '超大', 7);

-- typo.title_deco
INSERT INTO style_typo_options (sub_dim, value, label, description, sort_order) VALUES
('title_deco', 'none',             '无',           '无装饰', 1),
('title_deco', 'border_bottom',    '底边线',       '标题底部边框', 2),
('title_deco', 'underline',        '下划线',       '文本下划线（REPAIR）', 3),
('title_deco', 'wavy_underline',   '波浪下划线',   '波浪形下划线（CREATIVE-ENGINE）', 4),
('title_deco', 'uppercase_center', '大写居中',     '全大写 + 居中（PRINT/TECH-ARCHIVE）', 5),
('title_deco', 'center_border_bottom', '居中+底线', '居中 + 底部边框（FICTION-REALM/MEDIA-STREAM）', 6),
('title_deco', 'center_bg_highlight', '居中高亮',   '居中 + 背景高亮（TAMAGOTCHI）', 7),
('title_deco', 'function_prefix',  '函数前缀',     '"function " + "() {" 包裹（CODE-FORGE）', 8),
('title_deco', 'inverted_bar',    '反色条',       '反色标题条（FORMAT-DECK）', 9),
('title_deco', 'left_border',      '左侧色条',     '左侧彩色竖线（ROLE-ENGINE）', 10),
('title_deco', 'mirror',           '镜像',         'scaleX(-1) 反转（PANIC）', 11),
('title_deco', 'sticky_note',      '便签',         '浮出便利贴（LIFE-LOGBOOK）', 12);


-- ===== 4. BORDER 维度（3 个子维度）=====
CREATE TABLE IF NOT EXISTS style_border_options (
    id          SERIAL PRIMARY KEY,
    sub_dim     TEXT NOT NULL,       -- style / radius / shadow
    value       TEXT NOT NULL,
    label       TEXT NOT NULL,
    description TEXT,
    sort_order  INT DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    UNIQUE(sub_dim, value)
);

-- border.style
INSERT INTO style_border_options (sub_dim, value, label, description, sort_order) VALUES
('style', 'solid',         '标准实线 2px',   '2px solid（DEFAULT/LIFE-LOGBOOK/FORMAT-DECK）', 1),
('style', 'none',          '无边框',           '无边框（PRINT/FICTION-REALM）', 2),
('style', 'thin_solid',    '细实线 1px',     '1px solid（PANIC/TECH-ARCHIVE/WORK-BENCH/SOCIAL-BROADCAST/MEDIA-STREAM/MISC-MYSTERY）', 3),
('style', 'thick_solid',   '粗实线 3px',     '3px solid（TAMAGOTCHI）', 4),
('style', 'heavy_solid',   '超粗实线 4px',   '4px solid（TAMAGOTCHI）', 5),
('style', 'double',        '双线 3px',        '3px double（ROLE-ENGINE）', 6),
('style', 'dotted',        '点线 2px',        '2px dotted（LIFE-LOGBOOK）', 7),
('style', 'dashed',        '虚线 1px',        '1px dashed（MISC-MYSTERY）', 8),
('style', 'left_accent',   '左侧重点条 6px',  '左侧 6px 实线（CODE-FORGE）', 9),
('style', 'solid_outline', '实线+外轮廓',      '实线边框 + outline（OVERHEAT）', 10);

-- border.radius
INSERT INTO style_border_options (sub_dim, value, label, description, sort_order) VALUES
('radius', '0', '直角 0px',  '无圆角（17种中的16种）', 1),
('radius', '8', '圆角 8px',  '8px 圆角（SOCIAL-BROADCAST）', 2);

-- border.shadow
INSERT INTO style_border_options (sub_dim, value, label, description, sort_order) VALUES
('shadow', 'none',       '无',         '无阴影（大部分）', 1),
('shadow', 'soft',       '柔和',       '2px 2px 8px rgba(0,0,0,0.2)（REPAIR）', 2),
('shadow', 'inset',      '内嵌',       'inset 0 0 10px rgba(0,0,0,0.5)（OVERHEAT）', 3),
('shadow', 'soft_small', '轻微',       '0 2px 5px rgba(0,0,0,0.1)（FICTION-REALM）', 4);


-- ===== 5. DECO 维度（3 个子维度）=====
CREATE TABLE IF NOT EXISTS style_deco_options (
    id          SERIAL PRIMARY KEY,
    sub_dim     TEXT NOT NULL,       -- bg_pattern / separator / pseudo_label
    value       TEXT NOT NULL,
    label       TEXT NOT NULL,
    description TEXT,
    sort_order  INT DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    UNIQUE(sub_dim, value)
);

-- deco.bg_pattern
INSERT INTO style_deco_options (sub_dim, value, label, description, sort_order) VALUES
('bg_pattern', 'none',        '无',         '无背景图案', 1),
('bg_pattern', 'tape_stripe', '胶带斜纹',   '::before 斜条纹胶带（REPAIR）', 2),
('bg_pattern', 'perf_line',   '打孔线',     '::before 顶部断线（PRINT）', 3),
('bg_pattern', 'scanline',    '扫描线',     '::after 水平扫描线（OVERHEAT）', 4),
('bg_pattern', 'lines',       '横线本',     '横线纸 line-height 对齐（CREATIVE-ENGINE）', 5),
('bg_pattern', 'grid',        '方格纸',     '交叉网格 20px（FORMAT-DECK）', 6);

-- deco.separator
INSERT INTO style_deco_options (sub_dim, value, label, description, sort_order) VALUES
('separator', 'none',          '无',           '无分隔符', 1),
('separator', 'asterisk',      '*  *  *',    '星号分隔', 2),
('separator', 'dash',          '- - - -',     '短横分隔', 3),
('separator', 'dots',          '· · · ·',    '中间点', 4),
('separator', 'dots_sparse',   '·  ·  ·',   '稀疏点（SOCIAL-BROADCAST）', 5),
('separator', 'plus',          '+ + + +',      '加号（TAMAGOTCHI）', 6),
('separator', 'bang',          '! ! ! !',     '叹号（API-DEBT）', 7),
('separator', 'hex',           '0x0 0x0',    '十六进制（PANIC）', 8),
('separator', 'code_comment',  '/* ---- */',  '代码注释（CODE-FORGE）', 9),
('separator', 'tilde',         '~ ~ ~ ~',     '波浪号（LIFE-LOGBOOK）', 10),
('separator', 'triple_star',   '* * *',       '三星号（FICTION-REALM）', 11),
('separator', 'question',      '? ? ? ?',    '问号（MISC-MYSTERY）', 12);

-- deco.pseudo_label
INSERT INTO style_deco_options (sub_dim, value, label, description, sort_order) VALUES
('pseudo_label', 'none',          '无',       '无伪标签', 1),
('pseudo_label', 'tamagotchi',   'TAMAGOTCHI', '顶部居中 "TAMAGOTCHI"（TAMAGOTCHI）', 2),
('pseudo_label', 'question_mark', '?',        '右下角大号 "?"（MISC-MYSTERY）', 3);


-- ===== 6. EFFECT 维度（3 个子维度）=====
CREATE TABLE IF NOT EXISTS style_effect_options (
    id          SERIAL PRIMARY KEY,
    sub_dim     TEXT NOT NULL,       -- animation / filter / transform
    value       TEXT NOT NULL,
    label       TEXT NOT NULL,
    description TEXT,
    sort_order  INT DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    UNIQUE(sub_dim, value)
);

-- effect.animation
INSERT INTO style_effect_options (sub_dim, value, label, description, sort_order) VALUES
('animation', 'none',            '无',         '无动画', 1),
('animation', 'blink',           '闪烁',       '状态栏/印章闪烁（OVERHEAT/API-DEBT）', 2),
('animation', 'scanline_jitter', '扫描线抖动', '标题扫描线抖动（OVERHEAT）', 3);

-- effect.filter
INSERT INTO style_effect_options (sub_dim, value, label, description, sort_order) VALUES
('filter', 'none',  '无',     '无滤镜', 1),
('filter', 'blur', '模糊 0.3px', 'blur(0.3px)（MISC-MYSTERY）', 2);

-- effect.transform
INSERT INTO style_effect_options (sub_dim, value, label, description, sort_order) VALUES
('transform', 'none',         '无',         '无变换', 1),
('transform', 'slight_tilt', '轻微倾斜',   'rotate(±0.5~1deg)（REPAIR/LIFE-LOGBOOK）', 2),
('transform', 'mirror',       '镜像反转',   'scaleX(-1)/scaleY(-1)（PANIC）', 3);


-- ===== 7. ELEMENTS 变体（4 个元素，可选数据化）=====
CREATE TABLE IF NOT EXISTS style_elements_options (
    id          SERIAL PRIMARY KEY,
    element     TEXT NOT NULL,       -- date / capsule / title / highlights
    value       TEXT NOT NULL,
    label       TEXT NOT NULL,
    description TEXT,
    sort_order  INT DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    UNIQUE(element, value)
);

INSERT INTO style_elements_options (element, value, label, description, sort_order) VALUES
('date',       'default',     '横排',       '默认横向排列', 1),
('date',       'vertical',    '竖排',       '日期字符竖向排列', 2),
('date',       'stamp',       '印章方块',   '日期呈方形印章样式', 3),
('date',       'big_number',  '大号日期',   '日期数字放大突出', 4),
('date',       'right_align', '右对齐',     '日期靠右显示', 5),
('date',       'hidden',      '隐藏',       '不显示日期', 6),

('capsule',    'default',     '基础',       '默认胶囊标签样式', 1),
('capsule',    'rounded',     '圆角胶囊',   '更圆润的胶囊形状', 2),
('capsule',    'outline',     '镂空描边',   '仅描边无填充', 3),
('capsule',    'underline',   '下划线',     '底部下划线样式', 4),
('capsule',    'bubble',      '气泡框',     '对话气泡样式', 5),
('capsule',    'hidden',      '隐藏',       '不显示胶囊标签', 6),

('title',      'default',       '默认',     '无额外处理', 1),
('title',      'gradient',      '渐变文字', '标题渐变色', 2),
('title',      'strikethrough', '删除线',   '标题加删除线', 3),
('title',      'outline_text',  '描边字',   '文字描边效果', 4),
('title',      'uppercase',     '全大写',   '标题强制全大写', 5),

('highlights', 'default',      '> 前缀',     '每行以 ">" 开头', 1),
('highlights', 'bullet_dot',   '圆点 •',    '每行以 "•" 开头', 2),
('highlights', 'numbered',     '有序编号',   '1. 2. 3. 编号', 3),
('highlights', 'dash_prefix',  '短横 —',    '每行以 "—" 开头', 4),
('highlights', 'no_prefix',   '无前缀',     '无前缀纯文本', 5),
('highlights', 'tag_style',    '标签风格',   '每个高亮句呈标签样式', 6);


-- ============================================================
-- 索引（加速按 sub_dim 查询）
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_layout_sub     ON style_layout_options(sub_dim);
CREATE INDEX IF NOT EXISTS idx_typo_sub       ON style_typo_options(sub_dim);
CREATE INDEX IF NOT EXISTS idx_border_sub     ON style_border_options(sub_dim);
CREATE INDEX IF NOT EXISTS idx_deco_sub       ON style_deco_options(sub_dim);
CREATE INDEX IF NOT EXISTS idx_effect_sub     ON style_effect_options(sub_dim);
CREATE INDEX IF NOT EXISTS idx_elements_elem  ON style_elements_options(element);

-- 完成提示
-- SELECT 'style_dimension_options tables created and seeded' AS result;
