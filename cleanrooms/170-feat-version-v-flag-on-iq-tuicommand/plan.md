---
id: plan
title: "Plan"
date: 2026-06-04
status: complete
tags: [plan, execution-ready]
---

# Plan

## Diagnosis decisions this plan assumes

- `cleanrooms\170-feat-version-v-flag-on-iq-tuicommand\analyze\diagnosis.md` resolved the user-visible semantics: root `--version` and `-v` must converge with the existing `iq version` surface.
- The same diagnosis established that the failure happens before `TuiCommand`, because the router rejects flagged root invocations before the empty route can dispatch.
- `iq` with no args must remain the banner/TUI surface, and `iq version` remains the dedicated version-printing command.
- The external `cli_router` locus carries more dependency risk than a local CLI entry-surface change, so this plan uses the local normalization path in `code\cli\lib\inquiry_cli.dart`.

## Shared interface / type-shape impact

- No shared interface or type-shape change is planned for this packet.
- `TuiInput`, `TuiOutput`, `VersionInput`, and `VersionOutput` should remain unchanged; the bounded work is root-argument normalization plus regression coverage.
- Because no shared type shape is expected to change, there is no constructor-site inventory requirement for this packet.

## Phase dependencies

- Phase 1 -> Phase 2 -> Phase 3
- Phase 1 defines the bounded RED signal in `code\cli\test\version_test.dart` for root `--version` / `-v`.
- Phase 2 turns that bounded target GREEN through the local CLI entry-surface normalization path already chosen above.
- Phase 3 is the exact packet stop line: verify root `--version` / `-v` dispatch in the same worktree state, then run the full suite.

## Approval gate

- [ ] Explicit user approval of this `cleanrooms\170-feat-version-v-flag-on-iq-tuicommand\plan.md` is recorded before any EXECUTE handoff.

## Phase 1 — Add bounded regression coverage for the alias contract

**Entry criteria**

- Diagnosis decisions above are the planning baseline.
- Existing version coverage lives in `code\cli\test\version_test.dart`.
- No shared interface or type changes are required.

**Dependencies**

- None.

**Execution steps**

- [ ] Extend `code\cli\test\version_test.dart` so the bounded stop-line target directly covers root `--version` / `-v` aliasing.
- [ ] Import and exercise `normalizeInquiryArgs(...)` from `code\cli\lib\inquiry_cli.dart` so the test defines the root-dispatch expectation before implementation.
- [ ] Keep the coverage anchored to the existing `VersionCommand` / `inquiryVersion` contract from `diagnosis.md`; do not invent a separate root-output contract.

**Verification**

- [ ] Source review of `code\cli\test\version_test.dart` shows direct alias assertions for `--version` and `-v`, plus unchanged semantic anchors for `VersionCommand(VersionInput())` and `inquiryVersion`.
- [ ] On the pre-implementation worktree, `dart test test\version_test.dart` is expected to fail on the new alias assertions and nowhere else, providing the RED signal for this packet.

**Test definition (pseudocode)**

```text
group 'root version aliases':
  expect(normalizeInquiryArgs(['--version']), ['version'])
  expect(normalizeInquiryArgs(['-v']), ['version'])
  expect(normalizeInquiryArgs(['version']), ['version'])
  expect(normalizeInquiryArgs([]), [])
  expect(normalizeInquiryArgs(['fsm', 'state']), ['fsm', 'state'])

group 'version command contract':
  output = await VersionCommand(VersionInput()).execute()
  expect(output.exitCode, 0)
  expect(output.version, inquiryVersion)
  expect(output.version, isNotEmpty)
```

**Risk notes**

- Coverage that skips the root-alias helper would leave the dispatch regression unprotected.
- Pulling full process execution into the unit test would widen flakiness beyond the minimal deterministic RED signal needed here.

## Phase 2 — Normalize root version aliases at the CLI entry surface

**Entry criteria**

- Phase 1 has defined the bounded alias contract in `code\cli\test\version_test.dart`.
- `code\cli\lib\inquiry_cli.dart` still normalizes only `--help` and `-h`.
- Current runtime behavior for `dart run bin\main.dart --version` and `dart run bin\main.dart -v` is still the diagnosis failure mode.

**Dependencies**

- Phase 1.

**Execution steps**

- [ ] Extend `code\cli\lib\inquiry_cli.dart` so a single root argument of `--version` or `-v` rewrites to `['version']`, matching the existing `--help` / `-h` normalization pattern.
- [ ] Keep the rewrite scoped to the single-argument root case so `iq`, `iq version`, and other module or flag invocations preserve current routing behavior.
- [ ] Leave `code\cli\lib\modules\global\commands\tui.dart`, `code\cli\lib\modules\global\commands\version.dart`, and the external `cli_router` dependency unchanged for this packet.

**Verification**

- [ ] Source review shows `runInquiry()` still performs exactly one normalization pass before `cli.run(...)`, rewriting only the single-root-argument `--version` and `-v` cases while leaving `[]`, `['version']`, and unrelated multi-token inputs unchanged.
- [ ] In the post-implementation worktree, `dart test test\version_test.dart` passes, proving the alias normalization turns the Phase 1 RED signal GREEN without changing the named `iq version` contract.

**Test definition (pseudocode)**

```text
expect(normalizeInquiryArgs(['--version']), ['version'])
expect(normalizeInquiryArgs(['-v']), ['version'])
expect(normalizeInquiryArgs(['version']), ['version'])
expect(normalizeInquiryArgs([]), [])
expect(normalizeInquiryArgs(['fsm', 'state']), ['fsm', 'state'])
expect(run('dart test test\version_test.dart').exitCode, 0)
```

**Risk notes**

- Over-broad normalization could accidentally rewrite non-root or multi-token invocations.
- A router-level fix would widen the blast radius into external dependencies; this phase intentionally avoids that path.

## Phase 3 — Verify root `--version` / `-v` dispatch in the same worktree state and run the full suite

**Entry criteria**

- Phase 1 bounded RED coverage and Phase 2 GREEN implementation are in place.
- The packet stop line remains root `--version` / `-v` dispatch to the existing `iq version` surface defined in `diagnosis.md`.
- The bounded packet still excludes version bump, changelog work, docs cleanup, release, PR, merge, and broader router or TUI redesign.
- `iq` with no args remains outside the changed path and should behave as before.

**Dependencies**

- Phase 2.

**Execution steps**

- [ ] From `code\cli`, record the current worktree state once and keep it unchanged throughout this phase's verification commands.
- [ ] In that same worktree state, run `dart run bin\main.dart version` to capture the existing version-surface baseline required by `diagnosis.md`.
- [ ] In that same worktree state, run `dart run bin\main.dart --version` and capture exit code plus stdout.
- [ ] In that same worktree state, run `dart run bin\main.dart -v` and capture exit code plus stdout.
- [ ] In that same worktree state, run `dart test test\version_test.dart` as the packet-local regression check.
- [ ] Without any intervening worktree edits, run `dart test` as the required final full-project verification step.

**Verification**

- [ ] In one unchanged worktree state, `dart run bin\main.dart --version` exits `0` and matches `dart run bin\main.dart version`.
- [ ] In that same unchanged worktree state, `dart run bin\main.dart -v` exits `0` and matches `dart run bin\main.dart version`.
- [ ] In that same worktree state, `dart test test\version_test.dart` passes.
- [ ] In that same worktree state, `dart test` passes.
- [ ] The worktree state recorded before the phase still matches after the last command, proving the stop-line checks ran on one consistent implementation state.

**Test definition (pseudocode)**

```text
baselineStatus = run('git status --short')
named = run('dart run bin\main.dart version')
long = run('dart run bin\main.dart --version')
short = run('dart run bin\main.dart -v')
packetRegression = run('dart test test\version_test.dart')
fullSuite = run('dart test')
finalStatus = run('git status --short')

expect(named.exitCode, 0)
expect(long.exitCode, 0)
expect(short.exitCode, 0)
expect(trim(long.stdout), trim(named.stdout))
expect(trim(short.stdout), trim(named.stdout))
expect(packetRegression.exitCode, 0)
expect(fullSuite.exitCode, 0)
expect(finalStatus.stdout, baselineStatus.stdout)
```

**Risk notes**

- Full-suite failures may expose pre-existing instability unrelated to this packet, but they still block completion per the runtime contract.
- Runtime output comparisons can catch newline or formatting regressions that pure unit assertions might miss.
- Splitting the alias runtime checks and full-suite run across different edit states would weaken stop-line evidence, so this phase keeps them in one worktree state.
