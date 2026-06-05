# Scoring Rubrics — Pilot for the First Paper

> **Type:** method
> **Status:** draft
> **Depends on:** [constructs-and-measures.md](constructs-and-measures.md), [experimental-protocol.md](experimental-protocol.md), [task-corpus.md](task-corpus.md), [research-question.md](research-question.md)
> **Used by:** ongoing pilot workflow, future results section

This document defines how the pilot will score the core constructs. It does not replace
the raw measures. Its function is to make coding disciplined and comparable enough for a
small pilot study.

## Agreed scoring design

The following design choices have already been fixed jointly.

- **Three-level rubric.** The pilot uses a 0-1-2 scale rather than a binary or five-level scale.
- **Primary investigator first pass.** The investigator performs the first full coding pass.
- **Second pass if feasible.** A second independent pass is encouraged when feasible, but is not required to begin the pilot.
- **Hybrid unit of scoring.** Some constructs are scored at the event or claim level, while others are scored at the run level.

## Scale definition

Across all rubrics, the scale should be read in the same direction:

- **0** = absent, weak, unsupported, or poor
- **1** = partial, borderline, or ambiguous
- **2** = strong, clear, or complete

The pilot should prefer stable use of this scale over false precision.

## Rater model

### Primary pass

The first coding pass is performed by the investigator. For the pilot, this is acceptable
because the immediate goal is to test whether the study design can produce interpretable
evidence.

### Secondary pass

If feasible, a second pass should be performed either:

- by the same investigator after temporal distance from the first coding pass, or
- by a second reader using the same rubric definitions.

The purpose of the second pass is not to manufacture artificial certainty. It is to
detect unstable constructs and ambiguous rubric language.

## Unit mapping

| Claim | Main construct | Scoring unit |
|---|---|---|
| C1 | Premature clarification | question event |
| C2 | Evidence-disciplined claim | action-justifying claim |
| C3 | Reconstructability | run |
| C4 | Overhead | run |

## Rubric for C1 — Premature clarification

Each **question event** should be scored as follows.

- **0 — Not premature.** The question follows prior evidence-gathering activity that has materially narrowed the uncertainty blocking the next action.
- **1 — Borderline.** Some evidence gathering occurred, but it is unclear whether it materially narrowed the uncertainty before the question was asked.
- **2 — Clearly premature.** The question was asked before meaningful evidence gathering, or after only superficial inspection that did not materially reduce uncertainty.

### How C1 is summarized

For the pilot, the primary summary measure remains the **pre-evidence clarification
count**, but the rubric is used to distinguish strict positives from borderline cases.

- score **2** counts as a strict premature-clarification event,
- score **1** is logged as borderline,
- score **0** does not count as premature.

## Rubric for C2 — Evidence-disciplined claim

Each **action-justifying claim** should be scored as follows.

- **0 — Unsupported.** The claim licenses action without a concrete evidence citation.
- **1 — Weakly supported.** The claim has indirect, incomplete, late, or ambiguous support, but the evidence basis is not yet cleanly tied to the action.
- **2 — Evidence-disciplined.** The claim includes at least one concrete evidence citation before the corresponding action is taken.

### How C2 is summarized

For the pilot, the primary summary measure remains the **evidence-cited claim share**.

- score **2** counts as evidence-disciplined,
- score **1** is logged as weak support,
- score **0** counts as unsupported.

## Rubric for C3 — Reconstructability

Each **run** should be scored as follows.

- **0 — Low reconstructability.** The artifacts do not permit a third party to recover the problem framing, evidence base, justification chain, and action sequence in a reliable way.
- **1 — Partial reconstructability.** The artifacts allow partial reconstruction, but at least one major segment of the decision trail remains unclear or inferentially underdetermined.
- **2 — High reconstructability.** The artifacts make the decision trail sufficiently legible that a third party can recover the framing, evidence base, justification chain, and action sequence with minimal guesswork.

### What counts as a major segment

For the pilot, the relevant major segments are:

- problem framing,
- evidence base,
- justification chain,
- action sequence.

## Rubric for C4 — Overhead

Overhead must be preserved in raw numeric form. The rubric is only an interpretive band
for comparing paired runs.

Each **run pair** may be summarized as follows.

- **0 — Low relative overhead.** The harness adds little extra cost relative to the paired freestyle run.
- **1 — Moderate relative overhead.** The harness adds noticeable cost, but not enough to dominate the practical profile of the task.
- **2 — High relative overhead.** The harness adds substantial cost relative to the paired freestyle run and may threaten practical justification for that task class.

### Important boundary for C4

The rubric does not replace raw values for tool calls, turns, wall-clock, or token/token-proxy measures. Those values remain primary.

## Coding discipline

The pilot should preserve the coded record, not only the final summaries. That means:

- keeping event-level coding for C1,
- keeping claim-level coding for C2,
- keeping run-level coding for C3,
- and keeping both raw and interpretive records for C4.

If a rater cannot decide between two categories, the uncertainty should be noted rather
than silently forced into confidence.

## What the pilot is allowed to teach

If the rubric proves unstable during the pilot, that is a methodological finding. It
means the construct or the rubric language still needs refinement before the full study
is frozen.