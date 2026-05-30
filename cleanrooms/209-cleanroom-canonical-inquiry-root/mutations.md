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
| H4 | Cycle runtime and CLI config separate cleanly | PENDING | Phase 4 |
| H5 | status lifecycle expressible without persisting IDLE | PENDING | Phase 5 |
| H6 | Discovery degrades safely at the edges | CONFIRMED | Phase 2: no-cycle (non-git / detached HEAD) resolves to derived IDLE without error; load returns IDLE on missing/malformed state |
| H7 | Extension can follow CLI resolution | PENDING | Phase 7 |

## Decisions

- U1 (config.yaml location): PENDING — Phase 4.
- U2 (status ownership): PENDING — Phase 5.
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
