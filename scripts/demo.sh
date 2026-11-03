#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

[[ -f "$DEMO_DIR/run.mjs" ]] || die "deterministic demo missing: demo/run.mjs"
[[ -f "$DEMO_DIR/package-lock.json" ]] || die "demo dependency lock missing"
[[ -d "$DEMO_DIR/node_modules" ]] || die "demo dependencies missing; run make setup"
[[ -s "$BUILD_DIR/OutcomeBatch.abi.json" ]] || die "build artifacts missing; run make build"
[[ -s "$BUILD_DIR/OutcomeBatch.runtime.bin" ]] || die "runtime artifact missing; run make build"
check_node_version

(
  cd "$DEMO_DIR"
  OUTCOMEBATCH_ARTIFACT_DIR="$BUILD_DIR" \
    NO_COLOR=1 \
    node run.mjs
)

printf 'demo=PASS\n'
