# Task Packet Template — Pilot Runs

> **Type:** method
> **Status:** draft
> **Depends on:** [experimental-protocol.md](experimental-protocol.md), [task-corpus.md](task-corpus.md), [constructs-and-measures.md](constructs-and-measures.md)
> **Used by:** instantiated pilot task packets for T1, T2, and T3

This template is the condition-neutral container for a pilot task. It should be copied
once per approved pilot task and completed before either condition is run. The purpose
of the packet is to keep both conditions anchored to the same problem statement,
starting revision, success target, and allowed baseline context.

The packet is written **before** the paired runs begin. It may record deviations during
execution, but it should not be retrofitted to match what happened.

## Template

### Packet identity

- **Packet ID:**
- **Pilot task ID:** T1 | T2 | T3
- **Task type:** bug fix | feature slice | refactor
- **Historical reference:**
- **Condition order for the pair:** H -> F | F -> H

### Shared task statement

Write the bounded task statement that both conditions will receive. It should be narrow,
actionable, and free of hidden guidance.

### Starting repository revision

- **Repository revision / commit:**
- **Workspace assumptions:**

State the exact revision from which both conditions must begin and any relevant
environment assumptions that are held constant across the pair.

### Intended success condition

State what would count as a successful completion of the task. This should be concrete
enough that both conditions can be judged against the same target.

### Scored stop line

Define the exact point at which the paired comparison stops for primary scoring.

- **Shared scored stop line:**
- **Shared validation commands:**
- **Excluded post-target work:**

### Allowed baseline context

List the issue, artifact, or repository context that may be shared across both
conditions before the run begins.

- **Issue or task context allowed:**
- **Artifacts allowed:**
- **Additional baseline context allowed:**

### Excluded carry-over

State what must **not** be transferred between conditions.

- outputs from the paired condition,
- condition-specific intermediate artifacts,
- post hoc hints discovered during the first run,
- any guidance not already declared in the packet.

### Capture-mode plan

Record how each condition will preserve an equivalent interaction record.

- **Harness session capture mode:** interactive export | non-interactive share fallback | other
- **Freestyle session capture mode:** interactive export | non-interactive share fallback | other
- **If mixed, justification:**

### Expected records

For this packet, confirm what must be preserved so the constructs can be scored.
Use [paired-run-capture-template.md](paired-run-capture-template.md) as the default
capture worksheet.

- [ ] transcript or equivalent interaction record
- [ ] durable session export or verified export-failure note
- [ ] artifact set
- [ ] shared stop-line validation output
- [ ] final diff/status snapshot
- [ ] overhead record
- [ ] paired-run capture sheet
- [ ] deviation log

### Invalidation watchpoints

List any packet-specific risks that would likely invalidate the pair or force protocol
review.

- **Watchpoint 1:**
- **Watchpoint 2:**
- **Watchpoint 3:**

### Deviation log

Record any deviation from the packet that occurs during the paired runs.

- **Deviation 1:**
- **Deviation 2:**
- **Deviation 3:**

## Use rule

One packet should govern one paired comparison for one approved pilot task. If the task
statement or the starting revision changes materially, a new packet should be created
instead of silently mutating the old one.