---
id: confirmations
title: "Confirmations"
date: 2026-05-30
status: active
tags: [confirmations, findings]
---

# Confirmations

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: StateTransitionOutput loses operational guidance on the text surface — CONFIRMED

`StateTransitionOutput` carries `required_role`, `required_instructions`, and `prompt_fragment_id` in its structured output, but `toText()` returns only `message`.

Evidence:
- `code/cli/lib/modules/fsm/commands/transition.dart`

Implication:
- A terminal-first consumer that only sees the text surface does not receive all the transition guidance the runtime already computed.

## F2: In END-related transitions, `required_instructions` represents material work, not decorative metadata — CONFIRMED

The transition contract maps EXECUTE and END follow-up paths to `issue-end`, and that instruction includes version bump, CHANGELOG, commit, push, and PR creation obligations.

Evidence:
- `code/cli/assets/fsm/transition_contract.yaml`
- `code/cli/assets/instructions/issue-end.md`

Implication:
- Omitting those instructions from visible transition text can hide contractually relevant work.

## F3: Inquiry already has a dedicated long-instruction transport path for the LLM — CONFIRMED

The active APE prompt resolves `prompt_fragment_id`, loads the named instruction documents, extracts only the `## Prompt Summary` section, and injects that summary into the effective prompt.

Evidence:
- `code/cli/lib/modules/ape/commands/prompt.dart`
- `code/cli/lib/modules/ape/instruction_prompt_loader.dart`
- `code/cli/test/instruction_prompt_loader_test.dart`

Implication:
- The canonical long-form transport for the LLM is not `iq fsm transition` text output; it is the assembled APE prompt plus instruction summaries.

## F4: The impact is conditional, not universal — CONFIRMED

Not every transition is equally affected. The contract includes prompt fragments with empty `instructions`; in those cases, collapsing the text output to `message` does not discard additional operational content.

Evidence:
- `code/cli/assets/fsm/transition_contract.yaml`

Implication:
- The issue scope is narrower than “all transitions”: it concerns transitions whose prompt fragment has non-empty `instructions`.

## F5: Current test coverage protects the structured model but not the human-readable text surface — CONFIRMED

Existing tests assert structured transition metadata and instruction summary loading, but this analysis found no equivalent assertion for `StateTransitionOutput.toText()` preserving or surfacing that metadata.

Evidence:
- `code/cli/test/fsm_transition_test.dart`
- `code/cli/test/fsm_transition_integration_test.dart`
- `code/cli/test/instruction_prompt_loader_test.dart`

Implication:
- The current test suite is aligned with the observed drift: structured guidance is covered, visible text fidelity is not.

## F6: The audit is being run on an active installed CLI older than the merged source tree — CONFIRMED

`iq doctor` reported `inquiry 0.6.1` with `0.6.3 available`. This does not invalidate the finding because the current repository source inspected during ANALYZE still shows `toText() => message`, but it does matter for claims about the exact runtime the audit exercised.

Evidence:
- `iq doctor` output during issue-start / ANALYZE

Implication:
- Conclusions about the architectural mismatch are source-grounded; conclusions about end-to-end runtime behavior should note the installed/runtime version gap.
