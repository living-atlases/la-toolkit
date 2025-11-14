
"""
Sort import directives in Dart files into groups and alphabetically.
Groups: dart:, package:, relative (starts with 'package:' but not our package, then our package:, then relative './' '../' or no prefix). For simplicity: dart:, package:la_toolkit/, package:, relative.
This is a safe, mechanical change.
"""
import os,re
ROOT=os.path.dirname(os.path.dirname(__file__))
SKIP={' .git','build','ios','android','macos','linux','windows','.dart_tool','gen','coverage','utils/node_modules'}
imp_re=re.compile(r"^(\s*import\s+['\"]([^'\"]+)['\"];?)", re.M)

def group_key(path):
    if path.startswith('dart:'):
        return (0, path)
    if path.startswith('package:la_toolkit/'):
        return (1, path)
    if path.startswith('package:'):
        return (2, path)
    return (3, path)  # relative

changed=[]
for dp,ds,fs in os.walk(ROOT):
    if any(skip in dp for skip in ['.git','build','ios','android','macos','linux','windows','.dart_tool','gen','coverage','utils/node_modules']):
        continue
    for f in fs:
        if not f.endswith('.dart'):
            continue
        path=os.path.join(dp,f)
        try:
            with open(path,'r',encoding='utf-8') as fh:
                s=fh.read()
        except Exception:
            continue
        # find all import lines and their spans
        imports=[]
        for m in imp_re.finditer(s):
            full=m.group(1)
            p=m.group(2)
            imports.append((m.start(),m.end(),full,p))
        if not imports:
            continue
        # Determine contiguous top import block: from first import to last import in sequence without non-empty non-import lines between
        # We'll rebuild all import lines found and replace the block from first import start to last import end
        first=imports[0][0]
        last=imports[-1][1]
        # build sorted groups
        items=[(p,full) for (_,_,full,p) in imports]
        items_sorted=sorted(items, key=lambda pp: group_key(pp[0]))
        grouped=[]
        curgrp=None
        out_lines=[]
        for p,full in items_sorted:
            g=group_key(p)[0]
            if curgrp is None:
                curgrp=g
            if g!=curgrp:
                out_lines.append('')
                curgrp=g
            out_lines.append(full)
        new_block='\n'.join(out_lines)
        # replace in s
        ns=s[:first]+new_block+s[last:]
        if ns!=s:
            with open(path,'w',encoding='utf-8') as fh:
                fh.write(ns)
            changed.append(path)

if changed:
    print('Sorted imports in:')
    for p in changed:
        print(p)
else:
    print('No import blocks changed')

