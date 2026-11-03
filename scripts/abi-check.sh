#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "$0")/common.sh"

ABI_FILE="$BUILD_DIR/OutcomeBatch.abi.json"
RUNTIME_FILE="$BUILD_DIR/OutcomeBatch.runtime.bin"
EXPECTED_SELECTOR="0x398f3653"
MAX_RUNTIME_BYTES="24576"

[[ -s "$ABI_FILE" ]] || die "ABI artifact missing; run make build"
[[ -s "$RUNTIME_FILE" ]] || die "runtime artifact missing; run make build"
[[ -f "$DEMO_DIR/package.json" ]] || die "demo/package.json missing"
[[ -d "$DEMO_DIR/node_modules/ethers" ]] || die "Ethers dependency missing; run make setup"
check_node_version

(
  cd "$DEMO_DIR"
  ABI_FILE="$ABI_FILE" EXPECTED_SELECTOR="$EXPECTED_SELECTOR" \
    node --input-type=module <<'NODE'
import { readFileSync } from "node:fs";
import { Interface } from "ethers";

const abi = JSON.parse(readFileSync(process.env.ABI_FILE, "utf8"));
const execute = abi.filter((item) => item.type === "function" && item.name === "execute");
if (execute.length !== 1) throw new Error(`expected one execute function; found ${execute.length}`);

const fn = execute[0];
if (fn.stateMutability !== "payable") throw new Error("execute must remain payable");
if (fn.inputs?.length !== 1 || fn.inputs[0].type !== "tuple[]") {
  throw new Error("execute input must remain one tuple[]");
}
if (fn.outputs?.length !== 1 || fn.outputs[0].type !== "tuple[]") {
  throw new Error("execute output must remain one tuple[]");
}

const expectedInput = [
  ["target", "address"],
  ["requested_gas", "uint256"],
  ["value", "uint256"],
  ["data", "bytes"],
];
const expectedOutput = [
  ["index", "uint32"],
  ["success", "bool"],
  ["class", "uint8"],
  ["selector_present", "bool"],
  ["selector", "uint32"],
  ["panic_present", "bool"],
  ["panic_code", "uint256"],
  ["returndata_len", "uint256"],
  ["prefix", "bytes"],
  ["prefix_hash", "bytes32"],
  ["hash_is_complete", "bool"],
];

function assertComponents(actual, expected, label) {
  if (!Array.isArray(actual) || actual.length !== expected.length) {
    throw new Error(`${label} component count changed`);
  }
  expected.forEach(([name, type], i) => {
    if (actual[i].name !== name || actual[i].type !== type) {
      throw new Error(`${label}[${i}] changed: ${actual[i].name}:${actual[i].type}`);
    }
  });
}

assertComponents(fn.inputs[0].components, expectedInput, "CallSpec");
assertComponents(fn.outputs[0].components, expectedOutput, "CallReport");

const selector = new Interface(abi).getFunction("execute").selector;
if (selector !== process.env.EXPECTED_SELECTOR) {
  throw new Error(`execute selector changed: ${selector}`);
}
console.log(`execute_selector=${selector}`);
console.log("abi_schema=PASS");
NODE
)

runtime_hex="$(tr -d '[:space:]' < "$RUNTIME_FILE")"
[[ -n "$runtime_hex" && "$runtime_hex" =~ ^[0-9A-Fa-f]+$ ]] || die "runtime is not hexadecimal"
(( ${#runtime_hex} % 2 == 0 )) || die "runtime has an odd hex length"
runtime_bytes=$(( ${#runtime_hex} / 2 ))
(( runtime_bytes <= MAX_RUNTIME_BYTES )) || die "runtime exceeds EIP-170: $runtime_bytes bytes"

printf 'abi_sha256=%s\n' "$(sha256_of "$ABI_FILE")"
printf 'runtime_sha256=%s\n' "$(sha256_of "$RUNTIME_FILE")"
printf 'runtime_bytes=%s\n' "$runtime_bytes"
printf 'eip170_headroom=%s\n' "$(( MAX_RUNTIME_BYTES - runtime_bytes ))"
printf 'abi_check=PASS\n'
