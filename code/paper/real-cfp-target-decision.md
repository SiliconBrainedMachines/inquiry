# Real CFP Target Decision

> **Type:** plan
> **Status:** stable
> **Depends on:** [submission-target-and-formatting-decision.md](submission-target-and-formatting-decision.md), [short-paper-surrogate-template.md](short-paper-surrogate-template.md), [manuscript-assembly-draft.md](manuscript-assembly-draft.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), future venue-specific manuscript draft

This document fixes the first real submission target for the paper. The earlier
publication-framing documents narrowed the paper family and created an internal short-
paper surrogate. This document chooses the first actual CFP to target.

## Decision

Use **AgenticDev 2026 at ASE 2026** as the primary real CFP target for the first
paper.

Workshop identity: *The International Workshop on Agentic AI for Next-Generation
Software Development (AgenticDev 2026)*.

Current public dates from the workshop page:

- Submission deadline: Wed 15 Jul 2026 AoE.
- Notification: Fri 21 Aug 2026.
- Camera-ready: Fri 28 Aug 2026.
- Workshop day: Mon 12 Oct 2026 at ASE 2026 in Munich.

For immediate external formatting work, use the **official IEEE Conference Template**
as the working real template until AgenticDev exposes workshop-specific page and
formatting instructions publicly.

## Why AgenticDev is the right primary target

The match is direct on topic, contribution shape, and maturity level.

1. **Topic fit is strong.** The workshop explicitly targets agentic AI in software
   engineering, including orchestration of AI-agent communities, human-AI
   collaboration, integration into development workflows, and evaluation of
   trustworthiness, transparency, scalability, and agent-based software engineering
   systems.
2. **The paper's artifact fits the call.** Inquiry is precisely an explicit harness for
   agentic coding work: named operators, explicit state, durable traces, and a
   repository-local orchestration layer over the same underlying model.
3. **The paper's method fits the call.** The current manuscript is not a full matured
   empirical victory paper. It is a bounded pilot with a methodological contribution,
   exactly the kind of work a focused workshop can absorb without forcing premature
   overclaiming.
4. **The paper's core results fit the workshop's evaluation concerns.** Capture
   discipline, human-in-the-loop limits, scoreable traces, transparency of process, and
   stable overhead are all directly relevant to the workshop's stated concerns about
   reliable and human-centric AI-driven development.

## Why other visible options are weaker right now

### AISM 2026 is weaker as a thematic fit

AISM 2026 is centered on AI for software modernization. That is narrower and more
transformation-oriented than the current paper. Inquiry's first paper is about agentic
inference governance and comparative evaluation of a coding harness, not primarily about
legacy modernization.

### Harness4GenUI 2026 is weaker as a domain fit

Harness4GenUI 2026 is conceptually interesting because of the harness language, but its
domain is generative UI. The current paper is not about UI generation or UI pipelines;
it is about agentic software development work more broadly.

### ICSE 2027 NIER is a credible backup, not the primary target

ICSE 2027 NIER is real and thematically plausible, but it should not be the primary
target for this manuscript as it currently stands.

The main reasons are structural.

1. NIER requires a much more aggressive compression to **4 pages of main text plus 1
   page of references**.
2. NIER requires a **Future Plans** section, which would force a different rhetorical
   center than the current workshop-shaped manuscript.
3. NIER is best used for forward-looking or emerging ideas with promising initial
   results; this paper can fit that mold, but only after a sharper reframing than the
   current AgenticDev-oriented version needs.

NIER should therefore be treated as a backup path if the workshop target becomes
unavailable, slips in schedule, or later seems strategically weaker than expected.

## Immediate adaptation rule

Until AgenticDev exposes fuller public formatting guidance, the working manuscript should
stay aligned to [short-paper-surrogate-template.md](short-paper-surrogate-template.md).
That surrogate already matches the paper family the workshop call is likely to tolerate:
short, two-column, one main table, no appendix-dependent argument, and a bounded
methodological claim.

The next drafting step is therefore **not** to reopen the claim structure. It is to
adapt [manuscript-assembly-draft.md](manuscript-assembly-draft.md) to AgenticDev's CFP
language and to a real external proceedings template. The working choice for that
external template is the official IEEE Conference Template, because it is a real,
stable, two-column conference format and ICSE 2027 NIER already documents it explicitly
for a nearby software-engineering venue. If later AgenticDev guidance publishes a more
specific workshop format, that later guidance overrides the provisional IEEE choice.

## Fallback rule

If AgenticDev later proves unusable because of hidden formatting constraints, mismatch in
paper category, or scheduling problems, the next live fallback should be **ICSE 2027
NIER**, not a random workshop chosen only because it is open.