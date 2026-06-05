# Experimental Protocol — Pilot for the First Paper

> **Type:** method
> **Status:** stable
> **Depends on:** [thesis.md](thesis.md), [research-question.md](research-question.md), [constructs-and-measures.md](constructs-and-measures.md), [evidence/evidence-plan.md](evidence/evidence-plan.md)
> **Used by:** future task-corpus document, future scoring-rubrics document, ongoing pilot workflow

This document defines the protocol that emerged from the pilot stage of the first paper.
After T1-T3 and the explicit freeze decision in [protocol-freeze-decision.md](protocol-freeze-decision.md),
it should be treated as the controlling method for the next evidence-collection phase
unless a later design-level failure forces a new revision.

## Decisions fixed so far

The following design choices have already been agreed.

- **Pilot-first scope.** The next empirical step is a pilot, not the full paper study.
- **Two-condition comparison.** The pilot compares harness use against freestyle use of
  the same model.
- **Strict human intervention rule.** The human may answer direct questions from the
  system, but may not volunteer unsolicited guidance during a valid run.
- **Pilot size.** The pilot will use three tasks.
- **Condition order.** The two conditions will be counterbalanced across tasks rather
   than always run in the same order.
- **Premature-clarification threshold.** A question ceases to count as premature only
   when prior evidence gathering has materially reduced uncertainty about the next step.

## Objective of the pilot

The pilot is designed to answer a methodological question before it answers the thesis.

> Can this protocol generate interpretable evidence about C1 through C4 without letting
> uncontrolled variation dominate the comparison?

The pilot is successful if it exposes ambiguity early enough to refine the method before
the full task set is run.

## Conditions

### Condition H — Harness

The task is executed through Inquiry's explicit harness: FSM structure, named operators,
durable artifacts, and trace-producing workflow.

### Condition F — Freestyle

The same task is executed with the same model in the host's native interface, without
the Inquiry harness and without importing Inquiry's stateful artifacts into the run.

## Condition order

The pilot will use **counterbalanced order across tasks**. Some task pairs will run
Harness first and Freestyle second; others will run Freestyle first and Harness second.
The purpose is not full statistical balancing, but early detection of obvious order
effects during the pilot stage.

## Controls

The pilot should preserve the following controls across both conditions whenever
possible:

- the same model family and version,
- the same host environment,
- the same starting repository revision,
- the same task statement,
- the same success target,
- and the same human-availability rule.

If one of these controls cannot be preserved, the deviation must be recorded and the run
should be reviewed for invalidation.

## Condition-neutral completion boundary

Each task packet must define a **shared scored stop line** in addition to the general
success target. The stop line is the point at which the paired comparison is judged
complete for the primary C1-C4 coding pass.

For the pilot, the scored stop line must specify:

- the concrete shared success target,
- the shared validation surface required before scoring,
- and any post-target work that is explicitly outside the primary paired comparison.

When one condition continues into release preparation, version bumping, changelog work,
PR creation, issue hygiene, harness END or EVOLUTION behavior, or other repository
integration work after the shared success target is already satisfied, that work must
be recorded as a **post-target extension** rather than silently folded into the paired
comparison.

If capture reliability forces one condition to use a non-interactive share-producing
fallback, the paired condition should use its own documented share-producing fallback as
well unless the packet explicitly treats host mode as a study variable.

Before a paired run begins, the investigator should also perform a condition-neutral
preflight check from the packet's starting revision to confirm that the intended task
surface is actually present in a scorable form. For a bug-fix task, this usually means
a failing test or another concrete failure surface. If the starting revision already
satisfies the stated success target, the task packet should be marked for invalidation
review or rewritten before either condition is run.

If packet design, repair discussion, or preflight work has already exposed a likely
solution path, the paired conditions must then be executed in fresh host sessions. The
setup conversation that discovered the reproducible surface is not part of either
scored run transcript.

## Task handling rules

Each pilot task should be prepared as a bounded **task packet** containing:

- the task statement,
- the starting repository revision,
- the intended success condition,
- and any baseline issue or artifact context that is allowed to be shared across conditions.

For each task:

1. both conditions should begin from materially equivalent repository state,
2. the runs should be treated as independent,
3. no artifacts produced by one condition may be fed into the other as guidance,
4. all durable artifacts and available traces should be preserved,
5. the shared scored stop line must be evidenced explicitly,
6. any post-target extension work must be recorded separately from the primary paired run,
7. and any deviation from the task packet must be recorded.

The protocol does not yet fix the final task list. That belongs in the future
task-corpus document.

## Human intervention rule

The human investigator may:

- answer direct questions issued by the active system,
- stop a run for safety, feasibility, or obvious protocol breakdown,
- and record procedural observations outside the run record.

The human investigator may not, during a valid run:

- volunteer extra hints,
- redirect the system toward a preferred solution,
- add unrequested clarifications,
- or repair the reasoning path interactively.

If such intervention occurs, the run should be marked for invalidation review.

## Invalidation rules

A run should be considered invalidated, or at minimum flagged for invalidation review,
if any of the following occurs:

- the human provides substantive unsolicited guidance,
- the task statement changes materially after the run has started,
- the starting repository state is not comparable across conditions,
- the shared scored stop line is missing, or post-target extension work cannot be
  separated from the primary paired comparison,
- the model or host version differs across the paired runs,
- the freestyle run still has active host-scoped Inquiry deployment or other harness residue from the paired Harness run,
- essential artifacts or traces are missing such that C1–C4 cannot be scored,
- or one condition is contaminated by outputs from the other.

Invalidated runs are not useless; they may still inform protocol refinement. They should
not be treated as clean evidence for the first comparison.

## Required records

For each pilot run, the study should retain enough material to score the constructs in
[constructs-and-measures.md](constructs-and-measures.md). At minimum, this includes:

- the task packet,
- the paired-run capture sheet derived from [paired-run-capture-template.md](paired-run-capture-template.md),
- the run transcript or equivalent interaction record for each condition,
- a durable session export or a verified export-failure note for each condition,
- the artifact set produced by the run,
- the shared stop-line validation outputs and final diff/status snapshots,
- and the available overhead record, including any post-target extension window.

## Rule for coding premature clarification

For the pilot, a question event should still count as **premature clarification** unless
the prior evidence-gathering activity has materially narrowed the uncertainty that
blocks the next action. Mere file opening, superficial search, or nominal inspection
does not by itself remove the label of prematurity.

## Expected output of the pilot

The pilot should produce three outputs:

1. a small set of paired runs,
2. a list of protocol ambiguities or breakdowns,
3. and a decision about whether the first-paper method is ready to freeze or must be revised.

## Status note

This protocol is now frozen for the next first-paper evidence-collection phase. That
does not mean the thesis is confirmed or that all run-level deviations disappeared. It
means the pilot has shown the rules to be workable enough to stop redesigning the method
by default. Any later method change should be treated as an explicit protocol revision,
not as an untracked local tweak.