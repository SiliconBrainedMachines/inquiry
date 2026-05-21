---
title: "Deliver transition-owned instructions as prompt-ready fragments"
issue: 185
date: 2026-05-20
status: active
---

# Plan: Issue #185

## TDD Rules

1. Start every phase by writing or updating focused failing tests.
2. Make the smallest change that turns those tests green.
3. Refactor only after the focused slice is green.
4. Do not advance to the next phase while the current phase still has red tests.
5. End with the full CLI test suite, not only phase-local tests.

## Planning Note

This plan follows the accepted diagnosis, with one repo-state correction discovered after the analysis was approved: [code/cli/assets/skills](../../../code/cli/assets/skills) already contains only the universal skills `kritik`, `legion`, and `research`. The remaining drift is not in the asset directory split itself, but in the FSM contract vocabulary, prompt assembly, transition-to-prompt handoff, and stale tests such as [code/cli/test/assets_test.dart](../../../code/cli/test/assets_test.dart).

## Phase 1 — Lock the runtime boundary in tests

**Objective:** Encode the accepted architecture and the real current asset inventory before changing runtime behavior.

### Tasks

- [ ] 1.1 Update [code/cli/test/assets_test.dart](../../../code/cli/test/assets_test.dart) so `assets/skills` is expected to list only `kritik`, `legion`, and `research`.
- [ ] 1.2 Add assertions that [code/cli/assets/instructions](../../../code/cli/assets/instructions) contains the private instruction assets `doc-read.md`, `doc-write.md`, `issue-create.md`, `issue-start.md`, and `issue-end.md`.
- [ ] 1.3 Extend [code/cli/test/fsm_contract_test.dart](../../../code/cli/test/fsm_contract_test.dart) to lock the transition-owned runtime set to `doc-read`, `doc-write`, `issue-start`, and `issue-end`.
- [ ] 1.4 Add assertions that `issue-create` and `inquiry-install` are not referenced by `prompt_fragments` in [code/cli/assets/fsm/transition_contract.yaml](../../../code/cli/assets/fsm/transition_contract.yaml).
- [ ] 1.5 Remove or rewrite any stale test expectation that still loads `assets/skills/doc-read`, `doc-write`, `issue-start`, `issue-end`, or `issue-create`.

### Verification

- [ ] Run `dart test test/assets_test.dart test/fsm_contract_test.dart`
- [ ] Confirm no focused test still assumes transition-owned private protocols live under `assets/skills`

---

## Phase 2 — Define minimal prompt-ready instruction summaries

**Objective:** Make runtime delivery depend on compact prompt text rather than raw Markdown bodies.

**Design choice:** Keep the existing instruction Markdown files as the source of record, but add an explicit prompt-summary section inside each transition-owned instruction file. That section must be short, ordered, and plain enough to inject directly into a prompt without frontmatter, fences, or Markdown noise.

### Tasks

- [ ] 2.1 Add a new focused test file, for example [code/cli/test/instruction_prompt_loader_test.dart](../../../code/cli/test), that defines the extraction contract for prompt-ready instruction text.
- [ ] 2.2 Write failing tests for `doc-read`, `doc-write`, `issue-start`, and `issue-end` requiring an explicit prompt-summary section.
- [ ] 2.3 Define the normalization rules in tests first: no YAML frontmatter, no fenced code blocks, no backticks, no checklist markers, no quoted examples, and no unnecessary special characters in the extracted runtime text.
- [ ] 2.4 Add the prompt-summary section to [code/cli/assets/instructions/doc-read.md](../../../code/cli/assets/instructions/doc-read.md), [code/cli/assets/instructions/doc-write.md](../../../code/cli/assets/instructions/doc-write.md), [code/cli/assets/instructions/issue-start.md](../../../code/cli/assets/instructions/issue-start.md), and [code/cli/assets/instructions/issue-end.md](../../../code/cli/assets/instructions/issue-end.md).
- [ ] 2.5 Keep [code/cli/assets/instructions/issue-create.md](../../../code/cli/assets/instructions/issue-create.md) outside this runtime prompt-fragment slice unless a later FSM change starts referencing it.

### Verification

- [ ] Run the new instruction-summary test file plus `dart test test/assets_test.dart`
- [ ] Confirm extracted runtime text is stable, ordered, and prompt-ready

---

## Phase 3 — Replace `skill` with ordered `instructions` lists in the FSM contract

**Objective:** Align the contract with the accepted architecture and support multiple instruction fragments per transition event.

### Tasks

- [ ] 3.1 Add failing tests in [code/cli/test/fsm_contract_test.dart](../../../code/cli/test/fsm_contract_test.dart) for `instructions: [...]` parsing.
- [ ] 3.2 Add a synthetic parser test with more than one instruction in a fragment to lock ordering before production YAML needs it.
- [ ] 3.3 Keep `role` and `template` intact while replacing the singular `skill` field.
- [ ] 3.4 Update [code/cli/assets/fsm/transition_contract.yaml](../../../code/cli/assets/fsm/transition_contract.yaml) so each `prompt_fragments` entry uses `instructions: [...]` instead of `skill:`.
- [ ] 3.5 Update [code/cli/lib/fsm_contract.dart](../../../code/cli/lib/fsm_contract.dart) so `PromptFragmentContract` stores `List<String> instructions` and the YAML parser preserves list order.
- [ ] 3.6 Update every touched test assertion from `fragment.skill` to `fragment.instructions`.

### Verification

- [ ] Run `dart test test/fsm_contract_test.dart test/fsm_transition_test.dart test/fsm_transition_integration_test.dart`
- [ ] Confirm malformed or missing instruction lists fail closed

---

## Phase 4 — Add a loader for prompt-ready instruction text

**Objective:** Give the runtime one deterministic path from instruction name to injected prompt text.

### Tasks

- [ ] 4.1 Introduce a loader module that resolves `assets/instructions/<name>.md` and extracts only the prompt-summary section.
- [ ] 4.2 Add tests for successful load, missing asset, missing prompt-summary section, and multiple-instruction concatenation in declared order.
- [ ] 4.3 Reuse the existing assets infrastructure instead of ad-hoc path logic.
- [ ] 4.4 Fail closed with explicit errors when a transition references an instruction asset that cannot produce prompt-ready text.

### Verification

- [ ] Run the new loader tests plus `dart test test/assets_test.dart`
- [ ] Confirm loader output never contains raw frontmatter or fenced Markdown blocks

---

## Phase 5 — Thread transition context into prompt generation

**Objective:** Make prompt generation aware of which transition event owns the prompt fragment.

**Rationale:** [code/cli/lib/modules/ape/commands/prompt.dart](../../../code/cli/lib/modules/ape/commands/prompt.dart) currently knows FSM state, APE name, and optional sub-state, but not the triggering event. Without event context, the runtime cannot distinguish `analyze_continue` from `analyze_to_plan`, or `plan_to_execute` from `plan_to_idle`.

### Tasks

- [ ] 5.1 Add failing tests showing that `iq ape prompt` cannot yet choose between multiple prompt fragments available from the same FSM state.
- [ ] 5.2 Choose the handoff contract before implementation: either persist `last_transition_event` or `prompt_fragment_id` in `.inquiry/state.yaml`, or add an explicit `--event` override with a persisted default.
- [ ] 5.3 Update [code/cli/lib/modules/ape/inquiry_state.dart](../../../code/cli/lib/modules/ape/inquiry_state.dart) and the FSM transition path so successful transitions preserve that event-owned prompt context.
- [ ] 5.4 Update focused tests in [code/cli/test/fsm_transition_test.dart](../../../code/cli/test/fsm_transition_test.dart), [code/cli/test/fsm_transition_integration_test.dart](../../../code/cli/test/fsm_transition_integration_test.dart), and [code/cli/test/ape_prompt_test.dart](../../../code/cli/test/ape_prompt_test.dart).
- [ ] 5.5 Preserve deterministic behavior for prompt inspection when no transition context exists.

### Verification

- [ ] Run `dart test test/fsm_transition_test.dart test/fsm_transition_integration_test.dart test/ape_prompt_test.dart`
- [ ] Confirm a real transition leaves enough context for the next prompt to resolve the correct fragment

---

## Phase 6 — Inject ordered instruction summaries into prompt assembly

**Objective:** Make the transition-owned instructions appear inside the final prompt in a deterministic place.

### Tasks

- [ ] 6.1 Add failing tests in [code/cli/test/ape_definition_test.dart](../../../code/cli/test/ape_definition_test.dart) for prompt assembly with an injected instruction block.
- [ ] 6.2 Extend [code/cli/lib/modules/ape/ape_definition.dart](../../../code/cli/lib/modules/ape/ape_definition.dart) so `assemblePrompt()` can accept rendered instruction content while preserving existing behavior when none is supplied.
- [ ] 6.3 Lock the placement order in tests: base prompt -> sub-state prompt -> transition instruction block -> operational contract -> inquiry-context.
- [ ] 6.4 Update [code/cli/lib/modules/ape/commands/prompt.dart](../../../code/cli/lib/modules/ape/commands/prompt.dart) to resolve the fragment, load the ordered instruction summaries, join them, and pass the rendered block into `assemblePrompt()`.
- [ ] 6.5 Add or update prompt tests proving that generated prompts contain the minimal summary text and not the raw Markdown source.

### Verification

- [ ] Run `dart test test/ape_definition_test.dart test/ape_prompt_test.dart`
- [ ] Confirm injected instruction text preserves declared order and excludes Markdown noise

---

## Phase 7 — Clean stale assumptions and harden the migration boundary

**Objective:** Finish the migration so future changes cannot silently drift back to the old model.

### Tasks

- [ ] 7.1 Remove or rewrite any remaining code, test, or documentation reference that still treats transition-owned private protocols as `skills`.
- [ ] 7.2 Update integrity checks, including [code/cli/test/assets_test.dart](../../../code/cli/test/assets_test.dart) and any doctor-related coverage if needed, so the repo validates the new boundary.
- [ ] 7.3 Add assertions that every allowed transition fragment references instruction assets that exist and expose a prompt-summary section.
- [ ] 7.4 Reconcile the final implementation with [cleanrooms/185-feat-iq-skill-module-inquiry-bound-skill-delivery/analyze/diagnosis.md](./analyze/diagnosis.md), keeping the approved scope but reflecting the corrected fact that `assets/skills` is already universal-only.

### Verification

- [ ] Run all focused tests touched in Phases 1-7
- [ ] Confirm no repo reference expects `assets/skills/doc-read`, `doc-write`, `issue-start`, `issue-end`, or `issue-create`

---

## Final Verification

- [ ] Run `dart test` from [code/cli](../../../code/cli)
- [ ] Run a manual smoke sequence covering at least:
  - [ ] `iq fsm transition --event start_analyze`
  - [ ] `iq ape prompt --name socrates`
  - [ ] `iq fsm transition --event complete_analysis`
  - [ ] `iq ape prompt --name descartes`
  - [ ] `iq fsm transition --event approve_plan`
  - [ ] `iq ape prompt --name basho`
- [ ] Confirm each prompt includes the correct transition-owned summary block for the owning event
- [ ] Confirm `iq fsm state --json` remains a diagnostic surface and is not repurposed as the primary carrier for full instruction bodies

## Dependency Order

```text
Phase 1 -> Phase 2 -> Phase 3 -> Phase 4 -> Phase 5 -> Phase 6 -> Phase 7
```

## Exit Criteria

- Transition-owned private protocols are modeled as `instructions: [...]` in the FSM contract
- The runtime can resolve the owning transition event before generating an APE prompt
- Prompt generation injects minimal prompt-ready instruction summaries in deterministic order
- Universal thinking tools remain the only assets under `assets/skills`
- Stale tests expecting private protocols under `assets/skills` are removed or rewritten
- The full CLI test suite passes