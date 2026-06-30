# Implementation Plan: iq-* phase skills

**Branch**: `282-sdd-iq-phase-skills` | **Date**: 2026-06-26 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-iq-phase-skills/spec.md`

## Summary

Provide three on-demand skills — `iq-analyze`, `iq-plan`, `iq-execute` — that let a
human or a weak model run an Inquiry phase step-by-step without the scheduler
agent. Each skill is a thin **3-layer orchestrator** (mechanics = `iq` CLI;
shape = artifact template; judgment = FSM contract + APE method) and is
**generated at build time** from the existing contracts by a new `SkillBuilder`
(mirroring `AgentBuilder`), so it cannot drift from the gates the CLI enforces.
The skills deploy globally alongside research/legion/kritik via `iq host get`.

## Technical Context

**Language/Version**: Dart 3.8 (the existing `iq` CLI).

**Primary Dependencies**: existing `AgentBuilder`/`Assets` pattern; `HostDeployer`
(deploys skills); FSM state contracts (`assets/fsm/states/*.yaml`); APE operator
prompts (`assets/apes/*.yaml`); gate definitions (`transition.dart` prechecks).

**Storage**: files only — generated `SKILL.md` assets; no DB.

**Testing**: `dart test` (unit: SkillBuilder output; integration: deployed skill
content) + a conducted experiment for SC-003 (weak model with vs without skill).

**Target Platform**: the CLI runs on Windows/Linux; skills consumed by OpenCode
+ Claude Code (global `~/.config/opencode/skills/`, `~/.claude/skills/`).

**Project Type**: single project (Dart CLI), `code/cli/`.

**Performance Goals**: N/A (build-time generation; skills are static once built).

**Constraints**: each skill's methodology core MUST be short (SC-004, readable in
~2 min); skills MUST be generated from contracts (SC-005, no drift).

**Scale/Scope**: 3 phases (ANALYZE/PLAN/EXECUTE); ~3 generated skills.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Compliance |
|---|---|
| I. CLI is the brain | ✅ Skills instruct "run `iq fsm state`, follow `next`, run the phase's `iq` commands" — the CLI stays authoritative; the skill is a guide, not a second scheduler. |
| II. Model never decides | ✅ At a gate / `completion_authority: user`, the skill says STOP and present to the human — no autonomous decision. |
| III. Evidence over inference | ✅ The artifact-shape layer requires re-checkable handles (e.g. every Evidence bullet); the skill defers verification to the `iq` gate, not its own judgment. |
| IV. Artifact-as-function | ✅ Each skill's deliverable is writing the phase `.md` artifact on disk, then passing the gate. |
| V. Structure over prose | ✅ The skill leans on CLI gates for enforcement; it adds no behavior the CLI can't verify. Generated from contracts, so the FSM/CLI remains the source of truth. |
| VI. Accessible models are the target | ✅ The whole feature exists to make a weak model followable; success is measured by SC-003 (conducted experiment), not assumption. |

**Result: PASS** — no violations; Complexity Tracking not required.

## Project Structure

### Documentation (this feature)

```text
specs/001-iq-phase-skills/
├── plan.md              # This file
├── research.md          # Phase 0 — resolve unknowns (artifact-shape source, naming, host format)
├── data-model.md        # Phase 1 — PhaseSkill / PhaseContract entities
├── quickstart.md        # Phase 1 — manual usage + regeneration
├── contracts/
│   └── skillbuilder.md  # Phase 1 — SkillBuilder API + skill content contract
└── tasks.md             # Phase 2 (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
code/cli/
├── lib/hosts/
│   ├── agent_builder.dart        # existing — model to mirror
│   └── skill_builder.dart        # NEW — assembles iq-<phase> SKILL.md from contracts
├── lib/modules/fsm/...           # existing FSM state contracts (read by SkillBuilder)
├── assets/
│   ├── fsm/states/*.yaml         # existing — phase goal/constraints/gate (judgment source)
│   ├── apes/*.yaml               # existing — operator method (judgment source)
│   ├── skills/                   # existing static skills (research/legion/kritik)
│   └── skills-templates/         # NEW — the 3-layer SKILL.md body template + per-phase data
└── test/
    └── skill_builder_test.dart   # NEW — output structure + per-phase content
```

**Structure Decision**: single Dart project under `code/cli/`. `SkillBuilder`
lives beside `AgentBuilder` in `lib/hosts/`; generated `iq-*` skills are emitted
into the host skills dir by `HostDeployer` at deploy time (same path as the static
skills), so no new deploy plumbing is needed.

## Phase 0 — Research (unknowns to resolve in research.md)

1. **Artifact-shape source**: the required shape of `diagnosis.md`/`plan.md` is
   currently implicit in the gate prechecks (`transition.dart`). Decide: derive
   the shape from the gate, or define explicit artifact templates that BOTH the
   skill and (eventually) the gate reference. (Single source of truth.)
2. **Per-phase command set**: enumerate the exact `iq` commands for each phase
   from the FSM contract (state → events → gate event).
3. **Skill format + naming**: confirm `iq-<phase>` SKILL.md frontmatter (name,
   description) is discovered globally by OpenCode + Claude (already proven for
   research/legion/kritik).
4. **Brevity budget**: define the max methodology-core length (SC-004).

## Phase 1 — Design (data-model.md, contracts/, quickstart.md)

- **data-model.md**: `PhaseSkill` (name, goal, commands[], artifactShape, doneWhen[])
  and `PhaseContract` (FSM state + APE operator + gate event) it is derived from.
- **contracts/skillbuilder.md**: `SkillBuilder.build(phase)` → `SKILL.md` string;
  the required sections of every generated skill; the deploy integration.
- **quickstart.md**: how a human/weak model uses `/iq-analyze` end-to-end, and how
  a maintainer regenerates skills after a contract change.
- Re-evaluate Constitution Check after design (expected: still PASS).

## Complexity Tracking

> No Constitution violations — section intentionally empty.
