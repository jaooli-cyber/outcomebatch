#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

[[ -f "$FE_PROJECT_DIR/fe.toml" ]] || die "Fe manifest missing: $FE_PROJECT_DIR/fe.toml"
[[ -f "$FE_PROJECT_DIR/src/lib.fe" ]] || die "Fe source missing: $FE_PROJECT_DIR/src/lib.fe"
check_fe

if [[ -f "$DEMO_DIR/package-lock.json" ]]; then
  check_node_version
  [[ -f "$DEMO_DIR/package.json" ]] || die "demo/package.json missing"
  [[ -d "$DEMO_DIR/node_modules" ]] || die "demo dependencies missing; run make setup"
  (
    cd "$DEMO_DIR"
    npm ls --all --offline >/dev/null
  )
fi

printf 'toolchain_version=%s\n' "$FE_EXPECTED_VERSION"
printf 'toolchain_commit=%s\n' "$FE_FULL_COMMIT"
printf 'toolchain_sha256=%s\n' "$FE_SHA256"
printf 'toolchain_size=%s\n' "$FE_SIZE"

if [[ -f "$DEMO_DIR/package-lock.json" ]]; then
  printf 'node_version=%s\n' "$(node --version)"
  printf 'npm_version=%s\n' "$(npm --version)"
fi

printf 'check=PASS\n'
