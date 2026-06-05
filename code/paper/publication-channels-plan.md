# Publication Channels Plan

> **Type:** plan
> **Status:** stable
> **Depends on:** [agenticdev-2026-ieee-manuscript-draft.md](agenticdev-2026-ieee-manuscript-draft.md), [agenticdev-2026-ieee-manuscript.tex](agenticdev-2026-ieee-manuscript.tex), [real-cfp-target-decision.md](real-cfp-target-decision.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), site publications page, LinkedIn draft, release workflow

This document fixes how the first Inquiry paper is distributed, announced, and formally
submitted. The manuscript remains single-source; the channels are distinct surfaces for
the same paper, not different papers.

## Decision

The first paper uses four channels.

1. **arXiv** as the canonical public paper URL.
2. **GitHub Releases** as the artifact-distribution channel for the compiled PDF.
3. **Inquiry site plus LinkedIn** as the amplification layer pointing readers to the
   canonical paper URL.
4. **AgenticDev 2026 at ASE 2026** as the primary formal submission venue, with
   **ICSE 2027 NIER** as the first fallback.

## Channel 1: arXiv

arXiv is the public preprint surface. Once the paper receives a real arXiv identifier,
that identifier becomes the canonical public link reused by the site, LinkedIn, and
other outward-facing references.

Until the identifier exists, placeholders may point only to `https://arxiv.org/` as a
temporary reminder surface, not as if the final preprint URL already existed.

## Channel 2: GitHub Releases

GitHub releases distribute the compiled manuscript PDF as a release asset.

Important policy: the PDF is a generated artifact and should **not** be versioned in
Git. The repository versions the manuscript sources (`.md`, `.tex`, `.bib`) and rebuilds
the PDF during release preparation or CI.

This keeps source control clean while still letting each tagged release ship the paper
artifact beside the CLI binaries.

## Channel 3: Site and LinkedIn

The Inquiry website should expose a public publications surface that points readers to
the canonical paper URL and the live distribution channels.

LinkedIn is the announcement surface, not the canonical archive. The LinkedIn post
should link primarily to the arXiv paper once available, and secondarily to the Inquiry
publications page or releases page for context.

## Channel 4: Formal venue submission

The primary formal venue remains [real-cfp-target-decision.md](real-cfp-target-decision.md):
AgenticDev 2026 at ASE 2026. If that path fails or becomes structurally incompatible,
the first fallback remains ICSE 2027 NIER.

This channel governs formal peer-review submission. It does not replace arXiv,
GitHub-release distribution, or the public amplification surfaces.

## Update rule

When a real arXiv identifier exists, update all outward-facing placeholders in one pass:

- site publications page,
- LinkedIn draft or published post,
- any manuscript-facing public-link note that still points only to the arXiv home page.

Do not create multiple competing public paper URLs when one canonical arXiv URL is
available.