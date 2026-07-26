-- ============================================================
-- 字段级双轴对齐：h_align（水平）/ v_align（垂直）重构
-- ------------------------------------------------------------
-- 背景：旧 alignment_mode(text-align) / cross_alignment_mode(margin-block:auto)
--       均为「书写模式相关」属性，挂在容器/卡片根上后，横排竖排语义翻转，
--       全竖排时整卡 writing-mode 翻转还把网格转置成窄列 → 三个维度在混排/全竖排下失控。
-- 新方案（引擎 20260727a）：
--   · writing-mode 只挂文字元素 .card-XXX.is-vertical，容器/网格保持 horizontal-tb；
--   · 对齐坐标系固定为物理「水平/垂直」，横排竖排含义一致；
--   · h_align / v_align 用「物理 margin」实现，且 h_align 额外对水平文字补 text-align(:not(.is-vertical))，
--     使「水平对齐」在横排(文字内对齐)与竖排(窄框水平移动)下都直观有效。
-- 选择器：data-attr 由引擎按 perElement 发射为 data-style-typo-h-align-<field> / -v-align-<field>（挂在 .gallery-card 根）。
--   落点：.fx-wrap[data-fx="<field>"]（字段包裹层，flex item）+ .card-<field>:not(.is-vertical)（仅水平文字）。
-- ============================================================

-- ---------- h_align：字段水平对齐 ----------
INSERT INTO style_typo_options (sub_dim, value, label, description, gradient, css_template, sort_order) VALUES
('h_align', 'start', '靠左 start',
 '字段水平靠左：竖排=窄框左移 / 横排=文字左对齐',
 '{"date":"inherit","title":"inherit","capsule":"inherit","highlights":"inherit"}',
 '.gallery-card[data-style-typo-h-align-title="start"] .fx-wrap[data-fx="title"]{margin-left:0;margin-right:auto}
.gallery-card[data-style-typo-h-align-title="start"] .card-title:not(.is-vertical){text-align:left}
.gallery-card[data-style-typo-h-align-date="start"] .fx-wrap[data-fx="date"]{margin-left:0;margin-right:auto}
.gallery-card[data-style-typo-h-align-date="start"] .card-date:not(.is-vertical){text-align:left}
.gallery-card[data-style-typo-h-align-capsule="start"] .fx-wrap[data-fx="capsule"]{margin-left:0;margin-right:auto}
.gallery-card[data-style-typo-h-align-capsule="start"] .card-capsule:not(.is-vertical){text-align:left}
.gallery-card[data-style-typo-h-align-highlights="start"] .fx-wrap[data-fx="highlights"]{margin-left:0;margin-right:auto}
.gallery-card[data-style-typo-h-align-highlights="start"] .card-highlights:not(.is-vertical){text-align:left}', 211),
('h_align', 'center', '居中 center',
 '字段水平居中：竖排=窄框水平居中 / 横排=文字水平居中',
 '{"date":"inherit","title":"inherit","capsule":"inherit","highlights":"inherit"}',
 '.gallery-card[data-style-typo-h-align-title="center"] .fx-wrap[data-fx="title"]{margin-left:auto;margin-right:auto}
.gallery-card[data-style-typo-h-align-title="center"] .card-title:not(.is-vertical){text-align:center}
.gallery-card[data-style-typo-h-align-date="center"] .fx-wrap[data-fx="date"]{margin-left:auto;margin-right:auto}
.gallery-card[data-style-typo-h-align-date="center"] .card-date:not(.is-vertical){text-align:center}
.gallery-card[data-style-typo-h-align-capsule="center"] .fx-wrap[data-fx="capsule"]{margin-left:auto;margin-right:auto}
.gallery-card[data-style-typo-h-align-capsule="center"] .card-capsule:not(.is-vertical){text-align:center}
.gallery-card[data-style-typo-h-align-highlights="center"] .fx-wrap[data-fx="highlights"]{margin-left:auto;margin-right:auto}
.gallery-card[data-style-typo-h-align-highlights="center"] .card-highlights:not(.is-vertical){text-align:center}', 212),
('h_align', 'end', '靠右 end',
 '字段水平靠右：竖排=窄框右移 / 横排=文字右对齐',
 '{"date":"inherit","title":"inherit","capsule":"inherit","highlights":"inherit"}',
 '.gallery-card[data-style-typo-h-align-title="end"] .fx-wrap[data-fx="title"]{margin-left:auto;margin-right:0}
.gallery-card[data-style-typo-h-align-title="end"] .card-title:not(.is-vertical){text-align:right}
.gallery-card[data-style-typo-h-align-date="end"] .fx-wrap[data-fx="date"]{margin-left:auto;margin-right:0}
.gallery-card[data-style-typo-h-align-date="end"] .card-date:not(.is-vertical){text-align:right}
.gallery-card[data-style-typo-h-align-capsule="end"] .fx-wrap[data-fx="capsule"]{margin-left:auto;margin-right:0}
.gallery-card[data-style-typo-h-align-capsule="end"] .card-capsule:not(.is-vertical){text-align:right}
.gallery-card[data-style-typo-h-align-highlights="end"] .fx-wrap[data-fx="highlights"]{margin-left:auto;margin-right:0}
.gallery-card[data-style-typo-h-align-highlights="end"] .card-highlights:not(.is-vertical){text-align:right}', 213);

-- ---------- v_align：字段垂直对齐 ----------
INSERT INTO style_typo_options (sub_dim, value, label, description, gradient, css_template, sort_order) VALUES
('v_align', 'start', '靠上 start',
 '字段垂直靠上（物理 margin-top/bottom:auto，横竖排通用）',
 '{"date":"inherit","title":"inherit","capsule":"inherit","highlights":"inherit"}',
 '.gallery-card[data-style-typo-v-align-title="start"] .fx-wrap[data-fx="title"]{margin-top:0;margin-bottom:auto}
.gallery-card[data-style-typo-v-align-date="start"] .fx-wrap[data-fx="date"]{margin-top:0;margin-bottom:auto}
.gallery-card[data-style-typo-v-align-capsule="start"] .fx-wrap[data-fx="capsule"]{margin-top:0;margin-bottom:auto}
.gallery-card[data-style-typo-v-align-highlights="start"] .fx-wrap[data-fx="highlights"]{margin-top:0;margin-bottom:auto}', 221),
('v_align', 'center', '居中 center',
 '字段垂直居中（物理 margin-top/bottom:auto，横竖排通用）',
 '{"date":"inherit","title":"inherit","capsule":"inherit","highlights":"inherit"}',
 '.gallery-card[data-style-typo-v-align-title="center"] .fx-wrap[data-fx="title"]{margin-top:auto;margin-bottom:auto}
.gallery-card[data-style-typo-v-align-date="center"] .fx-wrap[data-fx="date"]{margin-top:auto;margin-bottom:auto}
.gallery-card[data-style-typo-v-align-capsule="center"] .fx-wrap[data-fx="capsule"]{margin-top:auto;margin-bottom:auto}
.gallery-card[data-style-typo-v-align-highlights="center"] .fx-wrap[data-fx="highlights"]{margin-top:auto;margin-bottom:auto}', 222),
('v_align', 'end', '靠下 end',
 '字段垂直靠下（物理 margin-top/bottom:auto，横竖排通用）',
 '{"date":"inherit","title":"inherit","capsule":"inherit","highlights":"inherit"}',
 '.gallery-card[data-style-typo-v-align-title="end"] .fx-wrap[data-fx="title"]{margin-top:auto;margin-bottom:0}
.gallery-card[data-style-typo-v-align-date="end"] .fx-wrap[data-fx="date"]{margin-top:auto;margin-bottom:0}
.gallery-card[data-style-typo-v-align-capsule="end"] .fx-wrap[data-fx="capsule"]{margin-top:auto;margin-bottom:0}
.gallery-card[data-style-typo-v-align-highlights="end"] .fx-wrap[data-fx="highlights"]{margin-top:auto;margin-bottom:0}', 223);

-- ============================================================
-- 可选清理：删除已废弃的 alignment_mode / cross_alignment_mode 行
-- （引擎 20260727a 不再发射对应 data-attr，其 css_template 已成死代码；
--   不影响现有卡片渲染，仅清理维度表。如不确定可跳过本段。）
-- ============================================================
-- DELETE FROM style_typo_options WHERE sub_dim IN ('alignment_mode','cross_alignment_mode');
