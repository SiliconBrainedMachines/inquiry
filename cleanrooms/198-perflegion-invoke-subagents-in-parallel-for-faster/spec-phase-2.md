---
id: spec-phase-2
issue: 198
title: "Phase 2 Specification: legion parallel-first routing"
status: active
phase: specify
owner: basho
date: 2026-05-18
---

# Phase 2 Specification

## Purpose
Make legion's default routing rule explicit before any product-code edit: parallel-first when the runtime supports isolated parallel subagents, degraded sequential fallback otherwise.

## Traceability
- D1: Environmental parallel capability is already proven and remains a premise, not an open question.
- D2: The remaining problem is the missing explicit default-routing rule.
- D3: Expert isolation and degraded sequential fallback remain mandatory.
- D4: Sequential-only behavior preserves correctness but pays avoidable wall-clock latency.

## Default Behavior
When capability detection confirms isolated parallel subagent support, legion launches all selected experts concurrently in separate isolated contexts and waits for all expert outputs before synthesis begins.

Expected runtime property: wall-clock time scales approximately with the longest expert run plus synthesis overhead, not with the sum of expert durations.

## Degraded Fallback Trigger
Legion degrades to sequential mode when any of the following is true:

1. The runtime does not support isolated subagent invocation.
2. Capability detection is ambiguous or returns unknown.
3. Parallel launch fails and the runtime falls back safely rather than silently losing expert coverage.

## User-Visible Degraded Behavior
When degraded mode is active, legion must emit explicit messaging instead of silently changing execution shape.

Required language:

> Warning: legion running in degraded sequential mode because parallel subagents are unavailable. Execution will take longer.

The degraded path still produces a complete synthesis after all experts finish; only latency and dispatch shape change.

## Shared Invariants
The following invariants hold in both dispatch modes:

1. Expert isolation: no expert sees another expert's output during its own reasoning.
2. Synthesis completeness: synthesis waits for all expert outputs and does not synthesize partial sets.
3. Expert independence: expert reasoning remains valid regardless of launch order or overlap.
4. Explicit fallback: degraded behavior is surfaced to the user rather than hidden.

## Implementation-Oriented Pseudocode

```text
function invokeLegion(selectedExperts, problem):
    capability = detectParallelCapability()

    if capability == PARALLEL:
        notify("Starting parallel consultation")
        outputs = {}
        for expert in selectedExperts:
            outputs[expert.name] = invokeSubagentAsync(
                persona = expert.persona,
                context = isolatedContext(),
                problem = problem,
                mode = "parallel"
            )
        waitAll(outputs)
    else:
        notify("Warning: legion running in degraded sequential mode because parallel subagents are unavailable. Execution will take longer.")
        outputs = {}
        for expert in selectedExperts:
            outputs[expert.name] = invokeSubagentSync(
                persona = expert.persona,
                context = isolatedContext(),
                problem = problem,
                mode = "degraded-sequential"
            )

    return synthesizeAll(outputs, problem)
```

## Capability Detection Contract
Capability detection must fail safe to degraded mode.

```text
function detectParallelCapability():
    if runtime explicitly advertises isolated parallel subagents:
        return PARALLEL

    if runtime explicitly disables or lacks parallel subagents:
        return DEGRADED

    log("Parallel capability ambiguous; using degraded mode")
    return DEGRADED
```

## Decision For Phase 3
Phase 3 remains required. Phase 1 classified the current routing at [code/cli/assets/skills/legion/SKILL.md](code/cli/assets/skills/legion/SKILL.md) Step 3 as `implicit/unclear`, so this specification is not yet implemented by the product path.