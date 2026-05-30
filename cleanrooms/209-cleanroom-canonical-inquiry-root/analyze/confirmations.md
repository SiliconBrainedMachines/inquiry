---
id: confirmations
title: "Confirmations"
date: 2026-05-30
status: active
tags: [confirmations, findings]
---

# Confirmations

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: cleanrooms/<slug>/ should be the canonical inquiry_root — CONFIRMED

The cycle needs one explicit home for analysis, diagnosis, plan handoff, and cycle-local runtime surfaces. Using `cleanrooms/<slug>/` gives the same conceptual model in worktree-first and non-worktree usage.

## F2: project_root and inquiry_root must be resolved separately — CONFIRMED

The current CLI overloads `workingDirectory` for repository root, cycle root, git execution base, and runtime state lookup. That coupling is the structural source of cwd sensitivity.

## F3: IDLE should be derived rather than persisted inside a cycle root — CONFIRMED

`IDLE` describes the absence of a resolved active cycle in the current repository context. It is not a property of a specific cleanroom directory.

## F4: active cycle discovery should be deterministic and branch-first — CONFIRMED

Repositories may legitimately contain many historical cleanrooms. The CLI should resolve the active cycle by branch first, then cwd-contained convenience, and never by hidden global memory or timestamp guessing.

## F5: .iq.state.yaml is the strongest current filename candidate — CONFIRMED

The active cycle state file should be explicit, cycle-scoped, and distinct from any future tracked project manifest. `.iq.state.yaml` best matches those constraints among the names discussed so far.

## F6: ephemeral cycle state must be gitignored even inside a tracked cleanroom — CONFIRMED

Tracking the cleanroom corpus is a per-repository preference. In this repository it is valuable (it records how the system solves problems), so cleanrooms stay tracked. But ephemeral runtime state must never be committed. Therefore `.iq.state.yaml` (and any future ephemeral runtime file) must be excluded via a pattern such as `cleanrooms/**/.iq.state.yaml`, regardless of whether the surrounding cleanroom is tracked.

## F7: issue.md is a recommended local mirror of the GitHub issue — CONFIRMED

The issue body already lives in GitHub. `issue.md` is a downloaded local cache so the cleanroom is self-explanatory when reopened and ANALYZE does not depend on the network or `gh`. It is recommended (generated at cycle bootstrap), not a hard precondition for the FSM to function. This resolves former open question C2/diagnosis Q1.

## F8: the cleanroom directory name equals the branch name — CONFIRMED

Canonical term, fixed: the cleanroom directory name **is** the current branch name, formatted `<issue>-<slug>` (e.g., `209-cleanroom-canonical-inquiry-root`). The ambiguous bare word "slug" is no longer used to mean the directory. Discovery matches `cleanrooms/<branch>/`. Issue-number padding (3 vs 4 digits) is a cosmetic sort choice and does not change the rule. This resolves inconsistency I1.

## F9: IDLE is an FSM state but not part of the internal APE cycle — CONFIRMED

IDLE belongs to the FSM, not to a persisted cycle. When no cycle resolves from repository context, `iq fsm state` returns IDLE and dispatches the IDLE sub-agent (DEWEY). DEWEY's only job in IDLE is to create atomic, well-scoped issues. Only when the user expresses intent to work on a specific issue does the system transition to ANALYZE. This resolves inconsistency I2.

## F10: there is a third root — the CLI installation/config root — CONFIRMED

`config.yaml` is general CLI configuration, not cycle runtime state. It belongs at the root where Inquiry is installed/initialized (`inquiry_cli_root`), not inside a cycle. The model therefore has three distinct roots: `project_root` (repository), `inquiry_root` (the active cycle = `cleanrooms/<branch>/`), and `inquiry_cli_root` (CLI/project-level config home for `config.yaml`).

## F11: extension activation must follow what `iq state` detects — CONFIRMED

The VS Code extension must stop activating on the hardcoded marker `workspaceContains:.inquiry/`. Activation should be driven by the same context resolution that `iq fsm state` performs (presence of a resolvable Inquiry context, e.g., `cleanrooms/`), so the extension and the CLI agree on a single source of truth.

## F12: the IDLE→ANALYZE bootstrap is the only cycle-creation moment — CONFIRMED

IDLE persists nothing. The transition IDLE→ANALYZE is what materializes a cycle: optionally create a worktree, checkout the `<issue>-<slug>` branch, create `cleanrooms/<branch>/` with initial files (`issue.md`, `analyze/index.md`, `analyze/confirmations.md`), and write the first `.iq.state.yaml`. This resolves gap G4: there is no separate bootstrap to specify beyond this transition.

## F13: cross-cycle metrics are out of scope for this cycle — CONFIRMED

Metrics are not yet consumed by the workflow. `metrics.snapshot.yaml` / `metrics.yaml` are removed from the required and optional layout for #209 and excluded from migration scope. They can be reintroduced by a dedicated metrics cycle (#141) later.

## F14: this is a breaking change; no migration window is required — CONFIRMED

The project is pre-1.0 (v0.x.x) with no external users. The migration from repo-level `.inquiry/state.yaml` to cycle-local `.iq.state.yaml` is a clean breaking change. No dual-source-of-truth precedence rule is needed (resolves R1); the old surface is simply replaced.

## F15: branch/directory desync is a development-time test risk, not a design hole — CONFIRMED

Renaming a branch without renaming its cleanroom (or vice versa) makes the cycle fall back to IDLE. This is acceptable (safe over guessing) and is to be hardened through extensive testing during EXECUTE, not by adding inference. Tracks R2.

## F16: status lifecycle of .iq.state.yaml must be enumerated — CONFIRMED (needs PLAN detail)

The `status` field needs a defined, closed value set and closure rules. Proposed set: `active` (a live cycle, fsm_state in ANALYZE..EVOLUTION), and `completed` (set when the cycle exits via END→IDLE or EVOLUTION→IDLE). Optional `blocked` may mark a cycle parked via the `block` event. Because IDLE is derived and never persisted, a "closed" cycle is simply one whose branch no longer resolves as active and/or whose `.iq.state.yaml` reads `completed`. Exact transitions belong to PLAN. Resolves G5/G9 at the analysis level.

## F17: non-git / detached-HEAD / slashed-branch edges resolve to IDLE or hard error — CONFIRMED

`iq doctor` already requires git, so discovery may assume a git repo. Specified behavior: outside a git repository → hard, explicit error (not silent IDLE). Detached HEAD (branch resolves to `HEAD`) → derived IDLE, since no `<issue>-<slug>` branch resolves. The `<issue>-<slug>` convention forbids slashes, so nested `cleanrooms/feature/foo/` cannot occur; the spec states the directory name must be a single filesystem-safe path segment. Resolves G7/G8.
*** Add File: c:\Users\44358590\Code\silicon-brained-machines\inquiry\cleanrooms\209-cleanroom-canonical-inquiry-root\issue.md
---
id: issue-209-reference
title: "Issue #209 Reference"
date: 2026-05-30
status: active
tags: [issue, reference, architecture, inquiry-root]
author: socrates
---

# Issue #209

## Metadata

- Number: 209
- Title: architecture: make cleanrooms/<slug> the canonical inquiry root with cycle-local state
- URL: https://github.com/ccisnedev/inquiry/issues/209

## Summary

This cycle specifies the architectural shift from a repo-level active runtime state toward a cycle-local root under `cleanrooms/<slug>/`.

The issue consolidates the main pressures already visible in:

- #150 — `mutations.md` belongs with the active cleanroom
- #178 — `iq` must stop depending on ambient cwd to resolve context
- worktree-first usage — ignored runtime files do not carry over across newly created worktrees

## Scope

The issue is about cycle-root architecture and active-cycle resolution.

It is not, by itself, approval to implement the full migration in one step.
*** Add File: c:\Users\44358590\Code\silicon-brained-machines\inquiry\cleanrooms\209-cleanroom-canonical-inquiry-root\analyze\diagnosis.md
---
id: diagnosis
title: "Diagnosis — canonical cycle root and active cycle resolution"
date: 2026-05-30
status: active
tags: [diagnosis, architecture, inquiry-root, cleanroom]
author: socrates
---

# Diagnosis

## Problem

The current CLI binds too many responsibilities to one implicit cwd-derived `workingDirectory`.

Today that single value is used as though it were all of the following at once:

- repository root
- runtime state root
- cleanroom root
- asset/config lookup base
- git command execution base

That is why the current runtime is brittle when cwd drifts and why the repo-level `.inquiry/` directory remains overloaded.

## Main findings

### 1. The cycle needs a canonical local root

The strongest candidate is `cleanrooms/<slug>/`.

That gives one visible and durable home for the active inquiry in both modes:

- worktree-first usage
- standard single-worktree repository usage

### 2. `IDLE` should be derived

`IDLE` should not be stored inside a cycle-local state file.

Instead, `IDLE` should mean:

> no active cycle resolves from the current repository context

### 3. project_root remains necessary

Accepting `cleanrooms/<slug>/` as `inquiry_root` does not remove `project_root`.

The CLI still needs repository-level resolution for:

- source tree lookup
- asset loading
- repository configuration
- branch discovery
- transition prechecks outside the cleanroom

### 4. Active cycle resolution must be deterministic

The active cycle should be discovered by rule, not by hidden memory.

Preferred order:

1. resolve `project_root`
2. resolve current branch
3. if `cleanrooms/<branch>/.iq.state.yaml` exists, use it
4. else if cwd is already inside a valid cleanroom root, use it as a convenience rule
5. else return `IDLE`

## Working conclusion

The cleanest target architecture is:

- `project_root` stays explicit
- `inquiry_root` becomes `cleanrooms/<slug>/`
- active cycle state moves into `.iq.state.yaml` inside that root
- `IDLE` becomes derived instead of persisted in a root-level singleton

## Open design questions

1. Should `issue.md` be mandatory as a local mirror of the issue context?
2. Should `pr.md` remain optional until END creates a pull request?
3. Should any tracked project-level `inquiry.yaml` exist for policy, separate from cycle runtime state?
4. Which currently weak metrics surfaces should remain in the minimal first migration?

## Inputs to planning

Planning should define:

- the exact `.iq.state.yaml` schema
- the canonical cycle layout
- the precise discovery algorithm
- the migration boundary from `.inquiry/*` to cycle-local state
*** Add File: c:\Users\44358590\Code\silicon-brained-machines\inquiry\cleanrooms\209-cleanroom-canonical-inquiry-root\analyze\canonical-cycle-root-analysis.md
---
id: canonical-cycle-root-analysis
title: "Canonical Cycle Root Analysis"
date: 2026-05-30
status: active
tags: [analysis, architecture, cleanroom, inquiry-root]
author: socrates
---

# Canonical Cycle Root Analysis

## Origin

This analysis started from issue #150, which asked whether `mutations.md` should move from `.inquiry/` into the cleanroom, and expanded into a broader architectural question:

- where should the active cycle actually live?
- what should remain project-scoped?
- how should the CLI know whether it is inside a live inquiry or merely inside a repository with old cleanrooms?

The current cycle for issue #209 reframes that broader question around an explicit target: `cleanrooms/<slug>/` as the canonical inquiry root.

## Core conclusion

The right design target is no longer "keep `.inquiry/`, but reduce it".

The stronger and cleaner target is:

- `cleanrooms/<slug>/` is the canonical root of a cycle
- active cycle state is local to that root
- `project_root` remains explicit for repository operations
- `IDLE` is derived when no active cycle resolves

## Why this is better than cwd-based state

It preserves an explicit home for the inquiry without forcing the user to invoke `iq` from one special directory.

This distinction matters:

- `inquiry_root` is the cycle's home
- cwd is just invocation context

Once those are separated, the CLI can be robust without relying on either:

- terminal-scoped environment variables
- a hidden global memory inside the CLI

## Why this still works without worktrees

The proposal does not depend on worktrees.

In worktree-first mode:

- `project_root` is the worktree root
- `inquiry_root` is `cleanrooms/<slug>/`

In non-worktree mode:

- `project_root` is the repository root
- `inquiry_root` is still `cleanrooms/<slug>/`

That symmetry is one of the strongest arguments in favor of the model.

## Why many cleanrooms are not a problem

A repository can contain many historical cleanrooms.

That only becomes ambiguous if the CLI treats `cleanrooms/` itself as the active cycle.

Instead, the CLI should treat `cleanrooms/` as a set of possible cycle roots and resolve one active cycle deterministically from repository context.

Preferred discriminator order:

1. current branch
2. current cwd only if already inside a cleanroom root
3. explicit future selection command when heuristics are insufficient

## Why `.iq.state.yaml` is preferable to generic names

The active cycle state file should be both explicit and cycle-scoped.

Compared with candidates such as `inquiry.yaml`, `ape_cycle.yaml`, or `fsm.yaml`, `.iq.state.yaml` is currently the strongest option because it:

- says this is runtime state, not a generic manifest
- stays local to the cycle root
- avoids confusion with future tracked project-level config

## Resulting document set

The current working set for the cycle should be centered on:

- `.iq.state.yaml`
- `issue.md`
- `analyze/index.md`
- `analyze/confirmations.md`
- `analyze/diagnosis.md`
- `plan.md`
- `mutations.md`
- `pr.md` once a PR exists

Files beyond that should not become mandatory until the workflow actually consumes them.

## Next step

The next step is not more open-ended debate. It is a concrete specification of:

- cycle layout
- state schema
- active cycle resolution rules
- migration boundaries from current `.inquiry/*` behavior
*** Add File: c:\Users\44358590\Code\silicon-brained-machines\inquiry\cleanrooms\209-cleanroom-canonical-inquiry-root\analyze\canonical-cycle-root-spec.md
---
id: canonical-cycle-root-spec
title: "Canonical Cycle Root Specification"
date: 2026-05-30
status: draft
tags: [specification, architecture, inquiry-root, cleanroom]
author: socrates
---

# Canonical Cycle Root Specification

## Status

This is a working specification draft produced during ANALYZE for issue #209.

It defines the target contract being evaluated, not an already-implemented behavior.

## 1. Definitions

### 1.1 project_root

The git repository root of the current checkout or worktree.

`project_root` owns:

- source code
- repository documentation
- repository-level assets
- repository configuration
- git branch identity

### 1.2 inquiry_root

The canonical root directory of one active or historical cycle.

Target value:

`cleanrooms/<slug>/`

### 1.3 active cycle

A cycle is active when repository context resolves to one concrete `inquiry_root` whose state indicates a live FSM state other than derived `IDLE`.

### 1.4 derived IDLE

`IDLE` is the state returned when no active cycle resolves from the current repository context.

`IDLE` is not stored inside a cycle-local state file.

## 2. Canonical cycle layout

### 2.1 Required files

```text
cleanrooms/<slug>/
├── .iq.state.yaml
├── issue.md
├── analyze/
│   ├── index.md
│   ├── confirmations.md
│   ├── diagnosis.md
│   └── <other analysis docs>
├── plan.md
└── mutations.md
```

### 2.2 Optional files

```text
cleanrooms/<slug>/
├── retrospective.md
├── pr.md
├── metrics.snapshot.yaml
└── metrics.yaml
```

Optional means:

- not required to initialize a cycle
- only created when the workflow actually reaches the phase that needs them

## 3. State file

### 3.1 Filename

Canonical name:

`.iq.state.yaml`

Rationale:

- explicit runtime meaning
- local to a single cycle
- avoids collision with future project-level `inquiry.yaml`

### 3.2 Minimum schema

```yaml
version: 1
issue:
	number: 209
	slug: 209-cleanroom-canonical-inquiry-root
branch: 209-cleanroom-canonical-inquiry-root
fsm_state: ANALYZE
prompt_fragment_id: idle_to_analyze
status: active
ape:
	name: socrates
	state: clarification
created_at: 2026-05-30T12:00:00Z
updated_at: 2026-05-30T12:00:00Z
```

### 3.3 Allowed FSM states in `.iq.state.yaml`

- `ANALYZE`
- `PLAN`
- `EXECUTE`
- `END`
- `EVOLUTION`

`IDLE` must not be stored in `.iq.state.yaml`.

## 4. Active cycle discovery

### 4.1 Goal

`iq fsm state` must answer:

> does this repository context resolve to an active cycle?

### 4.2 Discovery algorithm

1. Resolve `project_root` using git.
2. Resolve current branch using git.
3. If `cleanrooms/<branch>/.iq.state.yaml` exists under `project_root`, resolve that cycle.
4. Else, if cwd is already inside a cleanroom root containing `.iq.state.yaml`, resolve that cycle as a convenience rule.
5. Else, return derived `IDLE`.

### 4.3 Non-goals for discovery

The CLI must not infer the active cycle from:

- most recent file timestamp
- most recently touched cleanroom
- hidden CLI-global memory
- terminal-scoped environment as the primary source of truth

## 5. State semantics

### 5.1 New repository, no cycle started

Result: `IDLE`

### 5.2 Repository with many historical cleanrooms

Result:

- active cycle resolves only if branch or cwd-contained explicit context identifies one
- otherwise `IDLE`

### 5.3 Repository on a feature branch with matching cleanroom

Result:

- the matching cleanroom is the active cycle

## 6. Issue and PR mirrors

### 6.1 issue.md

`issue.md` should exist as a local mirror of the cycle's GitHub issue context.

Purpose:

- stable local reference for title, number, URL, and scope
- analysis can proceed without repeated GitHub fetches
- the cleanroom remains self-explanatory when reopened later

### 6.2 pr.md

`pr.md` should be optional and created only when END produces or links a real pull request.

Before that moment it should not be required.

## 7. Migration consequences

The following current behaviors would need migration:

- repo-level `.inquiry/state.yaml` reads and writes
- prompt context that still injects `.inquiry/mutations.md`
- evolution instructions referencing repo-level metrics files
- extension activation assumptions tied to `.inquiry/`
- any command that treats cwd as both `project_root` and `inquiry_root`

## 8. Invariants

1. Every active cycle has exactly one canonical `inquiry_root`.
2. `project_root` and `inquiry_root` are distinct concepts even when invoked from the same cwd.
3. `IDLE` is derived, not stored in a cycle-local state file.
4. Historical cleanrooms must not create ambiguous automatic selection.
5. The CLI must remain usable from any cwd inside the repository or worktree.

## 9. Open questions

1. Should a tracked project-level `inquiry.yaml` exist for repository policy?
2. Which optional metrics files still deserve first-class runtime support?
3. Does the future command surface need `iq cycle list`, `iq cycle show`, and `iq cycle resume`?
4. Should END persist additional closure artifacts beyond `pr.md`?
*** Delete File: c:\Users\44358590\Code\silicon-brained-machines\inquiry\docs\research\issue-150-cleanroom-runtime-boundary-analysis.md
