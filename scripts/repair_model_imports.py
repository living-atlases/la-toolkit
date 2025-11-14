#!/usr/bin/env python3
import os, re
ROOT = os.path.dirname(os.path.dirname(__file__))
LIB = os.path.join(ROOT, 'lib')

# build map of existing files under lib keyed by lowercase rel path
file_map = {}
for dp, ds, fs in os.walk(LIB):
    for f in fs:
        if not f.endswith('.dart'):
            continue
        rel = os.path.relpath(os.path.join(dp, f), LIB).replace('\\','/')
        file_map[rel.lower()] = rel

imp_re = re.compile(r"(^\s*import\s+['\"])([^'\"]+)(['\"];?)", re.M)

changed = []
for dp, ds, fs in os.walk(ROOT):
    # skip heavy dirs
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
        for m in imp_re.finditer(s):
            full_prefix = m.group(1)
            imp_path = m.group(2)
            full_suffix = m.group(3)
            # only care about imports that reference models/ or package:la_toolkit/models/
            if imp_path.startswith('package:la_toolkit/models/'):
                rel = imp_path[len('package:la_toolkit/'):]  # models/....dart
                key = rel.lower()
                if key in file_map:
                    continue
                # try heuristics
                basename = os.path.basename(rel)
                # try snake from camel
                def to_snake(name):
                    b = name[:-5] if name.endswith('.dart') else name
                    s1 = re.sub('(.)([A-Z][a-z]+)', r"\1_\2", b)
                    s2 = re.sub('([a-z0-9])([A-Z])', r"\1_\2", s1)
                    return s2.replace('-', '_').lower() + '.dart'
                snake = to_snake(basename)
                cand1 = os.path.join(os.path.dirname(rel), snake).replace('\\','/')
                if cand1.lower() in file_map:
                    real = file_map[cand1.lower()]
                    new_imp = 'package:la_toolkit/' + real
                    ns = ns.replace(full_prefix + imp_path + full_suffix, full_prefix + new_imp + full_suffix)
                    changed.append((path, imp_path, new_imp))
                    continue
                # search any file with same base ignoring underscores and case
                def keyname(p):
                    return os.path.basename(p).replace('_','').lower()
                target = None
                for k,v in file_map.items():
                    if keyname(k) == keyname(basename):
                        target = v
                        break
                if target:
                    new_imp = 'package:la_toolkit/' + target
                    ns = ns.replace(full_prefix + imp_path + full_suffix, full_prefix + new_imp + full_suffix)
                    changed.append((path, imp_path, new_imp))
                continue

            # local imports like 'models/xxx.dart' or 'models/XXX.dart'
            if imp_path.startswith('models/'):
                rel = imp_path  # relative to lib root
                key = rel.lower()
                if key in file_map:
                    continue
                basename = os.path.basename(rel)
                def to_snake(name):
                    b = name[:-5] if name.endswith('.dart') else name
                    s1 = re.sub('(.)([A-Z][a-z]+)', r"\1_\2", b)
                    s2 = re.sub('([a-z0-9])([A-Z])', r"\1_\2", s1)
                    return s2.replace('-', '_').lower() + '.dart'
                snake = to_snake(basename)
                cand1 = os.path.join(os.path.dirname(rel), snake).replace('\\','/')
                if cand1.lower() in file_map:
                    real = file_map[cand1.lower()]
                    new_imp = real.replace('\\','/')
                    # keep it as 'models/...' style
                    new_imp = new_imp if new_imp.startswith('models/') else 'models/' + new_imp
                    ns = ns.replace(full_prefix + imp_path + full_suffix, full_prefix + new_imp + full_suffix)
                    changed.append((path, imp_path, new_imp))
                    continue
                # try match any file with same base
                def keyname(p):
                    return os.path.basename(p).replace('_','').lower()
                target = None
                for k,v in file_map.items():
                    if keyname(k) == keyname(basename):
                        target = v
                        break
                if target:
                    new_imp = target.replace('\\','/')
                    new_imp = new_imp if new_imp.startswith('models/') else 'models/' + new_imp
                    ns = ns.replace(full_prefix + imp_path + full_suffix, full_prefix + new_imp + full_suffix)
                    changed.append((path, imp_path, new_imp))
                continue

        if ns != s:
            with open(path, 'w', encoding='utf-8') as fh:
                fh.write(ns)

if changed:
    print('Rewrote imports:')
    for p,o,n in changed:
        print(p, ' : ', o, '->', n)
else:
    print('No changes')

