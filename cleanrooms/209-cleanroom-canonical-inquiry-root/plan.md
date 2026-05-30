---
id: plan
title: "Execution Plan — Canonical Inquiry Root (Scientific / TDD)"
date: 2026-05-30
status: draft
tags: [plan, tdd, experiment, architecture, inquiry-root]
author: descartes
---

# Execution Plan — Canonical Inquiry Root

## 0. Framing

This plan implements the diagnosis in
[diagnosis.md](diagnosis.md) and the confirmed decisions in
[confirmations.md](confirmations.md) (F6–F17), refining the draft in
[canonical-cycle-root-spec.md](canonical-cycle-root-spec.md).

It is structured as a **controlled experiment**, not just a task list. The
refactor carries hypotheses that must be confirmed or refuted by tests, and
uncertainties that must be resolved by evidence. Every phase follows **TDD**
(red → green → refactor), ends with a **rigorous QA gate**, and only then a
**commit**. A **final full-suite QA** closes the cycle.

### Method

- Each phase states the hypothesis it tests and its falsification criterion.
- Tests are written **before** implementation (red), then made green.
- A phase is "done" only when its QA gate passes *and* the full existing suite
  stays green (no regression budget).
- Commits are per-phase, conventional, and never use `--no-verify`.

### Non-negotiable constraints (from PLAN operational contract)

- No code edits during PLAN. This document is the deliverable.
- The plan must include a final step that runs the **entire** project test
  suite, not only phase-specific tests.
- Each phase has explicit verification criteria.
- User approval is required before transitioning to EXECUTE.

---

## 1. Hypotheses

> Each hypothesis is falsifiable. The paired test is the instrument.

- **H1 — Centralized resolution is behavior-preserving.**
  A single `CycleContext` resolver can replace manually threaded
  `workingDirectory` path-building (`p.join(workingDirectory, '.inquiry', …)`)
  without changing any existing observable behavior.
  *Falsified if* any existing test changes meaning or the characterization suite
  diverges after introducing the resolver while still pointing at old paths.

- **H2 — State can be cycle-local with IDLE derived.**
  Active FSM state can live in `cleanrooms/<branch>/.iq.state.yaml`, and `IDLE`
  can be returned purely by *absence of resolution* (never persisted), while
  `iq fsm state` and `iq fsm transition` keep their contracts.
  *Falsified if* any state transition needs a persisted IDLE record, or if
  discovery cannot deterministically distinguish active vs idle.

- **H3 — The IDLE→ANALYZE transition is a sufficient bootstrap.**
  Materializing the cleanroom, `issue.md` mirror, initial analyze files, and the
  first `.iq.state.yaml` entirely within the IDLE→ANALYZE transition produces a
  valid, resolvable active cycle with no separate bootstrap command.
  *Falsified if* a freshly bootstrapped cycle fails discovery or precondition
  checks.

- **H4 — Cycle runtime and CLI config separate cleanly.**
  `mutations.md` (cycle-local) and `config.yaml` (`inquiry_cli_root`) can be
  separated so that nothing cycle-scoped lives at repo-level `.inquiry/`.
  *Falsified if* any consumer needs config and cycle runtime in the same root.

- **H5 — `status` lifecycle is expressible without persisting IDLE.**
  `active` / `completed` / `blocked` fully describe a cycle's lifecycle, with
  "closed" meaning *non-resolving branch and/or `status: completed`*.
  *Falsified if* a real lifecycle state cannot be represented by this set.

- **H6 — Discovery degrades safely at the edges.**
  Outside git → hard error; detached HEAD → derived IDLE; slashed branch names
  are forbidden by convention and cannot produce nested cleanroom paths.
  *Falsified if* any edge yields a wrong active cycle or a silent crash.

- **H7 — The extension can follow CLI resolution.**
  VS Code activation and status bar can be driven by the same context resolution
  (cleanrooms-based, `.iq.state.yaml`) instead of `workspaceContains:.inquiry/`.
  *Falsified if* the extension cannot detect an active cycle without `.inquiry/`.

---

## 2. Uncertainties to resolve (with experiments)

- **U1 — `inquiry_cli_root` location for `config.yaml`.**
  Candidates: (a) repo-level tracked `inquiry.yaml` at `project_root`;
  (b) keep a minimal repo-level `.inquiry/config.yaml`; (c) user-level config.
  *Experiment:* enumerate every reader/writer of `config.yaml`
  (CLI `_readEvolutionEnabled`, `init`, VS Code `toggleEvolution`) and pick the
  location that keeps all three consistent with the fewest special cases.
  *Decision recorded in Phase 4.*

- **U2 — `status` transition wiring.**
  Who sets `completed`/`blocked`, and at which effect/transition.
  *Experiment:* trace `close_cycle`, END→IDLE, EVOLUTION→IDLE, and the `block`
  event; choose the single effect that owns each write.
  *Decision recorded in Phase 5.*

- **U3 — Metrics surfaces during a breaking change.**
  Metrics are out of scope (F13) but `evolution.yaml` and `effect_executor`
  still read `.inquiry/state.yaml` / write `.inquiry/metrics*.yaml`.
  *Experiment:* confirm metrics are not consumed by any passing test or shipped
  feature; choose minimal action (repoint reads to new state path **or**
  quarantine the effects behind `evolution.enabled`) that avoids breakage
  without investing in metrics. *Decision recorded in Phase 8.*

---

## 3. Surfaces in scope (from the diagnosis map)

| Surface | File | Action |
|---|---|---|
| State load/save | `code/cli/lib/modules/ape/inquiry_state.dart` | Repoint to `.iq.state.yaml`; add `status`, `created_at`, `updated_at`, `version` |
| State query | `code/cli/lib/modules/fsm/commands/state.dart` | Use resolver; derive IDLE; read config from `inquiry_cli_root` |
| Transition | `code/cli/lib/modules/fsm/commands/transition.dart` | Use resolver; bootstrap on IDLE→ANALYZE; status writes |
| Effects | `code/cli/lib/modules/fsm/effect_executor.dart` | `update_state`, `close_cycle`, `reset_mutations` cycle-local |
| Prompt context | `code/cli/lib/modules/ape/commands/prompt.dart` | Cycle-local `mutations.md`/state paths |
| Init | `code/cli/lib/modules/global/commands/init.dart` | New gitignore rule; stop creating repo-level state/mutations |
| Branch/path | `code/cli/lib/src/git_utils.dart` | Extend with toplevel + edge handling; back `CycleContext` |
| Evolution asset | `code/cli/assets/fsm/states/evolution.yaml` | Repoint or quarantine (U3) |
| Extension | `code/vscode/src/{extension,status-bar,commands,parsers}.ts` | Resolution-driven activation + paths |

Out of scope: building a metrics system (F13); migration/back-compat shims
(F14 — clean breaking change, pre-1.0).

---

## 4. Phases

> Every phase: write failing tests → implement → refactor → QA gate → commit.
> "Full suite" = `dart test` for the CLI package and the extension test runner.

### Phase 0 — Baseline & characterization

**Goal:** lock a green baseline and capture current behavior so H1 can be judged.

- Run the full CLI suite and extension suite; record pass counts.
- Add characterization tests (if missing) that assert current observable
  outputs of `iq fsm state` and `iq fsm transition` for IDLE and a started
  cycle, so later phases can prove behavior preservation.

**QA gate:** full suite green; baseline counts recorded in `mutations.md`.
**Commit:** `test: characterize fsm state/transition baseline (#209)`

### Phase 1 — `CycleContext` resolver (H1)

**Goal:** introduce one resolver for `project_root`, current `branch`,
`inquiry_root` (`cleanrooms/<branch>/`), `inquiry_cli_root`, and derived IDLE —
**still pointing at current paths** so behavior is unchanged.

- **Red:** unit tests for the resolver:
  - resolves `project_root` via `git rev-parse --show-toplevel`
  - resolves branch via `getCurrentBranch`
  - computes `inquiry_root` = `cleanrooms/<branch>/`
  - outside git → throws explicit error (H6)
  - detached HEAD (`HEAD`) → resolves to derived IDLE (H6)
  - rejects branch names containing `/` (H6)
- **Green:** implement `CycleContext` in the CLI, backed by `git_utils`.
- **Refactor:** thread `CycleContext` through the `*Input` classes without
  changing target paths yet.

**Verification:** new resolver tests green; **all existing tests unchanged and
green** (this is the H1 instrument).
**Commit:** `feat(cli): add CycleContext resolver, behavior-preserving (#209)`

### Phase 2 — Cycle-local `.iq.state.yaml` + derived IDLE (H2, H6)

**Goal:** move active state to `cleanrooms/<branch>/.iq.state.yaml`; make IDLE
the absence of resolution.

- **Red:** tests for
  - `InquiryState.load` from cycle-local path; missing file → derived IDLE
  - new schema fields: `version`, `status`, `created_at`, `updated_at`
  - `iq fsm state` returns IDLE (DEWEY) when no cleanroom/state resolves
  - discovery: branch match → active; cwd-inside-cleanroom convenience → active;
    historical cleanrooms on `main` → IDLE
- **Green:** update `inquiry_state.dart`, `state.dart`, `effect_executor`
  `update_state`/`close_cycle` to the cycle-local path via `CycleContext`.
- **Refactor:** remove repo-level `.inquiry/state.yaml` reads/writes.

**Verification:** new tests green; updated existing tests green; characterization
outputs from Phase 0 preserved for equivalent scenarios.
**Commit:** `feat(cli): move FSM state to cycle-local .iq.state.yaml (#209)`

### Phase 3 — Bootstrap on IDLE→ANALYZE (H3)

**Goal:** the IDLE→ANALYZE transition materializes the full cycle.

- **Red:** transition tests asserting that after IDLE→ANALYZE:
  - `cleanrooms/<branch>/` exists with `analyze/index.md`, `analyze/confirmations.md`
  - `issue.md` mirror is written (recommended, F7)
  - `.iq.state.yaml` exists with `status: active`, `fsm_state: ANALYZE`
  - the freshly created cycle passes discovery and ANALYZE preconditions
- **Green:** extend the transition / `open_analysis_context` effect to bootstrap;
  fetch issue body for `issue.md` (best-effort; absence is non-fatal).
- **Refactor:** ensure idempotency (re-running does not clobber existing files).

**Verification:** bootstrap tests green; full suite green.
**Commit:** `feat(cli): bootstrap cycle on IDLE→ANALYZE transition (#209)`

### Phase 4 — Separate cycle runtime from CLI config (H4, U1)

**Goal:** `mutations.md` cycle-local; `config.yaml` at `inquiry_cli_root`.

- **Decision (U1):** record the chosen `config.yaml` location and rationale in
  `mutations.md` before implementing.
- **Red:** tests for
  - `mutations.md` resolved at `cleanrooms/<branch>/mutations.md`
  - `reset_mutations` writes cycle-local
  - prompt context (`prompt.dart`) injects cycle-local mutations/state paths
  - `_readEvolutionEnabled` reads config from `inquiry_cli_root`
- **Green:** update `effect_executor`, `prompt.dart`, `state.dart`.
- **Refactor:** delete repo-level mutations path usage.

**Verification:** new + existing tests green; full suite green.
**Commit:** `feat(cli): separate cycle mutations from CLI config root (#209)`

### Phase 5 — `status` lifecycle wiring (H5, U2)

**Goal:** implement `active` / `completed` / `blocked`.

- **Decision (U2):** record which effect owns each `status` write.
- **Red:** tests asserting
  - new cycle → `status: active`
  - END→IDLE and EVOLUTION→IDLE → `status: completed`
  - `block` event → `status: blocked`
  - a `completed` cycle no longer resolves as active (IDLE returned)
- **Green:** wire status writes into the owning effects/transitions.
- **Refactor:** centralize status mutation in one place.

**Verification:** lifecycle tests green; full suite green.
**Commit:** `feat(cli): add cycle status lifecycle (active/completed/blocked) (#209)`

### Phase 6 — `init` and `.gitignore` (H4 cont.)

**Goal:** align `iq init` with the new model.

- **Red:** `init_command_test` updates:
  - `.gitignore` contains `cleanrooms/**/.iq.state.yaml` (F6)
  - `init` no longer creates repo-level `.inquiry/state.yaml` or `mutations.md`
  - `config.yaml` created at `inquiry_cli_root`
  - `cleanrooms/` still created
- **Green:** update `init.dart` (`_ensureGitignore`, remove state/mutations
  scaffolding, relocate config).
- **Refactor:** simplify init steps.

**Verification:** init tests green; full suite green.
**Commit:** `feat(cli): align iq init with cycle-local model (#209)`

### Phase 7 — VS Code extension follows resolution (H7)

**Goal:** activation + status bar driven by resolution, not `.inquiry/`.

- **Red:** extension tests:
  - activation triggers on a workspace with `cleanrooms/` (replace
    `workspaceContains:.inquiry/`)
  - status bar reads `cleanrooms/<branch>/.iq.state.yaml`; IDLE when none
  - `addMutation` targets cycle-local `mutations.md`
  - `toggleEvolution` targets the new `config.yaml` location
- **Green:** update `extension.ts`, `status-bar.ts`, `commands.ts`, `parsers.ts`,
  and `package.json` `activationEvents`.
- **Refactor:** share a single path-resolution helper in TS.

**Verification:** extension test suite green.
**Commit:** `feat(vscode): drive activation/status from cycle resolution (#209)`

### Phase 8 — Metrics surfaces decision (U3)

**Goal:** keep metrics out of scope without leaving broken reads.

- **Decision (U3):** defer metrics by design. Do not repoint or redesign the
  metrics surfaces in this refactor; keep the existing `.inquiry/metrics*.yaml`
  behavior until Inquiry has a real consumer, a stable schema, and a clear scope
  decision (project-scoped vs cycle-scoped).
- **Red:** bounded evidence only — confirm the current repo still has writers /
  prompts / contracts for metrics, but no new cycle-root requirement that forces
  a design decision here.
- **Green:** record the deferral explicitly in the hypothesis ledger and phase
  log; leave runtime code unchanged.

**Verification:** ledger + plan updated consistently; runtime code unchanged.
**Commit:** `chore(cli): defer metrics surfaces by design (#209)`

---

## 5. Final rigorous QA (cycle gate)

Run as one block before END:

1. **Full CLI suite:** `dart test` (entire package, not phase subsets) — all green.
2. **Extension suite:** run the VS Code extension tests — all green.
3. **Static checks:** `dart analyze` clean; `dart format --set-exit-if-changed`.
4. **Manual smoke (documented in `mutations.md`):**
   - fresh repo: `iq init` → `iq fsm state` returns IDLE
   - start a cycle → `.iq.state.yaml` created, `.inquiry/state.yaml` absent
   - run `iq` from a sub-cwd and from repo root → same resolved state
   - on `main` with historical cleanrooms → IDLE
5. **Version discipline (mandatory):** bump `code/cli/pubspec.yaml`,
   `code/cli/lib/src/version.dart`, `code/site/index.html` badge; update CHANGELOG;
   confirm `version_sync_test.dart` passes.
6. **Hypothesis ledger:** in `mutations.md`, mark each of H1–H7 as
   CONFIRMED/REFUTED with the test that decided it, and record U1–U3 outcomes.

A red result at any step blocks END.

---

## 6. Dependency order & rationale

```
Phase 0 (baseline)
   └─ Phase 1 (resolver, no behavior change)   ← enables everything
        └─ Phase 2 (state cycle-local + derived IDLE)
             ├─ Phase 3 (bootstrap)            ← needs cycle-local state
             ├─ Phase 4 (mutations/config split)
             │     └─ Phase 6 (init alignment)
             └─ Phase 5 (status lifecycle)
                  └─ Phase 7 (extension)        ← reads new state shape
                       └─ Phase 8 (metrics decision)
                            └─ Final QA
```

Phase 1 is deliberately behavior-preserving so H1 isolates "did centralizing
resolution change anything?" from "did moving paths change anything?" (Phase 2).
This keeps each hypothesis independently falsifiable.

## 7. Risks & mitigations

- **R2 (branch/dir desync):** hardened by Phase 2 discovery tests and the final
  smoke test; documented as accepted operational risk (F15).
- **Breaking change blast radius:** mitigated by per-phase QA gates and the
  Phase 0 characterization net; pre-1.0 with no external users (F14).
- **Hidden `.inquiry/` reader:** mitigated by a repo-wide search for
  `.inquiry/` literals as part of Final QA step 3.

## 8. Open items deferred to EXECUTE decisions

- U1 (config location) → decided and recorded in Phase 4.
- U2 (status ownership) → decided and recorded in Phase 5.
- U3 (metrics action) → decided and recorded in Phase 8.
