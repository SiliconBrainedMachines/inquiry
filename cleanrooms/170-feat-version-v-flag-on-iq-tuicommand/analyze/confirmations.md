---
id: confirmations
title: "Confirmations"
date: 2026-06-04
status: complete
tags: [confirmations, findings]
---

# Confirmations

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: Root version flags currently fail at runtime — CONFIRMED

- Re-checked in `code\cli\`:
  - `dart run bin/main.dart --version` -> exit `64`, prints `Command not found or invalid usage.` followed by the generic help summary.
  - `dart run bin/main.dart -v` -> exit `64`, prints the same invalid-usage help path.
  - Positive control: `dart run bin/main.dart version` -> exit `0`, prints `version: 0.7.3`.

## F2: Entry-point normalization only handles help flags — CONFIRMED

- `code\cli\lib\inquiry_cli.dart` defines `normalizeInquiryArgs`.
- Current behavior rewrites only `--help` and `-h` to `help`.
- No equivalent normalization exists for `--version` or `-v`.

## F3: A dedicated version command exists, but coverage is subcommand-only — CONFIRMED

- `code\cli\lib\modules\global\global_builder.dart` registers:
  - root command `''` -> `TuiCommand`
  - `version` -> `VersionCommand`
- `code\cli\test\version_test.dart` verifies `VersionCommand` returns `inquiryVersion`.
- No bounded local test currently verifies root-surface `--version` or `-v`.

## F4: Issue narrative about existing root flag handling is not supported by current HEAD — CONFIRMED

- `cleanrooms\170-feat-version-v-flag-on-iq-tuicommand\issue.md` states that `TuiInput.fromCliRequest()` already captures a version flag path and that `TuiCommand.execute()` already delegates to `VersionCommand`.
- Current source in `code\cli\lib\modules\global\commands\tui.dart` does not show that:
  - `TuiInput` has no `showVersion` field or flag parsing.
  - `TuiCommand.execute()` always builds the diagram output and does not delegate to `VersionCommand`.
- This invalidates the issue body as evidence about current HEAD implementation; semantic resolution therefore has to come from bounded runtime, docs, and test evidence instead.

## F5: The router currently blocks flagged root invocations before `TuiCommand` can run — CONFIRMED

- `code\cli\.dart_tool\package_config.json` resolves `cli_router` to `C:\Users\44358590\AppData\Local\Pub\Cache\hosted\pub.dev\cli_router-0.0.3`.
- In `C:\Users\44358590\AppData\Local\Pub\Cache\hosted\pub.dev\cli_router-0.0.3\lib\src\cli_router.dart`, `_dispatch()` contains:
  - `if (j == 0 && args.isNotEmpty) continue;`
- Because `iq --version` and `iq -v` pass non-empty args, the empty-route registration in `code\cli\lib\modules\global\global_builder.dart` cannot match those requests.

## F6: Bounded docs and tests define version as a separate CLI surface, not a distinct TUI mode — CONFIRMED

- `code\cli\README.md` documents `iq` as the TUI banner and `iq version` as the version-printing command.
- `dart test test\help_command_test.dart test\tui_test.dart test\version_test.dart` exits `0` with `All tests passed!`.
- `code\cli\test\help_command_test.dart` verifies only `--help` and `-h` normalization.
- `code\cli\test\tui_test.dart` verifies banner output only.
- `code\cli\test\version_test.dart` verifies only the `version` subcommand.
- No bounded local doc or test describes a root-specific version banner or mixed TUI/version behavior.

## F7: The carried semantic question is resolved by bounded evidence — CONFIRMED

- The issue body presents two implementation options, but both converge on the same user-visible intent: root `--version` / `-v` should surface version information rather than the normal TUI banner.
- The bounded corpus does not support a distinct root/TUI-specific version mode.
- What remains open is implementation locus, not semantics: entry-point normalization versus router/root-command dispatch.

## F8: Adjacent affected perspectives converge on the same bounded diagnosis — CONFIRMED

- Top-level CLI user perspective:
  - `iq --version` and `iq -v` currently appear unsupported because they terminate in generic invalid-usage help.
  - `iq version` succeeds immediately and prints the version, so the inconsistency is visible at the user surface.
- Command router perspective:
  - `cli_router` rejects the empty-route registration whenever args are non-empty, so flagged root invocations are blocked before root-command logic can run.
- Existing `iq version` surface perspective:
  - `code\cli\lib\modules\global\commands\version.dart` defines a dedicated version-printing command that returns `inquiryVersion`.
  - The bounded runtime confirms that this surface currently prints `version: 0.7.3`.
- Bounded docs/tests perspective:
  - `code\cli\README.md` and the current tests preserve `iq` as the banner/TUI surface and `iq version` as the version surface.
  - The missing direct coverage is specifically root `--version` / `-v`, so the analysis gap is about an uncovered alias path, not about competing documented semantics.

## F9: The packet stayed on the right bounded question — CONFIRMED

- The highest-value packet-local question was whether root `--version` / `-v` should converge with the already-existing `iq version` surface or imply a distinct root/TUI-specific contract.
- `diagnosis.md` resolves that semantic question and explicitly leaves implementation-locus choice, general CLI flag normalization policy, and broader router/SDK redesign out of scope.
- No stronger bounded question remains for issue #170: the remaining uncertainty is how to implement the alias path, which belongs to planning/execution rather than further analysis.
