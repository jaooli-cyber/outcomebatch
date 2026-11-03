#!/usr/bin/env bash
set -euo pipefail

ROOT="$(unset CDPATH; cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TOOLS_DIR="$ROOT/.contest-tools"
FE_BIN="$TOOLS_DIR/fe_linux_amd64"
FE_PROJECT_DIR="$ROOT"
BUILD_ROOT="$ROOT/.build"
BUILD_DIR="$ROOT/.build/fe"
DEMO_DIR="$ROOT/demo"
PROJECT_ID="FE-016"
CANDIDATE_TAG_EXPECTED="fe-016-submission-v1"

FE_VERSION="26.5.0"
FE_FULL_COMMIT="3dab95f8eebdccf9a2382bb59a33f7bbd03540ca"
FE_EXPECTED_VERSION="fe 26.5.0 (3dab95f)"
FE_SHA256="3732fbe8a6e9d2ea3925d02d0e3a1478bc1e01d742c2be75d3ea7300c46c45f0"
FE_SIZE="54195184"
FE_URL="https://github.com/argotorg/fe/releases/download/v26.5.0/fe_linux_amd64"

export LC_ALL=C
export TZ=UTC
export SOURCE_DATE_EPOCH=0

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

sha256_of() {
  sha256sum -- "$1" | awk '{print $1}'
}

assert_within_root() {
  local path="$1"
  case "$path" in
    "$ROOT"/*) ;;
    *) die "path escapes repository root: $path" ;;
  esac
}

check_fe() {
  require_command sha256sum
  [[ -f "$FE_BIN" && -x "$FE_BIN" ]] || die "pinned Fe compiler missing; run make setup"
  [[ ! -L "$FE_BIN" ]] || die "refusing symlinked Fe compiler: $FE_BIN"

  local actual_hash actual_size actual_version
  actual_hash="$(sha256_of "$FE_BIN")"
  actual_size="$(wc -c < "$FE_BIN" | tr -d '[:space:]')"
  actual_version="$($FE_BIN --version)"

  [[ "$actual_hash" == "$FE_SHA256" ]] || die "Fe SHA-256 mismatch: $actual_hash"
  [[ "$actual_size" == "$FE_SIZE" ]] || die "Fe size mismatch: $actual_size"
  [[ "$actual_version" == "$FE_EXPECTED_VERSION" ]] || die "Fe version mismatch: $actual_version"
}

check_node_version() {
  require_command node
  require_command npm
  node -e '
    const [major, minor] = process.versions.node.split(".").map(Number);
    if (major < 20 || (major === 20 && minor < 19)) {
      console.error(`Node >=20.19 is required; found ${process.versions.node}`);
      process.exit(1);
    }
  '
}

validate_build_dir() {
  assert_within_root "$BUILD_DIR"
  case "$BUILD_DIR" in
    "$ROOT"/.build/*) ;;
    *) die "BUILD_DIR must remain below $ROOT/.build" ;;
  esac
}
