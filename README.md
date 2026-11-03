# OutcomeBatch

OutcomeBatch is a bounded payable batch executor written in Fe. It continues
after individual call failures and returns a compact structured report.

Work here began after 2026-11-03 00:00:00 UTC. Precontest research and AI
assistance are disclosed; no precontest implementation or pseudocode was
copied here.

## Status

- Historical fixed-window gate (00:30-03:00 UTC): **KILL**, because the
  empirical run did not start under the original resource-isolation rule.
- Later user-authorized technical assessment: **GO**.
- Evaluated commit:
  `45fca58a425c57129dba32b8a8fe46e99bfaeacc`.
- Fe 26.5.0 (`3dab95f`): build succeeds and 11/11 tests pass.
- The late GO proves technical viability; it neither rewrites the historical
  result nor starts this candidate automatically.

## Bounds and semantics

- Maximum 16 calls, 4,096 bytes per call and 32,768 input bytes total.
- Maximum 256 copied return-data bytes per report.
- Exact funding is required. Failed-call value is refunded after the batch;
  refund rejection atomically reverts the whole batch.
- EIP-1153 transient storage blocks reentrancy.
- Reports distinguish empty, short, canonical `Error(string)`, exact
  `Panic(uint256)`, other selectors and malformed standard errors.
- The gas recurrence reserves for the suffix, final report and refund.

## Evidence and limitations

Bundle: `evidence/final2-20261103T093400Z`.

- Manifest SHA-256:
  `a71b463fba7378c51b64e5fb569d3683017aeb0ea640356d7753de84c3094c31`.
- Verification-log SHA-256:
  `20e2b648ce682bf3c2538f8658f9210f85e7ff3688c7ad60213841c589457153`.
- Maximum trace: 16 exhausted targets at 32 KiB, all reported, outer success.
- Gas bracket: 600,000 rejects and 1,200,000 accepts.
- Ethers selector: `0x398f3653`; actual runtime succeeds on Cancun and
  produces the expected invalid opcode on Shanghai.

Typed ABI materializes dynamic input before contract bounds, so these are
post-decode product bounds, not a calldata firewall. Raw EVM call success does
not prove target code. Cancun+ is mandatory. The gas bracket is not a
universal minimum-gas claim.

See `GATE-DECISION.md`, `RED-TEAM.md` and `TEST-MATRIX.md`.
