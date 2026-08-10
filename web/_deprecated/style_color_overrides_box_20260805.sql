-- ============================================================
-- style_color_overrides_box_20260805.sql
-- 逐元素颜色覆写 Phase 2 —— Deco Box「色槽化」
--
-- 配套引擎版本：style-engine.js ?v=20260805c
-- 前端（capsule-preview.html「[配色]」页 BOX SLOTS 组）已完成：
--   · 按当前卡片已添加的 box_style 动态列出色槽控件（accent/bg/muted/text）
--   · 引擎根级按 box_style 发射 --box-<style>-<role>
--
-- 本 SQL 只做一件事（无需新增元数据列，前端按 css_template 动态识别角色）：
--   把 style_deco_options(sub_dim='box_style') 各 css_template 里硬编码的
--     var(--card-X [, 兜底]) 原地包一层
--         → var(--box-<value>-<role>, var(--card-X [, 兜底]))
--   两级回退：未覆写 → 落回原色板槽 → 落回原兜底色，行为与改造前逐字节一致。
--
-- 非破坏性保证：
--   · regexp_replace(...,'g') 原地改写，不整体覆盖 css_template，
--     不会冲掉其他迁移（geo / deco 多层 / 容器组）的改动。
--   · 每条 UPDATE 带 NOT LIKE 幂等守卫，重复执行不会二次包裹。
--   · 兼容「有兜底 / 无兜底」两种写法：var(--card-X) 与 var(--card-X, #hex) 均包裹。
--
-- 回滚：见文件末尾 [REVERT] 区块（整段注释掉，需要时解开执行）。
-- ============================================================

BEGIN;

-- 通用包裹：一次性改写某 box_style 行的四种色板角色。
-- 用 value 列拼接出该取值专属的变量名（--box-<value>-<role>），天然按取值隔离。
UPDATE style_deco_options
SET css_template = regexp_replace(
  regexp_replace(
    regexp_replace(
      regexp_replace(css_template,
        'var\(\s*--card-accent(\s*,[^)]*)?\)',
        'var(--box-' || value || '-accent, var(--card-accent\1))', 'g'),
      'var\(\s*--card-bg(\s*,[^)]*)?\)',
        'var(--box-' || value || '-bg, var(--card-bg\1))', 'g'),
    'var\(\s*--card-muted(\s*,[^)]*)?\)',
      'var(--box-' || value || '-muted, var(--card-muted\1))', 'g'),
  'var\(\s*--card-text(\s*,[^)]*)?\)',
    'var(--box-' || value || '-text, var(--card-text\1))', 'g')
WHERE sub_dim = 'box_style'
  AND css_template NOT LIKE '%--box-' || value || '-%';

COMMIT;

-- ============================================================
-- 自检：执行后跑这段，应看到每个 box_style 的 css_template 含 --box-<value>-* 包裹层，
--       且包裹后的内容与「原 var(--card-X, 兜底)」逐字节对应（两级回退等价）。
-- ============================================================
-- SELECT value,
--        (length(css_template) - length(replace(css_template, '--box-' || value || '-', ''))) AS box_var_hits,
--        css_template
--   FROM style_deco_options
--  WHERE sub_dim = 'box_style'
--  ORDER BY sort_order;

-- ============================================================
-- [REVERT] 回滚：解开注释整段执行，恢复到本次迁移之前
--   逆向脱掉 --box-<value>-<role> 外层，原样交还内层 var(--card-X [, 兜底])。
-- ============================================================
/*
BEGIN;

UPDATE style_deco_options
SET css_template = regexp_replace(
  regexp_replace(
    regexp_replace(
      regexp_replace(css_template,
        'var\(\-\-box\-' || value || '\-accent,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g'),
      'var\(\-\-box\-' || value || '\-bg,\s*(var\(--card-bg(\s*,[^)]*)?\))\)', '\1', 'g'),
    'var\(\-\-box\-' || value || '\-muted,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g'),
  'var\(\-\-box\-' || value || '\-text,\s*(var\(--card-text(\s*,[^)]*)?\))\)', '\1', 'g')
WHERE sub_dim = 'box_style'
  AND css_template LIKE '%--box-' || value || '-%';

COMMIT;
*/
