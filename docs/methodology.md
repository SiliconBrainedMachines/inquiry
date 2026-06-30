# The Inquiry Method — Stages & Canonical Artifacts

Inquiry structures AI-assisted (or human) software work as a sequence of bounded
stages, each with a **canonical artifact** that the CLI scaffolds (the *hands*)
and the brain (model or human) fills, and a **gate** the CLI enforces before the
next stage. Each artifact is named by its **output**, unambiguously, borrowing
the standard term of its own layer — never a term from another layer (no
`runbook` for a build plan, no `PRD` for a diagnosis).

## Controlled vocabulary

The method enforces a controlled vocabulary: **each word occupies exactly one
slot**, in both languages, so no term names two things at different links of the
chain.

| Term (en / es) | Means | Slot |
|----------------|-------|------|
| **requisition** / *solicitud* | a formal request that a change be made (the business need) | stage-1 intake document |
| **request** | the HTTP transport object | architecture (not a methodology artifact) |
| **requirement** / *requisito* | a single **verifiable condition** the system must meet | a line item *inside* `specification.md` (a user story + its acceptance criteria) |
| **specification** / *especificación* | the engineering document that contains the requirements | stage-1 contract (`specification.md`) |

So the chain is **requisition → specification → requirements**, with no overlap.
The intake document is `requisition.md` (not `requirement.md`): "requirement" is
a false friend of the Spanish *requerimiento* and collides with the verifiable
`requirements` living inside the specification — "requisition" (low-frequency,
single sense) names exactly the petition and clashes with nothing.

## The six stages

| # | Stage | Owner | Canonical artifact(s) | Answers | Standard basis |
|---|-------|-------|-----------------------|---------|----------------|
| 1 | **Specification** | QA | `requisition.md`, `specification.md`, `issue-<slug>.md` | the need + the **what** (the contract) | BABOK Gap Analysis (AS-IS/TO-BE); spec-kit / IEEE SRS; User Stories (INVEST, Cohn); BDD Given-When-Then (North) |
| 2 | **Analyze** | Dev | `diagnosis.md` (+ `confirmations.md`) | **why it fails** (evidence-first) | Root-Cause Analysis / investigation — ★ *original to Inquiry* |
| 3 | **Plan** | Dev | `plan.md` | the **how** (verifiable, test-first) | *Implementation Plan*; SDD design |
| 4 | **Execute** | Dev | code + commits | **built right** | TDD red-green-refactor (Beck) |
| 5 | **End** | QA + Dev | PR / merge | **accepted** | code review / PR gate |
| 6 | **Evolution** | — | methodology mutations | improve the method | ★ *original to Inquiry* (Darwinian selection) |

> **Two teams, two workspaces.** QA owns stage 1 in `requisitions/<slug>/` (lands
> on `main` via a doc-PR — the QA review gate). Dev owns stages 2–4 in
> `cleanrooms/<branch>/` + the code. The **GitHub issues are the handoff** —
> tracked in-repo as `issue-<slug>.md` (source of truth; GitHub is a projection).

## `diagnosis` — an original contribution

Mainstream Spec-Driven Development (spec-kit, Kiro) goes **spec → design →
tasks**: it assumes the specification is enough and jumps to *how to build*. It
has **no stage for understanding why an existing system misbehaves**. Inquiry's
**Analyze** stage — a Socratic, evidence-first investigation that produces
`diagnosis.md` (every claim carrying a re-checkable handle) before any plan — is
an original contribution of this methodology. It is the discipline that makes
the later plan *licensed by evidence, not inference*.

## The SDD → TDD traceability spine

The objective of the method is that **every acceptance criterion is traceable
and verifiable by a test, with documented evidence**. The artifacts hand the
same `AC-id` down the line:

```
specification.md   AC-1, AC-2 …            (acceptance — outer loop, BDD)
        │ traces to
plan.md            Phase N "Covers: AC-1"  + executable Verify check   (unit — inner loop, TDD)
        │ traces to
EXECUTE            test written FIRST → red → green                    (proves the AC)
        │ recorded as
specification.md   Decisions (evidence)    (each decision cites its experiment)
```

This is SDD's core principle — *the spec is authoritative, enforced by
automation, not by human discipline* — realized through Inquiry's gates.

## Templates & languages

The CLI scaffolds each artifact from a single-source template in
`assets/artifacts/`. `requisition.md` and `specification.md` ship `en` (default)
and `es` (via a language flag; more languages may follow). The dev-cycle
artifacts (`diagnosis.md`, `plan.md`) are English-only, because their gates parse
English. Requesting a language with no template falls back to English with a
one-line notice.
