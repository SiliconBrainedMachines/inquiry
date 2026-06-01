---
id: task-environment-contract
title: "Task Environment Contract — bounded execution for Inquiry"
date: 2026-05-31
status: active
tags: [harness, context, contract, inquiry, execution]
author: descartes
---

# Task Environment Contract

## Overview

Inquiry's `inquiry-context` block is no longer just a bag of phase-local paths. It is the minimum task contract the harness exposes to the active operator so execution stays bounded, inspectable, and less dependent on ad hoc inference.

The contract answers eight questions:

1. What repository am I operating in?
2. What active task am I serving?
3. What artifacts are authoritative inputs?
4. What outputs am I expected to leave?
5. What surfaces may I edit?
6. What surfaces should be treated as read-only authority?
7. What validation commands exist right now?
8. What counts as done for this phase-owned task?

## Principles

- **Contract before improvisation.** The agent should see a bounded task surface before it starts reasoning.
- **Paths are not enough.** Operational paths remain necessary, but they are only one part of bounded execution.
- **Evidence before inference.** Input artifacts and read-only authority should make it harder to invent context the harness could have provided explicitly.
- **Validation may be partial.** `validation_commands` can be empty until the sensor stack matures, but the field must still exist so the absence of automation is explicit rather than hidden.

## Minimum fields

The minimum task-environment contract for active-cycle prompts is:

| Field | Meaning |
|---|---|
| `project_root` | Absolute repository/worktree root |
| `task_id` | Active issue/cycle identifier; fallback is branch name when issue is unavailable |
| `input_artifacts` | Authoritative inputs for the current phase |
| `expected_outputs` | Files or surfaces the phase is expected to produce/update |
| `editable_surfaces` | Files/directories the phase is allowed to modify |
| `read_only_surfaces` | Inputs that should be treated as authority, not casually rewritten |
| `validation_commands` | Commands currently available to validate the task; may be `[]` |
| `done_criteria` | Explicit bounded completion criteria for the current phase |

These fields live alongside the older phase-specific runtime paths such as `output_dir`, `plan_file`, `analysis_input`, `index_file`, and similar keys.

## Serialization rules

- `project_root` is absolute.
- Cycle-local artifacts remain rooted relative to the repository, for example `cleanrooms/<branch>/...`.
- List-valued fields should be serialized as YAML flow sequences when injected into `inquiry-context`.
- The contract should stay explicit in the assembled prompt after APE identity and after the phase-owned operational contract.

## Current phase mapping

### SOCRATES

- `input_artifacts`: issue material plus `analyze/index.md`
- `expected_outputs`: `confirmations.md`, `diagnosis.md`
- `editable_surfaces`: `cleanrooms/<branch>/analyze/`
- `read_only_surfaces`: issue statement / prior authority for the cycle
- `done_criteria`: diagnosis written and grounded in the bounded analysis corpus

### DESCARTES

- `input_artifacts`: `analyze/diagnosis.md`
- `expected_outputs`: `plan.md`
- `editable_surfaces`: `plan.md`
- `read_only_surfaces`: approved diagnosis and other bounded inputs
- `done_criteria`: ordered phased plan with verification criteria

### BASHO

- `input_artifacts`: `plan.md`
- `expected_outputs`: bounded project changes plus cycle-local artifacts
- `editable_surfaces`: project working tree under `project_root`, subject to plan constraints
- `read_only_surfaces`: `plan.md` as the governing execution contract
- `pre_pr_inspection_report`: `cleanrooms/<branch>/pre_pr_inspection.md` on the closure path into END, auto-seeded on `finish_execute`, with an auto-generated `Consistency` pass and automatic `plan.md` checkbox completeness review both refreshed at `pr_ready`, plus `Completeness` and `Traceability` passes, overall verdict, and `file:line` citations for `FAIL` findings
- `done_criteria`: implementation stays bounded by plan and completes required validation before END

### DARWIN

- `input_artifacts`: diagnosis, plan, retrospective, mutations, metrics
- `expected_outputs`: evolution findings grounded in cycle evidence
- `editable_surfaces`: evolution-facing cycle artifacts and proposal surfaces
- `read_only_surfaces`: observed cycle artifacts and metrics authority
- `done_criteria`: proposed mutations remain traceable to observed evidence

## Non-goals

This contract does not replace the separate context-policy layer, the separate sensor layer, or the future observability layer. It is the foundation those later layers depend on.

In particular:

- it does not replace phase-owned operational contracts
- it does not, by itself, encode the full sensor stack without the paired sensor layer in `sensor-taxonomy.md`
- it does not by itself solve duplicate rereads without the paired context policy in `context-policy.md`
- it does not, on its own, decide retrieval discipline or handoff authority semantics

Those concerns are layered on top of this contract in later 0.6.x work.