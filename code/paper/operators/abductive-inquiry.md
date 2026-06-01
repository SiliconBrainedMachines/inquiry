# Operator — Abductive Inquiry (DEWEY / Peirce)

> **Type:** operator
> **Status:** draft
> **Depends on:** [../concepts/abductive-machine.md](../concepts/abductive-machine.md), [../concepts/thinking-tools.md](../concepts/thinking-tools.md), [../references.md](../references.md)
> **Used by:** [../research-question.md](../research-question.md) (claim C3)

## Philosophical source

Dewey's pattern of inquiry — the controlled movement from an **indeterminate situation**
to a **warranted assertion** — in *How We Think* [dewey_htwt] and *Logic: The Theory of
Inquiry* [dewey_logic], built on Peirce's account of abduction as the hypothesis-forming
phase of inference [peirce_cp; peirce_dih].

## Inference discipline it encodes

Inquiry, in Dewey's sense, supplies the **shape of the whole movement**: a problem is
first made determinate, hypotheses are formed (abduction), their consequences are worked
out (deduction), and they are tested (induction) until an assertion is *warranted* — i.e.
justified by the conduct of inquiry, not merely asserted. The key engineering property is
that the *trail* of this movement is explicit and reconstructable.

## Mapping to the APE operator

This is the operator that most directly motivates Inquiry's overall cycle and its
Memory-as-Code artifacts. The FSM makes the movement from indeterminate situation
(IDLE/ANALYZE) to warranted assertion (PLAN → EXECUTE → END) explicit and total, and the
durable artifacts (`diagnosis.md`, `plan.md`, traces) record the trail so a third party
can reconstruct *why* each step was warranted (see [docs/architecture.md](../../../docs/architecture.md)).

Where generic scaffolding sequences "plan then execute," Deweyan inquiry adds the
requirement that the result be a *warranted* assertion with a reconstructable trail — not
merely a completed task.

## Falsifiable behavioral signature

The operator predicts a measurable change ([../research-question.md](../research-question.md),
C3): the durable artifacts allow a third party to **reconstruct the decision trail more
completely** than freestyle use of the same model permits.
*The operator's claim fails if independent reconstruction is no more complete.*
