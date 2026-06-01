# Research Line — Engineering of Inference

> **Type:** research-line
> **Status:** stable
> **Depends on:** [concepts/abductive-machine.md](concepts/abductive-machine.md), [concepts/thinking-tools.md](concepts/thinking-tools.md)
> **Used by:** [thesis.md](thesis.md), [research-question.md](research-question.md)

## The program

The long-horizon research line is the **engineering of inference**: taking disciplines
of reasoning developed by philosophy and reifying them as executable engineering
artifacts — states, contracts, prompts, and protocols — that govern how a machine
reasons.

The generative idea is older than this project and simple to state: **philosophy can be
turned into engineering of thought.** Methods such as Socratic maieutics, Cartesian
methodic doubt, and Deweyan inquiry are not merely historical doctrines; they are
*procedures for disciplining inference*. The new fact that makes the program timely is
the arrival of a practical abductive machine — the large language model
([concepts/abductive-machine.md](concepts/abductive-machine.md)).

## Why now

For most of history these inference-disciplines had only human practitioners. They were
taught, not executed. An LLM changes the situation: it produces fluent abduction at
scale but does not natively govern it. That creates, for the first time, a concrete
substrate on which inference-disciplines can be **mechanized and measured** rather than
only described.

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
