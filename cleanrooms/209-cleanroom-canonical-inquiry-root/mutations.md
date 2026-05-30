# Mutations — Issue #209

Cycle notebook for EXECUTE. Records baselines, decisions (U1–U3), and the
hypothesis ledger (H1–H7) as evidence accumulates.

## Baseline (Phase 0)

- Dart SDK 3.11.5 (stable), windows_x64.
- Full CLI suite green before any change: **379 tests passing**.
- The existing 379 tests serve as the characterization net for H1.

## Hypothesis ledger

| ID | Statement | Status | Deciding evidence |
|----|-----------|--------|-------------------|
| H1 | Centralized resolution is behavior-preserving | CONFIRMED | Phase 1: +7 resolver tests green, existing suite unchanged (386 total) |
| H2 | State can be cycle-local with IDLE derived | CONFIRMED | Phase 2: state at `cleanrooms/<branch>/.iq.state.yaml`, IDLE derived from `status: completed`/no-cycle, never persisted; full suite green (393) |
| H3 | IDLE→ANALYZE is a sufficient bootstrap | CONFIRMED | Phase 3: transition materializes analyze/index.md + confirmations.md + issue.md mirror + `.iq.state.yaml` (status active, state ANALYZE); freshly created cycle resolves as active; suite green (397) |
| H4 | Cycle runtime and CLI config separate cleanly | CONFIRMED | Phase 4: cycle-scoped `mutations.md` moves to `cleanrooms/<branch>/`; project-scoped `config.yaml` stays at `.inquiry/` (U1); CLI + VS Code extension both resolve cycle-local mutations; metrics writers made dir-self-sufficient; CLI suite green (397) + extension unit suite green (69) |
| H5 | status lifecycle expressible without persisting IDLE | CONFIRMED | Phase 5: `active` (update_state non-IDLE), `completed` (update_state→IDLE), `blocked` (pause_analysis/pause_plan effects) fully cover the lifecycle; centralized in `_markStatus`; `load()` derives IDLE for completed+blocked; full suite green (400) |
| H6 | Discovery degrades safely at the edges | CONFIRMED | Phase 2: no-cycle (non-git / detached HEAD) resolves to derived IDLE without error; load returns IDLE on missing/malformed state |
| H7 | Extension can follow CLI resolution | CONFIRMED | Phase 7: VS Code extension drives off cycle resolution — `resolveStatePath` → `cleanrooms/<branch>/.iq.state.yaml` (null→IDLE); status bar watches `cleanrooms/**/.iq.state.yaml` and re-resolves per refresh; `parseState` derives IDLE for `status: completed`/`blocked`; activationEvents add `workspaceContains:cleanrooms/`; unit suite green (74) + integration green (13) |

## Decisions

- U1 (config.yaml location): **DECIDED — option (b): keep `.inquiry/config.yaml`
  at `project_root`.** Rationale: `config.yaml` holds *project-scoped* settings
  (the `evolution.enabled` toggle), not cycle runtime, so leaving it at repo-level
  `.inquiry/` does **not** violate H4 ("nothing *cycle-scoped* lives at repo-level
  `.inquiry/`"). Experiment outcome: enumerating the three consumers —
  CLI `_readEvolutionEnabled` (`state.dart`), `init` (`init.dart`), VS Code
  `toggleEvolution` (`commands.ts`) — they all already resolve `.inquiry/config.yaml`;
  keeping that path yields **zero special cases** and the fewest moving parts, which
  is the deciding criterion. `inquiryCliRoot` remains `project_root`; only
  *cycle-scoped* `mutations.md` moves to `cleanrooms/<branch>/`.
- U2 (status ownership): **DECIDED — one effect owns each `status` write.**
  - `active`: owned by `update_state` — every non-IDLE transition writes `status: active`
    (already in place since Phase 2).
  - `completed`: owned by `update_state` when the target is IDLE — `updateState('IDLE')`
    → `_markCompleted()` (END→IDLE `pr_ready`/`pr_ready_no_evolution`, EVOLUTION→IDLE
    `finish_evolution` via `close_cycle`). Already in place since Phase 2.
  - `blocked`: owned by the **`pause_analysis` / `pause_plan`** effects (the CLI side of the
    `block` event, ANALYZE→IDLE and PLAN→IDLE). These run *after* `update_state` in
    `executeAll`, so `_markBlocked()` overrides the default `completed` that
    `updateState('IDLE')` writes. The pause effect is the single owner of the `blocked` write.
  - Refactor: `_markCompleted`/`_markBlocked` share a private `_markStatus(status)` helper
    (centralized status mutation, one place).
  - `load()` derives IDLE for BOTH `completed` and `blocked` (the FSM target of every
    closing/pausing transition is IDLE; IDLE is never persisted). The `status` value in the
    file records *why* the cycle left an active phase. A `blocked` cycle is **not closed**
    (its branch still resolves and its cleanroom artifacts remain on disk for resumption),
    but its derived FSM phase is IDLE — consistent with the transition contract.
- U3 (metrics action): PENDING — Phase 8.

## Phase log

### Phase 1 — CycleContext resolver (behavior-preserving)

- Added `getProjectRoot` to `lib/src/git_utils.dart` (git `rev-parse --show-toplevel`).
- Added `lib/src/cycle_context.dart`: `CycleContext` + `CycleResolutionException`.
  - Resolves `projectRoot`, `branch`, `inquiryRoot` (`cleanrooms/<branch>/`),
    `inquiryCliRoot`.
  - `normalizeBranch`: empty/`HEAD` → null (derived IDLE).
  - Outside git → throws; branch with `/` or `\` → throws.
- Not yet wired into command paths (deliberately behavior-preserving).
- Tests: `test/cycle_context_test.dart` (7). Full suite: 386 green. `dart analyze` clean.

### Phase 2 — Cycle-local state with derived IDLE

- `lib/modules/ape/inquiry_state.dart`: rewritten.
  - `const kStateFileName = '.iq.state.yaml';`
  - `stateFileFor(workingDir)`: resolves cycle via `CycleContext`; returns
    `<inquiryRoot>/.iq.state.yaml` or null (no cycle).
  - `loadFrom(path)`: pure file read; missing/malformed → `InquiryState(state: 'IDLE')`.
  - `load(workingDir)`: no cycle → IDLE; `status: completed` → derived IDLE (issue null).
  - `saveTo`/`save`: write `version/state/issue/prompt_fragment_id/status/ape/created_at/updated_at`.
  - Added fields: `version`, `status`, `createdAt`, `updatedAt`; `copyWith` with `clearApe`.
- `lib/modules/fsm/effect_executor.dart`: `updateState('IDLE')` now `_markCompleted()`
  (sets `status: completed`, clears APE) — IDLE is **never persisted**. dewey on IDLE is
  **derived** at query time, not written.
- `lib/modules/fsm/commands/transition.dart`: `_resolveIssue`/`_isIssueSelected`/
  `_loadCurrentState` now read via `InquiryState.load` (cycle-local).
- mutations/metrics/config stay at `.inquiry/` (deferred to Phase 4/8).
- Tests: added `test/support/cycle_fixture.dart`; repaired legacy tests to git-init a born
  branch and write/read cycle-local state. Removed obsolete "activates dewey on IDLE" test
  (dewey now derived). Full suite: **393 green**. `dart analyze` clean.
- **H2 CONFIRMED**, **H6 CONFIRMED**.

### Phase 3 — Bootstrap on IDLE→ANALYZE

- `lib/modules/fsm/effect_executor.dart`: `openAnalysisContext()` now also writes a
  best-effort `cleanrooms/<branch>/issue.md` mirror (F7).
  - New `typedef IssueBodyProvider = String? Function(String issue, String workingDirectory);`
    injected via the constructor; default runs `gh issue view <n> --json body -q .body`.
  - Body fetch is **best-effort**: failure/empty → mirror still written with metadata and a
    placeholder note (non-fatal).
  - **Idempotent**: existing `issue.md` is never clobbered.
- The `.iq.state.yaml` (status `active`, state `ANALYZE`) and analyze bootstrap files were
  already produced by `updateState` + `openAnalysisContext` (Phase 2); Phase 3 closes the gap
  with the issue mirror and an end-to-end bootstrap assertion.
- Tests: 3 new `effect_executor_test` cases (mirror with body / null body non-fatal /
  no-clobber) + 1 `fsm_transition_integration_test` end-to-end bootstrap. Full suite:
  **397 green**. `dart analyze` clean.
- **H3 CONFIRMED**.

### Phase 4 — Separate cycle mutations (cycle-local) from config (CLI root)

- `lib/modules/fsm/effect_executor.dart`:
  - `resetMutations()` now writes to `_mutationsPath()` instead of `.inquiry/mutations.md`.
  - New `_mutationsPath()`: `cleanrooms/<branch>/mutations.md` when on a born branch,
    else falls back to `.inquiry/mutations.md` (no-cycle edge).
  - **Regression fix**: `resetMutations` previously created `.inquiry/` as a side effect that
    `snapshotMetrics`/`collectMetrics` implicitly relied on. With mutations now cycle-local,
    both metrics writers `createSync(recursive: true)` their `.inquiry/` dir before writing.
    (Metrics *location* unchanged — Phase 8 territory; this only restores the dir guarantee.)
- `lib/modules/ape/commands/prompt.dart`: darwin runtime context `mutations_file` →
  `cleanrooms/<branch>/mutations.md`, `state_file` → `cleanrooms/<branch>/.iq.state.yaml`.
  `metrics_*` paths stay `.inquiry/...` (Phase 8).
- VS Code extension (per user requirement — the add-mutation command must target the
  cycle-local ledger):
  - New `code/vscode/src/cycle.ts`: `resolveBranch(workspaceFolder)` (git
    `rev-parse --abbrev-ref HEAD`; null on no-repo / `HEAD` / slashed branch) and
    `resolveMutationsDir(workspaceFolder)` → `cleanrooms/<branch>` or `.inquiry` fallback.
  - `extension.ts`: `inquiry.addMutation` now resolves `resolveMutationsDir(workspaceFolder)`
    at invocation time instead of the fixed `.inquiry` path. `toggleEvolution` still targets
    `.inquiry/config.yaml` (U1).
  - `commands.ts`: `addMutation` `mkdirSync(recursive)` before append (robust when the
    cycle dir is resolved fresh).
  - Tests: new `test/unit/cycle.test.ts` (5 cases, real git repos). Extension unit suite: **69 green**.
- Tests: `effect_executor_test` reset_mutations/executeAll repointed cycle-local;
  `ape_prompt_test` darwin assertions repointed. CLI suite: **397 green**. `dart analyze` clean.
- **H4 CONFIRMED**.

### Phase 5 — status lifecycle wiring (active / completed / blocked)

- Decision U2 recorded above (single owner per status write).
- `lib/modules/ape/inquiry_state.dart`: `load()` now derives IDLE for `status: blocked`
  as well as `completed` (both target IDLE; IDLE never persisted).
- `lib/modules/fsm/effect_executor.dart`:
  - Refactored `_markCompleted()` and new `_markBlocked()` to share a private
    `_markStatus(status)` (centralized terminal-status write; clears APE; no-op when already
    at that status).
  - `executeAll` now handles the `pause_analysis` / `pause_plan` effects (block event,
    ANALYZE→IDLE / PLAN→IDLE) → `_markBlocked()`. These run *after* `update_state`, so they
    override the default `completed` that `updateState('IDLE')` writes — the pause effect is
    the single owner of the `blocked` write.
- Tests: `inquiry_state_test` "load returns IDLE when cycle status is blocked"; 2
  `effect_executor_test` block cases (pause_analysis / pause_plan → blocked + derived IDLE).
  CLI suite: **400 green**. `dart analyze` clean.
- **H5 CONFIRMED**.

### Phase 6 — `iq init` + `.gitignore` aligned with cycle-local model

- `lib/modules/global/commands/init.dart`:
  - Removed `_ensureStateYaml` and `_ensureMutationsMd` — init no longer scaffolds
    repo-level `.inquiry/state.yaml` or `.inquiry/mutations.md` (cycle runtime is
    materialized per cycle under `cleanrooms/<branch>/` by the FSM).
  - `_ensureGitignore` now ensures **two** entries idempotently: `.inquiry/` and
    `cleanrooms/**/.iq.state.yaml` (F6 — derived cycle state never tracked).
  - `_ensureConfigYaml` keeps `.inquiry/config.yaml` (project-scoped, U1) and now creates
    `.inquiry/` itself when absent (previously relied on the removed state step).
  - Steps renumbered 1–4; doc comment updated.
- Real repo `.gitignore`: added `cleanrooms/**/.iq.state.yaml` (no state file was tracked).
- Tests: removed obsolete `.inquiry/state.yaml` (2) and `.inquiry/mutations.md` (2) groups;
  added `ignores cycle-local state files under cleanrooms/` + a `cycle-local model` group
  (no repo-level state.yaml / mutations.md); idempotency test trimmed to gitignore+config.
  CLI suite: **399 green**. `dart analyze` clean.
- **H4 CONFIRMED** (init alignment — nothing cycle-scoped scaffolded at repo-level `.inquiry/`).

### Phase 7 — VS Code extension follows cycle resolution

- `src/cycle.ts`: new `resolveStatePath(workspaceFolder)` → `cleanrooms/<branch>/.iq.state.yaml`
  on a valid branch, else `null` (no git / unborn / detached / slashed branch → caller IDLE).
- `src/parsers.ts`: `parseState` now reads `status` and derives IDLE for `completed`/`blocked`,
  mirroring the CLI's `InquiryState.load()` (IDLE never persisted).
- `src/status-bar.ts`: no longer hardcodes `.inquiry/state.yaml`. `refresh()` re-resolves the
  cycle state path each time (IDLE when `null`); the `FileSystemWatcher` follows the cycle
  pattern `cleanrooms/**/.iq.state.yaml`. `toggleEvolution` stays on `.inquiry/config.yaml` (U1).
- `package.json`: `activationEvents` adds `workspaceContains:cleanrooms/` (keeps `.inquiry/` for config).
- Tests: `state-parser` +3 (active keeps phase; completed/blocked derive IDLE); `cycle` +2
  (`resolveStatePath` valid branch / null outside git); status-bar integration repointed to a
  real git cycle workspace via new `createCycleWorkspace` helper, +1 case (completed→IDLE in bar).
  Unit suite **74 green**; integration **13 green**; `tsc` clean.
- **H7 CONFIRMED** (extension resolves cycle state exactly like the CLI; degrades to IDLE at the edges).
