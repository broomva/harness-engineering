#!/usr/bin/env bash
set -euo pipefail

root_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
cd "$root_dir"

failures=0

check_exists() {
  local rel="$1"
  if [ -e "$rel" ]; then
    echo "[ok]      $rel"
  else
    echo "[missing] $rel"
    failures=$((failures + 1))
  fi
}

check_not_contains() {
  local rel="$1"
  local pattern="$2"
  local label="$3"
  if [ ! -f "$rel" ]; then
    echo "[missing] $label (file missing: $rel)"
    failures=$((failures + 1))
    return
  fi
  if grep -En "$pattern" "$rel" >/dev/null 2>&1; then
    echo "[drift]   $label"
    failures=$((failures + 1))
  else
    echo "[ok]      $label"
  fi
}

echo "Entropy check: $root_dir"
echo

check_exists "AGENTS.md"
check_exists "PLANS.md"
check_exists "docs/ARCHITECTURE.md"
check_exists "docs/OBSERVABILITY.md"
check_exists "Makefile.harness"

check_not_contains "AGENTS.md" "<project-name>|<runtime>|<entrypoints>" "AGENTS.md placeholders removed"
check_not_contains "docs/ARCHITECTURE.md" "^# Architecture$" "ARCHITECTURE customized"
check_not_contains "docs/OBSERVABILITY.md" "^# Observability$" "OBSERVABILITY customized"

echo
if [ "$failures" -gt 0 ]; then
  echo "Entropy check failed: $failures issue(s)."
  exit 1
fi
echo "Entropy check passed."
