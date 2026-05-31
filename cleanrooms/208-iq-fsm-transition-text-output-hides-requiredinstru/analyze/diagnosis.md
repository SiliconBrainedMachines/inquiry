---
id: diagnosis
title: "Diagnosis — issue 208: transition text hides operational follow-up"
date: 2026-05-30
status: final
tags: [diagnosis, issue-208, fsm, transition, prompt, instructions, analyze]
author: socrates
---

# Diagnosis — issue 208: transition text hides operational follow-up

## 1. Problem Defined

Issue #208 concerns a mismatch between two surfaces produced by the Inquiry CLI for the same state transition:

- the structured transition output, which carries `required_role`, `required_instructions`, and `prompt_fragment_id`, and
- the human-readable text output, which currently returns only the generic transition message.

The issue is not merely cosmetic. For some transitions, especially around EXECUTE and END, the omitted instruction payload corresponds to material operational work rather than explanatory metadata.

The active audit also clarified a second boundary: the CLI already has a separate channel for passing complex operational guidance to the LLM. That channel is the assembled APE prompt, not the plain-text output of `iq fsm transition`.

## 2. Evidence

### E1: Structured transition output is richer than the text output

In `code/cli/lib/modules/fsm/commands/transition.dart`, `StateTransitionOutput` exposes:

- `promptFragmentId`
- `requiredRole`
- `requiredInstructions`

and `execute()` populates those fields from the resolved prompt fragment. However, `toText()` returns only `message`.

This confirms that the visible text surface discards transition metadata that the runtime already computed.

### E2: Some prompt fragments carry operationally significant instructions

In `code/cli/assets/fsm/transition_contract.yaml`, END-related prompt fragments resolve to `issue-end`. The underlying instruction document at `code/cli/assets/instructions/issue-end.md` includes operational obligations such as:

- choosing and applying the version bump,
- updating `CHANGELOG.md`,
- committing the release changes,
- pushing the branch, and
- creating the pull request.

Therefore, in those transitions, hidden instructions are hidden obligations.

### E3: Inquiry already transports long-form instructions through the prompt assembly path

The current LLM transport path does not rely on transition text output.

`code/cli/lib/modules/ape/commands/prompt.dart` resolves `prompt_fragment_id`, loads the associated instruction names, and passes them through `InstructionPromptLoader`.

`code/cli/lib/modules/ape/instruction_prompt_loader.dart` does not inject the full markdown document. It extracts only the `## Prompt Summary` section and normalizes it into prompt-ready text. Tests in `code/cli/test/instruction_prompt_loader_test.dart` confirm this behavior for `issue-start`, `issue-end`, `doc-read`, and `doc-write`.

This means the CLI already has a deliberate mechanism for delivering long or complex protocol guidance to the LLM without overloading a plain-text terminal line.

### E4: The impact is selective

The issue does not affect every transition equally. Some prompt fragments define empty `instructions`, and in those cases the generic message does not omit additional operational content.

The practical boundary is therefore not “all delegated transitions,” but specifically transitions whose prompt fragment has non-empty `instructions`.

### E5: Coverage gap is on text fidelity, not on structured metadata

The test suite covers the structured transition model and the instruction summary loader, but this analysis did not find corresponding coverage for the fidelity of `StateTransitionOutput.toText()` when instructions are present.

That matches the observed drift: the structured model is present and test-protected, while the text surface can diverge silently.

## 3. Decisions Taken During Analysis

### D1: Treat the issue as a surface-fidelity problem, not as a prompt-assembly problem

The prompt assembly path already carries instruction summaries into the LLM-facing prompt. The diagnosed mismatch is specifically between the runtime's structured transition knowledge and the transition command's human-readable text surface.

### D2: Narrow the issue scope to transitions with non-empty instruction payloads

The analysis rejects the broader claim that every transition is equally affected. The meaningful scope is transitions whose prompt fragment carries instructions with operational content.

### D3: Keep transport concerns separate

This cycle distinguishes three different surfaces:

- structured transition metadata,
- human-readable transition text, and
- assembled APE prompt for the LLM.

Collapsing them into one surface would obscure the actual problem definition.

## 4. Constraints and Risks Identified

| # | Constraint / Risk | Effect on diagnosis |
|---|-------------------|--------------------|
| R1 | The active installed CLI reported by `iq doctor` is 0.6.1 while the source tree under analysis is newer | Runtime observations must be framed carefully; source-level conclusions remain valid |
| R2 | ANALYZE must not prescribe implementation | This diagnosis defines the mismatch and scope, but does not choose a repair strategy |
| R3 | Some legacy docs still describe older runtime surfaces elsewhere in the repo | This diagnosis relies on current code and tests as the controlling evidence, not on broad narrative docs |

## 5. Scope

### In scope

- Whether `iq fsm transition` loses operational guidance on its text surface
- Whether that guidance is materially important in current transitions
- Which current runtime surface actually transports long instructions to the LLM
- Whether the issue is universal or limited to a subset of transitions

### Out of scope

- Choosing the concrete implementation strategy for a future fix
- Deciding whether the text surface should be brief, rich, or machine-oriented
- Refactoring the skill/private-skill naming model
- Any change to EXECUTE/END semantics beyond the diagnosed visibility mismatch

## 6. Conclusions

1. The issue is real: current transition text output does not expose all the operational guidance the runtime already knows.
2. In END-related transitions, the omitted guidance corresponds to materially significant release and PR work.
3. The current architecture already has a better channel for long-form LLM guidance: prompt assembly via `iq ape prompt`, backed by instruction summaries.
4. The problem is therefore not that the CLI lacks a transport for long instructions; it is that the text surface of `iq fsm transition` does not reveal enough of the transition contract when instructions are present.
5. The affected scope is narrower than all transitions and should be understood as conditional on non-empty prompt-fragment instructions.

## 7. References

- `code/cli/lib/modules/fsm/commands/transition.dart`
- `code/cli/assets/fsm/transition_contract.yaml`
- `code/cli/assets/instructions/issue-end.md`
- `code/cli/lib/modules/ape/commands/prompt.dart`
- `code/cli/lib/modules/ape/instruction_prompt_loader.dart`
- `code/cli/test/fsm_transition_test.dart`
- `code/cli/test/fsm_transition_integration_test.dart`
- `code/cli/test/instruction_prompt_loader_test.dart`