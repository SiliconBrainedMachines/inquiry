---
id: diagnosis
title: "Diagnosis"
date: 2026-05-29
status: final
tags: [diagnosis, analyze, dispatch, scheduler]
author: socrates
---

# Diagnosis

## Problem defined

Issue #181 asks whether scheduler dispatch is still coupled to `agentName = ape.name` during the Inner Loop. The original operational risk was that the scheduler could assemble the correct effective APE prompt but still fail at dispatch time because it tried to invoke a runtime agent by the APE's identity rather than using the prompt itself as the dispatch contract.

More concretely: if the runtime did not expose a custom invocable agent named after the APE, dispatch could fail even though the scheduler had already assembled the full prompt required for the sub-agent to act.

## Decisions taken

1. Treat the effective APE prompt as the complete runtime contract.

Justification:
The active firmware instructs the scheduler to run `iq ape prompt --name <ape.name>` and treat that result as the exact effective sub-agent prompt surface. This establishes that the prompt assembly, not a runtime name lookup, is the authoritative interface for sub-agent behavior.

2. Dispatch through a generic/current sub-agent path rather than deriving `agentName` from `ape.name`.

Justification:
The active firmware explicitly says: use the `agent` tool to invoke a generic/current sub-agent path with the prompt as full context, and do not set `agentName` from `ape.name`. That is a direct architectural decoupling between APE identity and runtime dispatch target.

3. Lock the decoupling into regression tests.

Justification:
The firmware test suite asserts both the absence of APE-name-based dispatch syntax and the presence of the explicit prohibition against deriving `agentName` from `ape.name`. This converts the intended behavior into an enforced contract.

## Constraints and risks identified

### Constraint: scheduler behavior is instruction-driven

The scheduler's dispatch semantics live in firmware instructions rather than in a typed runtime interface. That means regressions can be introduced by prompt edits even if CLI code remains unchanged.

### Constraint: APE identity still matters for prompt assembly

`ape.name` remains necessary for selecting the correct prompt via `iq ape prompt --name <ape.name>`. The decoupling here is narrower: dispatch no longer depends on that same value being a valid runtime `agentName`.

### Risk: reintroducing named dispatch would recreate an avoidable runtime dependency

The repository QA note records the concrete failure mode: named dispatch to `socrates` or `descartes` fails when no matching custom agent exists, while generic dispatch succeeds with the same assembled APE prompt. If the scheduler reintroduces `agentName = ape.name`, it would again depend on runtime agent registry configuration instead of the assembled prompt.

### Risk: mirrored firmware assets must stay aligned

The active contract appears in both source firmware and generated build assets. A change applied to one without the other could create divergent behavior between source-of-truth review and packaged runtime behavior.

## Scope

### In scope

- Confirming the original dispatch coupling problem in the legacy firmware.
- Confirming the current scheduler contract around prompt assembly and generic dispatch.
- Confirming that current evidence supports the claim that dispatch no longer depends on `agentName = ape.name`.
- Recording the implications of that decoupling for runtime robustness.

### Out of scope

- Proposing implementation changes.
- Modifying firmware, CLI code, or tests.
- Re-triaging the issue or selecting a different task.
- Proving every historical commit transition that led from legacy behavior to the current contract.

## Conclusion

The original problem was real: legacy scheduler instructions bound dispatch to named sub-agents such as SOCRATES, which coupled APE identity to runtime agent lookup. The current firmware has removed that dependency. It now uses `ape.name` only to assemble the effective prompt and explicitly forbids deriving runtime `agentName` from that value. The regression tests encode the same rule, and repository QA notes record the relevant behavioral distinction between failing named dispatch and succeeding generic dispatch.

On the available evidence, ANALYZE can conclude that scheduler dispatch no longer depends on `agentName = ape.name`.

## References

- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/confirmed.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/confirmed.md)
- [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md)
- [code/cli/assets/agents/inquiry.agent.md](code/cli/assets/agents/inquiry.agent.md#L75)
- [code/cli/assets/archive/inquiry.agent.md.legacy](code/cli/assets/archive/inquiry.agent.md.legacy#L70)
- [code/cli/build/assets/agents/inquiry.agent.md](code/cli/build/assets/agents/inquiry.agent.md#L75)
- [code/cli/test/firmware_agent_test.dart](code/cli/test/firmware_agent_test.dart#L35)
- /memories/repo/release-qa.md