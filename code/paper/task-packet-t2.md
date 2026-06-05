# Task Packet — T2 Feature Slice (root version flags)

> **Type:** method
> **Status:** draft
> **Depends on:** [task-packet-template.md](task-packet-template.md), [experimental-protocol.md](experimental-protocol.md), [task-corpus.md](task-corpus.md)
> **Used by:** pilot run pair for T2

## Packet identity

- **Packet ID:** T2-pilot-feature-root-version-flags
- **Pilot task ID:** T2
- **Task type:** feature slice
- **Historical reference:** issue `#170`, commit `3e0f2d8` — Support root version flags
- **Condition order for the pair:** F -> H

## Shared task statement

Add support for root `--version` and `-v` flags so they dispatch correctly and expose
the expected version behavior from the top-level CLI surface.

## Starting repository revision

- **Repository revision / commit:** `0f34254d6c83ff7bb7a27a0ac34a20f6804ce3c9`
- **Workspace assumptions:**
  - both conditions begin from the same repository revision,
  - the run is evaluated as a bounded CLI feature slice,
  - no artifacts from the paired condition are visible during the run.

## Intended success condition

The task is successful if `dart run bin/main.dart --version` and
`dart run bin/main.dart -v` both dispatch through the top-level CLI surface to the
expected version behavior from the starting revision, the relevant focused and full test
surfaces pass, and the change stays within the bounded feature slice rather than
expanding into unrelated CLI-router or SDK redesign.

## Scored stop line

For the primary H/F comparison, T2 is scored at the first worktree state where root
`--version` and `-v` both dispatch correctly through the top-level CLI surface and the
shared validation commands below are preserved as passing from that same bounded change
surface.

- **Shared scored stop line:** stop primary scoring once root `--version` and `-v`
  both work from `dart run bin/main.dart` and the shared validation commands below
  pass from the same worktree state.
- **Shared validation commands:**
  - `dart run bin/main.dart --version`
  - `dart run bin/main.dart -v`
  - `dart test test/version_test.dart`
  - `dart test`
- **Excluded post-target work:** version bump and release-surface sync, changelog or
  site badge updates, PR packaging, docs cleanup, and broader CLI-router or SDK
  redesign beyond the bounded root-version slice.

## Allowed baseline context

- **Issue or task context allowed:** issue `#170` title and body as the shared problem statement
- **Artifacts allowed:** none from prior paired runs
- **Additional baseline context allowed:** the starting revision and the fact that the
  task concerns root-level version-flag behavior on the CLI surface

## Excluded carry-over

- outputs from the paired condition,
- condition-specific intermediate artifacts,
- post hoc hints discovered during the first run,
- any guidance not already declared in the packet.

## Capture-mode plan

- **Harness session capture mode:** non-interactive share fallback
- **Freestyle session capture mode:** non-interactive share fallback
- **If mixed, justification:** not planned. T1 on this host already showed that the
  interactive Freestyle export path was not reliable enough to guarantee a durable
  share artifact, so T2 freezes the symmetric non-interactive share-producing mode in
  advance rather than waiting for an asymmetric failure during the pair.

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

- **Watchpoint 1:** the run expands from bounded root version-flag support into broader router or SDK redesign
- **Watchpoint 2:** one condition receives extra guidance about which implementation option to prefer beyond what is already present in issue `#170`
- **Watchpoint 3:** the compared runs are not evaluated from materially equivalent repository state

## Deviation log

- **Deviation 1:**
- **Deviation 2:**
- **Deviation 3:**