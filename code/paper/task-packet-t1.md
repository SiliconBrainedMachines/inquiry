# Task Packet — T1 Bug Fix (Windows ape prompt paths)

> **Type:** method
> **Status:** draft
> **Depends on:** [task-packet-template.md](task-packet-template.md), [experimental-protocol.md](experimental-protocol.md), [task-corpus.md](task-corpus.md)
> **Used by:** pilot run pair for T1

## Packet identity

- **Packet ID:** T1-pilot-bugfix-windows-ape-prompt-paths
- **Pilot task ID:** T1
- **Task type:** bug fix
- **Historical reference:** commit `4739cf1` — Fix Windows ape prompt path expectations
- **Condition order for the pair:** H -> F

## Shared task statement

Make the Windows ape prompt test expectations match the git-resolved project root
when the repository is accessed through an alternate path spelling such as a
junction.

## Starting repository revision

- **Repository revision / commit:** `e078f36577e704fa2eec09bd520501a512cdf60b`
- **Workspace assumptions:**
  - both conditions begin from the same repository revision,
  - the run is evaluated as a Windows-oriented bug-fix task,
  - no artifacts from the paired condition are visible during the run.

## Condition-neutral reproduction surface

- **Preflight setup:** create a temporary git repository on Windows, then access that
  same repository through a directory junction or equivalent alternate path spelling.
- **Observed mismatch:** from the alternate path, `git rev-parse --show-toplevel`
  resolves the canonical repository root rather than the entered junction path.
- **Task implication:** the prompt code already emits the git-resolved project root,
  while the historical test expectations in the starting revision still anchor some
  assertions to the raw temporary directory path. The task is therefore to repair the
  test oracle, not to change prompt assembly behavior.

## Intended success condition

The task is successful if the Windows-specific ape prompt path expectations are aligned
to the git-resolved project root without widening scope beyond the bounded bug-fix
slice, and the focused regression surface passes under the junction-based reproduction
from the starting revision.

## Allowed baseline context

- **Issue or task context allowed:** the packet title and shared task statement only
- **Artifacts allowed:** none from prior paired runs
- **Additional baseline context allowed:** the starting revision and the fact that the
  task is a Windows-oriented bug fix in the ape prompt test surface, including the
  junction-based preflight setup declared in this packet

## Excluded carry-over

- outputs from the paired condition,
- condition-specific intermediate artifacts,
- post hoc hints discovered during the first run,
- any guidance not already declared in the packet.

## Expected records

- [ ] transcript or equivalent interaction record
- [ ] artifact set
- [ ] overhead record
- [ ] deviation log

## Invalidation watchpoints

- **Watchpoint 1:** the run expands from test-path correction into unrelated prompt-assembly or platform refactoring
- **Watchpoint 2:** one condition receives extra Windows-specific diagnostic hints that are not part of the packet
- **Watchpoint 3:** the compared runs are not evaluated from materially equivalent repository state

## Preflight outcome

The first condition-neutral preflight on Windows showed that the original binary
framing was too weak: `dart test test/ape_prompt_test.dart` already passes from the
packet's starting revision. A second neutral preflight using a temporary git repository
accessed through a junction exposed the relevant path mismatch: `git rev-parse
--show-toplevel` resolves the canonical target path rather than the entered junction
path. T1 is therefore reformulated around that reproducible Windows path-canonicalization
surface.

## Deviation log

- **Deviation 1:** In the first full-scheduler Harness pilot on Windows, the deployed
  `iq` runtime created GitHub issue #231 for the bounded T1 problem, but the next
  handoff step failed when `iq ape transition --event issue_selected_or_created`
  returned `NO_ACTIVE_APE` while `iq fsm state --json` still reported `state: IDLE`,
  `issue: null`, and `dewey: RUNNING`. The run was therefore stopped as a
  harness-level blockage before any bounded T1 code edit phase began.
- **Deviation 2:**
- **Deviation 3:**