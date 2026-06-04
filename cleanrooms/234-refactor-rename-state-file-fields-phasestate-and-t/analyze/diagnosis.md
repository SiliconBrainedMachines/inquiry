---
id: diagnosis
title: "Diagnosis"
date: 2026-06-04
status: active
tags: [diagnosis, evidence-first]
---

# Diagnosis

## Problem defined

Issue #234 is a naming-alignment refactor for the persisted Inquiry state file: rename the state-tracking keys `phase`→`state` and `task`→`issue`, then align every CLI surface that reads, writes, or presents those fields. The issue explicitly constrains the work to a field rename only, with no structural change beyond the two keys and no intended behavior change in the FSM itself. (`../issue.md:12-25`)

The bounded repository does not currently present one consistent state-file contract. Different surfaces disagree about the state-file path (`.inquiry/state.yaml` vs `.ape/state.yaml`), the YAML shape (flat keys vs `cycle.<key>`), and the persisted vocabulary (`phase/task` vs partial `issue` usage). The diagnosis is therefore not "find two literals and replace them"; it is "close a schema drift seam so every CLI state surface converges on the same persisted names."

## Evidence

### O1. Canonical docs and current writers point to `.inquiry/state.yaml`
- `iq init` creates `.inquiry/state.yaml` and writes nested `cycle.phase` and `cycle.task`, while leaving `ready`, `waiting`, and `complete` intact. (`../../../code/cli/lib/modules/global/commands/init.dart:121-137`)
- The architecture and FSM specs describe `.inquiry/state.yaml` as the persisted FSM authority for the repository. (`../../../docs/architecture.md:27-31,43-44,68-69,110-118`; `../../../docs/spec/finite-ape-machine.md:28-35,60-68`)
- The `issue-start` skill instructs the scheduler to write the same `.inquiry/state.yaml` surface under `cycle:`. (`../../../code/cli/assets/skills/issue-start/SKILL.md:109-123`)

### O2. The status reader does not match the writer schema
- `FsmStateCommand` reads `.inquiry/state.yaml`, but it looks for top-level `yaml['phase']` and `yaml['task']` rather than `yaml['cycle']['phase']` and `yaml['cycle']['task']`. (`../../../code/cli/lib/modules/fsm/commands/state.dart:159-181`)
- The same command emits `task` in JSON and `Task:` in text output. (`../../../code/cli/lib/modules/fsm/commands/state.dart:41-72`)

### O3. The transition reader uses a different file and a different schema slice
- `StateTransitionCommand` loads current state from `.ape/state.yaml`, enters `yaml['cycle']`, and reads `cycle['phase']`. (`../../../code/cli/lib/modules/fsm/commands/transition.dart:225-238`)
- Its issue-precheck logic already uses `issue` from `.ape/context.yaml`, so the target noun is already present on an adjacent CLI surface. (`../../../code/cli/lib/modules/fsm/commands/transition.dart:203-223`)

### O4. Tests encode the old names and the split representations
- `fsm_state_test.dart` writes a flat `.inquiry/state.yaml` fixture with `phase` and `task`, then asserts `json['task']`. (`../../../code/cli/test/fsm_state_test.dart:17-65`)
- `init_command_test.dart` expects generated content to contain `phase: IDLE` and `task: null`, and it preserves an existing flat file during idempotency checks. (`../../../code/cli/test/init_command_test.dart:97-124`)
- `fsm_transition_test.dart` and `fsm_transition_integration_test.dart` write `.ape/state.yaml` fixtures with `cycle.phase`. (`../../../code/cli/test/fsm_transition_test.dart:169-173`; `../../../code/cli/test/fsm_transition_integration_test.dart:96-100`)

### O5. Shipped prompt and skill assets are internally inconsistent
- `inquiry.agent.md` still instructs updating `.inquiry/state.yaml` with `phase` and `task`. (`../../../code/cli/assets/agents/inquiry.agent.md:45-52`)
- The same agent asset later maps `issue` to `.inquiry/state.yaml → cycle.task`, confirming naming drift inside one shipped surface. (`../../../code/cli/assets/agents/inquiry.agent.md:498-501`)
- `issue-end` still validates `phase: EXECUTE`, but its later END and EVOLUTION snippets already use `issue:` beside `phase:`. (`../../../code/cli/assets/skills/issue-end/SKILL.md:24-37,117-176`)

### O6. The active T3 harness already uses the target vocabulary outside the CLI source tree
- The cleanroom authority file for this dispatch, `.iq.state.yaml`, uses top-level `state` and `issue`. (`../.iq.state.yaml:1-10`)
- `run_trace.yaml` points runtime sensor authority to that file. (`../run_trace.yaml:1-12,24-33`)
- This confirms the desired packet vocabulary, but it does not itself update the CLI implementation.

## Hypotheses

The repository is carrying overlapping generations of state handling. One line of authority centers on `.inquiry/state.yaml` and the `cycle.phase`/`cycle.task` schema used by `init`, specs, and issue-start. Another survives in the transition code and tests, which still rely on `.ape/state.yaml` and `phase`. Issue #234 is best understood as the bounded cleanup that makes those surfaces converge on one persisted naming contract.

## Decisions taken

1. **Treat `.inquiry/state.yaml` as the authoritative repository state file for this issue.**
   - Justification: `issue.md` names the "inquiry state file"; `iq init`, the architecture docs, the FSM spec, and shipped skills all point to `.inquiry/state.yaml`. (`../issue.md:12-25`; `../../../code/cli/lib/modules/global/commands/init.dart:121-137`; `../../../docs/architecture.md:27-31,43-44,68-69,110-118`; `../../../docs/spec/finite-ape-machine.md:28-35,60-68`)
   - Consequence: `.ape/state.yaml` references are treated as legacy drift that cannot remain the effective source of truth if the rename is to be coherent.

2. **Treat the rename as a persisted-schema and user-surface alignment, not a workflow redesign.**
   - Justification: the issue forbids structural change beyond the two renamed keys and forbids behavior change. (`../issue.md:23-25`)
   - Consequence: FSM state values, transition legality, and phase sequencing remain unchanged.

3. **Use `cycle.state` and `cycle.issue` as the bounded target shape.**
   - Justification: current authoritative writers already use the `cycle:` wrapper, and the issue forbids broader structure changes. (`../../../code/cli/lib/modules/global/commands/init.dart:128-135`; `../../../code/cli/assets/skills/issue-start/SKILL.md:111-120`; `../issue.md:23-25`)
   - Consequence: the sibling lists `ready`, `waiting`, and `complete` stay as they are; the rename is confined to the two state-tracking keys.

4. **Include shipped CLI assets and tests in the affected surface area.**
   - Justification: the issue covers every CLI surface that reads or writes the fields, and the deployed agent/skill markdown actively instructs those writes. (`../issue.md:23-25`; `../../../code/cli/assets/agents/inquiry.agent.md:45-52`; `../../../code/cli/assets/skills/issue-start/SKILL.md:109-141`; `../../../code/cli/assets/skills/issue-end/SKILL.md:24-37,117-176`)
   - Consequence: bounded execution must update code, fixtures, and deployed prompt assets together.

5. **No further user clarification is required to hand off to planning.**
   - Justification: repository artifacts already define the requested key rename, preserved structure, and no-behavior-change constraint. (`../issue.md:12-25`)
   - Consequence: remaining uncertainty is operational risk, not missing human intent.

## Stakeholder perspectives

- **Direct CLI users and automation consumers.** The CLI-as-API spec says humans can invoke `iq state transition --event <e>` directly without any AI layer, so state-schema drift is visible to operators and scripts, not only to deployed prompt assets. (`../../../docs/spec/cli-as-api.md:34-38,55-68`)
- **Prompt and asset consumers.** The shipped agent and skill markdown remains a live runtime input that can perpetuate old keys even if the Dart implementation is corrected. (Observed evidence O5)
- **Task-backend consumers.** The Inquiry CLI spec uses `task` as an abstract work-item identifier mapped to GitHub Issues and stored in `.inquiry/status.md`, which is a different contract from the persisted FSM state file. (`../../../docs/spec/inquiry-cli-spec.md:18-31,618-647,676-689`)
- **Bounded implication.** A critic could argue that renaming `task`→`issue` in the state file should cascade into the entire `iq task` namespace. The bounded evidence does not support that: the state-file rename targets FSM tracking, while the `iq task` family names a broader backend abstraction.

## Constraints and risks

- **No FSM behavior drift.** Transition legality, active APE mapping, and instructional meaning must remain the same after the naming change. (`../issue.md:23-25`; `../../../code/cli/lib/modules/fsm/commands/state.dart:97-107`; `../../../code/cli/lib/modules/fsm/commands/transition.dart:122-178`)
- **No extra structural change.** The rename must not absorb unrelated shape changes; `ready`, `waiting`, and `complete` remain outside scope. (`../issue.md:23-25`; `../../../code/cli/lib/modules/global/commands/init.dart:128-135`)
- **Path drift and key drift are coupled.** A field-only edit that leaves `.ape/state.yaml` as an active reader would preserve an internally inconsistent state contract. (Observed evidence O1-O4)
- **Backward-compatibility risk is real.** Existing initialized repositories will contain `phase/task`, and bounded evidence shows no migration or alias-reading layer for old keys. `init` only creates the file if missing, and current loaders read exact field names. (`../../../code/cli/lib/modules/global/commands/init.dart:126-138`; `../../../code/cli/lib/modules/fsm/commands/state.dart:164-181`; `../../../code/cli/lib/modules/fsm/commands/transition.dart:232-238`)
- **Prompt assets can reintroduce old keys after code changes.** Because the agent and skills are deployed runtime inputs, leaving stale schema language there would keep the old contract alive even if the Dart code changes. (Observed evidence O5)

## Implications and consequences

- **If the documented writer remains unchanged while `iq fsm state` keeps reading flat keys, the status surface cannot be treated as authoritative.** `iq init` writes `cycle.phase`/`cycle.task`, but `FsmStateCommand` reads top-level `phase`/`task`, so a freshly initialized repository is logically forced onto the command's fallback path (`IDLE` and no task) unless some other surface rewrites the file into the older flat layout. (`../../../code/cli/lib/modules/global/commands/init.dart:126-135`; `../../../code/cli/lib/modules/fsm/commands/state.dart:159-181`)
- **If the rename is applied only to `.inquiry/state.yaml`, transition validation still remains split-brain.** `StateTransitionCommand` continues to source current state from `.ape/state.yaml`, so the repository would still expose two competing state authorities even after the key rename. (`../../../code/cli/lib/modules/fsm/commands/transition.dart:225-238`)
- **If shipped assets keep the legacy vocabulary, inaction perpetuates schema regression.** The scheduler-facing markdown can continue instructing `phase`/`task` writes after the Dart implementation is corrected, which would make the persisted state contract nondeterministic across human, CLI, and agent-driven entry points. (`../../../code/cli/assets/skills/issue-start/SKILL.md:109-141`; `../../../code/cli/assets/skills/issue-end/SKILL.md:24-37,117-176`; `../../../code/cli/assets/agents/inquiry.agent.md:45-52,498-501`)

## Scope

### Enters scope
- Repository state-file readers and writers under `code/cli/lib`.
- User-facing FSM status output that currently exposes `task`.
- Tests and fixtures that assert the persisted key names or schema layout.
- Deployed CLI assets under `code/cli/assets/` that instruct or depend on the state-file keys.
- Directly related canonical documentation references when needed to keep the schema description coherent.

### Does not enter scope
- Renaming the FSM state values themselves (`IDLE`, `ANALYZE`, `PLAN`, `EXECUTE`, `END`, `EVOLUTION`).
- Replacing the conceptual word "phase" everywhere it appears in prose, lifecycle explanations, or prompt-fragment identifiers such as `execute.phase`.
- Renaming the broader `iq task` command family or task-backend terminology; in the CLI spec that word names an abstract work-item API backed by GitHub Issues and persisted in `.inquiry/status.md`, not the FSM state file. (`../../../docs/spec/inquiry-cli-spec.md:18-31,618-647,676-689`)
- Changing `.ape/context.yaml` issue-precheck semantics; that surface already uses `issue` and is not the renamed state file.
- Cleanroom harness artifacts such as `.iq.state.yaml`, except as contextual evidence for the target vocabulary.
- Rewriting historical release notes that mention `.ape/state.yaml`; those entries describe prior lineage rather than an active state-handling contract. (`../../../code/cli/CHANGELOG.md:128-136`)

## Open questions

No additional user question is required to bound planning. The only live uncertainty is operational: whether execution should preserve read-compatibility with pre-rename `phase/task` files or make a coordinated schema cutover. The repository does not resolve that policy, so it should be treated as a planning risk rather than an analysis blocker.

## References

- [Issue #234](../issue.md)
- [Analyze index](index.md)
- [Confirmations](confirmations.md)
- [Init state scaffold](../../../code/cli/lib/modules/global/commands/init.dart)
- [FSM state reader and output](../../../code/cli/lib/modules/fsm/commands/state.dart)
- [FSM transition reader](../../../code/cli/lib/modules/fsm/commands/transition.dart)
- [Issue-start skill](../../../code/cli/assets/skills/issue-start/SKILL.md)
- [Issue-end skill](../../../code/cli/assets/skills/issue-end/SKILL.md)
- [Inquiry agent asset](../../../code/cli/assets/agents/inquiry.agent.md)
- [FSM state tests](../../../code/cli/test/fsm_state_test.dart)
- [Init command tests](../../../code/cli/test/init_command_test.dart)
- [FSM transition tests](../../../code/cli/test/fsm_transition_test.dart)
- [FSM transition integration tests](../../../code/cli/test/fsm_transition_integration_test.dart)
- [Architecture](../../../docs/architecture.md)
- [Finite APE Machine spec](../../../docs/spec/finite-ape-machine.md)
- [CLI as API spec](../../../docs/spec/cli-as-api.md)
- [Inquiry CLI spec](../../../docs/spec/inquiry-cli-spec.md)
- [CLI changelog](../../../code/cli/CHANGELOG.md)
- [Cleanroom authority state](../.iq.state.yaml)
- [Execution trace](../run_trace.yaml)
