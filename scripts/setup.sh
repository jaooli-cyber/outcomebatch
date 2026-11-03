#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

require_command curl
require_command sha256sum
require_command wc
require_command chmod
require_command mv

mkdir -p -- "$TOOLS_DIR"
assert_within_root "$TOOLS_DIR"

if [[ ! -e "$FE_BIN" ]]; then
  tmp="$TOOLS_DIR/.fe_linux_amd64.download.$$"
  trap 'rm -f -- "$tmp"' EXIT
  printf 'Downloading Fe %s from the official release...\n' "$FE_VERSION"
  curl --fail --location --proto '=https' --tlsv1.2 \
    --retry 3 --retry-delay 2 --output "$tmp" "$FE_URL"

  actual_hash="$(sha256_of "$tmp")"
  actual_size="$(wc -c < "$tmp" | tr -d '[:space:]')"
  [[ "$actual_hash" == "$FE_SHA256" ]] || die "downloaded Fe SHA-256 mismatch: $actual_hash"
  [[ "$actual_size" == "$FE_SIZE" ]] || die "downloaded Fe size mismatch: $actual_size"
  chmod 0755 "$tmp"
  mv -- "$tmp" "$FE_BIN"
  trap - EXIT
fi

check_fe
printf 'Verified %s\n' "$FE_EXPECTED_VERSION"

if [[ -f "$DEMO_DIR/package-lock.json" ]]; then
  check_node_version
  [[ -f "$DEMO_DIR/package.json" ]] || die "demo/package.json missing"
  printf 'Installing locked demo dependencies...\n'
  (
    cd "$DEMO_DIR"
    npm ci --ignore-scripts --no-audit --no-fund
  )
else
  printf 'Demo dependency lock not present yet; skipping npm setup.\n'
fi

printf 'Setup complete. Subsequent build, test, demo and verify commands are offline.\n'
