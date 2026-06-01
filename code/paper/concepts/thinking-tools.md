# Thinking Tools as Disciplines of Inference

> **Type:** concept
> **Status:** stable
> **Depends on:** [abductive-machine.md](abductive-machine.md), [../references.md](../references.md)
> **Used by:** [../thesis.md](../thesis.md), [../operators/maieutics.md](../operators/maieutics.md), [../operators/methodic-doubt.md](../operators/methodic-doubt.md), [../operators/abductive-inquiry.md](../operators/abductive-inquiry.md)

## Claim

The philosophical methods Inquiry uses are best understood not as doctrines but as
**disciplines of inference**: explicit procedures for governing how a reasoner moves
from an unsettled situation to a justified conclusion. This reframing is what lets them
be reified as engineering artifacts.

## The reframing

"Thinking tool" is precise here. A tool is defined by what it *does to* a process, not by
who invented it. Each operator answers a different governance question that an abductive
machine ([abductive-machine.md](abductive-machine.md)) does not answer for itself:

| Operator | Source | Governance question it answers |
|---|---|---|
| Maieutics | Plato, *Theaetetus* [plato_theaetetus] | When should the reasoner seek another premise, and when does it already have enough? |
| Methodic doubt | Descartes, *Discourse* / *Meditations* [descartes_discourse; descartes_meditations] | What may be treated as established before acting? |
| Inquiry | Dewey, *How We Think* / *Logic* [dewey_htwt; dewey_logic]; Peirce [peirce_cp] | How does one move from an indeterminate situation to a warranted assertion? |

The lineage is not the argument; the **function** is. The philosophical pedigree explains
why these procedures are unusually well-developed — they are the distilled output of long
practice — but the operational claim stands on what each procedure *constrains*.

## Why "philosophical" is not decoration

The decisive test ([../thesis.md](../thesis.md)) is whether the adjective adds anything
measurable beyond "structured." It does, on the strong path, because each operator
specifies a *named constraint* that generic scaffolding leaves unspecified:

- Generic scaffolding says "ask clarifying questions if needed." Maieutics specifies a
  *stop condition* on questioning ([../operators/maieutics.md](../operators/maieutics.md)).
- Generic scaffolding says "use evidence." Methodic doubt specifies a *gate*: nothing is
  acted on until it survives deliberate doubt
  ([../operators/methodic-doubt.md](../operators/methodic-doubt.md)).
- Generic scaffolding says "plan, then execute." Deweyan inquiry specifies a *shape* for
  the whole movement from problem to warranted assertion
  ([../operators/abductive-inquiry.md](../operators/abductive-inquiry.md)).

Adjacent engineering traditions converge on the same insight from another direction:
explicit heuristics for problem-solving [polya_htsi], argument structure with warrants
and backing [toulmin_uses], and design as a science of the artificial [simon_sciences].
The philosophical operators are not in competition with these; they are the
inference-governance layer those traditions assume but rarely name.
