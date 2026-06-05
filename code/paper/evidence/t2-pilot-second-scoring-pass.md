# T2 Pilot Pair — Second Scoring Pass

> **Type:** evidence
> **Status:** draft
> **Depends on:** [t2-pilot-first-scoring-pass.md](t2-pilot-first-scoring-pass.md), [../scoring-rubrics.md](../scoring-rubrics.md), [../constructs-and-measures.md](../constructs-and-measures.md)
> **Used by:** [../first-paper-checklist.md](../first-paper-checklist.md), future results section

This file records a second investigator pass over the completed T2 pair. It is **not**
an independent blind rating. It is a conservative stability check run immediately after
the first pass, with the same stricter rule used after T1: when live observation and
durable artifacts do not support the same confidence level, code the weaker durable
position and record any instability explicitly.

## Evidence base for the second pass

The second pass uses the same retained surfaces as the first pass:

- [t2-pilot-first-scoring-pass.md](t2-pilot-first-scoring-pass.md)
- the exported H share and H cleanroom artifact set
- the exported F share and copied F session-state transcript
- the focused/full validation logs and final status snapshots for both conditions

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

The second pass does not surface any question event that would justify changing the
first coding. Both runs still show a direct progression from bounded packet intake into
repository inspection and execution without asking the user for clarifying input.

## C2 — Evidence-disciplined claim

### Second-pass coding

- **H:** `2`
- **F:** `2`

### Reasoning

#### H

The H record remains strong under the conservative rule. Its action-justifying claims
are durably tied to issue framing, analysis artifacts, plan artifacts, validation logs,
the run trace, and the exported share.

#### F

Unlike T1, the stricter durable-artifact-first rule does not force a downgrade. The F
run now preserves the decisive claim sequence in durable form: the share shows the
targeted reads leading into `normalizeInquiryArgs`, and the focused/full validation plus
status snapshot preserve the bounded closure claim at the shared stop line.

### Stability note

T2 does not reproduce the C2 instability seen in T1. The post-T1 protocol revisions
appear to have repaired the main source of uncertainty by making the freestyle record
durable enough to support claim-level coding.

## C3 — Reconstructability

### Second-pass coding

- **H:** `2`
- **F:** `2`

### Reasoning

The second pass leaves C3 unchanged.

- H still provides a recoverable trail from framing through analysis, plan, bounded
  code change, validation, and trace.
- F still provides a recoverable trail from problem framing through bounded edit,
  validation, and final status because the exported share and copied session-state
  artifacts make the internal run legible enough for third-party reconstruction.

The second pass therefore strengthens the claim that T2 is methodologically cleaner
than T1 on reconstructability, not merely provisionally better.

## C4 — Overhead

### Second-pass coding

- **Pair score:** `2`

### Reasoning

The raw asymmetry that justified the first-pass score is unchanged:

- H preserved a `68m 09s` scored stop-line window versus `6m 56s` for F,
- exported-session duration remains `70m 18s` versus `7m 36s`,
- observable share volume remains `119` Copilot turns / `491` tool-result blocks for H
  versus `7` / `46` for F,
- and H still carried substantially heavier artifact and process overhead.

The second pass does not reduce that interpretation. It strengthens it slightly by
showing that the overhead remains high even after excluding post-target release drift as
the main explanation.

## What the second pass changes

The second pass does not materially change any T2 score.

What it does change is the confidence level of the methodological reading:

- T2 now supports a stable parity reading on C2 and C3,
- the main durable difference between conditions is overhead rather than evidentiary
  asymmetry,
- and the protocol revisions introduced after T1 appear to have worked for this task
  class.

## Method implications

This second pass strengthens the case that the current pilot protocol is becoming
usable rather than merely exploratory.

T2 now shows three important things at once:

1. the harness still improves explicit externalization of process,
2. freestyle can now be scored conservatively without collapsing on C2 or C3,
3. and overhead remains high enough that the practical justification for the harness
   will depend on whether that extra structure is needed for a given task class.

## Second-pass decision

The T2 pair is interpretable enough to keep as a method-stabilizing pilot case. Unlike
T1, it does not force a downgrade under a conservative reread. The remaining open
question is therefore not whether T2 is scoreable, but whether future pairs continue to
show the same C2/C3 stability while preserving a lower or at least better-justified H
overhead profile.