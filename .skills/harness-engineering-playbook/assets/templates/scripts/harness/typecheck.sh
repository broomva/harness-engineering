#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

if [ -n "${HARNESS_TYPECHECK_CMD:-}" ]; then
  cd "$root_dir"
  eval "$HARNESS_TYPECHECK_CMD"
  exit 0
fi

if [ -f "$root_dir/Cargo.toml" ] && command -v cargo >/dev/null 2>&1; then
  cd "$root_dir"
  cargo check --quiet
  exit 0
fi

if [ -f "$root_dir/package.json" ] && command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  cd "$root_dir"
  if node -e 'const p=require("./package.json"); process.exit(p.scripts&&p.scripts.typecheck?0:1)' >/dev/null 2>&1; then
    npm run -s typecheck
    exit 0
  fi
  if node -e 'const p=require("./package.json"); process.exit(p.scripts&&p.scripts.tsc?0:1)' >/dev/null 2>&1; then
    npm run -s tsc
    exit 0
  fi
fi

if [ -f "$root_dir/pyproject.toml" ]; then
  cd "$root_dir"
  if command -v pyright >/dev/null 2>&1; then
    pyright
    exit 0
  fi
  if command -v mypy >/dev/null 2>&1; then
    mypy .
    exit 0
  fi
fi

echo "No default typecheck command detected."
echo "Set HARNESS_TYPECHECK_CMD or customize scripts/harness/typecheck.sh."
exit 1
