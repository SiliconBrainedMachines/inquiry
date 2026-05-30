---
id: plan
title: "Plan - Scheduler dispatch and control contract alignment"
date: 2026-05-30
status: active
tags: [plan, scheduler, dispatch, control, qa]
author: DESCARTES
---

# Plan - Scheduler dispatch and control contract alignment (#181)

**Hypothesis:** If EXECUTE first re-establishes the clean committed baseline and a clean `.inquiry` QA harness, then locks executable regression guards for both dispatch semantics and EXECUTE control leakage, then aligns the source instruction/code surfaces and packaged mirrors to those guards, then replays packaged and host-side QA from a fresh `.inquiry` trace, then synchronizes release metadata, and only then runs the full project suites, issue #181 can be resolved without confusing working-tree coherence, ambient state, and committed proof.

**Falsification:** Stop execution, annotate a deviation, and return to ANALYZE if any phase shows one of these conditions:
- the committed baseline still cannot be described separately from candidate working-tree repair;
- a clean `.inquiry` QA harness cannot be named and reproduced;
- the regression guards cannot distinguish named dispatch from generic/current dispatch, or cannot distinguish IDLE startup from EXECUTE continuation;
- EXECUTE prompt surfaces still inherit `issue-start`, or same-APE continuation still leaves the active APE stranded at `_DONE` when the plan expects a runnable prompt state;
- the packaged build and source surfaces still drift after rebuild;
- the host-side named-failure versus generic-success smoke cannot be replayed from clean packaged input;
- the final full-project verification fails for regressions introduced by the issue-181 slice.

**Diagnosis anchors:**
- Decision 1: separate committed baseline evidence from working-tree repair evidence.
- Decision 2: treat clean `.inquiry` as a mandatory QA precondition.
- Decision 3: treat source/build contract drift as the live problem under analysis.
- Decision 4: treat EXECUTE-to-ANALYZE reentry as explicit control-plane leakage, not autonomous FSM behavior.
- Decision 5: treat the decoupled regression rule as provisional until it exists in the committed test baseline.
- Decision 6: distinguish local coherence from committed-baseline proof.
- Decision 7: reframe the issue from "already resolved runtime behavior" to alignment of dispatch contract, transition contract, and clean-QA evidence surfaces.

**Adjacent evidence anchors:**
- Confirmed finding F4: the rejected Phase 0 EXECUTE result is a baseline-integrity constraint, not a footnote.
- Confirmed finding F5: admissible QA for this issue must start from clean `.inquiry`.
- Confirmed finding F6: ambient workspace runs and clean QA runs are different evidence classes.
- Confirmed finding F7: `plan_to_execute` and `execute_continue` currently inherit `issue-start`.
- Confirmed finding F8: continuing ANALYZE can preserve `_DONE` and strand SOCRATES prompt assembly.
- `code/cli/test/firmware_agent_test.dart` already names the exact dispatch-contract literals the repair must preserve.
- `code/cli/test/fsm_contract_test.dart`, `code/cli/test/fsm_transition_test.dart`, `code/cli/test/instruction_prompt_loader_test.dart`, `code/cli/test/assets_test.dart`, and `code/cli/test/effect_executor_test.dart` are the nearby executable gates for the control-plane slice.
- `/memories/repo/release-qa.md` already records the named-dispatch failure versus generic-dispatch success distinction and the clean `.inquiry` QA rule.

**Ordering rule for this cycle:** baseline boundary and clean-QA harness -> dispatch regression guard -> control-plane and state-reset guards -> source dispatch contract -> source control contract -> packaged rebuild and mirror check -> clean packaged and host-side QA -> release metadata -> full project verification.

**Phase-close rule for this cycle:** A phase closes only when its deliverable is recorded, its verification block has a clear pass/fail result, and no ambiguity remains inside that phase's scope. If verification contradicts the diagnosis anchor the phase depends on, append a deviation note and stop.

**Approval immutability rule for this cycle:** Once the user approves this plan, phase order, phase titles, dependencies, and verification definitions stay fixed. During EXECUTE, only checkboxes, pass/fail notes, and explicit deviation annotations may change.

**Verification rule for this cycle:** Every phase names the concrete checks to run and the pass/fail signal that decides whether execution may continue. The final executable verification step for the whole plan is the complete existing project test surface, not a narrower slice.

---

## Phase 0: Re-establish the committed baseline and clean-QA boundary

**Entry criteria:** Approved diagnosis exists at `cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/diagnosis.md`; `cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md` exists; execution has not yet treated the current working tree or ambient `.inquiry` state as proof.

**Dependencies:** None.

**Risk note:** Diagnosis decisions 1, 2, and 6 make this phase mandatory. If committed files, working-tree repair, and ambient workspace state are read as one surface, every later GREEN result becomes ambiguous.

- [ ] Read the committed `HEAD` and working-tree contents separately for these issue-181 surfaces: `code/cli/assets/agents/inquiry.agent.md`, `code/cli/build/assets/agents/inquiry.agent.md`, `code/cli/test/firmware_agent_test.dart`, `code/cli/assets/fsm/transition_contract.yaml`, `code/cli/assets/instructions/issue-start.md`, `code/cli/lib/modules/fsm/effect_executor.dart`, `code/cli/test/fsm_contract_test.dart`, `code/cli/test/fsm_transition_test.dart`, `code/cli/test/instruction_prompt_loader_test.dart`, `code/cli/test/assets_test.dart`, and `code/cli/test/effect_executor_test.dart`.
- [ ] Extend `phase-0-contract-baseline.md` if needed so every issue-181-relevant committed-vs-working-tree difference across dispatch, control, and state-reset surfaces is recorded in one authoritative place.
- [ ] Freeze the admissible QA harness: packaged QA must begin in a fresh working directory with no pre-existing `.inquiry` trace, and that clean trace must be created deliberately before packaged smoke runs.
- [ ] Record the exact clean-QA bootstrap to be used later: explicit packaged binary path, fresh working directory, and the sequence of FSM transitions that produces runnable SOCRATES and DESCARTES states without inheriting stale `_DONE`.
- [ ] Record repo-root `.inquiry` and `code/cli/.inquiry` as negative controls only. They may be consulted diagnostically later, but they do not count as admissible proof for this issue.
- [ ] Record explicit `--state` overrides as diagnostic disambiguators only, never as substitutes for a clean `.inquiry` trace.
- [ ] Cross-check diagnosis decisions 2, 4, and 6, confirmed findings F5-F8, and `/memories/repo/release-qa.md` against these frozen evidence classes so clean proof, diagnostic overrides, and ambient negative controls do not get merged later.

**Verification / test definition:**
```text
committed = git show HEAD:<path>
working = read <path>
for each issue-181 surface in phase 0:
  assert committed was reviewed separately from working
assert phase-0-contract-baseline.md names every issue-181-relevant committed-vs-working-tree difference
assert the admissible QA harness starts from a fresh working directory with no pre-existing .inquiry
assert repo-root .inquiry and code/cli/.inquiry are recorded only as diagnostic controls
assert explicit --state overrides are recorded only as diagnostic disambiguators
assert the clean-QA bootstrap names the packaged binary path and the clean transition sequence that yields runnable SOCRATES and DESCARTES states
```

**TDD applicability:** None. This phase freezes evidence boundaries and QA admissibility.

## Phase 1: Lock the dispatch regression guard into executable form

**Entry criteria:** Phase 0 has separated committed baseline evidence from working-tree repairs and frozen the clean-QA boundary.

**Dependencies:** Phase 0 complete.

**Risk note:** Diagnosis decisions 3 and 5 say the decoupled rule is only provisional until it exists in the regression guard. Without this phase, a green runtime smoke can still overstate the committed guarantees.

- [ ] Compare the committed `code/cli/test/firmware_agent_test.dart` against the working-tree guard and isolate the minimum missing assertions.
- [ ] Ensure the guard requires the exact issue-181 literals already evidenced locally: `generic/current sub-agent path`, omit `agentName`, `independent of APE identity`, `Do NOT set agentName from ape.name`, and rejection of `@<ape.name>`.
- [ ] If the committed guard already encodes those constraints exactly, record that no RED setup edit was required.
- [ ] Otherwise, add the minimal assertions needed to make the guard fail on named-dispatch coupling and pass on generic/current dispatch.
- [ ] Run the targeted firmware guard immediately after the assertions are fixed.
- [ ] Record whether the first executable result is immediate GREEN or intentional RED before any source repair.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/firmware_agent_test.dart"
if the guard was strengthened:
  expect the first run to distinguish RED from GREEN on dispatch wording
else:
  expect the first run to stay GREEN
assert code/cli/test/firmware_agent_test.dart contains 'generic/current sub-agent path'
assert code/cli/test/firmware_agent_test.dart contains 'omit agentName'
assert code/cli/test/firmware_agent_test.dart contains 'independent of APE identity'
assert code/cli/test/firmware_agent_test.dart contains 'Do NOT set agentName from ape.name'
assert code/cli/test/firmware_agent_test.dart rejects '@<ape.name>' dispatch syntax
```

**TDD applicability:** Yes. This is the dispatch RED/GREEN gate.

## Phase 2: Lock the control-plane and state-reset guards

**Entry criteria:** Phase 1 has established the dispatch guard; the relevant committed and working-tree control surfaces are known.

**Dependencies:** Phase 1 complete.

**Risk note:** Diagnosis decisions 2, 4, and 7 mean EXECUTE leakage and `_DONE` preservation are not secondary curiosities. If they stay unguarded, EXECUTE can legally drift back into ANALYZE or reopen ANALYZE with a non-invocable APE.

- [ ] Compare the committed and working-tree control tests: `code/cli/test/fsm_contract_test.dart`, `code/cli/test/fsm_transition_test.dart`, `code/cli/test/instruction_prompt_loader_test.dart`, `code/cli/test/assets_test.dart`, and `code/cli/test/effect_executor_test.dart`.
- [ ] Strengthen the transition/contract guards so `plan_to_execute` and `execute_continue` can no longer pass while still injecting `issue-start` or implying `start_analyze` from EXECUTE.
- [ ] Keep `issue-start` tested as an IDLE-to-ANALYZE startup instruction, not as an EXECUTE continuation instruction.
- [ ] Add or strengthen the nearby state-effect guard so continuing ANALYZE after `_DONE` leaves the active APE in a runnable prompt state rather than preserving `_DONE`.
- [ ] Run the targeted control-plane and state-effect tests immediately after the guard changes.
- [ ] Record RED/GREEN separately for prompt-surface leakage and for `_DONE`-state preservation so execution can see which control defect actually fails first.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/fsm_contract_test.dart test/fsm_transition_test.dart test/instruction_prompt_loader_test.dart test/assets_test.dart test/effect_executor_test.dart"
expect the suite to fail RED until the leaked EXECUTE instructions and _DONE continuation behavior are guarded correctly, unless the committed baseline already matches the desired behavior
assert plan_to_execute and execute_continue no longer require issue-start as the green condition
assert issue-start remains tested as a startup-only instruction surface
assert continuing ANALYZE from _DONE is tested to end in a runnable APE state, not _DONE
assert the phase output distinguishes control-leak RED from state-reset RED when they differ
```

**TDD applicability:** Yes. This is the control-plane RED/GREEN gate.

## Phase 3: Align the source-of-truth dispatch contract

**Entry criteria:** Phase 1 is green; the exact dispatch wording required by the guard is known.

**Dependencies:** Phase 1 complete.

**Risk note:** Diagnosis decisions 3 and 7 identify the source firmware contract as one live problem surface. Because scheduler behavior is instruction-driven, wording drift in the source asset is a runtime defect.

- [ ] Update `code/cli/assets/agents/inquiry.agent.md` so prompt assembly still uses `iq ape prompt --name <ape.name>`, while runtime dispatch stays on the generic/current sub-agent path and does not derive `agentName` from `ape.name`.
- [ ] Preserve the explicit prohibition `Do NOT set agentName from ape.name` in the source asset.
- [ ] Keep the edit surface limited to the dispatch-contract slice named in the diagnosis and guarded in Phase 1.
- [ ] Re-run `dart test test/firmware_agent_test.dart` immediately after the source edit.
- [ ] Record the exact source wording that the packaged mirror must reproduce later.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/firmware_agent_test.dart"
expect exit_code == 0
assert code/cli/assets/agents/inquiry.agent.md contains "iq ape prompt --name <ape.name>"
assert code/cli/assets/agents/inquiry.agent.md contains "generic/current sub-agent path"
assert code/cli/assets/agents/inquiry.agent.md contains "omit agentName"
assert code/cli/assets/agents/inquiry.agent.md contains "independent of APE identity"
assert code/cli/assets/agents/inquiry.agent.md contains "Do NOT set agentName from ape.name"
assert code/cli/assets/agents/inquiry.agent.md no longer instructs named dispatch as the runtime path
```

**TDD applicability:** Yes. This is the GREEN step for the dispatch guard.

## Phase 4: Align the source control contract and same-APE continuation behavior

**Entry criteria:** Phase 2 is green or has identified the exact source surfaces that still fail it.

**Dependencies:** Phase 2 complete.

**Risk note:** Diagnosis decisions 2, 4, and 7 say the control defect spans both prompt surfaces and CLI-side state effects. Fixing only one side leaves EXECUTE or reopened ANALYZE in an unsafe intermediate state.

- [ ] Remove IDLE startup instructions from the EXECUTE prompt surfaces in `code/cli/assets/fsm/transition_contract.yaml`. `plan_to_execute` and `execute_continue` must no longer route through `issue-start` or imply `start_analyze`.
- [ ] Keep `code/cli/assets/instructions/issue-start.md` scoped to IDLE/DONE startup before ANALYZE. If its wording changes, keep that scope explicit and update the prompt-loader and asset tests accordingly.
- [ ] Update `code/cli/lib/modules/fsm/effect_executor.dart` so continuing ANALYZE from `_DONE` does not leave SOCRATES stranded in `_DONE`. The post-transition state must be runnable for the active APE.
- [ ] Keep the implementation choice bounded to the observable green condition defined in Phase 2, rather than widening into unrelated FSM redesign.
- [ ] Re-run the targeted control-plane and state-effect test bundle immediately after the source edits.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/fsm_contract_test.dart test/fsm_transition_test.dart test/instruction_prompt_loader_test.dart test/assets_test.dart test/effect_executor_test.dart"
expect exit_code == 0
assert code/cli/assets/fsm/transition_contract.yaml no longer assigns issue-start to plan_to_execute
assert code/cli/assets/fsm/transition_contract.yaml no longer assigns issue-start to execute_continue
assert code/cli/assets/instructions/issue-start.md still describes startup into ANALYZE, not EXECUTE continuation
assert continuing ANALYZE from _DONE now leaves the active APE in a runnable state
```

**TDD applicability:** Yes. This is the GREEN step for the control-plane guard.

## Phase 5: Rebuild the packaged surface and verify mirror alignment

**Entry criteria:** Phases 3 and 4 are green; the source dispatch and control surfaces are stable.

**Dependencies:** Phases 3-4 complete.

**Risk note:** Diagnosis decisions 3 and 6 explicitly identify source/build drift as part of the live problem. Leaving packaged surfaces stale would recreate the same ambiguity under a different path.

- [ ] Rebuild the CLI package with `code/cli/scripts/build.ps1` so the compiled binary and paired `code/cli/build/assets` tree reflect the repaired source surfaces.
- [ ] Compare source versus packaged assets on the exact issue-181 slices only: dispatch firmware, transition contract, and startup instruction scope.
- [ ] Record any difference outside the issue-181 slice as out of scope rather than letting it blur this plan.
- [ ] Confirm that the rebuilt binary exists at `code/cli/build/bin/inquiry.exe` and that the packaged assets tree contains the mirrored agent, FSM, and instruction surfaces needed for QA.

**Verification / test definition:**
```text
run "pwsh -File code/cli/scripts/build.ps1"
expect exit_code == 0
assert code/cli/build/bin/inquiry.exe exists
for each mirrored surface in [
  ("code/cli/assets/agents/inquiry.agent.md", "code/cli/build/assets/agents/inquiry.agent.md"),
  ("code/cli/assets/fsm/transition_contract.yaml", "code/cli/build/assets/fsm/transition_contract.yaml"),
  ("code/cli/assets/instructions/issue-start.md", "code/cli/build/assets/instructions/issue-start.md"),
]:
  assert source and packaged agree on the issue-181 strings
assert the packaged tree is ready for clean-state QA
```

**TDD applicability:** None. This phase mirrors already-green source behavior into the packaged surface.

## Phase 6: Reproduce packaged and host-side behavior from a clean `.inquiry` trace

**Entry criteria:** Phase 5 is complete; the clean-QA harness defined in Phase 0 is available; no unresolved deviations remain.

**Dependencies:** Phase 5 complete.

**Risk note:** Diagnosis decisions 2 and 6, confirmed findings F5-F8, and `/memories/repo/release-qa.md` all say the proof surface is invalid if packaged QA starts from ambient state. This phase must start clean and use ambient state only as a secondary diagnostic control.

- [ ] Create the fresh working directory frozen in Phase 0 and confirm it has no existing `.inquiry`.
- [ ] Use the packaged binary by explicit path to create a clean trace in that directory and drive the minimum FSM transitions needed to obtain runnable SOCRATES and DESCARTES states without relying on manual `--state` overrides.
- [ ] From that clean trace, verify packaged prompt assembly for `socrates` and `descartes` succeeds without inherited `_DONE`.
- [ ] Identify and replay the existing host-side issue-181 smoke procedure that proves named dispatch fails without a matching custom agent while generic/current dispatch succeeds when `agentName` is omitted.
- [ ] If no reusable host-side smoke procedure can be named beyond the narrative note in `/memories/repo/release-qa.md`, record a deviation and stop instead of inventing a new proof surface during EXECUTE.
- [ ] Use explicit `--state` overrides only if the clean-trace smoke needs diagnostic disambiguation. Record them as secondary evidence, not as the primary verdict.
- [ ] Optionally run the current repo-root and `code/cli` ambient smokes afterward as negative controls only, to document that stale `.inquiry` no longer governs the verdict.

**Verification / test definition:**
```text
clean_dir = create fresh working directory with no .inquiry
assert clean_dir has no .inquiry before bootstrap
bootstrap clean trace with code/cli/build/bin/inquiry.exe
drive the minimal FSM transitions that yield runnable socrates and descartes states
run "code/cli/build/bin/inquiry.exe ape prompt --name socrates" from clean_dir
expect exit_code == 0
run "code/cli/build/bin/inquiry.exe ape prompt --name descartes" from clean_dir after the clean transition into PLAN
expect exit_code == 0
host_smoke = locate the existing named-failure versus generic-success procedure
if host_smoke is null:
  record deviation and stop
named_result = run host_smoke with agentName forced to the APE identity and no matching custom agent
expect named_result == failure
generic_result = run host_smoke with agentName omitted
expect generic_result == success
record any explicit --state override or ambient workspace run as diagnostic-only evidence
```

**TDD applicability:** None. This phase validates packaged and host behavior under admissible clean-QA preconditions.

## Phase 7: Synchronize release metadata for the verified issue slice

**Entry criteria:** Phase 6 has confirmed the repaired issue slice under clean packaged QA; no unresolved deviations remain.

**Dependencies:** Phase 6 complete.

**Risk note:** Repository policy requires a version bump for every merged issue, and the repository already has a targeted version-sync guard. If behavior is verified but version surfaces drift, the issue is still incomplete.

- [ ] Refresh branch comparison against `origin/main` before choosing the version bump.
- [ ] Determine the required semantic version bump from the final issue-181 change set.
- [ ] Update the synchronized version surfaces `code/cli/pubspec.yaml`, `code/cli/lib/src/version.dart`, and `code/site/index.html`.
- [ ] Update `code/cli/CHANGELOG.md` in the repository's current issue-facing format.
- [ ] Run `dart test test/version_sync_test.dart` immediately after the version surfaces are updated.
- [ ] Keep version metadata changes separate from unrelated product changes.

**Verification / test definition:**
```text
run "git fetch origin --prune"
expect exit_code == 0
assert version choice was compared against origin/main
run "cd code/cli && dart test test/version_sync_test.dart"
expect exit_code == 0
assert code/cli/pubspec.yaml, code/cli/lib/src/version.dart, and code/site/index.html contain the same approved version
assert code/cli/CHANGELOG.md names issue #181 in the repository format
```

**TDD applicability:** None. This phase synchronizes release metadata before the final gate.

## Phase 8: Run the full project verification gate

**Entry criteria:** Phases 0-7 are complete; every issue-181 behavior change and versioned surface is in final form.

**Dependencies:** Phases 0-7 complete.

**Risk note:** The PLAN contract requires the final verification step to cover the whole project. A narrower slice cannot close the cycle.

- [ ] Restore CLI dependencies and run the full CLI verification from `code/cli`.
- [ ] Restore VS Code extension dependencies in `code/vscode` if needed.
- [ ] Run the VS Code extension unit suite.
- [ ] Run the VS Code extension integration suite.
- [ ] Record the exact pass/fail result of every existing project test surface and stop on the first regression introduced by the issue-181 slice.

**Verification / test definition:**
```text
run "cd code/cli && dart pub get"
expect exit_code == 0
run "cd code/cli && dart analyze"
expect exit_code == 0
run "cd code/cli && dart test"
expect exit_code == 0
run "cd code/vscode && npm ci"
expect exit_code == 0
run "cd code/vscode && npm run test:unit"
expect exit_code == 0
run "cd code/vscode && npm run test:integration"
expect exit_code == 0
assert the full existing project test surface is green
assert this phase is the final executable verification step in the plan
```

**TDD applicability:** None. This is the final system-wide confirmation gate.

---

## Dependency summary

| Phase | Depends on | Why |
|---|---|---|
| 0 | none | separate committed proof, working-tree repair, and clean-QA admissibility before any repair claim |
| 1 | 0 | turn the dispatch diagnosis into an executable regression guard before editing the contract |
| 2 | 1 | turn the control-plane and state-reset diagnosis into executable guards before editing those surfaces |
| 3 | 1 | align the source dispatch contract to the dispatch guard |
| 4 | 2 | align the source control surfaces to the control guard |
| 5 | 3-4 | rebuild packaged surfaces only after both source slices are green |
| 6 | 5 | validate packaged and host behavior only after source and packaged surfaces agree |
| 7 | 6 | synchronize mandatory release metadata only after the repaired behavior is proven |
| 8 | 0-7 | run the full project verification gate last |

## Expected execution outcomes

- If Phase 0 finds that the committed baseline already matches the working tree on one surface, later phases still run, but they become confirmation phases instead of repair phases.
- If Phase 1 is immediately GREEN, Phase 3 still has to confirm that the source dispatch wording and the guard are describing the same contract.
- If Phase 2 is immediately GREEN on one control surface but RED on another, EXECUTE stops at the first failing control defect instead of widening scope.
- If Phase 6 can only pass with explicit `--state` overrides and not from a clean `.inquiry` trace, that is a deviation in QA admissibility, not a silent pass.
- If Phase 6 passes from a clean trace but ambient repo-root or `code/cli` still fails, those ambient failures remain diagnostic controls only.
- Phase 8 remains the final executable verification gate for the entire repository and cannot be replaced by a narrower CLI-only run.