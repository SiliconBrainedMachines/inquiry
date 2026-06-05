# Claim-to-Evidence Audit of Manuscript-Facing Pilot Drafts

## Corpus Definition

This audit uses a bounded corpus with two layers.

Audited texts in scope:

- `method-section-draft.md`
- `results-section-draft.md`
- `discussion-section-draft.md`

Authorizing corpus in scope:

- `experimental-protocol.md`
- `protocol-freeze-decision.md`
- `evidence/pilot-claim-summary-t1-t2-t3.md`
- `evidence/t1-pilot-second-scoring-pass.md`
- `evidence/t2-pilot-second-scoring-pass.md`
- `evidence/t3-pilot-second-scoring-pass.md`
- `limitations-and-threats-to-validity.md`

Out of scope:

- a full line-by-line audit of every sentence in every manuscript-facing draft,
- external truth claims beyond this repository-bounded pilot corpus,
- introduction or abstract claims that have not yet been drafted.

The audit scope is the high-stakes methodological and empirical claims that materially
govern what the current manuscript says the pilot has shown.

## Audit Standard

Proof standard: conservative bounded-corpus authorization.

- `entailed` is reserved for claims that follow with minimal interpretive residue from
  exact corpus language.
- `directly supported` is used when the corpus explicitly states or numerically anchors
  the claim, even if the claim is not a strict entailment.
- `reasonably inferred` is used when the claim is a bounded synthesis or recommendation
  that fits the corpus but is not itself directly stated by the strongest underlying
  artifacts.
- `insufficiently supported` is used when the claim outruns the bounded corpus or its
  external-validity limits.

This audit does not treat prior synthesis documents as raw truth. When a manuscript
claim rests on a synthesis document, the support relation is named explicitly rather
than disguised as direct quotation from first-order evidence.

## Claim Inventory

| ID | Source draft | Short label | Type |
|---|---|---|---|
| C1 | `method-section-draft.md` | Paired pilot design | Descriptive corpus claim |
| C2 | `method-section-draft.md` | Protocol is frozen | Descriptive corpus claim |
| C3 | `results-section-draft.md` | No observed C1 advantage | Empirical claim |
| C4 | `results-section-draft.md` | C2 mixed, parity under durable capture | Interpretive claim |
| C5 | `results-section-draft.md` | C3 mixed, parity under durable capture | Interpretive claim |
| C6 | `results-section-draft.md` | C4 is strongest stable result | Empirical claim |
| C7 | `results-section-draft.md` and `discussion-section-draft.md` | Capture discipline changes comparative story | Interpretive claim |
| C8 | `results-section-draft.md` and `discussion-section-draft.md` | Strong path unconfirmed, weaker claim warranted | Interpretive claim |
| C9 | `discussion-section-draft.md` | Thin baseline records could exaggerate H in this pilot | Interpretive claim |

## Claim-by-Claim Audit

### Claim 1 - Paired pilot design

#### Claim

The first paper uses a paired two-condition pilot that compares the same model on the
same repository tasks under shared controls, with a packet-defined shared scored stop
line.

#### Type

Descriptive corpus claim.

#### Evidence

- From `experimental-protocol.md`: "The pilot compares harness use against freestyle use of the same model."
- From `experimental-protocol.md`: controls include "the same model family and version," "the same host environment," "the same starting repository revision," "the same task statement," and "the same human-availability rule."
- From `experimental-protocol.md`: "Each task packet must define a **shared scored stop line** in addition to the general success target."

#### Support Relation

Close textual entailment.

#### Warrant

These protocol sentences explicitly define the comparison design that the method draft
describes.

#### Counterevidence

The same protocol says controls should be preserved "whenever possible" and deviations
must be recorded. That caveat narrows the claim to design intent rather than perfect
realized symmetry, but it does not contradict the manuscript wording.

#### Verdict

directly supported

#### Confidence

high - the design claim closely tracks explicit protocol language.

### Claim 2 - Protocol is frozen

#### Claim

The revised protocol is now frozen for the next evidence-collection phase.

#### Type

Descriptive corpus claim.

#### Evidence

- From `protocol-freeze-decision.md`: "Freeze the current revised protocol and use it as the controlling method for the next evidence-collection phase."
- From `experimental-protocol.md`: "it should be treated as the controlling method for the next evidence-collection phase unless a later design-level failure forces a new revision."
- From `experimental-protocol.md`: "This protocol is now frozen for the next first-paper evidence-collection phase."

#### Support Relation

Direct quotation.

#### Warrant

The freeze decision and the protocol status note explicitly state the frozen status.

#### Counterevidence

`protocol-freeze-decision.md` also states that the freeze does not mean the thesis is
settled or that all deviations disappeared. That limits the meaning of freeze but does
not contradict the claim.

#### Verdict

entailed

#### Confidence

high - the corpus states the freeze decision explicitly and repeatedly.

### Claim 3 - No observed C1 advantage

#### Claim

The pilot does not show a positive harness advantage on premature clarification.

#### Type

Empirical claim.

#### Evidence

- From `evidence/pilot-claim-summary-t1-t2-t3.md` table: C1 is `H 0, F 0 observed` for T1 and `H 0, F 0` for T2 and T3.
- From `evidence/pilot-claim-summary-t1-t2-t3.md`: "None of the three pilot tasks shows an observed C1 advantage for the harness."
- From `evidence/t1-pilot-second-scoring-pass.md`: "Both runs still appear to have gathered repository evidence before moving."
- From `evidence/t2-pilot-second-scoring-pass.md`: "Both runs still show a direct progression from bounded packet intake into repository inspection and execution without asking the user for clarifying input."
- From `evidence/t3-pilot-second-scoring-pass.md`: "Both conditions still move from packet intake into repository inspection, bounded execution, and validation without asking the user for clarifying input."

#### Support Relation

Inductive summary.

#### Warrant

All three second-pass readings code C1 as non-positive for a harness advantage, and the
three-task synthesis states the same result explicitly.

#### Counterevidence

No corpus evidence was found of a strict premature-clarification event that would defeat
the claim. T1's weak freestyle record affects reconstructability, not C1 event coding.

#### Verdict

directly supported

#### Confidence

high - the claim is numerically and textually anchored across all three second-pass documents.

### Claim 4 - C2 mixed, parity under durable capture

#### Claim

C2 is mixed overall: T1 favors H under the conservative reread, but T2 and T3 move to
parity once durable freestyle capture is stronger.

#### Type

Interpretive claim.

#### Evidence

- From `evidence/pilot-claim-summary-t1-t2-t3.md` table: C2 is `H 2, F 1` for T1 and `H 2, F 2` for T2 and T3.
- From `evidence/pilot-claim-summary-t1-t2-t3.md`: "T1 favors H under the conservative reread because the freestyle durable record was too thin... T2 returns to parity... T3 stays at parity..."
- From `evidence/t1-pilot-second-scoring-pass.md`: "The live run still looked evidence-first, but the retained durable record does not let a later reader recover the full claim sequence cleanly enough... F therefore drops to `1`."
- From `evidence/t2-pilot-second-scoring-pass.md`: "The post-T1 protocol revisions appear to have repaired the main source of uncertainty by making the freestyle record durable enough to support claim-level coding."
- From `evidence/t3-pilot-second-scoring-pass.md`: "Even with a preserved first attempt, a relaunch, and a post-validation artifact glitch, the retained F evidence is still strong enough to support the same claim-level coding as H."

#### Support Relation

Interpretive synthesis.

#### Warrant

The cross-task pattern is not a single quoted fact; it is a synthesis of the second-pass
score table plus the specific T1/T2/T3 explanations of why F was weak in T1 and stable
in T2/T3.

#### Counterevidence

The corpus still contains a real T1 harness advantage on C2. That is not a contradiction
because the audited claim is explicitly mixed rather than parity across all tasks.

#### Verdict

reasonably inferred

#### Confidence

high - the synthesis is strongly constrained by the second-pass record, but it remains a cross-task interpretation rather than a raw metric.

### Claim 5 - C3 mixed, parity under durable capture

#### Claim

C3 is mixed overall: T1 favors H, but T2 and T3 show parity once freestyle capture is
durably strong enough for reconstruction.

#### Type

Interpretive claim.

#### Evidence

- From `evidence/pilot-claim-summary-t1-t2-t3.md` table: C3 is `H 2, F 0` for T1 and `H 2, F 2` for T2 and T3.
- From `evidence/pilot-claim-summary-t1-t2-t3.md`: "T1 shows a clear H advantage... T2 removes that gap... T3 preserves that parity despite relaunches and artifact irregularities."
- From `evidence/t1-pilot-second-scoring-pass.md`: "F still fails the reconstructability test because the retained artifacts do not let a third party recover the internal decision trail without leaning on live observer memory."
- From `evidence/t2-pilot-second-scoring-pass.md`: "the exported share and copied session-state artifacts make the internal run legible enough for third-party reconstruction."
- From `evidence/t3-pilot-second-scoring-pass.md`: "T3 is therefore closer to T2 than to T1 on reconstructability: the retained freestyle record is thinner than H, but not too thin to score conservatively."

#### Support Relation

Interpretive synthesis.

#### Warrant

The claim restates the explicit cross-task reconstructability pattern preserved in the
three-task synthesis and the three second-pass audits.

#### Counterevidence

T1 does retain a strong H advantage on C3. That does not defeat the claim because the
claim explicitly says the overall pattern is mixed rather than uniformly favorable to H.

#### Verdict

reasonably inferred

#### Confidence

high - the inference is tightly constrained by the second-pass table and explanations.

### Claim 6 - C4 is strongest stable result

#### Claim

C4 is the strongest stable positive result in the pilot: harness overhead remains high
even after protocol cleanup.

#### Type

Empirical claim.

#### Evidence

- From `evidence/pilot-claim-summary-t1-t2-t3.md`: "C4 is the most stable result in the pilot."
- From `evidence/pilot-claim-summary-t1-t2-t3.md`: T2 and T3 "remove the easy escape hatch that T1 left open" and still show `9.25x` and `9.94x` asymmetries.
- From `evidence/t2-pilot-second-scoring-pass.md`: "the overhead remains high even after excluding post-target release drift as the main explanation."
- From `evidence/t3-pilot-second-scoring-pass.md`: "high H overhead persists even in a pair where both conditions remain fully scoreable under the stricter durable-artifact-first rule."

#### Support Relation

Inductive summary.

#### Warrant

The T2 and T3 second-pass documents explicitly strengthen the high-overhead reading once
protocol cleanup removed the most obvious T1 confound.

#### Counterevidence

`evidence/t1-pilot-second-scoring-pass.md` notes that some T1 overhead came from
post-target closure work. That limits how far T1 alone can carry the claim, but the T2
and T3 evidence directly addresses that limitation.

#### Verdict

directly supported

#### Confidence

high - the corpus explicitly identifies overhead as the most stable result and provides exact asymmetry values.

### Claim 7 - Capture discipline changes comparative story

#### Claim

Protocol design and capture quality change the observable comparative story between H
and F, especially on C2 and C3.

#### Type

Interpretive claim.

#### Evidence

- From `evidence/pilot-claim-summary-t1-t2-t3.md`: "This is enough to support a methodological conclusion: protocol design changes the observable comparative story, especially on C2 and C3."
- From `limitations-and-threats-to-validity.md`: "some apparent H advantage on C2/C3 may actually be a capture-quality advantage rather than a reasoning-quality advantage."
- From `evidence/t1-pilot-second-scoring-pass.md`: "The instability is methodological, not substantive: it is driven by record asymmetry between H and F rather than by a clear difference in the visible code-and-test behavior."
- From `evidence/t2-pilot-second-scoring-pass.md`: "the protocol revisions introduced after T1 appear to have worked for this task class."

#### Support Relation

Interpretive synthesis.

#### Warrant

The pilot's own conservative rereads attribute part of the apparent H/F difference to
record asymmetry and later show that protocol repair changed the observed pattern.

#### Counterevidence

`limitations-and-threats-to-validity.md` also states that the pilot is small-N, single-
repository, and not a pure like-for-like series because the protocol matured across the
pilot. That limits generalization and lowers confidence in broad causal wording.

#### Verdict

reasonably inferred

#### Confidence

medium - the interpretation is well motivated inside this pilot, but bounded-corpus and protocol-maturation limits prevent stronger generalization.

### Claim 8 - Strong path unconfirmed, weaker claim warranted

#### Claim

The current pilot does not justify the strong-path thesis and instead warrants a weaker
claim centered on scoreable record preservation, capture sensitivity, and high overhead.

#### Type

Interpretive claim.

#### Evidence

- From `evidence/pilot-claim-summary-t1-t2-t3.md`: "The current pilot evidence does not justify a strong-path results claim for the first paper."
- From `evidence/pilot-claim-summary-t1-t2-t3.md`: "What is currently defensible is a weaker synthesis" followed by the narrower bullet list.
- From `limitations-and-threats-to-validity.md`: "the paper cannot honestly present the pilot as preliminary confirmation of the full strong-path thesis."
- From `limitations-and-threats-to-validity.md`: "The strongest defensible use of the pilot is narrower: it supports a methodological claim about protocol design and a practical claim about high harness overhead."

#### Support Relation

Interpretive synthesis.

#### Warrant

The controlling pilot synthesis and the limitations document independently converge on
the same narrowing judgment.

#### Counterevidence

T1 does preserve a strong H advantage on some constructs, especially C3. That evidence
prevents a negative global thesis claim, but it does not overturn the cross-task result
that the full strong-path formulation is not authorized by the current pilot.

#### Verdict

directly supported

#### Confidence

high - the bounded corpus states the narrowing conclusion explicitly and repeatedly.

### Claim 9 - Thin baseline records could exaggerate H in this pilot

#### Claim

In this pilot, a thin baseline record could make a structured harness look stronger than
the bounded evidence later warranted.

#### Type

Interpretive claim.

#### Evidence

- From `discussion-section-draft.md`: "in this pilot, a thin baseline record could make a structured harness look stronger than the bounded evidence later warranted."
- Supporting local evidence from `evidence/pilot-claim-summary-t1-t2-t3.md`: "weak baseline capture can make freestyle look less evidence-disciplined and less reconstructable than it really is."
- Supporting local evidence from `limitations-and-threats-to-validity.md`: "some apparent H advantage on C2/C3 may actually be a capture-quality advantage rather than a reasoning-quality advantage."

#### Support Relation

Interpretive synthesis.

#### Warrant

The current pilot gives one concrete example in which baseline record weakness appears to
inflate the apparent comparative advantage of H. Once the wording is kept pilot-bounded,
the corpus is sufficient to authorize the caution.

#### Counterevidence

`limitations-and-threats-to-validity.md` still limits external validity through "Small N
and single repository," "Environment coupling," and "Bounded task class." Those limits
block broader generalization, but they no longer defeat the revised pilot-bounded
wording.

#### Verdict

reasonably inferred

#### Confidence

high - once narrowed to the pilot corpus, the caution is well aligned with the retained
evidence and validity analysis.

## Unsupported or Weakly Supported Claims

- None after narrowing C9 to the bounded pilot corpus.

## Contradicted Claims

- None in the audited claim set.

## Undecidable Claims

- None in the audited claim set under the present bounded scope.

## Aggregate Summary

The manuscript-facing pilot drafts are mostly authorized by the bounded corpus.

- **Entailed / directly supported:** C1, C2, C3, C6, C8.
- **Reasonably inferred:** C4, C5, C7, C9.
- **Insufficiently supported:** none.

The main pattern is healthy: the current manuscript generally tracks the retained pilot
evidence and the post-pilot narrowing decision. After narrowing the one overbroad
discussion warning to the pilot corpus, no audited claim remains below `reasonably
inferred`.

## Methodological Limitations

This audit is bounded and conservative, but it is not a truth oracle.

- It audits whether conclusions are authorized by the selected corpus, not whether they
  are true in some stronger external sense.
- Several audited claims rely on existing pilot synthesis documents, so some support is
  mediated through prior interpretation rather than raw first-order artifacts alone.
- The corpus itself carries known validity limits: small N, single repository, Windows-
  coupled environment, bounded task class, and protocol maturation across the pilot.
- This report audits high-stakes manuscript claims, not every sentence in the drafts.