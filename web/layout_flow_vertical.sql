-- layout_flow_vertical.sql
-- 日期: 2026-07-03
-- 描述: layout 维度 flow 子维度 css_template 改为 CSS 变量模式 + 新增 flow_vertical 子维度
-- 前置条件: style-engine.js 已更新（BASE_CSS 支持 --wm-* 变量, ATTR_MAP 支持 isArray）

-- ============================================================
-- 步骤 2: 更新 flow 行 css_template 为 --wm-* 变量模式
-- 旧: 直接设 writing-mode
-- 新: 设 --wm-* CSS 变量，由 BASE_CSS 映射到元素
-- ============================================================

-- horizontal: 全横排
UPDATE style_layout_options
SET css_template = '[data-style-layout-flow="horizontal"]{--wm-date:horizontal-tb;--wm-title:horizontal-tb;--wm-highlights:horizontal-tb;--wm-capsule:horizontal-tb;}'
WHERE sub_dim = 'flow' AND value = 'horizontal';

-- vertical: 全竖排（纯竖排，不污染）
UPDATE style_layout_options
SET css_template = '[data-style-layout-flow="vertical"]{--wm-date:vertical-rl;--wm-title:vertical-rl;--wm-highlights:vertical-rl;--wm-capsule:vertical-rl;}'
WHERE sub_dim = 'flow' AND value = 'vertical';

-- mixed: 默认全横排，由 flow_vertical 子维度决定哪些字段翻转为竖排
UPDATE style_layout_options
SET css_template = '[data-style-layout-flow="mixed"]{--wm-date:horizontal-tb;--wm-title:horizontal-tb;--wm-highlights:horizontal-tb;--wm-capsule:horizontal-tb;}'
WHERE sub_dim = 'flow' AND value = 'mixed';

-- ============================================================
-- 步骤 3: 新增 flow_vertical 子维度（4 行）
-- 每行对应一个字段的竖排开关，仅当 flow=mixed 时生效
-- data 属性: data-style-layout-flow-vertical-{field}
-- CSS 规则: 覆盖 --wm-{field} 为 vertical-rl
-- ============================================================

INSERT INTO style_layout_options (option_key, value, label, sub_dim, css_template, description, sort_order, is_enabled)
VALUES
  ('date',       'date',       'Date 竖排',
   'flow_vertical',
   '[data-style-layout-flow-vertical-date]{--wm-date:vertical-rl;}',
   'mixed 流向下将日期设为竖排书写', 410, true),

  ('title',      'title',      'Title 竖排',
   'flow_vertical',
   '[data-style-layout-flow-vertical-title]{--wm-title:vertical-rl;}',
   'mixed 流向下将标题设为竖排书写', 420, true),

  ('highlights', 'highlights', 'Highlights 竖排',
   'flow_vertical',
   '[data-style-layout-flow-vertical-highlights]{--wm-highlights:vertical-rl;}',
   'mixed 流向下将精华句设为竖排书写', 430, true),

  ('capsule',    'capsule',    'Capsule 竖排',
   'flow_vertical',
   '[data-style-layout-flow-vertical-capsule]{--wm-capsule:vertical-rl;}',
   'mixed 流向下将胶囊标签设为竖排书写', 440, true);

-- ============================================================
-- 步骤 7 (建议): grid 模板微调
-- 以下为建议修改，需根据实际 css_template 内容调整
-- ============================================================

-- 7a. timeline 布局: date 列太窄导致日期溢出
-- 建议: 将 grid-template-columns 中 date 列的最小宽度增大
-- 示例 (需替换为实际值):
-- UPDATE style_layout_options
-- SET css_template = REPLACE(css_template, '60px', '80px')
-- WHERE sub_dim = 'grid' AND value = 'timeline';

-- 7b. 双栏右宽/等宽: capsule 占太多空间
-- 建议: 调整 grid-template-columns 比例，给 capsule 列更窄的宽度
-- 示例 (需替换为实际值):
-- UPDATE style_layout_options
-- SET css_template = REPLACE(css_template, '1fr 1fr', '2fr 1fr')
-- WHERE sub_dim = 'grid' AND value = 'dual_equal';

-- 注意: 步骤 7 需要在预览页实际查看效果后微调，以上仅为方向建议
