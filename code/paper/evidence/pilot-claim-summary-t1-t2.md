# Pilot Claim Summary — T1 and T2

> **Type:** evidence
> **Status:** draft
> **Depends on:** [t1-pilot-second-scoring-pass.md](t1-pilot-second-scoring-pass.md), [t2-pilot-second-scoring-pass.md](t2-pilot-second-scoring-pass.md), [../research-question.md](../research-question.md), [../thesis.md](../thesis.md)
> **Used by:** [../first-paper-checklist.md](../first-paper-checklist.md), future results section

This file is an interim claim-by-claim synthesis across the first two pilot task pairs.
It is not the final results section. T3 is still pending, so the purpose here is to
state what the retained evidence already supports, what remains mixed, and which parts
of the thesis should still be treated as undecided.

## Scoring basis

The controlling readings in this summary are the second-pass scores for T1 and T2,
because they apply the stricter durable-artifact-first rule.

| Claim | T1 second pass | T2 second pass | Interim pattern |
|---|---|---|---|
| C1 | H `0`, F `0 observed` | H `0`, F `0` | No observed advantage for either condition |
| C2 | H `2`, F `1` | H `2`, F `2` | Mixed; T1 favors H, T2 is parity |
| C3 | H `2`, F `0` | H `2`, F `2` | Mixed; T1 favors H, T2 is parity |
| C4 | pair `2` | pair `2` | Stable high overhead for H |

## Claim-by-claim synthesis

## C1 — Premature clarification

### Observed pattern

Neither T1 nor T2 shows an observed C1 advantage for the harness. In both pairs, the
visible runs moved from packet intake into repository inspection and bounded execution
without a premature clarification event.

### Interim reading

After two pilot tasks, the current evidence does not support a positive C1 claim for
the harness. That does not falsify C1 globally, but it does mean the pilot has not yet
shown the predicted maieutic advantage on these tasks.

## C2 — Evidence-disciplined claim

### Observed pattern

- T1 favors H under the conservative reread because the freestyle durable record was too
  thin to preserve a full claim sequence with high confidence.
- T2 returns to parity because the revised protocol preserved enough durable freestyle
  evidence to sustain the same claim-level coding under the stricter rule.

### Interim reading

The current pilot does not yet show a stable harness advantage on C2. What it does show
is more specific:

1. weak freestyle capture can collapse C2 confidence even when the live run looked
   evidence-first,
2. stronger protocol discipline can repair that measurement problem,
3. and once repaired, bounded tasks may show parity rather than a harness lead.

This means C2 is currently a mixed pilot claim. The evidence is strong enough to say
that record quality affects whether C2 can be scored cleanly, but not yet strong enough
to say that the harness consistently improves evidence-discipline over freestyle.

## C3 — Reconstructability

### Observed pattern

- T1 shows a clear H advantage because the harness left a reconstructable decision trail
  while freestyle did not.
- T2 shows parity because both conditions preserved enough durable evidence for third-
  party reconstruction.

### Interim reading

The pilot supports a weaker reconstructability claim than the thesis currently states.
So far, the harness clearly guarantees stronger reconstructability when the baseline
capture path is weak, but T2 shows that freestyle can become reconstructable too when
the protocol forces durable export symmetry.

That makes C3 mixed rather than decisively positive for H across the first two tasks.

## C4 — Overhead

### Observed pattern

C4 is the most stable result in the pilot so far.

- T1: H exported duration `129m 10s` versus an observable F window of `27m 59s`, with
  about `4.62x` relative wall-clock and a much larger artifact/process surface.
- T2: H scored wall-clock `68m 09s` and exported duration `70m 18s` versus F `6m 56s`
  and `7m 36s`, with `9.25x` exported-duration asymmetry and much heavier share volume.

### Interim reading

The pilot strongly supports C4 as currently framed: harness overhead is real,
observable, and large enough that it must be reported as a first-class outcome rather
than treated as nuisance cost.

T1 leaves some ambiguity about how much of the overhead came from post-target extension
work, but T2 removes most of that ambiguity. Even after protocol cleanup and a shared
stop line, H remains substantially more expensive than F.

## What T1 and T2 jointly support

After two tasks, the most defensible interim reading is:

1. the pilot clearly supports the overhead claim,
2. it does not yet support a positive harness advantage on premature clarification,
3. it shows mixed evidence on evidence-discipline,
4. and it shows mixed evidence on reconstructability once freestyle capture is made
   methodologically stronger.

This is enough to support a methodological conclusion even before T3: the pilot has
already shown that protocol design changes the observable comparative story.

## Strong-path status after T1 and T2

The current evidence does not yet justify a strong-path results claim for the first
paper.

What is currently defensible is a weaker interim statement:

- the harness reliably externalizes process and preserves a scoreable record,
- weak freestyle capture can make the baseline look worse than it really is,
- improved capture symmetry can remove some apparent H advantages on C2 and C3,
- and the harness cost remains large enough that any practical benefit must be shown on
  task classes where that extra structure is actually needed.

T3 is therefore important not merely as another data point, but as the next test of
whether T2's parity pattern generalizes or whether T1 and T2 are separating different
task classes.

## Immediate use in the paper workflow

This document is ready to support two near-term moves:

1. a results-section scaffold that reports pilot findings claim by claim without
   overclaiming,
2. and a later decision on whether the first paper should retain the strong-path thesis
   framing or explicitly narrow it.