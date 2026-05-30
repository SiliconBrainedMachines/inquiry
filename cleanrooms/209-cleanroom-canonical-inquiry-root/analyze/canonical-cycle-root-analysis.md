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

The right design target is:

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
- stays local to a single cycle
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

The next step is a concrete specification of:

- cycle layout
- state schema
- active cycle resolution rules
- migration boundaries from current `.inquiry/*` behavior