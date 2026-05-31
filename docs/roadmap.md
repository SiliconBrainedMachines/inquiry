# Roadmap

> Status note: This roadmap is a strategic and partially historical planning document. It preserves backlog framing from earlier releases and should not be used as the authoritative description of the current operational model. For the current canonical explanation, see [architecture.md](architecture.md), [spec/finite-ape-machine.md](spec/finite-ape-machine.md), and [thinking-tools.md](thinking-tools.md).

> Version note: the live CLI source currently tracks `0.5.2` in [../code/cli/pubspec.yaml](../code/cli/pubspec.yaml). Public-facing version markers elsewhere in the repository may lag until the next coordinated release pass.

> Where APE is going next. For where APE is today, see [../README.md](../README.md).

> Live roster note: DEWEY now owns bounded IDLE triage in the current contract; `inquiry-start` remains the explicit handoff into ANALYZE.

This roadmap is **descriptive, not prescriptive**: it reflects the open issues currently in the backlog and the long-running theses that motivate the project. Anything not backed by an issue is exploratory.

## Vision

APE aims to be a **methodology for working with AI through explicit thinking tools**, robust across changing AI market conditions. Three theses guide every decision:

1. **Thinking tools make AI usable.** Model quality matters, but raw capability does not solve the core bottleneck by itself. Inquiry's wager is that AI gives renewed practical force to more than 2,500 years of philosophical labor: disciplined questioning, decomposition, inference, verification, and selection become operational tools for software work.
2. **Memory as code.** Project knowledge belongs in the repo, version-controlled, queryable by any agent — not in a cloud-hosted vector DB.
3. **Antifragility.** Each cycle should leave APE measurably better. DARWIN turns operational friction into improvements to the framework itself.

The end-state is an **APE that builds APE**: a self-improving framework where every cycle generates evidence (in `metrics.yaml`, in evolution issues, in mutations.md) that feeds the next cycle.

Recent research in [research/harness_engineering.md](research/harness_engineering.md) and [research/agent_engineering_taxonomy.md](research/agent_engineering_taxonomy.md) sharpens how this vision should be read: Inquiry is not only a methodology and not only a prompt packager. It is already becoming a **repository-local outer harness** for coding agents. The next frontier is therefore not just “more CLI features,” but the completion of that harness through better sensors, clearer context policy, stronger evals, and more explicit task environments.

## Historical planning snapshot (v0.0.14)

- 5-state FSM with declarative transition contract (IDLE / ANALYZE / PLAN / EXECUTE / EVOLUTION)
- 9 working CLI commands across 3 modules (`global`, `target`, `state`)
- Single-target deployment (Copilot) per [ADR D20](spec/target-specific-agents.md)
- Active roster at that snapshot: SOCRATES, DESCARTES, BASHŌ, DARWIN
- 131 tests, cross-platform (Windows + Linux), 12 GitHub releases
- Empirical bootstrap underway: APE is being built using APE (see [bootstrap-validation](research/ape_builds_ape/bootstrap-validation.md))

## Current runtime snapshot (v0.5.2)

The current CLI surface is still intentionally small. The live source tree exposes four active modules:

- **global** — bare `iq`, `init`, `version`, `doctor`, `upgrade`, `uninstall`
- **target** — `get`, `clean`
- **fsm** — `state`, `transition`
- **ape** — `prompt`, `state`, `transition`

The deployed runtime still centers on a single active host target, Copilot, with deferred adapters for other hosts retained in the codebase but not yet reactivated in `iq target get`.

The current persisted control surface is also concrete and live, not aspirational:

- `.inquiry/state.yaml`
- `.inquiry/config.yaml`
- `.inquiry/mutations.md`
- `.inquiry/metrics.yaml`
- `cleanrooms/<issue>/...` as per-cycle artifact space

This matters because it marks the real baseline: Inquiry is already operating as a small but substantive harness, not merely as a conceptual FSM described in prose.

## Strategic reading of the current frontier

Read through the current harness taxonomy, Inquiry's unfinished work clusters into four gaps:

1. **Sensor depth** — the methodology is explicit, but the catalog of local, CI, continuous, and runtime sensors is still thinner than the control model wants.
2. **Context policy** — Memory as Code is real, but progressive disclosure, compaction, and retrieval policy are still more implicit than formal.
3. **Eval discipline** — the project has gates and metrics, but not yet a full eval-engineering layer that systematically turns recurring failures into reusable benchmarks and graders.
4. **Task environments** — Inquiry already assembles prompts and paths, but it still has room to become more contract-first about bounded task inputs, outputs, and validation surfaces.

This section is strategic framing, not a substitute for the issue tracker. The issue-backed frontier remains below.

## Current frontier (post-v0.5.2)

This section is intentionally selective. It groups the open issues that most clearly define the next iterations of Inquiry; it is not a full dump of every issue in the tracker.

### Runtime and scheduler correctness
- **#181** — Scheduler dispatches the active APE name as `agentName` instead of the thinking-tool identity expected by the host
- **#180** — SOCRATES must not auto-complete analysis without an explicit boundary crossing
- **#178** — Persist the project root inside inquiry-context so prompt delivery remains stable across working directories
- **#174** — Linux install can leave `iq` unavailable after a nominally successful install
- **#167** — Collapse BASHO into a simpler single-phase execution surface once the current transition boundaries are revalidated

### Workflow and cycle discipline
- **#165** — Revisit `inquiry-start` / `inquiry-end` naming so the skill surfaces match the methodology-first vocabulary
- **#163** — Add a formal pre-PR inspection gate in END instead of treating PR creation as the only closing ritual
- **#127** — Tighten the EXECUTE contract so version bump and release proposal are always surfaced before completion
- **#49** — Enforce the single-task-per-cycle rule in IDLE and ANALYZE to prevent scope drift
- **#60** — Support explicit cross-repo dependency chains when one cycle depends on upstream work in another repo
- **#50** — Support dual-language configuration for user-facing outputs

### Product and platform surfaces
- **#185** — Introduce an `iq skill` module to manage Inquiry CLI private skills instead of leaving Inquiry-specific skills as static deployed markdown only
- **#183** — Publish Inquiry CLI to WinGet
- **#170** — Add `--version` / `-v` on bare `iq`
- **#153** — Redesign the Inquiry website around the current product identity
- **#151** — Add `iq auth` with GitHub-backed user profile and authentication context
- **#149** — Improve VS Code workspace discovery for multi-root and non-trivial repository layouts

### Research and measurement
- **#156** — Add GitHub platform usage metrics to the research dataset
- **#147** — Extend deep research beyond the current standalone `research` skill into a broader source-gathering capability
- **#141** — Centralize metrics in a database-backed store once the current file-based evidence stops being sufficient

## Foundations already landed

Several roadmap items from the early v0.0.x planning era are no longer near-term because they already shipped and now belong to the current baseline:

- **END state landed**: the FSM now includes END as the explicit PR gate between EXECUTE and EVOLUTION/IDLE (#63)
- **Backward transitions landed**: `PLAN → ANALYZE`, `EXECUTE → ANALYZE`, and the illegal `EVOLUTION + block` combination were implemented through the #64 / #65 line of work
- **Cycle memory landed**: the `.inquiry/` lifecycle and evolution-note memory model from the old #47 / #48 framing are part of the current repository contract
- **EVOLUTION internalization landed**: DARWIN's pass no longer depends on ad hoc human intervention in the way the old #57 backlog item described
- **Metrics foundation landed**: `metrics.yaml` collection exists and is no longer a speculative near-term item (#72)
- **Research delegation groundwork landed**: the original ANALYZE delegation concern from #46 is now complemented by the standalone `research` skill introduced later in the project

## Mid-term (v0.1.x → v0.5.0)

Larger features that require infrastructure from the near-term to land first. Not yet split into discrete issues.

Viewed through the harness framing above, these mid-term items are best understood as **harness completion work**: first-class memory tooling, first-class task orchestration, target reactivation, and comparative validation across hosts.

### `iq memory` CLI
First-class commands for the Memory-as-Code spec:
- `iq memory query` — index-aware lookup over `docs/`
- `iq memory validate` — schema enforcement (this is where **BORGES** materializes as a skill, not a separate agent)
- `iq memory write` — guided creation of new memory artifacts

### `iq task` CLI
Replace the manual `gh issue create / gh pr create / gh pr merge` dance with a single command per FSM transition. Currently the agent calls `gh` directly; `iq task` would wrap that with prechecks (issue exists, branch matches issue number, no scope drift per #49).

### Multi-target reactivation
The deferred half of [ADR D20](spec/target-specific-agents.md). Adapters already exist for Claude Code, Crush, Codex, and Gemini — they just aren't wired into `iq target get`. Reactivation requires:
1. Stable agent prompt API (so the same APE methodology runs identically across hosts)
2. A test matrix that runs the same APE cycle against multiple targets
3. Comparative metrics on top of the foundation already landed in #72

### Antifragility validation harness
A test rig that runs N identical APE cycles against M targets (Copilot, Crush, Claude Code, and similar hosted surfaces) and aggregates `metrics.yaml` to test how well the same philosophical-methodological discipline survives tool changes and operational constraints.

## Long-term (v1.0+)

Theses that take the project beyond a CLI tool.

### Philosophical and Methodological Consolidation
A mature statement of Inquiry as a doctrine for AI-assisted software work: sharpen the canonical role of Thinking Tools, clarify the Inquiry / APE / Finite APE Machine distinction, and make the philosophical lineage legible enough that the method survives changes in targets, vendors, and surrounding tooling.

### Bootstrap-validation paper
Publish the empirical paper on APE-builds-APE. Requires the existing metrics foundation from #72 plus at least 30 cycles of clean comparative data. Plan: [research/ape_builds_ape/bootstrap-validation.md](research/ape_builds_ape/bootstrap-validation.md).

### DARWIN community-level learning
Currently DARWIN proposes mutations only to *this* repo's APE. The long-term vision is a community-level DARWIN that aggregates evolution issues across many APE-using projects to propose changes upstream to the framework itself.

### Risk-matrix-driven UX
The semantic risk matrix exists in spec but not yet in CLI behavior. End-state: `iq fsm transition` automatically gates on human approval only when the risk class warrants it, and silently proceeds otherwise.

## Lore vs reality

The original [lore.md](lore.md) sketched 9+ apes. After two months of building APE with APE, the roster collapsed to a smaller live set. In the current contract, DEWEY owns IDLE triage alongside SOCRATES, DESCARTES, BASHŌ, and DARWIN. This is honest accounting, not a roadmap commitment to revive deferred ones — most other roles were absorbed by simpler operators that turned out to do the job better.

| Lore agent | Status | What happened |
|---|---|---|
| **DEWEY** | ✅ Active | IDLE — bounded issue triage and explicit handoff to `inquiry-start` |
| **SOCRATES** | ✅ Active | ANALYZE — implemented as the mayéutica agent |
| **DESCARTES** | ✅ Active | PLAN — replaces SUNZI's strategy + VITRUVIUS's WBS in one Cartesian Method |
| **BASHŌ** | ✅ Active | EXECUTE — replaces ADA's TDD with techne (functional beauty under constraints) |
| **DARWIN** | ✅ Active | EVOLUTION — implemented; produces concrete evidence (e.g. issue #54) |
| **MARCOPOLO** | Absorbed | Document and source gathering are now handled through SOCRATES plus `doc-read` and the direct-use `research` skill |
| **VITRUVIUS** | Absorbed | WBS / decomposition is part of DESCARTES's plan phase |
| **SUNZI** | Replaced | DESCARTES's Method is more explicit and testable than strategic prose |
| **GATSBY** | Absorbed | Test pseudocode lives in `plan.md` written by DESCARTES |
| **ADA** | Replaced | BASHŌ's techne replaces explicit TDD as a separate phase |
| **DIJKSTRA** | Future private skill | Quality-gate becomes a `pre-pr-review` skill inside END, not a separate agent |
| **BORGES** | Future private skill | Schema validation becomes `iq memory validate`, not a standalone ape |
| **HERMES** | Materialized | State transitions are now `iq fsm transition` (CLI command, not an agent) |

The lesson: **the framework wants fewer, sharper agents, not more**. Each absorption was driven by a real cycle where two agents were doing what one could do better.

## How this roadmap is updated

- **Near-term** items are GitHub issues in the backlog. They appear and disappear as DARWIN proposes and the maintainer accepts/rejects.
- **Mid-term** items become near-term once split into concrete issues with acceptance criteria.
- **Long-term** items are theses, not commitments. They move forward only when evidence justifies the investment.

If you want the absolute current state, run `gh issue list --state open` and `gh release list`.
