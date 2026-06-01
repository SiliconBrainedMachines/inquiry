---
id: harness-observability
title: "Harness Observability for Inquiry"
date: 2026-05-31
status: active
tags: [harness, observability, traces, metrics, inquiry]
author: descartes
---

# Harness Observability

## Overview

Inquiry already produces some durable evidence about cycle outcomes, but that is not yet the same as observability of the harness itself.

Harness observability answers a different question:

> What did the control system do, where did it block, what did it retry, and which evidence made the cycle advance or stop?

This spec separates two evidence lanes:

1. **result metrics** — what the cycle produced or how it ended
2. **execution traces** — how the harness behaved while the cycle was running

That distinction matters because a green outcome can still hide a noisy, expensive, or brittle harness path.

## Principles

- **Operational evidence before retrospective narration.** Durable traces outrank smooth after-the-fact explanations.
- **Result and execution are different surfaces.** `metrics.yaml`-style summaries should not be overloaded to explain the full control path.
- **Start with high-signal fields.** Early observability should capture a small number of operationally useful facts before attempting full telemetry.
- **Phase semantics before dashboards.** A trace is only useful if it says which phase, gate, or handoff it belongs to.
- **Host-boundary clarity matters.** The spec should distinguish what Inquiry can observe directly from what only the host can expose.

## Evidence surfaces

The minimum observability layer should distinguish these surfaces:

| Surface | Role |
|---|---|
| `.inquiry/metrics.yaml` | Cycle-level outcome summary and durable metrics snapshot |
| `cleanrooms/<branch>/run_trace.yaml` | Structured execution trace for the active cycle |
| `cleanrooms/<branch>/pre_pr_inspection.md` | Closure evidence for END and pre-PR blocking state |
| `cleanrooms/<branch>/retrospective.md` | Human-readable implementation retrospective, useful but not trace-authoritative |
| `.inquiry/mutations.md` | Human observations that can later inform EVOLUTION but do not replace direct operational trace data |

`run_trace.yaml` is the preferred local execution-trace sink for the 0.6.x observability layer, even if early implementations only populate part of the model.

## Runtime fields

The runtime should expose the minimum observability contract inside `inquiry-context` with these fields:

| Field | Meaning |
|---|---|
| `observability_policy` | Named observability mode for the current phase |
| `result_metrics_surface` | Where durable result metrics currently live |
| `execution_trace_surface` | Where structured trace events for the active cycle should be written |
| `trace_targets` | The minimum event classes expected for the current phase |
| `failure_taxonomy_surface` | Where failure classes or labels should be resolved from |
| `observability_authority_rule` | Human-readable rule describing which evidence lane outranks narrative summaries |

## Minimum trace targets

The minimum event model for `run_trace.yaml` should capture these event classes:

| Event class | Minimum data |
|---|---|
| `transition` | phase/event/from/to/outcome |
| `sensor_run` | sensor category, gate, verdict, authority |
| `block` | blocking boundary, reason, authoritative surface |
| `retry` | phase, triggering failure, retry count |
| `phase_timing` | phase name, start, end, duration |
| `tool_activity` | tool class or command family when the host/runtime can expose it |

Early implementations do not need full fidelity for every event class. The important requirement is that traces make blocking, retries, and phase cost visible in a stable structure.

When Inquiry can observe prompt assembly locally before handing work to a host, it should also emit optional `model_activity` events with fields such as `ape_name`, `prompt_characters`, `estimated_input_tokens`, `token_estimate_basis`, and `assembly_duration_seconds`. These events attribute the model-bound input surface and local assembly cost Inquiry can observe directly without pretending to know remote model runtime, completion-token usage, or cache behavior the host does not expose.

## Minimum phase expectations

### EXECUTE

EXECUTE should leave enough trace evidence to answer:

- what validations ran
- what retries happened
- what phase-local blocks or warnings appeared
- how much time the phase consumed

### END

END should leave enough trace evidence to answer:

- which pre-PR sensors ran
- what blocked or allowed closure
- whether release closure was explicit before PR creation
- what authority remained local versus delegated to CI

### EVOLUTION

EVOLUTION should consume observability evidence from:

- result metrics
- execution traces
- retrospectives
- mutations

It should not rely on narrative artifacts alone when stronger operational evidence exists.

## Relationship to other specs

- `task-environment-contract.md` gives the task identity and bounded surface that traces should refer to.
- `context-policy.md` determines what evidence may be brought into working context versus retrieved later.
- `sensor-taxonomy.md` defines the gate and sensor vocabulary that trace events should use.
- `eval-model.md` defines how recurring trace patterns become reusable eval cases.

## Non-goals

This spec does not yet require:

- a full telemetry platform
- perfect token or cache attribution from every host
- capture of every low-level tool action
- replacement of CI or existing repo validation surfaces
- exhaustive cost accounting before the high-signal trace model exists

The goal is a small but trustworthy observability layer, not a maximal dashboard.