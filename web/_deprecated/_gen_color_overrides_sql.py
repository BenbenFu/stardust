# -*- coding: utf-8 -*-
"""
生成 style_color_overrides_20260805.sql —— 装饰元素色槽化迁移。

策略（stale-proof）：
  不整体重写 css_template（会覆盖掉别处的改动，如 geo 迁移），
  改用 Postgres regexp_replace(...,'g') 做「原地包一层」：
      var(--card-accent, #888)  →  var(--el-float-c1, var(--card-accent, #888))
  两级回退：未覆写 → 落回原色板槽 → 落回原兜底色，与改造前逐字节等价。

色槽分配规则（机械可推导）：
  cN = 模板中第 N 个「首次出现」的不同 --card-* 变量。
  同一变量的多处出现（含不同兜底值）统一归入同一槽，各自保留原兜底。
"""
import json, re, io, os

HERE = os.path.dirname(os.path.abspath(__file__))
rows = json.load(open(os.path.join(HERE, '_live_element_20260805.json'), encoding='utf-8'))

SUBDIM_SHORT = {
    'header_deco': 'header', 'side_accent': 'side', 'divider': 'divider',
    'corner_badge': 'corner', 'bg_pattern': 'bg', 'edge_deco': 'edge',
    'floating_deco': 'float',
}
PAL = ('bg', 'text', 'accent', 'muted')


def distinct_order(t):
    """按首次出现顺序返回模板里用到的 --card-* 变量名列表"""
    out = []
    for m in re.finditer(r'var\(\s*--card-(bg|text|accent|muted)\b', t):
        v = m.group(1)
        if v not in out:
            out.append(v)
    return out


def q(s):
    return "'" + s.replace("'", "''") + "'"


plan = []
for r in rows:
    t = r.get('css_template') or ''
    short = SUBDIM_SHORT.get(r['sub_dim'])
    if not short:
        continue
    order = distinct_order(t)
    plan.append({
        'id': r['id'], 'sub_dim': r['sub_dim'], 'value': r['value'],
        'short': short, 'slots': order,
    })

out = io.StringIO()
W = out.write

W("""-- ============================================================
-- style_color_overrides_20260805.sql
-- 逐元素颜色覆写 Phase 1 —— 装饰元素「色槽化」
--
-- 配套引擎版本：style-engine.js ?v=20260805b
-- 引擎侧已完成：
--   · BASE_CSS 边框改为 border-color: var(--border-color, var(--card-accent, transparent))
--   · 根元素按需发射 --border-color / --el-<subdim>-cN
--   · 四字段与顶栏/侧栏自定义文字走内联 color（不依赖本 SQL）
--
-- 本 SQL 只做两件事：
--   [A] style_element_options 增加 color_slots / color_slot_sources 两列（供前端动态渲染色槽控件）
--   [B] 把各 css_template 里硬编码的 var(--card-*, X) 原地包一层
--         → var(--el-<subdim>-cN, var(--card-*, X))
--
-- 非破坏性保证：
--   · 用 regexp_replace(...,'g') 原地改写，不整体覆盖 css_template，
--     因此不会冲掉 geo 迁移（--el-geo-gap/--el-geo-thick）等别处改动。
--   · 未发射 --el-*-cN 时，两级回退逐字节等价于改造前。
--   · 每条 UPDATE 带 NOT LIKE 幂等守卫，重复执行不会二次包裹。
--
-- 色槽分配规则：cN = 模板中第 N 个「首次出现」的不同 --card-* 变量；
--               同一变量的多处出现归同一槽，各自保留原兜底值。
--
-- 回滚：见文件末尾 [REVERT] 区块（整段注释掉，需要时解开执行）。
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- [A] 元数据列：前端据此动态渲染「色槽 1/2/3」控件
--     color_slots        : 该取值有几个可覆写色槽（0 = 无可调颜色）
--     color_slot_sources : 各槽原本取自哪个色板槽，'|' 分隔，如 'accent|bg|text'
--                          （前端提示「色槽1（原 accent）」，用户一眼知道在改什么）
-- ------------------------------------------------------------
ALTER TABLE style_element_options
  ADD COLUMN IF NOT EXISTS color_slots        smallint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS color_slot_sources text;

COMMENT ON COLUMN style_element_options.color_slots
  IS '可覆写色槽数量（0~4）。引擎发射 --el-<subdim>-c1..cN，模板以两级回退消费。';
COMMENT ON COLUMN style_element_options.color_slot_sources
  IS '各色槽的原始色板来源，''|'' 分隔，如 accent|bg|text。仅用于前端标注。';

""")

# ---- A2: 写入 color_slots / sources ----
W("-- ---- A2. 逐取值写入色槽元数据 ----\n")
by_n = {}
for p in plan:
    by_n.setdefault(len(p['slots']), []).append(p)

for n in sorted(by_n):
    if n == 0:
        ids = ','.join(str(p['id']) for p in by_n[n])
        W("-- 无可调颜色（%d 条）\n" % len(by_n[n]))
        W("UPDATE style_element_options SET color_slots = 0, color_slot_sources = NULL\n")
        W("  WHERE id IN (%s);\n\n" % ids)
    else:
        W("-- %d 个色槽\n" % n)
        for p in by_n[n]:
            W("UPDATE style_element_options SET color_slots = %d, color_slot_sources = %s\n"
              "  WHERE id = %d;  -- %s / %s\n"
              % (n, q('|'.join(p['slots'])), p['id'], p['sub_dim'], p['value']))
        W("\n")

# ---- B: 模板包裹 ----
W("""-- ------------------------------------------------------------
-- [B] css_template 色槽化：var(--card-X, F) → var(--el-<subdim>-cN, var(--card-X, F))
--     regexp_replace 的 'g' 标志会处理该变量在模板中的【全部】出现，
--     且各处原兜底值 F 由捕获组 \\1 原样带回（如 line_number_column 的 #bbb / #999）。
--     负向守卫 NOT LIKE 保证幂等。
-- ------------------------------------------------------------
""")

total = 0
for p in plan:
    if not p['slots']:
        continue
    W("\n-- id=%d  %s / %s  →  %s\n" % (
        p['id'], p['sub_dim'], p['value'],
        ', '.join('c%d=%s' % (i + 1, v) for i, v in enumerate(p['slots']))))
    for i, v in enumerate(p['slots']):
        slot = '--el-%s-c%d' % (p['short'], i + 1)
        pat = r'var\(\s*--card-%s(\s*,[^)]*)?\)' % v
        rep = 'var(%s, var(--card-%s\\1))' % (slot, v)
        W("UPDATE style_element_options SET css_template = regexp_replace(css_template,\n"
          "    %s, %s, 'g')\n"
          "  WHERE id = %d AND css_template NOT LIKE %s;\n"
          % (q(pat), q(rep), p['id'], q('%' + slot + '%')))
        total += 1

W("""
COMMIT;

-- ============================================================
-- 自检：执行后跑这段，应看到每行 slots 与实际出现的 --el-*-cN 数量一致
-- ============================================================
-- SELECT id, sub_dim, value, color_slots, color_slot_sources,
--        (length(css_template) - length(replace(css_template, '--el-', ''))) AS el_var_hits
--   FROM style_element_options ORDER BY id;

-- ============================================================
-- [REVERT] 回滚：解开注释整段执行，恢复到本次迁移之前
-- ============================================================
/*
BEGIN;
""")

for p in plan:
    if not p['slots']:
        continue
    for i, v in enumerate(p['slots']):
        slot = '--el-%s-c%d' % (p['short'], i + 1)
        pat = r'var\(%s,\s*(var\(--card-%s(\s*,[^)]*)?\))\)' % (re.escape(slot), v)
        W("UPDATE style_element_options SET css_template = regexp_replace(css_template,\n"
          "    %s, %s, 'g') WHERE id = %d;\n"
          % (q(pat), q('\\1'), p['id']))

W("""
ALTER TABLE style_element_options
  DROP COLUMN IF EXISTS color_slots,
  DROP COLUMN IF EXISTS color_slot_sources;
COMMIT;
*/
""")

path = os.path.join(HERE, 'style_color_overrides_20260805.sql')
open(path, 'w', encoding='utf-8', newline='\n').write(out.getvalue())
print('written:', path)
print('rows with slots:', sum(1 for p in plan if p['slots']), '/ total', len(plan))
print('UPDATE stmts (B):', total)
print('slot distribution:', {n: len(v) for n, v in sorted(by_n.items())})
