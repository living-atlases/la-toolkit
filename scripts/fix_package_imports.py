#!/usr/bin/env python3
"""
Specifically normalize package:la_toolkit/... imports in all .dart files to match
actual files under lib/. This is a focused pass to fix remaining test and source
imports that still point to CamelCase filenames (e.g. StringUtils.dart -> string_utils.dart).
"""
import os, re
ROOT = os.path.dirname(os.path.dirname(__file__))
LIB = os.path.join(ROOT, 'lib')
PKG = 'package:la_toolkit/'

# build file map under lib
file_map = {}
for dp, ds, fs in os.walk(LIB):
    for f in fs:
        if f.endswith('.dart'):
            rel = os.path.relpath(os.path.join(dp, f), LIB).replace('\\','/')
            file_map[rel.lower()] = rel

pkg_re = re.compile(r"(package:la_toolkit/)([^'\"]+\.dart)")
changed = []
for dp, ds, fs in os.walk(ROOT):
    # skip common heavy dirs
    if any(skip in dp for skip in ['.git', 'build', 'ios', 'android', 'macos', 'linux', 'windows', '.dart_tool', 'gen', 'coverage', 'utils/node_modules']):
        continue
    for f in fs:
        if not f.endswith('.dart'):
            continue
        path = os.path.join(dp, f)
        with open(path, 'r', encoding='utf-8') as fh:
            try:
                s = fh.read()
            except Exception:
                continue
        ns = s
        for m in pkg_re.finditer(s):
            full = m.group(0)
            rel = m.group(2)
            # direct match
            if rel.lower() in file_map:
                real = file_map[rel.lower()]
                if real != rel:
                    ns = ns.replace(full, PKG + real)
                    changed.append((path, rel, real))
                    continue
            # try convert basename to snake
            base = os.path.basename(rel)
            if re.search('[A-Z]', base):
                name = base
                # convert CamelCase to snake
                s1 = re.sub('(.)([A-Z][a-z]+)', r"\1_\2", name[:-5])
                s2 = re.sub('([a-z0-9])([A-Z])', r"\1_\2", s1).replace('-', '_').lower()
                cand = os.path.join(os.path.dirname(rel), s2 + '.dart').replace('\\','/')
                if cand.lower() in file_map:
                    real = file_map[cand.lower()]
                    ns = ns.replace(full, PKG + real)
                    changed.append((path, rel, real))
                    continue
                # try find any with same basename
                for k, v in file_map.items():
                    if os.path.basename(k) == s2 + '.dart':
                        ns = ns.replace(full, PKG + v)
                        changed.append((path, rel, v))
                        break
        if ns != s:
            with open(path, 'w', encoding='utf-8') as fh:
                fh.write(ns)

if changed:
    print('Updated package imports:')
    for p, old, new in changed:
        print(p, ' : ', old, '->', new)
else:
    print('No changes')

