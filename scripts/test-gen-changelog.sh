#!/bin/bash
#
# test-gen-changelog.sh
#
# scripts/gen-changelog.py rebuilds CHANGELOG.md from the release tags, the commits
# between them, and the backend commits made between them. What this pins down,
# against the real history of both repositories:
#   1. every vX.Y.Z tag gets exactly one section, newest first, with an anchor;
#   2. every commit of this repository (on master or in a tag) appears exactly
#      once: in the oldest tag that contains it, or under "Unreleased";
#   3. every commit of the backend's master appears exactly once too;
#   4. a tag with neither notes file nor annotation links its GitHub release;
#   5. no em or en dash reaches the published file;
#   6. the committed CHANGELOG.md matches the generator for every tagged release
#      ("Unreleased" is left out: committing the file is itself a new commit).
#
# Usage: bash scripts/test-gen-changelog.sh      Exits 0 if every assertion holds.
# Needs the backend checkout (../la_toolkit_backend, or LA_TOOLKIT_BACKEND_DIR).

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR" || exit 1
BACKEND_DIR="${LA_TOOLKIT_BACKEND_DIR:-$(dirname "$REPO_DIR")/la_toolkit_backend}"

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
FAILURES=0
pass() { echo -e "${GREEN}[PASS]${NC} $*"; }
fail() { echo -e "${RED}[FAIL]${NC} $*"; FAILURES=$((FAILURES + 1)); }

OUT="$(mktemp)"
trap 'rm -f "$OUT"' EXIT
if ! python3 scripts/gen-changelog.py > "$OUT"; then
    fail "gen-changelog.py exited non-zero"; exit 1
fi

tags="$(git tag --sort=-v:refname | grep '^v[0-9]')"
n_tags="$(printf '%s\n' "$tags" | grep -c .)"
n_sections="$(grep -c '^## v' "$OUT")"
if [[ "$n_sections" -eq "$n_tags" ]]; then
    pass "one section per tag ($n_tags)"
else
    fail "$n_sections sections for $n_tags tags"
fi
if [[ "$(grep '^## v' "$OUT" | awk '{print $2}')" == "$tags" ]]; then
    pass "sections are in newest-first tag order"
else
    fail "section order does not match git tag --sort=-v:refname"
fi
missing_anchor=0
for t in $tags; do grep -q "^<a name=\"$t\"></a>$" "$OUT" || missing_anchor=$((missing_anchor + 1)); done
[[ "$missing_anchor" -eq 0 ]] && pass "every tag has an anchor" || fail "$missing_anchor tag(s) without an anchor"

count_links() {  # $1 repo url: total and unique commit links to it
    local all
    all="$(grep -o "$1/commit/[0-9a-f]\{40\})" "$OUT")"
    echo "$(printf '%s' "$all" | grep -c .) $(printf '%s' "$all" | sort -u | grep -c .)"
}
check_repo() {  # $1 name, $2 url, $3 expected count
    read -r n_links n_unique <<< "$(count_links "$2")"
    if [[ "$n_links" -eq "$3" && "$n_unique" -eq "$3" ]]; then
        pass "all $3 $1 commits listed exactly once"
    else
        fail "$1: $n_links links ($n_unique unique) for $3 commits"
    fi
}
check_repo "toolkit" "https://github.com/living-atlases/la-toolkit" \
    "$(git rev-list --count --no-merges HEAD $tags)"
check_repo "backend" "https://github.com/living-atlases/la-toolkit-backend" \
    "$(git -C "$BACKEND_DIR" rev-list --count --no-merges master)"

light="$(for t in $tags; do
    [[ "$(git cat-file -t "$t")" == commit && ! -f "docs/release-notes/$t.md" ]] && echo "$t"
done | head -1)"
if [[ -n "$light" ]]; then
    if grep -A2 "^## $light - " "$OUT" | grep -q "^Release notes: .*/releases/tag/$light$"; then
        pass "lightweight tag $light links its GitHub release"
    else
        fail "lightweight tag $light does not link its GitHub release"
    fi
fi

if grep -q $'—\|–' "$OUT"; then
    fail "an em/en dash reached the generated changelog"
else
    pass "no em/en dashes"
fi

released() { sed -n '/^<a name="v/,$p' "$1"; }
if diff -q <(released "$OUT") <(released CHANGELOG.md) >/dev/null 2>&1; then
    pass "CHANGELOG.md is up to date with the generator"
else
    fail "CHANGELOG.md differs from scripts/gen-changelog.py output (regenerate it)"
fi

[[ "$FAILURES" -eq 0 ]] && { echo "All checks passed."; exit 0; }
echo "$FAILURES check(s) failed."; exit 1
