# Paired Run Capture Template — Pilot Runs

> **Type:** method
> **Status:** draft
> **Depends on:** [experimental-protocol.md](experimental-protocol.md), [task-packet-template.md](task-packet-template.md)
> **Used by:** [t1-pilot-runbook.md](t1-pilot-runbook.md), future T2/T3 runbooks, paired evidence bundles

This template is a condition-symmetric capture sheet for one paired pilot run. Create
one copy before either condition starts. Keep it outside both active condition
worktrees so it does not become in-run guidance.

## Pair identity

- **Packet ID:**
- **Pilot task ID:**
- **Condition order:** H -> F | F -> H
- **Study root:**
- **Capture sheet created at:**

## Shared scored boundary

- **Shared success target:**
- **Shared scored stop line:**
- **Shared validation commands:**
- **Excluded post-target work:**

Use this section to define the primary comparison boundary. If either condition keeps
going after this boundary, record that extra work as a post-target extension rather than
silently folding it into the main pair.

## Condition H capture

- **Worktree path:**
- **Session mode:** interactive | non-interactive share fallback
- **Shell transcript path:**
- **Session export path:**
- **Session export verified on disk?** yes | no
- **Artifact root path:**
- **Focused validation output path:**
- **Full validation output path:**
- **Final diff/status snapshot path:**
- **Run start time:**
- **Shared stop line reached at:**
- **Post-target extension started at:**
- **Post-target extension ended at:**
- **Deviation notes:**
- **Missing artifact notes:**

## Condition F capture

- **Worktree path:**
- **Session mode:** interactive | non-interactive share fallback
- **Shell transcript path:**
- **Session export path:**
- **Session export verified on disk?** yes | no
- **Artifact root path or final change surface:**
- **Focused validation output path:**
- **Full validation output path:**
- **Final diff/status snapshot path:**
- **Run start time:**
- **Shared stop line reached at:**
- **Post-target extension started at:**
- **Post-target extension ended at:**
- **Deviation notes:**
- **Missing artifact notes:**

## Symmetry audit

- [ ] Same starting revision confirmed for both conditions
- [ ] Same shared stop line used for both conditions
- [ ] Same validation surface preserved for both conditions
- [ ] Durable session export or equivalent interaction record preserved for both conditions
- [ ] Final diff/status snapshot preserved for both conditions
- [ ] Overhead clocks recorded for both conditions
- [ ] Post-target extension, if any, is separated from the primary comparison
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
- [ ] F session export bundled
- [ ] H artifact set bundled
- [ ] F artifact set bundled
- [ ] Focused validation outputs bundled
- [ ] Overhead notes bundled
- [ ] Deviation log bundled