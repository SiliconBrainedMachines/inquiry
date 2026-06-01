# Spec Index

Technical specifications that still support the live Inquiry runtime.

## Canonical homes

| Concept | Canonical home | Notes |
|---------|----------------|-------|
| Inquiry / APE | [../architecture.md](../architecture.md) | Current system-level explanation of the runtime and operator model |
| Forward direction | [../roadmap.md](../roadmap.md) | Strategic direction for 0.7.x and beyond |
| Finite APE Machine | [finite-ape-machine.md](finite-ape-machine.md) | Technical overview of the finite-state system |

## Live supporting specs

| Document | Description |
|----------|-------------|
| [task-environment-contract.md](task-environment-contract.md) | Minimum bounded task contract exposed through `inquiry-context` |
| [context-policy.md](context-policy.md) | Progressive disclosure, authoritative handoffs, and retrieval discipline |
| [sensor-taxonomy.md](sensor-taxonomy.md) | Sensor vocabulary and gate semantics for EXECUTE and END |
| [harness-observability.md](harness-observability.md) | Separation between result metrics and execution traces |
| [eval-model.md](eval-model.md) | Failure classes and grader stack for evidence-backed evolution |
| [finite-ape-machine.md](finite-ape-machine.md) | Technical FSM and operator model |
| [memory-as-code-spec.md](memory-as-code-spec.md) | Memory-as-Code concepts still relevant to current artifact flow |
| [agent-lifecycle.md](agent-lifecycle.md) | Agent lifecycle and state responsibilities |
| [cooperative-multitasking-model.md](cooperative-multitasking-model.md) | Two-level FSM and scheduler/task coordination model |
| [signal-based-coordination.md](signal-based-coordination.md) | Signal/event model for coordination and transitions |
| [cli-as-api.md](cli-as-api.md) | Boundary between skills, agent behavior, and CLI enforcement |
| [target-specific-agents.md](target-specific-agents.md) | Host-boundary deployment strategy and current Copilot-first decision |
| [state-encapsulation.md](state-encapsulation.md) | State encapsulation principle and related system analogies |

## Recommended read order

1. [../architecture.md](../architecture.md)
2. [finite-ape-machine.md](finite-ape-machine.md)
3. [task-environment-contract.md](task-environment-contract.md)
4. [context-policy.md](context-policy.md)
5. [sensor-taxonomy.md](sensor-taxonomy.md)
6. [harness-observability.md](harness-observability.md)
7. [eval-model.md](eval-model.md)
