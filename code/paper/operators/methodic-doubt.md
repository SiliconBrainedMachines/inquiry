# Operator — Methodic Doubt (DESCARTES)

> **Type:** operator
> **Status:** draft
> **Depends on:** [../concepts/thinking-tools.md](../concepts/thinking-tools.md), [../references.md](../references.md)
> **Used by:** [../research-question.md](../research-question.md) (claim C2)

## Philosophical source

Cartesian methodic doubt — the deliberate suspension of assent to anything that can be
doubted, retaining only what survives — in Descartes' *Discourse on the Method* [descartes_discourse]
and *Meditations on First Philosophy* [descartes_meditations]. The method is procedural,
not skeptical for its own sake: doubt is a *filter* applied to reach a defensible
foundation for action.

## Inference discipline it encodes

Methodic doubt is a **gate over what may be treated as established**. Before a belief is
allowed to justify an action, it must survive deliberate doubt. Applied to an abductive
machine ([../concepts/abductive-machine.md](../concepts/abductive-machine.md)), this
directly counters its weakest tendency: acting on plausible-but-unverified hypotheses.

## Mapping to the APE operator

In Inquiry, ANALYZE/PLAN cognition is gated by **evidence discipline**: claims that
justify a downstream action must be backed by concrete, cited repository evidence before
the action proceeds, and authoritative artifacts (`diagnosis.md`, `plan.md`) record what
was established (see [docs/architecture.md](../../../docs/architecture.md)). This is
methodic doubt as an engineering gate: *plausible is not enough; it must survive
doubt and carry a citation.*

Generic scaffolding says "use evidence." Methodic doubt specifies the gate's position —
**before action** — and its pass condition — **survives deliberate doubt, evidenced**.

## Falsifiable behavioral signature

The operator predicts a measurable change ([../research-question.md](../research-question.md),
C2): a **higher share of action-justifying claims that cite concrete evidence** before
the action is taken, relative to freestyle use of the same model.
*The operator's claim fails if the cited-evidence share is not increased.*
