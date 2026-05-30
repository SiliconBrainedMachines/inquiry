---
id: confirmed
title: "Confirmed findings"
date: 2026-05-29
status: active
tags: [findings, confirmed]
author: socrates
---

# Confirmed Findings

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: Legacy scheduler dispatch coupled APE identity to runtime agent naming — CONFIRMED

The legacy scheduler firmware for ANALYZE explicitly instructed named dispatch: it said to invoke SOCRATES via `runSubagent` rather than dispatching through a generic sub-agent path. This means the runtime dispatch path depended on a concrete agent identity instead of treating the assembled APE prompt as the executable contract.

Evidence:
- Legacy firmware instructs named SOCRATES dispatch in [code/cli/assets/archive/inquiry.agent.md.legacy](code/cli/assets/archive/inquiry.agent.md.legacy#L70).
- The branch and cleanroom itself frame the issue as scheduler dispatch using APE name as agent name in [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md#L1).

## F2: Current repository evidence is split between a committed source/build mismatch and an uncommitted source-side repair — REVISED

The repository does not currently expose one coherent dispatch contract. The packaged build asset already documents the decoupled rule, but the Phase 0 cleanroom baseline records that the source asset only says the same thing in the current working tree, as an uncommitted issue-slice edit replacing named `@<ape.name>` dispatch. That means the committed baseline remains divergent even though a candidate repair is already present locally.

Evidence:
- The active source firmware now documents the generic/current dispatch path and explicit `agentName` prohibition in [code/cli/assets/agents/inquiry.agent.md](code/cli/assets/agents/inquiry.agent.md#L77).
- The generated build asset documents the generic/current path and the `agentName` prohibition in [code/cli/build/assets/agents/inquiry.agent.md](code/cli/build/assets/agents/inquiry.agent.md#L75).
- Phase 0 records that the matching source wording is currently an uncommitted edit and blocks a clean validation-only baseline in [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md#L41).

## F3: The decoupled dispatch rule is not yet locked into the committed regression baseline — REVISED

The current working tree test file does assert the generic/current dispatch wording and the prohibition on deriving `agentName` from `ape.name`, but the Phase 0 baseline records those assertions as uncommitted additions. The runtime smoke expectation remains useful, but the clean committed regression guard is not yet present in the baseline that EXECUTE was supposed to validate.

Evidence:
- The current firmware test file asserts the generic/current wording and the explicit `agentName` prohibition in [code/cli/test/firmware_agent_test.dart](code/cli/test/firmware_agent_test.dart#L36).
- Phase 0 records the regression additions as uncommitted issue-slice changes in [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md#L42).
- The repository QA notes still capture the relevant runtime distinction in /memories/repo/release-qa.md.

## F4: The rejected Phase 0 EXECUTE deliverable reframed the analysis problem as baseline integrity, not just dispatch semantics — CONFIRMED

EXECUTE did not stop on a procedural technicality. It stopped because Phase 0 required a pre-implementation contract baseline, but the evidence supporting the decoupled rule was already mixed with local implementation work. Reopened ANALYZE therefore has to distinguish committed source-of-truth, packaged/runtime contract, and candidate repair, rather than assuming the issue is already resolved.

Evidence:
- Phase 0 concludes that execution cannot close honestly as a clean validation-only baseline from the current repo state in [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md#L49).
- The plan defines Phase 0 as a baseline-freeze step with no prior implementation work in [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/plan.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/plan.md#L31).
- Repository QA notes preserve the runtime distinction that made the contract divergence operationally relevant in /memories/repo/release-qa.md.

## F5: QA is admissible only from clean `.inquiry` or an explicit diagnostic override — REVISED

The fresh compiled build no longer yields admissible QA evidence when it is run against ambient workspace state. In the current repository, both the repo-root `.inquiry/state.yaml` and `code/cli/.inquiry/state.yaml` now persist `ape.state: _DONE`, so an uncontrolled packaged run can fail before it tells us anything useful about dispatch. For issue #181, clean QA must therefore start from a clean `.inquiry` trace. An explicit `--state` override remains useful, but only as a bounded diagnostic probe rather than as a substitute for a clean runtime baseline.

Evidence:
- [.inquiry/state.yaml](.inquiry/state.yaml) currently records `state: ANALYZE` with `ape.state: _DONE`.
- [code/cli/.inquiry/state.yaml](code/cli/.inquiry/state.yaml) currently records `state: ANALYZE` with `ape.state: _DONE`.
- [code/cli/assets/apes/socrates.yaml](code/cli/assets/apes/socrates.yaml) does not define `_DONE` as an invocable prompt state.
- [code/cli/lib/modules/ape/ape_definition.dart](code/cli/lib/modules/ape/ape_definition.dart#L72) throws on unknown state names during prompt assembly.

## F6: Ambient workspace runs and clean QA runs are different evidence classes — REVISED

The narrow firmware gate and a fresh packaged build still matter, but they do not by themselves establish a clean QA trace. The current working tree can be locally coherent while ambient packaged runs remain contaminated by stale `.inquiry` state. For this issue, ambient runs are diagnostic controls only; the admissible QA claim starts after `.inquiry` is clean.

Evidence:
- [code/cli/test/firmware_agent_test.dart](code/cli/test/firmware_agent_test.dart#L36) still encodes the local regression guard.
- [code/cli/scripts/build.ps1](code/cli/scripts/build.ps1) still regenerates the packaged binary and paired `build/assets` tree.
- [.inquiry/state.yaml](.inquiry/state.yaml) and [code/cli/.inquiry/state.yaml](code/cli/.inquiry/state.yaml) currently retain stale APE state that can change the meaning of a packaged run.
- The repository QA notes in /memories/repo/release-qa.md already require explicit control of the packaged binary path and runtime environment during build smoke.

## F7: EXECUTE inherited `issue-start` and explicitly reopened ANALYZE — CONFIRMED

The jump from EXECUTE back to ANALYZE was not spontaneous FSM behavior. It was an explicit transition made possible by the current transition-owned prompt wiring. `plan_to_execute` and `execute_continue` both inject `issue-start` into BASHO's prompt surface, and `issue-start` literally instructs the scheduler to run `iq fsm transition --event start_analyze --issue NNN` even though that protocol is documented for IDLE-to-ANALYZE startup. During this session, the BASHO implement turn followed that instruction and explicitly reopened ANALYZE.

Evidence:
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml#L476) assigns `instructions: [issue-start]` to `plan_to_execute`.
- [code/cli/assets/fsm/transition_contract.yaml](code/cli/assets/fsm/transition_contract.yaml#L488) assigns `instructions: [issue-start]` to `execute_continue`.
- [code/cli/assets/instructions/issue-start.md](code/cli/assets/instructions/issue-start.md#L14) instructs `iq fsm transition --event start_analyze --issue NNN`.
- [code/cli/assets/instructions/issue-start.md](code/cli/assets/instructions/issue-start.md#L19) and [code/cli/assets/instructions/issue-start.md](code/cli/assets/instructions/issue-start.md#L22) scope that protocol to IDLE/DONE startup before IDLE-to-ANALYZE.

## F8: Continuing ANALYZE preserves `_DONE` and can strand SOCRATES prompt assembly — CONFIRMED

Reopening ANALYZE is currently not enough to make SOCRATES runnable again. When the FSM continues within the same top-level state/APE pairing, the state update logic preserves the existing APE sub-state instead of restoring the APE's initial state. If that preserved sub-state is `_DONE`, `iq ape prompt --name socrates` fails immediately, because `_DONE` is a sentinel transition target rather than a prompt-bearing SOCRATES state.

Evidence:
- [code/cli/lib/modules/fsm/effect_executor.dart](code/cli/lib/modules/fsm/effect_executor.dart#L68) and [code/cli/lib/modules/fsm/effect_executor.dart](code/cli/lib/modules/fsm/effect_executor.dart#L69) preserve the current APE state when the same APE remains active.
- [code/cli/lib/modules/ape/ape_definition.dart](code/cli/lib/modules/ape/ape_definition.dart#L72) throws on unknown state names during prompt assembly.
- [.inquiry/state.yaml](.inquiry/state.yaml) and [code/cli/.inquiry/state.yaml](code/cli/.inquiry/state.yaml) currently remain in `ape.state: _DONE` after continuing ANALYZE.
