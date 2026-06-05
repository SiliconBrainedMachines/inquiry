# Introduction Section Draft

> **Type:** plan
> **Status:** draft
> **Depends on:** [research-line.md](research-line.md), [contribution.md](contribution.md), [concepts/harness-vs-capability.md](concepts/harness-vs-capability.md), [thesis-narrowing-decision.md](thesis-narrowing-decision.md), [method-section-draft.md](method-section-draft.md), [results-section-draft.md](results-section-draft.md), [submission-target-and-formatting-decision.md](submission-target-and-formatting-decision.md), [references.md](references.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), future manuscript draft

This document is the working introduction for the first paper. It is written to fit the
current short-paper target, so it foregrounds the engineering problem, the artifact, the
pilot design, and the narrowed result rather than trying to carry the whole research
program at full length.

## Draft

Large language models are now capable enough to participate directly in software work
[brown2020gpt3]. The engineering problem is no longer only how to get useful output from
them, but how to govern when they may ask, infer, act, and claim to know. In practical
coding use, many consequential failures are not failures of raw fluency. They are
failures of inference governance: acting on weak premises, moving too quickly from guess
to edit, or leaving too little durable record for a later reader to reconstruct what
happened. Recent scaffold patterns such as chain-of-thought prompting, acting-and-
reasoning loops, deliberate search, and tool use try to impose discipline after the fact
[wei2022cot; yao2023react; yao2023tot; schick2023toolformer]. What remains less clear is
which disciplines should be imposed, how they should be separated, and how their effects
should be studied without confusing a richer harness record for a richer underlying
reasoning process.

Inquiry approaches that problem by treating philosophical lineage as a source of named
operator classes rather than as decoration. Socratic maieutics, Cartesian methodic
doubt, and Deweyan inquiry are used here as differentiated rules for questioning,
evidential gating, and movement from indeterminate situation to warranted assertion
[plato_theaetetus; descartes_discourse; descartes_meditations; dewey_htwt;
dewey_logic; peirce_cp]. The claim is not that historical pedigree is itself evidence
of effectiveness. The claim is that lineage can supply sharper operator boundaries than
generic scaffolding alone, and that those boundaries can be reified as an explicit
harness over the same underlying model.

This paper studies that claim in a deliberately bounded way. We compare the same model
under two conditions on the same repository tasks: Inquiry's explicit harness versus
host-native freestyle use. The harness contributes finite-state control, named
operators, durable intermediate artifacts, and trace-producing workflow; the freestyle
condition removes those explicit harness rules while keeping the same task and model.
The paired pilot tracks four constructs: premature clarification, evidence-disciplined
claiming, reconstructability, and overhead.

The completed pilot does not justify a simple superiority story for the harness. Across
three tasks, the pilot shows no observed advantage on premature clarification. It shows
mixed results on evidence-discipline and reconstructability, with the apparent harness
advantage shrinking sharply once baseline capture is made durably comparable. The most
stable positive result is instead cost: the harness preserves a richer decision trail,
but it does so with substantial overhead. That outcome matters because it changes what
the first paper can honestly claim. The strongest contribution of the pilot is
methodological and practical, not triumphalist: it shows how capture discipline changes
the comparative story and why explicit inference governance must be evaluated together
with its cost.

The paper therefore takes a narrower position than the original strong-path thesis. It
argues that Inquiry is a useful experimental harness for studying inference governance,
that weak baseline records can exaggerate the apparent benefit of structure, and that
high harness overhead is itself a first-class result. The goal of this first paper is
not to close the research program. It is to establish the artifact, the pilot method,
and the bounded comparative result clearly enough that later studies can test the
stronger operator claim under cleaner conditions.