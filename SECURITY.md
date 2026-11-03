# Security model

OutcomeBatch is a contest prototype, not audited production software.

## Adversary

The caller controls the batch shape, targets, requested gas, values, and calldata. A target may:

- revert with empty, short, malformed, or custom data;
- return very large data;
- consume all forwarded gas;
- attempt reentrancy;
- accept or reject value;
- have no code or be a precompile.

The original caller may reject the final refund.

## Intended guarantees

- admitted calls are attempted once and in order;
- one target failure does not by itself stop later calls;
- at most 256 return bytes are copied per call;
- later calls and final result construction receive a precomputed reserve;
- input count, per-item bytes, aggregate bytes, and funding are checked;
- arithmetic used for reserves saturates instead of wrapping;
- nested execution is rejected;
- failed-call value is either refunded or the whole transaction reverts;
- standard errors are classified only when their layouts are canonical.

## Explicit limitations

### Post-decode limits

The dynamic input has already been materialized by the typed ABI when product limits run. OutcomeBatch does not protect the ABI decoder from oversized raw calldata and must not be described as a calldata firewall.

### CALL success

The EVM success bit does not establish that an address contains code or that an application-level operation occurred. Calls to EOAs and precompiles follow ordinary EVM rules. Integrators that require code existence must validate it separately.

### Prefix-only evidence

For returns longer than 256 bytes, prefix and prefix_hash cover only the copied prefix. Different full returns may share the same prefix. hash_is_complete makes this scope explicit.

### Refund rollback

If the original caller rejects the refund, OutcomeBatch reverts the entire transaction. Earlier successful external effects are rolled back by EVM transaction semantics.

### Fork requirement

The reentrancy guard uses transient storage. The deployed bytecode requires Cancun or later and is expected to fail on Shanghai.

### Gas portability

requested_gas follows CALL semantics, including value-transfer stipend behavior. Reserve constants are not claimed to be globally minimal or optimal across forks, clients, compiler versions, or future gas schedules.

### Text validity

Class 3 proves a canonical Error(string) ABI shape and zero padding. It does not validate UTF-8.

## Non-goals

OutcomeBatch does not implement:

- target or selector allowlists;
- raw ABI parsing before typed decode;
- a full hash of unbounded return data;
- arbitrary custom-error decoding;
- code-existence guarantees;
- atomic multicall semantics;
- mainnet deployment or upgradeability.

## Reporting

For this contest repository, report potential vulnerabilities through a private GitHub security advisory. Do not include secrets in public issues.
