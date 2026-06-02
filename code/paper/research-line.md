# Research Line — Engineering of Inference

> **Type:** research-line
> **Status:** stable
> **Depends on:** [concepts/abductive-machine.md](concepts/abductive-machine.md), [concepts/thinking-tools.md](concepts/thinking-tools.md)
> **Used by:** [contribution.md](contribution.md), [thesis.md](thesis.md), [research-question.md](research-question.md)

## The program

The long-horizon research line is the **engineering of inference**: an exercise in
applied epistemology that asks how the conditions of justified machine action can be
designed rather than merely hoped for. In Inquiry, that means converting disciplines of
reasoning into executable engineering artifacts — operators, state contracts, prompts,
and durable traces — that govern when a machine may ask, infer, act, and claim to know.

The generative idea is not simply that philosophy contains interesting old ideas. It is
that philosophy may contain a **preexisting taxonomy of inference operators**:
differentiated procedures for eliciting premises, doubting claims, and moving from
indeterminate situations to warranted assertions. If such a taxonomy can be made
operational, AI engineering gains not only reusable heuristics but a structured design
space for building and comparing inference-governing systems.

## Why now

Until a practical, general, and accessible abductive machine existed, these disciplines
could be taught, exemplified, and argued over, but not embedded into everyday technical
systems and observed under real work conditions. A large language model changes that
condition. It provides a daily, general-purpose engine of fluent abduction that is
powerful enough to matter and undisciplined enough to need governance. That makes
inference-governance an engineering surface rather than a purely philosophical one.

## What would make the line non-trivial

This line matters scientifically only if it yields more than historical reuse. Its value
would lie in three outcomes:

- a reusable taxonomy of operator classes with sharper boundaries than ad hoc
  scaffolding,
- operational implementations whose effects can be isolated and measured,
- and a cumulative research program in which operators can be added, removed, combined,
  and compared across tasks and hosts.

If those outcomes do not materialize, the line collapses into a historically interesting
but scientifically weak source of metaphors.

## Scope of the line vs. the first paper

The research line is broad enough to yield several papers. Candidate future questions
include: which operators transfer across hosts, how operator composition behaves, and
whether operator discipline degrades gracefully under weaker models.

The **first paper** deliberately takes a narrow slice — see [thesis.md](thesis.md) and
[research-question.md](research-question.md). It commits to a small, named set of
operators rather than to "philosophy" in the abstract.

## Explicit out-of-scope for the first paper

- **Self-improvement / antifragility.** Whether a system can evolve its own methodology
  (the DARWIN operator) is a separate, harder claim and is not part of the first paper.
- **Model-capability substitution.** This program does **not** claim that methodology
  lets a small model match a large one. That claim is trivially false and is not made.
  The contribution is about *governing* a capable abductive machine, not replacing
  capability.
- **Memory-as-Code as a thesis.** Repository-local memory is a real design property of
  Inquiry, but here it is treated as a supporting design characteristic, not as the
  research claim.
