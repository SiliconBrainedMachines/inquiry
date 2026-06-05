# First Paper Checklist

> **Type:** plan
> **Status:** active
> **Depends on:** [research-line.md](research-line.md), [contribution.md](contribution.md), [thesis.md](thesis.md), [research-question.md](research-question.md), [evidence/evidence-plan.md](evidence/evidence-plan.md)
> **Used by:** ongoing investigator workflow

This is the operational tracker for the first paper. Unlike the other documents in this
folder, this file is intentionally stateful: it records what has already been fixed,
what is in progress, and what remains to be done.

## Foundation

- [x] Define the research line.
- [x] State the paper's non-trivial contribution.
- [x] State the main thesis.
- [x] State the research question and falsifiable claims.
- [x] Define the initial concept set.
- [x] Define the initial operator set.
- [x] Define the initial evidence plan.

## Operationalization

- [x] Define the core constructs in operational terms.
  Deliverable: [constructs-and-measures.md](constructs-and-measures.md).
- [x] Define the experimental protocol.
  Deliverable: [experimental-protocol.md](experimental-protocol.md).
- [x] Define the task corpus for the first paper.
  Deliverable: [task-corpus.md](task-corpus.md).
- [x] Define the scoring rubrics.
  Deliverable: [scoring-rubrics.md](scoring-rubrics.md).

## Pilot

- [x] Prepare task packets for T1-T3 from the template.
  Deliverable: [task-packet-t1.md](task-packet-t1.md), [task-packet-t2.md](task-packet-t2.md), [task-packet-t3.md](task-packet-t3.md).
- [x] Run a condition-neutral preflight for T1 from the packet base revision.
  Outcome: the original T1 framing was not reproducible as a binary bug-fix task on the current Windows environment, which forced a more precise reformulation.
- [x] Run a small pilot with the protocol.
  Goal: test whether the method produces usable evidence, not whether the thesis is already proven.
  Status: the first T1 Harness launch under the full scheduler created issue #231,
  then blocked at the `issue_selected_or_created` handoff with `NO_ACTIVE_APE`
  before entering ANALYZE. That blockage is now part of the pilot evidence and
  should inform protocol refinement.
  Update: the reformulated T1 pair has now been executed in fresh H/F sessions,
  and the first investigator coding pass is recorded in
  [evidence/t1-pilot-first-scoring-pass.md](evidence/t1-pilot-first-scoring-pass.md).
  That pass exposed material method ambiguity around success-target drift and
  freestyle transcript capture, which is why later T2/T3 runs used the revised
  protocol rather than the original pilot draft.
  Second-pass note: a conservative recoding is recorded in
  [evidence/t1-pilot-second-scoring-pass.md](evidence/t1-pilot-second-scoring-pass.md).
  The second pass leaves C1, C3, and C4 stable, but downgrades F on C2 under a
  durable-artifact-first reading.
  T2 and T3 have now also completed paired execution, pair capture, and first/second
  investigator scoring passes in
  [evidence/t2-pilot-first-scoring-pass.md](evidence/t2-pilot-first-scoring-pass.md),
  [evidence/t2-pilot-second-scoring-pass.md](evidence/t2-pilot-second-scoring-pass.md),
  [evidence/t3-pilot-first-scoring-pass.md](evidence/t3-pilot-first-scoring-pass.md),
  and [evidence/t3-pilot-second-scoring-pass.md](evidence/t3-pilot-second-scoring-pass.md).
  Resolution: the pilot is now accepted as method-usable and the freeze decision is
  recorded in [protocol-freeze-decision.md](protocol-freeze-decision.md).
- [x] Reformulate T1 around a reproducible Windows path-canonicalization mismatch.
- [x] Prepare a fresh-session execution runbook for the reformulated T1 pair.
  Deliverable: [t1-pilot-runbook.md](t1-pilot-runbook.md).
- [x] Refine constructs, protocol, or rubrics if the pilot exposes ambiguity.
  Deliverable: the revised shared-stop-line, export-symmetry, preflight, and post-target
  separation rules now codified in [experimental-protocol.md](experimental-protocol.md)
  and exercised in T2/T3.
- [x] Freeze the first-paper protocol after the pilot.
  Deliverable: [protocol-freeze-decision.md](protocol-freeze-decision.md).

## Evidence Collection

- [ ] Run the first paper's task set under the harness condition.
- [ ] Run the same task set under the freestyle condition.
- [ ] Collect traces, artifacts, and metrics in citation-ready form.
- [ ] Perform blind or at least structured reconstructability scoring.
  Update: T2 now has a first investigator scoring pass in
  [evidence/t2-pilot-first-scoring-pass.md](evidence/t2-pilot-first-scoring-pass.md)
  and a conservative second pass in
  [evidence/t2-pilot-second-scoring-pass.md](evidence/t2-pilot-second-scoring-pass.md).
  Unlike T1, the T2 reread leaves C1-C4 stable and shifts the main remaining method
  question toward overhead rather than reconstructability asymmetry.
  Update: T3 now also has a first investigator scoring pass in
  [evidence/t3-pilot-first-scoring-pass.md](evidence/t3-pilot-first-scoring-pass.md)
  and a conservative second pass in
  [evidence/t3-pilot-second-scoring-pass.md](evidence/t3-pilot-second-scoring-pass.md).
  Like T2, the T3 reread leaves C1-C4 stable and strengthens the reading that the main
  durable asymmetry is overhead rather than evidentiary collapse.

## Analysis

- [x] Summarize results claim by claim.
  Deliverables: [evidence/pilot-claim-summary-t1-t2-t3.md](evidence/pilot-claim-summary-t1-t2-t3.md), [results-section-draft.md](results-section-draft.md).
  Update: an interim T1/T2 synthesis is now recorded in
  [evidence/pilot-claim-summary-t1-t2.md](evidence/pilot-claim-summary-t1-t2.md).
  The current cross-task picture is mixed on C2/C3, negative-to-null on C1, and
  strongly positive on C4.
  Update: the controlling three-task synthesis is now recorded in
  [evidence/pilot-claim-summary-t1-t2-t3.md](evidence/pilot-claim-summary-t1-t2-t3.md).
  After T1-T3, the strongest stable positive result is C4, C1 remains unconfirmed, and
  the most defensible reading of C2/C3 is mixed with parity once durable freestyle
  capture is strong.
- [x] Report overhead honestly, including unfavorable cases.
  Deliverables: [results-section-draft.md](results-section-draft.md), [limitations-and-threats-to-validity.md](limitations-and-threats-to-validity.md).
- [x] Write limitations and threats to validity before discussion prose expands.
  Deliverable: [limitations-and-threats-to-validity.md](limitations-and-threats-to-validity.md).
- [x] Decide whether the current evidence supports the strong-path claim or only a weaker version.
  Deliverable: [thesis-narrowing-decision.md](thesis-narrowing-decision.md).
  Provisional reading after T1/T2: strong-path support is not yet established; the
  most defensible interim position is a weaker claim that the harness guarantees a
  scoreable externalized record while imposing substantial overhead.
  Update after T1-T3: the three-task synthesis still does not support the strong path.
  The current defensible reading is a narrower methodological claim plus a stable high-
  overhead result.

## Manuscript

- [x] Draft the paper shell.
  Deliverable: [first-paper-shell.md](first-paper-shell.md).
  Suggested sections: problem, contribution, theoretical framing, artifact, method, results, limits, discussion.
- [x] Write the method section from the frozen protocol.
  Deliverable: [method-section-draft.md](method-section-draft.md).
- [x] Write the results section from collected evidence.
  Deliverable: [results-section-draft.md](results-section-draft.md).
  Update: a manuscript-facing scaffold now exists in
  [results-section-scaffold.md](results-section-scaffold.md), ready to absorb the T3
  outcome without rewriting the section structure from scratch.
  Update: the scaffold has now been updated in place with the completed T1/T2/T3 second-
  pass readings and is ready for prose drafting.
- [x] Write the discussion section without overclaiming beyond the measurements.
  Deliverable: [discussion-section-draft.md](discussion-section-draft.md).
- [x] Write the abstract and introduction last.
  Deliverables: [abstract-draft.md](abstract-draft.md), [introduction-section-draft.md](introduction-section-draft.md).

## Release Readiness

- [x] Internal coherence pass across all paper documents.
  Outcome: the manuscript-facing shell, method, results, limits, discussion, and paper
  map are now aligned with the frozen protocol and the narrowed thesis framing.
- [x] Reference completeness pass.
  Outcome: the programmatic theory layer now exposes explicit bibliography keys for the
  external lineage and LLM-scaffold claims it carries.
- [x] Claim-to-evidence audit.
  Deliverable: [claim-to-evidence-audit.md](claim-to-evidence-audit.md).
- [x] Submission target and formatting decision.
  Deliverable: [submission-target-and-formatting-decision.md](submission-target-and-formatting-decision.md).
- [x] Adapt the assembled manuscript to the chosen real CFP.
  Outcome: [manuscript-assembly-draft.md](manuscript-assembly-draft.md) now targets
  AgenticDev 2026 explicitly and stays within the provisional IEEE conference
  constraints recorded in [real-cfp-target-decision.md](real-cfp-target-decision.md)
  without reopening the bounded claim.
- [x] Pressure-test the assembled manuscript against the short-paper budget.
  Outcome: the current assembly stays within the surrogate shape, with the main
  compression pressure concentrated in the introduction and then the results/discussion
  prose rather than in method or theory; a local introduction trim has already been
  applied before any template port.
- [x] Port the bounded assembly into a venue-specific IEEE-style shell.
  Deliverable: [agenticdev-2026-ieee-manuscript-draft.md](agenticdev-2026-ieee-manuscript-draft.md).
  Outcome: the paper now has a submission-oriented AgenticDev 2026 manuscript surface
  with IEEE-style front matter, Roman-numeral sectioning, preserved one-table budget,
  and unchanged bounded claim.
- [x] Instantiate the venue draft in real IEEE submission files.
  Deliverables: [agenticdev-2026-ieee-manuscript.tex](agenticdev-2026-ieee-manuscript.tex), [agenticdev-2026-ieee-references.bib](agenticdev-2026-ieee-references.bib).
  Outcome: MiKTeX successfully compiled the paper to PDF, the citation keys resolved
  against the derived BibTeX file, and the remaining bibliography warnings were reduced
  to source-level metadata cleanup now fixed in both the atomic reference registry and
  the derived .bib.

## Current Priority

The next step is to turn the adapted assembly into a submission-ready venue draft:

1. replace the placeholder author block in [agenticdev-2026-ieee-manuscript.tex](agenticdev-2026-ieee-manuscript.tex) with final author, affiliation, and acknowledgment metadata when the submission identity is fixed,
2. if AgenticDev later publishes different formatting guidance, reconcile the same bounded draft and compiled IEEE files to that format and re-run the compile check,
3. perform the final camera-ready hygiene pass in the compiled file: last-page column balancing, final bibliography polish, and any venue-specific wording constraints that appear later.