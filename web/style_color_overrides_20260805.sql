-- ============================================================
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

-- ---- A2. 逐取值写入色槽元数据 ----
-- 无可调颜色（11 条）
UPDATE style_element_options SET color_slots = 0, color_slot_sources = NULL
  WHERE id IN (1,6,11,17,22,27,28,29,31,33,51);

-- 1 个色槽
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 2;  -- header_deco / solid
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 5;  -- header_deco / blink
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 7;  -- side_accent / solid
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 8;  -- side_accent / gradient
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'muted'
  WHERE id = 12;  -- divider / thin_solid
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'muted'
  WHERE id = 13;  -- divider / double_line
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'muted'
  WHERE id = 14;  -- divider / dotted_line
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 15;  -- divider / gradient_line
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'muted'
  WHERE id = 16;  -- divider / char_asterisk
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 18;  -- corner_badge / circle_stamp
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'muted'
  WHERE id = 23;  -- bg_pattern / dot_grid
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'muted'
  WHERE id = 24;  -- bg_pattern / fine_grid
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'muted'
  WHERE id = 25;  -- bg_pattern / horizontal_lines
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 30;  -- edge_deco / bracket_frame
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'muted'
  WHERE id = 32;  -- edge_deco / tape_stripe
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 34;  -- floating_deco / floating_circle
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 35;  -- floating_deco / scatter_dots
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 36;  -- floating_deco / art_deco_diamond
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 37;  -- floating_deco / tamagotchi_label
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 42;  -- header_deco / diagonal
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 43;  -- header_deco / breathing
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 44;  -- header_deco / scanline
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 45;  -- side_accent / diagonal
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 46;  -- side_accent / breathing
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 47;  -- side_accent / scanline
UPDATE style_element_options SET color_slots = 1, color_slot_sources = 'accent'
  WHERE id = 53;  -- corner_badge / photo_corner

-- 2 个色槽
UPDATE style_element_options SET color_slots = 2, color_slot_sources = 'accent|muted'
  WHERE id = 4;  -- header_deco / gradient
UPDATE style_element_options SET color_slots = 2, color_slot_sources = 'muted|bg'
  WHERE id = 10;  -- side_accent / notebook_binding
UPDATE style_element_options SET color_slots = 2, color_slot_sources = 'muted|text'
  WHERE id = 19;  -- corner_badge / page_fold
UPDATE style_element_options SET color_slots = 2, color_slot_sources = 'accent|bg'
  WHERE id = 20;  -- corner_badge / corner_ribbon
UPDATE style_element_options SET color_slots = 2, color_slot_sources = 'bg|accent'
  WHERE id = 21;  -- corner_badge / dot_status
UPDATE style_element_options SET color_slots = 2, color_slot_sources = 'bg|muted'
  WHERE id = 26;  -- bg_pattern / gradient_overlay
UPDATE style_element_options SET color_slots = 2, color_slot_sources = 'text|muted'
  WHERE id = 48;  -- bg_pattern / starfield
UPDATE style_element_options SET color_slots = 2, color_slot_sources = 'bg|accent'
  WHERE id = 54;  -- floating_deco / vinyl_record

-- 3 个色槽
UPDATE style_element_options SET color_slots = 3, color_slot_sources = 'bg|text|muted'
  WHERE id = 9;  -- side_accent / line_number_column
UPDATE style_element_options SET color_slots = 3, color_slot_sources = 'accent|bg|text'
  WHERE id = 52;  -- floating_deco / wax_seal

-- ------------------------------------------------------------
-- [B] css_template 色槽化：var(--card-X, F) → var(--el-<subdim>-cN, var(--card-X, F))
--     regexp_replace 的 'g' 标志会处理该变量在模板中的【全部】出现，
--     且各处原兜底值 F 由捕获组 \1 原样带回（如 line_number_column 的 #bbb / #999）。
--     负向守卫 NOT LIKE 保证幂等。
-- ------------------------------------------------------------

-- id=2  header_deco / solid  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-header-c1, var(--card-accent\1))', 'g')
  WHERE id = 2 AND css_template NOT LIKE '%--el-header-c1%';

-- id=4  header_deco / gradient  →  c1=accent, c2=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-header-c1, var(--card-accent\1))', 'g')
  WHERE id = 4 AND css_template NOT LIKE '%--el-header-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-header-c2, var(--card-muted\1))', 'g')
  WHERE id = 4 AND css_template NOT LIKE '%--el-header-c2%';

-- id=5  header_deco / blink  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-header-c1, var(--card-accent\1))', 'g')
  WHERE id = 5 AND css_template NOT LIKE '%--el-header-c1%';

-- id=7  side_accent / solid  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-side-c1, var(--card-accent\1))', 'g')
  WHERE id = 7 AND css_template NOT LIKE '%--el-side-c1%';

-- id=8  side_accent / gradient  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-side-c1, var(--card-accent\1))', 'g')
  WHERE id = 8 AND css_template NOT LIKE '%--el-side-c1%';

-- id=9  side_accent / line_number_column  →  c1=bg, c2=text, c3=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-bg(\s*,[^)]*)?\)', 'var(--el-side-c1, var(--card-bg\1))', 'g')
  WHERE id = 9 AND css_template NOT LIKE '%--el-side-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-text(\s*,[^)]*)?\)', 'var(--el-side-c2, var(--card-text\1))', 'g')
  WHERE id = 9 AND css_template NOT LIKE '%--el-side-c2%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-side-c3, var(--card-muted\1))', 'g')
  WHERE id = 9 AND css_template NOT LIKE '%--el-side-c3%';

-- id=10  side_accent / notebook_binding  →  c1=muted, c2=bg
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-side-c1, var(--card-muted\1))', 'g')
  WHERE id = 10 AND css_template NOT LIKE '%--el-side-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-bg(\s*,[^)]*)?\)', 'var(--el-side-c2, var(--card-bg\1))', 'g')
  WHERE id = 10 AND css_template NOT LIKE '%--el-side-c2%';

-- id=12  divider / thin_solid  →  c1=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-divider-c1, var(--card-muted\1))', 'g')
  WHERE id = 12 AND css_template NOT LIKE '%--el-divider-c1%';

-- id=13  divider / double_line  →  c1=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-divider-c1, var(--card-muted\1))', 'g')
  WHERE id = 13 AND css_template NOT LIKE '%--el-divider-c1%';

-- id=14  divider / dotted_line  →  c1=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-divider-c1, var(--card-muted\1))', 'g')
  WHERE id = 14 AND css_template NOT LIKE '%--el-divider-c1%';

-- id=15  divider / gradient_line  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-divider-c1, var(--card-accent\1))', 'g')
  WHERE id = 15 AND css_template NOT LIKE '%--el-divider-c1%';

-- id=16  divider / char_asterisk  →  c1=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-divider-c1, var(--card-muted\1))', 'g')
  WHERE id = 16 AND css_template NOT LIKE '%--el-divider-c1%';

-- id=18  corner_badge / circle_stamp  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-corner-c1, var(--card-accent\1))', 'g')
  WHERE id = 18 AND css_template NOT LIKE '%--el-corner-c1%';

-- id=19  corner_badge / page_fold  →  c1=muted, c2=text
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-corner-c1, var(--card-muted\1))', 'g')
  WHERE id = 19 AND css_template NOT LIKE '%--el-corner-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-text(\s*,[^)]*)?\)', 'var(--el-corner-c2, var(--card-text\1))', 'g')
  WHERE id = 19 AND css_template NOT LIKE '%--el-corner-c2%';

-- id=20  corner_badge / corner_ribbon  →  c1=accent, c2=bg
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-corner-c1, var(--card-accent\1))', 'g')
  WHERE id = 20 AND css_template NOT LIKE '%--el-corner-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-bg(\s*,[^)]*)?\)', 'var(--el-corner-c2, var(--card-bg\1))', 'g')
  WHERE id = 20 AND css_template NOT LIKE '%--el-corner-c2%';

-- id=21  corner_badge / dot_status  →  c1=bg, c2=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-bg(\s*,[^)]*)?\)', 'var(--el-corner-c1, var(--card-bg\1))', 'g')
  WHERE id = 21 AND css_template NOT LIKE '%--el-corner-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-corner-c2, var(--card-accent\1))', 'g')
  WHERE id = 21 AND css_template NOT LIKE '%--el-corner-c2%';

-- id=23  bg_pattern / dot_grid  →  c1=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-bg-c1, var(--card-muted\1))', 'g')
  WHERE id = 23 AND css_template NOT LIKE '%--el-bg-c1%';

-- id=24  bg_pattern / fine_grid  →  c1=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-bg-c1, var(--card-muted\1))', 'g')
  WHERE id = 24 AND css_template NOT LIKE '%--el-bg-c1%';

-- id=25  bg_pattern / horizontal_lines  →  c1=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-bg-c1, var(--card-muted\1))', 'g')
  WHERE id = 25 AND css_template NOT LIKE '%--el-bg-c1%';

-- id=26  bg_pattern / gradient_overlay  →  c1=bg, c2=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-bg(\s*,[^)]*)?\)', 'var(--el-bg-c1, var(--card-bg\1))', 'g')
  WHERE id = 26 AND css_template NOT LIKE '%--el-bg-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-bg-c2, var(--card-muted\1))', 'g')
  WHERE id = 26 AND css_template NOT LIKE '%--el-bg-c2%';

-- id=30  edge_deco / bracket_frame  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-edge-c1, var(--card-accent\1))', 'g')
  WHERE id = 30 AND css_template NOT LIKE '%--el-edge-c1%';

-- id=32  edge_deco / tape_stripe  →  c1=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-edge-c1, var(--card-muted\1))', 'g')
  WHERE id = 32 AND css_template NOT LIKE '%--el-edge-c1%';

-- id=34  floating_deco / floating_circle  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-float-c1, var(--card-accent\1))', 'g')
  WHERE id = 34 AND css_template NOT LIKE '%--el-float-c1%';

-- id=35  floating_deco / scatter_dots  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-float-c1, var(--card-accent\1))', 'g')
  WHERE id = 35 AND css_template NOT LIKE '%--el-float-c1%';

-- id=36  floating_deco / art_deco_diamond  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-float-c1, var(--card-accent\1))', 'g')
  WHERE id = 36 AND css_template NOT LIKE '%--el-float-c1%';

-- id=37  floating_deco / tamagotchi_label  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-float-c1, var(--card-accent\1))', 'g')
  WHERE id = 37 AND css_template NOT LIKE '%--el-float-c1%';

-- id=42  header_deco / diagonal  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-header-c1, var(--card-accent\1))', 'g')
  WHERE id = 42 AND css_template NOT LIKE '%--el-header-c1%';

-- id=43  header_deco / breathing  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-header-c1, var(--card-accent\1))', 'g')
  WHERE id = 43 AND css_template NOT LIKE '%--el-header-c1%';

-- id=44  header_deco / scanline  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-header-c1, var(--card-accent\1))', 'g')
  WHERE id = 44 AND css_template NOT LIKE '%--el-header-c1%';

-- id=45  side_accent / diagonal  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-side-c1, var(--card-accent\1))', 'g')
  WHERE id = 45 AND css_template NOT LIKE '%--el-side-c1%';

-- id=46  side_accent / breathing  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-side-c1, var(--card-accent\1))', 'g')
  WHERE id = 46 AND css_template NOT LIKE '%--el-side-c1%';

-- id=47  side_accent / scanline  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-side-c1, var(--card-accent\1))', 'g')
  WHERE id = 47 AND css_template NOT LIKE '%--el-side-c1%';

-- id=48  bg_pattern / starfield  →  c1=text, c2=muted
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-text(\s*,[^)]*)?\)', 'var(--el-bg-c1, var(--card-text\1))', 'g')
  WHERE id = 48 AND css_template NOT LIKE '%--el-bg-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-muted(\s*,[^)]*)?\)', 'var(--el-bg-c2, var(--card-muted\1))', 'g')
  WHERE id = 48 AND css_template NOT LIKE '%--el-bg-c2%';

-- id=52  floating_deco / wax_seal  →  c1=accent, c2=bg, c3=text
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-float-c1, var(--card-accent\1))', 'g')
  WHERE id = 52 AND css_template NOT LIKE '%--el-float-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-bg(\s*,[^)]*)?\)', 'var(--el-float-c2, var(--card-bg\1))', 'g')
  WHERE id = 52 AND css_template NOT LIKE '%--el-float-c2%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-text(\s*,[^)]*)?\)', 'var(--el-float-c3, var(--card-text\1))', 'g')
  WHERE id = 52 AND css_template NOT LIKE '%--el-float-c3%';

-- id=53  corner_badge / photo_corner  →  c1=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-corner-c1, var(--card-accent\1))', 'g')
  WHERE id = 53 AND css_template NOT LIKE '%--el-corner-c1%';

-- id=54  floating_deco / vinyl_record  →  c1=bg, c2=accent
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-bg(\s*,[^)]*)?\)', 'var(--el-float-c1, var(--card-bg\1))', 'g')
  WHERE id = 54 AND css_template NOT LIKE '%--el-float-c1%';
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\s*--card-accent(\s*,[^)]*)?\)', 'var(--el-float-c2, var(--card-accent\1))', 'g')
  WHERE id = 54 AND css_template NOT LIKE '%--el-float-c2%';

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
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-header\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 2;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-header\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 4;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-header\-c2,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 4;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-header\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 5;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 7;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 8;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c1,\s*(var\(--card-bg(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 9;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c2,\s*(var\(--card-text(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 9;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c3,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 9;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 10;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c2,\s*(var\(--card-bg(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 10;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-divider\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 12;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-divider\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 13;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-divider\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 14;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-divider\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 15;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-divider\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 16;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-corner\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 18;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-corner\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 19;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-corner\-c2,\s*(var\(--card-text(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 19;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-corner\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 20;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-corner\-c2,\s*(var\(--card-bg(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 20;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-corner\-c1,\s*(var\(--card-bg(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 21;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-corner\-c2,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 21;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-bg\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 23;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-bg\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 24;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-bg\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 25;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-bg\-c1,\s*(var\(--card-bg(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 26;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-bg\-c2,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 26;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-edge\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 30;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-edge\-c1,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 32;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-float\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 34;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-float\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 35;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-float\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 36;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-float\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 37;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-header\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 42;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-header\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 43;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-header\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 44;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 45;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 46;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-side\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 47;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-bg\-c1,\s*(var\(--card-text(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 48;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-bg\-c2,\s*(var\(--card-muted(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 48;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-float\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 52;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-float\-c2,\s*(var\(--card-bg(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 52;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-float\-c3,\s*(var\(--card-text(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 52;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-corner\-c1,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 53;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-float\-c1,\s*(var\(--card-bg(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 54;
UPDATE style_element_options SET css_template = regexp_replace(css_template,
    'var\(\-\-el\-float\-c2,\s*(var\(--card-accent(\s*,[^)]*)?\))\)', '\1', 'g') WHERE id = 54;

ALTER TABLE style_element_options
  DROP COLUMN IF EXISTS color_slots,
  DROP COLUMN IF EXISTS color_slot_sources;
COMMIT;
*/
