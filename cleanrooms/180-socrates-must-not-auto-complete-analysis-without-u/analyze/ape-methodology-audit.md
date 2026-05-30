---
id: ape-methodology-audit
title: "Audit — active APE methodology purity (except DARWIN)"
date: 2026-05-30
status: active
tags: [ape, dewey, socrates, descartes, basho, methodology]
---

# Audit — active APE methodology purity (except DARWIN)

## Audit question

Do the active APEs for IDLE, ANALYZE, PLAN, and EXECUTE contain only
methodology, or do they still carry FSM, artifact, or phase knowledge that
should live elsewhere?

## Decision summary

- DEWEY is relatively clean, but not fully pure.
- SOCRATES is materially entangled with ANALYZE semantics in its current
  ecosystem role.
- DESCARTES is materially more coupled to phase semantics.
- BASHO is also coupled to EXECUTE artifact and boundary semantics.
- Therefore the current APE roster is inconsistent with the target architecture.

## DEWEY

### What is method-only

DEWEY's core is methodological:

- problematization
- scope control
- issue granularity
- deduplication
- issue formulation readiness

Those are legitimate thinking-method concerns.

### Where DEWEY leaks runtime knowledge

DEWEY is not perfectly pure because it still contains runtime-facing language:

- "Search for existing issues"
- "Help formulate a clear issue title and description"
- "Use the active IDLE contract and allowed command surface to search"
- "Use the injected inquiry-context to respect the active IDLE routing contract"

This is milder than SOCRATES knowing file outputs, but it is still more than
portable methodology. A perfectly clean DEWEY would express only how to turn an
indeterminate situation into a well-formed problem. The exact issue workflow,
allowed commands, and routing contract should come from IDLE.

### Verdict on DEWEY

Verdict: mostly aligned with the target architecture, but still slightly coupled
to IDLE operational policy.

## SOCRATES

### What is method-only

SOCRATES does contain a real method core:

- epistemic humility
- questions over answers
- clarification
- assumption-challenging
- evidence-seeking
- perspective shifts
- implication tracing
- meta-reflection

That is legitimate mayeutic method.

### Where SOCRATES leaks phase knowledge

SOCRATES is not methodology-only in its present form because it also knows
about:

- diagnosis.md as a named repository deliverable
- sufficiency of depth for that deliverable
- a linear path to _DONE that the scheduler can drive without visible dialogue

Some of the deeper problem is not in the YAML alone, but in the ecosystem around
it: ANALYZE, the transition gate, and firmware all rely on SOCRATES in a way
that makes the APE look like the owner of phase semantics.

### Verdict on SOCRATES

Verdict: the acute bug is centered here. SOCRATES should remain a mayeutic
method, but today it is too entangled with ANALYZE completion semantics and
diagnosis production expectations.

## DESCARTES

### What is method-only

DESCARTES does contain legitimate planning method:

- evidence discipline
- problem division
- sequencing
- completeness checking
- verification thinking

Those are the Four Rules translated into planning behavior.

### Where DESCARTES leaks phase knowledge

DESCARTES is not methodology-only. It currently knows about:

- diagnosis.md by name as input
- approval semantics
- execution-phase falsification returning to analysis
- plan immutability after approval
- concrete expected output structure for plan artifacts

These are not purely Cartesian method. They are PLAN-state contract and
transition-boundary semantics.

### Verdict on DESCARTES

Verdict: materially coupled to PLAN semantics and output policy. It needs the
same cleanup direction proposed for SOCRATES, although the coupling is less
severe than the current ANALYZE problem.

## BASHO

### What is method-only

BASHO does contain a genuine implementation method:

- elegance under constraints
- minimalism
- no waste
- separation of concerns
- disciplined phase-by-phase execution

That is a valid execution style and craft philosophy.

### Where BASHO leaks phase knowledge

BASHO is not methodology-only because it knows about:

- plan.md by name as the operative constraint source
- marking completed steps in plan.md
- annotating deviations inline
- commit behavior with issue references
- the test and commit sub-phases as named operational closure steps

Those are EXECUTE-state and transition concerns, not just implementation method.

### Verdict on BASHO

Verdict: coupled to EXECUTE artifact policy and phase closure semantics. Less
urgent than SOCRATES for product trust, but architecturally the same category of
problem.

## Relative ranking

From cleaner to more coupled:

1. DEWEY
2. DESCARTES
3. BASHO
4. SOCRATES in its current ecosystem positioning

This ranking is about contract purity, not product importance.

## What should move out

### For DEWEY

Move out to IDLE contract:

- exact issue workflow
- allowed command surface
- routing contract language

Keep in DEWEY:

- problematization
- issue granularity heuristics
- readiness questioning

### For SOCRATES

Move out to ANALYZE contract and ANALYZE -> PLAN boundary:

- named repository artifacts
- analysis completion semantics
- proof of user participation
- explicit completion confirmation requirements

Keep in SOCRATES:

- mayeutica
- question styles
- investigative progression
- epistemic stance

### For DESCARTES

Move out to PLAN contract:

- named canonical input/output files
- approval semantics
- plan immutability policy
- deviation return semantics

Keep in DESCARTES:

- division
- ordering
- completeness
- verification design

### For BASHO

Move out to EXECUTE contract:

- named plan artifact policy
- deviation annotation policy
- commit closure rules
- phase completion bookkeeping

Keep in BASHO:

- elegance under constraints
- minimal implementation style
- craft discipline
- implementation judgment within bounded scope

## Naming opinion: confirmations.md

I agree with confirmations.md over confirmed.md.

Reasons:

- confirmed.md sounds like a static bag of already-closed facts
- confirmations.md sounds like an active record of what has been stabilized,
  revised, invalidated, or explicitly confirmed with the user
- confirmations.md fits better with the contract you want: user participation
  plus living epistemic boundary, not just a dump of findings

If the file is meant to capture a living agreement surface during analysis,
confirmations.md is the better semantic choice.