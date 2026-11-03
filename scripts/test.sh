#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

"$ROOT/scripts/check.sh" >/dev/null
"$FE_BIN" fmt --check "$FE_PROJECT_DIR/src/lib.fe"
git -C "$ROOT" diff --check

"$FE_BIN" test "$FE_PROJECT_DIR" \
  --backend sonatina \
  --profile test \
  --optimize 1 \
  --jobs 1 \
  --color never

printf 'test=PASS\n'
