# T1 Pilot Pair — Second Scoring Pass

> **Type:** evidence
> **Status:** draft
> **Depends on:** [t1-pilot-first-scoring-pass.md](t1-pilot-first-scoring-pass.md), [../scoring-rubrics.md](../scoring-rubrics.md), [../constructs-and-measures.md](../constructs-and-measures.md)
> **Used by:** [../first-paper-checklist.md](../first-paper-checklist.md), future results section

This file records a second investigator pass over the completed T1 pair. It is **not**
an independent blind rating. It is a conservative stability check run immediately after
the first pass, with a stricter rule: when live observation and durable artifacts do not
support the same confidence level, code the weaker durable-artifact position and record
the instability explicitly.

## Evidence base for the second pass

The second pass uses the same retained surfaces as the first pass:

- [t1-pilot-first-scoring-pass.md](t1-pilot-first-scoring-pass.md)
- the exported H share and H cleanroom artifact set
- the retained F PowerShell transcript
- the final F change surface in `code/cli/test/ape_prompt_test.dart`

No new run evidence is introduced here. The purpose is to test score stability under a
more conservative reading of the already-retained record.

## Stability table

| Construct | First-pass reading | Second-pass reading | Stability |
|---|---|---|---|
| C1 | H `0`, F `0 observed` | H `0`, F `0 observed` | Stable |
| C2 | H `2`, F `2 provisional` | H `2`, F `1` | Unstable in F |
| C3 | H `2`, F `0` | H `2`, F `0` | Stable |
| C4 | pair `2` | pair `2` | Stable |

## C1 — Premature clarification

### Second-pass coding

- **H:** `0`
- **F:** `0 observed`

### Reasoning

The second pass does not surface any new question event that would justify changing the
first coding. Both runs still appear to have gathered repository evidence before moving.
The evidence weakness in F affects reconstructability, but it does not positively create
a premature-clarification event.

## C2 — Evidence-disciplined claim

### Second-pass coding

- **H:** `2`
- **F:** `1`

### Reasoning

#### H

The H record remains strong under the conservative rule. Its action-justifying claims
are durably tied to explicit code locations, targeted test runs, plan artifacts,
run-trace evidence, validation gates, and closure artifacts.

#### F

The live run still looked evidence-first, but the retained durable record does not let a
later reader recover the full claim sequence cleanly enough to preserve the first-pass
`2` with confidence. Under the stricter second-pass rule, F therefore drops to `1`:
there is visible support, but it is incomplete and partly observer-dependent.

### Stability note

This is the main unstable construct in T1. The instability is methodological, not
substantive: it is driven by record asymmetry between H and F rather than by a clear
difference in the visible code-and-test behavior.

## C3 — Reconstructability

### Second-pass coding

- **H:** `2`
- **F:** `0`

### Reasoning

The second pass leaves C3 unchanged.

- H still provides a recoverable trail from framing through evidence, justification,
  commits, trace, and PR handoff.
- F still fails the reconstructability test because the retained artifacts do not let a
  third party recover the internal decision trail without leaning on live observer
  memory.

## C4 — Overhead

### Second-pass coding

- **Pair score:** `2`

### Reasoning

The raw asymmetry that justified the first-pass score is unchanged:

- H preserved `129m 10s` of exported session duration,
- F preserved an observable `27m 59s` window,
- H/F wall-clock remains about `4.62x`,
- and H still carried substantially heavier artifact and process overhead.

The second pass does not reduce that interpretation. It does, however, keep the same
warning as the first pass: some of that extra cost came from post-target closure work,
not only from the harness's evidence discipline.

## What the second pass changes

The second pass narrows one earlier claim:

- The T1 pair no longer supports even a provisional parity reading on C2 unless the
  study is willing to let live observer memory compensate for missing host-native
  artifacts.

Everything else remains materially unchanged:

- no observed C1 difference,
- strong H advantage on C3,
- and high H overhead on C4.

## Method implications

This second pass strengthens the case for the protocol revisions already made after T1.
The pair now shows two different things at once:

1. the harness clearly improves reconstructability,
2. the current freestyle capture path is too weak to support high-confidence claim-level
   coding,
3. and overhead remains high enough that the study must separate common-target work from
   post-target extension work.

## Second-pass decision

The T1 pair is interpretable enough to keep, but not clean enough to freeze the method.
For the next pair, the revised protocol should be treated as mandatory rather than
advisory, especially for:

1. shared scored stop lines,
2. session-export symmetry,
3. and explicit post-target extension recording.