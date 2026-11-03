# OutcomeBatch gate decision

> **Historical record:** This file preserves the original gate timebox and later reassessment. For the current product state, use README.md and TEST-MATRIX.md.

## Verdict

`KILL`

The fixed gate window closed at 2026-11-03T03:00:00Z without the required backend compilation and runtime evidence. The candidate must therefore be abandoned under the predeclared rule; it does not advance automatically as a Plan B and no implementation work may continue in this project.

This verdict records an incomplete empirical gate caused by resource contention under the isolation runbook. It is not a demonstrated technical failure of OutcomeBatch.

## Evidence obtained in-window

- Gate opened at 2026-11-03T00:30:35Z and closed at 2026-11-03T03:00:00Z.
- Fe 26.5.0, compiler commit `3dab95f`, project-local toolchain.
- Parser and type-check passed with exit code 0 at 2026-11-03T00:44:34Z.
- Source commit: `a9796be421d8cbe8a2198b02bc47d9c8db84400a`.
- Source SHA-256: `327f3cc710850993a523fa4c2d35710369bf0df38653efd30769a547d9bd3483`.
- Nine authored tests cover classification boundaries, caps, continuation and suffix gas, return-data bombs and prefix boundaries, ABI sizes, value/refund behavior, hostile refund rollback, and reentrancy.
- At 2026-11-03T03:00:14Z, unrelated CPU-heavy work remained active. It was observed only through process name and aggregate resource fields, and was not inspected, modified or stopped.

## Missing mandatory evidence

- No backend compilation completed inside the gate window.
- No runtime test completed inside the gate window.
- No empirical gas-floor calibration or max-batch execution evidence was obtained.
- No clean demonstration of return-data behavior or rollback/refund behavior ran on the target backend.

## Residual risks

- Typed ABI materializes input before the per-item and aggregate byte caps; strict predecode bounding is not demonstrated.
- The gas-reserve recurrence is statically reasoned but its constants remain uncalibrated empirically.
- Partial-continuation semantics depend on the caller accepting the final push refund; refund rejection intentionally reverts the whole batch.
- A successful raw EVM call proves the CALL success bit, not that the target address contains code.

## Isolation and disposition

- No GitHub remote is configured.
- OutcomeBatch remains in its own directory, Git history, toolchain, source, tests and evidence ledger.
- Nothing from this project may be shared with other contest entries.
- Status after this decision: frozen and abandoned; no further development.

## Later user-authorized technical reassessment

At 2026-11-03T09:04Z the user required complete empirical checks of all three
candidates and authorized low-priority work alongside unrelated shared-host
jobs when aggregate resources are sufficient. This does not rewrite the
original timebox result. The repository is reopened solely to determine
whether the design is technically viable.

## Later technical verdict

**GO**

The accepted source is commit
`45fca58a425c57129dba32b8a8fe46e99bfaeacc`, tree
`f58d265936a25833f043d6a95568abc123318222`, built with Fe 26.5.0.
Fresh evidence establishes build exit 0, 11/11 tests, strict standard-error
boundaries, a 16-call/32-KiB exhaustion workload, a 600k-reject/1.2m-accept
gas bracket, capped return bombs, refund/reentrancy behavior and external ABI
execution on Cancun with the expected Shanghai negative control.

Evidence: `evidence/final2-20261103T093400Z`.
Manifest SHA-256:
`a71b463fba7378c51b64e5fb569d3683017aeb0ea640356d7753de84c3094c31`.
Verification-log SHA-256:
`20e2b648ce682bf3c2538f8658f9210f85e7ff3688c7ad60213841c589457153`.

## Problems resolved

1. Canonical-error validation now requires offset 32, exact padded length,
   zero padding and exactly 36 panic bytes.
2. The final trace combines maximum count, total input and gas exhaustion.
3. The suite proves both rejection and acceptance around a measured gas
   bracket.
4. An isolated ethers/ethereumjs harness checks generated ABI, bytecode and
   fork behavior.

## Accepted S2 constraints

Typed input caps run after ABI materialization; raw-call success does not prove
target code; refund rejection atomically rolls back; Cancun+ is mandatory;
gas constants are not a universal optimum; long returns hash only their copied
prefix and expose `hash_is_complete = false`.

No S0 or S1 remains open. OutcomeBatch is eligible for selection, but GO does
not authorize simultaneous development. No GitHub remote is configured.
