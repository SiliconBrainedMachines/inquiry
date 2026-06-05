# T2 Pair Capture Sheet

> **Type:** evidence
> **Status:** captured
> **Depends on:** [../task-packet-t2.md](../task-packet-t2.md), [../paired-run-capture-template.md](../paired-run-capture-template.md)
> **Used by:** future T2 paired evidence bundle

This file is the investigator-side paired capture sheet for the T2 pilot run. It is
created before either condition starts so the shared scored boundary, validation
surface, and planned record paths are frozen in one place.

## Pair identity

- **Packet ID:** T2-pilot-feature-root-version-flags
- **Pilot task ID:** T2
- **Condition order:** F -> H
- **Study root:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry`
- **Capture sheet created at:** 2026-06-04 pre-run

## Shared scored boundary

- **Shared success target:** root `--version` and `-v` dispatch correctly from the
  top-level CLI surface without widening scope beyond the bounded feature slice.
- **Shared scored stop line:** stop primary scoring at the first worktree state where
  `dart run bin/main.dart --version`, `dart run bin/main.dart -v`,
  `dart test test/version_test.dart`, and `dart test` are all preserved as passing
  from the same bounded change surface.
- **Shared validation commands:**
  - `dart run bin/main.dart --version`
  - `dart run bin/main.dart -v`
  - `dart test test/version_test.dart`
  - `dart test`
- **Excluded post-target work:** version bump and release-surface sync, changelog or
  site badge updates, PR packaging, docs cleanup, and broader CLI-router or SDK
  redesign beyond the bounded root-version slice.

## Condition H capture

- **Worktree path:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t2-h`
- **Session mode:** non-interactive share fallback
- **Shell transcript path:** `pilot-records/t2-harness-transcript.txt`
- **Session export path:** `pilot-records/t2-harness-share.md`
- **Session export verified on disk?** yes
- **Artifact root path:** `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand`; bounded code slice in `code/cli/lib/inquiry_cli.dart` and `code/cli/test/version_test.dart`
- **Focused validation output path:** `pilot-records/t2-h-focused-validation.txt`
- **Full validation output path:** `pilot-records/t2-h-full-validation.txt`
- **Final diff/status snapshot path:** `pilot-records/t2-h-status.txt`
- **Run start time:** 2026-06-04 13:02:47 local time
- **Shared stop line reached at:** 2026-06-04 14:10:56 local time
- **Post-target extension started at:** none observed beyond bounded harness closure
- **Post-target extension ended at:** none observed beyond bounded harness closure
- **Deviation notes:** preflight preserved at `pilot-records/t2-h-preflight.txt`; local worktree exclude now ignores `pilot-records/` so status snapshots stay scoped to code changes; the first H launch attempt failed because the repo-scoped agent file was missing, then `inquiry init` created `.inquiry/config.yaml` and `.github/agents/inquiry.agent.md` before the scored run was relaunched; that remediation is recorded in `pilot-records/t2-h-init.txt`; by about 2026-06-04 13:09 local time the relaunched harness had completed `inquiry-start`, selected issue `#170`, created cleanroom `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand`, and materialized `issue.md`, `analyze/index.md`, `analyze/confirmations.md`, and `analyze/diagnosis.md`; the shared stop line was then preserved in one unchanged worktree state and exported durably at `pilot-records/t2-harness-share.md`.
- **Missing artifact notes:** none

## Condition F capture

- **Worktree path:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t2-f`
- **Session mode:** non-interactive share fallback
- **Shell transcript path:** `pilot-records/t2-freestyle-transcript.txt`
- **Session export path:** `pilot-records/t2-freestyle-share.md`
- **Session export verified on disk?** yes
- **Artifact root path or final change surface:** `code/cli/lib/inquiry_cli.dart`, `code/cli/lib/modules/global/commands/help.dart`, `code/cli/test/help_command_test.dart`, `code/cli/test/version_test.dart`
- **Focused validation output path:** `pilot-records/t2-f-focused-validation.txt`
- **Full validation output path:** `pilot-records/t2-f-full-validation.txt`
- **Final diff/status snapshot path:** `pilot-records/t2-f-status.txt`
- **Run start time:** 2026-06-04 12:48:14 local time
- **Shared stop line reached at:** 2026-06-04 12:55:10 local time
- **Post-target extension started at:** none observed
- **Post-target extension ended at:** none observed
- **Deviation notes:** preflight preserved at `pilot-records/t2-f-preflight.txt`; local worktree exclude now ignores `pilot-records/` so status snapshots stay scoped to code changes; the local PowerShell transcript captured only the shell envelope, so the richer Copilot interaction record was copied from session-state to `pilot-records/t2-f-session-transcript.txt`; F reported a small share-formatting issue and corrected the durable export before completion.
- **Missing artifact notes:** none

## Symmetry audit

- [x] Same starting revision confirmed for both conditions
- [x] Same shared stop line used for both conditions
- [x] Same validation surface preserved for both conditions
- [x] Durable session export or equivalent interaction record preserved for both conditions
- [x] Final diff/status snapshot preserved for both conditions
- [x] Overhead clocks recorded for both conditions
- [x] Post-target extension, if any, is separated from the primary comparison
- [ ] Invalidation review required? If yes, explain below

## Invalidation review notes

- **Issue 1:**
- **Issue 2:**
- **Issue 3:**

## Bundle checklist

- [ ] Packet copied into evidence bundle
- [ ] H transcript bundled
- [ ] F transcript bundled
- [ ] H session export bundled
- [x] H session export bundled
- [x] H artifact set bundled
- [x] Focused validation outputs bundled
- [ ] Focused validation outputs bundled
- [ ] Overhead notes bundled
- [ ] Deviation log bundled