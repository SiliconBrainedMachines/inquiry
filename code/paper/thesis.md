# Thesis — First Paper

> **Type:** thesis
> **Status:** draft
> **Depends on:** [research-line.md](research-line.md), [concepts/abductive-machine.md](concepts/abductive-machine.md), [concepts/harness-vs-capability.md](concepts/harness-vs-capability.md)
> **Used by:** [research-question.md](research-question.md), [evidence/evidence-plan.md](evidence/evidence-plan.md)

## Statement

> Disciplines of inference of philosophical lineage — Socratic maieutics, Cartesian
> methodic doubt, and Deweyan inquiry — can be **reified as an explicit, finite,
> inspectable harness** over a large language model, and doing so produces software
> work that is **more evidence-disciplined, more inspectable, and more economical in
> its use of human clarification** than freestyle use of the same model — at a
> measurable overhead cost that is sometimes not justified.

## The two ideas it fuses

The thesis is a deliberate synthesis of two claims that are weak alone and strong
together:

- **A — Philosophy as engineering of thought (the generative idea).** The named
  operators are not decoration; each encodes a specific *governance rule over inference*
  ([operators/maieutics.md](operators/maieutics.md),
  [operators/methodic-doubt.md](operators/methodic-doubt.md),
  [operators/abductive-inquiry.md](operators/abductive-inquiry.md)). They supply the
  discipline an abductive machine lacks.
- **B — Harness over capability (the practical arm).** The bottleneck in LLM-assisted
  software work is the external control structure, not raw model capability
  ([concepts/harness-vs-capability.md](concepts/harness-vs-capability.md)). A harness is
  what makes the operators deliverable, repeatable, and **falsifiable by comparison**.

A without B is a manifesto. B without A is generic scaffolding. The contribution lives
in the hinge: **specific inference-disciplines, delivered as a harness, with a
contrafactual that can lose.**

## What the thesis is careful not to claim

- It does not claim Inquiry is the most capable coding agent.
- It does not claim "philosophy" in general helps; it commits to three named operators.
- It does not hide cost: the overhead claim is part of the thesis, not an afterthought.

## The decisive objection it must answer

A reviewer will ask: *is "philosophical" anything more than a branding metaphor over
what is already called structured prompting or agent scaffolding?* The paper answers on
the **strong path**: each operator is shown to impose a *specific, named behavioral
constraint* on the model's abduction that generic scaffolding does not specify, and that
constraint is measured ([research-question.md](research-question.md)). If those measures
come out null, the thesis fails — which is what makes it a thesis.
