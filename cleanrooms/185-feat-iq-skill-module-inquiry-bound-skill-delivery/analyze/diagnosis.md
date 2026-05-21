---
id: diagnosis
title: Diagnosis of private instructions versus universal skills
date: 2026-05-20
status: active
tags: [analysis, instructions, skills, fsm, prompts]
author: socrates
---

# Diagnosis

## Problem Defined

Issue #185 is no longer about introducing an `iq skill` CLI surface for Inquiry-private protocols. The corrected problem is architectural: Inquiry needs two different classes of prompt artifacts.

- Transition-owned private protocols such as `doc-read`, `doc-write`, `issue-start`, and `issue-end` should be treated as `instructions`, stored under `code/cli/assets/instructions/<name>.md`, and referenced from FSM transition prompt fragments through an `instructions:` list.
- Universal thinking tools such as `legion`, `research`, and `kritik` should remain `skills`, stored under `code/cli/assets/skills/<name>/SKILL.md`, and remain reusable outside the Inquiry FSM.
- `inquiry-install` does not belong to this runtime delivery path. If Inquiry can already be invoked, installation has already succeeded, so install/repair protocol is a bootstrap concern rather than a transition-owned prompt fragment.

The newly discovered gap is no longer *when* these private instructions should be delivered. `transition_contract.yaml` already resolves that timing by attaching a `prompt_fragment_id` to each allowed transition. The missing behavior is *how* that event-specific prompt is assembled: prompt assembly does not load or inject the referenced content, and the current fragment schema only allows one singular `skill` value instead of an `instructions` list. In parallel, the `instructions/` files that now exist are not short prompt payloads but full Markdown source protocols with frontmatter, headings, lists, fenced code blocks, placeholders, and punctuation. The problem is therefore a coupled refactor: separate private protocols from universal skills, redesign prompt-fragment metadata around `instructions: [...]`, define a minimization step that reduces long source instructions to prompt-ready text without unnecessary special characters, and make prompt assembly inject those normalized instruction fragments into the prompt generated for the corresponding event.

## Confirmed Findings

1. The current FSM transition contract already determines *when* transition-owned instruction content should be delivered. Each allowed transition points to a `prompt_fragment_id`, and `prompt_fragments` stores the event-specific metadata for that handoff. [code/cli/assets/fsm/transition_contract.yaml](../../../code/cli/assets/fsm/transition_contract.yaml)
2. The current prompt-fragment schema still models that metadata as one singular `skill` plus one `template`. [code/cli/assets/fsm/transition_contract.yaml](../../../code/cli/assets/fsm/transition_contract.yaml) uses values such as `doc-read`, `doc-write`, `issue-start`, and `issue-end`, and [code/cli/lib/fsm_contract.dart](../../../code/cli/lib/fsm_contract.dart) defines `PromptFragmentContract` with `role`, `template`, and `skill` fields only.
3. No current transition prompt fragment references `inquiry-install`. The runtime event-owned set in [code/cli/assets/fsm/transition_contract.yaml](../../../code/cli/assets/fsm/transition_contract.yaml) is limited to `doc-read`, `doc-write`, `issue-start`, and `issue-end`.
4. Prompt assembly does not consume prompt-fragment metadata today. [code/cli/lib/modules/ape/ape_definition.dart](../../../code/cli/lib/modules/ape/ape_definition.dart) builds prompts from base prompt, sub-state prompt, operational contract, and inquiry context, but does not load any fragment asset referenced by the FSM contract.
5. The APE prompt command follows that same path with no fragment injection step. [code/cli/lib/modules/ape/commands/prompt.dart](../../../code/cli/lib/modules/ape/commands/prompt.dart) calls `assemblePrompt()` without passing a fragment identifier or loading any private protocol content.
6. The asset tree is already split at the top-level directory boundary. [code/cli/assets/instructions](../../../code/cli/assets/instructions) contains `doc-read.md`, `doc-write.md`, `issue-create.md`, `issue-end.md`, and `issue-start.md`, while [code/cli/assets/skills](../../../code/cli/assets/skills) now contains only the universal thinking tools. The remaining migration drift is in FSM contract vocabulary, prompt assembly, and stale code or tests that still assume transition-owned protocols live under `skills/`.
7. The existing instruction files are long Markdown documents rather than prompt-ready scalar snippets. For example, [code/cli/assets/instructions/issue-start.md](../../../code/cli/assets/instructions/issue-start.md) includes YAML frontmatter, fenced code blocks, quoted examples, placeholders such as `<NNN>`, and checklist-style markdown. Similar formatting appears in [code/cli/assets/instructions/doc-read.md](../../../code/cli/assets/instructions/doc-read.md) and [code/cli/assets/instructions/doc-write.md](../../../code/cli/assets/instructions/doc-write.md).
8. The CLI already serializes multiline text safely in JSON output, but that state output is diagnostic rather than the intended delivery path for transition-owned instructions. [code/cli/lib/modules/fsm/commands/state.dart](../../../code/cli/lib/modules/fsm/commands/state.dart) includes an `instructions` field in JSON, where newlines are escaped correctly, while `toText()` deliberately omits the instructions body and shows only state, issue, APEs, and valid transitions.
9. The current operational contract loader is designed for short per-phase mission text, not for full protocol documents. [code/cli/assets/fsm/states/analyze.yaml](../../../code/cli/assets/fsm/states/analyze.yaml) carries a compact three-line mission, and [code/cli/lib/modules/ape/operational_contract.dart](../../../code/cli/lib/modules/ape/operational_contract.dart) renders that short contract into prompts and `iq fsm state` JSON.
10. Repository documentation already distinguishes Inquiry-private protocols from reusable tools, even if the codebase does not enforce that distinction yet. [docs/architecture.md](../../../docs/architecture.md) separates private skills from reusable skills, and [docs/research/legion.md](../../../docs/research/legion.md) documents the universal role of `legion`.

## Decisions Taken

1. Treat the user's correction as authoritative scope for issue #185. The architecture target is fixed: private protocols become instructions and universal tools remain skills.
2. Treat the absence of fragment injection as a discovered implementation gap inside that chosen architecture, not as a reason to reopen the issue scope.
3. Treat the singular `skill` field in prompt-fragment metadata as obsolete for Inquiry-private transition protocols. PLAN must redesign the schema around `instructions: [...]` for those private references and allow multiple instruction assets per event when needed.
4. Treat the partially populated `instructions/` directory as active migration state, not as an optional experiment or empty placeholder.
5. Treat the `skills/` directory boundary as already corrected to universal-only assets. The remaining work is runtime wiring, not asset-taxonomy cleanup.
6. Treat delivery timing as already resolved by `transition_contract.yaml`. Private transition instructions are delivered as part of the prompt generated for the corresponding event.
7. Treat state-inspection surfaces such as `iq fsm state` as diagnostic only, not as the primary carrier for full private instruction content.
8. Treat the long Markdown instruction files as canonical source material, not as the final prompt payload. PLAN should begin by summarizing each source instruction into a minimal prompt-ready expression without unnecessary special characters before injection.
9. Treat `inquiry-install` as out of scope for this runtime prompt-fragment slice. It is a bootstrap or repair concern, not a transition-owned event prompt.

## Constraints And Risks Identified

- `PromptFragmentContract` and its YAML parser must change in lockstep with `transition_contract.yaml`, and they must support ordered instruction lists rather than a single scalar field. Partial migration will leave contract parsing inconsistent.
- Prompt assembly currently ignores fragment metadata. Until an injection step exists, migrating files alone will not change runtime behavior.
- The order in which prompt assembly concatenates base prompt, state prompt, injected instruction content, operational contract, and inquiry context must be made explicit, otherwise prompt behavior can change accidentally.
- The runtime fragment references and the corresponding instruction assets must remain synchronized. Missing instruction files, stale fragment names, or out-of-order list handling would silently break transition-owned prompt behavior.
- The private-versus-universal boundary must be enforced in code and tests. If not, future changes can drift back to putting Inquiry-private protocols into the universal `skills/` taxonomy.
- Existing tests around prompt assembly and FSM contracts currently reflect the old inert-metadata model. PLAN must account for test updates as part of the design boundary.
- A derivation contract is needed between canonical Markdown instruction sources and their minimized prompt-ready summaries. Without that rule, the prompt payload can drift from the source protocol.
- The current instruction files are Markdown-heavy. If they are injected raw, frontmatter, fences, quotes, apostrophes, placeholders, and checklist noise will dilute the event prompt and make the prompt contract brittle.
- Multiple instruction references per event require a deterministic ordering and separator contract, otherwise prompt composition can become unstable across transitions.
- Completeness should be validated against the transition-owned prompt-fragment set rather than against every historical private skill, otherwise bootstrap-only or non-transition assets will blur the migration boundary.

## Scope

In scope:

- Defining transition-owned private Inquiry protocols as `instructions` under `code/cli/assets/instructions/<name>.md`.
- Keeping `legion`, `research`, and `kritik` as universal `skills` under `code/cli/assets/skills/<name>/SKILL.md`.
- Updating FSM prompt-fragment metadata so private transition references use an `instructions:` list rather than a singular `skill:` field.
- Designing prompt assembly so it loads and injects the referenced private instruction summaries into the prompt generated for the corresponding event.
- Defining a first-step minimization pass that reduces canonical instruction documents to prompt-ready text without unnecessary special characters.
- Updating the parsed contract surface to represent the new instruction vocabulary and multiplicity.

Out of scope:

- Redesigning the overall FSM lifecycle or APE phase model.
- Changing the role or deployment model of `legion`, `research`, or `kritik`.
- Turning `iq fsm state` or another inspection command into a document-delivery surface for full private instruction bodies.
- Including `inquiry-install` in the transition-owned prompt-fragment migration.
- Solving remote registries, independent versioning, or arbitrary user-provided prompt assets.
- Exhaustive normalization of Markdown punctuation beyond what is needed to produce stable prompt-ready instruction summaries.

## References

- [code/cli/assets/fsm/transition_contract.yaml](../../../code/cli/assets/fsm/transition_contract.yaml)
- [code/cli/lib/fsm_contract.dart](../../../code/cli/lib/fsm_contract.dart)
- [code/cli/lib/modules/ape/ape_definition.dart](../../../code/cli/lib/modules/ape/ape_definition.dart)
- [code/cli/lib/modules/ape/commands/prompt.dart](../../../code/cli/lib/modules/ape/commands/prompt.dart)
- [code/cli/lib/modules/fsm/commands/state.dart](../../../code/cli/lib/modules/fsm/commands/state.dart)
- [code/cli/lib/modules/ape/operational_contract.dart](../../../code/cli/lib/modules/ape/operational_contract.dart)
- [code/cli/assets/instructions](../../../code/cli/assets/instructions)
- [code/cli/assets/skills](../../../code/cli/assets/skills)
- [code/cli/assets/instructions/doc-read.md](../../../code/cli/assets/instructions/doc-read.md)
- [code/cli/assets/instructions/doc-write.md](../../../code/cli/assets/instructions/doc-write.md)
- [code/cli/assets/instructions/issue-start.md](../../../code/cli/assets/instructions/issue-start.md)
- [code/cli/assets/fsm/states/analyze.yaml](../../../code/cli/assets/fsm/states/analyze.yaml)
- [docs/architecture.md](../../../docs/architecture.md)
- [docs/research/legion.md](../../../docs/research/legion.md)
