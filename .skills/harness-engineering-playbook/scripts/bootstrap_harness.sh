#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap_harness.sh [repo_path] [--force]

Install harness templates into a target repository.

Arguments:
  repo_path   Target repository path (default: current directory)
  --force     Overwrite existing template-managed files
EOF
}

target_path="."
force=0

while [ $# -gt 0 ]; do
  case "$1" in
    --force)
      force=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [ "$target_path" != "." ]; then
        echo "error: multiple repo paths provided" >&2
        usage
        exit 1
      fi
      target_path="$1"
      ;;
  esac
  shift
done

if [ ! -d "$target_path" ]; then
  echo "error: target path does not exist: $target_path" >&2
  exit 1
fi

target_path=$(cd "$target_path" && pwd)
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
skill_dir=$(cd "$script_dir/.." && pwd)
template_dir="$skill_dir/assets/templates"

if [ ! -d "$template_dir" ]; then
  echo "error: template directory missing: $template_dir" >&2
  exit 1
fi

copy_template() {
  local relative="$1"
  local source="$template_dir/$relative"
  local destination="$target_path/$relative"

  if [ ! -f "$source" ]; then
    echo "[error] missing template: $relative" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$destination")"

  if [ -f "$destination" ] && [ "$force" -ne 1 ]; then
    echo "[skip]  $relative (exists)"
    return 0
  fi

  cp "$source" "$destination"
  echo "[write] $relative"
}

templates=(
  "AGENTS.md"
  "PLANS.md"
  "docs/ARCHITECTURE.md"
  "docs/OBSERVABILITY.md"
  "Makefile.harness"
  "scripts/audit_harness.sh"
  "scripts/harness/smoke.sh"
  "scripts/harness/test.sh"
  "scripts/harness/lint.sh"
  "scripts/harness/typecheck.sh"
  ".github/workflows/harness.yml"
)

for relative in "${templates[@]}"; do
  copy_template "$relative"
done

makefile="$target_path/Makefile"
if [ ! -f "$makefile" ]; then
  cat > "$makefile" <<'EOF'
-include Makefile.harness
EOF
  echo "[write] Makefile"
elif ! grep -Eq '(^|[[:space:]])-?include[[:space:]]+Makefile\.harness([[:space:]]|$)' "$makefile"; then
  cat >> "$makefile" <<'EOF'

# Harness engineering targets
-include Makefile.harness
EOF
  echo "[update] Makefile (+ include Makefile.harness)"
else
  echo "[skip]  Makefile already includes Makefile.harness"
fi

chmod +x \
  "$target_path/scripts/audit_harness.sh" \
  "$target_path/scripts/harness/smoke.sh" \
  "$target_path/scripts/harness/test.sh" \
  "$target_path/scripts/harness/lint.sh" \
  "$target_path/scripts/harness/typecheck.sh"

echo
echo "Bootstrap complete."
echo "Next:"
echo "  1) Customize commands in scripts/harness/*.sh"
echo "  2) Update AGENTS.md and docs/* placeholders"
echo "  3) cd \"$target_path\" && scripts/audit_harness.sh ."
