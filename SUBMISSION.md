# Submission record

This file records the public, non-secret fields for the Fe Builders Challenge submission. The private submission code and registered contact email are intentionally excluded from the repository.

## Project identity

- Project ID: FE-016
- Final project name: OutcomeBatch
- Public repository: https://github.com/jaooli-cyber/outcomebatch
- Candidate tag: fe-016-submission-v1

The authoritative 40-character submission SHA is the commit peeled from the annotated candidate tag:

    git rev-list -n 1 fe-016-submission-v1

## One-sentence pitch

OutcomeBatch is a Fe batch executor that survives individual EVM failures and return-data bombs, returning bounded, canonically classified reports while reserving gas for every later call and the final result.

## Exact Fe toolchain version

fe 26.5.0 (3dab95f), release commit 3dab95f8eebdccf9a2382bb59a33f7bbd03540ca. Official Linux x86-64 binary SHA-256: 3732fbe8a6e9d2ea3925d02d0e3a1478bc1e01d742c2be75d3ea7300c46c45f0.

## Fe-specific technical highlight

OutcomeBatch implements bounded best-effort EVM execution directly in Fe using RawCallOutcome, ephemeral ReturnData inspection, a pre-touched 256-byte MemBuffer, MemVec reports, an EIP-150-aware suffix-gas recurrence, typed Wei funding, TSlot transient reentrancy protection, and conservative standard-error classification. It preserves full RETURNDATASIZE while copying at most 256 bytes, distinguishes canonical Error(string), exact Panic(uint256), custom, and malformed failures, and explicitly scopes prefix_hash with hash_is_complete. The 14-case Fe suite and independent Ethers/EthereumJS demo deploy real creation bytecode, compare all eleven report fields, and prove that a 1 MiB return-data bomb is reported with only a 256-byte copy.

## Reproducible demo instructions

On Linux x86-64 with curl, sha256sum, make, Node.js 20.19 or newer, and npm:

    git clone https://github.com/jaooli-cyber/outcomebatch.git
    cd outcomebatch
    git checkout fe-016-submission-v1
    make setup
    make demo

The demo builds fresh Fe artifacts, deploys creation bytecode in an in-memory Cancun EVM, verifies the installed runtime byte-for-byte, executes a 32-byte success, a 0xdeadbeef custom revert, and a 1 MiB return-data bomb, decodes every CallReport field through Ethers, compares them with the committed golden, and confirms the expected Shanghai invalid-opcode failure. Success ends with "OutcomeBatch external ABI demo: PASS".

Run make verify for the complete 14-test Fe suite, frozen ABI and selector checks, the independent demo, and the EIP-170 runtime bound.

## Pre-existing work, reused code, and AI assistance

Before the build window, work was limited to research, specification, non-compilable pseudocode, test planning, threat modelling, and Red Team analysis kept outside this repository. No precontest implementation or pseudocode was copied into the entry. All Fe source, tests, scripts, fixtures, documentation, and build evidence in this repository were created after November 3, 2026 at 00:00 UTC.

No third-party application code was copied. OutcomeBatch depends on Fe core and standard libraries from the pinned compiler; the independently pinned Ethers/EthereumJS packages are used only by the external demo.

AI assisted research, architecture, Fe API review, implementation support, adversarial test design, failure diagnosis, documentation, reproducibility work, and technical, algorithmic, security, and contest Red Team review. AI output was not accepted as evidence by itself, and the human entrant remains responsible for the submission.

## Submission confirmation

At the tagged commit, confirm:

- public GitHub repository;
- Apache-2.0 OSI-approved license;
- Fe manifest;
- README documentation and build/test instructions;
- automated Fe tests and external EVM demo;
- deterministic evidence manifest and checksums.

The repository must remain private until the entrant explicitly authorizes publication. Before submitting the form, independently verify that the repository is public and that the candidate tag, workflow, release assets, and full commit SHA all match.
