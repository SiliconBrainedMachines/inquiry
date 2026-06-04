---
id: diagnosis
title: "Diagnosis"
date: 2026-06-04
status: complete
tags: [diagnosis, evidence-first]
---

# Diagnosis

## Problem defined

Issue #170 is bounded to one user-visible gap: `iq --version` and `iq -v` currently fail instead of surfacing the CLI version. The live ambiguity entering this analysis was whether those root flags should behave like the existing `iq version` surface or instead trigger some distinct root/TUI-specific behavior.

## Evidence

- `cleanrooms\170-feat-version-v-flag-on-iq-tuicommand\issue.md` defines the feature as root `--version` / `-v` support on `iq` and presents two candidate implementation loci. One rewrites to `version`; the other lets the root command accept the flags and then delegate into version handling. The issue does not describe a separate banner-mode output.
- `code\cli\lib\inquiry_cli.dart` normalizes only `--help` and `-h`. There is no equivalent normalization for `--version` or `-v`.
- `code\cli\lib\modules\global\global_builder.dart` registers two separate surfaces:
  - `''` → `TuiCommand`
  - `version` → `VersionCommand`
- `code\cli\lib\modules\global\commands\version.dart` implements `VersionCommand` as a dedicated version-printing surface that returns `inquiryVersion`.
- `code\cli\lib\modules\global\commands\tui.dart` shows that current HEAD does not yet implement the issue narrative's claimed version path:
  - `TuiInput` has no flag fields.
  - `TuiCommand.execute()` always builds the banner/diagram output.
  - There is no delegation to `VersionCommand`.
- `code\cli\README.md` documents `iq` as the TUI banner and `iq version` as the version-printing command. It does not document `iq --version` or `iq -v`.
- Direct runtime evidence re-checked from `code\cli`:
  - `dart run bin/main.dart --version` → exit `64`, `Command not found or invalid usage.` plus the generic help output.
  - `dart run bin/main.dart -v` → exit `64`, the same invalid-usage help path.
  - `dart run bin/main.dart version` → exit `0`, `version: 0.7.3`.
- Relevant bounded tests were re-run and passed:
  - `dart test test\help_command_test.dart test\tui_test.dart test\version_test.dart` → exit `0`, `All tests passed!`
  - Coverage of intent is split across help normalization, TUI banner behavior, and the `version` subcommand; there is no bounded test for root `--version` or `-v`.
- External router evidence resolved through `code\cli\.dart_tool\package_config.json`:
  - `cli_router` resolves to `C:\Users\44358590\AppData\Local\Pub\Cache\hosted\pub.dev\cli_router-0.0.3`.
  - `C:\Users\44358590\AppData\Local\Pub\Cache\hosted\pub.dev\cli_router-0.0.3\lib\src\cli_router.dart` contains `if (j == 0 && args.isNotEmpty) continue;`, which prevents flagged root invocations from dispatching to the empty-route command.

## Hypotheses

- Root `--version` / `-v` might be intended as aliases for the existing `iq version` surface.
- Root `--version` / `-v` might instead imply a distinct root/TUI-specific behavior.
- The bounded evidence resolves this in favor of the former: the repository already exposes `iq version` as the only local version-printing contract, while the corpus contains no separate root-specific version output definition.

## Adjacent perspectives

### Top-level CLI user

- The user-facing defect is inconsistency, not absence of version data. `iq --version` and `iq -v` currently fail with generic invalid-usage help, while `iq version` succeeds and prints the installed version.
- From this perspective, the CLI already knows its version; the problem is that the common root-flag affordance does not reach that existing surface.

### Command router

- The router is the first component to classify root invocations, and its empty-route guard treats any non-empty arg list as disqualifying for `''`.
- This means the failure happens before `TuiCommand` can interpret flags or before any root-command semantics can be expressed locally.

### Existing `iq version` surface

- The repository already exposes version as a named command with its own source, runtime output, and test coverage.
- Nothing in the bounded corpus defines a second output contract for root-level version requests; the observed dedicated surface is therefore the only local semantic anchor for what "show version" means.

### Bounded tests and docs

- The README teaches a clean separation: `iq` shows the banner/TUI and `iq version` prints the CLI version.
- The tests mirror that separation: help normalization is covered for `--help` / `-h`, banner behavior is covered for the root command, and the version string is covered for the `version` subcommand.
- The missing root-flag tests are therefore a coverage hole around an otherwise well-bounded CLI intent.

## Implications and consequences

- If nothing changes, `iq --version` and `iq -v` will continue to return exit `64` and generic invalid-usage help while `iq version` continues to return exit `0` and the version string. The CLI would therefore keep rejecting the shortest root-level "show version" requests even though the same information is already available through an existing command surface.
- The failure is upstream of `TuiCommand`, not inside its banner-rendering behavior. Because the router blocks flagged root invocations before the empty-route command can run, any plan that changes only `TuiInput` parsing or `TuiCommand.execute()` without also addressing dispatch or pre-dispatch normalization would leave the observed runtime defect intact.
- Leaving the bug unfixed preserves an inconsistent contract across three bounded surfaces that already exist today: `iq` with no args still shows the banner/TUI, `iq version` still prints the version, and the root flag aliases still fail as invalid usage.
- The alias path remains unprotected by direct automated coverage. If the defect is not fixed, future CLI changes can continue to ship with the root `--version` / `-v` regression observable only through manual or runtime probing.

## Decisions taken

- The final ANALYZE pass confirms the question was correctly bounded to issue #170: what user-visible meaning root `--version` / `-v` should have in relation to the already-existing `iq version` surface.
- The semantic question is resolved for planning: bounded evidence supports root `--version` / `-v` exposing the same version surface already represented by `iq version`, not a distinct root/TUI-only behavior.
- The analysis does **not** choose between the issue's two implementation loci. The bounded evidence closes the user-visible semantics, but it does not require either entry-point normalization or router/root-command dispatch as the sole valid approach.
- No better packet-local question remains. Broader CLI flag unification or router/SDK redesign would widen beyond the issue's stop line without reducing the material uncertainty left for planning.

## Constraints

- The issue narrative is partially stale relative to current HEAD. Planning cannot assume that `TuiInput` already parses version flags or that `TuiCommand` already delegates to `VersionCommand`.
- `cli_router` is an external dependency. Any plan that depends on empty-route dispatch for flagged invocations inherits dependency/versioning risk outside the local CLI package.
- `iq` with no args is already documented and tested as the banner/TUI surface. That no-args behavior is a current invariant inside the bounded scope.
- Planning must preserve the existing user-visible contracts already anchored locally: `iq` with no args remains the banner/TUI surface, and `iq version` remains the dedicated version-printing surface that root `--version` / `-v` should converge with.
- No bounded local test currently covers root `--version` / `-v`, so the failing surface is observable at runtime but not yet protected by direct automated coverage.
- The two candidate implementation loci imply different blast radii: one is local to the CLI entry surface, while the other crosses into router behavior shared through a dependency boundary. That is a planning risk distinction, not a semantic one.
- Broadening the discussion beyond root `--version` / `-v` would exceed the bounded scope and could accidentally redefine the documented contract between `iq` and `iq version`.

## Scope

### In scope

- Diagnose why root `--version` / `-v` currently fail.
- Resolve whether bounded evidence supports aliasing the existing version surface or introducing a distinct root/TUI behavior.
- Bound the implementation decision space for the next phase.

### Out of scope

- Selecting implementation option A versus option B.
- Editing code or prescribing a fix.
- Generalizing CLI flag policy or redesigning router behavior beyond the specific root `--version` / `-v` request.

## Open Questions

- None within the bounded corpus. The carried semantic ambiguity is closed, the adjacent perspectives are sufficiently covered, no better packet-local question remains, and no additional user clarification is required for this diagnosis.

## References

- [Issue](..\issue.md)
- [Confirmations](.\confirmations.md)
