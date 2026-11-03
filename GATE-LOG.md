# OutcomeBatch viability gate

> **Historical record:** This file preserves the original gate ledger. For the current product state, use README.md and TEST-MATRIX.md.

- Gate window: 2026-11-03 00:30:00-03:00:00 UTC.
- Gate started on time at 2026-11-03T00:30:35Z.
- Toolchain: Fe 26.5.0 (3dab95f), isolated project-local binary.
- Initial resource check: memory and disk thresholds passed; two unrelated same-user python3 processes were each consuming approximately one CPU. Per the runbook, compilation and tests were paused while source and test authoring continued. Those processes were neither inspected nor modified.
- No remote is configured because the VPS has no GitHub authentication. This does not affect the local empirical gate.

## Evidence ledger

- 2026-11-03T00:32:54Z: first formatter pass exposed a parse error; corrected before backend compilation.
- 2026-11-03T00:44:34Z: parser and type-check passed with exit code 0.
- Source snapshot after Red Team corrections: SHA-256 327f3cc710850993a523fa4c2d35710369bf0df38653efd30769a547d9bd3483.
- Test matrix in source: 9 tests covering classification boundaries, caps, continuation and suffix gas, 256/257/1 MiB returns, exact ABI sizes, value/refund, hostile refund rollback, and reentrancy.
- Typed ABI limitation: calldata is materialized before per-item and cumulative data caps. Claims for those caps are post-ABI-decode; strict predecode bounding is not claimed.
- 2026-11-03T03:00:14Z: the gate window closed while the unrelated heavy processes were still active (two `python3` processes and one `fe` process, each consuming approximately one CPU). Only process name, resource use, state and elapsed time were observed; their arguments and paths were not inspected, and they were neither modified nor stopped.
- Backend compilation and runtime tests were therefore not run inside the gate window. Static parser/type-check evidence is not a substitute for the required empirical backend/runtime evidence.
- Final gate result: `KILL` (empirical gate not completed within its fixed window under the resource-isolation rules). This is not evidence that the design is technically impossible; it is enforcement of the predeclared viability rule.

## Post-window technical verification

- 2026-11-03T09:04Z: the user explicitly superseded the conservative
  stop-on-shared-work rule and required complete empirical verification of all
  three isolated candidates when aggregate host resources are sufficient.
- The original timebox verdict above remains part of the audit trail.
- OutcomeBatch is reopened only for a late technical viability assessment;
  evidence obtained now is labelled post-window and cannot be represented as
  having passed the original 00:30-03:00 UTC gate.
- Runner limits: one Fe job, CPUs 6-7, one compiler/test worker, nice level 15,
  idle I/O priority, serial execution, no inspection or modification of
  unrelated workloads.

### Late empirical ledger

- Commit `dd1ae89`: first late build passed its then-current 9/9 tests.
  Red Team held PLAN B because combined maximum load, canonical error
  boundaries, a gas bracket and external ABI/fork execution were not proven.
- Commit `3f6e838`: added strict canonical `Error(string)`, adversarial
  offset/length/padding vectors, 16 full-gas burners at 32 KiB total input and
  a reject/accept gas bracket.
- Commit `45fca58`: required exactly 36 bytes for `Panic(uint256)` and
  added a 37-byte negative vector.
- 2026-11-03T09:33:26Z: fresh final suite passed 11/11.
- Maximum trace: exactly 16 target reverts and one outer success.
- Gas trace: one low-gas outer rejection, one high-gas outer success and the
  expected target/oracle calls.
- Ethers 6.17.0 encoded selector `0x398f3653`. Ethereumjs-vm 10.1.3
  executed and decoded the generated runtime on Cancun; Shanghai produced the
  expected invalid opcode.

## Later technical result

- Commit: `45fca58a425c57129dba32b8a8fe46e99bfaeacc`.
- Tree: `f58d265936a25833f043d6a95568abc123318222`.
- Source SHA-256:
  `2e8269b9e3b3b5a702e0c15f14085013df6293d09d4da7646f674606419e552a`.
- Evidence: `evidence/final2-20261103T093400Z`.
- Manifest SHA-256:
  `a71b463fba7378c51b64e5fb569d3683017aeb0ea640356d7753de84c3094c31`.
- Verification-log SHA-256:
  `20e2b648ce682bf3c2538f8658f9210f85e7ff3688c7ad60213841c589457153`.
- Later technical verdict: **GO**.

This does not alter the fixed-window KILL above.
