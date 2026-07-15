-- ============================================================
-- style_deco_box_multilayer_20260715.sql
-- Deco Box「多盒并存」改造 + Effect 滤镜分层 的 DB 迁移脚本
-- 由 agent 产出，需用户在 Supabase SQL Editor 手动执行（agent 无 DB 写权限）
-- ============================================================
--
-- 本次前端改动（style-engine.js / capsule-preview.html）：
--   1) Deco Box 由「单值 box_style + box_target」改为扁平有序列表
--      deco.boxes = [ { style, target }, ... ]
--      每个盒子渲染为一个独立绝对定位的 .deco-box 层，贴在目标区域内容底下，可任意叠加。
--      - target='global'  → 整卡内容区覆盖层（.deco-box-layer--global）
--      - target=title/date/capsule/highlights → 该字段的 .fx-wrap 内的叠放层
--      因此 css_template 不再需要 per-target 复合选择器，统一改为
--      .deco-box[data-style-deco-box="<value>"] { ... }  通用单层形式。
--
--   2) Effect 滤镜分层：filter_self 与 filter_backdrop 解耦为两个独立 data-attr
--      - self    → data-style-effect-filter-<el>  → 作用在内层字段元素 .card-XXX 的 filter
--      - backdrop → data-style-effect-backdrop-<el> → 作用在外层 .fx-wrap[data-fx=<el>] 的 backdrop-filter
--      （DOM 分层化解浏览器「filter 隔离 backdrop-filter 采样源」的层叠上下文冲突）
--      故 filter_backdrop 的 css_template 必须由 .card-XXX 改指向 .fx-wrap[data-fx="<el>"]。
--      filter_self 的 css_template 无需改动（仍指向 .card-XXX）。
--
-- 说明：下列 UPDATE 用「整行覆盖」精确匹配 sub_dim + value/option_key，
--       不依赖旧 css_template 文本，可安全重复执行（幂等覆盖）。
-- ============================================================


-- ------------------------------------------------------------
-- 0) 执行前校验：看清当前 box_style / filter_backdrop 行
-- ------------------------------------------------------------
SELECT sub_dim, option_key, value, left(css_template, 90) AS css_prev
FROM style_deco_options
WHERE sub_dim = 'box_style'
ORDER BY sort_order;

SELECT sub_dim, option_key, value, left(css_template, 90) AS css_prev
FROM style_effect_options
WHERE sub_dim = 'filter_backdrop'
ORDER BY sort_order;


-- ------------------------------------------------------------
-- 1) 旧 box_style 行改写为通用单层形式（.deco-box[data-style-deco-box="VALUE"]）
--    层 = 绝对定位、inset:0 覆盖目标区域，border/bg/shadow 即「框/面板」视觉效果
-- ------------------------------------------------------------

UPDATE style_deco_options
SET css_template = '.deco-box[data-style-deco-box="rounded"] { border: 1px solid var(--card-accent, #ccc); border-radius: 10px; }'
WHERE sub_dim = 'box_style' AND (value = 'rounded' OR option_key = 'rounded');

UPDATE style_deco_options
SET css_template = '.deco-box[data-style-deco-box="border_box"] { border: 1.5px solid var(--card-accent, #888); border-radius: 8px; }'
WHERE sub_dim = 'box_style' AND (value = 'border_box' OR option_key = 'border_box');

UPDATE style_deco_options
SET css_template = '.deco-box[data-style-deco-box="bg_fill"] { background: var(--card-muted, #e5e5e5); border-radius: 8px; }'
WHERE sub_dim = 'box_style' AND (value = 'bg_fill' OR option_key = 'bg_fill');

UPDATE style_deco_options
SET css_template = '.deco-box[data-style-deco-box="shadow_box"] { background: var(--card-muted, #e5e5e5); box-shadow: 2px 2px 6px rgba(0,0,0,0.15); border-radius: 8px; }'
WHERE sub_dim = 'box_style' AND (value = 'shadow_box' OR option_key = 'shadow_box');


-- ------------------------------------------------------------
-- 2) 新增 box 类型（渐变 / 毛玻璃 / 液态玻璃），可叠加使用
--    统一用调色板变量 var(--card-accent-rgb) / var(--card-bg-rgb)，随主题自适应
--    毛玻璃 / 液态玻璃使用白色调半透明底（深色主题下如需调整，改 css_template 即可）
-- ------------------------------------------------------------

-- 双色线性渐变
INSERT INTO style_deco_options (sub_dim, option_key, value, css_template, sort_order, label)
SELECT 'box_style', 'gradient_linear', 'gradient_linear',
       '.deco-box[data-style-deco-box="gradient_linear"] { background: linear-gradient(135deg, rgba(var(--card-accent-rgb),0.35), rgba(var(--card-bg-rgb),0.05)); border-radius: 10px; }',
       101, '双色线性渐变'
WHERE NOT EXISTS (SELECT 1 FROM style_deco_options WHERE sub_dim = 'box_style' AND value = 'gradient_linear');

-- 三色流光（动画）
INSERT INTO style_deco_options (sub_dim, option_key, value, css_template, sort_order, label)
SELECT 'box_style', 'gradient_flow', 'gradient_flow',
       '@keyframes deco-box-flow { 0% { background-position: 0% 50%; } 100% { background-position: 200% 50%; } }'
       || ' .deco-box[data-style-deco-box="gradient_flow"] { background: linear-gradient(90deg, rgba(var(--card-accent-rgb),0.35), rgba(var(--card-bg-rgb),0.04), rgba(var(--card-accent-rgb),0.35)); background-size: 200% 100%; animation: deco-box-flow 4s linear infinite; border-radius: 10px; }',
       102, '三色流光'
WHERE NOT EXISTS (SELECT 1 FROM style_deco_options WHERE sub_dim = 'box_style' AND value = 'gradient_flow');

-- 径向光晕
INSERT INTO style_deco_options (sub_dim, option_key, value, css_template, sort_order, label)
SELECT 'box_style', 'gradient_radial', 'gradient_radial',
       '.deco-box[data-style-deco-box="gradient_radial"] { background: radial-gradient(circle at 30% 25%, rgba(var(--card-accent-rgb),0.4), transparent 70%); border-radius: 10px; }',
       103, '径向光晕'
WHERE NOT EXISTS (SELECT 1 FROM style_deco_options WHERE sub_dim = 'box_style' AND value = 'gradient_radial');

-- 毛玻璃（backdrop-filter）
INSERT INTO style_deco_options (sub_dim, option_key, value, css_template, sort_order, label)
SELECT 'box_style', 'frosted', 'frosted',
       '.deco-box[data-style-deco-box="frosted"] { backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); background: rgba(255,255,255,0.14); border: 1px solid rgba(255,255,255,0.25); border-radius: 10px; }',
       104, '毛玻璃'
WHERE NOT EXISTS (SELECT 1 FROM style_deco_options WHERE sub_dim = 'box_style' AND value = 'frosted');

-- 液态玻璃（backdrop-filter + 高光描边）
INSERT INTO style_deco_options (sub_dim, option_key, value, css_template, sort_order, label)
SELECT 'box_style', 'liquid_glass', 'liquid_glass',
       '.deco-box[data-style-deco-box="liquid_glass"] { backdrop-filter: blur(10px) saturate(1.4); -webkit-backdrop-filter: blur(10px) saturate(1.4); background: linear-gradient(135deg, rgba(255,255,255,0.22), rgba(255,255,255,0.06)); border: 1px solid rgba(255,255,255,0.35); box-shadow: 0 4px 16px rgba(0,0,0,0.12), inset 0 1px 0 rgba(255,255,255,0.5); border-radius: 12px; }',
       105, '液态玻璃'
WHERE NOT EXISTS (SELECT 1 FROM style_deco_options WHERE sub_dim = 'box_style' AND value = 'liquid_glass');


-- ------------------------------------------------------------
-- 3) filter_backdrop css_template 改指向 .fx-wrap[data-fx="<el>"]
--    每个元素各一条规则（attr 为 per-element：data-style-effect-backdrop-title / -date / -capsule / -highlights）
--    注意：filter_self 的 css_template 不变（仍指向 .card-XXX）
-- ------------------------------------------------------------

-- blur_backdrop
UPDATE style_effect_options
SET css_template =
    '.gallery-card[data-style-effect-backdrop-title="blur_backdrop"] .fx-wrap[data-fx="title"] { backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }'
 || ' .gallery-card[data-style-effect-backdrop-date="blur_backdrop"] .fx-wrap[data-fx="date"] { backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }'
 || ' .gallery-card[data-style-effect-backdrop-capsule="blur_backdrop"] .fx-wrap[data-fx="capsule"] { backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }'
 || ' .gallery-card[data-style-effect-backdrop-highlights="blur_backdrop"] .fx-wrap[data-fx="highlights"] { backdrop-filter: blur(8px); -webkit-backdrop-filter: blur(8px); }'
WHERE sub_dim = 'filter_backdrop' AND (value = 'blur_backdrop' OR option_key = 'blur_backdrop');

-- frosted
UPDATE style_effect_options
SET css_template =
    '.gallery-card[data-style-effect-backdrop-title="frosted"] .fx-wrap[data-fx="title"] { backdrop-filter: blur(8px) saturate(1.3); -webkit-backdrop-filter: blur(8px) saturate(1.3); background: rgba(255,255,255,0.12); }'
 || ' .gallery-card[data-style-effect-backdrop-date="frosted"] .fx-wrap[data-fx="date"] { backdrop-filter: blur(8px) saturate(1.3); -webkit-backdrop-filter: blur(8px) saturate(1.3); background: rgba(255,255,255,0.12); }'
 || ' .gallery-card[data-style-effect-backdrop-capsule="frosted"] .fx-wrap[data-fx="capsule"] { backdrop-filter: blur(8px) saturate(1.3); -webkit-backdrop-filter: blur(8px) saturate(1.3); background: rgba(255,255,255,0.12); }'
 || ' .gallery-card[data-style-effect-backdrop-highlights="frosted"] .fx-wrap[data-fx="highlights"] { backdrop-filter: blur(8px) saturate(1.3); -webkit-backdrop-filter: blur(8px) saturate(1.3); background: rgba(255,255,255,0.12); }'
WHERE sub_dim = 'filter_backdrop' AND (value = 'frosted' OR option_key = 'frosted');

-- 若还有其他 filter_backdrop 值（如 blur_strong 等），请参照上面格式补 UPDATE；
-- 统一模板：
--   .gallery-card[data-style-effect-backdrop-<el>="<value>"] .fx-wrap[data-fx="<el>"] { backdrop-filter: <...>; }


-- ------------------------------------------------------------
-- 4) 旧 box_target 维度已废弃（前端不再使用）
--    下列行可保留（无害）或删除，不影响渲染：
--      SELECT * FROM style_deco_options WHERE sub_dim = 'box_target';
-- ------------------------------------------------------------
-- DELETE FROM style_deco_options WHERE sub_dim = 'box_target';  -- 确认无其它依赖后再执行


-- ------------------------------------------------------------
-- 5) 执行后校验
-- ------------------------------------------------------------
SELECT sub_dim, option_key, value, left(css_template, 90) AS css_prev
FROM style_deco_options
WHERE sub_dim = 'box_style'
ORDER BY sort_order;

SELECT sub_dim, option_key, value, left(css_template, 90) AS css_prev
FROM style_effect_options
WHERE sub_dim = 'filter_backdrop'
ORDER BY sort_order;
