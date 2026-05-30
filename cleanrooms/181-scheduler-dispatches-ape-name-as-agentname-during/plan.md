---
id: plan
title: "Plan - Scheduler dispatch contract audit"
date: 2026-05-29
status: active
tags: [plan, scheduler, dispatch, firmware]
author: DESCARTES
---

# Plan - Scheduler dispatch contract audit (#181)

**Hypothesis:** If we execute these phases in order, we will either confirm that issue #181 is already satisfied end to end or make only the minimal contract-preserving changes needed to keep firmware assets, packaged assets, and regression coverage aligned around the decoupled dispatch rule.

**Falsification:** If any targeted check shows that the scheduler still derives runtime `agentName` from `ape.name`, or if the packaged/runtime smoke contradicts the documented contract, stop execution, record the deviation, and return to ANALYZE.

**Diagnosis anchors:**
- Decision 1: treat the effective APE prompt as the complete runtime contract.
- Decision 2: dispatch via a generic/current sub-agent path, never by `agentName = ape.name`.
- Decision 3: preserve this decoupling in regression tests.

**Ordering rule for this cycle:** Move from the cheapest falsification step to the broadest confirmation step: static contract evidence -> isolated firmware regression gate -> conditional source/build repair -> packaged runtime smoke -> full CLI regression -> version bump proposal. Do not advance while a cheaper predecessor phase can still falsify the diagnosis.

**Phase-close rule for this cycle:** No execution phase is complete until its named verification result is recorded and that phase ends with a successful issue-181-scoped commit. Validation-only phases may commit cleanroom/evidence updates; repair phases must keep the commit bounded to the diagnosed dispatch-contract slice.

**Verification rule for this cycle:** Every phase must name both the concrete check to run and the expected pass/fail signal. The last executable verification step remains the full CLI suite gate in Phase 4; Phase 5 exists only to calculate/propose the required version bump after Phase 4 is green.

---

## Phase 0: Freeze the contract surface

**Entry criteria:** Approved diagnosis exists at `cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/diagnosis.md`; no implementation work has started; the branch is ready to record a Phase 0 closeout commit.

**Dependencies:** None.

**Risk note:** The diagnosis says scheduler behavior is instruction-driven. Prompt drift can live entirely in assets, so the first deliverable must be a baseline of the exact contract strings.

- [ ] Re-read the source firmware asset `code/cli/assets/agents/inquiry.agent.md` and the packaged mirror `code/cli/build/assets/agents/inquiry.agent.md`.
- [ ] Re-read the regression guard in `code/cli/test/firmware_agent_test.dart`.
- [ ] Reconfirm the runtime smoke expectation captured in `/memories/repo/release-qa.md`: named dispatch fails without a matching custom agent, while generic dispatch succeeds with the same assembled prompt.
- [ ] Record whether the issue is a true implementation gap or a validation-only closeout candidate.
- [ ] End Phase 0 with a successful issue-181-scoped commit that records the captured contract baseline in the cleanroom artifacts and states whether execution proceeds as validation-only or repair-driven.

**Verification / test definition:**
```text
assert source asset contains "iq ape prompt --name <ape.name>"
assert source asset contains "generic/current sub-agent path"
assert source asset contains "Do NOT set `agentName` from `ape.name`"
assert build asset contains the same three contract strings
assert firmware_agent_test.dart still checks the generic path and the agentName prohibition
assert a successful Phase 0 commit exists and is limited to issue-181 contract-baseline evidence
```

**TDD applicability:** None. This phase is evidence capture, not code change.

## Phase 1: Run the narrow regression gate

**Entry criteria:** Phase 0 is complete and committed; the exact contract strings and touched files are identified.

**Dependencies:** Phase 0 committed.

**Risk note:** If the narrow gate is skipped, EXECUTE can miss a contract regression hidden behind a broad green suite.

- [ ] Run the targeted firmware contract test first.
- [ ] Do not widen to packaged smoke or the full CLI suite until this isolated gate has settled GREEN or RED.
- [ ] If the targeted test is already GREEN, record that the current source contract matches diagnosis decisions 1-3.
- [ ] If the targeted test is RED, capture the failing assertion before editing anything.
- [ ] End Phase 1 with a successful issue-181-scoped commit that records the narrow-gate result; if the test is RED, the commit must capture the failure evidence before Phase 2 begins.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/firmware_agent_test.dart"
expect exit_code == 0 when the current firmware contract already matches diagnosis decisions 1-3
if exit_code != 0:
  capture the failing assertion and stop before Phase 2 edits
assert a successful Phase 1 commit exists before Phase 2 or Phase 3 begins
```

**TDD applicability:** Yes. This is the RED -> GREEN gate for any contract drift in the scheduler firmware instructions.

## Phase 2: Repair source and packaged asset drift only if the gate is red

**Entry criteria:** Phase 1 produced a concrete mismatch in the source asset, packaged build asset, or both, and the red evidence is already committed.

**Dependencies:** Phase 1 must be red and committed, or Phase 0 must have shown and committed a concrete source/build divergence.

**Risk note:** The diagnosis identifies mirrored firmware assets as a specific regression risk. Editing only one side recreates the same problem under a different file path.

- [ ] Restore the source firmware wording in `code/cli/assets/agents/inquiry.agent.md` so it treats the effective APE prompt as the full contract and explicitly forbids deriving `agentName` from `ape.name`.
- [ ] Bring `code/cli/build/assets/agents/inquiry.agent.md` back into semantic alignment with the source asset, either by regenerating the build artifact or by applying the equivalent minimal update.
- [ ] Keep the edit surface limited to the dispatch contract; do not reopen unrelated firmware instructions.
- [ ] End Phase 2 with a successful issue-181-scoped commit that contains only the dispatch-contract repair and its directly related source/build/test mirror updates.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/firmware_agent_test.dart"
expect exit_code == 0 after the source/build contract repair
run "cd code/cli && rg \"generic/current sub-agent path|Do NOT set `agentName` from `ape.name`|iq ape prompt --name <ape.name>\" assets/agents/inquiry.agent.md build/assets/agents/inquiry.agent.md"
expect both assets report the same three dispatch-contract strings
assert a successful Phase 2 commit exists and its diff stays bounded to the diagnosed contract surfaces
```

**TDD applicability:** Yes. Stay RED -> GREEN on the targeted firmware contract test before widening validation.

## Phase 3: Reconfirm the runtime behavior the diagnosis relies on

**Entry criteria:** The narrow firmware gate is green and committed, whether it stayed green in Phase 1 or was restored by Phase 2, and any required asset repair is complete and committed.

**Dependencies:** Phase 1 committed; Phase 2 only when required and committed, with the narrow gate rerun green before Phase 3 starts.

**Risk note:** Passing string-level assertions is necessary but not sufficient. The repo memory documents a concrete runtime distinction between failing named dispatch and succeeding generic dispatch; that behavior must remain true after any asset changes.

**Ordering note:** This packaged smoke stays after the narrow gate on purpose; otherwise a runtime failure would not tell us whether the problem is contract wording, build mirroring, or packaging.

- [ ] Build the CLI package so the packaged binary uses the paired `build/assets` tree.
- [ ] Run the packaged binary by explicit path from the current issue-181 workspace first; only fall back to a temp git repo if a clean bootstrap is needed. This keeps runtime asset resolution bound to `code/cli/build/assets`, matching the repository QA note.
- [ ] Capture the packaged DESCARTES prompt with `code/cli/build/bin/inquiry.exe ape prompt --name descartes` from the same workspace that will be used for the dispatch smoke.
- [ ] Reconfirm diagnosis decision 2 by replaying the repository-QA observation: named dispatch to an APE identity is not required, while generic/current dispatch with the same assembled prompt remains viable.
- [ ] If the smoke contradicts the diagnosis, stop and annotate a deviation instead of forcing execution forward.
- [ ] End Phase 3 with a successful issue-181-scoped commit that records the packaged smoke outcome; if the smoke forces a deviation stop, the commit must capture that deviation explicitly.

**Verification / test definition:**
```text
run "pwsh -File code/cli/scripts/build.ps1"
expect build exits 0 and produces code/cli/build/bin/inquiry.exe
workspace := current issue-181 repo root, unless a clean bootstrap is required
prompt = run "code/cli/build/bin/inquiry.exe ape prompt --name descartes" from workspace
expect exit_code == 0
expect prompt contains the same PLAN-owned contract used in Phase 0
expect prompt still forbids deriving `agentName` from `ape.name`
runtime_smoke := repository QA harness/sequence recorded in /memories/repo/release-qa.md, using the packaged prompt above
dispatch(runtime_smoke, prompt, agentName: "descartes") => expect failure when no matching custom agent exists
dispatch(runtime_smoke, prompt, genericCurrentSubagentPath, no agentName) => expect success
if runtime_smoke cannot reproduce the named/generic split:
  stop and record a deviation against diagnosis decision 2 before Phase 4
assert a successful Phase 3 commit exists before Phase 4 begins
```

**TDD applicability:** None. This phase is packaged/runtime confirmation.

## Phase 4: Run full CLI regression as final verification

**Entry criteria:** Prior phases are complete and committed; any deviations are resolved or documented.

**Dependencies:** Phases 1-3 complete and committed.

**Risk note:** The PLAN contract requires a final full-suite run. Without it, a local green fix can still regress unrelated CLI behaviors.

- [ ] Run `dart analyze` in `code/cli` as a structural sanity check.
- [ ] Run the full existing CLI test suite with `dart test`.
- [ ] Confirm the dispatch-contract tests are still green as part of the full suite, not only in isolation.
- [ ] Do not close the issue while the full suite is red for reasons introduced by this work.
- [ ] End Phase 4 with a successful issue-181-scoped commit that records the final full CLI regression result before any release-metadata work begins.

**Verification / test definition:**
```text
run "cd code/cli && dart pub get"
expect exit_code == 0
run "cd code/cli && dart analyze"
expect exit_code == 0
run "cd code/cli && dart test"
expect exit_code == 0
assert the full CLI suite remains green, including the dispatch-contract coverage exercised earlier
assert Phase 4 remains the last executable validation step in the plan
assert a successful Phase 4 commit exists before Phase 5 begins
```

**TDD applicability:** None. This is final regression confirmation across the full existing CLI suite.

## Phase 5: Calculate and propose the required version bump

**Entry criteria:** Phase 4 is green and committed; the final verified issue-181 change set is known; the full CLI suite run in Phase 4 remains the last executable verification step.

**Dependencies:** Phase 4 committed.

**Risk note:** Repository policy requires a version bump for every merged issue. Sizing the bump against a stale baseline, or forgetting synchronized version surfaces, would make the closeout incomplete even if the dispatch contract is already green.

- [ ] Run `git fetch origin --prune` and compare the final verified issue-181 change set against `origin/main` before sizing the bump.
- [ ] Calculate the necessary semantic version bump from the final verified change set and record the explicit proposal in the cleanroom artifacts.
- [ ] Record the synchronized version surfaces that will need the approved release number when EXECUTE applies the bump: `code/cli/pubspec.yaml`, `code/cli/lib/src/version.dart`, and `code/site/index.html`.
- [ ] Present the proposed version bump to the user for confirmation before editing any versioned artifact.
- [ ] End Phase 5 with a successful issue-181-scoped commit that records the proposed/calculated bump and its approval state; if confirmation is still pending, leave the phase open instead of implying completion.

**Verification / test definition:**
```text
run "git fetch origin --prune"
expect exit_code == 0
compare final verified issue-181 diff against origin/main
expect an explicit semver proposal is written down
assert the proposal names code/cli/pubspec.yaml, code/cli/lib/src/version.dart, and code/site/index.html as synchronized version surfaces
assert Phase 4 remains the last executable validation step; Phase 5 adds no broader test gate
assert a successful Phase 5 commit exists before issue-closure work continues
```

**TDD applicability:** None. This phase is release-metadata planning and semver sizing after the final verification gate is already green.

---

## Dependency summary

| Phase | Depends on | Why |
|---|---|---|
| 0 | none | establish the exact contract surface and its first closeout commit before any edit |
| 1 | 0 | prove whether the diagnosed contract is already green from a committed baseline |
| 2 | 1 (red only) | repair only when the narrow gate exposes drift and that red evidence is already committed |
| 3 | 1, 2 if needed | confirm runtime behavior, not just string-level wording, from committed contract state |
| 4 | 1-3 | finish with the full existing CLI suite as the last executable verification step |
| 5 | 4 | calculate/propose the mandatory version bump after final verification is committed |

## Expected execution outcomes

- If Phases 0-1 are already green, the issue may resolve as a no-code validation cycle plus packaged/runtime confirmation, but every completed phase still needs its own successful closeout commit.
- If Phase 2 is required, the only authorized edit slice is the dispatch contract surface and its packaged mirror.
- Phase 4 remains the last executable verification step and must end with the full CLI suite green before release-metadata work starts.
- Phase 5 must calculate/propose the required version bump from the final verified change set and name the synchronized version surfaces before issue closeout.