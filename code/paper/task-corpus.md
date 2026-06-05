# Task Corpus — Pilot for the First Paper

> **Type:** method
> **Status:** draft
> **Depends on:** [experimental-protocol.md](experimental-protocol.md), [constructs-and-measures.md](constructs-and-measures.md), [research-question.md](research-question.md)
> **Used by:** future scoring-rubrics document, ongoing pilot workflow

This document defines the approved task corpus for the pilot stage of the first paper.
The pilot corpus is intentionally small. Its role is not to establish broad external
validity, but to stress the method across a minimal range of task types while keeping
execution and interpretation manageable.

## Selection decisions already fixed

The pilot corpus follows these agreed constraints:

- it contains **three tasks**,
- it mixes **one bug fix, one feature slice, and one refactor**,
- it uses **historical tasks from this repository** rather than newly invented ones,
- and each task is **small enough to be completed in a single session**.

## Selection rationale

The corpus is designed to create minimal but meaningful variation.

- The **bug fix** tests whether the harness changes evidence gathering and clarification
  behavior when the problem is primarily corrective.
- The **feature slice** tests whether the harness changes behavior when a small new
  capability must be added with explicit expected behavior.
- The **refactor** tests whether the harness changes behavior when the goal is structural
  improvement rather than new outward functionality.

Using historical tasks from the repository keeps the pilot grounded in real work rather
than synthetic prompts, while keeping the task statements close to the kinds of work the
project already performs.

## Approved pilot tasks

### T1 — Bug fix

- **Task type:** bug fix
- **Historical reference:** commit `4739cf1`
- **Title:** Fix Windows ape prompt path expectations
- **Why selected:** the task is narrow, clearly corrective, and small enough to be
  rerun cleanly. After preflight refinement, it is framed as a Windows path-
  canonicalization mismatch in the ape prompt test oracle, reproduced through a
  repository accessed via junction path versus canonical git root. That keeps the task
  bounded while still offering a good pilot case for checking whether the harness
  reduces premature clarification and produces a clearer evidence trail in a debugging
  setting.

### T2 — Feature slice

- **Task type:** feature slice
- **Historical reference:** issue `#170`, commit `3e0f2d8`
- **Title:** Support root version flags
- **Why selected:** the task adds a bounded user-facing capability with a crisp expected
  behavior. It is a suitable pilot case for observing how the harness frames intent,
  justifies the change, and documents evidence for a small feature addition.

### T3 — Refactor

- **Task type:** refactor
- **Historical reference:** commit `447cf29`
- **Title:** Rename state.yaml fields `phase` -> `state`, `task` -> `issue`
- **Why selected:** the task is structural rather than feature-oriented, but still
  limited in scale. It is a suitable pilot case for studying whether the harness yields
  more reconstructable justification when the change is semantic cleanup instead of a bug
  fix or feature addition.

## Corpus boundaries

This corpus is approved for the **pilot only**. It is not yet the final corpus for the
full study.

The pilot should use these tasks to test whether:

- the protocol can be followed cleanly,
- the constructs can be scored without ambiguity,
- and the resulting records are rich enough to support C1 through C4.

If the pilot shows that one task is poorly specified, too easy, too noisy, or otherwise
methodologically unhelpful, the corpus may be revised before the full study is frozen.

## What still belongs elsewhere

- The exact **task packets** for each run still need to be prepared under the protocol.
- The **scoring method** for each construct belongs in the future scoring-rubrics
  document.
- The final judgment about whether this corpus is sufficient for the full paper belongs
  after the pilot, not before it.