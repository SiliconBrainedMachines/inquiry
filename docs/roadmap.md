# Roadmap

> This roadmap is the forward-looking companion to [architecture.md](architecture.md).
> The 0.6.x consolidation cycle is complete. 0.7.x should optimize for clarity, leverage, and focused expansion instead of carrying historical planning baggage.

## Vision

Inquiry aims to be a **small, explicit, repository-local harness for AI-assisted software work**. Three theses guide the 0.7.x line:

1. **Thinking tools make AI usable.** Model quality matters, but raw capability does not solve the core bottleneck by itself. Inquiry's wager is that AI gives renewed practical force to more than 2,500 years of philosophical labor: disciplined questioning, decomposition, inference, verification, and selection become operational tools for software work.
2. **Memory as code.** Project knowledge belongs in the repo, version-controlled, queryable by any agent — not in a cloud-hosted vector DB.
3. **Antifragility.** Each cycle should leave APE measurably better. DARWIN turns operational friction into improvements to the framework itself.

The end-state is an **Inquiry that compounds operational evidence into a better harness**, without bloating itself into a generic platform too early.

## 0.7.x baseline

The current baseline after 0.7.0 is:

- explicit task contract fields in `inquiry-context`
- evidence-first ANALYZE with diagnosis structure and evidence gating
- explicit context-policy and authoritative handoff rules
- visible sensor stack and deterministic END gate
- trace and overhead evidence for transitions, retries, host activity, and model-bound prompt assembly

This baseline is not the next project; it is the floor for 0.7.x.

## 0.7.x priorities

### 1. Keep the harness small and explicit

0.7.x should resist speculative surface area. Inquiry should stay legible: few commands, explicit state, inspectable prompts, durable artifacts, and no hidden orchestration magic.

### 2. Strengthen host-boundary portability

The next meaningful frontier is not more doctrine; it is a cleaner adapter contract across hosts so the same Inquiry runtime can be compared and reused with less glue.

### 3. Turn observability into practical tuning

0.6.x made overhead visible. 0.7.x should use that evidence to reduce waste: repeated rereads, noisy retries, unclear blocks, and host-boundary cost that can be better separated or reported.

### 4. Clarify product surfaces without reviving the archive

The repository should emphasize the current runtime, website, extension, and release surfaces. Historical planning material, exploratory doctrine, and completed transition baggage should stay out of the main navigation.

### 5. Keep EVOLUTION evidence-backed

DARWIN should continue to propose changes from concrete cycle evidence, not from taste, narrative drift, or nostalgia for earlier architecture.

## Deferred work that still matters

These remain real possibilities, but they should land only when the harness earns them:

- multi-host reactivation
- `iq task` and stronger issue/PR wrapping
- richer host-side telemetry when the platform exposes it
- more opinionated website and distribution surfaces
- durable metrics backends beyond local YAML when a real consumer exists

### Dogfood-surfaced (2026-07)

Concrete friction from real use (two live requirements; see
[field-evidence-dogfood-2026-07](../code/paper/field-evidence-dogfood-2026-07.md)):

- **`issue publish --plan` should validate labels** against the target repo and, when a
  label is missing, print the `gh label create …` command to create it. Currently the check
  fails late at `--apply`. *Carried over to MACSS, which now owns that command.*
- **`requisitions/` lifecycle — RESOLVED (2026-07).** Requisitions moved to
  **`docs/requisitions/<YYYYMMDD>-<slug>/`** (documentation, like ADRs; the date prefix sorts
  chronologically) and are **git-ignored as a local authoring workspace** — the durable
  artifacts are the published GitHub issues (+ code + tests carrying the spec→issue→test spine).
  That removes the accumulation problem from the repo entirely. *(These commands moved to
  MACSS in 0.22.0; the pointer is now `.macss/specification.yaml`.)* `specification new` records
  the **active requisition**, so `issue new` / `specification check` / `issue publish` are
  **slug-less** (with a `--slug` override). Deferred:
  an explicit `active/` vs `archive/` split if a team later wants selected requisitions tracked.

## Anti-goals for 0.7.x

- carrying historical planning files as if they were still live doctrine
- reopening already-closed 0.6.x consolidation questions as if they were unresolved
- inflating the agent roster instead of sharpening the current operators
- adding infrastructure just because it is architecturally imaginable

## How to read the repo now

If you want to understand Inquiry today, read [architecture.md](architecture.md).

If you want to understand where Inquiry should go next, read this roadmap.

If a historical artifact is not part of those two surfaces or the live code and tests, it should not be treated as current doctrine.

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

Viewed through the harness framing above, these mid-term items are best understood as **harness completion work**: first-class memory tooling, first-class task orchestration, host reactivation, and comparative validation across hosts.

### `iq memory` CLI
First-class commands for the Memory-as-Code spec:
- `iq memory query` — index-aware lookup over `docs/`
- `iq memory validate` — schema enforcement (this is where **BORGES** materializes as a skill, not a separate agent)
- `iq memory write` — guided creation of new memory artifacts

### `iq task` CLI
Replace the manual `gh issue create / gh pr create / gh pr merge` dance with a single command per FSM transition. Currently the agent calls `gh` directly; `iq task` would wrap that with prechecks such as task existence, branch/task identity coherence, and no scope drift under the single-task rule.

### Multi-host reactivation
The deferred half of [ADR D20](spec/host-specific-agents.md). Adapters already exist for Claude Code, Codex, Gemini, and OpenCode — they just aren't wired into `iq host get`. Reactivation requires:
1. Stable agent prompt API (so the same APE methodology runs identically across hosts)
2. A test matrix that runs the same APE cycle against multiple hosts
3. Comparative metrics on top of the foundation already landed in #72

### Antifragility validation harness
A test rig that runs N identical APE cycles against M hosts (Copilot, OpenCode, Claude Code, and similar hosted surfaces) and aggregates `metrics.yaml` to test how well the same philosophical-methodological discipline survives tool changes and operational constraints.

## Long-term (v1.0+)

Theses that take the project beyond a CLI tool.

### Philosophical and Methodological Consolidation
A mature statement of Inquiry as a doctrine for AI-assisted software work: sharpen the canonical role of Thinking Tools, clarify the Inquiry / APE / Finite APE Machine distinction, and make the philosophical lineage legible enough that the method survives changes in hosts, vendors, and surrounding tooling.

### Bootstrap-validation paper
Publish the empirical paper on APE-builds-APE once the project has enough clean comparative cycle evidence and a stable publication plan.

### DARWIN community-level learning
Currently DARWIN proposes mutations only to *this* repo's APE. The long-term vision is a community-level DARWIN that aggregates evolution issues across many APE-using projects to propose changes upstream to the framework itself.

### Risk-matrix-driven UX
The semantic risk matrix exists in spec but not yet in CLI behavior. End-state: `iq fsm transition` automatically gates on human approval only when the risk class warrants it, and silently proceeds otherwise.

## Lore vs reality

The original [lore.md](lore.md) sketched 9+ apes. After two months of building APE with APE, the roster collapsed to a smaller live set. In the current contract, DEWEY owns IDLE triage alongside SOCRATES, DESCARTES, ADA, and DARWIN. This is honest accounting, not a roadmap commitment to revive deferred ones — most other roles were absorbed by simpler operators that turned out to do the job better.

| Lore agent | Status | What happened |
|---|---|---|
| **DEWEY** | ✅ Active | IDLE — bounded issue triage and explicit handoff to `inquiry-start` |
| **SOCRATES** | ✅ Active | ANALYZE — implemented as the mayéutica agent |
| **DESCARTES** | ✅ Active | PLAN — replaces SUNZI's strategy + VITRUVIUS's WBS in one Cartesian Method |
| **ADA** | ✅ Active | EXECUTE — programming-manifesto cognition for bounded construction and review |
| **DARWIN** | ✅ Active | EVOLUTION — implemented; produces concrete evidence (e.g. issue #54) |
| **MARCOPOLO** | Absorbed | Document and source gathering are now handled through SOCRATES plus `doc-read` and the direct-use `research` skill |
| **VITRUVIUS** | Absorbed | WBS / decomposition is part of DESCARTES's plan phase |
| **SUNZI** | Replaced | DESCARTES's Method is more explicit and testable than strategic prose |
| **GATSBY** | Absorbed | Test pseudocode lives in `plan.md` written by DESCARTES |
| **BASHŌ** | Replaced | ADA restores EXECUTE as a cognitive operator while phase contracts keep commits, release gates, and closure |
| **DIJKSTRA** | Future private skill | Quality-gate becomes a `pre-pr-review` skill inside END, not a separate agent |
| **BORGES** | Future private skill | Schema validation becomes `iq memory validate`, not a standalone ape |
| **HERMES** | Materialized | State transitions are now `iq fsm transition` (CLI command, not an agent) |

The lesson: **the framework wants fewer, sharper agents, not more**. Each absorption was driven by a real cycle where two agents were doing what one could do better.

## Design direction: a module per stage (`iq <stage> <verb>`)

Adopted 2026-07, **narrowed 0.22.0**. The CLI is being reorganized so its command
surface mirrors the cycle's stages instead of its internals. Today commands are
grouped by mechanism (`iq fsm transition`, `iq ape prompt`) — names that leak how
the engine works and force the user to translate "I want to start analyzing" into
"run an FSM transition". The direction is one **module per stage**, each with a
small set of common verbs.

**The scope of "stage" is now the implementation stage only.** Requisition,
specification, issue, verification and deploy belong to
[MACSS](https://github.com/ccisnedev/macss), which owns the lifecycle; inquiry is
the state machine that drives an already specified issue. This roadmap no longer
plans `iq requisition` or `iq specification` modules — building them would
re-absorb what 0.22.0 deliberately handed over.

- `iq implementation`, `iq analyze`, `iq plan`, `iq execute` — one module each.
- Shared verbs where they make sense: `start` (enter the stage),
  `skill` (show the stage's operating instruction), `check` (run the stage gate).
  e.g. `iq analyze start`, `iq analyze skill`, `iq plan check`.
- Every argument explicit and named: `--issue 40`, not a positional. A required
  input is declared `required`, so the CLI refuses to run without it.

**`iq implementation start --issue <N>` is the first module built to this
pattern** (issue #295): it replaces the cryptic `iq cycle start 40` and folds the
whole manual bootstrap (slug + branch + cleanroom + transition) into one explicit
command. It is the template the remaining stages migrate toward — incrementally,
each stage keeping its old command working until its module lands.

Two principles this direction locks in (see the `mejora-ux` requisition):
- **Every mechanical process is an `iq` command**, never an instruction that has
  the model run `git`/`mkdir`/write scaffold by hand.
- **Commands are not flow-aware**: they do their job and report it; they do not
  print a "next step" that would bias what the user does next.

## How this roadmap is updated

- Keep this file forward-looking.
- Move completed work into code, tests, release notes, or the architecture document.
- Avoid recreating historical planning layers once the runtime has already made the decision concrete.

If you want the absolute current execution state, read [architecture.md](architecture.md), the active release surface, and the live code and tests.
