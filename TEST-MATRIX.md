# OutcomeBatch test matrix

Final commit:
`45fca58a425c57129dba32b8a8fe46e99bfaeacc`.
Aggregate result: 11/11 in
`evidence/final2-20261103T093400Z/logs/20-tests-full.log`.

| Test | Property | Result |
|---|---|---:|
| `classification_boundaries` | Success-shaped, empty, short and unknown outcomes stay distinct. | PASS |
| `standard_error_and_panic_boundaries` | Only canonical standard errors get classes 3/4; malformed data gets class 6. | PASS |
| `call_count_and_data_caps` | Boundaries for 16 calls, 4,096 bytes/item and 32,768 total. | PASS |
| `failure_continues_and_suffix_gas_is_preserved` | Exhaustion cannot starve a later call or final report. | PASS |
| `sixteen_exhausted_callees_at_max_total_data` | Sixteen exhausted calls at 32 KiB yield 16 reports. | PASS |
| `gas_admission_has_a_reject_and_accept_bracket` | 600k rejects; 1.2m accepts; target state proves branches. | PASS |
| `return_bomb_is_capped` | 256/257-byte and 1-MiB returns copy at most 256 bytes. | PASS |
| `maximum_report_abi_has_exact_sizes` | Maximum report array has exact bounded ABI sizes. | PASS |
| `exact_funding_self_value_and_refund` | Exact funding, self-value ban, payment and refund. | PASS |
| `failed_refund_reverts_all_effects` | Refund rejection atomically rolls back earlier effects. | PASS |
| `transient_guard_blocks_nested_execute_and_clears` | Nested call fails and guard clears afterward. | PASS |

| External check | Assertion | Result |
|---|---|---:|
| Maximum trace | 16 target reverts and one outer success. | PASS |
| Gas trace | Low-gas revert, high-gas success and expected calls. | PASS |
| ABI | Ethers selector is `0x398f3653`. | PASS |
| Cancun | Actual runtime returns an empty report array. | PASS |
| Shanghai | Actual runtime hits expected invalid opcode. | PASS |
