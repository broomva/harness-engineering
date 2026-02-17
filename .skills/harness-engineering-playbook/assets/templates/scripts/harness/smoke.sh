#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

if [ -n "${HARNESS_SMOKE_CMD:-}" ]; then
  cd "$root_dir"
  eval "$HARNESS_SMOKE_CMD"
  exit 0
fi

if [ -f "$root_dir/Cargo.toml" ] && command -v cargo >/dev/null 2>&1; then
  cd "$root_dir"
  cargo check --quiet
  exit 0
fi

if [ -f "$root_dir/package.json" ] && command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  cd "$root_dir"
  if node -e 'const p=require("./package.json"); process.exit(p.scripts&&p.scripts.smoke?0:1)' >/dev/null 2>&1; then
    npm run -s smoke
    exit 0
  fi
  if node -e 'const p=require("./package.json"); process.exit(p.scripts&&p.scripts.build?0:1)' >/dev/null 2>&1; then
    npm run -s build
    exit 0
  fi
fi

if [ -f "$root_dir/pyproject.toml" ] && command -v pytest >/dev/null 2>&1; then
  cd "$root_dir"
  pytest -q -k smoke || pytest -q -k "not integration and not e2e"
  exit 0
fi

echo "No default smoke command detected."
echo "Set HARNESS_SMOKE_CMD or customize scripts/harness/smoke.sh."
exit 1
