#!/usr/bin/env python3
"""
Validate skill manifests under ./skills/.

Checks:
1. Every `skills/<name>/SKILL.md` has YAML frontmatter with `name` + `description`.
2. `name` field matches the directory name.
3. All relative markdown links resolve to existing files.
4. No stray top-level `skills/SKILL.md` (would conflict with per-directory loaders).

Zero dependencies — Python 3 stdlib only.
Run from repo root:  python3 scripts/validate-skills.py
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
SKILLS_DIR = REPO / "skills"

FRONTMATTER_RE = re.compile(r"\A---\n(.*?)\n---\n", re.DOTALL)
FIELD_RE = re.compile(r"^(\w[\w-]*):\s*(.+?)\s*$", re.MULTILINE)
LINK_RE = re.compile(r"\[[^\]]*\]\(([^)]+)\)")


class Issue:
    __slots__ = ("path", "msg")

    def __init__(self, path: Path, msg: str) -> None:
        self.path = path.relative_to(REPO)
        self.msg = msg

    def __str__(self) -> str:
        return f"  {self.path}: {self.msg}"


def parse_frontmatter(content: str) -> dict[str, str] | None:
    m = FRONTMATTER_RE.match(content)
    if not m:
        return None
    return {k: v for k, v in FIELD_RE.findall(m.group(1))}


def check_frontmatter(path: Path, content: str, issues: list[Issue]) -> None:
    fm = parse_frontmatter(content)
    if fm is None:
        issues.append(Issue(path, "missing YAML frontmatter (--- ... ---)"))
        return

    if "name" not in fm:
        issues.append(Issue(path, "frontmatter missing 'name'"))
    if "description" not in fm:
        issues.append(Issue(path, "frontmatter missing 'description'"))

    if "name" in fm:
        expected = path.parent.name
        if fm["name"] != expected:
            issues.append(
                Issue(path, f"frontmatter name '{fm['name']}' != directory '{expected}'")
            )

    if "description" in fm and len(fm["description"]) < 30:
        issues.append(
            Issue(path, f"description too short ({len(fm['description'])} chars), aim ≥30")
        )


def check_links(path: Path, content: str, issues: list[Issue]) -> None:
    for link in LINK_RE.findall(content):
        if link.startswith(("http://", "https://", "mailto:", "#")):
            continue
        target = (path.parent / link.split("#", 1)[0]).resolve()
        if not target.exists():
            issues.append(Issue(path, f"broken relative link: '{link}'"))


def main() -> int:
    if not SKILLS_DIR.is_dir():
        print(f"error: {SKILLS_DIR} not found", file=sys.stderr)
        return 2

    issues: list[Issue] = []

    root_skill = SKILLS_DIR / "SKILL.md"
    if root_skill.exists():
        issues.append(
            Issue(
                root_skill,
                "root-level skills/SKILL.md conflicts with per-directory loaders; move under a named subdir",
            )
        )

    skill_files = sorted(SKILLS_DIR.glob("*/SKILL.md"))
    if not skill_files:
        print(f"error: no skills/*/SKILL.md found under {SKILLS_DIR}", file=sys.stderr)
        return 2

    for skill_md in skill_files:
        content = skill_md.read_text(encoding="utf-8")
        check_frontmatter(skill_md, content, issues)
        check_links(skill_md, content, issues)

    for extra_md in SKILLS_DIR.rglob("*.md"):
        if extra_md.name == "SKILL.md" or extra_md.parent == SKILLS_DIR:
            continue
        content = extra_md.read_text(encoding="utf-8")
        check_links(extra_md, content, issues)

    print(f"Scanned {len(skill_files)} skills under {SKILLS_DIR.relative_to(REPO)}/")
    if issues:
        print(f"\nFound {len(issues)} issue(s):")
        for issue in issues:
            print(str(issue))
        return 1
    print("OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
