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

## F5: Fresh QA supports the local decoupled rule only when workspace state is controlled — REVISED

The reopened repository state is not one of total uncertainty, but the fresh compiled build no longer yields a single unconditional result. The current working tree still passes the narrow firmware contract gate, and a fresh packaged build completes successfully. The same packaged binary also assembles the SOCRATES prompt when invoked from the repo root or when given an explicit valid APE state. However, invoking that same binary from `code/cli` against the local `code/cli/.inquiry/state.yaml` fails with `Unknown state: _DONE for APE socrates`. Fresh QA therefore supports the decoupled dispatch rule only after separating dispatch-contract evidence from workspace-state sensitivity.

Evidence:
- `dart test test/firmware_agent_test.dart` passes from `code/cli`, showing that the current working-tree firmware contract satisfies the local regression guard.
- A fresh packaged build completes via [code/cli/scripts/build.ps1](code/cli/scripts/build.ps1), regenerating `code/cli/build/bin/inquiry.exe` and the paired `code/cli/build/assets` tree.
- The packaged binary fails from `code/cli` because [code/cli/.inquiry/state.yaml](code/cli/.inquiry/state.yaml) currently sets `ape.state: _DONE`, and [code/cli/assets/apes/socrates.yaml](code/cli/assets/apes/socrates.yaml) does not define `_DONE` as an invocable prompt state.
- The same packaged binary succeeds when invoked from the repo root, where [.inquiry/state.yaml](.inquiry/state.yaml) currently sets `ape.state: meta_reflection`, and also succeeds from `code/cli` when passed an explicit valid SOCRATES state.

## F6: Different stakeholders can read the same QA evidence in contradictory ways unless the workspace precondition is named — CONFIRMED

The fresh build evidence is perspectival. A runtime critic can look at the `Unknown state: _DONE` crash and conclude the packaged binary is broken. A dispatch-contract reviewer can look at the successful root-level or explicit-state prompt assembly and conclude the generic/current dispatch repair is locally coherent. A plan owner has to hold both facts at once: the decoupled dispatch wording is locally coherent, but the compiled-build smoke is environment-sensitive and therefore cannot be cited loosely as unconditional proof.

Evidence:
- [code/cli/.inquiry/state.yaml](code/cli/.inquiry/state.yaml) and [.inquiry/state.yaml](.inquiry/state.yaml) currently encode different APE sub-states for the same issue slice.
- [code/cli/lib/modules/ape/ape_definition.dart](code/cli/lib/modules/ape/ape_definition.dart) throws on unknown state names during prompt assembly, so the QA outcome depends on which persisted workspace state the binary reads.
- The repository QA notes in /memories/repo/release-qa.md already require explicit control of the packaged binary path and runtime environment during build smoke.
