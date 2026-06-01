# Paper — Research as Code

This folder holds the research program behind Inquiry as a set of **atomic markdown
documents**. Each file is treated like a function in a program: one idea, a small
declared interface, explicit dependencies, and a clear set of consumers.

This is not the canonical runtime doctrine (that lives in [docs/architecture.md](../../docs/architecture.md)).
This folder exists to **conduct the research and produce the paper**.

## Conventions

Every document follows the same shape:

```
# Title

> **Type:** thesis | research-line | question | concept | operator | method | evidence
> **Status:** draft | stable
> **Depends on:** links to the documents this one assumes
> **Used by:** links to the documents that consume this one

Body: brief but substantial. One idea. Verifiable claims only.
```

Rules, in the spirit of clean code:

- **Atomic.** One document, one idea. If it needs two headings of unrelated content, split it.
- **Composable.** Reference other documents by link instead of repeating their content.
- **Substantial.** Short is good; thin is not. Every paragraph should carry weight.
- **Verifiable.** Every external claim must trace to an entry in [references.md](references.md).
- **No orphan prose.** If a paragraph does not feed a thesis, a claim, or the evidence
  plan, it does not belong here.

## Map

| Document | Type | Role |
|---|---|---|
| [research-line.md](research-line.md) | research-line | The long-horizon program: engineering of inference |
| [thesis.md](thesis.md) | thesis | The first paper's central, falsifiable claim |
| [research-question.md](research-question.md) | question | The question and the claims that can fail |
| [concepts/abductive-machine.md](concepts/abductive-machine.md) | concept | The LLM as an undisciplined abductive engine |
| [concepts/thinking-tools.md](concepts/thinking-tools.md) | concept | Philosophical methods as disciplines of inference |
| [concepts/harness-vs-capability.md](concepts/harness-vs-capability.md) | concept | Why the bottleneck is control, not raw capability |
| [operators/maieutics.md](operators/maieutics.md) | operator | SOCRATES — when to seek premises vs. when to stop |
| [operators/methodic-doubt.md](operators/methodic-doubt.md) | operator | DESCARTES — what may be taken as established |
| [operators/abductive-inquiry.md](operators/abductive-inquiry.md) | operator | DEWEY/Peirce — indeterminate situation to warranted assertion |
| [evidence/evidence-plan.md](evidence/evidence-plan.md) | evidence | What counts as evidence and the comparison frame |
| [references.md](references.md) | method | Verifiable, BibTeX-ready sources |

## How a paper is assembled from this folder

A paper draft is a **composition** of these atomic documents, not a separate manuscript
that duplicates them. The first paper draws its argument from `thesis.md` and
`research-question.md`, its mechanism from the `concepts/` and `operators/` files, and
its empirical structure from `evidence/evidence-plan.md`. Several papers can be composed
from the same atomic base; this is why the base must stay clean.
