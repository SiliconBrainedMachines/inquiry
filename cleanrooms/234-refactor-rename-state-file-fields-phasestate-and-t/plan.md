---
id: plan
title: "Plan — Issue #234: rename state-file fields to state/issue"
date: 2026-06-04
status: active
tags: [plan, issue-234, state-schema, fsm, t3]
author: descartes
---

# Plan — Issue #234: rename state-file fields to state/issue

## Hypothesis

If execution performs one coordinated cutover across the authoritative `.inquiry/state.yaml` writer, the CLI readers/output surfaces, the transition reader, the scored tests, and the shipped runtime assets, then issue #234 will be resolved inside the approved T3 packet without changing FSM behavior and without adding compatibility shims.

If any verification falsifies that hypothesis, the cycle returns to ANALYZE.

## Bounded decisions from `analyze/diagnosis.md`

- Decision 1: `.inquiry/state.yaml` is the authoritative repository state file.
- Decision 2: this is a naming-alignment refactor only; FSM behavior must not change.
- Decision 3: the target persisted shape is `cycle.state` and `cycle.issue`.
- Decision 4: tests and shipped CLI assets are in scope.
- Operational bound from the runtime packet: use a coordinated cutover only; do not add compatibility shims or broaden into FSM/lifecycle redesign.

## Dependencies

```text
Shared interface inventory lock
            ↓
Phase 1 (init + fsm state RED→GREEN)
            ↓
Phase 2 (fsm transition RED→GREEN)
            ↓
Phase 3 (runtime assets cutover)
            ↓
Phase 4 (five-command scored stop line)
```

- Phase 1 establishes the authoritative `.inquiry/state.yaml` shape and the first user-visible readback surface.
- Phase 2 must follow Phase 1 so transition logic is repointed to a contract that the writer and status reader already prove.
- Phase 3 waits until code/test behavior is stable, then aligns shipped runtime assets to that now-proven contract.
- Phase 4 freezes the worktree and preserves the scored five-command stop line in one state.

## Ordered execution mode

- **Phase 1 and Phase 2 use RED→GREEN.** Update the targeted tests/fixtures first so they encode the renamed contract, observe only rename-caused failures, then update production code to restore green.
- **Phase 3 uses search→edit→search.** Runtime markdown is aligned only after the code path is stable; verification is by targeted `rg` plus readback of edited sections.
- **Phase 4 is a no-edit gate.** Once command 1 of the scored sequence starts, no file edits are allowed until all five commands pass or the run returns to the owning phase.

## Shared interface inventory lock for the persisted state-shape rename

This rename changes a shared persisted interface. Execution must enumerate both construction sites and consumer sites before editing.

### Constructor search strategy

- [ ] Run `rg -n "\.inquiry/state\.yaml|\.ape/state\.yaml|writeAsStringSync|phase:|task:" code/cli/lib code/cli/test code/cli/assets -g "*.{dart,md}"`
- [ ] Run `rg -n "_writeState|setupWorkspace|state.yaml" code/cli/test -g "*.dart"`
- [ ] Treat every hit that authors `.inquiry/state.yaml` content, seeds a test fixture, or instructs a human/agent to write the file as a constructor site.

### Constructor sites to cover

- [ ] `code/cli/lib/modules/global/commands/init.dart` — `_ensureStateYaml`
- [ ] `code/cli/test/init_command_test.dart` — existing-state fixture strings and expected scaffold content
- [ ] `code/cli/test/fsm_state_test.dart` — `setupWorkspace`
- [ ] `code/cli/test/fsm_transition_test.dart` — `_writeState`
- [ ] `code/cli/test/fsm_transition_integration_test.dart` — `_writeState`
- [ ] `code/cli/assets/skills/issue-start/SKILL.md` — state-file write instructions
- [ ] `code/cli/assets/skills/issue-end/SKILL.md` — state-file read/write examples
- [ ] `code/cli/assets/agents/inquiry.agent.md` — IDLE setup instructions and metrics field mapping

### Consumer search strategy

- [ ] Run `rg -n "loadYaml|yaml\['phase'\]|yaml\['task'\]|cycle\['phase'\]|cycle\['task'\]|json\['task'\]|Task:" code/cli/lib code/cli/test code/cli/assets -g "*.{dart,md}"`
- [ ] Run `rg -n "\.inquiry/state\.yaml|\.ape/state\.yaml|phase:|task:|cycle\.phase|cycle\.task" code/cli/test code/cli/assets -g "*.{dart,md}"`
- [ ] Treat every hit that reads the persisted file, exposes the renamed fields in CLI output, or asserts those names in tests/assets as a consumer site.

### Consumer sites to cover

- [ ] `code/cli/lib/modules/fsm/commands/state.dart` — `_loadCurrentState`
- [ ] `code/cli/lib/modules/fsm/commands/state.dart` — `_loadTask` rename site plus `FsmStateOutput` field/constructor and `FsmStateCommand.execute()` return site
- [ ] `code/cli/lib/modules/fsm/commands/state.dart` — `FsmStateOutput.toJson()` / `toText()`
- [ ] `code/cli/lib/modules/fsm/commands/transition.dart` — `_loadCurrentState`
- [ ] `code/cli/test/init_command_test.dart` — assertions over scaffolded state content
- [ ] `code/cli/test/fsm_state_test.dart` — JSON/text expectations
- [ ] `code/cli/test/fsm_transition_test.dart` — transition fixture consumption
- [ ] `code/cli/test/fsm_transition_integration_test.dart` — transition fixture consumption
- [ ] `code/cli/assets/skills/issue-start/SKILL.md` — verification checklist text
- [ ] `code/cli/assets/skills/issue-end/SKILL.md` — state inspection/readback text
- [ ] `code/cli/assets/agents/inquiry.agent.md` — metrics mapping/read instructions

### Adjacent surface explicitly kept out of the rename

- [ ] `code/cli/lib/modules/fsm/commands/transition.dart::_isIssueSelected` continues reading `.ape/context.yaml`; it already uses `issue` and is not the persisted state-file schema being renamed.

---

## Phase 1 — Align init scaffolding and `iq fsm state`

**Depends on:** diagnosis only  
**Implements diagnosis decisions:** 1, 2, 3

### TDD applicability

- [ ] Yes — use RED→GREEN because the existing init/state tests are the executable contract for this rename.
- [ ] RED is complete only when the renamed expectations fail for the planned writer/reader seam, not because of unrelated behavior drift.
- [ ] GREEN is complete only when the same tests pass and the reported FSM state, transitions, APE mapping, and instructions remain unchanged apart from the `task`→`issue` surface rename.

### Entry criteria

- [ ] `analyze/diagnosis.md` remains the authoritative handoff.
- [ ] The shared interface inventory above has been reread and no extra constructor/consumer sites were missed in `code/cli/lib` or the four scored test files.
- [ ] The run remains bounded to T3: no compatibility shim, no docs sweep, no behavior redesign.

### Execution steps

- [ ] First update the phase-owned tests so they encode the target contract before any production edit:
  - `code/cli/test/init_command_test.dart` scaffold expectations assert `cycle.state: IDLE` and `cycle.issue: null`, while keeping `ready`, `waiting`, and `complete` unchanged.
  - The same test file's "already exists" fixture preserves the renamed nested shape rather than the old flat `phase/task` shape.
  - `code/cli/test/fsm_state_test.dart` fixture construction updates the persisted `.inquiry/state.yaml` shape from flat `phase/task` to nested `cycle.state/cycle.issue`; helper-local `setupWorkspace(phase:, task:)` parameter names or named-argument call sites may remain if they are only internal scaffolding.
  - `code/cli/test/fsm_state_test.dart` output expectations rename `task` to `issue`, explicitly including the `missing workspace` group's null assertion (`result.toJson()['task']` → `result.toJson()['issue']`) and the user-visible text label.
- [ ] Run `dart test test/init_command_test.dart` and `dart test test/fsm_state_test.dart` once to confirm any failures are confined to the planned rename seam (RED).
- [ ] Then update `code/cli/lib/modules/global/commands/init.dart::_ensureStateYaml` to write `cycle.state` and `cycle.issue` only, preserving the existing sibling lists.
- [ ] Then update `code/cli/lib/modules/fsm/commands/state.dart` so `_loadCurrentState` reads `yaml['cycle']['state']`, the issue loader reads `yaml['cycle']['issue']`, and the `FsmStateOutput` field/constructor, `FsmStateCommand.execute()` return site, `toJson()`, and `toText()` all expose `issue` instead of `task`.
- [ ] Re-run the same two targeted tests to restore green before leaving the phase.
- [ ] Confirm transition enumeration, APE mapping, and instruction strings remain behaviorally unchanged apart from the renamed issue surface.

### Verification

- [ ] From `code/cli`, run `dart test test/init_command_test.dart`
- [ ] From `code/cli`, run `dart test test/fsm_state_test.dart`
- [ ] In `code/cli/test/fsm_state_test.dart`'s `missing workspace` group, confirm the default-output assertion is `result.toJson()['issue'] == null` alongside `result.toJson()['state'] == 'IDLE'`.
- [ ] Run `rg -n "yaml\['phase'\]|yaml\['task'\]|result\.toJson\(\)\['task'\]|Task:|phase:|task:" test/init_command_test.dart test/fsm_state_test.dart lib/modules/global/commands/init.dart lib/modules/fsm/commands/state.dart` and confirm any remaining Phase 1 hits are limited to comments, unrelated prose, or internal `setupWorkspace(phase:, task:)` scaffolding in `fsm_state_test.dart`; do not force a helper-parameter rename merely to zero this grep.
- [ ] Confirm the resulting `FsmStateOutput` still reports the same current FSM state, valid transitions, APE list, and instructions as before; only the persisted/readback field names change.

### Test definitions (pseudocode)

```text
test('init writes renamed nested state keys')
  run init in empty workspace
  read .inquiry/state.yaml
  expect content contains:
    cycle:
      state: IDLE
      issue: null
  expect ready/waiting/complete blocks unchanged

test('fsm state reads nested keys and exposes issue')
  seed .inquiry/state.yaml with cycle.state = ANALYZE and cycle.issue = "145"
  execute FsmStateCommand
  expect json['state'] == 'ANALYZE'
  expect json['issue'] == '145'
  expect text contains 'State: ANALYZE'
  expect text contains 'Issue: 145'

test('fsm state missing workspace defaults to idle with null issue')
  do not create .inquiry/state.yaml
  provide the existing transition contract fixture
  execute FsmStateCommand
  expect json['state'] == 'IDLE'
  expect json['issue'] is null
```

### Risk notes

- Risk: a partial edit can leave the writer nested while the reader still expects flat keys, reproducing the current drift under new names.
- Mitigation: treat `init.dart`, `state.dart`, and the two scored tests as one atomic slice.
- Accepted bound: do not add legacy alias-reading for flat `phase/task`; coordinated cutover is the only T3-safe path.
- Phase gate: do not begin transition-path edits until both phase-owned tests are green against the renamed schema.

---

## Phase 2 — Align `iq fsm transition` with the authoritative state file

**Depends on:** Phase 1  
**Implements diagnosis decisions:** 1, 2, 3

### TDD applicability

- [ ] Yes — use RED→GREEN because the transition tests already encode the affected authority/path/key seam.
- [ ] RED is complete only when failures are confined to the `.ape/state.yaml` → `.inquiry/state.yaml` and `phase` → `state` cutover.
- [ ] GREEN is complete only when the same transition sequences pass and the legal events, next-state mapping, prompt fragments, and prechecks remain behaviorally identical.

### Entry criteria

- [ ] Phase 1 is green.
- [ ] The only state-file authority in play for this issue remains `.inquiry/state.yaml`.
- [ ] `.ape/context.yaml` issue-precheck behavior is explicitly being left unchanged.

### Execution steps

- [ ] First update the transition-owned fixtures/helpers:
  - `code/cli/test/fsm_transition_test.dart::_writeState` seeds `.inquiry/state.yaml` instead of `.ape/state.yaml`.
  - `code/cli/test/fsm_transition_test.dart` fixtures use `cycle.state` (and `cycle.issue` only when the work-item id is needed).
  - `code/cli/test/fsm_transition_integration_test.dart::_writeState` and its fixtures adopt the same authority/path/shape.
- [ ] Run `dart test test/fsm_transition_test.dart` and `dart test test/fsm_transition_integration_test.dart` once to confirm any failures are limited to the path/key cutover (RED).
- [ ] Then modify `code/cli/lib/modules/fsm/commands/transition.dart::_loadCurrentState` to read `.inquiry/state.yaml`, descend into `cycle`, and read `state` instead of `phase`.
- [ ] Re-run the same two targeted transition tests to restore green before leaving the phase.
- [ ] Verify that no other transition logic changes: legal events, next states, prompt fragments, required role, and precheck behavior remain identical.

### Verification

- [ ] From `code/cli`, run `dart test test/fsm_transition_test.dart`
- [ ] From `code/cli`, run `dart test test/fsm_transition_integration_test.dart`
- [ ] Run `rg -n "\.ape/state\.yaml|cycle\['phase'\]|cycle\.phase|phase:|task:|cycle\.task" test/fsm_transition_test.dart test/fsm_transition_integration_test.dart lib/modules/fsm/commands/transition.dart` and confirm no active transition-path reference remains to the legacy file authority or renamed persisted key in loaders or fixtures.
- [ ] Read the diff for `transition.dart` and confirm it is limited to state-file authority/path/key alignment, not transition semantics.

### Test definitions (pseudocode)

```text
test('transition reads current state from .inquiry/state.yaml cycle.state')
  seed .inquiry/state.yaml with cycle.state = END
  execute transition command for pr_ready
  expect allowed == true
  expect nextState == EVOLUTION

test('transition integration happy path is behaviorally unchanged')
  repeatedly seed/read .inquiry/state.yaml using cycle.state
  execute the same event sequence as before
  expect every nextState and promptFragmentId to match pre-rename behavior
```

### Risk notes

- Risk: lingering `.ape/state.yaml` references can leave the CLI split-brain even if the new keys are correct.
- Mitigation: treat both transition test helpers and `_loadCurrentState` as the full Phase 2 surface; do not stop after code-only edits.
- Phase gate: do not edit shipped assets until both transition tests are green against `.inquiry/state.yaml` + `cycle.state`.

---

## Phase 3 — Align shipped runtime assets that author or read the state file

**Depends on:** Phase 2  
**Implements diagnosis decisions:** 3, 4

### TDD applicability

- [ ] No — this phase edits shipped runtime markdown rather than executable code paths.
- [ ] Do not invent new tests; use the bounded search→edit→search loop plus readback of the edited sections as the verification method.

### Entry criteria

- [ ] Phases 1 and 2 are green.
- [ ] The runtime remains bounded to shipped CLI assets under `code/cli/assets`.
- [ ] No expansion into broad architectural/spec prose cleanup has been authorized.

### Execution steps

- [ ] Re-run the constructor/consumer search strategy against `code/cli/assets` first so the edit set stays bounded to shipped runtime sections that actually author or read `.inquiry/state.yaml`.
- [ ] Update `code/cli/assets/skills/issue-start/SKILL.md` so its `.inquiry/state.yaml` example writes `cycle.state: ANALYZE` and `cycle.issue: "<NNN>"`, and its verification bullet checks for `state`, not `phase`.
- [ ] Update `code/cli/assets/skills/issue-end/SKILL.md` so the Step 1 state check, the EXECUTE expectation text, the END snippet, the EVOLUTION snippet, and the direct-to-IDLE note all use the nested `cycle.state/cycle.issue` shape while preserving the existing END/EVOLUTION flow instructions.
- [ ] Update `code/cli/assets/agents/inquiry.agent.md` so both the ANALYZE bootstrap snippet and the metrics field-mapping table refer to `cycle.state` / `cycle.issue` instead of the old or drifted names.
- [ ] Re-run the same asset search to confirm no targeted runtime section still instructs `phase/task` for `.inquiry/state.yaml`.

### Verification

- [ ] Run `rg -n "phase:|task:|cycle\.phase|cycle\.task" code/cli/assets -g "*.md"` and inspect only the hits tied to `.inquiry/state.yaml`; the targeted runtime asset sections should no longer use the legacy names.
- [ ] Run `rg -n "cycle\.state|cycle\.issue" code/cli/assets/skills/issue-start/SKILL.md code/cli/assets/skills/issue-end/SKILL.md code/cli/assets/agents/inquiry.agent.md` and confirm each targeted runtime surface shows both renamed fields on the state-file examples or mappings it owns.
- [ ] Read back the updated sections of the three targeted asset files and confirm they consistently describe `.inquiry/state.yaml` as `cycle.state` + `cycle.issue`.

### Test definitions (pseudocode)

```text
for each targeted asset in {issue-start, issue-end, inquiry.agent}:
  read the state-file example and verification text
  expect no .inquiry/state.yaml example uses phase/task
  expect the relevant example or table uses cycle.state and cycle.issue
```

### Risk notes

- Risk: stale runtime markdown can reintroduce the old schema after the Dart code is fixed.
- Mitigation: limit this phase to shipped runtime assets only; do not broaden into general docs cleanup.
- Phase gate: if asset search still reports a targeted runtime section using the old names, Phase 4 cannot start.

---

## Phase 4 — Scored validation and shared stop line

**Depends on:** Phase 3  
**Implements diagnosis decisions:** 1, 2, 3, 4

### TDD applicability

- [ ] No — this phase is a no-edit validation gate that reruns existing tests exactly as scored.
- [ ] If the stop line fails, return to the owning phase to re-enter RED→GREEN there; do not turn the stop line itself into an exploratory debugging loop.

### Final scored stop-line contract

- [ ] Treat the five commands below as the entire scored stop line; preserve them exactly and in the listed order.
- [ ] Run all five commands from `code/cli` in one frozen worktree state with no inserted helper commands between them.
- [ ] Stop the scored sequence immediately on the first non-zero exit code; do not continue to later commands after a failure.
- [ ] Preserve per-command evidence sufficient to show ordinal, exact command string, working directory, exit code, and that no edits occurred between command 1 and command 5.

### Entry criteria

- [ ] No code or asset edits remain pending.
- [ ] The worktree is frozen for the scoring pass.
- [ ] The harness artifacts already present in the cleanroom (`.iq.state.yaml`, `run_trace.yaml`, and any captured validation outputs) are preserved.

### Execution steps

- [ ] From `code/cli`, run these commands in this exact order, with no intervening edits:
  1. `dart test test/init_command_test.dart`
  2. `dart test test/fsm_state_test.dart`
  3. `dart test test/fsm_transition_test.dart`
  4. `dart test test/fsm_transition_integration_test.dart`
  5. `dart test`
- [ ] If any command fails, return to the owning phase, fix only the bounded rename surface, and then rerun the full five-command sequence in the same worktree state.
- [ ] Preserve the focused validation output, the full `dart test` output, the final diff/status snapshot, and any `run_trace.yaml` evidence produced by the harness.
- [ ] Stop immediately at the shared T3 scored stop line once all five commands pass in the same worktree state.

### Verification

- [ ] All five commands pass in sequence.
- [ ] The scored stop line can be replayed from the retained evidence as the same five commands, in the same order, from `code/cli`, with exit code `0` for each command and no inserted edits.
- [ ] The final snapshot shows only the intended T3 rename-alignment changes.
- [ ] No compatibility shim, release work, PR work, broader FSM redesign, or general docs cleanup was added.

### Test definitions (pseudocode)

```text
run targeted tests 1-4 in order
assert every exit code == 0
run full project suite
assert exit code == 0
assert the executed command list exactly matches the preserved five-command stop line
assert no file edits occurred between command 1 and command 5
assert harness artifacts remain present after validation
```

### Risk notes

- Risk: the full suite may expose additional stale test expectations outside the four scored files; a known safe hit is `code/cli/test/fsm_contract_test.dart:94`, where `execute.phase` is a prompt-fragment template id rather than the persisted state-file schema.
- Mitigation: fix only failures directly caused by this bounded rename, leave the out-of-scope `execute.phase` prompt-fragment assertion unchanged, and then repeat the full validation sequence from the same worktree state.
