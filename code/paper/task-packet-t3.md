# Task Packet — T3 Refactor (state.yaml field rename)

> **Type:** method
> **Status:** draft
> **Depends on:** [task-packet-template.md](task-packet-template.md), [experimental-protocol.md](experimental-protocol.md), [task-corpus.md](task-corpus.md)
> **Used by:** pilot run pair for T3

## Packet identity

- **Packet ID:** T3-pilot-refactor-state-yaml-field-rename
- **Pilot task ID:** T3
- **Task type:** refactor
- **Historical reference:** commit `447cf29` — rename state.yaml fields `phase` -> `state`, `task` -> `issue`
- **Condition order for the pair:** H -> F

## Shared task statement

Rename the state-tracking fields from `phase` to `state` and from `task` to `issue`,
and align the related CLI state-handling surfaces with that unified naming.

## Starting repository revision

- **Repository revision / commit:** `07d369215a2c64c80426278369253cfd89f03ff8`
- **Workspace assumptions:**
  - both conditions begin from the same repository revision,
  - the run is evaluated as a bounded structural refactor,
  - no artifacts from the paired condition are visible during the run.

## Intended success condition

The task is successful if the state-file naming is unified from the starting revision,
the related CLI state-handling and test surfaces are aligned with the new names, and the
change remains a bounded refactor rather than expanding into a broader FSM or lifecycle
redesign.

## Scored stop line

For the primary H/F comparison, T3 is scored at the first worktree state where the
state-tracking surface consistently uses `state` and `issue` in `.inquiry/state.yaml`,
the related CLI state-handling commands are aligned with that naming, and the shared
validation commands below pass from that same bounded change surface.

- **Shared scored stop line:** stop primary scoring once `.inquiry/state.yaml`,
  `fsm state`, `fsm transition`, and `init` all align on `state` / `issue` naming and
  the shared validation commands below pass from the same worktree state.
- **Shared validation commands:**
  - `dart test test/init_command_test.dart`
  - `dart test test/fsm_state_test.dart`
  - `dart test test/fsm_transition_test.dart`
  - `dart test test/fsm_transition_integration_test.dart`
  - `dart test`
- **Excluded post-target work:** broader FSM or lifecycle redesign, config-schema
  cleanup beyond the field rename, backward-compatibility shims not required by the
  bounded refactor, release/version work, PR packaging, and unrelated documentation
  cleanup.

## Allowed baseline context

- **Issue or task context allowed:** the packet title and shared task statement only
- **Artifacts allowed:** none from prior paired runs
- **Additional baseline context allowed:** the starting revision and the fact that the
  task is a structural cleanup of state-file field naming and related state-handling surfaces

## Excluded carry-over

- outputs from the paired condition,
- condition-specific intermediate artifacts,
- post hoc hints discovered during the first run,
- any guidance not already declared in the packet.

## Capture-mode plan

- **Harness session capture mode:** non-interactive share fallback
- **Freestyle session capture mode:** non-interactive share fallback
- **If mixed, justification:** not planned. T2 established the symmetric non-
  interactive share-producing mode as the safer way to preserve comparable durable
  artifacts on this host.

## Expected records

- [ ] transcript or equivalent interaction record
- [ ] durable session export or verified export-failure note
- [ ] artifact set
- [ ] shared stop-line validation output
- [ ] final diff/status snapshot
- [ ] overhead record
- [ ] paired-run capture sheet
- [ ] deviation log

## Invalidation watchpoints

- **Watchpoint 1:** the run expands from field-rename alignment into broader FSM, lifecycle, or architecture redesign
- **Watchpoint 2:** one condition receives extra guidance about migration strategy beyond what is already implied by the packet
- **Watchpoint 3:** the compared runs are not evaluated from materially equivalent repository state

## Deviation log

- **Deviation 1:**
- **Deviation 2:**
- **Deviation 3:**