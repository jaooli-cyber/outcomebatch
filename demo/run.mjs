import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import { createCustomCommon, Hardfork, Mainnet } from "@ethereumjs/common";
import {
  Account,
  bytesToHex,
  createAddressFromString,
  hexToBytes,
} from "@ethereumjs/util";
import { createVM } from "@ethereumjs/vm";
import { Interface } from "ethers";

const demoDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(demoDir, "..");
const artifactDir = resolve(
  repoRoot,
  process.env.OUTCOMEBATCH_ARTIFACT_DIR ?? ".build/release",
);

const abi = JSON.parse(
  await readFile(join(artifactDir, "OutcomeBatch.abi.json"), "utf8"),
);
const creationHex = (
  await readFile(join(artifactDir, "OutcomeBatch.bin"), "utf8")
).trim();
const runtimeHex = (
  await readFile(join(artifactDir, "OutcomeBatch.runtime.bin"), "utf8")
).trim();
const golden = JSON.parse(
  await readFile(join(demoDir, "golden.json"), "utf8"),
);

const creation = hexToBytes(`0x${creationHex}`);
const expectedRuntime = hexToBytes(`0x${runtimeHex}`);
const iface = new Interface(abi);
const selector = iface.getFunction("execute").selector;
assert.equal(selector, golden.selector, "execute selector drifted");

const caller = createAddressFromString(
  "0x2000000000000000000000000000000000000002",
);
const successTarget = createAddressFromString(
  "0x3000000000000000000000000000000000000003",
);
const revertTarget = createAddressFromString(
  "0x4000000000000000000000000000000000000004",
);
const bombTarget = createAddressFromString(
  "0x5000000000000000000000000000000000000005",
);

// Returns the word 42.
const successCode = hexToBytes("0x602a60005260206000f3");
// Reverts with the four-byte custom selector 0xdeadbeef.
const customRevertCode = hexToBytes("0x63deadbeef6000526004601cfd");
// Expands memory to one MiB and returns it. The first 256 bytes are all zero.
const returnBombCode = hexToBytes("0x6001620fffff53621000006000f3");

async function freshVm(hardfork) {
  const common = createCustomCommon({}, Mainnet, { hardfork });
  const vm = await createVM({ common });
  await vm.stateManager.putAccount(
    caller,
    new Account(0n, 1_000_000_000_000_000_000n),
  );
  return vm;
}

async function deployOutcomeBatch(vm) {
  const result = await vm.evm.runCall({
    caller,
    origin: caller,
    gasLimit: 30_000_000n,
    data: creation,
    skipBalance: true,
  });
  assert.equal(
    result.execResult.exceptionError,
    undefined,
    `creation failed: ${result.execResult.exceptionError?.error}`,
  );
  assert.ok(result.createdAddress, "creation returned no contract address");
  const deployedRuntime = await vm.stateManager.getCode(result.createdAddress);
  assert.equal(
    bytesToHex(deployedRuntime),
    bytesToHex(expectedRuntime),
    "creation bytecode did not install the committed runtime",
  );
  return {
    address: result.createdAddress,
    gasUsed: result.execResult.executionGasUsed,
  };
}

async function installTarget(vm, address, code) {
  await vm.stateManager.putAccount(address, new Account());
  await vm.stateManager.putCode(address, code);
}

function selectorHex(value) {
  return `0x${Number(value).toString(16).padStart(8, "0")}`;
}

function normalizeReport(label, report) {
  return {
    label,
    index: Number(report[0]),
    success: report[1],
    class: Number(report[2]),
    selector_present: report[3],
    selector: selectorHex(report[4]),
    panic_present: report[5],
    panic_code: report[6].toString(),
    returndata_len: report[7].toString(),
    prefix: report[8].toLowerCase(),
    prefix_hash: report[9].toLowerCase(),
    hash_is_complete: report[10],
  };
}

function expandGoldenReport(report) {
  const prefix = report.prefix.hex ??
    `0x${report.prefix.repeat.repeat(report.prefix.bytes)}`;
  return { ...report, prefix };
}

const cancunVm = await freshVm(Hardfork.Cancun);
const cancunDeployment = await deployOutcomeBatch(cancunVm);
await installTarget(cancunVm, successTarget, successCode);
await installTarget(cancunVm, revertTarget, customRevertCode);
await installTarget(cancunVm, bombTarget, returnBombCode);

const calls = [
  [successTarget.toString(), 100_000n, 0n, "0x"],
  [revertTarget.toString(), 100_000n, 0n, "0x"],
  [bombTarget.toString(), 5_000_000n, 0n, "0x"],
];
const calldata = hexToBytes(iface.encodeFunctionData("execute", [calls]));
const execution = await cancunVm.evm.runCall({
  caller,
  origin: caller,
  to: cancunDeployment.address,
  gasLimit: 30_000_000n,
  data: calldata,
  value: 0n,
  skipBalance: true,
});
assert.equal(
  execution.execResult.exceptionError,
  undefined,
  `Cancun execution failed: ${execution.execResult.exceptionError?.error}`,
);

const decoded = iface.decodeFunctionResult(
  "execute",
  bytesToHex(execution.execResult.returnValue),
)[0];
assert.equal(decoded.length, 3, "expected exactly three reports");
const labels = ["success", "custom-revert", "returndata-bomb"];
const reports = decoded.map((report, index) =>
  normalizeReport(labels[index], report)
);
const expectedReports = golden.reports.map(expandGoldenReport);
assert.deepEqual(reports, expectedReports, "decoded report fields drifted");

// Keep the central bounded-copy claim explicit, in addition to the golden.
assert.equal(reports[2].returndata_len, "1048576");
assert.equal((reports[2].prefix.length - 2) / 2, 256);
assert.equal(reports[2].hash_is_complete, false);

const shanghaiVm = await freshVm(Hardfork.Shanghai);
const shanghaiDeployment = await deployOutcomeBatch(shanghaiVm);
const emptyCalldata = hexToBytes(
  iface.encodeFunctionData("execute", [[]]),
);
const shanghaiExecution = await shanghaiVm.evm.runCall({
  caller,
  origin: caller,
  to: shanghaiDeployment.address,
  gasLimit: 30_000_000n,
  data: emptyCalldata,
  value: 0n,
  skipBalance: true,
});
const shanghaiError = shanghaiExecution.execResult.exceptionError?.error;
assert.equal(
  shanghaiError,
  golden.shanghai_error,
  "Shanghai must reject the EIP-1153 runtime",
);

console.log("OutcomeBatch external ABI demo");
console.log(`selector=${selector}`);
console.log(`creation_runtime_match=yes runtime_bytes=${expectedRuntime.length}`);
for (const report of reports) {
  console.log(
    [
      `report=${report.index}`,
      `case=${report.label}`,
      `success=${report.success}`,
      `class=${report.class}`,
      `selector=${report.selector}`,
      `returndata=${report.returndata_len}`,
      `copied=${(report.prefix.length - 2) / 2}`,
      `hash_complete=${report.hash_is_complete}`,
    ].join(" "),
  );
}
console.log(`cancun_status=success deploy_gas=${cancunDeployment.gasUsed}`);
console.log(`cancun_execute_gas=${execution.execResult.executionGasUsed}`);
console.log(`shanghai_status=expected_failure error=${shanghaiError}`);
console.log("OutcomeBatch external ABI demo: PASS");
