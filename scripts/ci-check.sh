#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> [1/4] Validate skills"
python3 scripts/validate-skills.py

echo "==> [2/4] Resolve packages"
swift package resolve

echo "==> [3/4] Build (including tests)"
swift build --build-tests

echo "==> [4/4] Run tests"
swift test

echo "==> CI checks completed"
