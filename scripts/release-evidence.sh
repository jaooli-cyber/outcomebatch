#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

label="${1:-}"
run_id="${EVIDENCE_RUN:-$label}"
[[ "$label" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "invalid or missing evidence label"
[[ "$run_id" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "invalid evidence run identifier"
[[ -z "$(git -C "$ROOT" status --porcelain=v1 --untracked-files=all)" ]] || die "worktree must be clean"

commit="$(git -C "$ROOT" rev-parse HEAD)"
tree="$(git -C "$ROOT" rev-parse 'HEAD^{tree}')"
tag_object="none"
if git -C "$ROOT" rev-parse --verify --quiet "refs/tags/$label" >/dev/null; then
  [[ "$(git -C "$ROOT" cat-file -t "refs/tags/$label")" == "tag" ]] || die "evidence label must be an annotated tag"
  [[ "$(git -C "$ROOT" rev-parse "refs/tags/$label^{}")" == "$commit" ]] || die "tag does not peel to HEAD"
  tag_object="$(git -C "$ROOT" rev-parse "refs/tags/$label")"
fi

output_root="$ROOT/evidence/$run_id"
stage="$output_root/stage"
assert_within_root "$output_root"
case "$output_root" in
  "$ROOT"/evidence/*) ;;
  *) die "evidence output must remain below evidence/" ;;
esac

rm -rf -- "$output_root"
mkdir -p -- "$stage/build" "$stage/logs"

normalize_log() {
  sed -E \
    -e "s#$ROOT#.#g" \
    -e 's/\[[0-9]+\.[0-9]+s\]/[TIME]/g' \
    -e 's/[[:space:]]+$//' \
    "$1"
}

raw_build="$output_root/build.raw"
raw_test="$output_root/test.raw"
raw_demo="$output_root/demo.raw"
raw_abi="$output_root/abi.raw"

"$ROOT/scripts/build.sh" >"$raw_build" 2>&1
"$ROOT/scripts/test.sh" >"$raw_test" 2>&1
"$ROOT/scripts/demo.sh" >"$raw_demo" 2>&1
"$ROOT/scripts/abi-check.sh" >"$raw_abi" 2>&1

normalize_log "$raw_build" > "$stage/logs/build.log"
normalize_log "$raw_test" > "$stage/logs/test.log"
normalize_log "$raw_demo" > "$stage/logs/demo.log"
normalize_log "$raw_abi" > "$stage/logs/abi-check.log"
rm -f -- "$raw_build" "$raw_test" "$raw_demo" "$raw_abi"

cp -R -- "$BUILD_DIR"/. "$stage/build/"

{
  printf 'project=OutcomeBatch\n'
  printf "project_id=%s\n" "$PROJECT_ID"
  printf 'label=%s\n' "$label"
  printf 'commit=%s\n' "$commit"
  printf 'tree=%s\n' "$tree"
  printf 'tag_object=%s\n' "$tag_object"
  printf 'fe_version=%s\n' "$FE_EXPECTED_VERSION"
  printf 'fe_release_commit=%s\n' "$FE_FULL_COMMIT"
  printf 'fe_binary_sha256=%s\n' "$FE_SHA256"
  printf 'backend=sonatina\n'
  printf 'optimization=1\n'
  printf 'required_hardfork=cancun_or_later\n'
  printf 'source_date_epoch=0\n'
} > "$stage/MANIFEST.txt"

(
  cd "$ROOT"
  git ls-files | LC_ALL=C sort | while IFS= read -r path; do
    hash="$(sha256sum -- "$path" | awk '{print $1}')"
    printf '%s  %s\n' "$hash" "$path"
  done
) > "$stage/SOURCE-SHA256SUMS.txt"

(
  cd "$stage"
  find build -type f -printf '%p\n' | LC_ALL=C sort | while IFS= read -r path; do
    sha256sum -- "$path"
  done
) > "$stage/ARTIFACT-SHA256SUMS.txt"

(
  cd "$stage"
  find . -type f ! -name SHA256SUMS -printf '%P\n' | LC_ALL=C sort | while IFS= read -r path; do
    sha256sum -- "$path"
  done
) > "$stage/SHA256SUMS"

bundle_name="${PROJECT_ID}-evidence-$label.tar.gz"
bundle="$output_root/$bundle_name"
(
  cd "$stage"
  tar --sort=name --mtime='@0' --owner=0 --group=0 --numeric-owner \
    --mode=u+rwX,go+rX,go-w \
    -cf - . | gzip -n > "$bundle"
)
(
  cd "$output_root"
  sha256sum -- "$bundle_name" > "$bundle_name.sha256"
)

(
  cd "$stage"
  sha256sum -c SHA256SUMS >/dev/null
  sha256sum -c ARTIFACT-SHA256SUMS.txt >/dev/null
)
(
  cd "$ROOT"
  sha256sum -c "$stage/SOURCE-SHA256SUMS.txt" >/dev/null
)

printf 'evidence_commit=%s\n' "$commit"
printf 'evidence_tree=%s\n' "$tree"
printf 'evidence_bundle=%s\n' "$bundle"
printf 'evidence_bundle_sha256=%s\n' "$(sha256_of "$bundle")"
printf 'evidence=PASS\n'
