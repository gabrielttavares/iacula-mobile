#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

status=0

check_pattern() {
  local pattern="$1"
  local description="$2"
  local paths=(
    "lib/features/home/presentation"
    "lib/features/settings/presentation"
    "lib/features/profile/presentation"
    "lib/features/plan_of_life/presentation"
    "lib/features/premium/presentation"
    "lib/features/liturgia_diaria/presentation"
    "lib/features/search/presentation"
    "lib/features/favorites/presentation"
    "lib/features/auth/presentation"
  )
  if rg -n "$pattern" "${paths[@]}" --glob '*.dart' >/tmp/ui_std_check.out; then
    echo "[FAIL] $description"
    cat /tmp/ui_std_check.out
    status=1
  else
    echo "[OK] $description"
  fi
}

check_pattern 'showCupertinoModalPopup\s*\(' 'No raw showCupertinoModalPopup in feature presentation code'
check_pattern 'showCupertinoDialog\s*\(' 'No raw showCupertinoDialog in feature presentation code'
check_pattern 'CupertinoTextField\s*\(' 'No raw CupertinoTextField in feature presentation code'

if [[ $status -ne 0 ]]; then
  echo "UI standards check failed."
  exit 1
fi

echo "UI standards check passed."
