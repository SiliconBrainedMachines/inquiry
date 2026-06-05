# T3 Pair Capture Sheet

> **Type:** evidence
> **Status:** captured
> **Depends on:** [../task-packet-t3.md](../task-packet-t3.md), [../paired-run-capture-template.md](../paired-run-capture-template.md)
> **Used by:** future T3 paired evidence bundle

This file is the investigator-side paired capture sheet for the T3 pilot run. It is
created before either condition starts so the shared scored boundary, validation
surface, and planned record paths are frozen in one place.

## Pair identity

- **Packet ID:** T3-pilot-refactor-state-yaml-field-rename
- **Pilot task ID:** T3
- **Condition order:** H -> F
- **Study root:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry`
- **Capture sheet created at:** 2026-06-04 pre-run

## Shared scored boundary

- **Shared success target:** unify the state-tracking naming on `.inquiry/state.yaml`
	and the related CLI state-handling surfaces from the starting revision without
	widening the task into broader FSM or lifecycle redesign.
- **Shared scored stop line:** stop primary scoring at the first worktree state where
	`.inquiry/state.yaml`, `init`, `fsm state`, and `fsm transition` all align on
	`state` / `issue` naming and the shared validation commands below pass from the same
	bounded change surface.
- **Shared validation commands:**
	- `dart test test/init_command_test.dart`
	- `dart test test/fsm_state_test.dart`
	- `dart test test/fsm_transition_test.dart`
	- `dart test test/fsm_transition_integration_test.dart`
	- `dart test`
- **Excluded post-target work:** broader FSM or lifecycle redesign, config-schema
	cleanup beyond the bounded field rename, compatibility shims not required by the
	bounded refactor, release/version work, PR packaging, and unrelated documentation
	cleanup.

Use this section to define the primary comparison boundary. If either condition keeps
going after this boundary, record that extra work as a post-target extension rather than
silently folding it into the main pair.

## Condition H capture

- **Worktree path:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-h`
- **Session mode:** non-interactive share fallback
- **Shell transcript path:** `pilot-records/t3-harness-transcript.txt`
- **Session export path:** `pilot-records/t3-harness-share.md`
- **Session export verified on disk?** yes
- **Artifact root path:** `cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t`
- **Focused validation output path:** `pilot-records/t3-h-focused-validation.txt`
- **Full validation output path:** `pilot-records/t3-h-full-validation.txt`
- **Final diff/status snapshot path:** `pilot-records/t3-h-status.txt`
- **Run start time:** 2026-06-04 15:56:09 local time
- **Shared stop line reached at:** 2026-06-04 17:17:29 local time
- **Post-target extension started at:** none observed
- **Post-target extension ended at:** none observed
- **Deviation notes:** preflight preserved at `pilot-records/t3-h-preflight.txt`;
	repo-scoped harness bootstrap preserved at `pilot-records/t3-h-init.txt`; local
	worktree exclude now ignores `pilot-records/` so later status snapshots stay scoped
	to code and harness changes; a first H attempt created issue `#234`, exported
	`pilot-records/t3-harness-first-attempt-share.md`, and materialized branch
	`234-refactor-rename-state-file-fields-phasestate-and-t` plus cleanroom
	`cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t`, whose
	`run_trace.yaml` already records `issue_selected_or_created` and
	`feature_branch_selected` as approved. That first attempt nonetheless stalled in
	command-discovery rather than moving cleanly into the scored ANALYZE run, so H was
	relaunched with explicit start intent reusing issue `#234`; the second attempt also
	exported `pilot-records/t3-harness-second-attempt-share.md` but remained in `IDLE`
	with `dewey` running and `issue: null`, so a manual operator handoff was recorded in
	`pilot-records/t3-h-manual-start-handoff.txt`, which successfully moved the FSM to
	`ANALYZE` for issue `234` before the current H run was relaunched from that state.
- **Missing artifact notes:** none

## Condition F capture

- **Worktree path:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-f`
- **Session mode:** non-interactive share fallback
- **Shell transcript path:** `pilot-records/t3-freestyle-transcript.txt`
- **Session export path:** `pilot-records/t3-freestyle-share.md`
- **Session export verified on disk?** yes
- **Artifact root path or final change surface:** `code/cli/lib/modules/global/commands/init.dart`,
	`code/cli/lib/modules/fsm/commands/state.dart`,
	`code/cli/lib/modules/fsm/commands/transition.dart`,
	`code/cli/test/init_command_test.dart`,
	`code/cli/test/fsm_state_test.dart`,
	`code/cli/test/fsm_transition_test.dart`, and
	`code/cli/test/fsm_transition_integration_test.dart`
- **Focused validation output path:** `pilot-records/t3-f-focused-validation.txt`
- **Full validation output path:** `pilot-records/t3-f-full-validation.txt`
- **Final diff/status snapshot path:** `pilot-records/t3-f-status.txt`
- **Run start time:** 2026-06-04 17:19:28 local time
- **Shared stop line reached at:** 2026-06-04 17:27:39 local time
- **Post-target extension started at:** none observed
- **Post-target extension ended at:** none observed
- **Deviation notes:** preflight preserved at `pilot-records/t3-f-preflight.txt`;
	local worktree exclude now ignores `pilot-records/` so later status snapshots stay
	scoped to code changes; a first F attempt was preserved in
	`pilot-records/t3-freestyle-first-attempt-transcript.txt` and
	`pilot-records/t3-freestyle-first-attempt-share.md`, but it ended after extended
	repo discovery without edits or scored validation; F was then relaunched with a
	stricter bounded brief that reused only that first attempt's local discovery. During
	the relaunch, the first validation wrapper captured `dart` help text rather than the
	exact command outputs, so the agent reran the five scored commands directly and the
	copied focused/full logs are from that rerun. The relaunch share exported successfully
	to `pilot-records/t3-freestyle-share.md`, but the final artifact-capture shell inside
	the run hung on malformed string writing; investigator-side fallback files
	`pilot-records/t3-f-status.txt`, `pilot-records/t3-f-deviation-notes.txt`, and
	`pilot-records/t3-f-packet-stop-line.txt` were written after the terminal was stopped,
	using the already-stable scored worktree and copied validation logs.
- **Missing artifact notes:** none

## Symmetry audit

- [x] Same starting revision confirmed for both conditions
- [x] Same shared stop line used for both conditions
- [x] Same validation surface preserved for both conditions
- [x] Durable session export or equivalent interaction record preserved for both conditions
- [x] Final diff/status snapshot preserved for both conditions
- [x] Overhead clocks recorded for both conditions
- [x] Post-target extension, if any, is separated from the primary comparison
- [x] Invalidation review required? If yes, explain below

## Invalidation review notes

- **Issue 1:** H required operator intervention to complete the historical IDLE -> ANALYZE handoff. The scored H run therefore includes two preserved pre-scored attempts plus `pilot-records/t3-h-manual-start-handoff.txt` before the final ANALYZE/PLAN/EXECUTE pass.
- **Issue 2:** F required one preserved exploratory first attempt and one relaunch with a stricter bounded brief inside the same condition before the scored edit/validation pass.
- **Issue 3:** F's canonical share exported, but its in-run artifact-capture shell hung after the scored line, so investigator-side fallback files were written from the stable post-validation worktree and copied session-state logs.

## Bundle checklist

- [ ] Packet copied into evidence bundle
- [ ] H transcript bundled
- [ ] F transcript bundled
- [ ] H session export bundled
- [ ] F session export bundled
- [ ] H artifact set bundled
- [ ] F artifact set bundled
- [ ] Focused validation outputs bundled
- [ ] Overhead notes bundled
- [ ] Deviation log bundled