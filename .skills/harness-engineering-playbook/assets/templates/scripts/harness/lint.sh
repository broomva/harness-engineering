#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

if [ -n "${HARNESS_LINT_CMD:-}" ]; then
  cd "$root_dir"
  eval "$HARNESS_LINT_CMD"
  exit 0
fi

if [ -f "$root_dir/Cargo.toml" ] && command -v cargo >/dev/null 2>&1; then
  cd "$root_dir"
  cargo clippy --all-targets --all-features -- -D warnings
  exit 0
fi

if [ -f "$root_dir/package.json" ] && command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  cd "$root_dir"
  if node -e 'const p=require("./package.json"); process.exit(p.scripts&&p.scripts.lint?0:1)' >/dev/null 2>&1; then
    npm run -s lint
    exit 0
  fi
fi

if [ -f "$root_dir/pyproject.toml" ]; then
  cd "$root_dir"
  if command -v ruff >/dev/null 2>&1; then
    ruff check .
    exit 0
  fi
  if command -v flake8 >/dev/null 2>&1; then
    flake8 .
    exit 0
  fi
fi

echo "No default lint command detected."
echo "Set HARNESS_LINT_CMD or customize scripts/harness/lint.sh."
exit 1
