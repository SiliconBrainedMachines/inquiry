# Phase 1 Data Model: iq-* phase skills

## PhaseContract (source of truth — already exists)

The inputs the SkillBuilder reads for a phase:

| Field | Source |
|---|---|
| `goal`, `constraints`, `requiredArtifacts` | `assets/fsm/states/<phase>.yaml` |
| `operatorMethod` | `assets/apes/<operator>.yaml` (socrates/descartes/ada) |
| `gateEvent` | FSM transition contract (e.g. `complete_analysis`) |
| `artifactTemplate` | `assets/artifacts/<artifact>.template.md` (NEW, per R1) |

Phase → operator → artifact → gate mapping:

| Phase | Operator | Artifact | Gate event |
|---|---|---|---|
| analyze | socrates | diagnosis.md | complete_analysis |
| plan | descartes | plan.md | approve_plan / go_execute |
| execute | ada | (code + plan phases) | finish_execute |

## PhaseSkill (the generated output)

A `SKILL.md` with:
- `name`: `iq-<phase>` · `description`: one line.
- **Goal** (from contract.goal).
- **Steps** (mechanics): the `iq` commands for the phase (R2), "use the event `iq fsm state` lists".
- **Artifact shape**: the embedded `artifactTemplate`.
- **Done when**: a checklist derived from `requiredArtifacts` + the gate (e.g. "every Evidence bullet has a handle", "gate passes exit 0").

## Invariants
- Every generated skill MUST be derivable purely from the contract (no hand-authored phase logic in the builder) — Principle V / SC-005.
- The embedded `artifactTemplate` MUST satisfy the phase's gate (test: a template-shaped artifact passes the gate).
