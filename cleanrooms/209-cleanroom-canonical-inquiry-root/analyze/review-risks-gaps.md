---
id: review-risks-gaps
title: "Review — Contradictions, Inconsistencies, Gaps, Risks"
date: 2026-05-30
status: active
tags: [review, risks, gaps, architecture, inquiry-root]
author: socrates
---

# Review — Contradictions, Inconsistencies, Gaps, Risks

This document audits the current cycle material (`issue.md`, `diagnosis.md`,
`canonical-cycle-root-analysis.md`, `canonical-cycle-root-spec.md`,
`confirmations.md`) against the real CLI behavior in the codebase.

Each finding is grounded in a concrete source where possible.

## A. Contradictions (must resolve)

### C1: `.inquiry/` is gitignored, but cleanrooms are committed

This is the most important issue.

- `iq init` adds `.inquiry/` to `.gitignore` and treats it as ephemeral runtime
  (`code/cli/lib/modules/global/commands/init.dart`, step 2 `_ensureGitignore`).
- The FSM transition stages and commits cleanroom files
  (`code/cli/lib/modules/fsm/commands/transition.dart` stages
  `cleanrooms/<branch>/analyze` and `cleanrooms/<branch>/plan.md`).

Consequence: placing `.iq.state.yaml` **inside** `cleanrooms/<slug>/` would make
runtime state **git-tracked by default**, the opposite of the current
intentionally-ignored runtime model. The user explicitly wants this state file
to remain gitignored.

Required decision: the spec must define a gitignore rule such as
`cleanrooms/**/.iq.state.yaml` (and any other runtime files like
`metrics.snapshot.yaml`) so that the cleanroom corpus stays tracked while
cycle-local runtime state stays ignored.

Status: the spec does not currently address this. Blocking.

### C2: `issue.md` is both "required" and "open question"

- `canonical-cycle-root-spec.md` section 2.1 lists `issue.md` under **Required files**.
- `diagnosis.md` open question #1 and spec section 6.1 still treat it as undecided
  ("should exist", "Should `issue.md` be mandatory?").

Required decision: pick one. Recommended: keep `issue.md` required, and remove it
from the open-questions list, or downgrade it to "recommended" consistently.

## B. Inconsistencies (terminology / internal)

### I1: `slug` vs `branch` used interchangeably

- Spec uses `cleanrooms/<slug>/` as the canonical root (sections 1.2, 2).
- Spec discovery uses `cleanrooms/<branch>/.iq.state.yaml` (section 4.2).
- The real implementation names the directory after the **branch**, and the branch
  convention is `<NNN>-<slug>` (`code/cli/assets/instructions/issue-start.md`,
  steps 3–5; `effect_executor.dart` builds `cleanrooms/<branch>/analyze`).

So in practice the directory name equals the branch name, which is `NNN-slug`.
The word "slug" is ambiguous: sometimes it means only the text after `NNN`,
sometimes the whole `NNN-slug`.

Required fix: define one canonical term. Recommended: the cleanroom directory name
is exactly the branch name `<NNN>-<slug>`, and discovery matches on that branch
name. Avoid using bare "slug" to mean the directory.

### I2: "live FSM state other than derived IDLE"

Spec 1.3 says an active cycle has a "live FSM state other than derived IDLE", but
spec 3.3 already forbids storing `IDLE` in `.iq.state.yaml`. The qualifier is
redundant and slightly confusing. Minor wording fix.

## C. Gaps (missing specification)

### G1: gitignore handling for cycle-local runtime (ties to C1)

No rule defines which cycle files are tracked vs ignored. Needed:

- tracked: `issue.md`, `analyze/*`, `plan.md`, `mutations.md`, `retrospective.md`, `pr.md`
- ignored: `.iq.state.yaml`, `metrics.snapshot.yaml`, possibly `metrics.yaml`

### G2: `config.yaml` has no destination

`evolution.enabled` is read from `.inquiry/config.yaml`
(`code/cli/lib/modules/fsm/commands/state.dart` `_readEvolutionEnabled`).
The spec never says where repo policy/config goes after `.inquiry/` shrinks.
It is hinted only as open question #1 ("tracked project-level `inquiry.yaml`").

Needed: decide whether `config.yaml` becomes a tracked `inquiry.yaml` at
`project_root`, and add it to the migration list.

### G3: extension activation marker not replaced

`code/vscode/package.json` activates on `workspaceContains:.inquiry/`.
The spec lists this in migration consequences but does not define the replacement
marker (e.g., `cleanrooms/` or a project-level `inquiry.yaml`).

### G4: first-transition bootstrap is unspecified

During IDLE there is no cycle root yet. The IDLE→ANALYZE transition must create
`cleanrooms/<branch>/` and write the first `.iq.state.yaml`. The spec describes
discovery and steady state, but not who creates the state file on the first
transition, nor the exact write sequence.

### G5: cycle closure / archival lifecycle

When a cycle finishes (END/EVOLUTION) and especially after the branch is deleted:

- discovery by branch will stop matching (good, becomes history),
- but `.iq.state.yaml` may still say `status: active` and `fsm_state: EVOLUTION`.

Needed: define a closure rule (e.g., set `status: completed` at END/EVOLUTION exit)
and the meaning of `status`. The `status` field values are never enumerated.

### G6: cross-cycle metrics destination

EVOLUTION currently reads `.inquiry/mutations.md`, `.inquiry/state.yaml`,
`.inquiry/metrics_snapshot.yaml` and writes `.inquiry/metrics.yaml`
(`code/cli/assets/fsm/states/evolution.yaml`). Moving everything cycle-local
leaves cross-cycle aggregation undefined. The spec defers to #141 but does not
state where aggregated/cross-cycle evidence lives in the meantime.

### G7: non-git and detached-HEAD behavior

Discovery says "resolve project_root using git" and "resolve current branch", but:

- outside a git repo, `git rev-parse --show-toplevel` fails,
- in detached HEAD, `git rev-parse --abbrev-ref HEAD` returns `HEAD`.

Needed: define behavior for both (likely: error clearly / treat as `IDLE`,
since `iq doctor` already requires git).

### G8: branch names with slashes

If a branch is `feature/foo`, the cleanroom path becomes nested
`cleanrooms/feature/foo/`. The `NNN-slug` convention avoids slashes, but the spec
should state the constraint that the branch (hence directory) must be a single
filesystem-safe path segment.

### G9: `status` field semantics

`status: active` appears in the schema but its allowed values and transitions are
undefined (active / completed / blocked / abandoned?). Tied to G5.

## D. Risks (operational)

### R1: migration window with two sources of truth

During migration, both repo-level `.inquiry/state.yaml` and cycle-local
`.iq.state.yaml` may exist. Without a clear precedence rule and a one-time
migration step, `iq fsm state` could read stale state. Needs explicit precedence
and a migration/upgrade path.

### R2: branch rename or cleanroom rename desync

Discovery binds the active cycle to `branch == directory name`. If a user renames
the branch but not the directory (or vice versa), the cycle silently becomes
unresolvable (falls back to IDLE). This is safer than guessing, but should be
documented and ideally surfaced as a hint ("resumable cycles exist").

### R3: hidden file ergonomics

`.iq.state.yaml` is hidden while siblings (`issue.md`, `plan.md`, `pr.md`) are
visible. Intentional, but mixed visibility should be documented so users and tools
do not assume the directory is empty of runtime state.

### R4: auto-generated index is hardcoded

`effect_executor.openAnalysisContext()` writes an `index.md` that lists only
`confirmations.md`. Any spec that promises a richer required layout must also
update index generation, or the generated index will understate the corpus.

## E. What still needs to be specified

1. Gitignore policy for cycle-local runtime files (C1/G1). Blocking.
2. Destination of `config.yaml` / project policy (`inquiry.yaml`?) (G2).
3. Replacement activation marker for the VS Code extension (G3).
4. First-transition bootstrap sequence for `.iq.state.yaml` (G4).
5. `status` field value set and closure lifecycle (G5/G9).
6. Cross-cycle metrics destination, even if interim (G6).
7. Non-git / detached-HEAD / slashed-branch edge rules (G7/G8).
8. Migration precedence between old and new state during upgrade (R1).
9. Canonical term: directory name == branch name `<NNN>-<slug>` (I1).
10. Resolve `issue.md` required-vs-optional contradiction (C2).

## F. What is already solid

- `cleanrooms/<slug>/` as canonical `inquiry_root` (confirmations F1).
- `project_root` and `inquiry_root` as distinct concepts (F2).
- `IDLE` as derived, not persisted (F3).
- Deterministic, branch-first discovery with cwd convenience fallback (F4).
- `.iq.state.yaml` as the state filename candidate (F5), pending the gitignore
  decision in C1.

## Recommended next move

Resolve C1 and C2 first, because they change the spec's required-files table and
the gitignore contract. The remaining gaps (G2–G9, R1) are best closed in PLAN as
explicit acceptance criteria rather than reopened as free debate.

---

## Resolution status (2026-05-30)

User decisions applied to `confirmations.md` (F6–F17) and the spec.

| Item | Status | Resolution |
|------|--------|------------|
| C1 | RESOLVED | Cleanrooms stay tracked (repo preference); ephemeral `.iq.state.yaml` gitignored via `cleanrooms/**/.iq.state.yaml` (F6). |
| C2 | RESOLVED | `issue.md` is a recommended local mirror of the GitHub issue, generated at bootstrap (F7). |
| I1 | RESOLVED | Directory name == branch name == `<issue>-<slug>` (F8). |
| I2 | RESOLVED | IDLE is FSM-only, derived, dispatches DEWEY (F9). |
| G1 | RESOLVED | Gitignore policy defined in spec §2.4 (F6). |
| G2 | OPEN → PLAN | Third root `inquiry_cli_root` owns `config.yaml`; exact location is open question #1 (F10). |
| G3 | RESOLVED (direction) | Extension activation follows `iq state` context resolution (F11). |
| G4 | RESOLVED | Bootstrap == IDLE→ANALYZE transition; spec §5.5 (F12). |
| G5/G9 | RESOLVED (analysis) | `status` value set + closure defined; exact wiring → PLAN (F16, spec §5.6). |
| G6 | OUT OF SCOPE | Metrics deferred; removed from layout/migration (F13). |
| G7/G8 | RESOLVED | Non-git → hard error; detached HEAD → IDLE; slashes forbidden; spec §5.4 (F17). |
| R1 | RESOLVED | Breaking change, pre-1.0, no migration window (F14). |
| R2 | ACCEPTED RISK | Branch/dir desync hardened via tests in EXECUTE (F15). |
| R3 | NOTED | Mixed visibility documented. |
| R4 | RESOLVED | Generated index is updated by the process as docs are added. |
