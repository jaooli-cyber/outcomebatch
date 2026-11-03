# OutcomeBatch test matrix

The authoritative command is:

    make verify

It builds fresh artifacts and runs 14 Fe tests, the external Cancun deployment demo, the Shanghai negative control, the frozen ABI check, and the EIP-170 runtime bound.

## Fe suite

| Test | Property |
|---|---|
| classification_boundaries | Success, empty, short, custom and malformed outcomes remain distinct; empty-prefix hash is exact. |
| standard_error_and_panic_boundaries | Only canonical Error(string) and exact Panic(uint256) receive standard classes. |
| call_count_and_data_caps | Boundaries for 16 calls, 4,096 bytes per item and 32,768 bytes total. |
| failure_continues_and_suffix_gas_is_preserved | Gas exhaustion cannot starve a later call or final report. |
| sixteen_exhausted_callees_at_max_total_data | Sixteen exhausted calls at 32 KiB yield sixteen ordered reports. |
| gas_admission_has_a_reject_and_accept_bracket | 600,000 gas rejects and 1,200,000 accepts for the calibrated one-call case. |
| requested_gas_value_stipend_is_explicit | Zero requested gas fails without value and succeeds with the EVM value stipend. |
| funding_and_reserve_overflow_reject_before_call | Funding overflow and saturated gas reserve reject before any target side effect. |
| return_bomb_is_capped | 256, 257 and 1 MiB returns copy at most 256 bytes and expose prefix-hash scope. |
| maximum_report_abi_has_exact_sizes | Maximum dynamic report encoding retains the expected bounded ABI size. |
| maximum_reports_refund_and_final_return_share_one_path | Sixteen 2 KiB value-bearing failures refund fully and return 10,784 encoded report bytes. |
| exact_funding_self_value_and_refund | Exact funding, self-value rejection, successful payment and failed-call refund. |
| failed_refund_reverts_all_effects | A hostile caller rejecting its refund atomically rolls back earlier effects. |
| transient_guard_blocks_nested_execute_and_clears | Nested execution fails and the transient guard clears for a later call. |

Expected aggregate result:

    test result: ok. 14 passed; 0 failed

## External demo

| Check | Assertion |
|---|---|
| Creation | OutcomeBatch creation bytecode deploys and installs byte-identical runtime. |
| ABI | Ethers derives execute selector 0x398f3653 from the generated ABI. |
| Success target | A 32-byte return is reported completely and field-for-field. |
| Custom revert | Selector 0xdeadbeef is classified as another selector-bearing revert. |
| Return-data bomb | Full length is 1,048,576 bytes while the copied prefix remains 256 bytes. |
| Golden | All eleven fields of all three reports match demo/golden.json. |
| Cancun | The complete non-empty batch succeeds. |
| Shanghai | The EIP-1153 runtime fails with the expected invalid opcode. |
| Runtime size | OutcomeBatch runtime is 5,493 bytes, leaving 19,083 bytes below EIP-170. |

## Reproducibility

The candidate command additionally checks an annotated tag from a clean clone and compares two independently generated evidence bundles byte for byte:

    CANDIDATE_TAG=<annotated-tag> make candidate
