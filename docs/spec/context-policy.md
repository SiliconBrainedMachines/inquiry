---
id: context-policy
title: "Context Policy and Authoritative Handoffs for Inquiry"
date: 2026-05-31
status: active
tags: [harness, context, handoff, inquiry, analysis]
author: descartes
---

# Context Policy

## Overview

Inquiry's task contract answers what the active phase may touch. The context-policy layer answers a different question: what should enter working context immediately, what should be retrieved only if needed, and what should stay outside the prompt window unless a concrete gap justifies wider reads.

This policy exists to reduce duplicate rereads, prevent phases from reconstructing prior work from scratch, and make phase handoffs durable instead of implicit.

## Principles

- **Progressive disclosure by default.** Start from the smallest bounded context that can support the phase.
- **Authoritative handoffs beat rediscovery.** When a durable artifact exists, trust it before rebuilding context from broad repo rereads.
- **Retrieval is conditional.** Widen context only to resolve a named ambiguity, missing fact, or code-level question.
- **Duplicate rereads are harness waste.** Re-reading the same broad surfaces without new diagnostic value is a system defect, not neutral behavior.
- **Authority must be explicit.** The prompt should say which artifact carries authority and under what rule it may be bypassed.

## Runtime fields

The runtime expresses this policy inside `inquiry-context` with these fields:

| Field | Meaning |
|---|---|
| `context_policy` | Named policy mode for the current phase |
| `authority_mode` | Whether the phase is building authority or trusting an existing authoritative artifact |
| `upfront_context` | Bounded context that should be trusted first |
| `retrieval_context` | Surfaces that may be consulted on demand when bounded context is insufficient |
| `deferred_context` | Context that should remain outside the prompt window unless explicitly justified |
| `retrieval_trigger_rule` | The concrete condition that justifies leaving bounded context and consulting retrieval surfaces |
| `reread_avoidance_rule` | The rule that explains which broad rereads should be treated as harness waste |
| `authoritative_handoff` | The artifact that either carries or will become cross-phase authority |
| `authority_rule` | Human-readable rule for when the artifact outranks broad rereads |

## Phase mapping

### ANALYZE / SOCRATES

- `context_policy`: `progressive-disclosure`
- `authority_mode`: `build-authoritative-analysis`
- `upfront_context`: task statement and `analyze/index.md`
- `retrieval_context`: `analyze/index.md`, `confirmations.md`, targeted repo evidence
- `deferred_context`: broad repository rereads not justified by the active uncertainty
- `retrieval_trigger_rule`: widen retrieval only when the bounded analysis corpus leaves a named uncertainty unresolved
- `reread_avoidance_rule`: do not restart repository-wide discovery when `issue.md`, `index.md`, and `confirmations.md` already bound the active uncertainty
- `authoritative_handoff`: `analyze/diagnosis.md`
- `authority_rule`: once written, `diagnosis.md` becomes the handoff PLAN should trust first

ANALYZE is allowed to widen context, but it should do so intentionally. Its job is to compress the relevant evidence into a durable diagnosis so later phases do not have to rediscover the same context.

### PLAN / DESCARTES

- `context_policy`: `authoritative-handoff`
- `authority_mode`: `trust-diagnosis-first`
- `upfront_context`: `analyze/diagnosis.md`
- `retrieval_context`: `analyze/index.md`, targeted repo evidence
- `deferred_context`: reconstructing ANALYZE from broad rereads when `diagnosis.md` is already authoritative
- `retrieval_trigger_rule`: retrieve adjacent repo evidence only when `diagnosis.md` leaves a concrete gap that would change plan structure, scope, or verification
- `reread_avoidance_rule`: do not reconstruct ANALYZE from broad rereads when `diagnosis.md` already answers the planning question
- `authoritative_handoff`: `analyze/diagnosis.md`
- `authority_rule`: trust `diagnosis.md` as the planning baseline unless a concrete gap requires targeted retrieval

PLAN should not re-run ANALYZE by habit. It may retrieve adjacent evidence to sharpen the plan, but the burden of proof is on the reread, not on the handoff artifact.

### EXECUTE / ADA

- `context_policy`: `authoritative-handoff`
- `authority_mode`: `trust-plan-first`
- `upfront_context`: `plan.md`
- `retrieval_context`: targeted repository evidence and cycle-local execution artifacts
- `deferred_context`: re-reading broad analysis artifacts when `plan.md` already defines the bounded execution contract
- `retrieval_trigger_rule`: retrieve targeted code or cycle-local evidence only when `plan.md` leaves a concrete implementation or verification ambiguity
- `reread_avoidance_rule`: do not re-read broad analysis artifacts when `plan.md` already defines the bounded execution contract
- `authoritative_handoff`: `plan.md`
- `authority_rule`: trust `plan.md` as the execution baseline unless implementation hits a concrete ambiguity that requires targeted retrieval

EXECUTE may read code broadly because code changes demand it, but it should not rebuild the plan from analysis artifacts unless the plan is genuinely insufficient.

## Retrieval discipline

The policy intentionally separates three actions:

1. Trust the authoritative artifact.
2. Retrieve only the smallest adjacent evidence that resolves a concrete gap.
3. Leave broader surfaces out of the prompt window when they do not materially change the current phase.

This rule applies both to the orchestrator and to sub-agents. The harness should not preload broad context when a bounded handoff already exists.

## Relationship to other specs

- `task-environment-contract.md` defines the bounded task surface.
- This spec defines how that bounded surface is consumed over time.
- The future sensor stack may validate compliance, but authority semantics should already be visible in the prompt even before those sensors exist.