import urllib.request
import json
import ssl

BASE_URL = 'https://opyeahbzibuupmkmjpkr.supabase.co'
API_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9weWVhaGJ6aWJ1dXBta21qcGtyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMjk3MDcsImV4cCI6MjA5MzYwNTcwN30.7kCHwI7lKy1jH5BjI4gOKqw2vEUxpsjRJar_94j4Srk'
HEADERS = {
    'apikey': API_KEY,
    'Authorization': f'Bearer {API_KEY}',
    'Accept': 'application/json'
}

ctx = ssl.create_default_context()

def query_api(path):
    url = f'{BASE_URL}/rest/v1/{path}'
    req = urllib.request.Request(url, headers=HEADERS)
    try:
        with urllib.request.urlopen(req, timeout=30, context=ctx) as resp:
            raw = resp.read().decode()
            return resp.status, json.loads(raw)
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ''
        return e.code, body
    except Exception as e:
        return -1, str(e)

def check_table(table_name):
    status, body = query_api(f'{table_name}?limit=1')
    return status, body

# Test known tables
tables_to_check = [
    'style_field_registry',
    'style_container_group_options',
    'style_effect_options',
    'style_layout_options',
    'style_border_options',
    'style_palette_options',
    'style_typo_options',
    'style_deco_options',
    'style_element_options',
    'style_elements_options',
    'STYLE_POOL',
]

print('='*80)
print('1. CHECKING ALL KNOWN TABLE NAMES')
print('='*80)
existing_tables = []
for t in tables_to_check:
    status, body = check_table(t)
    marker = 'EXISTS' if status == 200 else f'NOT_FOUND ({status})'
    print(f'  [{t:40s}] => {marker}')
    if status == 200:
        existing_tables.append(t)

print()
print(f'Total existing tables: {len(existing_tables)}')
print(f'List: {existing_tables}')
print()

# 2. Get DISTINCT sub_dim for each existing table
print('='*80)
print('2. DISTINCT sub_dim VALUES FOR EACH TABLE')
print('='*80)
for t in existing_tables:
    status, body = query_api(f'{t}?select=sub_dim')
    if status == 200:
        sub_dims = set()
        for row in body:
            val = row.get('sub_dim')
            if val:
                sub_dims.add(val)
        print(f'  [{t}] => {sorted(sub_dims) if sub_dims else "EMPTY/NULL"}')
    else:
        print(f'  [{t}] => Error: {body}')
print()

# 3. Get all rows from style_layout_options (limit 50)
print('='*80)
print('3. FULL CONTENT OF style_layout_options (limit 50)')
print('='*80)
if 'style_layout_options' in existing_tables:
    status, body = query_api('style_layout_options?select=*&limit=50')
    if status == 200:
        print(f'  Rows returned: {len(body)}')
        for i, row in enumerate(body):
            print(f'\n  --- Row {i+1} ---')
            for k, v in row.items():
                if isinstance(v, str) and len(v) > 120:
                    print(f'    {k}: {v[:120]}...')
                else:
                    print(f'    {k}: {v}')
    else:
        print(f'  Error: {body}')
else:
    print('  style_layout_options does NOT exist')
print()

# 4. Verify style_element_options vs style_elements_options
print('='*80)
print('4. style_element_options vs style_elements_options VERIFICATION')
print('='*80)
for name in ['style_element_options', 'style_elements_options']:
    s, b = check_table(name)
    marker = 'EXISTS' if s == 200 else f'NOT_FOUND ({s})'
    print(f'  {name} => {marker}')
    if s == 200:
        s2, b2 = query_api(f'{name}?select=*&limit=5')
        if s2 == 200:
            print(f'    Rows: {len(b2)}')
            for row in b2[:3]:
                print(f'    {json.dumps(row, ensure_ascii=False)[:200]}')
        s3, b3 = query_api(f'{name}?select=sub_dim')
        if s3 == 200:
            sub_dims = set(r.get('sub_dim') for r in b3 if r.get('sub_dim'))
            print(f'    sub_dim values: {sorted(sub_dims) if sub_dims else "EMPTY/NULL"}')

print()
print('=' * 80)
print('RESEARCH COMPLETE')
print('=' * 80)
