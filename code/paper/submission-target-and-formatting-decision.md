# Submission Target and Formatting Decision

> **Type:** plan
> **Status:** stable
> **Depends on:** [first-paper-shell.md](first-paper-shell.md), [thesis-narrowing-decision.md](thesis-narrowing-decision.md), [limitations-and-threats-to-validity.md](limitations-and-threats-to-validity.md), [results-section-draft.md](results-section-draft.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), future abstract, future introduction, future manuscript draft

This document fixes the working publication target for the first paper early enough to
prevent avoidable structural churn. It does not lock a specific CFP, but it does lock
the paper family and the controlling format assumptions the next drafting steps should
honor.

## Decision

Write the first paper as a **short workshop-style software engineering / AI engineering
paper**, not as a full empirical conference paper or journal article.

The controlling format assumption is an **ACM-like two-column short-paper shape** with a
conservative main-text budget of about **7-8 pages plus references**. If a later venue
allows more room, that should be treated as slack rather than as permission to widen the
claim.

## Why this is the right target now

The current paper is strongest as a bounded methodological pilot with one durable
practical finding, not as a mature broad-claim empirical result.

Three facts force that choice.

1. The thesis has already been narrowed. The pilot no longer supports presenting the
   paper as a strong-path empirical win for the named operators.
2. The evidence base is still pilot-bounded: three tasks, one repository,
   Windows-coupled execution, and protocol maturation across the pilot.
3. The most stable positive result is high harness overhead, while C1-C3 are null or
   mixed once capture symmetry improves.

That package is suitable for a short paper whose contribution is: a research program, a
concrete artifact, a pilot method, a bounded comparative result, and a clear warning
against overclaiming. It is not yet suitable for a venue that expects strong external
validity or a settled causal claim about operator effects.

## What this target excludes

Do not write this manuscript as if it were any of the following.

- A full empirical software-engineering paper claiming stable behavioral superiority.
- A benchmark-heavy LLM paper centered on model capability gains.
- A purely philosophical paper where the artifact and pilot method are secondary.

Those shapes would pressure the manuscript into claims the current corpus does not
authorize.

## Controlling formatting constraints

The next drafting steps should obey these constraints.

### 1. Section compression

The paper should collapse into five manuscript blocks:

1. problem and contribution,
2. theoretical framing,
3. artifact and method,
4. pilot results,
5. limits and discussion.

The atomic documents remain more granular than the manuscript, but the manuscript should
compose them into this tighter short-paper shape.

### 2. Theory budget

The philosophical framing must stay functional and brief. Name the three operators,
state what governance question each answers, and move quickly to why that matters for a
testable harness. Do not spend scarce space on extended lineage exposition.

### 3. Results budget

Results should be carried by one controlling cross-task summary table and a compact
claim-by-claim narrative. The overhead result must remain visible. Detailed per-task
scoring logic belongs in the repository documents, not in the main body.

### 4. Limits must stay in-body

Threats to validity are not appendix material for this version. Because the paper's main
intellectual risk is overclaiming, the limits and narrowing decision must appear in the
main manuscript.

### 5. Abstract and introduction constraints

The abstract and introduction should be written for a short paper:

- lead with the engineering problem of inference governance,
- state the artifact under study and the paired pilot design,
- report the narrowed result honestly,
- and avoid promising a broad win for philosophical operators.

## Revision rule

Reopen this decision only if one of the following happens.

1. A concrete target venue imposes materially different format constraints.
2. A later evidence phase substantially strengthens external validity and justifies a
   full empirical-paper shape.
3. The paper's claim changes from pilot-methodological to something broader.

Until one of those conditions holds, this short-paper target should control manuscript
assembly.