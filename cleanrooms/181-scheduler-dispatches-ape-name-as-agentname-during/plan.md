---
id: plan
title: "Plan - Scheduler dispatch contract audit"
date: 2026-05-29
status: active
tags: [plan, scheduler, dispatch, firmware]
author: DESCARTES
---

# Plan - Scheduler dispatch contract audit (#181)

**Hypothesis:** If execution first treats the rejected Phase 0 deviation as a hard boundary between committed-baseline proof and candidate working-tree repair, then locks the decoupled dispatch rule into the committed regression guard using the exact firmware contract strings already evidenced in the local guard, then aligns source and packaged firmware assets to those same strings, then repeats packaged QA under explicit state control plus an explicitly identified host-side dispatch smoke, then synchronizes release metadata under the repository's version-sync guard, and only then runs the full project test suite, issue #181 can be resolved without mistaking local coherence for committed proof.

**Falsification:** Stop execution, annotate a deviation, and return to ANALYZE if any phase shows one of these conditions:
- the committed baseline cannot be described separately from the working-tree repair;
- the committed regression guard still cannot express the decoupled rule clearly enough to distinguish RED from GREEN;
- packaged/runtime behavior under an explicit valid APE state still depends on `agentName = ape.name`;
- workspace-sensitive QA cannot be made reproducible by fixing binary path, working directory, and explicit `--state` input;
- the final full-project verification fails for regressions introduced by the issue-181 slice.

**Diagnosis anchors:**
- Decision 1: separate committed baseline evidence from working-tree repair evidence.
- Decision 2: treat source/build contract drift as the live problem under analysis.
- Decision 3: treat the decoupled regression rule as provisional until it exists in the committed test baseline.
- Decision 4: distinguish local coherence from committed-baseline proof.
- Decision 5: reframe the issue from "already resolved runtime behavior" to alignment of contract and evidence surfaces.

**Adjacent evidence anchors:**
- Confirmed finding F4: the rejected Phase 0 EXECUTE result is a planning constraint about baseline integrity, not a procedural footnote.
- Confirmed finding F5: fresh packaged QA only counts as local support when binary path, working directory, and explicit valid `--state` are controlled.
- Confirmed finding F6: the same packaged QA evidence can look like success or failure unless workspace-local state is named explicitly.
- `code/cli/test/firmware_agent_test.dart` already names the exact issue-181 contract strings to preserve: `generic/current sub-agent path`, omit `agentName`, `independent of APE identity`, and Do NOT set `agentName` from `ape.name`.
- `code/cli/assets/apes/socrates.yaml` and `code/cli/assets/apes/descartes.yaml` provide the explicit valid packaged-QA controls `clarification` and `decomposition`, so Phase 4 does not invent runtime states.
- `code/cli/test/version_sync_test.dart` is the repository's targeted release-metadata guard for Phase 5.
- `cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md` remains the authoritative deviation record for committed-vs-working-tree contamination.

**Ordering rule for this cycle:** Remove ambiguity before repairing behavior: baseline boundary -> regression guard -> source contract -> packaged mirror -> controlled packaged QA -> release metadata -> full project verification. Do not widen validation while a cheaper predecessor phase can still falsify the diagnosis.

**Phase-close rule for this cycle:** A phase closes only when its deliverable is recorded, its verification block has a clear pass/fail result, and no unchecked ambiguity remains inside that phase's scope. If verification contradicts the diagnosis anchor that phase depends on, append a deviation note and stop instead of continuing.

**Approval immutability rule for this cycle:** Once the user approves this plan, phase order, phase titles, dependencies, and test definitions stay fixed. During EXECUTE, only checkboxes and explicit deviation annotations may change.

**Verification rule for this cycle:** Every phase names the concrete checks to run and the pass/fail signal that decides whether execution may continue. The final executable verification step for the whole plan is the full project test suite across every existing test surface in this repository.

---

## Phase 0: Re-establish the committed baseline boundary

**Entry criteria:** Approved diagnosis exists at `cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/diagnosis.md`; `cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/phase-0-contract-baseline.md` exists; execution has not yet treated the current working tree as committed proof.

**Dependencies:** None.

**Risk note:** Diagnosis decisions 1, 4, and 5 make the baseline boundary a first-class deliverable. If committed files and local repairs are read as one surface, every later GREEN result becomes ambiguous.

- [ ] Read the committed `HEAD` version of `code/cli/assets/agents/inquiry.agent.md` separately from the working-tree file.
- [ ] Read the committed `HEAD` version of `code/cli/build/assets/agents/inquiry.agent.md` separately from the working-tree file.
- [ ] Read the committed `HEAD` version of `code/cli/test/firmware_agent_test.dart` separately from the working-tree file.
- [ ] Record every issue-181-relevant committed-vs-working-tree difference as baseline evidence, using `phase-0-contract-baseline.md` as the authoritative deviation anchor.
- [ ] Record the rejected Phase 0 EXECUTE result as a hard planning constraint: any pre-existing issue-181 working-tree edit counts as candidate repair to keep or reapply deliberately, not as committed proof.
- [ ] Freeze three packaged-QA surfaces explicitly: the controlled smoke must use binary path `code/cli/build/bin/inquiry.exe`, a chosen working directory, and explicit valid `--state` values derived from the APE definitions (`clarification` for `socrates`, `decomposition` for `descartes`); the ambient repo-root smoke without `--state` is documentation-only evidence of workspace-sensitive success; the ambient `code/cli` smoke without `--state` is documentation-only negative control expected to reproduce the `_DONE` failure. Neither ambient run may replace the explicit-state verdict.
- [ ] Cross-check `analyze/confirmed.md` findings F4-F6 and `/memories/repo/release-qa.md` against those frozen QA modes so committed proof, local coherence, and workspace sensitivity remain separate claims.
- [ ] Record whether execution starts from a genuinely clean committed baseline or from a local repair that may only count as candidate evidence.

**Verification / test definition:**
```text
committed_source = git show HEAD:code/cli/assets/agents/inquiry.agent.md
working_source = read code/cli/assets/agents/inquiry.agent.md
committed_build = git show HEAD:code/cli/build/assets/agents/inquiry.agent.md
working_build = read code/cli/build/assets/agents/inquiry.agent.md
committed_test = git show HEAD:code/cli/test/firmware_agent_test.dart
working_test = read code/cli/test/firmware_agent_test.dart
assert committed_source was reviewed separately from working_source
assert committed_build was reviewed separately from working_build
assert committed_test was reviewed separately from working_test
assert phase-0-contract-baseline.md names every issue-181-relevant committed-vs-working-tree difference
assert the rejected Phase 0 EXECUTE result is recorded as a constraint on how working-tree evidence may be used
assert packaged QA preconditions name explicit binary path, chosen working directory, explicit valid --state input derived from the APE definitions, an ambient repo-root smoke, and an ambient code/cli smoke
assert both ambient modes are documented as workspace-sensitivity evidence only and never as substitutes for the explicit-state verdict
assert confirmed.md F4-F6 and /memories/repo/release-qa.md are cross-checked against the frozen QA modes so baseline proof and workspace-sensitive smoke are not treated as the same evidence
```

**TDD applicability:** None. This phase establishes evidence boundaries, not behavior.

Deviation anchor already established (2026-05-29): `phase-0-contract-baseline.md` records that the source firmware and firmware regression guard already contain uncommitted issue-slice edits, so execution cannot treat the current working tree as clean baseline proof.

## Phase 1: Lock the decoupled rule into the committed regression guard

**Entry criteria:** Phase 0 has separated committed baseline evidence from working-tree repairs; the exact committed and working-tree contents of the firmware guard are known.

**Dependencies:** Phase 0 complete.

**Risk note:** Diagnosis decision 3 says the decoupled rule is only provisional until it exists in the committed regression baseline. Without this phase, a green runtime smoke can still overstate the repository's committed guarantees.

- [ ] Compare the committed `code/cli/test/firmware_agent_test.dart` guard against the exact issue-181 contract strings already evidenced in the working-tree guard: `generic/current sub-agent path`, omit `agentName`, `independent of APE identity`, Do NOT set `agentName` from `ape.name`, and rejection of `@<ape.name>`.
- [ ] If the committed test already requires those exact strings and rejects APE-name-bound dispatch syntax, record that no RED setup edit is needed.
- [ ] Otherwise, add the minimal regression assertions that require those exact strings and the rejection of `@<ape.name>`.
- [ ] Run the targeted firmware contract test immediately after the guard is in place.
- [ ] Record whether the first result is immediate GREEN because the committed source already matches the guard, or intentional RED because the source/build contract still drifts.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/firmware_agent_test.dart"
if the guard had to be strengthened:
  expect the first run to expose RED against any remaining source/build drift
else:
  expect the first run to stay GREEN
assert code/cli/test/firmware_agent_test.dart now encodes 'generic/current sub-agent path'
assert code/cli/test/firmware_agent_test.dart now encodes 'omit `agentName`'
assert code/cli/test/firmware_agent_test.dart now encodes 'independent of APE identity'
assert code/cli/test/firmware_agent_test.dart now encodes 'Do NOT set `agentName` from `ape.name`'
assert code/cli/test/firmware_agent_test.dart rejects '@<ape.name>' dispatch syntax
assert the phase output states clearly whether execution is entering GREEN confirmation or RED -> GREEN repair
```

**TDD applicability:** Yes. This is the RED gate that turns the diagnosis into an executable regression contract.

## Phase 2: Align the source-of-truth firmware contract

**Entry criteria:** Phase 1 has established the committed regression guard; the source asset still diverges from that guard, or Phase 1 recorded that it already matches and only needs confirmation.

**Dependencies:** Phase 1 complete.

**Risk note:** Diagnosis decisions 2 and 5 identify the source firmware contract as a live problem surface. Because scheduler behavior is instruction-driven, a source-side wording defect is a runtime defect.

- [ ] Update `code/cli/assets/agents/inquiry.agent.md` so `iq ape prompt --name <ape.name>` remains prompt assembly only, while runtime dispatch says `generic/current sub-agent path`, tells the runtime to omit `agentName`, and remains `independent of APE identity`.
- [ ] Preserve the explicit prohibition Do NOT set `agentName` from `ape.name` in the source asset.
- [ ] Keep the edit surface bounded to the dispatch-contract instructions named in diagnosis decisions 1-3.
- [ ] Re-run `dart test test/firmware_agent_test.dart` immediately after the source edit.
- [ ] Record the exact source wording that Phase 3 must mirror into the packaged asset.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/firmware_agent_test.dart"
expect exit_code == 0
assert code/cli/assets/agents/inquiry.agent.md contains "iq ape prompt --name <ape.name>"
assert code/cli/assets/agents/inquiry.agent.md contains 'generic/current sub-agent path'
assert code/cli/assets/agents/inquiry.agent.md contains 'omit `agentName`'
assert code/cli/assets/agents/inquiry.agent.md contains 'independent of APE identity'
assert code/cli/assets/agents/inquiry.agent.md contains 'Do NOT set `agentName` from `ape.name`'
assert code/cli/assets/agents/inquiry.agent.md no longer requires named dispatch as the runtime path
```

**TDD applicability:** Yes. This is the GREEN step for the Phase 1 regression gate.

## Phase 3: Align the packaged build mirror

**Entry criteria:** Phase 2 has produced a GREEN source contract and a stable wording to mirror.

**Dependencies:** Phase 2 complete.

**Risk note:** Diagnosis decisions 2 and 5 explicitly identify source/build contract drift as part of the live problem. Leaving `code/cli/build/assets` stale would recreate the same ambiguity under a different file path.

- [ ] Regenerate or minimally update `code/cli/build/assets/agents/inquiry.agent.md` from the aligned source contract.
- [ ] Compare source and packaged assets only on the exact issue-181 dispatch-contract strings named in Phase 2, rather than on paraphrases.
- [ ] Record any intentional difference outside the dispatch-contract slice as out of scope rather than letting it blur this issue.
- [ ] Do not widen the edit surface beyond the packaged mirror needed for the issue-181 contract.

**Verification / test definition:**
```text
source = read code/cli/assets/agents/inquiry.agent.md
packaged = read code/cli/build/assets/agents/inquiry.agent.md
required_strings = [
  'iq ape prompt --name <ape.name>',
  'generic/current sub-agent path',
  'omit `agentName`',
  'independent of APE identity',
  'Do NOT set `agentName` from `ape.name`',
]
for each required_string in required_strings:
  assert source contains required_string
  assert packaged contains required_string
assert code/cli/build/assets/agents/inquiry.agent.md no longer drifts from the source asset on issue-181 wording
```

**TDD applicability:** None. This phase mirrors an already-green contract into the packaged surface.

## Phase 4: Reproduce packaged runtime behavior under controlled state

**Entry criteria:** Phases 1-3 are green; the packaged mirror is aligned; the QA preconditions frozen in Phase 0 are available.

**Dependencies:** Phase 3 complete.

**Risk note:** Diagnosis decision 4, confirmed findings F5-F6, and the repository QA notes show that packaged evidence splits into two different proof surfaces: packaged prompt assembly is locally observable from the CLI binary, but named-vs-generic dispatch proof only exists in the host runtime that actually honors the agent dispatch contract. This phase must keep those surfaces separate instead of treating prompt-string inspection alone as dispatch proof.

- [ ] Identify the concrete host-side issue-181 smoke procedure already used to prove named-failure vs generic-success, and record its runtime, exact invocation surface, and the precondition that no matching custom agent exists.
- [ ] If only the narrative bullet in `/memories/repo/release-qa.md` exists and no reusable smoke procedure can be named, record a deviation and stop instead of inventing a new runtime proof during EXECUTE.
- [ ] Build the CLI package with `code/cli/scripts/build.ps1` so runtime smoke uses the paired `build/assets` tree.
- [ ] Run the packaged binary by explicit path and assemble prompts with explicit valid APE states taken from the APE definitions (`clarification` for `socrates`, `decomposition` for `descartes`) instead of ambient `.inquiry/state.yaml`.
- [ ] Treat each assembled packaged prompt as the exact runtime instruction surface that the host dispatch smoke must consume; do not infer dispatch success from prompt assembly alone.
- [ ] Replay the repository-QA distinction from `/memories/repo/release-qa.md` for both `socrates` and `descartes` using that identified host-side smoke procedure, because the recorded failure mode mentions both identities.
- [ ] For each packaged prompt, verify in that host runtime that named dispatch to the APE identity fails without a matching custom agent while generic/current dispatch succeeds with omitted `agentName`.
- [ ] Run one ambient smoke from the repo root and one ambient smoke from `code/cli`, both without the explicit `--state` override, only to document workspace sensitivity; do not let either ambient result replace the explicit-state verdict.
- [ ] If the explicit-state smoke contradicts diagnosis decisions 2 or 4, record a deviation and stop.

**Verification / test definition:**
```text
host_smoke = locate existing issue-181 dispatch smoke procedure already used for release QA
if host_smoke is null:
  record deviation and stop
assert host_smoke names runtime, exact invocation surface, and the no-custom-agent precondition
run "pwsh -File code/cli/scripts/build.ps1"
expect exit_code == 0
for each (ape, state) in [("socrates", "clarification"), ("descartes", "decomposition")]:  # initial_state from the APE definitions
  prompt = run "code/cli/build/bin/inquiry.exe ape prompt --name <ape> --state <state>"
  expect prompt exit_code == 0
  expect prompt contains the generic/current dispatch wording
  expect prompt contains the explicit prohibition on deriving agentName from ape.name
  named_result = run host_smoke with the same prompt and agentName = <ape>
  expect named_result == failure when no matching custom agent exists
  generic_result = run host_smoke with the same prompt and agentName omitted
  expect generic_result == success
ambient_root = run the packaged prompt from repo root without --state
record ambient_root as workspace-sensitivity evidence only
ambient_cli = run the packaged prompt from code/cli without --state
record ambient_cli as workspace-sensitivity evidence only
```

**TDD applicability:** None. This phase validates runtime evidence under controlled preconditions.

## Phase 5: Synchronize release metadata for the verified issue slice

**Entry criteria:** Phase 4 has confirmed the decoupled dispatch rule under controlled packaged QA; no unresolved deviations remain.

**Dependencies:** Phase 4 complete.

**Risk note:** Repository policy requires a version bump for every merged issue, and the repository already ships a targeted version-sync guard. If the dispatch-contract repair is verified but version surfaces remain unsynchronized, the issue is still incomplete.

- [ ] Refresh branch comparison against `origin/main` before choosing the version bump so stale local history cannot mis-state the required release metadata.
- [ ] Determine the required semantic version bump from the final issue-181 change set.
- [ ] Update the synchronized version surfaces `code/cli/pubspec.yaml`, `code/cli/lib/src/version.dart`, and `code/site/index.html`.
- [ ] Update the issue-facing changelog surface required by current repository policy in `code/cli/CHANGELOG.md`.
- [ ] Run `dart test test/version_sync_test.dart` immediately after the version surfaces are updated.
- [ ] Keep the version-metadata diff separate from unrelated product changes.
- [ ] Prepare this phase so the final executable verification still happens after every versioned surface is synchronized.

**Verification / test definition:**
```text
run "git fetch origin --prune"
expect exit_code == 0
assert version selection was compared against origin/main rather than stale local main
run "cd code/cli && dart test test/version_sync_test.dart"
expect exit_code == 0
assert code/cli/pubspec.yaml, code/cli/lib/src/version.dart, and code/site/index.html all contain the same approved version
assert code/cli/CHANGELOG.md names issue #181 in the expected repository format
assert the plan still ends with a full-project test run after this phase completes
```

**TDD applicability:** None. This phase prepares release metadata before the final verification gate.

## Phase 6: Run the full project verification gate

**Entry criteria:** Phases 0-5 are complete; every issue-181 behavior change and versioned surface is in its intended final state.

**Dependencies:** Phases 0-5 complete.

**Risk note:** The PLAN contract requires the final verification step to cover the full project, not only the firmware slice. Repository evidence in `code/cli/test` and `code/vscode/test` shows the existing test surfaces for this repo are the CLI Dart suite plus the VS Code extension unit and integration suites.

- [ ] Restore CLI dependencies and run structural verification from `code/cli` so relative-path tests such as `version_sync_test.dart` resolve correctly.
- [ ] Run the full existing CLI suite from `code/cli`.
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
assert repository test surfaces discovered for this plan are code/cli/test and code/vscode/test
assert every existing project test surface is green
assert this phase is the final executable verification step in the plan
```

**TDD applicability:** None. This phase is the final system-wide confirmation gate.

---

## Dependency summary

| Phase | Depends on | Why |
|---|---|---|
| 0 | none | separate committed proof from working-tree repair before any repair or validation claim |
| 1 | 0 | turn the diagnosis into an executable regression guard before changing the contract |
| 2 | 1 | align the source-of-truth firmware wording to the regression guard |
| 3 | 2 | remove source/build drift after the source contract is green |
| 4 | 3 | validate packaged behavior only after source, build, and test surfaces agree |
| 5 | 4 | synchronize mandatory release metadata only after the behavior is verified |
| 6 | 0-5 | run the full project suite last, after every issue-181 surface is in final form |

## Expected execution outcomes

- If Phase 0 finds that the committed baseline is already aligned, the later phases still run, but they become confirmation phases instead of repair phases.
- If Phase 1 immediately turns GREEN, Phase 2 must still confirm that the source wording and the test guard are describing the same contract, not just passing accidentally.
- If Phase 4 can only assemble prompts locally but cannot replay the host dispatch smoke, that is a deviation in proof surface, not a silent pass.
- If Phase 4 fails only in the ambient-state negative control, that result is evidence about QA preconditions, not by itself proof that the decoupled dispatch rule is wrong.
- Phase 6 remains the final executable verification gate for the entire repository and cannot be replaced by a narrower CLI-only run.