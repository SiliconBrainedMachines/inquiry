---
id: responsibility-map
title: "Responsibility map — APE vs phase vs scheduler vs transition"
date: 2026-05-30
status: active
tags: [architecture, boundaries, analyze]
---

# Responsibility map — APE vs phase vs scheduler vs transition

## Stable layering

The clean split should be:

- APE definition = thinking method
- FSM state contract = operational contract of the phase
- FSM transition contract = formal boundary gate between phases
- Scheduler firmware = generic orchestration and enforcement
- CLI effects = materialization of declared effects, not hidden policy owners

## What stays in the analysis APE

These responsibilities should remain inside SOCRATES, or any future replacement
APE for ANALYZE:

- epistemic posture
- question style
- method-specific moves
- internal sub-state progression
- method-specific prompting language

Examples:

- mayeutica
- challenge assumptions
- seek counterexamples
- alternate viewpoints
- meta-reflection sequence

## What must move out of SOCRATES

These responsibilities do not belong to SOCRATES:

- repository file names
- cleanroom corpus policy
- completion gate semantics
- proof that the user participated
- criteria for leaving ANALYZE
- naming of canonical analyze artifacts

If any of those remain in SOCRATES, swapping methodology requires changing the
meaning of ANALYZE itself, which is exactly what the architecture should avoid.

## Responsibility transfer map

| Concern | Current owner | Target owner | Why |
|---|---|---|---|
| Mayeutic questioning method | SOCRATES | SOCRATES | This is methodology, not phase policy |
| Visible user participation during ANALYZE | Implicit issue language and ad hoc expectations | ANALYZE phase contract | This must hold even if SOCRATES is replaced |
| Required analyze corpus: index.md, confirmations.md, topic docs, diagnosis.md | Mixed between effect executor and current phase wording | ANALYZE phase contract | Artifact policy is part of the phase boundary |
| Final permission to leave ANALYZE | completion_authority + diagnosis_exists | FSM transition contract | Boundary logic belongs to the formal transition gate |
| Evidence that analysis actually happened with the user | Not modeled | FSM transition contract + ANALYZE state evidence policy | Without this, diagnosis.md can be generated autonomously |
| Whether analysis output is shown or hidden | Scheduler firmware | Scheduler obeying ANALYZE interaction policy | The scheduler should enforce the state contract, not invent one |
| Creation of analyze artifacts | Hardcoded in CLI effect executor | CLI effect executor driven by declarative ANALYZE artifact spec | The executor should materialize policy, not define it |
| Binding ANALYZE to a specific APE | Hardcoded ANALYZE -> socrates mapping | Configurable analysis operator binding | Methodology swap should not require code edits |

## Concrete moves by file

### From assets/apes/socrates.yaml

Keep:

- epistemic humility
- question types
- investigation progression
- method-specific prompts

Move out:

- any knowledge of diagnosis.md as a repository deliverable
- any file naming policy
- any implication that reaching _DONE alone is sufficient for phase completion

### From assets/fsm/states/analyze.yaml

Keep and strengthen:

- phase purpose
- phase constraints
- allowed actions

Rewrite so it becomes methodology-agnostic:

- remove specifically Socratic wording from the state contract
- add explicit participation, visibility, and artifact policy
- define the inspectable analyze corpus

### From assets/fsm/transition_contract.yaml

Keep:

- complete_analysis as the boundary event

Add:

- explicit_user_confirmation precheck
- confirmations_exist precheck
- index_exists precheck
- possibly a corpus-ready or conversation-recorded precheck

The key point is that diagnosis_exists remains necessary, but no longer carries
the full burden of proving completion.

### From modules/fsm/effect_executor.dart

Keep:

- file materialization mechanics

Move out of hardcoded Dart strings:

- confirmed.md as the canonical filename
- author: socrates in the analysis artifact template
- any artifact meaning that depends on one methodology

Target behavior:

- the executor reads a declarative analyze artifact policy
- the executor creates the required files without attributing them to one APE

### From assets/agents/inquiry.agent.md

Keep:

- generic orchestration
- dispatch discipline
- separation between APE completion and FSM transition

Change:

- replace universal hidden-dispatch behavior with state-aware interaction policy
- ANALYZE must allow visible dialogue with the user
- the scheduler should not treat hidden sub-agent completion as equivalent to
  completed shared understanding

## Transitional implementation note

The current system bootstraps analyze artifacts with confirmed.md. The target
contract should adopt confirmations.md instead.

This rename should be treated as an implementation follow-up, not as a reason to
leave the conceptual split ambiguous.

## Bottom line

If the methodology changes, ANALYZE should still mean the same thing.

That is only possible if method lives in the APE and phase policy lives in the
FSM contract.