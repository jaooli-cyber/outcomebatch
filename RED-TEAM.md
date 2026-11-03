# OutcomeBatch Red Team

## Threat model

The caller controls batch shape, calldata, values and requested gas. Targets may consume all forwarded gas, produce huge or malformed return data, attempt reentrancy, revert, have no code, or be precompiles. The original caller may reject a refund.

Required invariants are bounded copying, ordered continuation, suffix and final gas preservation, exact funding, explicit refund semantics, non-reentrancy, conservative classification, reproducibility, and claims that match the observable EVM behavior.

## Closed findings

| ID | Severity | Finding | Resolution | Status |
|---|---:|---|---|---|
| OB-01 | S0 | Alternate offsets, unpadded data or dirty padding could look like canonical Error(string). | Require offset 32, exact padded total and zero padding; adversarial vectors added. | Closed |
| OB-02 | S1 | Panic(uint256) with trailing bytes was accepted. | Require exactly 36 bytes and test a 37-byte negative vector. | Closed |
| OB-03 | S1 | Maximum count, total input and target exhaustion were initially separate. | One test executes sixteen burners with 32 KiB total and returns sixteen reports. | Closed |
| OB-04 | S1 | Gas admission lacked an empirical bracket. | A calibrated case rejects at 600,000 and accepts at 1,200,000 gas. | Closed |
| OB-05 | S1 | ABI, creation bytecode and fork assumptions lacked independent execution. | Ethers plus EthereumJS deploy creation bytecode, verify runtime, decode three non-empty reports on Cancun, and reject Shanghai. | Closed |
| OB-06 | S1 | A return-data bomb could trigger proportional copying. | 256, 257 and 1 MiB vectors prove a 256-byte copy cap. | Closed |
| OB-07 | S1 | Reentrancy or failed refund could leave ambiguous effects. | Transient guard and hostile-refund tests prove rejection, clearing and atomic rollback. | Closed |
| OB-08 | S1 | requested_gas could be misunderstood as an absolute cap when value adds an EVM stipend. | Rename the ABI field, document CALL semantics, and test zero requested gas with and without value. | Closed |
| OB-09 | S1 | Funding and reserve arithmetic overflow paths were untested. | Exact FundingOverflow index and saturated-reserve rejection are verified before target effects. | Closed |
| OB-10 | S1 | Maximum reports, value refund and final return reserve were not exercised together. | Sixteen value-bearing 257-byte reverts at 32 KiB return 10,784 encoded bytes and refund fully. | Closed |
| OB-11 | S1 | Ignored stale artifacts could be consumed accidentally. | Every build removes its fixed output directory and demo/ABI consume only fresh artifacts. | Closed |
| OB-12 | S1 | The judge-facing demo command required an undocumented prior build. | The Makefile makes demo depend on a clean build. | Closed |

## Accepted limitations

| ID | Severity | Limitation | Disposition |
|---|---:|---|---|
| OB-13 | S2 | Typed ABI materializes dynamic input before product caps. | Describe bounds as post-decode; never call OutcomeBatch a calldata firewall. |
| OB-14 | S2 | EVM CALL success does not prove target code exists. | Document EOA behavior; integrations validate code when required. |
| OB-15 | S2 | Prefix hashes collide whenever long returns share a prefix. | Expose hash_is_complete and never present a truncated prefix hash as a full commitment. |
| OB-16 | S2 | Refund rejection reverts the complete transaction. | Intentional atomic policy, documented and tested. |
| OB-17 | S2 | EIP-1153 excludes pre-Cancun environments. | Cancun or later is mandatory; Shanghai is a negative control. |
| OB-18 | S2 | Reserve constants are not universally optimal across forks or future gas schedules. | Publish the measured bracket and avoid minimum-gas claims. |
| OB-19 | S2 | A refund callback does not have a dedicated reentry vector. | The same transient guard remains set during refund; direct target reentry is tested. |
| OB-20 | S2 | Precompile behavior has no dedicated Fe vector. | Precompiles remain valid ordinary targets; no special guarantee is claimed. |

## Contest review

The main competitive risk is perceived familiarity: multicalls already exist. OutcomeBatch must therefore be presented as a bounded diagnostic execution primitive, not as another batching wrapper.

Its Fe-specific core is substantial: raw CALL outcomes, ephemeral return-data inspection, bounded MemBuffer capture, MemVec reports, an EIP-150-aware reserve recurrence, typed Wei funding, transient storage, conservative ABI classification and dynamic output encoding.

The strongest demo is the 1 MiB return-data bomb producing a complete report while copying only 256 bytes, followed by field-for-field Ethers decoding of all reports.

## Current verdict

Technical and algorithmic review: GO.

Open S0: 0.

Open S1: 0.

Candidate-release readiness remains conditional on green CI, an annotated tag, clean-clone verification and byte-identical double evidence generation.
