#!/usr/bin/env python3
"""
Scan Dart files under the repo and replace imports that reference CamelCase filenames
with snake_case filenames where a matching file exists on disk. Also normalize
imports like 'components/foo.dart' used inside files under lib/components to
just 'foo.dart' (same for models/, utils/), to fix URIs that reference the
folder from within the same folder.

Additionally, this script now normalizes `package:la_toolkit/...` imports to
match actual files under `lib/` (converts CamelCase basenames to snake_case
and uses the real relative path under lib).
"""
import os
import re

ROOT = os.path.dirname(os.path.dirname(__file__))
LIB = os.path.join(ROOT, 'lib')
PKG_PREFIX = 'package:la_toolkit/'

# Directories to skip when scanning workspace for files to edit
SKIP_DIRS = {'.git', 'build', 'ios', 'android', 'macos', 'linux', 'windows', '.dart_tool', 'gen', 'build', 'coverage'}

COMMON_PREFIXES = ['components', 'models', 'utils']

def to_snake(name):
    # remove .dart if present
    base = name
    if base.endswith('.dart'):
        base = base[:-5]
    # convert CamelCase or camelCase to snake_case
    s1 = re.sub('(.)([A-Z][a-z]+)', r"\1_\2", base)
    s2 = re.sub('([a-z0-9])([A-Z])', r"\1_\2", s1)
    snake = s2.replace('-', '_').lower()
    return snake + '.dart'

# build map of relative paths under lib by lowercased path
file_map = {}
for dirpath, dirs, files in os.walk(LIB):
    for f in files:
        if not f.endswith('.dart'):
            continue
        rel = os.path.relpath(os.path.join(dirpath, f), LIB).replace('\\', '/')
        file_map[rel.lower()] = rel

# regex to find import lines with single or double quotes
imp_re = re.compile(r"^\s*import\s+['\"]([^'\"]+)['\"];?", re.M)

changed_files = 0
changed_imports = 0

# Walk the whole repo but skip large/generated dirs
for dirpath, dirs, files in os.walk(ROOT):
    # prune dirs
    dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
    for f in files:
        if not f.endswith('.dart'):
            continue
        path = os.path.join(dirpath, f)
        # only edit files inside repo (ignore packages in utils/node_modules etc.)
        if not path.startswith(ROOT):
            continue
        origin_dir = os.path.dirname(os.path.relpath(path, LIB)).replace('\\','/') if os.path.commonpath([path, LIB]) == LIB else ''
        with open(path, 'r', encoding='utf-8') as fh:
            try:
                content = fh.read()
            except UnicodeDecodeError:
                # skip binary or unreadable files
                continue
        new_content = content
        for m in imp_re.finditer(content):
            imp = m.group(1)
            # ignore dart: and external urls
            if imp.startswith('dart:') or imp.startswith('http'):
                continue

            # Handle package:la_toolkit/ imports
            if imp.startswith(PKG_PREFIX):
                pkg_rel = imp[len(PKG_PREFIX):]  # path relative to lib/
                # if path contains uppercase in basename, try to map to snake_case
                basename = os.path.basename(pkg_rel)
                modified = False
                if re.search('[A-Z]', basename):
                    snake = to_snake(basename)
                    dirpart = os.path.dirname(pkg_rel)
                    candidate_rel = os.path.normpath(os.path.join(dirpart, snake)).replace('\\','/')
                    if candidate_rel.lower() in file_map:
                        real_rel = file_map[candidate_rel.lower()].replace('\\','/')
                        new_imp = PKG_PREFIX + real_rel
                        if new_imp != imp:
                            new_content = new_content.replace(m.group(0), m.group(0).replace(imp, new_imp))
                            changed_imports += 1
                            modified = True
                    else:
                        for candidate_key, candidate_val in file_map.items():
                            if os.path.basename(candidate_key) == snake:
                                real_rel = candidate_val.replace('\\','/')
                                new_imp = PKG_PREFIX + real_rel
                                if new_imp != imp:
                                    new_content = new_content.replace(m.group(0), m.group(0).replace(imp, new_imp))
                                    changed_imports += 1
                                    modified = True
                                    break
                if modified:
                    continue
                # If package import references a folder path but actual file exists with different case, normalize to actual file if present
                if pkg_rel.lower() in file_map:
                    real_rel = file_map[pkg_rel.lower()].replace('\\','/')
                    new_imp = PKG_PREFIX + real_rel
                    if new_imp != imp:
                        new_content = new_content.replace(m.group(0), m.group(0).replace(imp, new_imp))
                        changed_imports += 1
                        continue
                # else skip package imports we can't resolve
                continue

            # only consider local imports (relative or lib-root style without package:)
            basename = os.path.basename(imp)
            modified = False

            # If import contains uppercase in basename try to map to snake_case file
            if re.search('[A-Z]', basename):
                snake = to_snake(basename)
                dirpart = os.path.dirname(imp)
                candidate_rel = os.path.normpath(os.path.join(dirpart, snake)).replace('\\','/')
                if candidate_rel.lower() in file_map:
                    real_rel = file_map[candidate_rel.lower()]
                    # compute new import preserving relative or library style
                    if imp.startswith('../') or imp.startswith('./'):
                        # only compute relpath if origin_dir refers to lib
                        if origin_dir:
                            relpath = os.path.relpath(os.path.join(LIB, real_rel), os.path.join(LIB, origin_dir)).replace('\\','/')
                        else:
                            # fallback keep new relative path from repo root to target
                            relpath = os.path.join('lib', real_rel).replace('\\','/')
                        new_imp = relpath
                    else:
                        # if original had no leading ./ or ../, keep it relative to lib root
                        new_imp = real_rel.replace('\\','/')
                    if new_imp != imp:
                        new_content = new_content.replace(m.group(0), m.group(0).replace(imp, new_imp))
                        changed_imports += 1
                        modified = True
                else:
                    # fallback: search any file whose basename matches snake
                    for candidate_key, candidate_val in file_map.items():
                        if os.path.basename(candidate_key) == snake:
                            real_rel = candidate_val
                            if imp.startswith('../') or imp.startswith('./'):
                                if origin_dir:
                                    relpath = os.path.relpath(os.path.join(LIB, real_rel), os.path.join(LIB, origin_dir)).replace('\\','/')
                                else:
                                    relpath = os.path.join('lib', real_rel).replace('\\','/')
                                new_imp = relpath
                            else:
                                new_imp = real_rel.replace('\\','/')
                            if new_imp != imp:
                                new_content = new_content.replace(m.group(0), m.group(0).replace(imp, new_imp))
                                changed_imports += 1
                                modified = True
                                break

            if modified:
                continue

            # Additional normalization: if import starts with a common prefix (e.g. 'components/foo.dart')
            # and the importing file is inside that same folder, replace with basename (local import).
            for prefix in COMMON_PREFIXES:
                if imp.startswith(prefix + '/') and origin_dir == prefix:
                    # replace with just the file name (no folder)
                    new_imp = os.path.basename(imp)
                    if new_imp != imp:
                        new_content = new_content.replace(m.group(0), m.group(0).replace(imp, new_imp))
                        changed_imports += 1
                        modified = True
                        break

        if new_content != content:
            with open(path, 'w', encoding='utf-8') as fh:
                fh.write(new_content)
            changed_files += 1

print(f"Updated imports in {changed_files} files, changed {changed_imports} imports")
