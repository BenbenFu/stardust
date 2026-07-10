import sys

with open('style-engine.js', 'r', encoding='utf-8') as f:
    lines = f.readlines()

print(f"总行数: {len(lines)}", file=sys.stderr)

# 第82-101行（1-indexed）= 索引 81-100（0-indexed）
# lines[81] = "/* === 2. 配色板（17 组）=== */"
# lines[100] = "    .gallery-card[data-palette=\"dostoevsky_notebook\"] ..."
# 删除索引 81 到 100（包含）
new_lines = lines[:81] + lines[101:]

# 在原来第82行的位置插入一段注释，说明 palette 已改为 DB 驱动
# lines[:81] 的最后一行是 PALETTES 的闭合大括号（第81行）
# 在它后面插入注释，然后接上原来的 line 103（现在是 new_lines[81]）
comment = '/* === 2. 配色板（DB 驱动，无硬编码）=== */\n'
final_lines = new_lines[:81] + [comment, '\n'] + new_lines[81:]

with open('style-engine.js', 'w', encoding='utf-8') as f:
    f.writelines(final_lines)

print(f"删除完成，新行数: {len(final_lines)}", file=sys.stderr)
print("OK", file=sys.stderr)
