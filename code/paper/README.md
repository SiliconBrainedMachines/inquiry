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

> **Type:** thesis | research-line | contribution | question | concept | operator | method | evidence | plan
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
| [first-paper-checklist.md](first-paper-checklist.md) | plan | Operational checklist and progress tracker for the first paper |
| [first-paper-shell.md](first-paper-shell.md) | plan | Assembly shell for the first manuscript, defining section order and controlling source documents |
| [constructs-and-measures.md](constructs-and-measures.md) | method | Operational definitions for the paper's core constructs and preliminary measures |
| [experimental-protocol.md](experimental-protocol.md) | method | Frozen protocol for the pilot comparison and next evidence-collection phase |
| [protocol-freeze-decision.md](protocol-freeze-decision.md) | method | Explicit post-pilot decision to freeze the revised protocol for the next study stage |
| [method-section-draft.md](method-section-draft.md) | method | Manuscript-facing method prose assembled from the frozen protocol, corpus, measures, and scoring rules |
| [task-corpus.md](task-corpus.md) | method | Approved pilot task set and selection rationale |
| [scoring-rubrics.md](scoring-rubrics.md) | method | Three-level scoring rules for pilot coding across events, claims, and runs |
| [task-packet-template.md](task-packet-template.md) | method | Reusable template for preparing condition-neutral pilot task packets |
| [task-packet-t1.md](task-packet-t1.md) | method | First instantiated pilot packet for the Windows ape prompt bug-fix task |
| [t1-pilot-runbook.md](t1-pilot-runbook.md) | method | Fresh-session operational scaffold for executing the reformulated T1 pair without cross-condition contamination |
| [task-packet-t2.md](task-packet-t2.md) | method | Second instantiated pilot packet for the root version-flags feature slice |
| [task-packet-t3.md](task-packet-t3.md) | method | Third instantiated pilot packet for the state.yaml field-rename refactor |
| [research-line.md](research-line.md) | research-line | The long-horizon program: engineering of inference |
| [contribution.md](contribution.md) | contribution | The paper's non-trivial contribution and why the philosophical lineage matters |
| [thesis.md](thesis.md) | thesis | The first paper's central, falsifiable claim |
| [thesis-narrowing-decision.md](thesis-narrowing-decision.md) | thesis | Explicit post-pilot decision to frame the first paper around a weaker claim than the original strong path |
| [research-question.md](research-question.md) | question | The question and the claims that can fail |
| [concepts/abductive-machine.md](concepts/abductive-machine.md) | concept | The LLM as an undisciplined abductive engine |
| [concepts/thinking-tools.md](concepts/thinking-tools.md) | concept | Philosophical methods as disciplines of inference |
| [concepts/harness-vs-capability.md](concepts/harness-vs-capability.md) | concept | Why the bottleneck is control, not raw capability |
| [operators/maieutics.md](operators/maieutics.md) | operator | SOCRATES — when to seek premises vs. when to stop |
| [operators/methodic-doubt.md](operators/methodic-doubt.md) | operator | DESCARTES — what may be taken as established |
| [operators/abductive-inquiry.md](operators/abductive-inquiry.md) | operator | DEWEY/Peirce — indeterminate situation to warranted assertion |
| [evidence/evidence-plan.md](evidence/evidence-plan.md) | evidence | What counts as evidence and the comparison frame |
| [claim-to-evidence-audit.md](claim-to-evidence-audit.md) | evidence | Durable audit of whether manuscript-facing pilot claims are authorized by the bounded corpus |
| [results-section-draft.md](results-section-draft.md) | evidence | Manuscript-facing results prose for the completed T1-T3 pilot using controlling second-pass readings |
| [limitations-and-threats-to-validity.md](limitations-and-threats-to-validity.md) | evidence | Manuscript-facing limits and threats-to-validity prose derived from the pilot's retained deviation record |
| [discussion-section-draft.md](discussion-section-draft.md) | plan | Manuscript-facing discussion prose interpreting the pilot under the narrowed thesis framing |
| [submission-target-and-formatting-decision.md](submission-target-and-formatting-decision.md) | plan | Working publication-target decision that fixes the paper family and short-paper formatting constraints |
| [short-paper-surrogate-template.md](short-paper-surrogate-template.md) | plan | Concrete internal ACM-like surrogate template used before selecting a real CFP or publisher format |
| [real-cfp-target-decision.md](real-cfp-target-decision.md) | plan | Chosen real CFP target, with AgenticDev 2026 as primary venue and IEEE conference format as provisional external template |
| [publication-channels-plan.md](publication-channels-plan.md) | plan | Four-channel publication strategy covering arXiv, GitHub release artifacts, site and LinkedIn amplification, and formal venue submission |
| [abstract-draft.md](abstract-draft.md) | plan | Working short-paper abstract aligned with the narrowed pilot claim |
| [introduction-section-draft.md](introduction-section-draft.md) | plan | Working introduction that frames the engineering problem, artifact, pilot design, and bounded result |
| [manuscript-assembly-draft.md](manuscript-assembly-draft.md) | plan | Single short-paper assembly surface that compresses the current atomic drafts into one manuscript-form flow |
| [agenticdev-2026-ieee-manuscript-draft.md](agenticdev-2026-ieee-manuscript-draft.md) | plan | Venue-specific submission surface that ports the bounded assembly into a paste-ready AgenticDev 2026 manuscript shell under the provisional IEEE conference format |
| [references.md](references.md) | method | Verifiable, BibTeX-ready sources |

## External Submission Artifacts

These files are derived submission artifacts rather than atomic research documents.

| File | Role |
|---|---|
| [agenticdev-2026-ieee-manuscript.tex](agenticdev-2026-ieee-manuscript.tex) | Real IEEE conference manuscript instantiated from the venue-specific markdown draft |
| [agenticdev-2026-ieee-references.bib](agenticdev-2026-ieee-references.bib) | Companion BibTeX file derived from the cited subset of [references.md](references.md) |

Compiled PDFs and all LaTeX auxiliaries under [output/](output/) are generated
artifacts, not versioned sources. They are built locally or in CI and distributed as
release assets rather than stored in Git.

## How a paper is assembled from this folder

A paper draft is a **composition** of these atomic documents, not a separate manuscript
that duplicates them. The first paper draws its research program from `research-line.md`,
its non-trivial claim from `contribution.md`, its original falsifiable target from
`thesis.md` and `research-question.md`, its post-pilot framing constraint from
`thesis-narrowing-decision.md`, its operational vocabulary from
`constructs-and-measures.md`, its frozen study rules from `experimental-protocol.md`
and `protocol-freeze-decision.md`, its approved task set from `task-corpus.md`, its
mechanism from the `concepts/` and `operators/` files, its coding rules from
`scoring-rubrics.md`, and its empirical structure from `evidence/evidence-plan.md` plus
the pilot synthesis documents in `evidence/`. The manuscript-facing layer is then
assembled through `first-paper-shell.md`, `method-section-draft.md`,
`results-section-draft.md`, `limitations-and-threats-to-validity.md`, and
`discussion-section-draft.md`, while `claim-to-evidence-audit.md` checks whether that
manuscript-facing layer is actually authorized by the bounded corpus.
`submission-target-and-formatting-decision.md` fixes the publication shape early enough
that abstract and introduction drafting do not drift into a manuscript family the pilot
cannot yet support. `short-paper-surrogate-template.md` turns that publication decision
into a concrete internal manuscript format before any real CFP is chosen.
`real-cfp-target-decision.md` then selects AgenticDev 2026 at ASE 2026 as the first
real venue target and records the official IEEE conference format as the provisional
external template until workshop-specific guidance becomes public.
`publication-channels-plan.md` fixes the four outward channels for the first paper:
arXiv as the canonical public paper URL, GitHub releases as the PDF artifact channel,
the Inquiry site plus LinkedIn as amplification surfaces, and AgenticDev 2026 with
ICSE 2027 NIER fallback as the formal venue path.
`abstract-draft.md` and `introduction-section-draft.md` are the front-matter drafts now
written against that constrained paper shape rather than against the earlier broader
strong-path ambition. `manuscript-assembly-draft.md` is the first place where those
front-matter pieces, the section drafts, and the narrowed claim are forced to coexist
under one short-paper budget. `agenticdev-2026-ieee-manuscript-draft.md` is the first
venue-specific port of that assembly, reorganized as a submission-oriented shell for
AgenticDev 2026 under the provisional IEEE conference format. That venue-specific shell
is now instantiated as the real external submission artifacts
`agenticdev-2026-ieee-manuscript.tex` and `agenticdev-2026-ieee-references.bib`, while
the compiled PDF is rebuilt for release distribution instead of being versioned.
`task-packet-template.md` is the reusable container used to instantiate the pilot runs
from the approved corpus. Several papers can be composed from the same atomic base;
this is why the base must stay clean.

`first-paper-checklist.md` is the operational exception: it is the stateful tracker for
the work still to be done, and it should be updated as the research progresses.
