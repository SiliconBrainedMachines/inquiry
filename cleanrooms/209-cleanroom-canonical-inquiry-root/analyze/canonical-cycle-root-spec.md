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

It defines the target contract being evaluated, not already-implemented behavior.

## 1. Definitions

### 1.1 `project_root`

The git repository root of the current checkout or worktree.

`project_root` owns:

- source code
- repository documentation
- repository-level assets
- repository configuration
- git branch identity

### 1.2 `inquiry_root`

The canonical root directory of one active or historical cycle.

Canonical value:

`cleanrooms/<branch>/`

The cleanroom directory name **is** the current branch name, formatted
`<issue>-<slug>` (e.g. `209-cleanroom-canonical-inquiry-root`). The directory name
must be a single filesystem-safe path segment (no `/`). The bare word "slug" is
not used to mean the directory.

### 1.3 `inquiry_cli_root`

The root where Inquiry is installed/initialized for the project. It owns general
CLI configuration (`config.yaml`), which is **not** cycle runtime state.

The model therefore has three distinct roots:

- `project_root` — the git repository / worktree
- `inquiry_root` — the active cycle, `cleanrooms/<branch>/`
- `inquiry_cli_root` — the CLI/project-level config home for `config.yaml`

### 1.4 Active cycle

A cycle is active when repository context resolves to one concrete `inquiry_root` whose state indicates a live FSM state.

### 1.5 Derived `IDLE`

`IDLE` is the state returned when no active cycle resolves from the current repository context.

`IDLE` is an FSM state but not part of a persisted APE cycle. It is never stored
inside a cycle-local state file. When `iq fsm state` returns `IDLE` it dispatches
the IDLE sub-agent (DEWEY), whose only role is to create atomic, well-scoped
issues. A cycle only comes into existence at the IDLE→ANALYZE transition.

## 2. Canonical cycle layout

### 2.1 Required files

```text
cleanrooms/<branch>/
├── .iq.state.yaml      (ephemeral, gitignored)
├── analyze/
│   ├── index.md
│   ├── confirmations.md
│   ├── diagnosis.md
│   └── <other analysis docs>
├── plan.md
└── mutations.md
```

### 2.2 Recommended files

```text
cleanrooms/<branch>/
└── issue.md            (local mirror of the GitHub issue body)
```

`issue.md` is downloaded at cycle bootstrap so the cleanroom is self-explanatory
when reopened and ANALYZE does not depend on the network or `gh`. It is
recommended, not a hard precondition for the FSM.

### 2.3 Optional files

```text
cleanrooms/<branch>/
├── retrospective.md
└── pr.md
```

Optional means:

- not required to initialize a cycle
- only created when the workflow actually reaches the phase that needs them

Metrics files (`metrics.snapshot.yaml`, `metrics.yaml`) are out of scope for this
cycle; metrics are not yet consumed by the workflow and are deferred to a
dedicated metrics cycle.

### 2.4 Tracking and gitignore

Whether a cleanroom corpus is tracked is a per-repository preference. In this
repository cleanrooms are tracked as research artifacts. Independently of that
preference, ephemeral runtime state must never be committed:

```gitignore
cleanrooms/**/.iq.state.yaml
```

Tracked: `issue.md`, `analyze/*`, `plan.md`, `mutations.md`, `retrospective.md`,
`pr.md`. Ignored: `.iq.state.yaml`.

## 3. State file

### 3.1 Filename

Canonical name:

`.iq.state.yaml`

Rationale:

- explicit runtime meaning
- local to a single cycle
- avoids collision with future tracked project-level `inquiry.yaml`

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

Result: `IDLE` (DEWEY dispatched)

### 5.2 Repository with many historical cleanrooms

Result:

- active cycle resolves only if branch or cwd-contained explicit context identifies one
- otherwise `IDLE`

### 5.3 Repository on a feature branch with matching cleanroom

Result:

- the matching cleanroom is the active cycle

### 5.4 Edge cases

- Outside a git repository → hard, explicit error (not silent `IDLE`). `iq doctor`
  already requires git.
- Detached HEAD (branch resolves to `HEAD`) → derived `IDLE`, since no
  `<issue>-<slug>` branch resolves.
- Branch names with `/` → forbidden by the `<issue>-<slug>` convention; the
  directory name must be a single path segment.

### 5.5 Cycle bootstrap (IDLE→ANALYZE)

The transition IDLE→ANALYZE is the only moment a cycle is materialized:

1. optionally create a worktree
2. checkout the `<issue>-<slug>` branch
3. create `cleanrooms/<branch>/` with initial files (`issue.md`,
   `analyze/index.md`, `analyze/confirmations.md`)
4. write the first `.iq.state.yaml` with `status: active`

### 5.6 Status lifecycle

`status` has a closed value set:

- `active` — a live cycle, `fsm_state` in ANALYZE..EVOLUTION
- `completed` — set when the cycle exits via END→IDLE or EVOLUTION→IDLE
- `blocked` — optional, a cycle parked via the `block` event

Because `IDLE` is derived and never persisted, a closed cycle is simply one whose
branch no longer resolves as active and/or whose `.iq.state.yaml` reads
`completed`.

## 6. Issue and PR mirrors

### 6.1 `issue.md`

`issue.md` should exist as a local mirror of the cycle's GitHub issue context.

Purpose:

- stable local reference for title, number, URL, and scope
- analysis can proceed without repeated GitHub fetches
- the cleanroom remains self-explanatory when reopened later

### 6.2 `pr.md`

`pr.md` should be optional and created only when END produces or links a real pull request.

Before that moment it should not be required.

## 7. Migration consequences

This is a pre-1.0 (v0.x.x) project with no external users. The migration is a
clean **breaking change**: the old surface is replaced, with no dual-source-of-truth
precedence rule.

The following current behaviors would be replaced:

- repo-level `.inquiry/state.yaml` reads and writes → cycle-local `.iq.state.yaml`
- prompt context that still injects `.inquiry/mutations.md` → cycle-local `mutations.md`
- `config.yaml` → moved to `inquiry_cli_root` (CLI/project-level config), not a cycle
- extension activation tied to `workspaceContains:.inquiry/` → driven by the same
  context resolution `iq fsm state` performs
- any command that treats cwd as both `project_root` and `inquiry_root`

Metrics surfaces are explicitly excluded from this migration.

## 8. Invariants

1. Every active cycle has exactly one canonical `inquiry_root`.
2. `project_root` and `inquiry_root` are distinct concepts even when invoked from the same cwd.
3. `IDLE` is derived, not stored in a cycle-local state file.
4. Historical cleanrooms must not create ambiguous automatic selection.
5. The CLI must remain usable from any cwd inside the repository or worktree.

## 9. Open questions

1. Exact `inquiry_cli_root` resolution: where `config.yaml` physically lives after
   `.inquiry/` shrinks (project-level `inquiry.yaml`?), and how it is discovered.
2. Does the future command surface need `iq cycle list`, `iq cycle show`, and
   `iq cycle resume` to surface resumable cycles after branch/directory desync?
3. Should END persist additional closure artifacts beyond `pr.md`?
4. Exact `status` transition wiring (who sets `completed`/`blocked`, and when) —
   to be finalized in PLAN.