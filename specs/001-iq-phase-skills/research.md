# Phase 0 Research: iq-* phase skills

## R1 — Source of the artifact "shape" (the key decision)

**Question**: a skill must show the required shape of `diagnosis.md`/`plan.md`.
Today that shape is *implicit* in the gate prechecks (`transition.dart`: required
sections, the evidence-handle rule). Where should the skill's shape come from?

**Options**:
- (a) Re-state the shape inside each skill template (drift risk — Principle V).
- (b) Derive the shape from the gate code (no clean machine-readable source).
- (c) **Define explicit per-phase artifact templates** (`assets/artifacts/diagnosis.template.md`,
  `plan.template.md`) that the SkillBuilder embeds AND that the gate can later
  reference — one source of truth.

**Decision: (c)** — add explicit artifact templates as a first-class asset.
**Rationale**: satisfies Principle III/IV (the shape that carries evidence handles
is authored once) and V (no drift; the same template can back the gate later). For
v1 the gate keeps its current checks; the template MUST be consistent with them
(verified by a test that a template-shaped diagnosis passes the gate).

## R2 — Per-phase command set (mechanics layer)

Derived from the FSM contracts; each skill prescribes exactly:
- **ANALYZE**: `iq fsm state --json` → `iq ape prompt --name socrates` (method) →
  write `diagnosis.md` → `iq fsm transition --event complete_analysis`.
- **PLAN**: `iq fsm state` → `iq ape prompt --name descartes` → write `plan.md`
  (executable checks) → `iq fsm transition --event <approve_plan|go_execute>`.
- **EXECUTE**: `iq fsm state` → `iq ape prompt --name ada` → implement per phase →
  `iq fsm transition --event finish_execute`.
The exact event names are read from `iq fsm state` at runtime (Principle I — the
skill says "use the event `iq fsm state` lists", never hardcodes a guess).

## R3 — Skill format, naming, discovery

- **Decision**: `iq-<phase>` (`iq-analyze`, `iq-plan`, `iq-execute`), one dir per
  skill with `SKILL.md`, frontmatter `name` + `description` — identical to the
  existing research/legion/kritik skills and to spec-kit's `speckit-*` skills.
- **Discovery**: deployed globally by `iq host get` into `~/.config/opencode/skills/`
  and `~/.claude/skills/`; both hosts auto-discover (already proven). No new plumbing.

## R4 — Brevity budget (SC-004)

- **Decision**: the methodology core (Goal + Steps + Done-when) ≤ ~40 lines;
  the artifact template is referenced/embedded separately and not counted against
  the "reasoned-over" core. Mechanics are one-line `iq` commands.
- **Rationale**: spec-kit's effective core (`plan.md` outline) is ~7 steps;
  brevity is what a weak model can actually follow.

## R5 — Generation timing

- **Decision**: generate at **deploy time** via `SkillBuilder` (mirrors how
  `AgentBuilder` assembles the agent at deploy), reading the FSM state contract +
  APE prompt + artifact template. Keeps generated skills out of source control and
  always in sync with the installed CLI version. (A `--check` mode can fail CI if
  a committed snapshot drifts, if desired later.)

All NEEDS CLARIFICATION resolved.
