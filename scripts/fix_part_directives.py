#!/usr/bin/env python3
"""
Fix 'part' directives in lib/models/*.dart so they reference the correct snake_case
generated filenames (e.g. part 'la_service_deploy.g.dart';). Also fix 'part of'
inside '.g.dart' files to point back to the snake_case parent.
"""
import os,re
ROOT = os.path.dirname(os.path.dirname(__file__))
MODELS = os.path.join(ROOT, 'lib', 'models')

changed = []
# Process non-generated dart files
for fname in os.listdir(MODELS):
    if not fname.endswith('.dart'):
        continue
    if fname.endswith('.g.dart'):
        continue
    path = os.path.join(MODELS, fname)
    with open(path, 'r', encoding='utf-8') as fh:
        s = fh.read()
    # expected gname
    expected_g = os.path.basename(fname[:-5] + '.g.dart')
    # find existing part directive
    m = re.search(r"part\s+['\"]([^'\"]+\.g\.dart)['\"];", s)
    if m:
        current = m.group(1)
        if current != expected_g:
            ns = s.replace(m.group(0), f"part '{expected_g}';")
            with open(path, 'w', encoding='utf-8') as fh:
                fh.write(ns)
            changed.append((path, current, expected_g))

# Process generated .g.dart files to ensure 'part of' refers to snake_case parent
for fname in os.listdir(MODELS):
    if not fname.endswith('.g.dart'):
        continue
    path = os.path.join(MODELS, fname)
    with open(path, 'r', encoding='utf-8') as fh:
        s = fh.read()
    # expected parent
    parent = fname[:-6] + '.dart'
    m = re.search(r"part of\s+['\"]([^'\"]+\.dart)['\"];", s)
    if m:
        current = m.group(1)
        if current != parent:
            ns = s.replace(m.group(0), f"part of '{parent}';")
            with open(path, 'w', encoding='utf-8') as fh:
                fh.write(ns)
            changed.append((path, current, parent))

if changed:
    print('Fixed part directives:')
    for p,c,n in changed:
        print(p, ':', c, '->', n)
else:
    print('No changes')

