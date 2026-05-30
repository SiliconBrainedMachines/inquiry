---
id: analyze-contract
title: "ANALYZE phase contract — methodology-agnostic"
date: 2026-05-30
status: active
tags: [analyze, contract, methodology, fsm]
---

# ANALYZE phase contract — methodology-agnostic

## Core decision

ANALYZE is a phase contract, not a SOCRATES contract.

The phase owns:

- the requirement for user participation
- the visibility of the analysis interaction
- the shape of the analysis corpus in cleanrooms/<branch>/analyze/
- the completion criteria required before PLAN may begin

The active analysis APE owns only the investigation method.

That means SOCRATES may be replaced by another analysis APE without breaking
ANALYZE, as long as the replacement still satisfies the ANALYZE phase contract.

## Normative contract text

ANALYZE exists to build shared understanding of the problem with the user before
planning begins.

The active analysis APE provides the investigation method. The FSM state
provides the operational contract.

During ANALYZE:

1. User participation is mandatory.
2. The analysis interaction must remain visible to the user while the phase is
   running.
3. The active APE may guide the inquiry using its own methodology, but it may
   not define repository artifact names or completion policy.
4. The phase must maintain an inspectable analysis corpus under
   cleanrooms/<branch>/analyze/.
5. The corpus must include:
   - index.md as the navigable entry point
   - confirmations.md as the living record of stabilized findings,
     confirmations, revisions, and invalidations
   - one markdown document per relevant topic when the analysis opens a distinct
     question, evidence class, boundary decision, or conceptual split
   - diagnosis.md as the final synthesis
6. diagnosis.md is the sole planning input, but it is not by itself proof that
   ANALYZE is complete.
7. ANALYZE may transition to PLAN only after explicit user confirmation that the
   analysis is complete.

## Target completion semantics

The ANALYZE -> PLAN boundary should require all of the following:

- explicit user confirmation that analysis is complete
- diagnosis.md exists
- index.md exists and points to the relevant analysis documents
- confirmations.md exists
- the analysis corpus is inspectable and coherent enough for PLAN to consume

This boundary must fail closed. Hidden autonomous completion is invalid.

## Naming decision

Target name: confirmations.md

Rationale:

- confirmed.md sounds like a list of already-fixed facts
- confirmations.md better captures a living boundary document that records what
  the user and the analysis process have actually stabilized, revised, or
  invalidated

Transitional note: the current runtime still creates confirmed.md. The contract
target should be confirmations.md, with migration handled separately during
implementation.

## Proposed target-state YAML

This is a proposed redaction for the future ANALYZE contract. It is not a claim
that the current parser already supports every field.

```yaml
name: analyze
version: "2.0.0"
description: "Shared problem understanding before planning"

instructions: |
  Build shared understanding of the problem with the user before planning.
  Use the active analysis APE's methodology to investigate.
  Maintain an inspectable analysis corpus in cleanrooms/<branch>/analyze/.
  Produce diagnosis.md as the final synthesis and sole input for PLAN.

constraints:
  - User participation is mandatory before completion
  - Analysis interaction must remain visible to the user
  - The active APE does not define repository artifact names or completion gates
  - No solution proposals
  - No code edits
  - No branch creation

allowed_actions:
  - Investigate with the active analysis methodology
  - Ask the user questions or otherwise elicit analysis input
  - Read and search the codebase
  - Create and update analyze/ documents
  - Synthesize diagnosis.md

required_artifacts:
  - index.md
  - confirmations.md
  - diagnosis.md

artifact_policy:
  topic_documents: |
    Create one markdown document per relevant topic when analysis opens a
    distinct question, evidence class, or boundary decision.

interaction:
  mode: visible_iterative_dialogue
  user_participation_required: true

completion_requirements:
  - explicit_user_confirmation
  - diagnosis_exists
  - index_exists
  - confirmations_exist
  - corpus_is_navigable
```

## Consequence

Once this contract is made canonical, SOCRATES becomes what it should be:
replaceable methodology, not repository procedure.