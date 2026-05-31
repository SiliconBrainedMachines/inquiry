---
id: sensor-taxonomy
title: "Sensor Taxonomy and Minimum Phase Gates for Inquiry"
date: 2026-05-31
status: active
tags: [harness, sensors, gates, validation, inquiry]
author: descartes
---

# Sensor Taxonomy

## Overview

Inquiry already has real checks, but they are easier to reason about when treated as a sensor system instead of a loose collection of rituals.

A **sensor** is a source of operational evidence.

A **gate** is a control decision that uses one or more sensors to allow, block, or condition a transition or closure action.

This taxonomy exists so the harness can say, explicitly:

- which checks are cheap and should run early
- which checks are blocking versus informative
- which sensors belong to EXECUTE, END, CI, drift detection, or runtime health
- how to reason about gaps in validation coverage

## Categories

| Category | Purpose | Typical cost | Authority | Blocking semantics |
|---|---|---|---|---|
| `local_fast` | Cheap local evidence during active work | low | medium | Blocking when attached to current phase completion or commit readiness |
| `pre_transition` | Evidence required before phase advance | medium | high | Blocking for phase transition |
| `pre_pr` | Closure evidence before push or PR creation | medium | high | Blocking for END gate and PR creation |
| `ci_required` | Remote merge-authoritative checks | medium to high | very high | Non-blocking for local prompt assembly, but blocking for merge/release closure |
| `continuous_drift` | Detect accumulated contract or asset drift | low to medium | medium | Usually non-blocking per action, but escalates when drift becomes repeated or structural |
| `runtime` | Detect harness, state, config, or tool incoherence | low to medium | high | Blocking when the harness itself cannot be trusted |
| `inferential_optional` | Human or agent review findings not yet backed by stronger evidence | variable | low | Informative only unless upgraded by stronger sensors |

## Runtime fields

The runtime exposes the active phase's minimum sensor model inside `inquiry-context` with these fields:

| Field | Meaning |
|---|---|
| `sensor_policy` | Named sensor policy mode for the current phase |
| `minimum_sensor_stack` | The minimum sensor categories expected for the phase |
| `blocking_sensor_stack` | Sensor categories that can currently block progress |
| `advisory_sensor_stack` | Sensor categories that inform review without blocking on their own |
| `sensor_gate` | The named gate this sensor stack currently serves |
| `sensor_authority_rule` | Human-readable rule describing which sensors remain authoritative at this boundary |

## Rules

- **Mechanical evidence outranks narration.** Hard failures from stronger sensors overrule weak heuristic confidence.
- **Blocking must be named.** A gate should say which sensor categories can stop progress.
- **Cheap checks should run early.** `local_fast` exists to fail fast before expensive closure work.
- **Remote authority remains real authority.** `ci_required` may be downstream from END, but it still carries merge authority.
- **Drift is not noise.** Repeated source/build/doc/runtime divergence is a harness defect, not a minor annoyance.

## Minimum phase stack

### EXECUTE

EXECUTE should not treat validation as a single blob. Its minimum stack is:

- `local_fast` — cheap phase-local checks during active implementation
- `pre_transition` — blocking verification before phase advance
- `pre_pr` — closure preparation before END handoff
- `runtime` — harness health checks when repo, state, or tooling looks suspect

EXECUTE gate semantics:

- `local_fast` and `pre_transition` failures block phase completion or phase advance
- incomplete `pre_pr` evidence blocks handoff into END
- `inferential_optional` findings can inform caution, but do not override stronger blocking sensors alone

Runtime mapping:

- `sensor_policy`: `minimum-phase-stack`
- `minimum_sensor_stack`: `local_fast`, `pre_transition`, `pre_pr`, `runtime`
- `blocking_sensor_stack`: `local_fast`, `pre_transition`, `runtime`
- `advisory_sensor_stack`: `inferential_optional`
- `sensor_gate`: `handoff-to-end`
- `sensor_authority_rule`: `pre_pr` evidence must be complete before END handoff even when phase-local checks are green

### END

END is the explicit pre-PR gate. Its minimum stack is:

- `pre_pr` — blocking inspection before push or PR creation
- `ci_required` — merge-authoritative checks that remain binding after PR creation
- `runtime` — blocking checks when branch, issue, FSM state, or target state looks inconsistent
- `inferential_optional` — non-blocking review findings unless strengthened by harder evidence

END gate semantics:

- failing `pre_pr` or `runtime` sensors stop PR creation
- passing END locally does not cancel `ci_required` authority
- review observations without stronger evidence remain informative, not blocking

Runtime mapping:

- `sensor_policy`: `minimum-phase-stack`
- `minimum_sensor_stack`: `pre_pr`, `ci_required`, `runtime`, `inferential_optional`
- `blocking_sensor_stack`: `pre_pr`, `runtime`
- `advisory_sensor_stack`: `inferential_optional`
- `sensor_gate`: `end-pre-pr-inspection`
- `sensor_authority_rule`: `ci_required` remains merge-authoritative after PR creation even when the local END gate is green

Current enforcement surface:

- local END gate authority is materialized in `cleanrooms/<branch>/pre_pr_inspection.md`
- entering END seeds `cleanrooms/<branch>/pre_pr_inspection.md` from the inspection template when the report does not yet exist
- the report must include `Consistency`, `Completeness`, and `Traceability` passes with `PASS`, `FAIL`, or `WARN` checks in each pass
- every `FAIL` finding must cite repo-relative `file:line`
- `verdict: APPROVED` is only valid when no pass contains `FAIL`
- missing report, missing pass structure, or any non-`APPROVED`/contradictory report blocks PR creation

## Relationship to current contracts

- `execute.yaml` should name the EXECUTE minimum sensor stack and its blocking behavior
- `end.yaml` should name the END pre-PR gate as part of the phase contract
- `inquiry-end.md` should describe END as a gate, not as a purely mechanical push step
- `validation_commands` may remain partial or empty until repo-specific command discovery becomes more systematic, but the sensor model should still be explicit

## Non-goals

This taxonomy does not yet implement full automated enforcement across every category.

In particular, it does not yet:

- auto-discover every repo-specific validation command
- replace CI configuration
- solve harness observability or cost accounting by itself
- eliminate the need for later work in #163, #127, #207, or #29

It provides the vocabulary and minimum contract that those later mechanisms should plug into.