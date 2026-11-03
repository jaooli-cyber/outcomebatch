#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

"$ROOT/scripts/check.sh" >/dev/null
validate_build_dir

rm -rf -- "$BUILD_DIR"
mkdir -p -- "$BUILD_DIR"

"$FE_BIN" build "$FE_PROJECT_DIR" \
  --contract OutcomeBatch \
  --backend sonatina \
  --profile release \
  --optimize 1 \
  --emit abi,bytecode,runtime-bytecode \
  --out-dir "$BUILD_DIR" \
  --color never

for artifact in OutcomeBatch.abi.json OutcomeBatch.bin OutcomeBatch.runtime.bin; do
  [[ -s "$BUILD_DIR/$artifact" ]] || die "missing build artifact: $artifact"
done

(
  cd "$BUILD_DIR"
  find . -maxdepth 1 -type f -printf '%P\n' \
    | LC_ALL=C sort \
    | while IFS= read -r artifact; do
        sha256sum -- "$artifact"
      done
) > "$BUILD_ROOT/ARTIFACT-SHA256SUMS.txt"

printf 'build=PASS\n'
