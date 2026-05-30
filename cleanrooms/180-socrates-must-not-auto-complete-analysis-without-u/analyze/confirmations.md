---
id: confirmations
title: "Confirmations"
date: 2026-05-30
status: active
tags: [findings, confirmations]
---

# Confirmations

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: ANALYZE must own the participation and artifact contract — CONFIRMED

User participation, visible interaction during analysis, and the required
analysis corpus belong to the ANALYZE state contract. They do not belong to
SOCRATES as a method-specific APE.

## F2: SOCRATES should own methodology only — CONFIRMED

SOCRATES should own mayeutic method: epistemic posture, question style,
investigation rhythm, and internal thought progression. It should not own file
names, cleanroom policy, or completion semantics.

## F3: The current runtime still hardcodes ANALYZE to SOCRATES — CONFIRMED

The present system still binds ANALYZE to socrates in the active APE mapping and
in prompt fragments. That means methodology swap is not yet a clean
configuration change.

## F4: The current analyze bootstrap is still APE-colored — CONFIRMED

The current open_analysis_context effect creates confirmed.md with author:
socrates. That couples an ANALYZE artifact to one particular APE identity.

## F5: diagnosis.md alone is not a valid proof of completion — CONFIRMED

The ANALYZE -> PLAN boundary must require explicit user confirmation and an
inspectable analysis corpus. diagnosis.md by itself is necessary, but not
sufficient.

## F6: DEWEY is closer to methodology-only, but still not fully pure — CONFIRMED

DEWEY mostly stays in method space: problematization, scope questioning,
deduplication, and issue formulation. However, it still knows about active IDLE
contract usage and injected inquiry-context, which means it is not yet a purely
portable thinking method.

## F7: DESCARTES still contains substantial phase knowledge — CONFIRMED

DESCARTES knows about diagnosis.md as named input, plan approval, execution
deviation, and immutable post-approval plan structure. That means it currently
contains PLAN semantics in addition to planning method.

## F8: Methodological purity varies by APE today — CONFIRMED

The repository is not yet consistent. SOCRATES, DEWEY, DESCARTES, and BASHO sit
at different points on the methodology-versus-phase-policy spectrum.

## F9: BASHO also carries non-method execution semantics — CONFIRMED

BASHO knows about plan.md by name, inline deviation annotations, and commit
closure behavior. That makes it an execution operator plus part of the EXECUTE
contract, not just an implementation method.

## F10: confirmations.md is the right target name — CONFIRMED

The target analysis corpus should use confirmations.md, not confirmed.md.
confirmations.md better represents a living epistemic boundary that records what
was stabilized with the user during analysis.