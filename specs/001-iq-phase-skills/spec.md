# Feature Specification: iq-* phase skills

**Feature Branch**: `282-sdd-iq-phase-skills`

**Created**: 2026-06-25

**Status**: Draft

**Input**: User description: "Per-phase skills (/iq-analyze, /iq-plan, /iq-execute) so a weak model — or a human — can run the Inquiry methodology step-by-step when the inquiry scheduler agent cannot autonomously drive the CLI. Generated from the existing FSM + APE contracts so they stay in sync; brief but highly functional."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Run ANALYZE manually/assisted when the model can't drive (Priority: P1)

A developer is working on an inquiry cycle with a weak local model (e.g. qwen3-coder:30b) that ignores or mis-drives the `inquiry` scheduler agent. Instead of relying on the agent, the developer invokes the `/iq-analyze` skill. The skill guides them (or the weak model) through the ANALYZE phase: what the phase must accomplish, the exact `iq` commands to run, the required shape of `diagnosis.md`, and how to pass the gate — until `complete_analysis` succeeds.

**Why this priority**: ANALYZE is the first phase and the one where weak models fail most (engagement + producing a gate-compliant diagnosis). Delivering just this skill already lets an accessible model complete the hardest step, which is the project's core goal.

**Independent Test**: Invoke `/iq-analyze` on a repo at the ANALYZE state and follow it; success = a `diagnosis.md` that passes `iq fsm transition --event complete_analysis` (exit 0), without using the scheduler agent.

**Acceptance Scenarios**:

1. **Given** a cycle in the ANALYZE state, **When** the user follows `/iq-analyze`, **Then** they produce a `diagnosis.md` that passes the `complete_analysis` gate.
2. **Given** the gate rejects the diagnosis, **When** the user re-reads the skill's "Done when" checklist and the gate error, **Then** the skill tells them exactly what to fix (e.g. a missing evidence handle) and they pass on retry.

---

### User Story 2 - Run PLAN and EXECUTE the same way (Priority: P2)

The developer continues the cycle with `/iq-plan` (produce a gate-passing `plan.md` with executable checks) and `/iq-execute` (implement the plan phase-by-phase under its constraints), each a self-contained guide for that phase.

**Why this priority**: Completes the manual/assisted path end-to-end, but depends on the pattern proven by P1.

**Independent Test**: From a repo in PLAN (resp. EXECUTE), follow `/iq-plan` (resp. `/iq-execute`); success = the phase's gate passes.

**Acceptance Scenarios**:

1. **Given** a cycle in PLAN, **When** the user follows `/iq-plan`, **Then** `plan.md` passes the PLAN→EXECUTE gate.
2. **Given** a cycle in EXECUTE, **When** the user follows `/iq-execute`, **Then** the plan's phases are implemented and the EXECUTE gate passes.

---

### User Story 3 - Skills stay in sync with the methodology automatically (Priority: P2)

A maintainer changes an FSM state contract or an APE operator prompt. The `iq-*` skills are regenerated from those sources, so they never drift from the actual gates and methodology the CLI enforces.

**Why this priority**: Without this, the skills rot the moment the contracts change — the same drift problem the single-source firmware solved. It is what makes the skills trustworthy over time.

**Independent Test**: Change a phase contract (e.g. add a required section to the diagnosis), regenerate, and confirm the corresponding `iq-*` skill reflects the change without manual edits.

**Acceptance Scenarios**:

1. **Given** a changed phase contract, **When** the skills are rebuilt, **Then** the affected `iq-*` skill content matches the new contract.

---

### Edge Cases

- The user invokes `/iq-analyze` when the cycle is **not** in ANALYZE → the skill must tell them to run `iq fsm state` and which phase/skill actually applies, rather than proceeding wrongly.
- No cleanroom/cycle exists yet → the skill points to the `iq`/`gh`/`git` commands that start a cycle (start/end are not their own skills).
- The gate keeps failing → the skill's "Done when" checklist + the gate's own error message must be enough to self-correct (no scheduler agent needed).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide three phase skills — `iq-analyze`, `iq-plan`, `iq-execute` — invocable on demand (no scheduler agent required). Start and end are handled by direct `iq`/`gh`/`git` commands, not dedicated skills.
- **FR-002**: Each skill MUST state the phase's **goal** and methodology (from the FSM state contract + the phase's APE operator), the exact **`iq` commands** for that phase (the mechanics), the required **artifact shape** (e.g. `diagnosis.md` sections + evidence-handle rule), and a **"Done when"** checklist tied to the phase's gate.
- **FR-003**: Each skill MUST be **brief but highly functional** — the methodology core (the part a human/weak model reasons over) MUST be short; mechanical work is delegated to `iq` commands and the artifact shape to a referenced template.
- **FR-004**: The skills MUST be **generated from the existing contracts** (FSM state contracts and APE operator prompts) at build time, so they cannot drift from the gates the CLI enforces.
- **FR-005**: The skills MUST be deployable to a host alongside the existing skills (research/legion/kritik) via the established deploy path.
- **FR-006**: A skill invoked in the wrong phase MUST direct the user to `iq fsm state` and the applicable phase, not produce a wrong artifact.

### Key Entities *(include if feature involves data)*

- **Phase skill (`iq-<phase>`)**: a self-contained, on-demand guide for one FSM phase; attributes — goal, methodology, `iq` commands, artifact shape, gate "Done when".
- **Phase contract**: the existing source of truth for a phase — the FSM state contract (mission, constraints, required artifacts, gate) + the phase's APE operator prompt (cognitive method). The skill is derived from it.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user (or weak model) with no scheduler agent can take a cycle from ANALYZE to a passing `complete_analysis` gate using only `/iq-analyze` — measured by gate exit code 0.
- **SC-002**: With the three skills, a cycle can be driven manually/assisted through ANALYZE → PLAN → EXECUTE with every phase gate passing, without invoking the `inquiry` scheduler agent.
- **SC-003**: A weak local model assisted by `/iq-analyze` passes the ANALYZE gate at a **higher rate** than the same model driving the scheduler agent unaided (the manual skill is more followable than autonomous orchestration).
- **SC-004**: The methodology core of each skill stays short (a human can read and act on it in under ~2 minutes per phase), with mechanics offloaded to `iq` commands.
- **SC-005**: A change to a phase contract is reflected in the regenerated skill with zero manual skill edits (no drift).

## Assumptions

- The host (OpenCode, Claude Code) discovers on-demand skills from its skills directory, as the existing research/legion/kritik skills already prove.
- The existing `iq` CLI gates (e.g. `complete_analysis`) already verify artifacts and return actionable errors — the skills lean on them rather than re-implementing validation.
- Start/end of a cycle are adequately covered by direct `iq`/`gh`/`git` commands, so `iq-start`/`iq-cleanroom`/`iq-end` skills are out of scope for v1.
- The three current FSM phases map cleanly to three skills; additional states (IDLE, END, EVOLUTION) are out of scope for v1.
