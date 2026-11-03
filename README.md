# OutcomeBatch

Contest registration: **FE-016**.

OutcomeBatch is a bounded diagnostic batch executor written in Fe. It executes every admitted EVM call exactly once, continues after individual failures, and returns compact reports without copying unbounded return data.

Its purpose is observability under adversarial failure, not atomic multicall. A target may revert, burn its forwarded gas, return malformed standard errors, or produce a return-data bomb; OutcomeBatch preserves enough gas for later calls and for the final report.

## Why this is a Fe project

The core behavior is implemented in Fe and exercises Fe 26.5.0 primitives directly:

- RawCallOutcome and ephemeral ReturnData for raw EVM outcomes;
- a 256-byte MemBuffer capture bound per call;
- MemVec and dynamic ABI output for structured reports;
- has_min_gas plus an EIP-150-aware suffix reserve;
- Wei for exact funding and failed-call refunds;
- TSlot transient storage for a Cancun reentrancy guard;
- typed custom errors and a stable execute ABI.

This is not a wrapper around atomic multicall. The Fe contract owns admission, execution, bounded capture, conservative classification, refund policy, and report construction.

## Quick start

Requirements: Linux x86-64, curl, sha256sum, make, Node.js 20.19 or newer, and npm.

    make setup
    make demo

The setup step downloads the official Fe 26.5.0 Linux binary, verifies its SHA-256, and installs the pinned demo dependencies. The demo then builds fresh artifacts, deploys OutcomeBatch on an in-memory Cancun EVM, sends a non-empty adversarial batch, decodes every report with Ethers, and compares the normalized result with a committed golden.

For the complete local check:

    make verify

The verification path runs the Fe tests serially, checks the ABI and runtime-size bound, and runs the external EVM demo. After make setup, build, test, demo, and verification do not require network access.

## Bounds

| Property | Bound |
|---|---:|
| Calls per batch | 16 |
| Calldata per call | 4,096 bytes |
| Aggregate calldata | 32,768 bytes |
| Copied return-data prefix | 256 bytes per call |
| Target environment | Cancun or later |

These input limits are product bounds enforced after typed ABI decoding. They are not pre-decode calldata bounds and OutcomeBatch is not a calldata firewall.

## Report classes

| Class | Meaning |
|---:|---|
| 0 | successful EVM CALL |
| 1 | failed CALL with empty returndata |
| 2 | revert shorter than four bytes |
| 3 | canonical Error(string) layout |
| 4 | exact 36-byte Panic(uint256) |
| 5 | other selector-bearing revert |
| 6 | malformed Error(string) or Panic payload |

Classification is deliberately conservative. A canonical Error(string) report describes ABI layout; it does not claim that the string bytes are valid UTF-8. A successful CALL does not prove that the target contains code.

The prefix_hash field is Keccak-256 of the copied prefix. When hash_is_complete is false, it is not a hash of the full return value.

## Funding and failure semantics

The caller supplies the exact sum of all requested values. Value belonging to failed target calls is refunded after the batch. If the caller rejects that refund, the complete transaction reverts, including earlier target effects.

requested_gas is the amount requested from CALL. EVM value-transfer rules may add a stipend when value is non-zero, so it is not an absolute cap on all gas available to a callee. The reserve constants are tested safety parameters for the pinned toolchain and fork, not universal minimum-gas claims.

## Project map

- src/lib.fe — contract, adversarial test targets, and Fe integration tests;
- demo/ — independent Ethers and EthereumJS deployment/decoding demo;
- scripts/ and Makefile — pinned reproducible commands;
- DESIGN.md — algorithms, ABI, gas recurrence, and report semantics;
- SECURITY.md — threat model, guarantees, and explicit limitations;
- PROVENANCE.md — build-window history, reused material, and AI disclosure;
- JUDGING.md — concise guide to the contest criteria;
- SUBMISSION.md — public, non-secret submission fields and candidate-tag procedure.

## Reproducibility

The repository pins Fe 26.5.0, release commit 3dab95f8eebdccf9a2382bb59a33f7bbd03540ca, and the official Linux binary SHA-256:

    3732fbe8a6e9d2ea3925d02d0e3a1478bc1e01d742c2be75d3ea7300c46c45f0

Candidate evidence is generated from a clean tree and contains source hashes, artifact hashes, normalized verification output, ABI, bytecode, runtime bytecode, and an EIP-170 size check.

## Scope

OutcomeBatch is a contest prototype and has not received a production security audit. It intentionally does not provide target allowlists, pre-decode parsing, full return-data hashing, arbitrary string decoding, code-existence checks, universal gas calibration, deployment automation, or a user interface.

See SECURITY.md before integrating it.

## License

Apache-2.0. See LICENSE.
