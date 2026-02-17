#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

if [ -n "${HARNESS_TEST_CMD:-}" ]; then
  cd "$root_dir"
  eval "$HARNESS_TEST_CMD"
  exit 0
fi

if [ -f "$root_dir/Cargo.toml" ] && command -v cargo >/dev/null 2>&1; then
  cd "$root_dir"
  cargo test --quiet
  exit 0
fi

if [ -f "$root_dir/package.json" ] && command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  cd "$root_dir"
  if node -e 'const p=require("./package.json"); process.exit(p.scripts&&p.scripts.test?0:1)' >/dev/null 2>&1; then
    npm run -s test
    exit 0
  fi
fi

if [ -f "$root_dir/pyproject.toml" ] && command -v pytest >/dev/null 2>&1; then
  cd "$root_dir"
  pytest -q
  exit 0
fi

echo "No default test command detected."
echo "Set HARNESS_TEST_CMD or customize scripts/harness/test.sh."
exit 1
