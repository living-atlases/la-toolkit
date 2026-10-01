#!/usr/bin/env python3
"""Regenerate CHANGELOG.md from the release tags and the commits between them.

A release ships two repositories: this one (frontend, la_toolkit_core, MCP) and
la-toolkit-backend, which the image clones from master when it is built. So each
entry lists this repository's commits that first shipped in that tag (the oldest
tag, by version, that contains them: a plain prev..tag range repeats or loses
commits where a tag sits on a side branch, like v1.6.7), and the backend commits
made between the previous tag and this one (by commit date: the backend is not
tagged per release).

Release notes, on top of each entry, come from docs/release-notes/<tag>.md when it
exists (docs/release-notes/next.md for "Unreleased"), else from the annotated tag
message, else a link to the GitHub release. Everything else comes from git, so:

    scripts/gen-changelog.py > CHANGELOG.md

The backend checkout defaults to ../la_toolkit_backend (LA_TOOLKIT_BACKEND_DIR).
"""
import os
import re
import subprocess
import sys

REPO_URL = "https://github.com/living-atlases/la-toolkit"
BACKEND_URL = "https://github.com/living-atlases/la-toolkit-backend"
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BACKEND_DIR = os.environ.get(
    "LA_TOOLKIT_BACKEND_DIR", os.path.join(os.path.dirname(ROOT), "la_toolkit_backend"))
NOTES_DIR = os.path.join(ROOT, "docs", "release-notes")
FOLD_OVER = 30  # ranges longer than this are folded in <details>
MAX_SUBJECT = 140

GROUPS = [
    ("Features", {"feat", "add", "added", "build", "perf", "new"}),
    ("Fixes", {"fix", "fixes", "fixed", "correct", "revert", "restore", "remove"}),
    ("Tests and CI", {"test", "tests", "ci", "e2e", "docs+test"}),
    ("Documentation", {"docs", "doc"}),
    ("Maintenance", {"chore", "refactor", "style", "cleanup", "update", "upgrade",
                     "improve", "bump"}),
]
CONVENTIONAL = re.compile(r"^(?P<type>[A-Za-z+]+)(?:\((?P<scope>[^)]*)\))?!?:\s*(?P<rest>.*)$")


def git(*args, cwd=ROOT):
    return subprocess.run(["git", *args], cwd=cwd, capture_output=True, text=True,
                          check=True).stdout


def clean(text):
    return text.replace("—", "-").replace("–", "-").replace("\r", "")


def shorten(subject):
    """A body pasted into the subject line (no blank line after it) is cut off."""
    if len(subject) <= MAX_SUBJECT:
        return subject
    cut = subject.find(" - ")
    return subject[:cut] if 0 < cut <= MAX_SUBJECT else subject[:MAX_SUBJECT - 3] + "..."


def classify(subject):
    """Return (group, display text) for a commit subject."""
    subject = shorten(subject)
    m = CONVENTIONAL.match(subject)
    if m:
        kind = m.group("type").lower()
        scope = m.group("scope")
        text = f"**{scope}**: {m.group('rest')}" if scope else m.group("rest")
    else:
        first = subject.split()[0].rstrip(":").lower() if subject.split() else ""
        kind, text = first, subject
    for name, kinds in GROUPS:
        if kind in kinds:
            return name, text
    return "Other changes", text


def commits(*log_args, cwd=ROOT):
    out = git("log", "--no-merges", "--format=%h%x09%H%x09%s", *log_args, cwd=cwd)
    return [line.split("\t", 2) for line in out.splitlines() if line.strip()]


def backend_commits(after, until):
    """Backend commits with a commit date in (after, until]; epoch seconds or None."""
    if not os.path.isdir(BACKEND_DIR):
        sys.exit(f"gen-changelog: no backend checkout at {BACKEND_DIR} "
                 "(set LA_TOOLKIT_BACKEND_DIR)")
    out = git("log", "--no-merges", "--format=%ct%x09%h%x09%H%x09%s", "master",
              cwd=BACKEND_DIR)
    picked = []
    for line in out.splitlines():
        ts, short, full, subject = line.split("\t", 3)
        ts = int(ts)
        if (after is None or ts > after) and (until is None or ts <= until):
            picked.append([short, full, subject])
    return picked


def render_commits(entries, url):
    grouped = {}
    for short, full, subject in entries:
        name, text = classify(clean(subject))
        grouped.setdefault(name, []).append(f"- {text} ([{short}]({url}/commit/{full}))")
    lines = []
    for name in [g for g, _ in GROUPS] + ["Other changes"]:
        if name in grouped:
            lines += [f"#### {name}", ""] + grouped[name] + [""]
    return lines


def render_block(title, entries, url):
    lines = [f"### {title} ({len(entries)})", ""]
    if not entries:
        return lines + ["None.", ""]
    body = render_commits(entries, url)
    if len(entries) > FOLD_OVER:
        return lines + ["<details>", f"<summary>All {len(entries)} commits, by type</summary>",
                        ""] + body + ["</details>", ""]
    return lines + body


def notes_file(name):
    path = os.path.join(NOTES_DIR, f"{name}.md")
    if os.path.isfile(path):
        with open(path, encoding="utf-8") as f:
            # One level down: in the changelog they sit under the "## vX.Y.Z" heading.
            return re.sub(r"^(#+) ", r"#\1 ", clean(f.read()).strip(), flags=re.M)
    return ""


def tag_notes(tag):
    from_file = notes_file(tag)
    if from_file:
        return from_file
    if git("cat-file", "-t", tag).strip() == "tag":  # a lightweight tag has no notes
        subject = clean(git("for-each-ref", f"refs/tags/{tag}",
                            "--format=%(contents:subject)").strip())
        body = clean(git("for-each-ref", f"refs/tags/{tag}",
                         "--format=%(contents:body)").strip())
        title = re.sub(r"^(la-toolkit\s+)?v?" + re.escape(tag.lstrip("v")) + r"\s*[-:]*\s*",
                       "", subject).strip()
        return "\n\n".join(p for p in (f"**{title}**" if title else "", body) if p)
    return ""


def tag_time(tag):
    return int(git("log", "-1", "--format=%ct", tag).strip())


def main():
    # Releases are vX.Y.Z; 1.0.18 is a stray duplicate of v1.0.18.
    tags = [t for t in git("tag", "--sort=-v:refname").split() if re.match(r"^v\d", t)]
    out = [
        "# Changelog",
        "",
        "Changes per release tag, newest first: the release notes, then every commit",
        "since the previous tag in this repository and in",
        f"[la-toolkit-backend]({BACKEND_URL}), which the image clones from master at",
        "build time (backend commits are placed by date). Generated by",
        "scripts/gen-changelog.py; do not edit by hand, write the notes in",
        "docs/release-notes/ instead.",
        "",
    ]
    # Each commit goes to the oldest tag that contains it; the rest are unreleased.
    shipped, seen = {}, set()
    for tag in reversed(tags):
        shipped[tag] = [c for c in commits(tag) if c[1] not in seen]
        seen.update(c[1] for c in shipped[tag])
    newest = tag_time(tags[0]) if tags else None
    out += ['<a name="unreleased"></a>', "", "## Unreleased", ""]
    notes = notes_file("next")
    if notes:
        out += [notes, ""]
    out += render_block("Commits", [c for c in commits("HEAD") if c[1] not in seen], REPO_URL)
    out += render_block("Backend commits", backend_commits(newest, None), BACKEND_URL)
    for i, tag in enumerate(tags):
        prev = tags[i + 1] if i + 1 < len(tags) else None
        date = git("log", "-1", "--format=%cs", tag).strip()
        out += [f'<a name="{tag}"></a>', "", f"## {tag} - {date}", ""]
        notes = tag_notes(tag)
        out += [notes, ""] if notes else [f"Release notes: {REPO_URL}/releases/tag/{tag}", ""]
        since = f" since {prev}" if prev else ""
        out += render_block(f"Commits{since}", shipped[tag], REPO_URL)
        out += render_block("Backend commits",
                            backend_commits(tag_time(prev) if prev else None, tag_time(tag)),
                            BACKEND_URL)
    sys.stdout.write("\n".join(out).rstrip("\n") + "\n")


if __name__ == "__main__":
    main()
