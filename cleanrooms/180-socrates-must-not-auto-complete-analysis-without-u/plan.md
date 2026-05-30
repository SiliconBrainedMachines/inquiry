---
id: plan
title: "Plan - Extract phase policy from active APEs and repair ANALYZE completion semantics"
date: 2026-05-30
status: active
tags: [plan, analyze, contract, ape, scheduler, confirmations]
author: DESCARTES
---

# Plan - Extract phase policy from active APEs and repair ANALYZE completion semantics (#180)

**Hypothesis:** If execution first locks regression guards that distinguish methodology from phase policy, then implements the minimal state-owned contract needed for ANALYZE participation, visibility, artifact policy, and completion gating, then aligns firmware, transition, bootstrap, and prompt surfaces to that contract while canonicalizing confirmations.md, and only after that applies a bounded hygiene pass to DEWEY, DESCARTES, and BASHO, issue #180 can be resolved without turning this cycle into a full six-state redesign.

**Falsification:** Stop execution, annotate a deviation, and return to ANALYZE if any phase shows one of these conditions:
- the required ANALYZE behavior cannot be encoded without a broad schema redesign that also forces simultaneous rewrites of IDLE, PLAN, and EXECUTE contracts;
- firmware behavior cannot be made state-aware for ANALYZE without reintroducing the old false-approval-gate problem across every phase;
- confirmations.md cannot replace confirmed.md without breaking packaged prompt assembly, bootstrap, or regression expectations in a way that cannot be bounded to this slice;
- the proposed hygiene pass for DEWEY, DESCARTES, and BASHO expands from prompt cleanup into a wider contract rewrite that should be handled as follow-up work instead of inside #180;
- the full project verification fails for regressions introduced by the issue-180 slice.

**Diagnosis anchors:**
- D1: the product invariant must be phase-stable and methodology-agnostic.
- D2: APE definitions should contain methodology, not repository procedure.
- D3: the current runtime leaks phase policy in more than one place.
- D4: the acute repair for #180 belongs in the ANALYZE slice, but the doctrine must be generalized.
- D5: confirmations.md is the correct canonical name.

**Adjacent evidence anchors:**
- F1: ANALYZE must own the participation and artifact contract.
- F2: SOCRATES should own methodology only.
- F3: the runtime still hardcodes ANALYZE to SOCRATES.
- F4: analyze bootstrap is still APE-colored.
- F5: diagnosis.md alone is not valid proof of completion.
- F6: DEWEY is closer to methodology-only, but not fully pure.
- F7: DESCARTES still contains substantial phase knowledge.
- F8: methodological purity varies across active APEs.
- F9: BASHO also carries non-method execution semantics.
- F10: confirmations.md is the correct target name.
- `code/cli/test/firmware_agent_test.dart`, `code/cli/test/fsm_contract_test.dart`, `code/cli/test/fsm_state_test.dart`, `code/cli/test/fsm_transition_test.dart`, `code/cli/test/effect_executor_test.dart`, `code/cli/test/ape_prompt_test.dart`, `code/cli/test/ape_definition_test.dart`, and `code/cli/test/assets_test.dart` are the nearby executable gates for this slice.

**Ordering rule for this cycle:** regression guards and minimal contract vocabulary -> ANALYZE state/boundary repair -> firmware and bootstrap alignment -> confirmations rename and prompt-surface alignment -> bounded non-DARWIN APE hygiene -> packaged rebuild and focused clean verification -> full project verification.

**Phase-close rule for this cycle:** A phase closes only when its deliverable is recorded, its verification block has a clear pass/fail result, and the resulting behavior can be described without appealing to hidden scheduler intuition.

**Approval immutability rule for this cycle:** Once the user approves this plan, phase order, phase titles, dependencies, and verification definitions stay fixed. During EXECUTE, only checkboxes, pass/fail notes, and explicit deviation annotations may change.

**Verification rule for this cycle:** Every phase names the concrete checks to run and the pass/fail signal that decides whether execution may continue. The final executable verification step for the whole plan is the complete existing project test surface, not a narrower slice.

---

## Phase 0: Lock the regression surface and the minimum contract vocabulary

**Entry criteria:** Approved diagnosis exists at `cleanrooms/180-socrates-must-not-auto-complete-analysis-without-u/analyze/diagnosis.md`; no execution edits have widened the issue beyond the diagnosed slice.

**Dependencies:** None.

**Risk note:** D3 and D4 make scope control mandatory. Without a frozen list of source-of-truth surfaces and the minimum vocabulary required for ANALYZE, execution can drift into a repo-wide contract rewrite.

- [x] Read the current source surfaces for this slice only: `code/cli/assets/agents/inquiry.agent.md`, `code/cli/assets/fsm/states/analyze.yaml`, `code/cli/assets/fsm/transition_contract.yaml`, `code/cli/lib/modules/ape/operational_contract.dart`, `code/cli/lib/modules/fsm/commands/state.dart`, `code/cli/lib/modules/fsm/commands/transition.dart`, `code/cli/lib/modules/fsm/effect_executor.dart`, `code/cli/assets/apes/socrates.yaml`, `code/cli/assets/apes/dewey.yaml`, `code/cli/assets/apes/descartes.yaml`, and `code/cli/assets/apes/basho.yaml`.
- [x] Freeze the minimum new contract vocabulary needed for this issue. Prefer the smallest extension that can encode ANALYZE interaction visibility, participation requirements, required artifacts, and completion requirements without redesigning every phase schema.
- [x] Freeze the executable guard set that will be used during the cycle: `firmware_agent_test.dart`, `fsm_contract_test.dart`, `fsm_state_test.dart`, `fsm_transition_test.dart`, `effect_executor_test.dart`, `ape_prompt_test.dart`, `ape_definition_test.dart`, and `assets_test.dart`.
- [x] Record explicit out-of-scope boundaries for this issue: DARWIN/EVOLUTION work, a full generic configurable APE registry across all states, and a complete rewrite of IDLE/PLAN/EXECUTE state contracts beyond bounded hygiene.

**QA result:** PASS

Execution boundary frozen before the first product edit.

- Minimum contract vocabulary for this cycle: interaction visibility, user participation requirement, required analyze artifacts, completion requirements, and the smallest state/runtime exposure needed for firmware to obey that contract.
- Frozen guard set for the first RED pass: `firmware_agent_test.dart`, `fsm_contract_test.dart`, `fsm_state_test.dart`, `fsm_transition_test.dart`, `effect_executor_test.dart`, `ape_prompt_test.dart`, `ape_definition_test.dart`, and `assets_test.dart`.
- Out of scope for #180 EXECUTE: DARWIN/EVOLUTION cleanup, a generic configurable APE registry across all states, and a full state-contract rewrite of IDLE/PLAN/EXECUTE beyond bounded prompt hygiene.

**Verification / test definition:**
```text
for each required source surface in phase 0:
  assert the file was reviewed and mapped to one of these concerns:
    - ANALYZE contract
    - ANALYZE boundary gate
    - firmware interaction policy
    - analyze bootstrap artifacts
    - active non-DARWIN APE prompt hygiene
assert the minimum contract vocabulary is stated before code edits begin
assert the focused regression guard set is frozen before implementation starts
assert DARWIN and full multi-phase redesign are recorded as out of scope
```

**TDD applicability:** None. This phase freezes the execution boundary and nearby guard surface.

## Phase 1: Lock failing guards for ANALYZE visibility, completion, and artifact naming

**Entry criteria:** Phase 0 has frozen the minimum contract vocabulary and nearby regression surfaces.

**Dependencies:** Phase 0 complete.

**Risk note:** D1, D3, and F5 say the failure must be made executable before source edits claim to solve it. Otherwise the implementation can still pass by narrative rather than by guard.

- [x] Strengthen the nearby tests so they can fail on the issue-180 defects now named in the diagnosis: hidden ANALYZE progression, insufficient ANALYZE completion proof, and confirmed.md bootstrapping where the contract target is confirmations.md.
- [x] Add or adjust assertions in `code/cli/test/firmware_agent_test.dart` so firmware can be distinguished between universally hidden dispatch and state-aware ANALYZE dialogue behavior.
- [x] Add or adjust assertions in `code/cli/test/fsm_contract_test.dart`, `code/cli/test/fsm_state_test.dart`, and `code/cli/test/fsm_transition_test.dart` so the ANALYZE contract and the ANALYZE -> PLAN boundary can be tested for the new required conditions instead of only `diagnosis_exists`.
- [x] Add or adjust assertions in `code/cli/test/effect_executor_test.dart` and `code/cli/test/ape_prompt_test.dart` so confirmations.md becomes the target analyze artifact name and prompt/context surfaces stop hardwiring confirmed.md as the canonical artifact.
- [x] Keep the RED surface bounded to #180. Do not invent a new all-phase generic policy engine in the tests before there is a minimal source design to support it.

**QA result:** PASS (expected RED observed)

Focused bundle executed:

- `firmware_agent_test.dart`
- `ape_prompt_test.dart`
- `fsm_contract_test.dart`
- `fsm_state_test.dart`
- `fsm_transition_test.dart`

Observed RED boundary after the first TDD pass: 105 tests passed, 8 failed.

The failing cases are now concentrated on the intended issue-180 slice:

- firmware still declares a universal user-interaction rule and does not document visible ANALYZE interaction;
- analyze prompt/context still emits `confirmed_doc` and `confirmed.md` instead of `confirmations_doc` and `confirmations.md`;
- the operational contract for ANALYZE still exposes neither `required_artifacts` nor `interaction`;
- the ANALYZE -> PLAN boundary still requires only `diagnosis_exists` and therefore still allows completion without `index.md` and `confirmations.md`.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/firmware_agent_test.dart test/fsm_contract_test.dart test/fsm_state_test.dart test/fsm_transition_test.dart test/effect_executor_test.dart test/ape_prompt_test.dart"
expect the suite to fail RED until the ANALYZE contract, boundary, and artifact surfaces are aligned
assert at least one guard distinguishes confirmed.md from confirmations.md
assert at least one guard distinguishes diagnosis_exists-only completion from the fuller ANALYZE completion rule
assert at least one guard distinguishes hidden universal dispatch from ANALYZE-visible interaction behavior
```

**TDD applicability:** Yes. This is the RED/GREEN gate for the issue-180 slice.

## Phase 2: Implement the minimal state-owned ANALYZE contract and boundary gate

**Entry criteria:** Phase 1 has established the failing guard surface or confirmed the exact green conditions to preserve.

**Dependencies:** Phase 1 complete.

**Risk note:** D1 and D4 require the repair to be phase-owned, not SOCRATES-owned. If this phase only rewrites SOCRATES or firmware wording, the architectural defect remains.

- [x] Extend `code/cli/lib/modules/ape/operational_contract.dart` and any dependent state serialization surfaces only as much as needed to expose the ANALYZE-specific metadata required by the fix.
- [x] Rewrite `code/cli/assets/fsm/states/analyze.yaml` so ANALYZE becomes methodology-agnostic and explicitly owns user participation, visible interaction, analyze corpus expectations, and completion prerequisites.
- [x] Update `code/cli/assets/fsm/transition_contract.yaml` and `code/cli/lib/modules/fsm/commands/transition.dart` so ANALYZE -> PLAN no longer reduces completion to `diagnosis_exists` alone.
- [x] Update `code/cli/lib/modules/fsm/commands/state.dart` if needed so the runtime exposes the new operational contract data required by firmware behavior.
- [x] Keep the implementation minimal: solve the ANALYZE slice without forcing a full declarative redesign of every other state in the same phase.
- [x] Re-run the focused contract and transition guard set immediately after the source edits.

**QA result:** PASS

Focused bundle executed after the minimal contract implementation:

- `fsm_contract_test.dart`
- `fsm_state_test.dart`
- `fsm_transition_test.dart`

Observed result after one local fixture repair pass: 59 passed, 0 failed.

What is now green in the issue-180 slice:

- ANALYZE exposes `required_artifacts` and `interaction` through the operational contract surface;
- `analyze.yaml` now carries a methodology-agnostic phase contract with explicit participation and visibility requirements;
- the ANALYZE -> PLAN boundary no longer reduces completion to `diagnosis_exists` alone and now requires `index.md` and `confirmations.md`;
- the transition validator now fails closed when the analysis corpus is structurally incomplete.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/fsm_contract_test.dart test/fsm_state_test.dart test/fsm_transition_test.dart"
expect exit_code == 0
assert analyze.yaml is no longer defined by specifically Socratic wording where the phase contract should be methodology-agnostic
assert ANALYZE -> PLAN no longer relies on diagnosis_exists as the sole green condition
assert state output exposes the operational contract data needed by firmware to behave differently in ANALYZE
```

**TDD applicability:** Yes. This is the GREEN step for the state-owned ANALYZE contract.

## Phase 3: Align firmware, bootstrap, and prompt surfaces to the ANALYZE contract

**Entry criteria:** Phase 2 is green; the ANALYZE contract and boundary semantics are now explicit enough to drive runtime behavior.

**Dependencies:** Phase 2 complete.

**Risk note:** D3 says the defect is distributed across firmware, bootstrap, and prompt surfaces. If only the YAML contract changes, the user still experiences the same hidden runtime behavior.

- [x] Update `code/cli/assets/agents/inquiry.agent.md` so the scheduler no longer treats the completion gate as the only user interaction point in every state.
- [x] Make firmware behavior explicitly state-aware for ANALYZE: the active analysis APE's output must remain visible, further inner-loop movement must depend on visible user exchange, and hidden autonomous progression to `_DONE` must no longer be the implied default.
- [x] Update `code/cli/lib/modules/fsm/effect_executor.dart` so analyze bootstrap uses confirmations.md and no longer stamps the analyze artifact as if SOCRATES owned it.
- [x] Update `code/cli/test/ape_prompt_test.dart` and any nearby prompt/context expectations so the analyze corpus references confirmations.md consistently.
- [x] Re-run firmware, effect, and prompt tests immediately after the edits.

**QA result:** PASS

Focused runtime bundle executed after the firmware/bootstrap alignment:

- `firmware_agent_test.dart`
- `effect_executor_test.dart`
- `ape_prompt_test.dart`

Observed result after one firmware-thinning repair pass: 77 passed, 0 failed.

What is now green in the issue-180 slice:

- firmware no longer frames the completion gate as a universal interaction monopoly and now states that ANALYZE must remain visible to the user;
- the analyze bootstrap now creates `confirmations.md` and removes methodology-colored ownership from the file template;
- the SOCRATES runtime prompt context now injects `confirmations_doc` instead of `confirmed_doc`.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/firmware_agent_test.dart test/effect_executor_test.dart test/ape_prompt_test.dart"
expect exit_code == 0
assert inquiry.agent.md no longer declares one universal user-interaction rule that hides ANALYZE dialogue
assert open_analysis_context creates confirmations.md, not confirmed.md
assert prompt/context surfaces no longer reference confirmed.md as the canonical analyze artifact
assert the analyze artifact bootstrap no longer encodes author: socrates as the meaning of the file
```

**TDD applicability:** Yes. This is the GREEN step for the runtime/bootstrapping slice.

## Phase 4: Decouple SOCRATES and apply bounded prompt hygiene to DEWEY, DESCARTES, and BASHO

**Entry criteria:** Phase 3 is green; the acute ANALYZE defect is fixed in phase-owned surfaces.

**Dependencies:** Phase 3 complete.

**Risk note:** D2 and D4 say the doctrine must be generalized, but the issue must stay bounded. This phase is hygiene, not a full phase-contract rewrite for IDLE, PLAN, and EXECUTE.

- [x] Remove repository-procedure leakage from `code/cli/assets/apes/socrates.yaml` so SOCRATES keeps mayeutic method but stops owning named repository deliverables or implicit completion authority.
- [x] Apply the same bounded cleanup rule to `code/cli/assets/apes/dewey.yaml`, `code/cli/assets/apes/descartes.yaml`, and `code/cli/assets/apes/basho.yaml`: keep method, remove the clearest phase-policy and repository-procedure leakage that is now owned elsewhere.
- [x] Keep the cleanup bounded to prompt purity. Do not simultaneously redesign all state contracts for IDLE, PLAN, and EXECUTE in this phase.
- [x] Update the nearby tests that hardcode the old artifact and prompt assumptions, especially `code/cli/test/ape_definition_test.dart`, `code/cli/test/ape_prompt_test.dart`, and any other touched prompt tests.
- [x] If the bounded cleanup reveals that DEWEY, DESCARTES, or BASHO need a larger host-phase redesign to stay coherent, record a deviation and stop widening scope under #180.

**QA result:** PASS

Focused prompt-hygiene bundle executed after the bounded APE cleanup:

- `ape_definition_test.dart`
- `ape_prompt_test.dart`
- `firmware_agent_test.dart`

Observed result: 81 passed, 0 failed.

What is now green in the issue-180 slice:

- SOCRATES keeps Socratic method while dropping direct ownership of a named repository deliverable;
- DEWEY no longer carries the clearest repository-procedure leakage in its base prompt and local sub-prompts;
- DESCARTES now speaks in terms of approved analysis/planning contracts instead of hardwiring `diagnosis.md` and approval semantics into its identity prompt;
- BASHO now refers to the approved phase plan and active execution contract without owning `plan.md` or commit procedure details directly.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/ape_definition_test.dart test/ape_prompt_test.dart test/firmware_agent_test.dart"
expect exit_code == 0
assert socrates.yaml keeps mayeutic method but no longer names canonical repository deliverables as its own responsibility
assert dewey.yaml, descartes.yaml, and basho.yaml preserve methodology while dropping the clearest phase-policy leakage targeted in this cycle
assert no touched APE prompt becomes empty, incoherent, or dependent on hidden firmware assumptions after the cleanup
```

**TDD applicability:** Yes. This is the hygiene GREEN step for the active non-DARWIN APE roster.

## Phase 5: Rebuild packaged assets and replay focused behavior checks from the packaged surface

**Entry criteria:** Phases 2-4 are green; source-of-truth assets are stable for this issue.

**Dependencies:** Phases 2-4 complete.

**Risk note:** The repo ships packaged assets. Leaving the build tree stale would preserve exactly the kind of source/build ambiguity that previously confused issue #181.

- [x] Rebuild the CLI package with `code/cli/scripts/build.ps1` so `code/cli/build/bin/inquiry.exe` and `code/cli/build/assets/` mirror the repaired source surfaces.
- [x] Compare source vs packaged assets for this slice only: `inquiry.agent.md`, `fsm/states/analyze.yaml`, `fsm/transition_contract.yaml`, active APE YAMLs touched in this cycle, and the analyze bootstrap artifacts implied by prompt/context output.
- [x] Replay the narrow packaged behavior checks needed for this issue from a clean workspace trace: packaged `fsm state`, packaged `ape prompt` for ANALYZE and PLAN, and packaged analyze bootstrap naming.
- [x] Record any discrepancy outside the issue-180 slice as out of scope rather than letting it blur this plan.

**QA result:** PASS

Packaged validation executed in two passes:

- initial rebuild with `code/cli/scripts/build.ps1`;
- packaged trace replay after a local repair to `instructions/doc-write.md`, which still leaked `confirmed_doc` into transition-owned instructions.

Final packaged checks that passed:

- source/package asset parity for `inquiry.agent.md`, `fsm/states/analyze.yaml`, `fsm/transition_contract.yaml`, `instructions/doc-write.md`, and the touched active APE YAMLs;
- packaged `fsm state --json` in IDLE, ANALYZE, and PLAN from a clean temporary git workspace;
- packaged ANALYZE bootstrap creating `index.md` and `confirmations.md` on `start_analyze`;
- packaged `ape prompt --name socrates --state clarification` exposing `confirmations_doc` with no stale `confirmed_doc` leakage;
- packaged `ape prompt --name descartes --state decomposition` exposing `analysis_input` after `complete_analysis`.

No out-of-scope packaged discrepancy remains open for the issue-180 slice after the `doc-write.md` repair.

**Verification / test definition:**
```text
run "pwsh -File code/cli/scripts/build.ps1"
expect exit_code == 0
assert code/cli/build/bin/inquiry.exe exists
for each touched source/package pair:
  assert source and packaged agree on the issue-180 strings
bootstrap a clean workspace trace with the packaged binary
assert packaged analyze bootstrap yields confirmations.md
assert packaged ape prompt for the active ANALYZE and PLAN APEs succeeds on the clean trace
```

**TDD applicability:** None. This phase mirrors already-green source behavior into the packaged surface.

## Phase 6: Run full project verification and close execution readiness

**Entry criteria:** Phase 5 is complete; no unresolved deviation remains from the issue-180 slice.

**Dependencies:** Phase 5 complete.

**Risk note:** The PLAN contract requires final full-suite verification. Without it, the cycle could ship a clean local slice that destabilizes adjacent CLI behavior.

- [x] Run the focused Dart test bundle for the issue-180 surfaces one final time after all source and packaged edits are settled.
- [x] Run `dart analyze` for `code/cli`.
- [x] Run the complete existing Dart test suite for `code/cli`.
- [x] Run the existing VS Code extension test surfaces if the touched assets or docs materially affect them; if not, record the reason they are outside the changed slice.
- [x] Record execution readiness in the plan: what passed, what was not run, and whether any deviation remains.

**QA result:** PASS

Final verification executed after Phases 2-5 settled:

- Focused issue-180 Dart bundle: `firmware_agent_test.dart`, `fsm_contract_test.dart`, `fsm_state_test.dart`, `fsm_transition_test.dart`, `effect_executor_test.dart`, `ape_prompt_test.dart`, `ape_definition_test.dart`, `assets_test.dart`
- `dart analyze` in `code/cli`
- full `dart test` suite in `code/cli`

Observed results:

- focused bundle: 178 passed, 0 failed;
- `dart analyze`: clean after one local fixture cleanup (`unused_local_variable` in `fsm_transition_test.dart`);
- full CLI suite: 386 passed, 0 failed.

VS Code extension tests were not run. Reason: the modified slice is confined to `code/cli` source assets, CLI prompt assembly/runtime behavior, and CLI tests; no files under `code/vscode/` or extension-specific execution surfaces were changed.

Execution readiness for #180:

- no known deviation remains open in the repaired issue-180 slice;
- the phase-owned ANALYZE contract, boundary gate, runtime surfaces, bounded APE hygiene, write protocol, and packaged surface all agree on `confirmations.md` and visible ANALYZE interaction;
- the CLI is ready for the next formal boundary in the FSM.

**Verification / test definition:**
```text
run "cd code/cli && dart test test/firmware_agent_test.dart test/fsm_contract_test.dart test/fsm_state_test.dart test/fsm_transition_test.dart test/effect_executor_test.dart test/ape_prompt_test.dart test/ape_definition_test.dart test/assets_test.dart"
expect exit_code == 0
run "cd code/cli && dart analyze"
expect exit_code == 0
run "cd code/cli && dart test"
expect exit_code == 0
if vscode surfaces were touched materially:
  run the existing VS Code test command(s)
else:
  record why they remain outside the modified slice
```

**TDD applicability:** None. This phase confirms that the repaired slice stays green across the full existing project surface.