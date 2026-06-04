---
id: confirmations
title: "Confirmations"
date: 2026-06-04
status: active
tags: [confirmations, findings]
---

# Confirmations

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: Issue #234 is bounded to persisted key renames, not workflow redesign — CONFIRMED
- `issue.md` defines the work as renaming state-file fields `phase`→`state` and `task`→`issue`, with "no behaviour change" and "no structural change beyond the two keys." (`../issue.md:12-25`)
- The analyze index repeats the same bounded scope. (`index.md:3-6`)

## F2: `.inquiry/state.yaml` is the documented repository authority, but live CLI readers and writers do not agree on schema or path — CONFIRMED
- `iq init` creates `.inquiry/state.yaml` with nested `cycle.phase` and `cycle.task`, while preserving `ready`, `waiting`, and `complete`. (`../../../code/cli/lib/modules/global/commands/init.dart:121-137`)
- The architecture and FSM specs describe `.inquiry/state.yaml` as the repository FSM authority. (`../../../docs/architecture.md:27-31,43-44,68-69,110-118`; `../../../docs/spec/finite-ape-machine.md:28-35,60-68`)
- `FsmStateCommand` also reads `.inquiry/state.yaml`, but it expects flat top-level `phase` and `task`. (`../../../code/cli/lib/modules/fsm/commands/state.dart:159-181`)
- `StateTransitionCommand` instead reads `.ape/state.yaml` and `cycle.phase`. (`../../../code/cli/lib/modules/fsm/commands/transition.dart:225-238`)

## F3: The user-facing FSM status surface still exposes `task` naming — CONFIRMED
- `FsmStateOutput` serializes `task` in JSON and renders `Task:` in text output. (`../../../code/cli/lib/modules/fsm/commands/state.dart:41-72`)
- Tests assert `json['task']` and describe IDLE as having no task. (`../../../code/cli/test/fsm_state_test.dart:37-65,205-220`)

## F4: Shipped agent and skill assets embed mixed naming and mixed layout — CONFIRMED
- `issue-start` instructs writing `.inquiry/state.yaml` with `cycle.phase` and `cycle.task`, then verifies `phase: ANALYZE`. (`../../../code/cli/assets/skills/issue-start/SKILL.md:109-141`)
- `issue-end` still validates `phase: EXECUTE`, but its END and EVOLUTION snippets already use `issue:` beside `phase:`. (`../../../code/cli/assets/skills/issue-end/SKILL.md:24-37,117-176`)
- `inquiry.agent.md` tells the scheduler to set `phase` and `task`, while its metrics table already labels the value as `issue` sourced from `cycle.task`. (`../../../code/cli/assets/agents/inquiry.agent.md:45-52,498-501`)

## F5: Tests lock both the old field names and the split file locations — CONFIRMED
- `fsm_state_test.dart` writes a flat `.inquiry/state.yaml` fixture with `phase` and `task`. (`../../../code/cli/test/fsm_state_test.dart:17-34`)
- `init_command_test.dart` expects generated content to contain `phase: IDLE` and `task: null`, and it preserves an existing flat schema. (`../../../code/cli/test/init_command_test.dart:97-124`)
- `fsm_transition_test.dart` and `fsm_transition_integration_test.dart` write `.ape/state.yaml` fixtures with `cycle.phase`. (`../../../code/cli/test/fsm_transition_test.dart:169-173`; `../../../code/cli/test/fsm_transition_integration_test.dart:96-100`)

## F6: The active T3 harness already uses the target vocabulary, but only in cleanroom runtime artifacts — CONFIRMED
- The cleanroom authority file `.iq.state.yaml` uses top-level `state` and `issue`. (`../.iq.state.yaml:1-10`)
- `run_trace.yaml` points runtime sensor authority to that file. (`../run_trace.yaml:1-12,24-33`)
- This confirms the packet vocabulary, but it is not yet the CLI implementation surface.

## F7: No dedicated migration or alias-reading path is evident for the old state-file keys — CONFIRMED
- `InitCommand` only creates `.inquiry/state.yaml` when it is missing and otherwise leaves the file untouched. (`../../../code/cli/lib/modules/global/commands/init.dart:126-138`; `../../../code/cli/test/init_command_test.dart:110-124`)
- Current state loaders read exact key names directly, with no fallback logic for alternative schema names. (`../../../code/cli/lib/modules/fsm/commands/state.dart:164-181`; `../../../code/cli/lib/modules/fsm/commands/transition.dart:232-238`)

## F8: Historical `.ape/state.yaml` mentions remain as release-history evidence, not active state-handling authority — CONFIRMED
- `code/cli/CHANGELOG.md` records version `0.0.7` creating `.ape/state.yaml` as a past change, which explains lineage but does not itself read or write the current repository state. (`../../../code/cli/CHANGELOG.md:128-136`)
- This keeps the bounded issue focused on live CLI readers, writers, tests, and shipped assets rather than retrospective release notes.

## F9: The broader `iq task` subsystem is a separate CLI/API domain and does not widen the state-file rename scope — CONFIRMED
- The CLI spec defines `iq` as the programmatic API for apes, with `iq task *` commands as a separate structured-write surface alongside state transitions. (`../../../docs/spec/inquiry-cli-spec.md:18-31`)
- In that same spec, `iq task create` and `iq task status` use `task` as an abstract backend identifier mapped to a GitHub Issue and persisted in `.inquiry/status.md`, not `.inquiry/state.yaml`. (`../../../docs/spec/inquiry-cli-spec.md:618-647,676-689`)
- The CLI-as-API spec separately frames `iq state transition --event <e>` as the direct state-handling command that humans can invoke without AI, so the bounded rename remains about FSM state surfaces rather than the whole task-management namespace. (`../../../docs/spec/cli-as-api.md:34-38,55-68`)
