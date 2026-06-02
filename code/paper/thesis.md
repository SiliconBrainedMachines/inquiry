# Thesis — First Paper

> **Type:** thesis
> **Status:** draft
> **Depends on:** [research-line.md](research-line.md), [contribution.md](contribution.md), [concepts/abductive-machine.md](concepts/abductive-machine.md), [concepts/harness-vs-capability.md](concepts/harness-vs-capability.md)
> **Used by:** [research-question.md](research-question.md), [evidence/evidence-plan.md](evidence/evidence-plan.md)

## Statement

> A small library of philosophically individuated inference operators — Socratic
> maieutics, Cartesian methodic doubt, and Deweyan inquiry — can be reified as
> explicit harness rules over a large language model, and doing so yields software work
> that is **more evidence-disciplined, more reconstructable, and less prone to
> premature clarification** than freestyle use of the same model — at a measurable
> overhead cost.

## Why this thesis is not trivial

The thesis does not claim merely that old ideas can still help. It claims that
philosophical lineage supplies a better-differentiated operator taxonomy than generic
scaffolding alone, and that this taxonomy can be operationalized and tested. That is
the non-trivial contribution stated in [contribution.md](contribution.md).

## The two ideas it fuses

The thesis is a deliberate synthesis of two claims that are weak alone and strong
together:

- **A — Philosophy as a differentiated operator library.** The named operators are not
  decoration; each encodes a specific *governance rule over inference*
  ([operators/maieutics.md](operators/maieutics.md),
  [operators/methodic-doubt.md](operators/methodic-doubt.md),
  [operators/abductive-inquiry.md](operators/abductive-inquiry.md)). They matter only
  if their boundaries are sharper than ad hoc scaffolding and their behavioral effects
  can be measured.
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
- It does not claim historical pedigree is itself evidence.
- It does not hide cost: the overhead claim is part of the thesis, not an afterthought.

## The decisive objection it must answer

A reviewer will ask: *is "philosophical" anything more than a branding metaphor over
what is already called structured prompting or agent scaffolding?* The paper answers on
the **strong path**: each operator is shown to impose a *specific, named behavioral
constraint* on the model's abduction that generic scaffolding does not specify, and that
constraint is measured ([research-question.md](research-question.md)). If the operators
cannot be distinguished from generic scaffolding in either specification or behavior,
the thesis fails — which is what makes it a thesis.
