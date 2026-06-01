# Spec — Finite APE Machine

Technical specifications and architectural references for the current Inquiry/APE system.

## Canonical Homes

Start here when you need the first authoritative explanation of a core concept.

| Concept | Canonical home | Notes |
|---------|----------------|-------|
| Inquiry | [../research/inquiry/index.md](../research/inquiry/index.md) | Philosophical and epistemic foundation of the Inquiry cycle |
| APE | [../architecture.md](../architecture.md) | Current system-level explanation of APE as the orchestrating methodology |
| Finite APE Machine | [finite-ape-machine.md](finite-ape-machine.md) | Primary technical overview of the engineered finite-state system |
| Thinking Tools | [../thinking-tools.md](../thinking-tools.md) | Current canonical explainer; [../lore.md](../lore.md) remains the historical and nomenclature companion |

## Current Supporting Specs

These documents support the current model and should be read as technical elaborations rather than co-equal concept homes.

| Document | Description |
|----------|-------------|
| [task-environment-contract.md](task-environment-contract.md) | Minimum bounded task contract exposed through `inquiry-context` for contract-first execution |
| [context-policy.md](context-policy.md) | Progressive disclosure, authoritative handoffs, and retrieval discipline across phases |
| [sensor-taxonomy.md](sensor-taxonomy.md) | Minimum sensor vocabulary and gate semantics for EXECUTE, END, and later closure enforcement |
| [harness-observability.md](harness-observability.md) | Separation between result metrics and execution traces, with minimum trace targets for the harness |
| [eval-model.md](eval-model.md) | Minimal eval entities, failure classes, and grader types for evidence-backed harness evolution |
| [agent-lifecycle.md](agent-lifecycle.md) | Agent lifecycle and state responsibilities in the current model |
| [cooperative-multitasking-model.md](cooperative-multitasking-model.md) | Two-level FSM and scheduler/task coordination model |
| [signal-based-coordination.md](signal-based-coordination.md) | Signal/event model for coordination and transitions |
| [cli-as-api.md](cli-as-api.md) | Boundary between skills, agent behavior, and CLI enforcement |
| [target-specific-agents.md](target-specific-agents.md) | Per-target deployment strategy and current single-target decision |
| [state-encapsulation.md](state-encapsulation.md) | State encapsulation principle, system analogies, TRIAGE sub-agent design |

## 0.6.x Harness Read Order

If you are trying to understand the current harness-consolidation program rather than the full historical spec surface, read these in order:

1. [../architecture.md](../architecture.md)
2. [task-environment-contract.md](task-environment-contract.md)
3. [context-policy.md](context-policy.md)
4. [sensor-taxonomy.md](sensor-taxonomy.md)
5. [harness-observability.md](harness-observability.md)
6. [eval-model.md](eval-model.md)
7. [../0.6.x-harness-backlog.md](../0.6.x-harness-backlog.md)

## Mixed, Historical, or Planned Specs

These documents remain relevant, but they should not be treated as the cleanest source of current doctrine without checking their status and scope.

| Document | Status | Description |
|----------|--------|-------------|
| [orchestrator-spec.md](orchestrator-spec.md) | Historical | Expanded orchestrator architecture from an earlier multi-agent model |
| [memory-as-code-spec.md](memory-as-code-spec.md) | Mixed | Memory architecture with still-useful concepts and legacy operational assumptions |
| [inquiry-cli-spec.md](inquiry-cli-spec.md) | Mixed/planned | CLI/TUI direction with both current intent and planned surfaces |
