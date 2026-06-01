# Harness over Capability

> **Type:** concept
> **Status:** stable
> **Depends on:** [abductive-machine.md](abductive-machine.md)
> **Used by:** [../thesis.md](../thesis.md), [../research-question.md](../research-question.md)

## Claim

In LLM-assisted software work, the binding constraint on reliability is not the model's
raw capability but the **external control structure** placed around it. A harness that is
explicit, inspectable, and repository-local can produce more disciplined work from the
*same* model than freestyle prompting.

## Argument

A capable abductive machine ([abductive-machine.md](abductive-machine.md)) will produce
plausible output regardless of whether its inference was disciplined. The failure modes
that matter in practice — acting on unverified assumptions, asking the user prematurely,
losing the decision trail across turns — are not capability failures. They are
**governance failures**. More capability does not remove them; it produces more fluent
versions of them.

This is why the harness is the practical arm (claim B) of the thesis
([../thesis.md](../thesis.md)). The operators ([../concepts/thinking-tools.md](thinking-tools.md))
define *what discipline to impose*; the harness defines *how to impose it repeatably and
how to measure whether it worked*.

## What "harness" means operationally

Concretely, in Inquiry the harness is the finite-state control system around the host:
explicit state, total transition contract, inspectable prompt assembly, deployable
operators, and durable artifacts (see [docs/architecture.md](../../../docs/architecture.md)).
The research relevance is narrower than the full system: the harness is what makes the
comparison ([../research-question.md](../research-question.md)) possible, because it can
be switched **on or off over the same model and the same tasks**.

## Boundary

This concept does **not** claim that structure can substitute for capability. A weaker
model with a better harness is not expected to match a stronger model — that substitution
claim is explicitly rejected in [../research-line.md](../research-line.md). The claim is
strictly *within-model*: given a fixed capable model, governance is the lever.
