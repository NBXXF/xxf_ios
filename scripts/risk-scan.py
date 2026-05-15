#!/usr/bin/env python3
"""
Lightweight static risk scanner for xxf_ios.

Outputs:
- Markdown report: reports/risk-report.md
- Exit code: always 0 (informational), suitable for CI artifact generation.
"""
from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

REPO = Path(__file__).resolve().parent.parent
SCAN_DIRS = ["Sources", "Tests", "Package.swift"]
REPORT_DIR = REPO / "reports"
REPORT_PATH = REPORT_DIR / "risk-report.md"


@dataclass(frozen=True)
class Rule:
    id: str
    severity: str
    pattern: re.Pattern[str]
    note: str


RULES: list[Rule] = [
    Rule("R001", "HIGH", re.compile(r"\bfatalError\("), "Runtime crash path should be validated for release usage."),
    Rule("R002", "HIGH", re.compile(r"\btry!\b"), "Forced try can crash on recoverable failures."),
    Rule("R003", "MEDIUM", re.compile(r"\bas!\b"), "Forced cast may crash when type assumptions drift."),
    Rule("R004", "MEDIUM", re.compile(r"DispatchQueue\.main\.sync"), "Potential deadlock or UI stall risk."),
    Rule("R005", "MEDIUM", re.compile(r"nonisolated\(unsafe\)|@unchecked\s+Sendable"), "Concurrency safety bypass requires careful audit."),
    Rule("R006", "LOW", re.compile(r"TODO|FIXME|HACK|XXX"), "Unresolved marker in production code path."),
]

EXCLUDE_SUBSTRINGS = [
    "/.build/",
    "/.git/",
    "/skills/",
    "/reports/",
]

IGNORE_PATTERNS: list[re.Pattern[str]] = [
    re.compile(r"init\??\(coder:.*fatalError", re.IGNORECASE),
    re.compile(r"has not been implemented", re.IGNORECASE),
]


@dataclass
class Hit:
    rule: Rule
    relpath: str
    line_no: int
    line: str


def iter_files() -> Iterable[Path]:
    for item in SCAN_DIRS:
        p = REPO / item
        if p.is_file():
            yield p
            continue
        if p.is_dir():
            for f in p.rglob("*.swift"):
                yield f


def should_skip(path: Path) -> bool:
    s = str(path)
    return any(x in s for x in EXCLUDE_SUBSTRINGS)


def scan() -> list[Hit]:
    hits: list[Hit] = []
    for file_path in iter_files():
        if should_skip(file_path):
            continue
        try:
            content = file_path.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        lines = content.splitlines()
        for idx, line in enumerate(lines, start=1):
            stripped = line.strip()
            if stripped.startswith("//"):
                continue
            for rule in RULES:
                if rule.pattern.search(line):
                    if any(p.search(line) for p in IGNORE_PATTERNS):
                        continue
                    hits.append(
                        Hit(
                            rule=rule,
                            relpath=str(file_path.relative_to(REPO)),
                            line_no=idx,
                            line=line.strip(),
                        )
                    )
    return hits


def render_markdown(hits: list[Hit]) -> str:
    by_severity: dict[str, list[Hit]] = {"HIGH": [], "MEDIUM": [], "LOW": []}
    for h in hits:
        by_severity[h.rule.severity].append(h)

    total = len(hits)
    lines: list[str] = []
    lines.append("# Risk Scan Report")
    lines.append("")
    lines.append(f"Generated from `{REPO.name}`.")
    lines.append("")
    lines.append(f"- Total findings: **{total}**")
    lines.append(f"- HIGH: **{len(by_severity['HIGH'])}**")
    lines.append(f"- MEDIUM: **{len(by_severity['MEDIUM'])}**")
    lines.append(f"- LOW: **{len(by_severity['LOW'])}**")
    lines.append("")

    for sev in ("HIGH", "MEDIUM", "LOW"):
        items = by_severity[sev]
        lines.append(f"## {sev}")
        lines.append("")
        if not items:
            lines.append("No findings.")
            lines.append("")
            continue

        lines.append("| Rule | File | Line | Snippet |")
        lines.append("|---|---|---:|---|")
        for h in items:
            snippet = h.line.replace("|", "\\|")
            lines.append(f"| {h.rule.id} | `{h.relpath}` | {h.line_no} | `{snippet}` |")
        lines.append("")

    lines.append("## Rule Notes")
    lines.append("")
    for r in RULES:
        lines.append(f"- `{r.id}` ({r.severity}): {r.note}")

    return "\n".join(lines) + "\n"


def main() -> int:
    hits = scan()
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_PATH.write_text(render_markdown(hits), encoding="utf-8")
    print(f"Wrote risk report: {REPORT_PATH.relative_to(REPO)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
