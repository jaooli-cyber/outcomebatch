#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

validate_build_dir
assert_within_root "$ROOT/.candidate"

rm -rf -- "$BUILD_ROOT" "$ROOT/.candidate"

if [[ -d "$DEMO_DIR/node_modules" ]]; then
  assert_within_root "$DEMO_DIR/node_modules"
  rm -rf -- "$DEMO_DIR/node_modules"
fi

printf 'clean=PASS\n'
