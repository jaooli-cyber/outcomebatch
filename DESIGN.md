# OutcomeBatch design

## Goal

OutcomeBatch turns a heterogeneous batch of external EVM calls into a bounded sequence of observable outcomes. An admitted call is attempted exactly once. Failure of one target does not suppress later targets unless OutcomeBatch itself must reject the batch or the final refund fails.

## ABI

Each BatchCall contains:

- target: destination address;
- requested_gas: gas requested from CALL;
- value: wei sent to the target;
- data: dynamic calldata.

Each CallReport contains the call index, CALL success bit, conservative class, optional selector, optional panic code, full return-data length, copied prefix, Keccak-256 of that prefix, and a flag saying whether the hash covers the complete return value.

The execute selector is fixed by:

    execute((address,uint256,uint256,bytes)[])

Renaming the tuple component from gas_limit to requested_gas does not change this selector.

## Admission

Before any target runs, OutcomeBatch verifies:

1. no more than 16 calls;
2. no call data exceeds 4,096 bytes;
3. aggregate call data does not exceed 32,768 bytes;
4. summing values does not overflow u256;
5. the supplied transaction value equals the exact sum;
6. a value-bearing call does not target OutcomeBatch itself.

Typed ABI decoding occurs before these checks. The bounds therefore constrain admitted product values, not decoder allocation.

## Gas recurrence

The contract constructs a suffix reserve from the last call backwards. For a requested target amount m and a suffix reserve r, admission includes:

- m;
- ceil(m / 63), accounting for EIP-150 forwarding;
- r;
- a fixed per-call overhead allowance.

Addition saturates at u256::MAX. A saturated requirement fails admission rather than wrapping and executing with an unsafe reserve.

Before every target call, has_min_gas checks the requested amount and the precomputed suffix. A final reserve protects report encoding. A separate return reserve protects refund completion and final return encoding.

requested_gas is a requested CALL parameter, not a universal upper bound: a non-zero value transfer follows EVM stipend rules.

## Bounded return capture

Before each call, OutcomeBatch allocates and touches one 256-byte return buffer. The raw call copies no more than that buffer. RawCallOutcome retains the full RETURNDATASIZE, while the owned buffer contains only the bounded prefix.

Classification and any reads from live ReturnData occur immediately, before a later external call can replace the EVM return-data region.

prefix_hash is calculated over the copied bytes. hash_is_complete is true only when the full return length is at most 256 bytes.

## Conservative classification

Success is the EVM CALL success bit. Failed calls are classified as:

- empty;
- shorter than a selector;
- canonical Error(string);
- exact Panic(uint256);
- another selector;
- malformed standard error.

Canonical Error(string) requires offset 32, an exact padded total length, and zero padding. Panic(uint256) requires exactly 36 bytes. The contract never copies or decodes an arbitrary string.

## Values and refunds

Successful value transfers remain with their targets. The value of every failed target call is accumulated. At the end, a single bounded-gas refund is sent to the original caller.

Refund rejection intentionally reverts the complete outer transaction. This atomic refund policy avoids leaving failed-call value trapped in OutcomeBatch, but it also rolls back effects of previously successful calls.

## Reentrancy

A transient TSlot guard is set before the first external call and cleared before returning. Nested execute calls fail with ReentrantExecution. EIP-1153 makes Cancun or later mandatory.

## Determinism

Reports preserve input order. Every admitted call produces exactly one report unless OutcomeBatch reverts the whole transaction. The demo normalizes all externally visible report fields and compares them to a committed golden vector.
