---
id: diagnosis
title: "Diagnosis — methodology belongs to APEs, phase policy belongs to FSM"
date: 2026-05-30
status: final
tags: [diagnosis, analyze, ape, contract]
---

# Diagnosis — methodology belongs to APEs, phase policy belongs to FSM

## Problem

Issue #180 enters through a specific failure: SOCRATES can be driven to _DONE
without visible user conversation, and the system can then treat diagnosis.md as
enough evidence to approach the ANALYZE -> PLAN boundary.

That acute failure is real, but it is not the deepest diagnosis.

The deeper problem is architectural inconsistency in how Inquiry distributes
responsibility between APE identity and FSM phase contract.

The intended model is:

- APE = thinking methodology
- FSM state = operational contract of the phase
- FSM transition = formal boundary gate
- scheduler = generic enforcement

The current system only partially realizes that split.

## Evidence synthesis

### 1. The architecture already declares the correct split

The canonical architecture says the effective prompt is composed from APE
identity, phase-owned operational contract, and runtime inquiry-context.

That doctrine already implies that repository procedure should not live inside an
APE definition.

### 2. SOCRATES exposes the most visible break

SOCRATES remains method-rich, but the surrounding runtime effectively lets its
linear progression stand in for analysis completion.

This is why the product regression is felt so sharply in ANALYZE: the user no
longer experiences a visible, shared inquiry. Instead the system risks treating
hidden sub-agent progress as equivalent to completed understanding.

### 3. The same category of impurity appears across the active roster

The audit of active non-EVOLUTION APEs shows inconsistent layering:

- DEWEY is closest to methodology-only, but still knows about IDLE routing
  contract and issue workflow behavior.
- SOCRATES is method-rich but too entangled with ANALYZE completion expectations.
- DESCARTES knows about plan approval, diagnosis.md, and post-approval plan
  semantics.
- BASHO knows about plan.md, deviation annotation, and commit closure behavior.

The issue is therefore broader than one YAML file. Inquiry has not yet made the
APE-vs-phase boundary consistent across its active operator roster.

## Core diagnosis

### D1. The product invariant must be phase-stable and methodology-agnostic

If Inquiry can swap SOCRATES for another analysis APE, then ANALYZE cannot be
defined by Socratic method. ANALYZE must instead be defined by its stable phase
contract:

- shared understanding with the user
- visible interaction during the phase
- inspectable analyze corpus
- explicit human confirmation before leaving the phase

This invariant belongs to the FSM, not to the active APE.

### D2. APE definitions should contain methodology, not repository procedure

Each APE should describe how it thinks, questions, plans, or implements.

It should not define:

- canonical repository artifact names
- state transition semantics
- approval policy
- boundary proof conditions
- plan/commit/file workflow policy

Once those concerns enter an APE YAML, the APE stops being a replaceable
thinking tool and becomes a hidden phase contract.

### D3. The current runtime leaks phase policy in more than one place

The impurity is distributed, not localized:

- APE YAMLs carry named artifacts and approval assumptions
- FSM state contracts are not yet explicit enough about participation,
  visibility, and corpus policy
- transition prechecks under-model phase completion
- firmware currently treats hidden sub-agent progress as sufficient process
  movement
- CLI effects still materialize analyze artifacts with APE-colored defaults

That is why the behavior feels "automatic" or "magical" to the user. The system
has no single explicit contract for what completed analysis means as a shared
human process.

### D4. The correct local fix for #180 is in ANALYZE, but the doctrine must be generalized

The acute repair for #180 belongs in the ANALYZE slice:

- ANALYZE contract
- ANALYZE -> PLAN boundary
- scheduler interaction policy during ANALYZE
- analyze artifact bootstrap

But the doctrinal lesson is larger: DEWEY, DESCARTES, and BASHO should also be
cleaned over time so that all active non-DARWIN APEs converge on the same
architectural rule.

### D5. confirmations.md is the correct canonical name

The analysis corpus should use confirmations.md.

Reason:

- confirmed.md suggests a static list of fixed conclusions
- confirmations.md better expresses a living record of what has been stabilized,
  revised, invalidated, or explicitly confirmed with the user

This matters because the file is not just a note log. It is part of the
epistemic boundary of ANALYZE.

## Scope decision

### In scope for this diagnosis

- the acute #180 failure around SOCRATES and ANALYZE completion
- the correct location of user participation and artifact policy
- the canonical naming decision confirmations.md
- the audit of active APEs except DARWIN to test whether the same architectural
  confusion appears elsewhere

### Out of scope for this diagnosis

- DARWIN and EVOLUTION semantics
- the detailed implementation plan for every required code change
- final migration sequencing across all APEs

Those belong to planning.

## Consequences

If this diagnosis is accepted, Inquiry should be understood as follows:

1. APEs are methodologies, not hidden workflow owners.
2. FSM states own the operational contract of each phase.
3. Transition gates own formal crossing requirements.
4. Scheduler behavior must obey state interaction policy rather than silently
   invent one.
5. Artifact bootstrap effects must materialize declared policy, not define it.

This restores the possibility of replacing an APE without changing the meaning
of the phase itself.

## Final statement

The bug described in #180 is not just that SOCRATES auto-completes.

The real defect is that Inquiry still distributes product meaning across the
wrong layers. The active APEs should be methodologies. The FSM should own phase
policy. Today that split is incomplete, and ANALYZE is where the defect becomes
user-visible first and most painfully.

## References

- analyze-contract.md
- responsibility-map.md
- ape-methodology-audit.md
- confirmations.md