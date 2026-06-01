# Research Question — First Paper

> **Type:** question
> **Status:** draft
> **Depends on:** [thesis.md](thesis.md)
> **Used by:** [evidence/evidence-plan.md](evidence/evidence-plan.md)

## Question

Does reifying specific philosophical inference-disciplines as an explicit harness
measurably improve the **evidence-discipline**, **inspectability**, and **human-clarification
economy** of LLM-assisted software work, relative to freestyle use of the same model —
and at what overhead cost?

## Falsifiable claims

Each claim names a mechanism, a measure, and a way to fail.

### C1 — Maieutic economy
The maieutic operator ([operators/maieutics.md](operators/maieutics.md)) reduces
**premature clarification**: fewer questions are asked to the user before repository
evidence has been gathered.
*Fails if* the harness asks as many or more pre-evidence questions than the baseline.

### C2 — Doubt as evidence gate
The methodic-doubt operator ([operators/methodic-doubt.md](operators/methodic-doubt.md))
increases the **share of action-justifying claims that cite concrete evidence** before
the action is taken.
*Fails if* the cited-evidence share is no higher than the baseline.

### C3 — Inspectability / reconstructability
A third party, given only the durable artifacts, can **reconstruct the decision trail**
of a cycle more completely under the harness than under freestyle use.
*Fails if* independent reconstruction is no more complete than for the baseline.

### C4 — Overhead is real and bounded
The harness imposes **measurable overhead** (tool calls, tokens, wall-clock, turns).
The paper reports it honestly and identifies task classes where the overhead is **not**
justified.
*This claim "fails" only by being hidden* — reporting overhead, including unfavorable
cases, is mandatory.

## Comparison frame

The contrafactual is the **same model, same tasks, without the harness** (freestyle
host-native usage). Secondary comparisons against generic scaffolding strengthen the
strong-path argument but are not required for the first paper. See
[evidence/evidence-plan.md](evidence/evidence-plan.md).

## What a positive result would and would not show

A positive result would show that *named inference-disciplines, delivered as a harness,*
change measurable behavior in the predicted direction. It would **not** show
universal superiority, nor that the effect holds for every model, task, or host. Those
are future-paper questions ([research-line.md](research-line.md)).
