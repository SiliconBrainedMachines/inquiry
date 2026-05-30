---
id: diagnosis
title: "Diagnosis"
date: 2026-05-29
status: final
tags: [diagnosis, analyze, dispatch, scheduler]
author: socrates
---

# Diagnosis

## Problem defined

Issue #181 is no longer best framed as a single yes/no question about whether scheduler dispatch is coupled to `agentName = ape.name`. The current repository evidence is split across three surfaces that do not agree with each other:

1. the legacy firmware contract, which clearly coupled dispatch to named sub-agents;
2. the committed source-side baseline identified by the Phase 0 cleanroom deviation, which still needed a local replacement of `@<ape.name>` dispatch;
3. the packaged build asset and current working-tree edits, which already express the decoupled generic/current dispatch rule.

The problem being solved in reopened ANALYZE is therefore contract divergence, baseline ambiguity, and evidence ambiguity. The repository can appear "fixed" if one reads the working tree or packaged build asset, yet still fail the stricter question of whether the committed source-of-truth and committed regression baseline actually encode the same rule. Fresh compiled-build QA adds a second ambiguity: the same packaged binary can either assemble the SOCRATES prompt or crash on `Unknown state: _DONE for APE socrates`, depending on which workspace-local inquiry state it reads.

## Decisions taken

1. Separate committed baseline evidence from working-tree repair evidence.

Justification:
The rejected Phase 0 deliverable established that the current working tree already contains issue-slice edits in the source firmware and firmware regression test. Treating those edits as if they described the clean committed baseline would collapse the distinction that caused EXECUTE to stop.

2. Treat source/build contract drift as the live problem under analysis.

Justification:
The packaged build asset already instructs generic/current dispatch and forbids deriving `agentName` from `ape.name`, while the cleanroom Phase 0 deviation records that the source asset only says the same thing in an uncommitted local edit. That means the repository currently exposes different contracts depending on which surface is read.

3. Treat the decoupled regression rule as provisional until it exists in the committed test baseline.

Justification:
The current working tree test file now asserts the generic/current dispatch wording and the explicit `agentName` prohibition, but the cleanroom Phase 0 baseline records those assertions as uncommitted additions. That makes them evidence of intended repair, not proof that the committed baseline is already guarded.

4. Distinguish local coherence from committed-baseline proof.

Justification:
Fresh verification adds useful evidence, but not a single unconditional runtime verdict. The narrow firmware gate passes, a fresh packaged build completes, and the packaged binary resolves the requested APE prompt when run from the repo root or with an explicit valid state. The same binary fails from `code/cli` because it reads a local persisted APE state of `_DONE`, which SOCRATES does not define as an invocable prompt state. That means the local repair is coherent across source, test, and packaged binary under a valid state, but this still does not prove that the committed source and committed regression baseline already encode the same rule.

5. Reframe the issue from "already resolved runtime behavior" to "alignment of contract and evidence surfaces."

Justification:
Phase 0 stopped because it could not honestly establish a pre-implementation validation baseline. Fresh QA now adds a second interpretive hazard: different stakeholders can read the same build evidence differently depending on whether they control workspace state. The main analytical question is no longer whether the repository can describe a decoupled dispatch rule somewhere, but whether source instructions, packaged/runtime instructions, regression coverage, and QA preconditions all agree on what is being proved.

## Alternative perspectives

- A dispatch-contract reviewer sees the core problem as coupling between APE identity and runtime lookup. From that viewpoint, the decisive evidence is the source/build wording, the regression guard, and the fact that prompt assembly still succeeds under a valid state without deriving `agentName` from `ape.name`.
- A release or QA reviewer sees a different problem: the same packaged binary can pass or fail depending on which `.inquiry/state.yaml` it inherits from the current working directory. From that viewpoint, "fresh build passed" is too imprecise to count as trustworthy evidence.
- A planner or critic of the cleanroom process sees a third problem: Phase 0 already showed baseline contamination from uncommitted issue-slice edits, and the fresh build smoke shows additional ambiguity unless runtime preconditions are named explicitly. From that viewpoint, the central risk is overclaiming certainty from evidence that changes meaning across surfaces.

## Constraints and risks identified

### Constraint: scheduler behavior is instruction-driven

The scheduler's dispatch semantics live in firmware instructions rather than in a typed runtime interface. That means regressions can be introduced by prompt edits even if CLI code remains unchanged.

### Constraint: packaged behavior and source-of-truth review can diverge

The repository currently contains a build asset that already documents the decoupled rule while the Phase 0 deviation shows the source asset required a local repair. This creates a split between what packaged/runtime smoke may appear to validate and what source review still asserts.

### Constraint: APE identity still matters for prompt assembly

`ape.name` still matters for prompt assembly via `iq ape prompt --name <ape.name>`. The issue is not whether APE identity disappears entirely; it is whether dispatch wrongly reuses that identity as a runtime lookup key.

### Constraint: packaged prompt assembly depends on workspace-local inquiry state

The compiled binary does not assemble prompts from assets alone. It also reads persisted inquiry state from the current working directory. Because [code/cli/.inquiry/state.yaml](code/cli/.inquiry/state.yaml) currently records `ape.state: _DONE` while [.inquiry/state.yaml](.inquiry/state.yaml) currently records `ape.state: meta_reflection`, the same packaged binary can produce different QA outcomes without any asset change.

### Risk: a dirty working tree can overstate the degree of resolution

Reading only the current working tree suggests the issue is already solved, because the local source edit and local test additions match the packaged build asset. The rejected Phase 0 deliverable shows why that conclusion is unsafe: those edits are not yet the clean baseline the plan expected to verify.

### Risk: a green local gate and a successful fresh build can still be misread as baseline proof

The current repo now has stronger working-tree evidence than a static read alone: the narrow firmware test passes, `build.ps1` completes, and the packaged binary resolves the requested APE prompt under a valid workspace state. Those checks matter, but they validate the current local slice, not the cleanliness of the committed baseline that Phase 0 was supposed to freeze.

### Risk: fresh compiled-build QA can be over-read in either direction

If one runs the binary from the repo root or passes an explicit valid SOCRATES state, the build appears healthy and locally coherent. If one runs the same binary from `code/cli`, it crashes on `Unknown state: _DONE for APE socrates` because of the local persisted inquiry state. A supporter can therefore overclaim success, while a critic can overclaim failure, unless the QA precondition is named precisely.

### Risk: named dispatch remains an avoidable runtime dependency wherever the old source contract persists

The repository QA note records the concrete runtime failure mode: named dispatch to `socrates` or `descartes` fails when no matching custom agent exists, while generic dispatch succeeds with the same assembled prompt. Any remaining or regenerated source instruction that preserves `@<ape.name>` can therefore recreate a runtime dependency on agent registry configuration.

### Risk: mirrored firmware assets and tests can drift independently

This issue is not just source vs build. The test guard for the decoupled rule also lives on a separate surface. If source, build, and tests are not updated from the same committed baseline, the repository can present a false sense of consistency.

## Scope

### In scope

- Confirming the original dispatch coupling problem in the legacy firmware.
- Distinguishing the committed source baseline from the current working-tree repair.
- Determining whether the packaged build asset, source firmware, and regression guard currently describe one coherent dispatch contract.
- Recording what the rejected Phase 0 EXECUTE deliverable changes about the analytical framing of the issue.

### Out of scope

- Proposing implementation changes.
- Modifying firmware, CLI code, or tests.
- Re-triaging the issue or selecting a different task.
- Proving every historical commit transition that led from legacy behavior to the current divergence.

## Conclusion

The original problem was real: legacy scheduler instructions bound dispatch to named sub-agents such as SOCRATES, coupling APE identity to runtime agent lookup. Reopened ANALYZE shows that the current repository does not yet justify the stronger claim that this dependency is fully removed from the clean baseline.

Instead, the evidence now supports a narrower and more rigorous conclusion: the packaged build asset, the current working-tree repair, and the narrow local firmware gate support the decoupled generic/current dispatch rule in the current local slice. Fresh compiled-build QA partially supports that rule as well, but only under a valid persisted APE state; the same binary can fail from a different working directory because prompt assembly reads workspace-local inquiry state and rejects `_DONE` for SOCRATES. The rejected Phase 0 deliverable is therefore substantive evidence, not incidental process noise. It reveals that issue #181 remains a contract-alignment problem spanning source firmware, packaged mirror, regression guard, QA preconditions, and the distinction between local verification and committed proof.

On the available evidence, ANALYZE can conclude that issue #181 is not yet resolved at the level of a clean committed baseline. It can also conclude that fresh packaged-build QA is not self-interpreting: one stakeholder can see local coherence, another can see a packaged failure, and both can be looking at the same binary under different persisted states. The problem definition for subsequent planning is therefore the alignment of those contract and evidence surfaces, not the assumption that the scheduler is already safely decoupled everywhere.

## References

- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/confirmed.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/confirmed.md)
- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md)
- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md)
- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/plan.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/plan.md)
- [code/cli/assets/agents/inquiry.agent.md](code/cli/assets/agents/inquiry.agent.md#L77)
- [code/cli/assets/archive/inquiry.agent.md.legacy](code/cli/assets/archive/inquiry.agent.md.legacy#L70)
- [code/cli/assets/apes/socrates.yaml](code/cli/assets/apes/socrates.yaml)
- [code/cli/build/assets/agents/inquiry.agent.md](code/cli/build/assets/agents/inquiry.agent.md#L75)
- [code/cli/.inquiry/state.yaml](code/cli/.inquiry/state.yaml)
- [.inquiry/state.yaml](.inquiry/state.yaml)
- [code/cli/lib/modules/ape/ape_definition.dart](code/cli/lib/modules/ape/ape_definition.dart#L68)
- [code/cli/scripts/build.ps1](code/cli/scripts/build.ps1)
- [code/cli/test/firmware_agent_test.dart](code/cli/test/firmware_agent_test.dart#L35)
- /memories/repo/release-qa.md