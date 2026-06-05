# AgenticDev Submission Checklist

> **Type:** plan
> **Status:** active
> **Depends on:** [real-cfp-target-decision.md](real-cfp-target-decision.md), [agenticdev-2026-ieee-manuscript.tex](agenticdev-2026-ieee-manuscript.tex), [agenticdev-2026-ieee-references.bib](agenticdev-2026-ieee-references.bib)
> **Used by:** publication operations while arXiv endorsement is pending

This checklist is the formal-submission lane for the primary venue (AgenticDev 2026 @ ASE 2026). It can be executed in parallel with arXiv endorsement outreach.

## Locked Dates (from CFP decision)

- Submission deadline: 2026-07-15 (AoE)
- Notification: 2026-08-21
- Camera-ready: 2026-08-28
- Workshop day: 2026-10-12

## Submission Package Readiness

- [x] IEEE-format manuscript source exists.
  Artifact: [agenticdev-2026-ieee-manuscript.tex](agenticdev-2026-ieee-manuscript.tex)
- [x] Bibliography source exists and compiles.
  Artifact: [agenticdev-2026-ieee-references.bib](agenticdev-2026-ieee-references.bib)
- [x] Venue-facing bounded draft exists.
  Artifact: [agenticdev-2026-ieee-manuscript-draft.md](agenticdev-2026-ieee-manuscript-draft.md)
- [x] Freeze submission title for AgenticDev.
  Frozen title: "Inquiry: A Pilot Study of Explicit Inference Governance for Agentic Software Development"
- [x] Freeze author metadata exactly as it will appear in the submission form.
  Frozen author block: Cristian Cisneros; Independent Researcher; Piura, Peru; ccisnedev@gmail.com.
- [x] Produce final submission PDF for the venue portal from current sources.
  Candidate snapshot: [output/agenticdev-2026-ieee-manuscript.pdf](output/agenticdev-2026-ieee-manuscript.pdf) (compiled from current IEEE source).
- [ ] Verify anonymous/non-anonymous policy for AgenticDev 2026 and conform manuscript metadata.

## Policy and Compliance Checks

- [ ] Confirm page limit and reference-page policy on official submission portal.
- [ ] Confirm whether appendices/supplementary artifacts are accepted.
- [ ] Confirm required keywords/track selection in portal.
- [ ] Confirm conflict-of-interest entry requirements before portal submission.

## Quality Gates Before Upload

- [ ] Final claim-boundary pass (no overclaim beyond pilot evidence).
- [ ] Final table and figure caption pass (self-contained captions).
- [ ] Final reference completeness pass (no unresolved citation keys).
- [x] Final reproducibility statement pass (what is and is not claimed).
  Added an explicit `Data Availability Statement` section before bibliography in the IEEE manuscript.
- [ ] Final PDF smoke-check in clean environment.

Build note: current candidate PDF compiles successfully to 3 pages at
`output/agenticdev-2026-ieee-manuscript.pdf`.

## Portal Execution (Day-of-Submission)

- [ ] Create/update submission in workshop portal.
- [ ] Upload final PDF.
- [ ] Fill metadata exactly matching manuscript (title/authors/abstract/keywords).
- [ ] Validate rendered PDF in portal preview.
- [ ] Submit and capture confirmation screenshot/email.
- [ ] Log submission ID and timestamp in [publication-operations-checklist.md](publication-operations-checklist.md).

## Risks and Mitigations

- Risk: late formatting mismatch from workshop page.
  Mitigation: keep IEEE source canonical and do one constrained format pass only if official instructions differ.
- Risk: last-minute metadata drift between PDF and portal.
  Mitigation: freeze title/authors first, then upload.
- Risk: rushed final edits introduce citation/compile issues.
  Mitigation: no content edits after final compile except blocking fixes.

## Immediate Next Actions (This Week)

- [x] Freeze final submission title.
- [x] Confirm author block and affiliation wording.
- [x] Compile and stage a candidate "submission-ready" PDF snapshot.
- [ ] Keep arXiv outreach running in parallel without blocking formal venue lane.

## Current Open Dependency

- The public AgenticDev page currently shows dates and scope, but not explicit workshop-specific formatting, anonymity, or portal-field constraints; verify these at the submission portal before final upload.
