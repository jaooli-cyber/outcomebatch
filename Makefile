SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

REQUIRE_DEMO ?= 1
CANDIDATE_TAG ?=
export REQUIRE_DEMO CANDIDATE_TAG

.PHONY: help setup check build test demo abi-check verify evidence candidate clean

help:
	@printf '%s\n' \
	  'OutcomeBatch reproducible commands:' \
	  '  make setup       download and verify pinned tools/dependencies (network)' \
	  '  make check       verify the installed toolchain (offline)' \
	  '  make build       produce clean Fe artifacts (offline)' \
	  '  make test        run the Fe suite serially (offline)' \
	  '  make demo        run the deterministic Cancun demo (offline)' \
	  '  make abi-check   verify ABI, selector and EIP-170 bound (offline)' \
	  '  make verify      run all offline verification' \
	  '  make evidence LABEL=name  create a deterministic evidence bundle' \
	  '  make candidate CANDIDATE_TAG=tag  verify an annotated candidate tag'

setup:
	@./scripts/setup.sh

check:
	@./scripts/check.sh

build:
	@./scripts/build.sh

test:
	@./scripts/test.sh

demo: build
	@./scripts/demo.sh

abi-check:
	@./scripts/abi-check.sh

verify:
	@./scripts/verify.sh

evidence:
	@./scripts/release-evidence.sh "$${LABEL:?set LABEL to a stable release label}"

candidate:
	@./scripts/candidate.sh

clean:
	@./scripts/clean.sh
