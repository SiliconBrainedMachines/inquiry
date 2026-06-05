# AgenticDev 2026 IEEE Manuscript Draft

> **Type:** plan
> **Status:** draft
> **Depends on:** [manuscript-assembly-draft.md](manuscript-assembly-draft.md), [real-cfp-target-decision.md](real-cfp-target-decision.md), [short-paper-surrogate-template.md](short-paper-surrogate-template.md), [references.md](references.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), [agenticdev-2026-ieee-manuscript.tex](agenticdev-2026-ieee-manuscript.tex)

This document is the venue-specific submission surface for the first paper. It preserves
the bounded pilot claim while recasting the assembled draft into a paste-ready
AgenticDev 2026 manuscript shell under the provisional IEEE conference format. Author
names, affiliations, acknowledgments, and numeric bibliography formatting still belong
to the external template, but the title, abstract, index terms, section order, and
single-table body are now fixed here.

## Title

Inquiry: A Pilot Study of Explicit Inference Governance for Agentic Software Development

## Author Block

Cristian Cisneros

Independent Researcher

Piura, Peru

ccisnedev@gmail.com

Acknowledgments and any funding statement still belong to the external IEEE template if
they later become necessary.

## Abstract

Agentic AI systems are entering software development workflows, but they often do so
through fluent and weakly governed inference that leaves thin records for later audit.
This paper studies whether explicit harness rules can make that work more transparent
and reconstructable without changing the underlying model. We examine Inquiry, a
repository-local orchestration harness that externalizes process through named
operators, explicit state, durable artifacts, and trace-producing workflow. We report a
three-task paired pilot in one repository comparing the same model under Inquiry's
harness and under host-native freestyle use on a bug fix, a feature slice, and a
bounded refactor. The pilot tracks premature clarification, evidence-disciplined
claims, reconstructability, and overhead. The result is not a simple harness win.
Premature clarification shows no observed advantage, and evidence-discipline and
reconstructability become mixed once baseline capture is made durably comparable.
Overhead remains the strongest stable result, with roughly 4.6x to 9.9x relative time
asymmetry across the completed pairs. The pilot therefore supports a narrower claim:
explicit harnessing reliably preserves a scoreable decision trail, but apparent
comparative behavioral gains are method-sensitive and can be overstated when baseline
records are thin. The main contribution is a bounded evaluation design for studying
transparency and inference governance in agentic software development without
overclaiming from weak comparative capture.

## Index Terms

agentic software development; inference governance; workflow transparency;
human-AI collaboration; decision-trail reconstructability

## I. Introduction

Agentic AI systems are now capable enough to participate directly in software
development workflows [brown2020gpt3]. The engineering problem is not only how to
obtain useful output from them, but how to govern when an agent may ask, infer, act,
and claim to know in collaboration with a human teammate. In practical coding use,
many consequential failures reflect weak inference governance and weak workflow
transparency: acting on thin premises, moving too quickly from guess to edit, or
leaving too little durable record for later reconstruction. Scaffold patterns such as
chain-of-thought prompting, acting-and-reasoning loops, deliberate search, and tool use
try to impose discipline after the fact [wei2022cot; yao2023react; yao2023tot;
schick2023toolformer]. What remains less clear is which disciplines should be imposed,
how they should be separated, and how their effects should be studied without
confusing a richer harness record for richer underlying reasoning.

Inquiry approaches that problem by treating philosophical lineage as a source of named
operator classes rather than as decoration. In the first paper, the relevant operators
are Socratic maieutics for clarification discipline, Cartesian methodic doubt for
evidence-gated action, and Deweyan inquiry for movement from an indeterminate situation
to a warranted assertion [plato_theaetetus; descartes_discourse;
descartes_meditations; dewey_htwt; dewey_logic; peirce_cp]. The claim is not that
historical pedigree is itself evidence. The claim is that philosophical lineage can
function as a reusable operator taxonomy for AI engineering, with sharper boundaries
than generic scaffolding alone.

That framing creates an obvious risk: if the named operators cannot be distinguished
from generic structure in observable behavior, the project collapses toward decorated
scaffolding. The first paper therefore tests a bounded practical arm of the idea rather
than defending it only by exposition. Its contribution is threefold: Inquiry as a
concrete artifact for transparent agentic software development, a paired pilot method
for comparing harnessed and freestyle use of the same model on the same tasks, and a
result reported honestly enough to narrow the thesis rather than protect it. The
completed pilot does not support a broad strong-path empirical win. It supports a
methodological result about capture discipline, a practical result about substantial
harness cost, and a narrower claim about what the artifact can already be said to do.

Concretely, the paper contributes three things.

1. A repository-local harness artifact that makes inference governance explicit through
	named operators, state, and durable traces.
2. A paired pilot method for comparing harnessed and freestyle use of the same model on
	the same bounded software tasks.
3. A bounded result set that narrows the original thesis: capture discipline strongly
	affects the observed comparison, while harness overhead remains the most stable
	positive result.

## II. Theoretical Framing

The motivating theory behind Inquiry is that a capable language model is best treated as
an abductive machine: effective at generating plausible continuations, but not natively
disciplined about when a hypothesis is warranted enough to guide action [peirce_dih;
peirce_cp]. The first paper uses three named operators to make those governance and
transparency questions explicit: maieutics for licensing and stopping clarification,
methodic doubt for evidential gating before action, and Deweyan inquiry for movement
from an indeterminate situation to a warranted assertion. The point is not ornament. It
is to use philosophical lineage as a source of differentiated operator boundaries that
can be instantiated in a harness and tested.

This is why the practical comparison is with the same model under two different control
structures. The paper is not about better model capability. It is about whether
explicit inference-governing rules change the visible work product and decision trail
enough to justify their cost.

## III. Inquiry and Pilot Method

Inquiry is the artifact under study. Operationally, it is a repository-local
orchestration layer around the host model: explicit state, named operators, inspectable
prompt assembly, durable intermediate artifacts, and trace-producing workflow. The
comparison in this paper therefore does not ask whether software work with tooling
differs from software work without tooling in the abstract. It asks whether the same
model behaves differently when explicit harness rules are imposed, preserved for later
audit, and recorded.

All reported runs in the pilot were executed against Inquiry v0.7.5, the tagged
software release that defined the artifact surface under study [inquiry_0_7_5].

The first paper uses a small comparative pilot rather than a broad empirical study. The
same model is compared under two conditions on the same bounded repository tasks:
Inquiry's explicit harness and host-native freestyle use. Across paired runs, the method
holds constant the starting revision, the task packet, the host environment, the model
family, and the human-availability rule as far as the environment allows. Condition
order is counterbalanced across tasks.

The pilot corpus contains three historical tasks: a bug fix, a feature slice, and a
bounded refactor. Each task is executed under a condition-neutral packet with a shared
scored stop line and shared validation surface, explicitly separated from later release
or repository-integration work.

The pilot tracks four constructs: premature clarification, evidence-disciplined claims,
reconstructability, and overhead. Because the main methodological risk is distortion
from weak capture, the study is artifact-forward. Each paired run preserves a durable
record rich enough for later scoring, and where first-pass impressions and later
durable-artifact rereads disagree, the weaker second-pass reading controls the paper.

## IV. Results

Across T1, T2, and T3, the pilot does not support a simple overall superiority claim for
the harness. The stable positive result is overhead: the harness is consistently more
expensive than freestyle in time, interaction volume, and artifact / process surface.
The other three claims are either null or mixed once the comparison is restricted to the
durable record.

| Claim | T1 second pass | T2 second pass | T3 second pass | Pilot reading |
|---|---|---|---|---|
| C1 | H `0`, F `0 observed` | H `0`, F `0` | H `0`, F `0` | No observed advantage for either condition |
| C2 | H `2`, F `1` | H `2`, F `2` | H `2`, F `2` | Mixed overall; stronger recent pattern is parity |
| C3 | H `2`, F `0` | H `2`, F `2` | H `2`, F `2` | Mixed overall; parity once durable freestyle capture is strong |
| C4 | pair `2` | pair `2` | pair `2` | Stable high relative overhead for H |

### C1

Premature clarification did not move in the predicted direction. Across all three tasks,
neither condition produced an observed positive premature-clarification event under the
conservative reread. The paper therefore cannot present maieutic clarification economy
as a supported harness advantage on this task set.

### C2 and C3

Evidence-discipline and reconstructability both show mixed rather than stable positive
results. T1 favored the harness on both constructs, but the retained freestyle record in
that task was thinner than in the later pairs. Once the revised protocol forced more
durable freestyle capture in T2 and T3, the apparent gap narrowed sharply toward
parity. The methodological implication is important: at least part of the visible H
advantage on C2 and C3 can be generated by record quality rather than by superior
reasoning discipline alone.

### C4

Overhead is the strongest and most stable pilot result. T1 preserved roughly 4.62x
relative wall-clock asymmetry between H and F, T2 roughly 9.25x exported-duration
asymmetry, and T3 roughly 9.94x scored wall-clock asymmetry. T2 and T3 matter most here
because they remove the easy escape hatch left by T1: even after protocol cleanup, a
shared scored stop line, and stronger export symmetry, the harness remains substantially
more expensive than freestyle.

### Synthesis

Taken together, the pilot's main result is methodological before it is triumphalist.
Weak baseline capture can make freestyle look less evidence-disciplined and less
reconstructable than it really is, while stronger capture symmetry removes much of that
apparent harness advantage. The harness still guarantees explicit process
externalization, but it does so at substantial cost.

## V. Discussion and Limits

The completed pilot should therefore be read as a bounded methodological and practical
result for agentic software development workflows, not as a broad confirmation of the
original strong-path thesis. The pilot is small-N, repository-bounded, Windows-coupled,
and methodologically uneven because the protocol matured across the three tasks. Most
importantly, the current comparison does not yet isolate named operator effect from the
combined effects of generic structure, artifact discipline, and capture asymmetry.

Those limits determine what the paper can say honestly. Inquiry is presented here as a
concrete harness for studying inference governance, not yet as a system that has already
demonstrated broad behavioral superiority through its named operators. The strongest
defensible lesson of the pilot is that method matters twice: in the design of the
harness and in the design of the comparison used to evaluate it. The artifact already
shows that explicit governance can preserve a scoreable decision trail for later human
audit; the comparison shows that weak baseline records can exaggerate the apparent
benefit of structure; and the overhead result shows that any future defense of
transparent agentic workflows will have to justify their cost by task class. A stronger
future study will need capture symmetry by design, cleaner isolation of operator effect
from generic structure, and a broader task base before the deferred strong-path claim
can be revisited.

The narrowed claim for this paper is therefore straightforward: Inquiry reliably
externalizes process and preserves a scoreable decision trail, but the apparent harness
advantage on evidence-discipline and reconstructability is method-sensitive and can
shrink toward parity once freestyle capture is made durably comparable; meanwhile, the
harness imposes substantial and stable overhead that must be justified rather than
assumed away.

## Reference Note

- `inquiry_0_7_5`: Inquiry v0.7.5 release, https://github.com/ccisnedev/inquiry/releases/tag/v0.7.5