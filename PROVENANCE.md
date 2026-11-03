# Provenance and AI assistance

## Timeline

Before 2026-11-03 00:00:00 UTC, work was limited to research, specification, non-compilable pseudocode, test planning, threat modelling, and Red Team analysis kept outside this repository. That material was not copied into the implementation.

This repository and its implementation history began after the contest build window opened. The first commit is dated 2026-11-03 00:01:26 UTC.

The original 00:30–03:00 UTC empirical gate was closed as KILL because a conservative shared-host rule prevented backend execution before its fixed deadline. This was a procedural timebox result, not a technical failure. The audit trail remains in GATE-LOG.md and GATE-DECISION.md.

At 09:04 UTC the entrant explicitly authorized a later isolated technical reassessment when aggregate resources were sufficient. That reassessment built with Fe 26.5.0, passed the initial adversarial suite, and produced a technical GO. Productization, new tests, demo work, CI, documentation, and final evidence remain work performed inside the contest window.

## Reused code and dependencies

No precontest implementation or pseudocode was copied into the entry. No third-party application source was copied into OutcomeBatch.

The project depends on:

- Fe core and standard libraries distributed with the pinned Fe compiler;
- Ethers and EthereumJS packages pinned by demo/package-lock.json for independent ABI and EVM verification.

Those dependencies retain their own licenses. OutcomeBatch source is Apache-2.0.

## AI assistance

AI assisted with:

- primary-source and Fe API research;
- architecture and implementation support;
- adversarial test design;
- debugging and failure diagnosis;
- reproducibility and CI design;
- documentation;
- technical, algorithmic, security, and contest Red Team review.

AI output was not accepted as evidence by itself. Claims in the submission are backed by compiler output, automated tests, external EVM execution, committed golden vectors, clean-clone verification, or cryptographic hashes. The human entrant remains responsible for the submission.

## Evidence policy

All final metrics, artifacts, logs, and hashes are regenerated against the submitted commit. Candidate evidence records:

- exact commit and tree;
- Fe version, release commit, binary size, and binary hash;
- source hashes;
- ABI and bytecode hashes;
- test and demo results;
- runtime size and EIP-170 headroom.

The private submission code and registered contact email are deliberately excluded from the repository.
