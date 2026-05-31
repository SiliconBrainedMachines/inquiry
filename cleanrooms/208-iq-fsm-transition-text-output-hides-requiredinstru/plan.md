---
id: plan
title: "Execution Plan — issue 208: transition text must expose required instructions"
date: 2026-05-30
status: draft
tags: [plan, tdd, issue-208, fsm, transition, prompt]
author: descartes
---

# Execution Plan — issue 208: transition text must expose required instructions

## 0. Framing

This plan implements the diagnosis in [analyze/diagnosis.md](analyze/diagnosis.md).
Its controlling decisions are:

- D1: treat the bug as a text-surface fidelity problem, not as a prompt-assembly failure.
- D2: scope the repair to transitions whose prompt fragment carries non-empty instructions.
- D3: keep structured transition metadata, human-readable transition text, and assembled APE prompt as separate surfaces.

Working hypothesis:

> If the transition text surface conditionally renders the structured metadata the runtime already computes for instruction-bearing transitions, while prompt assembly continues to own summary transport, then the CLI will expose required follow-up contract information without collapsing text output into full instruction documents.

Operational constraints:

- PLAN produces this document only; no source edits belong here.
- Execution must stay on the transition text surface, structured metadata, prompt assembly boundary, and tests around those surfaces.
- Phases 1 through 4 should use RED -> GREEN where applicable.
- The cycle ends with a final full-project test-suite verification step.
- User approval is required before transition out of PLAN.

## 1. Surfaces In Scope

- code/cli/lib/modules/fsm/commands/transition.dart
  Owns StateTransitionOutput, the current toText() behavior, and the structured metadata already emitted by execute().
- code/cli/lib/modules/ape/commands/prompt.dart
  Owns the separate transition-instruction assembly path used by iq ape prompt.
- code/cli/lib/modules/ape/instruction_prompt_loader.dart
  Owns summary-only loading from instruction markdown.
- code/cli/test/ape_prompt_test.dart
  Owns the nearest command-level coverage for iq ape prompt assembly and is the natural D3 guardrail when transition-text rendering changes nearby.
- code/cli/test/fsm_transition_test.dart
  Owns the nearest command-level coverage for transition behavior.
- code/cli/test/fsm_transition_integration_test.dart
  Owns integration coverage for transition command behavior if representative end-to-end checks are needed.
- code/cli/test/instruction_prompt_loader_test.dart
  Owns the nearest executable proof that prompt assembly transports summaries, not whole markdown documents.

Out of scope:

- changing transition-contract semantics in transition_contract.yaml
- changing instruction markdown content in assets/instructions
- making iq fsm transition execute the follow-up work itself
- collapsing the text surface into the same payload used by iq ape prompt

## 2. Phase Dependencies

- Phase 1 has no implementation dependency and establishes the executable contract.
- Phase 2 depends on Phase 1.
- Phase 3 depends on Phase 2's chosen formatter shape.
- Phase 4 depends on Phases 2 and 3.
- Phase 5 depends on all prior phases.

## 3. Phases

### Phase 1 — Freeze The Text-Surface Contract

Dependencies: none.

Entry criteria:

- [ ] The diagnosis decisions D1 through D3 are accepted as implementation boundaries.
- [ ] The relevant owning surfaces are confirmed in transition.dart, prompt.dart, and the existing transition/prompt tests.

Execution:

- [ ] Add characterization coverage for StateTransitionOutput.toText() when requiredInstructions is null or empty, proving message-only output remains the baseline for no-instruction transitions.
- [ ] Add RED coverage for instruction-bearing transition outputs that requires the text surface to expose the already-computed metadata block: message, required_role, required_instructions, and prompt_fragment_id.
- [ ] Reuse existing fragments already present in the contract, especially analyze_to_plan with doc-write and idle_to_analyze with doc-read, so coverage exercises real metadata without inventing new transition semantics.
- [ ] Keep assertions semantic rather than whitespace-coupled so the repair cannot regress by hiding fields behind minor formatting churn.

Verification:

- [ ] The no-instruction characterization test passes against current behavior.
- [ ] The instruction-bearing text-fidelity test fails against current behavior, proving the diagnosed gap before implementation starts.

Test definitions in pseudocode:

```text
output = StateTransitionOutput(
  allowed: true,
  currentState: 'ANALYZE',
  event: 'complete_analysis',
  nextState: 'PLAN',
  promptFragmentId: 'analyze_to_plan',
  requiredRole: 'DESCARTES',
  requiredInstructions: ['doc-write'],
  message: 'Transition ANALYZE --complete_analysis--> PLAN',
)

expect(output.toText(), contains('Transition ANALYZE --complete_analysis--> PLAN'))
expect(output.toText(), contains('DESCARTES'))
expect(output.toText(), contains('doc-write'))
expect(output.toText(), contains('analyze_to_plan'))

plainOutput = StateTransitionOutput(
  allowed: true,
  currentState: 'PLAN',
  event: 'approve_plan',
  nextState: 'EXECUTE',
  promptFragmentId: 'plan_to_execute',
  requiredRole: 'BASHO',
  requiredInstructions: [],
  message: 'Transition PLAN --approve_plan--> EXECUTE',
)

expect(plainOutput.toText(), equals('Transition PLAN --approve_plan--> EXECUTE'))
```

Risk notes:

- The diagnosis authorizes metadata visibility but does not pin a final human-readable layout; tests should lock field presence before they lock cosmetic formatting.
- This phase must not assert full instruction summaries; D3 reserves that behavior for prompt assembly.

### Phase 2 — Implement Conditional Transition-Text Enrichment

Dependencies: Phase 1.

Entry criteria:

- [ ] Phase 1 has a passing no-instruction characterization and a failing instruction-bearing text-fidelity test.

Execution:

- [ ] Refactor StateTransitionOutput.toText() into a deterministic formatter that starts with message and conditionally appends structured metadata only when requiredInstructions is non-empty.
- [ ] Preserve the existing structured JSON contract from execute(); the change belongs to rendering, not to transition resolution.
- [ ] Keep the formatter dependent only on fields already carried by StateTransitionOutput.
- [ ] Do not load instruction markdown, Prompt Summary content, or any additional asset file inside toText().

Verification:

- [ ] Phase 1 tests turn green.
- [ ] Existing command tests that inspect promptFragmentId, requiredRole, and requiredInstructions remain green without semantic rewrites.
- [ ] No-instruction transitions still render the original single-line message.

Test definitions in pseudocode:

```text
output = runTransition(event: 'complete_analysis')

expect(output.requiredInstructions, ['doc-write'])
expect(output.requiredRole, 'DESCARTES')
expect(output.promptFragmentId, 'analyze_to_plan')
expect(output.toText(), contains('doc-write'))
expect(output.toText(), contains('DESCARTES'))
expect(output.toText(), contains('analyze_to_plan'))

plainOutput = runTransition(event: 'approve_plan')

expect(plainOutput.requiredInstructions, isEmpty)
expect(plainOutput.toText(), equals('Transition PLAN --approve_plan--> EXECUTE'))
```

Risk notes:

- Illegal-transition and precheck-failure text must not accidentally gain empty metadata wrappers.
- The formatter should remain brief enough for terminal use; surfacing identifiers is in scope, inlining long-form protocol prose is not.

### Phase 3 — Guard The Prompt-Assembly Boundary

Dependencies: Phase 2.

Entry criteria:

- [ ] Phase 2 proves the text formatter uses only structured metadata already present on transition output.

Execution:

- [ ] Add or tighten tests in ape_prompt_test.dart and instruction_prompt_loader_test.dart so summary transport remains the responsibility of prompt assembly.
- [ ] Add a regression that demonstrates the intended separation of surfaces: transition text exposes instruction identifiers, while ape prompt exposes normalized Prompt Summary content.
- [ ] Use current assets such as issue-end or doc-write to prove the separation with real instruction data instead of synthetic markdown fixtures when possible.
- [ ] If helper extraction is introduced during execution, keep transition text formatting and prompt-summary loading in separate units with separate tests.

Verification:

- [ ] ape_prompt_test.dart remains green for prompt assembly scenarios that resolve prompt_fragment_id into Prompt Summary content.
- [ ] InstructionPromptLoader tests still prove that only Prompt Summary content is loaded.
- [ ] Prompt assembly tests remain green and do not depend on transition-text formatting details.
- [ ] Transition-text tests do not require phrases taken from instruction markdown bodies.

Test definitions in pseudocode:

```text
transitionText = transitionOutput.toText()

expect(transitionText, contains('doc-write'))
expect(transitionText, isNot(contains('Read index_file first from inquiry-context.')))

prompt = buildApePrompt(name: 'descartes', promptFragmentId: 'analyze_to_plan')

expect(prompt, contains('Write inside the CLI-created template and keep frontmatter unchanged.'))
expect(prompt, isNot(contains('## When to Use')))
```

Risk notes:

- The cheapest stable proof may combine transition coverage for analyze_to_plan/doc-write with loader coverage for issue-end if a direct END-path fixture is expensive to maintain.
- This phase must resist the temptation to solve the problem by duplicating prompt summaries into transition text.

### Phase 4 — Add Command And Integration Regressions For Aligned Surfaces

Dependencies: Phases 2 and 3.

Entry criteria:

- [ ] The formatter contract is green at unit level.
- [ ] Prompt-assembly guardrail tests are green.

Execution:

- [ ] Extend transition command tests to cover one transition with non-empty instructions and one with empty instructions using the nearest existing fixtures.
- [ ] Add or update integration coverage so structured metadata and toText() are asserted together on the same command result.
- [ ] Include a failure-path regression to prove illegal or precheck-blocked transitions preserve their original failure text without irrelevant metadata.
- [ ] Prefer the existing analyze_to_plan and plan_to_execute command scenarios before introducing broader test harnesses.

Verification:

- [ ] Command-level tests prove alignment between requiredInstructions and the human-readable text surface.
- [ ] Integration-level tests prove empty-instruction transitions remain concise.
- [ ] Existing branch policy, boundary-commit, and precheck tests remain green.

Test definitions in pseudocode:

```text
output = runTransition(event: 'complete_analysis')

expect(output.requiredInstructions, ['doc-write'])
expect(output.toText(), contains('doc-write'))
expect(output.toText(), contains('DESCARTES'))

plainOutput = runTransition(event: 'approve_plan')

expect(plainOutput.requiredInstructions, isEmpty)
expect(plainOutput.toText(), equals('Transition PLAN --approve_plan--> EXECUTE'))

illegalOutput = runTransition(event: 'go_execute', state: 'IDLE')

expect(illegalOutput.allowed, isFalse)
expect(illegalOutput.toText(), contains('forbidden'))
expect(illegalOutput.toText(), isNot(contains('Required instructions')))
```

Risk notes:

- END is materially important in the diagnosis, but representative coverage may still be cheaper and more stable than a dedicated END transition harness.
- Over-broad integration changes would violate D1 by widening this into a prompt-assembly rewrite.

### Phase 5 — Final Verification Gate

Dependencies: Phases 1 through 4.

Entry criteria:

- [ ] All targeted transition and prompt-boundary tests added in earlier phases are green.

Execution:

- [ ] Run the narrow CLI tests touched by the implementation slice first — fsm_transition_test.dart, fsm_transition_integration_test.dart, ape_prompt_test.dart, and instruction_prompt_loader_test.dart — so failures remain local and diagnosable.
- [ ] Run the full project test suite, including all existing tests beyond the FSM slice.
- [ ] Compare the observed outcome against the planning hypothesis: richer text only when requiredInstructions is non-empty, unchanged concise text when it is empty, and no prompt-assembly coupling.
- [ ] If the full-suite run exposes a contradiction to D1 through D3, stop and return to ANALYZE rather than broadening the fix opportunistically.

Verification:

- [ ] All existing tests pass across the full project suite.
- [ ] No regression appears in iq ape prompt or InstructionPromptLoader behavior.
- [ ] Representative instruction-bearing transitions and empty-instruction transitions both satisfy the intended text contract.

Test definitions in pseudocode:

```text
runFocusedCliTests([
  'fsm_transition_test',
  'fsm_transition_integration_test',
  'ape_prompt_test',
  'instruction_prompt_loader_test',
])
expect(allFocusedTestsPass, true)

runFullProjectTestSuite()
expect(allProjectTestsPass, true)
```

Risk notes:

- The full suite may surface unrelated pre-existing failures; execution must separate those from regressions introduced by this change.
- A green focused slice is not sufficient closure for this issue; the full-suite gate is mandatory.

## 4. Open Ambiguities To Carry Into PLAN Review

- The analysis authorizes exposing structured metadata on the text surface, but it does not settle the final human-readable labels and ordering. Execution should treat field visibility as the invariant; PLAN review should confirm the exact presentation contract before tests overfit it.
- If a direct END transition harness is not the cheapest stable executable check, PLAN review should confirm that representative command coverage plus issue-end prompt-path coverage is sufficient for this issue.