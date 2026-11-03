#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

tag="${CANDIDATE_TAG:-}"
[[ "$tag" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "set CANDIDATE_TAG to the annotated submission tag"
[[ -z "$(git -C "$ROOT" status --porcelain=v1 --untracked-files=all)" ]] || die "candidate worktree must be clean"

head="$(git -C "$ROOT" rev-parse HEAD)"
[[ "$(git -C "$ROOT" cat-file -t "refs/tags/$tag" 2>/dev/null || true)" == "tag" ]] || die "candidate tag must be annotated"
[[ "$(git -C "$ROOT" rev-parse "refs/tags/$tag^{}")" == "$head" ]] || die "candidate tag does not peel to HEAD"

for forbidden in \
  'ghp_[A-Za-z0-9]+' \
  'github_pat_[A-Za-z0-9_]+' \
  'BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY' \
  'TODO|FIXME|TBD|PLACEHOLDER|CHANGEME' \
  "[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}"; do
  if git -C "$ROOT" grep -nEI "$forbidden" -- . ':!scripts/candidate.sh'; then
    die "candidate contains forbidden marker or secret-like material"
  fi
done

"$ROOT/scripts/verify.sh"

candidate_root="$ROOT/.candidate"
clone="$candidate_root/clean-clone"
assert_within_root "$candidate_root"
[[ "$candidate_root" == "$ROOT/.candidate" ]] || die "invalid candidate workspace"
rm -rf -- "$candidate_root"
mkdir -p -- "$candidate_root"

git clone --no-local --quiet "$ROOT" "$clone"
git -C "$clone" checkout --quiet "$tag"
[[ "$(git -C "$clone" rev-parse HEAD)" == "$head" ]] || die "clean clone commit mismatch"

(
  cd "$clone"
  make setup
  REQUIRE_DEMO=1 make verify
  EVIDENCE_RUN=pass1 ./scripts/release-evidence.sh "$tag"
  EVIDENCE_RUN=pass2 ./scripts/release-evidence.sh "$tag"
)

bundle_name="OutcomeBatch-evidence-$tag.tar.gz"
bundle1="$clone/evidence/pass1/$bundle_name"
bundle2="$clone/evidence/pass2/$bundle_name"
cmp -- "$bundle1" "$bundle2" || die "independent evidence generations differ"

release_dir="$ROOT/evidence/release"
assert_within_root "$release_dir"
rm -rf -- "$release_dir"
mkdir -p -- "$release_dir"
cp -- "$bundle1" "$release_dir/$bundle_name"
(
  cd "$release_dir"
  sha256sum -- "$bundle_name" > "$bundle_name.sha256"
)
cp -- "$clone/evidence/pass1/stage/SOURCE-SHA256SUMS.txt" "$release_dir/"
cp -- "$clone/evidence/pass1/stage/ARTIFACT-SHA256SUMS.txt" "$release_dir/"
cp -- "$clone/evidence/pass1/stage/MANIFEST.txt" "$release_dir/"

printf 'candidate_tag=%s\n' "$tag"
printf 'candidate_commit=%s\n' "$head"
printf 'candidate_evidence_sha256=%s\n' "$(sha256_of "$release_dir/$bundle_name")"
printf 'candidate=PASS\n'
