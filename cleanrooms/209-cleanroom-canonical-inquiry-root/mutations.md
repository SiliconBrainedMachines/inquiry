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
| H2 | State can be cycle-local with IDLE derived | PENDING | Phase 2 |
| H3 | IDLE→ANALYZE is a sufficient bootstrap | PENDING | Phase 3 |
| H4 | Cycle runtime and CLI config separate cleanly | PENDING | Phase 4 |
| H5 | status lifecycle expressible without persisting IDLE | PENDING | Phase 5 |
| H6 | Discovery degrades safely at the edges | PARTIAL | Phase 1 resolver: outside-git throws, detached HEAD→IDLE, slashed branch rejected |
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
