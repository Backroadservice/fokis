#!/usr/bin/env python3
import csv, sys
from pathlib import Path
if len(sys.argv) < 3:
  print('Usage: python3 dod_csv_to_issues.py <csv> <owner/repo> [label]')
  raise SystemExit(64)
csv_path = Path(sys.argv[1]); repo = sys.argv[2]; label = sys.argv[3] if len(sys.argv)>3 else 'DoD'
out = Path('gh_create_issues.sh')
with out.open('w', encoding='utf-8') as sh:
  sh.write('#!/usr/bin/env bash\nset -euo pipefail\n')
  for r in csv.DictReader(csv_path.open('r', encoding='utf-8')):
    title = f"[{r['id']}] {r['name']}"
    body  = f"Category: {r['category']}\\nCriteria: {r['criteria']}\\nAuto: {csv_path.name}"
    t = title.replace('"','\"'); b = body.replace('"','\"')
    sh.write(f'gh issue create -R {repo} -t "{t}" -b "{b}" -l "{label}"\n')
print(f"Wrote {out}"); 
