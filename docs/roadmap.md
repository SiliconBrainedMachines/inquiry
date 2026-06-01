# Roadmap

> Status note: This roadmap is a strategic and partially historical planning document. It preserves backlog framing from earlier releases and should not be used as the authoritative description of the current operational model. For the current canonical explanation, see [architecture.md](architecture.md), [spec/finite-ape-machine.md](spec/finite-ape-machine.md), and [thinking-tools.md](thinking-tools.md).

> Execution note: the canonical actionable backlog for the `0.6.x` harness-consolidation series lives in [0.6.x-harness-backlog.md](0.6.x-harness-backlog.md).

> Version note: the live CLI source currently tracks `0.6.5` in [../code/cli/pubspec.yaml](../code/cli/pubspec.yaml). Public-facing version markers elsewhere in the repository may lag until the next coordinated release pass.

> Where APE is going next. For where APE is today, see [../README.md](../README.md).

> Live roster note: DEWEY now owns bounded IDLE triage in the current contract; `inquiry-start` remains the explicit handoff into ANALYZE.

This roadmap is **descriptive, not prescriptive**: it captures strategic direction, selected historical snapshots, and the long-running theses that motivate the project. The canonical current execution program for `0.6.x` lives in [0.6.x-harness-backlog.md](0.6.x-harness-backlog.md). Anything not backed by a current system surface, a concrete program block, or validated repo evidence should be read as exploratory.

## Vision

APE aims to be a **methodology for working with AI through explicit thinking tools**, robust across changing AI market conditions. Three theses guide every decision:

1. **Thinking tools make AI usable.** Model quality matters, but raw capability does not solve the core bottleneck by itself. Inquiry's wager is that AI gives renewed practical force to more than 2,500 years of philosophical labor: disciplined questioning, decomposition, inference, verification, and selection become operational tools for software work.
2. **Memory as code.** Project knowledge belongs in the repo, version-controlled, queryable by any agent — not in a cloud-hosted vector DB.
3. **Antifragility.** Each cycle should leave APE measurably better. DARWIN turns operational friction into improvements to the framework itself.

The end-state is an **APE that builds APE**: a self-improving framework where every cycle generates evidence (in `metrics.yaml`, in evolution issues, in mutations.md) that feeds the next cycle.

Recent research in [research/harness_engineering.md](research/harness_engineering.md) and [research/agent_engineering_taxonomy.md](research/agent_engineering_taxonomy.md) sharpens how this vision should be read: Inquiry is not only a methodology and not only a prompt packager. It is already becoming a **repository-local outer harness** for coding agents. The next frontier is therefore not just “more CLI features,” but the completion of that harness through better task contracts, evidence-first ANALYZE, clearer context policy, stronger sensors, and more explicit observability.

## Historical planning snapshot (v0.0.14)

- 5-state FSM with declarative transition contract (IDLE / ANALYZE / PLAN / EXECUTE / EVOLUTION)
- 9 working CLI commands across 3 modules (`global`, `target`, `state`)
- Single-target deployment (Copilot) per [ADR D20](spec/target-specific-agents.md)
- Active roster at that snapshot: SOCRATES, DESCARTES, BASHŌ, DARWIN
- 131 tests, cross-platform (Windows + Linux), 12 GitHub releases
- Empirical bootstrap underway: APE is being built using APE (see [bootstrap-validation](research/ape_builds_ape/bootstrap-validation.md))

## Current runtime snapshot (v0.6.5)

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

Read through the current harness taxonomy, Inquiry's unfinished work clusters into five core `0.6.x` program blocks plus one later extension:

1. **Task contracts** — Inquiry already assembles prompts and paths, but it still has room to become more contract-first about bounded task inputs, outputs, editable surfaces, and validation commands.
2. **Evidence-first ANALYZE** — ANALYZE and source gathering still need stronger repo-first and web-assisted rules so questioning and planning do not get ahead of observable facts.
3. **Context policy and authoritative handoffs** — Memory as Code is real, but progressive disclosure, artifact authority, and deduplication between orchestrator, sub-agents, durable artifacts, and rereads are still too implicit.
4. **Sensor stack and END discipline** — the methodology is explicit, but the catalog of local, CI, continuous, and runtime sensors is still thinner than the control model wants, especially around closure.
5. **Overhead observability and eval discipline** — the project needs repeatable measurement of tool volume, wall-clock time, cached versus uncached tokens, and process overhead so harness cost is visible and improvable.
6. **Host-boundary portability** — after the core harness is tighter, the remaining frontier is a clearer adapter contract for multi-target comparison and reactivation.

This section is strategic framing. The selective traceability snapshot below is historical context, not the canonical operating plan.

## 0.6.x completion program (0.6.5 -> 0.6.99)

The 0.6.x line should be treated as a harness-consolidation release train, not as an optimization pass. Before 0.7.0, the priority is to remove base defects, tighten evidence discipline, and reduce structural overhead in how Inquiry assembles and reuses context.

1. **Task-contract-first execution.** Inquiry should make the active task explicit through bounded inputs, outputs, editable surfaces, validation commands, and done criteria visible to the agent.
2. **Evidence-first ANALYZE.** Repo state, cleanroom artifacts, docs, tests, and targeted web research should be the default evidence base before the user is questioned.
3. **Context economy and authoritative handoffs.** Inquiry should reduce duplication between the orchestrator, sub-agents, durable artifacts, and rereads by making handoff documents authoritative instead of repeatedly reconstructing the same context.
4. **Sensor stack and END discipline.** The main closure work before 0.7.0 is explicit sensor taxonomy, visible pre-transition and pre-PR checks, and a less ritualized END path.
5. **Overhead audit as first-class evidence.** Inquiry should measure tool volume, wall-clock time, token consumption, cached share, and process overhead as explicit inputs to EVOLUTION and future harness tuning.

Deferred until after these base corrections land: configurable depth modes and explicit per-phase budgets. Those are optimization levers, not the main 0.6.x bottlenecks.

## Selective traceability snapshot for 0.6.x (non-canonical)

This section is intentionally selective. It preserves a few live implementation surfaces that historically cluster around the current frontier, but it is not the authoritative plan and should not be read as the definition of progress.

### Task Contract Foundation
- `inquiry-context` still needs a more explicit task envelope for bounded execution
- `project_root` stability remains part of prompt-delivery robustness
- single-task-per-cycle and complex workspace discovery still shape what a valid task contract means in practice
- cross-repo dependency handling remains part of contract scope, not ad hoc reasoning

### Evidence-First ANALYZE
- SOCRATES still needs tighter question relevance and clearer stop conditions
- source gathering must reach beyond the standalone `research` skill when the repo alone is insufficient
- ANALYZE should propose candidate alternatives instead of delegating ideation back to the user

### Context Policy and Authoritative Handoffs
- `diagnosis.md` and `plan.md` still need stronger authority semantics across phases
- rereads and duplicated context across orchestrator, sub-agents, and durable artifacts remain a core cost center
- first-class memory tooling remains a mid-term surface once policy is stable

### Sensor Stack and END Discipline
- pre-PR inspection must be an explicit closure mechanism, not just implied PR ritual
- release closure must stay visible before END handoff
- transition output should declare autonomous operations and blocking conditions more clearly
- document-level gates for pending work remain part of the desired closure model

### Observability and Eval Foundation
- cycle audit, platform usage metrics, and richer failure taxonomy remain core research inputs
- a stronger evidence store may be needed once file-based metrics stop being sufficient

### Adjacent but non-core surfaces
- host identity dispatch and private-skill management remain relevant to runtime polish
- product packaging, auth, website, WinGet, and dual-language output remain valuable but non-core for the harness program

## Foundations already landed

Several roadmap items from the early v0.0.x planning era are no longer near-term because they already shipped and now belong to the current baseline:

- **END state landed**: the FSM now includes END as the explicit PR gate between EXECUTE and EVOLUTION/IDLE (#63)
- **Backward transitions landed**: `PLAN → ANALYZE`, `EXECUTE → ANALYZE`, and the illegal `EVOLUTION + block` combination were implemented through the #64 / #65 line of work
- **Cycle memory landed**: the `.inquiry/` lifecycle and evolution-note memory model from the old #47 / #48 framing are part of the current repository contract
- **EVOLUTION internalization landed**: DARWIN's pass no longer depends on ad hoc human intervention in the way the old #57 backlog item described
- **Metrics foundation landed**: `metrics.yaml` collection exists and is no longer a speculative near-term item (#72)
- **Research delegation groundwork landed**: the original ANALYZE delegation concern from #46 is now complemented by the standalone `research` skill introduced later in the project

## Mid-term (late 0.6.x -> pre-0.7.0)

Larger features that require infrastructure from the near-term to land first. Not yet split into discrete issues.

Viewed through the harness framing above, these mid-term items are best understood as **harness completion work**: first-class memory tooling, first-class task orchestration, target reactivation, and comparative validation across hosts.

### `iq memory` CLI
First-class commands for the Memory-as-Code spec:
- `iq memory query` — index-aware lookup over `docs/`
- `iq memory validate` — schema enforcement (this is where **BORGES** materializes as a skill, not a separate agent)
- `iq memory write` — guided creation of new memory artifacts

### `iq task` CLI
Replace the manual `gh issue create / gh pr create / gh pr merge` dance with a single command per FSM transition. Currently the agent calls `gh` directly; `iq task` would wrap that with prechecks such as task existence, branch/task identity coherence, and no scope drift under the single-task rule.

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

- The live `0.6.x` execution program is maintained in [0.6.x-harness-backlog.md](0.6.x-harness-backlog.md).
- This roadmap keeps strategic framing, selected historical snapshots, and medium/long-term direction.
- Mid-term items mature when they become concrete specs, validated runtime surfaces, or explicit program blocks.
- Long-term items are theses, not commitments. They move forward only when evidence justifies the investment.

If you want the absolute current execution state, read [0.6.x-harness-backlog.md](0.6.x-harness-backlog.md), [architecture.md](architecture.md), and the active release surface.
