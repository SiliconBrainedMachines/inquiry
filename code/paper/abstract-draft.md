# Abstract Draft

> **Type:** plan
> **Status:** draft
> **Depends on:** [first-paper-shell.md](first-paper-shell.md), [submission-target-and-formatting-decision.md](submission-target-and-formatting-decision.md), [method-section-draft.md](method-section-draft.md), [results-section-draft.md](results-section-draft.md), [thesis-narrowing-decision.md](thesis-narrowing-decision.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), future manuscript draft

This document is the working abstract for the first paper. It is written against the
current short-paper target and the narrowed post-pilot thesis framing.

## Draft

Large language models can produce useful software work, but they often do so through
fluent and weakly governed inference. This paper studies whether explicit harness rules
can make that work more disciplined without changing the underlying model. We examine
Inquiry, a repository-local harness that externalizes process through named operators,
explicit state, durable artifacts, and trace-producing workflow. We report a three-task
paired pilot in one repository comparing the same model under Inquiry's harness and
under host-native freestyle use on a bug fix, a feature slice, and a bounded refactor.
The pilot tracks premature clarification, evidence-disciplined claims,
reconstructability, and overhead. The result is not a simple harness win. Premature
clarification shows no observed advantage, and evidence-discipline and
reconstructability become mixed once baseline capture is made durably comparable.
Overhead remains the strongest stable result, with roughly 4.6x to 9.9x relative time
asymmetry across the completed pairs. The pilot therefore supports a narrower claim:
explicit harnessing reliably preserves a scoreable decision trail, but apparent
comparative behavioral gains are method-sensitive and can be overstated when baseline
records are thin. The main contribution is methodological as much as empirical: a
bounded design for studying inference governance without overclaiming from weak
comparative capture.