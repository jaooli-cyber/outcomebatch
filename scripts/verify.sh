#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

"$ROOT/scripts/check.sh"
"$ROOT/scripts/build.sh"
"$ROOT/scripts/test.sh"

if [[ "${REQUIRE_DEMO:-1}" == "1" ]]; then
  "$ROOT/scripts/demo.sh"
elif [[ -f "$DEMO_DIR/run.mjs" ]]; then
  "$ROOT/scripts/demo.sh"
else
  printf 'demo=SKIP (REQUIRE_DEMO=0)\n'
fi

if [[ -f "$DEMO_DIR/package.json" ]]; then
  "$ROOT/scripts/abi-check.sh"
else
  [[ "${REQUIRE_DEMO:-1}" == "0" ]] || die "demo package required for ABI verification"
  printf 'abi_check=SKIP (REQUIRE_DEMO=0)\n'
fi

printf 'verify=PASS\n'
