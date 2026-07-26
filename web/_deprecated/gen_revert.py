# -*- coding: utf-8 -*-
"""
生成「反 SQL」：把 element 维度 13 个模板还原到 element_composite_reorder_20260725.sql
执行前的状态（即 style_element_refactor_20260723.sql 原始定义 + starfield_fix_20260724.sql）。

做法：用正则从两个源 SQL 精确抽取每个 id 的整条 UPDATE（包含原始 14 槽复合块，
顺序为 corner,edge,bg,float = reorder 前的顺序），避免手工抄写出错。
"""
import re, os

BASE = os.path.dirname(os.path.abspath(__file__))
SRC_ORIG = os.path.join(BASE, "..", "_deprecated", "style_element_refactor_20260723.sql")
SRC_SF   = os.path.join(BASE, "starfield_fix_20260724.sql")
OUT      = os.path.join(BASE, "element_revert_reorder_20260725.sql")

# 20260723 覆盖的 id（reorder/strip 改动的 12 个）
IDS_FROM_ORIG = {18, 19, 21, 23, 24, 25, 26, 27, 30, 32, 34, 35}
# starfield (id=48) 在 20260723 里不存在，来自 starfield_fix（reorder 之前）
IDS_FROM_SF = {48}

BLOCK_RE = re.compile(
    r"UPDATE style_element_options SET css_template = (.*?)'\s+WHERE id = (\d+);",
    re.DOTALL | re.IGNORECASE,
)

def extract(path, want):
    with open(path, encoding="utf-8") as f:
        txt = f.read()
    out = {}
    for m in BLOCK_RE.finditer(txt):
        body, sid = m.group(1), int(m.group(2))
        if sid in want:
            # 还原成完整 UPDATE 语句
            out[sid] = "UPDATE style_element_options SET css_template = %s' WHERE id = %d;" % (body, sid)
    return out

blocks = {}
blocks.update(extract(SRC_ORIG, IDS_FROM_ORIG))
blocks.update(extract(SRC_SF, IDS_FROM_SF))

missing = (IDS_FROM_ORIG | IDS_FROM_SF) - set(blocks.keys())
assert not missing, "未能从源 SQL 抽取到这些 id: %s" % missing

# 按 id 排序输出
header = """-- ============================================================
-- 反 SQL：撤销 element_composite_reorder_20260725.sql + element_strip_composite_20260725.sql
-- 目标状态：reorder 执行前（= style_element_refactor_20260723.sql 原始定义 + starfield_fix_20260724.sql）
-- 说明：
--   - 13 个模板的 css_template 全部恢复为「自带完整 14 槽复合块」的原始形态，
--     复合层顺序回到 corner, edge, bg, float（reorder 改成的 corner,edge,float,bg 被撤销）。
--   - 同时覆盖 strip 的改动（strip 把复合块整段删了，这里一并补回）。
--   - 引擎 style-engine.js 需同步回退 BASE_CSS（去掉 14 槽复合块、版本号退回 20260724a），
--     否则模板自带复合块 + 引擎复合块会再次层叠打架。
-- 幂等：重跑无害。执行后硬刷新预览页（Ctrl+Shift+R）重拉 dimensionCache。
-- agent 无 DB 写权限，需在 Supabase SQL Editor 粘贴执行。
-- ============================================================

"""

ordered = [blocks[i] for i in sorted(blocks.keys())]
with open(OUT, "w", encoding="utf-8") as f:
    f.write(header)
    f.write("\n".join(ordered))
    f.write("\n")

print("已生成 %s，共 %d 条 UPDATE：" % (OUT, len(ordered)))
for i in sorted(blocks.keys()):
    print("  id=%d" % i)
