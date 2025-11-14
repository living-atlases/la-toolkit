#!/usr/bin/env python3
"""
Remove exact duplicate import lines in Dart files across the repo. This only
removes identical import statements that appear more than once in a file.
"""
import os, re
ROOT = os.path.dirname(os.path.dirname(__file__))
SKIP = {'.git', 'build', 'ios', 'android', 'macos', 'linux', 'windows', '.dart_tool', 'gen', 'coverage', 'utils/node_modules'}
imp_re = re.compile(r"^(\s*import\s+['\"][^'\"]+['\"];?)$", re.M)
changed = []
for dp, ds, fs in os.walk(ROOT):
    # skip dirs
    if any(part in dp for part in SKIP):
        continue
    for f in fs:
        if not f.endswith('.dart'):
            continue
        path = os.path.join(dp, f)
        try:
            with open(path, 'r', encoding='utf-8') as fh:
                s = fh.read()
        except Exception:
            continue
        imports = imp_re.findall(s)
        if not imports:
            continue
        seen = set()
        new_lines = []
        changed_file = False
        lines = s.splitlines()
        for line in lines:
            m = imp_re.match(line)
            if m:
                imp = m.group(1)
                if imp in seen:
                    # drop duplicate
                    changed_file = True
                    continue
                seen.add(imp)
                new_lines.append(line)
            else:
                new_lines.append(line)
        if changed_file:
            ns = '\n'.join(new_lines) + ('\n' if s.endswith('\n') else '')
            with open(path, 'w', encoding='utf-8') as fh:
                fh.write(ns)
            changed.append(path)

if changed:
    print('Removed duplicate imports in:')
    for p in changed:
        print(p)
else:
    print('No duplicate imports found')

