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

Issue #181 is no longer best framed as a single yes/no question about whether scheduler dispatch is coupled to `agentName = ape.name`. Reopened ANALYZE now has to explain two coupled contract failures plus one QA admissibility rule.

The repository evidence is split across four surfaces that do not agree with each other:

1. the legacy firmware contract, which clearly coupled dispatch to named sub-agents;
2. the committed source-side baseline identified by the Phase 0 cleanroom deviation, which still needed a local replacement of `@<ape.name>` dispatch;
3. the packaged build asset and current working-tree edits, which already express the decoupled generic/current dispatch rule;
4. the transition-owned EXECUTE prompt wiring, which currently injects `issue-start` into BASHO and therefore exposes an explicit `start_analyze` path while already in EXECUTE.

The problem being solved in reopened ANALYZE is therefore dispatch-contract divergence, control-plane leakage, and evidence ambiguity. The repository can appear "fixed" if one reads the working tree or packaged build asset, yet still fail the stricter question of whether the committed source-of-truth and committed regression baseline actually encode the same rule. It can also appear to "reopen itself" when the actual cause is a prompt-surface defect that explicitly tells BASHO to run `start_analyze`. Finally, fresh QA is not admissible unless it begins from a clean `.inquiry` trace, because persisted workspace state can strand SOCRATES in `_DONE` and change the meaning of a packaged run before dispatch behavior is even tested.

## Decisions taken

1. Separate committed baseline evidence from working-tree repair evidence.

Justification:
The rejected Phase 0 deliverable established that the current working tree already contains issue-slice edits in the source firmware and firmware regression test. Treating those edits as if they described the clean committed baseline would collapse the distinction that caused EXECUTE to stop.

2. Treat clean `.inquiry` as a mandatory QA precondition.

Justification:
Ambient workspace state is now known to retain stale APE substates such as `_DONE`. That means a packaged QA run can fail before it says anything useful about dispatch, so uncontrolled `.inquiry` state is diagnostic noise rather than admissible evidence.

3. Treat source/build contract drift as the live problem under analysis.

Justification:
The packaged build asset already instructs generic/current dispatch and forbids deriving `agentName` from `ape.name`, while the cleanroom Phase 0 deviation records that the source asset only says the same thing in an uncommitted local edit. That means the repository currently exposes different contracts depending on which surface is read.

4. Treat EXECUTE-to-ANALYZE reentry as explicit control-plane leakage, not autonomous FSM behavior.

Justification:
The session evidence and the transition-owned instruction surfaces agree: BASHO did not invent a new route. It was handed `issue-start`, and `issue-start` literally contains `iq fsm transition --event start_analyze --issue NNN`. The unexpected reopen is therefore a contract bug in the prompt surface, not a spontaneous state-machine mutation.

5. Treat the decoupled regression rule as provisional until it exists in the committed test baseline.

Justification:
The current working tree test file now asserts the generic/current dispatch wording and the explicit `agentName` prohibition, but the cleanroom Phase 0 baseline records those assertions as uncommitted additions. That makes them evidence of intended repair, not proof that the committed baseline is already guarded.

6. Distinguish local coherence from committed-baseline proof.

Justification:
Fresh verification adds useful evidence, but not a single unconditional runtime verdict. The narrow firmware gate passes, a fresh packaged build completes, and the packaged binary can be made to resolve a requested APE prompt under a clean or explicit valid state. But stale `.inquiry` state can still force the same binary into `_DONE`, and that still does not prove that the committed source and committed regression baseline already encode the same rule.

7. Reframe the issue from "already resolved runtime behavior" to "alignment of dispatch contract, transition contract, and clean-QA evidence surfaces."

Justification:
Phase 0 stopped because it could not honestly establish a pre-implementation validation baseline. The later EXECUTE incident adds a second control-plane hazard: transition-owned instructions can directly tell BASHO to reopen ANALYZE. The main analytical question is no longer whether the repository can describe a decoupled dispatch rule somewhere, but whether source instructions, packaged/runtime instructions, transition-owned instructions, regression coverage, and clean-QA preconditions all agree on what is being proved.

## Alternative perspectives

The disagreement around issue #181 is not only about facts. It is also about what each stakeholder treats as admissible proof.

- A dispatch-contract reviewer sees the core problem as semantic coupling between APE identity and runtime lookup. From that viewpoint, the decisive evidence is the instruction surface itself: the source firmware, the packaged mirror, the regression guard, and the requirement that runtime dispatch remain on the generic/current path without deriving `agentName` from `ape.name`. This reviewer will object to any claim of resolution that is supported only by a successful packaged run, because a green smoke can coexist with a still-dirty contract baseline.
- A runtime or host-integration critic sees the problem less as wording drift and more as avoidable dependency on local agent registry shape. From that viewpoint, the key question is whether the same assembled prompt still fails when dispatch is forced through a named custom-agent lookup and succeeds when `agentName` is omitted. This critic will object if the analysis treats prompt assembly alone as proof of dispatch correctness, because the concrete failure mode in repository QA is precisely named-dispatch failure in the absence of a matching custom agent.
- A release or QA reviewer sees a different problem again: reproducibility of packaged evidence. From that viewpoint, the same binary producing success from the repo root and failure from `code/cli` is itself the warning sign. This reviewer will object to phrases such as "fresh build passed" unless the binary path, working directory, and explicit valid APE state are frozen, because ambient workspace state changes the meaning of the result.
- A cleanroom-process critic or plan owner sees the central problem as evidentiary hygiene. From that viewpoint, the rejected Phase 0 deliverable is not background process noise but the strongest evidence that the repository was already mixing candidate repair with baseline proof. This critic will object whenever working-tree alignment is described as committed truth, because that collapses the very boundary the plan was supposed to preserve.

These perspectives do not cancel each other out. They identify different failure modes: semantic contract drift, runtime registry coupling, workspace-sensitive QA, and baseline contamination. The analytical burden is to keep those proof standards separate long enough to say which claim has actually been established.

- A FSM-control reviewer sees a separate but coupled problem: the EXECUTE prompt surface should not carry IDLE startup instructions at all. From that viewpoint, the decisive evidence is the transition contract assigning `issue-start` to `plan_to_execute` and `execute_continue`, plus the fact that `issue-start` explicitly calls `start_analyze`. This reviewer will object to any diagnosis that talks only about dispatch semantics while ignoring the control-plane leak that actually reopened ANALYZE.

## Constraints and risks identified

### Constraint: scheduler behavior is instruction-driven

The scheduler's dispatch semantics live in firmware instructions rather than in a typed runtime interface. That means regressions can be introduced by prompt edits even if CLI code remains unchanged.

### Constraint: packaged behavior and source-of-truth review can diverge

The repository currently contains a build asset that already documents the decoupled rule while the Phase 0 deviation shows the source asset required a local repair. This creates a split between what packaged/runtime smoke may appear to validate and what source review still asserts.

### Constraint: EXECUTE currently inherits `issue-start` transition instructions

The EXECUTE prompt surface is not isolated to execution semantics. `plan_to_execute` and `execute_continue` currently inject `issue-start`, a startup protocol documented for IDLE-to-ANALYZE. That means an execution sub-agent can be told to verify issues, create analyze directories, and call `start_analyze` while already inside EXECUTE.

### Constraint: APE identity still matters for prompt assembly

`ape.name` still matters for prompt assembly via `iq ape prompt --name <ape.name>`. The issue is not whether APE identity disappears entirely; it is whether dispatch wrongly reuses that identity as a runtime lookup key.

### Constraint: packaged prompt assembly depends on workspace-local inquiry state

The compiled binary does not assemble prompts from assets alone. It also reads persisted inquiry state from the current working directory. In the current repository, both [code/cli/.inquiry/state.yaml](code/cli/.inquiry/state.yaml) and [.inquiry/state.yaml](.inquiry/state.yaml) currently record `ape.state: _DONE`. Because [code/cli/lib/modules/fsm/effect_executor.dart](code/cli/lib/modules/fsm/effect_executor.dart#L68) and [code/cli/lib/modules/fsm/effect_executor.dart](code/cli/lib/modules/fsm/effect_executor.dart#L69) preserve the current APE state when the same APE remains active, a reopened analysis can stay stranded in `_DONE`. [code/cli/lib/modules/ape/ape_definition.dart](code/cli/lib/modules/ape/ape_definition.dart#L72) then rejects prompt assembly. QA therefore cannot rely on ambient workspace state at all; it must start from clean `.inquiry` or use an explicit diagnostic override.

### Constraint: continuing ANALYZE does not currently reset SOCRATES from `_DONE`

`ANALYZE --start_analyze--> ANALYZE` is allowed, but the current state update behavior preserves SOCRATES' existing sub-state instead of restoring its initial state. If that preserved value is `_DONE`, the state machine reopens ANALYZE while leaving the active APE effectively non-invocable.

### Risk: a dirty working tree can overstate the degree of resolution

Reading only the current working tree suggests the issue is already solved, because the local source edit and local test additions match the packaged build asset. The rejected Phase 0 deliverable shows why that conclusion is unsafe: those edits are not yet the clean baseline the plan expected to verify.

### Risk: QA started from ambient `.inquiry` can overstate or understate the repository state before dispatch is even exercised

If `.inquiry` is stale, a packaged run can fail on `_DONE` and look like a dispatch regression when it is really a QA-precondition failure. If `.inquiry` happens to contain a valid state, the same ambient run can look healthier than the actual clean baseline deserves. Both readings are unsafe.

### Risk: a green local gate and a successful fresh build can still be misread as baseline proof

The current repo now has stronger working-tree evidence than a static read alone: the narrow firmware test passes, `build.ps1` completes, and the packaged binary resolves the requested APE prompt under a valid workspace state. Those checks matter, but they validate the current local slice, not the cleanliness of the committed baseline that Phase 0 was supposed to freeze.

### Risk: fresh compiled-build QA can be over-read in either direction

If one starts from clean `.inquiry` or passes an explicit valid SOCRATES state, the build can appear healthy and locally coherent. If one reuses ambient workspace state, the same binary can crash on `Unknown state: _DONE for APE socrates` before dispatch is even evaluated. A supporter can therefore overclaim success, while a critic can overclaim failure, unless the QA precondition is named precisely.

### Risk: EXECUTE can reopen ANALYZE explicitly whenever execution prompts carry startup instructions

As long as EXECUTE prompt fragments inject `issue-start`, a sub-agent can follow its own prompt and call `start_analyze`. That makes execution control behavior depend on prompt leakage rather than on the narrower intent of the active state.

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
- Explaining why EXECUTE reopened ANALYZE and whether that was an autonomous FSM move or an explicit tool action.
- Defining clean `.inquiry` as the admissible QA starting point for this issue.

### Out of scope

- Proposing implementation changes.
- Modifying firmware, CLI code, or tests.
- Re-triaging the issue or selecting a different task.
- Proving every historical commit transition that led from legacy behavior to the current divergence.

## Conclusion

The original problem was real: legacy scheduler instructions bound dispatch to named sub-agents such as SOCRATES, coupling APE identity to runtime agent lookup. Reopened ANALYZE now shows that the current repository contains two coupled defects rather than one resolved runtime story.

First, the dispatch-contract baseline is still not cleanly proven. The packaged build asset, the current working-tree repair, and the narrow local firmware gate support the decoupled generic/current dispatch rule in the current local slice, but that still does not prove the committed source and committed regression baseline are aligned.

Second, the control-plane surface is itself defective. EXECUTE did not reopen ANALYZE "by itself". The reopen was an explicit tool action made possible by transition-owned prompt leakage: BASHO inherited `issue-start`, and `issue-start` literally instructs `start_analyze`. On top of that, continuing ANALYZE currently preserves `_DONE`, which means the system can reenter ANALYZE while leaving SOCRATES non-invocable.

The QA rule that follows from this is strict: admissible QA for issue #181 must begin from clean `.inquiry`. Ambient workspace runs may still be useful as diagnostics, but they no longer count as clean evidence because stale state can distort the result before dispatch behavior is exercised.

On the available evidence, ANALYZE can conclude that issue #181 is not yet resolved at the level of a clean committed baseline, and that the surrounding control contract is also unsound. The problem definition for subsequent planning is therefore the alignment of dispatch instructions, transition-owned instructions, regression coverage, and clean-QA preconditions rather than the assumption that the scheduler is already safely decoupled everywhere.

## References

- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/confirmed.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/confirmed.md)
- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md)
- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md)
- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/plan.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/plan.md)
- [code/cli/assets/agents/inquiry.agent.md](code/cli/assets/agents/inquiry.agent.md#L77)
- [code/cli/assets/archive/inquiry.agent.md.legacy](code/cli/assets/archive/inquiry.agent.md.legacy#L70)
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml#L241)
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml#L476)
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml#L488)
- [code/cli/assets/instructions/issue-start.md](code/cli/assets/instructions/issue-start.md#L14)
- [code/cli/assets/apes/socrates.yaml](code/cli/assets/apes/socrates.yaml)
- [code/cli/build/assets/agents/inquiry.agent.md](code/cli/build/assets/agents/inquiry.agent.md#L75)
- [code/cli/.inquiry/state.yaml](code/cli/.inquiry/state.yaml)
- [.inquiry/state.yaml](.inquiry/state.yaml)
- [code/cli/lib/modules/ape/ape_definition.dart](code/cli/lib/modules/ape/ape_definition.dart#L68)
- [code/cli/lib/modules/fsm/effect_executor.dart](code/cli/lib/modules/fsm/effect_executor.dart#L68)
- [code/cli/scripts/build.ps1](code/cli/scripts/build.ps1)
- [code/cli/test/firmware_agent_test.dart](code/cli/test/firmware_agent_test.dart#L35)
- /memories/repo/release-qa.md