---
id: eval-model
title: "Eval Model for Inquiry Harness Evolution"
date: 2026-05-31
status: active
tags: [harness, evals, failure-taxonomy, inquiry, evolution]
author: descartes
---

# Eval Model

## Overview

Inquiry already has tests, gates, and durable cycle artifacts. The eval layer adds a more specific discipline:

> recurring harness failures should become comparable cases with explicit graders, instead of remaining isolated anecdotes, one-off tickets, or purely narrative retrospectives.

This spec defines the minimum model for turning repeated control-path defects into reusable evaluation assets for the Inquiry harness itself.

## Principles

- **Recurring failures first.** Start from real repeated defects before inventing abstract benchmark suites.
- **Behavior outranks rhetoric.** The eval subject is what the harness did, not how persuasively an artifact describes it.
- **Deterministic graders first.** Prefer structural or trace-based graders before subjective judgments.
- **Failure-source attribution must be explicit.** Distinguish model failure, host failure, Inquiry-harness failure, and mixed cases.
- **Keep evals close to repo evidence.** Cases and graders should stay anchored in artifacts the repo already knows how to produce.

## Core entities

| Entity | Meaning |
|---|---|
| `failure_class` | Named recurring defect family the harness wants to detect or compare |
| `eval_case` | A bounded case with inputs, expected behavior, and evidence surfaces |
| `grader` | The rule that scores or judges the eval case |
| `eval_suite` | A grouped set of cases for one harness concern |
| `eval_report` | The recorded outcome of running a case or suite |

## Failure-source model

Every eval case should classify the dominant failure source as one of these:

| Source | Meaning |
|---|---|
| `model` | The base model generated or ignored something incorrectly despite adequate harness structure |
| `host` | The host tool or adapter failed to expose or preserve the required behavior |
| `inquiry_harness` | Inquiry's own contracts, prompts, state rules, or gates were insufficient or inconsistent |
| `mixed` | Multiple layers plausibly contributed and cannot yet be cleanly separated |

## Minimum harness failure classes

The first eval layer should focus on failure classes directly tied to the 0.6.x program:

| Failure class | What it covers |
|---|---|
| `task_contract_failure` | Missing or ambiguous task identity, editable surface, output expectation, or done criteria |
| `evidence_discipline_failure` | ANALYZE asks too early, ignores repo evidence, or fails to separate evidence from hypothesis |
| `handoff_authority_failure` | Later phases rebuild prior work instead of trusting the authoritative handoff artifact |
| `sensor_gate_failure` | Expected gate behavior is missing, contradictory, or non-blocking when it should block |
| `observability_failure` | The harness cannot explain where it blocked, retried, or spent cost with direct evidence |

## Minimum grader types

The initial grader stack should stay small:

| Grader type | Use |
|---|---|
| `structure_grader` | Checks required fields, sections, or contract surfaces exist |
| `trace_grader` | Checks execution traces contain required events or consistent boundaries |
| `artifact_consistency_grader` | Checks authoritative artifacts agree with each other |
| `human_audit_grader` | Used only when stronger deterministic grading is not yet available |

Human review may remain necessary, but it should be named as a fallback, not hidden as if it were deterministic evidence.

## Runtime fields

The runtime should expose the minimum eval layer inside `inquiry-context` with these fields:

| Field | Meaning |
|---|---|
| `eval_policy` | Named eval mode for the current cycle or phase |
| `eval_targets` | The current harness concerns the cycle should generate evaluable evidence for |
| `failure_classification_mode` | How the cycle should classify repeated failures |
| `grader_stack` | The grader types currently expected or available |
| `eval_authority_rule` | Human-readable rule describing what evidence outranks narrative retrospection in eval judgments |

## Minimum evidence for eval cases

An `eval_case` should be considered minimally well-formed when it includes:

1. a named `failure_class`
2. the bounded task or phase surface it concerns
3. the relevant authoritative artifacts
4. the expected behavior or boundary condition
5. a grader definition
6. an outcome record or comparison target

This keeps the eval layer tied to visible system behavior instead of free-floating methodological prose.

## Relationship to other specs

- `task-environment-contract.md` defines the bounded task surface an eval case refers to.
- `context-policy.md` defines whether the relevant evidence should have been trusted upfront or retrieved on demand.
- `sensor-taxonomy.md` defines the gate semantics a sensor or closure eval should judge.
- `harness-observability.md` defines the trace and metrics evidence the eval layer can consume.

## Non-goals

This spec does not yet require:

- a large benchmark platform
- cross-host comparative scoring from day one
- universal coverage of every possible failure taxonomy
- automatic grading for all non-deterministic cases
- replacement of existing unit, integration, or CI checks

The goal is to make harness evolution more evidence-backed, not to build a heavyweight eval infrastructure before the core control system is stable.