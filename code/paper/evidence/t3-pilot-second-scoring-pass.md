# T3 Pilot Pair — Second Scoring Pass

> **Type:** evidence
> **Status:** draft
> **Depends on:** [t3-pilot-first-scoring-pass.md](t3-pilot-first-scoring-pass.md), [../scoring-rubrics.md](../scoring-rubrics.md), [../constructs-and-measures.md](../constructs-and-measures.md)
> **Used by:** [../first-paper-checklist.md](../first-paper-checklist.md), future results section

This file records a second investigator pass over the completed T3 pair. It is **not**
an independent blind rating. It is a conservative stability check run immediately after
the first pass, with the same stricter rule used after T1 and T2: when live observation
and durable artifacts do not support the same confidence level, code the weaker durable
position and record any instability explicitly.

## Evidence base for the second pass

The second pass uses the same retained surfaces as the first pass:

- [t3-pilot-first-scoring-pass.md](t3-pilot-first-scoring-pass.md)
- the exported H share and H cleanroom artifact set
- the exported F share plus copied F validation/status/deviation artifacts
- the pair-capture sheet and preserved first-attempt/relaunch records for both conditions

No new run evidence is introduced here. The purpose is to test score stability under a
more conservative reading of the already-retained record.

## Stability table

| Construct | First-pass reading | Second-pass reading | Stability |
|---|---|---|---|
| C1 | H `0`, F `0` | H `0`, F `0` | Stable |
| C2 | H `2`, F `2` | H `2`, F `2` | Stable |
| C3 | H `2`, F `2` | H `2`, F `2` | Stable |
| C4 | pair `2` | pair `2` | Stable |

## C1 — Premature clarification

### Second-pass coding

- **H:** `0`
- **F:** `0`

### Reasoning

The conservative reread does not surface any question event that would justify changing
the first coding. Both conditions still move from packet intake into repository
inspection, bounded execution, and validation without asking the user for clarifying
input.

## C2 — Evidence-disciplined claim

### Second-pass coding

- **H:** `2`
- **F:** `2`

### Reasoning

#### H

The H record remains strong under the conservative rule. The decisive action claims are
durably tied to issue framing, analysis artifacts, the plan, phase4 validation logs,
the run trace, and the exported share.

#### F

The stricter durable-artifact-first rule does not force a downgrade. The F record now
retains the decisive claim sequence durably: the canonical share shows the bounded read
set and edit set, the copied focused/full validation logs preserve the shared stop line,
and the status/deviation bundle makes the relaunch and artifact-capture irregularities
explicit rather than hidden.

### Stability note

T3 does not reintroduce the C2 instability seen in T1. Even with a preserved first
attempt, a relaunch, and a post-validation artifact glitch, the retained F evidence is
still strong enough to support the same claim-level coding as H.

## C3 — Reconstructability

### Second-pass coding

- **H:** `2`
- **F:** `2`

### Reasoning

The second pass again leaves C3 unchanged.

- H still provides a recoverable trail from issue framing through analysis, plan,
  bounded code change, validation, and trace.
- F still provides a recoverable trail from bounded framing through edit, validation,
  relaunch accounting, and final status because the canonical share and copied fallback
  artifacts make the internal run legible enough for third-party reconstruction.

T3 is therefore closer to T2 than to T1 on reconstructability: the retained freestyle
record is thinner than H, but not too thin to score conservatively.

## C4 — Overhead

### Second-pass coding

- **Pair score:** `2`

### Reasoning

The raw asymmetry that justified the first-pass score is unchanged:

- H preserved an `81m 20s` scored stop-line window versus `8m 11s` for F,
- exported-session duration remains `71m 09s` versus `8m 11s`,
- observable share volume remains `32` Copilot turns / `525` tool-result blocks for H
  versus `9` / `39` for F,
- and H still carried substantially heavier artifact, relaunch, and process overhead.

The conservative reread does not soften that interpretation. If anything, it strengthens
it by showing that high H overhead persists even in a pair where both conditions remain
fully scoreable under the stricter durable-artifact-first rule.

## What the second pass changes

The second pass does not materially change any T3 score.

What it does change is the confidence level of the methodological reading:

- T3 remains parity on C2 and C3 under conservative rereading,
- the main durable asymmetry between conditions is still overhead,
- and substantial procedural deviation can occur without collapsing scoreability when
  both conditions preserve strong durable exports.

## Method implications

This second pass strengthens the case that the current pilot protocol is now producing
usable comparative evidence rather than merely exploratory anecdotes.

T3 now shows three important things at once:

1. the harness still guarantees explicit externalization of process,
2. freestyle can remain conservatively scoreable even after a relaunch and artifact
   irregularity when durable capture is preserved,
3. and overhead remains high enough that any defense of the harness must justify that
   cost on task classes where the extra structure is actually necessary.

## Second-pass decision

The T3 pair is interpretable enough to keep as a method-stabilized pilot case. Unlike
T1, it does not force a downgrade under a conservative reread. The main remaining paper
question is therefore no longer whether T3 is scoreable, but what the three-task pilot
now jointly says about the thesis once T1, T2, and T3 are synthesized on the controlling
second-pass readings.