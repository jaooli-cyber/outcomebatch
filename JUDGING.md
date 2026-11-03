# Judging guide

## One-line thesis

OutcomeBatch is a Fe batch executor that survives individual EVM failures and return-data bombs, returning bounded, canonically classified reports while reserving gas for every later call and the final result.

## Technical quality

- bounded input and output dimensions;
- exactly-once, ordered target execution;
- EIP-150-aware suffix-gas recurrence with saturating arithmetic;
- strict canonical Error(string) and Panic(uint256) boundaries;
- exact funding, failed-call refunds, rollback policy, and transient reentrancy guard;
- adversarial Fe tests plus independent Ethers/EthereumJS execution;
- pinned compiler, CI, clean-clone verification, and deterministic evidence.

## Fe-specific value

The implementation uses RawCallOutcome, ephemeral ReturnData, bounded MemBuffer capture, MemVec, dynamic ABI values, has_min_gas, Wei, TSlot, typed custom errors, and raw CALL effects in one cohesive contract.

Fe makes the safety-relevant distinctions visible in types while still exposing the low-level EVM behavior needed for bounded diagnostics.

## Originality

The novelty is not batching itself. OutcomeBatch combines:

- partial continuation;
- return-bomb-resistant prefix capture;
- cautious standard-error classification;
- explicit prefix-hash scope;
- suffix-gas preservation;
- structured, bounded reports;
- exact failed-value refund semantics.

It should be evaluated as a diagnostic execution primitive, not as another atomic multicall.

## Utility and insight

Batch callers often learn only that the outer transaction failed. OutcomeBatch preserves one compact outcome per admitted call, including failures, without copying arbitrary return data.

It also demonstrates several reusable insights:

- RETURNDATA must be inspected before the next external call;
- Error(string) selectors alone do not prove canonical encoding;
- CALL success does not prove code exists;
- a prefix hash is not a full-return commitment;
- value-transfer stipend changes the meaning of requested gas;
- partial continuation and refund rejection interact at transaction scope.

## Demo

Run:

    make setup
    make demo

The demo builds fresh Fe bytecode, deploys it on Cancun, executes a non-empty hostile batch, decodes complete reports through Ethers, and matches a committed golden. make verify adds all Fe tests, ABI checks, runtime-size checks, and reproducibility assertions.
