#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/audit_harness.sh [repo_path]

Audit a repository for baseline harness engineering artifacts.
EOF
}

target_path="${1:-.}"
if [ "$target_path" = "-h" ] || [ "$target_path" = "--help" ]; then
  usage
  exit 0
fi

if [ ! -d "$target_path" ]; then
  echo "error: target path does not exist: $target_path" >&2
  exit 1
fi

target_path=$(cd "$target_path" && pwd)
failures=0

ok() {
  echo "[ok]      $1"
}

fail() {
  echo "[missing] $1"
  failures=$((failures + 1))
}

check_file() {
  local relative="$1"
  if [ -f "$target_path/$relative" ]; then
    ok "$relative"
  else
    fail "$relative"
  fi
}

check_contains() {
  local relative="$1"
  local pattern="$2"
  local label="$3"
  local full="$target_path/$relative"

  if [ ! -f "$full" ]; then
    fail "$label (file missing: $relative)"
    return
  fi

  if grep -Eq "$pattern" "$full"; then
    ok "$label"
  else
    fail "$label"
  fi
}

echo "Auditing harness artifacts in: $target_path"
echo

check_file "AGENTS.md"
check_file "PLANS.md"
check_file "docs/ARCHITECTURE.md"
check_file "docs/OBSERVABILITY.md"
check_file "Makefile.harness"
check_file "scripts/audit_harness.sh"
check_file "scripts/harness/smoke.sh"
check_file "scripts/harness/test.sh"
check_file "scripts/harness/lint.sh"
check_file "scripts/harness/typecheck.sh"
check_file ".github/workflows/harness.yml"

echo
check_contains "AGENTS.md" "Harness Commands" "AGENTS.md: Harness Commands section"
check_contains "AGENTS.md" "Execution Plans" "AGENTS.md: Execution Plans section"
check_contains "docs/ARCHITECTURE.md" "Boundaries" "ARCHITECTURE.md: boundary guidance"
check_contains "docs/OBSERVABILITY.md" "Required Event Fields" "OBSERVABILITY.md: required fields"
check_contains "Makefile.harness" "^smoke:" "Makefile.harness: smoke target"
check_contains "Makefile.harness" "^test:" "Makefile.harness: test target"
check_contains "Makefile.harness" "^lint:" "Makefile.harness: lint target"
check_contains "Makefile.harness" "^typecheck:" "Makefile.harness: typecheck target"
check_contains "Makefile.harness" "^ci:" "Makefile.harness: ci target"
check_contains ".github/workflows/harness.yml" "make ci" "CI workflow executes make ci"

echo
if [ "$failures" -gt 0 ]; then
  echo "Harness audit failed: $failures issue(s) detected."
  exit 1
fi

echo "Harness audit passed."
