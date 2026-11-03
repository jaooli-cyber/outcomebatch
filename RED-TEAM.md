# OutcomeBatch Red Team

## Threat model

The caller controls batch shape, calldata, values and gas limits. Targets may
consume all gas, emit adversarial or huge return data, reenter, revert, or have
no code. The sender may reject a refund. Required invariants are bounded
copying, continuation, suffix/final gas, exact funding, atomic refund policy,
non-reentrancy and unambiguous classification.

## Findings

| ID | Severity | Finding | Resolution / disposition | Status |
|---|---:|---|---|---|
| OB-01 | S0 | Alternate offsets, unpadded data or dirty padding could look like canonical `Error(string)`. | Require offset 32, exact padded total and zero padding; adversarial vectors added. | Closed |
| OB-02 | S1 | `Panic(uint256)` with trailing bytes was accepted. | Require exactly 36 bytes; 37-byte negative vector added. | Closed |
| OB-03 | S1 | Initial suite omitted maximum count + total data + exhaustion together. | 16 burners of 2,048 bytes; trace proves 16 reverts and outer success. | Closed |
| OB-04 | S1 | Gas admission had no empirical bracket. | A separate one-call bracket rejects at 600k and accepts at 1.2m. | Closed |
| OB-05 | S1 | ABI/runtime/fork assumptions lacked an independent check. | Ethers encoding, Cancun execution and Shanghai negative control. | Closed |
| OB-06 | S1 | A return bomb could cause proportional copying. | 256/257-byte and 1-MiB tests prove a 256-byte copy cap. | Closed |
| OB-07 | S1 | Reentrancy or failed refund could leave partial effects. | Guard and hostile-refund tests prove clearing and rollback. | Closed |
| OB-08 | S2 | Typed ABI allocates dynamic input before caps. | Describe bounds as post-decode, never as a calldata firewall. | Accepted |
| OB-09 | S2 | An EOA can return EVM call success. | Integrations validate code if required. | Accepted |
| OB-10 | S2 | Refund rejection reverts the whole batch. | Intentional atomic policy; disclose in API/UX. | Accepted |
| OB-11 | S2 | EIP-1153 excludes pre-Cancun chains. | Cancun+ is mandatory. | Accepted |
| OB-12 | S2 | Gas constants are not a cross-fork optimum. | Benchmark target networks; avoid exact-minimum claims. | Accepted |

## Contest review

The main contest risk is differentiation, not viability: multicalls are
familiar. The pitch should center adversarial reports, strict canonical
classification, return-bomb bounds, suffix-gas preservation and reproducible
Fe evidence.

No S0 or S1 remains open at
`45fca58a425c57129dba32b8a8fe46e99bfaeacc`.
