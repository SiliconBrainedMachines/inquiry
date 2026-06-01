# Operator — Maieutics (SOCRATES)

> **Type:** operator
> **Status:** draft
> **Depends on:** [../concepts/thinking-tools.md](../concepts/thinking-tools.md), [../references.md](../references.md)
> **Used by:** [../research-question.md](../research-question.md) (claim C1)

## Philosophical source

Socratic maieutics — the "midwife" method — in Plato's *Theaetetus* [plato_theaetetus,
148e–151d]. Socrates claims he produces no doctrine himself; he draws out and tests what
the interlocutor already implicitly holds, discarding what cannot withstand examination.

## Inference discipline it encodes

Maieutics is, operationally, a **discipline over questioning**: it governs *when to
elicit a premise and when one is already available*. Its essential, often-missed feature
is the **stop condition**. The midwife does not ask endlessly; she asks only what is
needed to bring forth and test what is latent.

## Mapping to the APE operator

In Inquiry, the ANALYZE operator (SOCRATES) is bound to an **evidence-first** rule:
gather bounded repository and cycle evidence *before* questioning the user, and ask the
user only when the evidence base cannot settle the question. This is the maieutic stop
condition turned into a control rule (see [docs/architecture.md](../../../docs/architecture.md)).

This is the contrast with generic scaffolding. "Ask clarifying questions if needed"
leaves *needed* undefined. Maieutics defines it: a question is licensed only when latent
evidence has been drawn out first and found insufficient.

## Falsifiable behavioral signature

The operator predicts a measurable change ([../research-question.md](../research-question.md),
C1): **fewer premature clarification questions** — questions issued to the user before
repository evidence has been gathered — relative to freestyle use of the same model.
*The operator's claim fails if pre-evidence question counts are not reduced.*
