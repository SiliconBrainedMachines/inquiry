# Feature Specification: iq-specification (the QA requirement phase)

**Status**: Draft · **Branch**: `spec/iq-specification` (planned) · **Date**: 2026-06-27

## Summary

`iq-specification` is the manual, QA-facing **requirement phase** of the Inquiry
method. It turns a raw requirement (arriving as email, documents, chat, a
message) into a **healthy, coherent, actionable, well-granulated specification**
plus the GitHub issues that decompose it — deciding by **evidence from
throwaway experiments, not by inference**. It is **independent** of the
developer cycle (analyze → plan → execute): it *precedes* it and produces the
issues each developer cycle then consumes.

It mirrors the user's engineering handbook (`cacsi-dev/handbook` →
`especificacion.md`), which now references this Inquiry methodology instead of a
separate CLI.

## Team / workspace separation

| Role | Skill(s) | Workspace | Level |
|---|---|---|---|
| **QA** | `iq-specification` | `requirements/<slug>/` | WHAT / why (requirement) |
| **Dev** | `iq-analyze` → `iq-plan` → `iq-execute` | `cleanrooms/<branch>/` + code | HOW (implementation) |

Handoff = the GitHub issues. (Mirrors spec-kit's "spec = what/why, never how".)

## User Scenarios

### User Story 1 — Turn a raw requirement into a specification (Priority: P1)
A QA analyst receives a requirement by email with attachments. They run
`iq-specification`, which scaffolds `specification.md`; they investigate (running
throwaway experiments where a decision needs evidence) and fill it with user
stories, Given-When-Then acceptance criteria, a testing strategy, explicit
scope, and a Decisions(evidence) section.
**Acceptance**: a filled `specification.md` that passes the `specification_ready`
quality gate.

### User Story 2 — Decompose into well-scoped issues (Priority: P1)
From the specification, the analyst derives one `issue-<slug>.md` per issue
(tracked in-repo as the platform-independent source of truth), and the skill
prints the `gh` commands to create them — **after** a duplicate check
(`gh issue list --search`); if a too-similar issue exists, it edits instead.
**Acceptance**: one `issue-<slug>.md` per identified issue + ready `gh` commands;
no duplicate issues created.

### User Story 3 — Decide by evidence, not inference (Priority: P2)
Where a scope/AC decision is uncertain, the analyst runs a throwaway probe (a DB
query, a container run, an API call) and records the decision with its
re-checkable evidence handle in the Decisions(evidence) section.
**Acceptance**: each key decision in the spec cites a re-checkable handle.

## Requirements (functional)

- **FR-1**: A new `iq-specification` skill, assembled from the contracts, using
  the **DEWEY** operator. Steps: gather the raw requirement from all sources →
  experiment for evidence → fill `specification.md` → derive `issue-<slug>.md`
  per issue → duplicate-check + print `gh` commands → present to human and stop.
- **FR-2**: The CLI scaffolds `requirements/<slug>/specification.md` from a
  single-source template (the hands), in the selected language.
- **FR-3**: **Bilingual** templates — `en` (default) and `es` via a `--lang`
  flag. (Scope: the QA spec only; dev-cycle artifacts stay English because the
  gates parse English.)
- **FR-4**: The template mirrors the handbook `especificacion.md`: Metadata,
  User Stories (As a / I want / So that) + Acceptance Criteria (Given-When-Then),
  Testing Strategy (Unit/Integration/E2E), Explicit Scope, **Decisions
  (evidence)**, Annexes.
- **FR-5**: A `specification_ready` gate: each user story has ≥1 Given-When-Then
  AC, explicit scope is present, a testing strategy is present, ≥1 issue is
  derived, and each Decisions bullet carries a re-checkable handle.
- **FR-6**: Issues live as `issue-<slug>.md` in the repo (source of truth);
  GitHub issues are a projection synced via the printed `gh` commands.
- **FR-7**: Methodology: `requirements/<slug>/` lands on `main` via a doc-PR
  from `spec/<slug>` (the QA review gate); main is branch-protected.

## Success Criteria

- **SC-1**: A QA analyst (or capable model) using `iq-specification` produces a
  `specification.md` that passes `specification_ready`, plus the issue files +
  `gh` commands, without touching the developer cycle.
- **SC-2**: The Inquiry template and the handbook `especificacion.md` are
  structurally identical (the handbook references Inquiry).
- **SC-3**: Every key decision in a produced spec carries a re-checkable
  evidence handle (evidence over inference, measured on a sample).

## Open design decisions (resolve before wiring)

1. **Skill shape**: `iq-specification`'s step structure differs from the
   analyze/plan/execute 5-step shape (it has experiment + issue-derivation +
   gh-command steps). Extend `SkillBuilder` with a third shape, or give
   `iq-specification` its own builder path.
2. **Goal source**: there is no `fsm/states/specification.yaml` (it is
   standalone). Add a small `specification` contract (goal + method) vs reuse
   `idle.yaml`/`dewey`.
3. **`--lang` plumbing**: a CLI flag vs a per-project config setting; default
   `en`.
4. **Gate home**: `specification_ready` as a standalone check (no FSM state) vs
   a mini-FSM for the requirement phase.

## Out of scope

- Auto-creating GitHub issues (manual mode prints `gh` commands; the FSM/agent
  mode could auto-create later).
- Bilingual dev-cycle artifacts (`diagnosis.md`, `plan.md` stay English).
- An `iq start` command (separate work).
