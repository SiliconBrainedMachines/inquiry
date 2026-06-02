# Evidence Plan — First Paper

> **Type:** evidence
> **Status:** draft
> **Depends on:** [../contribution.md](../contribution.md), [../thesis.md](../thesis.md), [../research-question.md](../research-question.md)
> **Used by:** the assembled paper draft

## Principle

Evidence outranks narrative. Traces, metrics, and authoritative phase artifacts carry
more weight than retrospective storytelling. The harness already emits most of what is
needed; the job is to make it **citation-ready**.

## Primary evidence surfaces

Produced by real Inquiry cycles (see [docs/architecture.md](../../../docs/architecture.md)):

- `cleanrooms/<branch>/analyze/diagnosis.md` — evidence and claims at ANALYZE
- `cleanrooms/<branch>/plan.md` — the warranted plan
- `cleanrooms/<branch>/run_trace.yaml` — transitions, retries, host activity
- `cleanrooms/<branch>/pre_pr_inspection.md` — closure checks
- `.inquiry/metrics.yaml`, `metrics_snapshot.yaml` — tool volume, tokens, time, cached share
- Git, issue, and release history — independent corroboration of the trail

## Comparison design

The contrafactual is **same model, same tasks, harness on vs. off**.

- **Condition H (harness):** task executed through the Inquiry FSM and operators.
- **Condition F (freestyle):** the same task given to the same model host-native, without
  the harness.
- Tasks are drawn from representative repository work (bug fix, feature slice,
  refactor) with a mix of clear and underspecified cases.

A secondary condition (generic scaffolding, operators stripped of their named
constraints) can be added later to harden the strong-path argument
([../contribution.md](../contribution.md)); it is not required for the first paper.

## Measures, mapped to claims

| Claim | Measure | Source |
|---|---|---|
| C1 maieutic economy | count of clarification questions issued before any evidence-gathering | trace + transcript |
| C2 doubt gate | share of action-justifying claims with a concrete evidence citation | diagnosis/plan + transcript |
| C3 inspectability | completeness of independent decision-trail reconstruction (blind rater) | durable artifacts |
| C4 overhead | tool calls, tokens, wall-clock, turns per task | metrics.yaml |

## Honesty constraints

- Report **C4 overhead unconditionally**, including task classes where the harness costs
  more than it returns. A paper that reports only gains is not credible.
- Distinguish **operator effect** from **harness effect** wherever the design allows, so
  the strong-path claim (named operators matter) is not silently carried by generic
  structure.
- Treat null results as results. If C1–C3 do not move, the thesis is weakened or refuted,
  and the paper says so.

## Threats to validity (to address in the draft)

- **Small N / single repository** — limits generalization; state it plainly.
- **Author-run cycles** — risk of favorable execution; mitigate with pre-registered task
  list and blind reconstruction rating.
- **Model and host drift** — pin model/host versions per run; record them in the trace.
- **Construct validity of "philosophical"** — the secondary stripped-operator condition
  is the cleanest defense; until it exists, argue the construct, do not overclaim it.
