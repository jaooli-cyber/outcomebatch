# OutcomeBatch gate decision

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
- Nothing from this project may be shared with DualClear or Calldata Firewall.
- Status after this decision: frozen and abandoned; no further development.
