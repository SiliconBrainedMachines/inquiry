---
id: diagnosis
title: Diagnosis of legion parallel invocation gap
date: 2026-05-18
status: active
tags: [analysis, legion, parallelism, copilot]
author: socrates
---

# Diagnosis

## Problem Defined

Legion's contract already requires isolated, independent subagents, but its effective default invocation behavior in VS Code is not documented as parallel-first. The user experiences latency because typical legion runs involve five to seven experts and are currently observed as one-by-one launches in the skill path they use.

The investigation established that parallel subagent fan-out is real in this environment, so the problem is no longer whether GitHub Copilot or the host can parallelize at all. The unresolved gap is narrower: whether legion's default path currently routes through that parallel-capable channel, or whether it still defaults to sequential behavior despite the available capability.

## Confirmed Findings

1. Legion already mandates separate isolated subagents. The skill contract in [code/cli/assets/skills/legion/SKILL.md](../../../../code/cli/assets/skills/legion/SKILL.md) requires each expert to run as a separate independent subagent and explicitly forbids sequential role-play in a shared context.
2. Legion is runtime-agnostic and already models sequential execution as degraded fallback. The same skill document allows sequential prompting only when subagent support is unavailable and explicitly labels that path degraded.
3. Historical documentation overstates current sequential limits. [docs/spec/orchestrator-spec.md](../../../../docs/spec/orchestrator-spec.md) describes GitHub Copilot fleet mode and native parallelism, but also marks the document as a historical design record rather than the canonical current model.
4. The bundled Copilot installation exposes parallel subagent concepts. The local extension changelog states that parallel subagents can run in parallel for faster task completion, and cached command metadata exposes a fleet command described as enabling parallel subagent execution.
5. The probe route supports real parallel fan-out in this environment. Debug traces from a two-way probe showed session starts separated by 6 ms with overlapping lifetimes of 6.8 s and 10.7 s. A five-way probe then showed five session starts at timestamps 1779141843233, 1779141843236, 1779141843238, 1779141843241, and 1779141843243, a total spread of 10 ms across five subagents.
6. Therefore the bottleneck is not host incapability in the tested route. The environment can fan out at a scale comparable to legion's typical council size.
7. What remains unproven is legion's default routing behavior. The investigation did not directly trace a live legion invocation through the default skill entry point, so it cannot yet claim that the skill already uses the parallel-capable path automatically.

## Decisions Taken

1. Treat environmental capability as confirmed rather than hypothetical.
2. Treat older claims of strictly sequential runtime behavior as partially outdated relative to the observed probe route.
3. Frame the root analytical question as a default-routing gap, not a raw platform-capability gap.
4. Preserve legion's existing invariants as non-negotiable analysis constraints: isolated expert contexts and a degraded sequential fallback for runtimes that cannot parallelize.

## Constraints And Risks Identified

- Legion cannot trade away context isolation to gain speed; independence of expert reasoning is part of the technique's epistemic value.
- Any future parallel-first behavior must preserve a degraded sequential fallback for runtimes or profiles where parallel fan-out is unavailable or gated.
- The local Copilot evidence is mixed: the installation exposes parallel-subagent concepts, but cached metadata also shows a fleet command gated with when:false. That means capability exposure may vary by profile, feature gate, or invocation path.
- Probe evidence demonstrates host capability but does not automatically prove that legion's present default invocation path is wired to that capability.
- Inaction has a clear consequence: legion keeps paying wall-clock latency proportional to expert count even in environments that can already fan out work.

## Scope

In scope:

- Legion's invocation model.
- The relation between legion's skill contract and runtime-specific dispatch behavior.
- The default routing question: automatic parallel fan-out versus sequential-by-default behavior with fallback.
- Documentation accuracy around legion, Copilot parallelism, and degraded sequential behavior.

Out of scope:

- Changing legion's epistemic role as a skill rather than an APE.
- Redesigning expert synthesis semantics.
- Broader scheduler changes outside the legion invocation path.

## References

- [code/cli/assets/skills/legion/SKILL.md](../../../../code/cli/assets/skills/legion/SKILL.md)
- [docs/spec/orchestrator-spec.md](../../../../docs/spec/orchestrator-spec.md)
- [docs/research/council_of_experts.md](../../../../docs/research/council_of_experts.md)
- [code/vscode/.vscode-test/extensions/.9d1b6bd8-2d09-48c0-8762-e607625a322c/changelog.md](../../../../code/vscode/.vscode-test/extensions/.9d1b6bd8-2d09-48c0-8762-e607625a322c/changelog.md)
- [code/vscode/.vscode-test/extensions/.9d1b6bd8-2d09-48c0-8762-e607625a322c/readme.md](../../../../code/vscode/.vscode-test/extensions/.9d1b6bd8-2d09-48c0-8762-e607625a322c/readme.md)
- Official VS Code chat sessions documentation: https://code.visualstudio.com/docs/copilot/chat/chat-sessions
- Local debug traces under the session log directory for the two-way and five-way runSubagent probes