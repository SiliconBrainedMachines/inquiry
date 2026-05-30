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

### 3. `project_root` remains necessary

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

Resolved during ANALYZE (see confirmations F6–F17):

1. `issue.md` — recommended local mirror, generated at bootstrap (not a hard precondition).
2. `pr.md` — optional until END creates a pull request.
3. `config.yaml` — belongs to a third root, `inquiry_cli_root` (CLI/project-level config), not a cycle.
4. Metrics — out of scope for this cycle; deferred.

Remaining for PLAN:

- exact `inquiry_cli_root` resolution and `config.yaml` location
- exact `status` transition wiring

## Inputs to planning

Planning should define:

- the exact `.iq.state.yaml` schema
- the canonical cycle layout
- the precise discovery algorithm
- the migration boundary from `.inquiry/*` to cycle-local state