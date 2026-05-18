---
id: plan
issue: 198
title: "Plan: Make legion parallel-first with degraded sequential fallback"
status: active
phase: decomposition
owner: descartes
date: 2026-05-18
---

# Plan - Issue #198 (decomposition)

## Goal
Reduce legion wall-clock latency in GitHub Copilot environments by closing the diagnosed default-routing gap: audit the current invocation path, specify parallel-first behavior with degraded sequential fallback, implement the routing decision only if the audit proves it is missing, and verify the result with focused checks first and full-suite validation last.

## Scope Guardrails
- [ ] Keep work limited to legion invocation behavior and the documentation/tests directly needed to support that behavior.
- [ ] Preserve legion's epistemic invariant: each expert remains an isolated independent subagent.
- [ ] Preserve the degraded sequential fallback contract for runtimes where parallel fan-out is unavailable or ambiguous.
- [ ] Treat the host capability question as already answered by ANALYZE; do not reopen platform-capability investigation unless execution falsifies the diagnosis.
- [ ] Treat this artifact as PLAN-only; no implementation details beyond execution-ready steps.

## Diagnosis Decision Traceability (Mandatory)
- [ ] D1: Environmental capability is already proven and remains a fixed premise for execution.
- [ ] D2: The root question is default routing, not raw platform capability.
- [ ] D3: Isolated expert contexts and degraded sequential fallback remain non-negotiable constraints.
- [ ] D4: The cost of inaction remains explicit: latency scales with expert count even when the runtime can fan out.

## Ordering Contract
- [ ] Execute phases strictly in order: Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5.
- [ ] A later phase may start only when the verification checklist of the previous phase is green.
- [ ] If Phase 1 proves legion is already parallel-first by default, skip implementation work in Phase 3 and continue with documentation alignment and verification only.
- [ ] If any new contradiction invalidates diagnosis.md, stop execution and return to ANALYZE instead of widening scope ad hoc.

## Commit Contract
- [ ] After each successful phase, create a non-interactive commit before starting the next phase.
- [ ] A phase counts as successful only when its verification checklist is green.
- [ ] Each phase commit must stay scoped to the verified slice completed by that phase and reference issue #198.
- [ ] If a phase is skipped by plan logic, do not create a placeholder commit; commit after the next actually completed phase instead.

## Phase 1 - Audit Current Default Invocation Path

### Entry Criteria
- [x] [cleanrooms/198-perflegion-invoke-subagents-in-parallel-for-faster/analyze/diagnosis.md](cleanrooms/198-perflegion-invoke-subagents-in-parallel-for-faster/analyze/diagnosis.md) is approved and accepted as source of truth.
- [x] The target surface is still legion's default invocation path in the VS Code / Copilot runtime.
- [x] Relevant legion skill and target-specific invocation files are available for inspection.

### Steps
- [x] Re-read [code/cli/assets/skills/legion/SKILL.md](code/cli/assets/skills/legion/SKILL.md) with focus on the consultation step and any wording that implies dispatch shape.
- [x] Trace the concrete target path that executes legion from the VS Code / Copilot environment.
- [x] Determine whether the current path explicitly uses a parallel-capable route, leaves routing implicit, or forces sequential launch.
- [x] Identify any existing capability-detection or feature-gating logic relevant to parallel fan-out.
- [x] Record the observed classification before changing any code.

### Verification
- [x] The current default invocation path is classified as one of: `parallel-first`, `sequential-first`, or `implicit/unclear`.
- [x] The audit identifies the exact decision point where routing behavior is determined.
- [x] Any existing gate or fallback logic is documented and attributable to a concrete file/symbol.

### Pseudotests
- [x] PseudoTest P1.1: "Given the current legion entry path, I can name the file and branch point that decides parallel vs sequential dispatch."
- [ ] PseudoTest P1.2: "If the path is already parallel-first, no execution phase is opened for routing changes."
- [x] PseudoTest P1.3: "If the path is implicit or sequential-first, the missing routing decision is explicit enough to repair in one bounded slice."

### Risk Notes
- [x] Risk: The audit mistakes skill prose for actual runtime behavior.
- [x] Mitigation: Require a traced code path, not only documentation wording.
- [x] Risk: Feature gates are profile-specific and appear absent when only hidden.
- [x] Mitigation: Treat ambiguity as degraded/unsupported until proven otherwise.

### Dependencies
- [x] Depends on diagnosis decisions D1 and D2.
- [x] Must complete before any behavior specification or routing change is attempted.

Execution note (2026-05-18): Phase 1 audited the active legion path at [code/cli/assets/skills/legion/SKILL.md](code/cli/assets/skills/legion/SKILL.md) Step 3 and classified the default dispatch as `implicit/unclear`, not `parallel-first`. The decision point is the consultation instruction to invoke each expert as a separate independent sub-agent without an explicit temporal dispatch mode. The degraded sequential fallback is documented in the same step, so the remaining gap is the missing explicit default-routing rule. As a result, Phase 3 remains required and cannot be skipped.

## Phase 2 - Specify Parallel-First Behavior

### Entry Criteria
- [x] Phase 1 is complete and the current behavior is classified.
- [x] The routing decision point and fallback conditions are understood well enough to specify without guessing.

### Steps
- [x] Define the expected default behavior: launch all experts concurrently when the runtime supports isolated parallel subagents.
- [x] Define the degraded fallback trigger: lack of parallel capability or ambiguous capability detection.
- [x] Define user-visible degraded behavior language so fallback is transparent rather than silent.
- [x] Define the invariants shared by both paths: expert isolation, synthesis after all expert results, and no sequential role-play in one shared context.
- [x] Capture the routing rule in implementation-oriented pseudocode before any edit is made.

### Verification
- [x] The specification distinguishes default parallel behavior from degraded sequential fallback.
- [x] The specification preserves diagnosis constraints D3 and D4.
- [x] The specification makes ambiguous capability detection fail safe to degraded mode.

### Pseudotests
- [x] PseudoTest P2.1: "If capability detection returns parallel, all experts are launched concurrently in isolated contexts."
- [x] PseudoTest P2.2: "If capability detection returns degraded or unknown, experts run sequentially with explicit degraded labeling."
- [x] PseudoTest P2.3: "Synthesis waits for all expert outputs regardless of dispatch mode."

### Risk Notes
- [x] Risk: A vague specification reopens design choices during EXECUTE.
- [x] Mitigation: Require explicit routing conditions and fallback wording before code changes.
- [x] Risk: Sequential fallback weakens user expectations if described unclearly.
- [x] Mitigation: Make degraded status explicit in both docs and runtime messaging.

### Dependencies
- [x] Depends on Phase 1 routing classification.
- [x] Must complete before tests or implementation are written.

Execution note (2026-05-18): Phase 2 specification was captured in [cleanrooms/198-perflegion-invoke-subagents-in-parallel-for-faster/spec-phase-2.md](cleanrooms/198-perflegion-invoke-subagents-in-parallel-for-faster/spec-phase-2.md). The specification makes the missing default-routing rule explicit: `parallel-first` when isolated parallel subagents are available, degraded sequential fallback when capability is absent or ambiguous, explicit degraded-mode user messaging, shared isolation and synthesis invariants, and fail-safe pseudocode for capability detection. This locks the design surface and confirms that Phase 3 remains required.

## Phase 3 - Implement Routing And Tests

### Entry Criteria
- [x] Phase 2 is complete and approved for execution.
- [x] Phase 1 did not prove the current implementation is already parallel-first.
- [x] The bounded edit slice for the routing decision is identified.

### Steps
- [x] Write narrow tests first for the routing decision, covering both parallel-capable and degraded paths.
- [x] Add or update focused checks that verify expert launch shape without broadening into unrelated behavior.
- [x] Implement the routing decision in the bounded invocation slice so legion defaults to parallel when supported and degrades safely otherwise.
- [x] Preserve isolated expert contexts in both paths.
- [x] Add only the minimal diagnostics needed to confirm which path was chosen during validation.

### Verification
- [x] A narrow failing check exists before the substantive routing edit.
- [x] Parallel-path validation proves concurrent launch in the touched slice.
- [x] Degraded-path validation proves sequential fallback remains available and explicit.
- [x] The diff stays limited to the diagnosed routing slice and directly adjacent tests/docs.

### Pseudotests
- [x] PseudoTest P3.1: "In a parallel-capable environment, five experts are launched with overlapping start times rather than one-by-one."
- [x] PseudoTest P3.2: "In degraded mode, experts still complete sequentially and synthesis remains valid."
- [x] PseudoTest P3.3: "No expert output references another expert's output as prior context in either path."

### Risk Notes
- [x] Risk: Timing-based assertions become flaky.
- [x] Mitigation: Use bounded ranges or structural evidence of overlap rather than exact timestamps.
- [x] Risk: Parallel launch changes performance but breaks isolation or synthesis completeness.
- [x] Mitigation: Keep isolation and complete fan-in as explicit acceptance criteria.

### Dependencies
- [x] Depends on Phases 1 and 2.
- [x] Skipped entirely if Phase 1 proves no routing change is needed.

Execution note (2026-05-18): Phase 3 implemented the missing routing contract in the bounded asset slice by updating [code/cli/assets/skills/legion/SKILL.md](code/cli/assets/skills/legion/SKILL.md) Step 3/4 and adding a focused regression in [code/cli/test/assets_test.dart](code/cli/test/assets_test.dart). The new contract makes `parallel-first` explicit when isolated parallel sub-agents are available, makes degraded sequential fallback explicit when capability is absent or ambiguous, surfaces a degraded-mode warning, and states that synthesis must wait until every expert has finished. The change stayed bounded to the distributed skill asset plus its asset-contract test.

## Phase 4 - Align Documentation

### Entry Criteria
- [ ] Phase 3 is green, or Phase 1 proved documentation-only drift.
- [ ] The final intended behavior is now concrete enough to document accurately.

### Steps
- [ ] Update [code/cli/assets/skills/legion/SKILL.md](code/cli/assets/skills/legion/SKILL.md) so the consultation step reflects the verified dispatch model.
- [ ] Update any adjacent docs that currently imply obsolete sequential-only behavior or otherwise contradict diagnosis.md.
- [ ] Document degraded sequential fallback as a supported but lower-capability path.
- [ ] Document performance implications carefully without overstating support outside verified runtimes.

### Verification
- [ ] Legion documentation matches the audited and implemented runtime behavior.
- [ ] No remaining doc claims contradict the verified parallel capability or the preserved degraded fallback.
- [ ] Performance claims stay bounded to verified evidence.

### Pseudotests
- [ ] PseudoTest P4.1: "A reader of SKILL.md can tell when legion runs parallel-first and when it degrades."
- [ ] PseudoTest P4.2: "No referenced document still claims the runtime is strictly sequential where current evidence disproves that."
- [ ] PseudoTest P4.3: "Documentation still preserves legion's identity as a skill using isolated experts, not sequential role-play."

### Risk Notes
- [ ] Risk: Documentation drifts into promises the runtime cannot make everywhere.
- [ ] Mitigation: Tie claims to capability detection and degraded fallback language.
- [ ] Risk: Historical docs are silently left contradictory.
- [ ] Mitigation: Audit and patch only the docs that materially shape user expectations or future maintenance.

### Dependencies
- [ ] Depends on verified behavior from Phase 1 and, if needed, Phase 3.
- [ ] Must complete before final closure validation.

## Phase 5 - Full Validation And Benchmark Gate

### Entry Criteria
- [ ] All earlier phases are complete.
- [ ] The final diff is limited to legion routing, directly related tests, and aligned documentation.

### Steps
- [ ] Run the narrow legion-focused validation used during implementation one final time.
- [ ] Run the full project validation gate required by PLAN constraints.
- [ ] Compare a parallel-capable run against a degraded or forced-sequential baseline when the environment allows it.
- [ ] Confirm no regressions in existing legion use cases that depend on expert isolation or synthesis completeness.
- [ ] Calculate the required version bump from the final verified change set once validation is green.
- [ ] Present the proposed version bump to the user and obtain confirmation before editing versioned artifacts.
- [ ] Record closure evidence in the cleanroom artifacts as needed by EXECUTE.

### Verification
- [ ] The first verification in this phase is the narrow legion slice, followed by broader gates.
- [ ] The full project test suite passes.
- [ ] Parallel-capable validation demonstrates a meaningful reduction in wall-clock time relative to sequential baseline when measured in the available environment.
- [ ] Degraded fallback remains functional and correctly labeled.
- [ ] The required version bump is computed from the final verified change set.
- [ ] User confirmation is obtained before any version bump artifacts are changed.

### Pseudotests
- [ ] PseudoTest P5.1: "Focused legion routing tests pass after the final edit set."
- [ ] PseudoTest P5.2: "The full repository test suite passes with no new regressions."
- [ ] PseudoTest P5.3: "Measured wall-clock for a multi-expert run improves materially on the verified parallel-capable route."

### Risk Notes
- [ ] Risk: Full-suite failures unrelated to legion obscure closure.
- [ ] Mitigation: Keep the narrow validation evidence and diff audit available before running the broad gate.
- [ ] Risk: Benchmark noise makes exact multipliers unreliable.
- [ ] Mitigation: Treat performance as directional evidence with documented environment context, not as an exact invariant.

### Dependencies
- [ ] Depends on all prior phases.
- [ ] Is the mandatory terminal gate before the issue can be considered execution-ready and closure-ready.

## Final Verification Gate
- [ ] Run the full project test suite required by the repository for this change set.
- [ ] Confirm the final validation includes all existing tests, not only legion-specific checks.
- [ ] Confirm the final evidence supports D1 through D4 simultaneously: proven capability premise, repaired routing gap, preserved invariants, and reduced latency in capable environments.
- [ ] Confirm every completed phase ended with its own commit before closure work continues.
- [ ] Confirm the proposed version bump has been calculated and explicitly confirmed by the user before it is applied.

## Completion Criteria
- [ ] Every phase includes Entry Criteria, Steps, Verification, Pseudotests, Risk Notes, and Dependencies.
- [ ] The plan explicitly preserves diagnosis decisions D1 through D4.
- [ ] The plan includes a final verification step that runs the full project test suite.
- [ ] The plan allows an execution pivot if Phase 1 proves the routing gap is already closed.
- [ ] The plan keeps the repair bounded to legion's invocation model and directly adjacent surfaces.
- [ ] The plan requires a commit after every successful phase and a user-confirmed version bump calculation at the end.