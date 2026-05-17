# Epistemic Audit Skill Proposal

## Purpose
This document records the design proposed after the research in [reasoning-beyond-evidence-humans-llms.md](reasoning-beyond-evidence-humans-llms.md). The central motivation is that a generative AI should not be treated as a subject with reliable introspective access to its own reasons. A model can produce a plausible answer, then produce a plausible retrospective explanation of that answer, without either step constituting an audited evidential trace.

The proposed response is a standalone skill whose job is not to generate conclusions but to audit the evidential status of conclusions against an explicitly bounded corpus.

## Core Thesis
A generative model is a plausibility optimizer before it is a truth-tracker. Once it finds a plausible direction, it can continue reinforcing that direction through coherence, completion pressure, and local consistency. This creates a familiar failure mode:

1. The model forms a plausible conclusion.
2. The model treats that conclusion as if it were already well-supported.
3. The model selectively interprets later evidence in that direction.
4. The model can then narrate its own error in a way that sounds explanatory, even when that narration is itself only another plausible generation.

The skill proposed here is meant to break that loop by replacing introspective self-justification with public, auditable justification.

## Problem Statement
The key epistemic problem is not simply that a model can be wrong. The deeper problem is that the model can collapse several distinct epistemic stages into one smooth paragraph:

1. Observed evidence.
2. Hypothesis generation.
3. Implicit assumptions.
4. Intermediate inference.
5. Final conclusion.
6. Confidence claim.

When those are collapsed, plausibility is easily mistaken for proof. The user then receives a coherent answer whose real evidential status is unclear.

This also explains why naive self-verification is not enough. If the same style of model simply re-reads its own conclusion and asks whether it is supported, the result can be redundant. The system may only restate the same hidden warrant in different words.

## Design Goal
The proposed skill should answer this question:

Given a bounded corpus and a set of candidate conclusions, which conclusions are directly supported, which are only inferentially supported, which are contradicted, and which are not licensed by the available evidence?

This is not a truth oracle. It is an evidential licensing system.

## Non-Goals
The skill should not pretend to do the following:

1. Determine universal truth outside the provided corpus.
2. Reconstruct the true hidden causal pathway inside the model.
3. Replace executable validation where executable validation exists.
4. Treat every inference beyond quotation as invalid.
5. Collapse all support judgments into a binary true or false label.

## Why This Is Not Redundant
The generator and the auditor do different jobs.

The generator proposes a claim.
The auditor checks whether the burden of proof for that claim has been discharged.

That distinction matters. The right verification question is not:

"Do I still believe this conclusion?"

It is:

"What exact evidence in the corpus licenses this conclusion, by what inferential relation, under what assumptions, and against what counterevidence?"

A system that cannot answer that second question should not be allowed to present the conclusion as established.

## Object of Audit
The atomic unit of output should be a claim record. Each claim record should contain at least the following fields:

1. Claim text.
2. Claim identifier.
3. Claim type.
4. Evidence spans.
5. Evidence source identifiers.
6. Support relation type.
7. Warrant.
8. Backing.
9. Rebuttals or counterevidence.
10. Verdict.
11. Confidence.
12. Analyst notes.

This is the minimum public object needed for an auditable epistemic judgment.

## Claim Types
Different claims require different standards of support. The skill should classify each claim before evaluating it. A practical starting taxonomy is:

1. Descriptive corpus claim.
   Example: a document states X.
2. Normative claim.
   Example: the process requires Y.
3. Historical or state claim.
   Example: issue 48 is closed.
4. Causal claim.
   Example: mechanism A causes behavior B.
5. Code behavior claim.
   Example: this command writes state.yaml.
6. Empirical claim.
   Example: a study found Z.
7. Interpretive claim.
   Example: this architecture implies a separation of concerns.
8. Hypothesis or abductive explanation.
   Example: the likely reason for failure is W.

This typing is necessary because the evidential burden for a quotation claim is not the same as the burden for a causal or interpretive claim.

## Verdict Taxonomy
The skill should not use a crude binary supported or unsupported label by default. It should use a graded verdict system such as:

1. Entailed by corpus.
   The claim follows directly from explicit content, executable result, or formal artifact.
2. Directly supported.
   The corpus states the substance of the claim clearly, though not with full logical entailment.
3. Reasonably inferred.
   The claim is not explicit but follows by transparent and defeasible reasoning from the cited material.
4. Weakly supported.
   Some evidence points in the direction of the claim, but important warrants or conditions remain underjustified.
5. Insufficient support.
   The cited evidence does not adequately license the claim.
6. Contradicted by corpus.
   Available corpus material conflicts with the claim.
7. Undecidable from corpus.
   The corpus does not provide enough information to assess the claim.

This avoids the recurring mistake of treating every plausible inference as if it were already proven.

## Support Relation Types
Each claim-evidence link should be typed. Useful relation labels include:

1. Direct quotation.
2. Close textual entailment.
3. Structural inference.
4. Executable confirmation.
5. Inductive summary.
6. Abductive explanation.
7. Analogy.
8. Interpretive synthesis.

The skill should make these relations explicit. An abductive relation may be legitimate, but it should never be silently smuggled in as if it were direct quotation.

## Core Principles

### 1. Strict Traceability
Every substantial judgment must be anchored to exact evidence spans, not just to whole documents in general. The skill must be able to point to the exact text, output, or artifact on which the judgment rests.

### 2. Claim Atomization
Complex statements should be decomposed into smaller claims before evaluation. This prevents vague composite claims from hiding unsupported subclaims.

### 3. Warrant Exposure
The skill must state the inferential bridge from evidence to conclusion. If the bridge cannot be made explicit, the conclusion should not receive a strong verdict.

### 4. Counterevidence Search
The skill must search not only for confirming evidence but also for rebuttals, exceptions, limit clauses, silence, and conflicting passages.

### 5. Heterogeneous Validation
No single generative judgment should be sovereign. Where possible, the skill should combine retrieval, quotation, NLI-style classification, adversarial checks, and deterministic validation.

### 6. Standards by Claim Type
The skill should use different proof obligations for different kinds of claims rather than one global notion of support.

## Formal Methodologies
The proposal can be grounded in several formal or semi-formal methodologies.

### Traceability Matrix
This provides a public mapping from claims to evidence artifacts. It is useful for descriptive, normative, and repository-state claims.

### Toulmin Model
Each claim can be represented as:

1. Claim.
2. Data.
3. Warrant.
4. Backing.
5. Qualifier.
6. Rebuttal.

This is especially helpful because many model errors occur in the warrant rather than in the quoted evidence.

### Natural Language Inference
NLI-style classification can help identify whether a cited span entails, contradicts, or is neutral with respect to a claim. It should be treated as a subordinate signal, not as the final authority.

### Defeasible Reasoning
The system should treat many conclusions as defeasible rather than absolute. This is particularly important for interpretive and abductive judgments.

### Adversarial Review
A second pass should deliberately search for defeating evidence and alternative explanations. This helps prevent confirmation bias.

### Calibration and Scoring
If the skill emits confidence values, those values should be empirically measured rather than trusted by feel. Accuracy, over-support rate, omission rate, and calibration should be tracked.

## Verification Pipeline
A practical pipeline for the skill would look like this.

### Stage 1 - Input Normalization
Inputs should include:

1. Bounded corpus.
2. Candidate conclusions or source document.
3. Desired proof standard.
4. Claim type hints if available.

### Stage 2 - Claim Extraction
Extract candidate conclusions and atomize them into auditable claims.

### Stage 3 - Evidence Retrieval
Retrieve candidate evidence spans from the corpus for each claim.

### Stage 4 - Evidence Anchoring
Require exact textual, structural, or executable anchors.

### Stage 5 - Relation Classification
Classify the evidence-claim relation using typed support categories.

### Stage 6 - Warrant Construction
State the warrant explicitly.

### Stage 7 - Counterevidence Search
Search for contradictions, exceptions, missing conditions, or corpus silence.

### Stage 8 - Verdict Assignment
Assign a graded verdict and confidence value.

### Stage 9 - Report Generation
Produce a durable report with a claim-by-claim audit trail.

## Claim Evaluation Template
A single claim record could follow this structure:

### Claim
A concise atomic statement.

### Type
Descriptive, normative, historical, causal, code behavior, empirical, interpretive, or abductive.

### Evidence
Exact spans or executable artifacts supporting the claim.

### Support Relation
Direct quotation, entailment, structural inference, executable confirmation, induction, abduction, or synthesis.

### Warrant
Why the evidence licenses the claim.

### Counterevidence
Conflicting passages, exception clauses, or relevant absences.

### Verdict
One of the graded verdict labels.

### Confidence
High, medium, or low, with explanation.

## Proof Standards by Claim Type

### Descriptive Corpus Claims
Primary standard:

1. Exact quotation or close entailment from the corpus.

### Normative Claims
Primary standard:

1. Citation to the governing contract, spec, or policy.
2. Precedence rule if multiple documents disagree.

### Historical or Repository-State Claims
Primary standard:

1. Issue state.
2. Commit history.
3. File contents.
4. Timestamps or current artifacts.

### Code Behavior Claims
Primary standard:

1. Local code reading.
2. Tests.
3. Narrow executable check.
4. Static reasoning tied to control flow.

### Causal Claims
Primary standard:

1. Explicit mechanism in corpus.
2. Or else downgrade to interpretive or abductive status.

### Empirical Claims
Primary standard:

1. Study citation.
2. Method.
3. Sample or benchmark context.
4. Limits and external validity.

### Interpretive Claims
Primary standard:

1. Multiple converging pieces of evidence.
2. Explicit warrant.
3. Counterevidence review.

### Abductive Claims
Primary standard:

1. Must be labeled as hypothesis.
2. Must state alternatives.
3. Must not be promoted to established fact without further confirmation.

## Mechanisms to Prevent Self-Validation Loops
The system must not rely on one homogeneous pass of the same reasoning style. Several safeguards are needed.

### 1. Prompt Separation
Generation and audit prompts should have different objectives.

### 2. Blind Second Pass
A second pass should examine evidence without inheriting the first pass's framing when possible.

### 3. Adversarial Retrieval
One retrieval stage should search for support; another should search for defeat.

### 4. Deterministic Checks
Quoted spans, line references, executable outputs, and artifact existence should be verified deterministically when possible.

### 5. Multi-Signal Judgment
Final verdicts should depend on several signals rather than one language-model judgment.

## Typical Failure Modes the Skill Must Detect

### Support Laundering
A conclusion cites a passage that sounds adjacent to the claim but does not actually license it.

### Warrant Smuggling
The evidence is real, but the inferential bridge is hidden and unjustified.

### Quote Without Entailment
A passage is cited verbatim, but the claim goes beyond what the passage says.

### Silence Mistaken for Support
The corpus does not contradict the claim, but neither does it support it.

### Overconfident Abduction
A plausible explanation is presented as if it were already an established fact.

### Self-Agreement Mistaken for Verification
The model restates the same reasoning in new words and treats repetition as confirmation.

### Context Omission
A supporting passage is cited while a nearby limit clause or exception is ignored.

## Recommended Output Contract
The skill should produce one durable markdown report with at least these sections:

1. Corpus definition.
2. Audit standard.
3. Claim inventory.
4. Claim-by-claim evidence audit.
5. Unsupported or weakly supported claims.
6. Contradicted claims.
7. Undecidable claims.
8. Aggregate summary.
9. Methodological limitations.

A tabular appendix can be added for quick scanning, but the core output should preserve explicit warrants and counterevidence.

## Recommended Naming
The canonical name should be:

1. kritik

This is the strongest name because it captures the real function of the skill.

The skill is not merely auditing evidence in a bureaucratic sense. It is examining whether a conclusion is entitled to stand given the available evidence, the authority of its sources, the warrant connecting evidence to claim, the presence of counterevidence, and the limits of the inferential leap.

That is critique in the Kantian sense: not a takedown, not a review, but an examination of legitimacy, scope, and limit.

The more literal alternatives remain useful as glosses, but not as the canonical name:

1. evidence-audit is too narrow because the skill does more than retrieve or check evidence.
2. epistemic-audit is closer, but still sounds procedural rather than conceptual and is less memorable as an invocable capability.

The right split is therefore:

1. `kritik` as the canonical skill name
2. evidence audit or epistemic audit as explanatory paraphrases in documentation when needed

## Relation to Existing Inquiry Surfaces
This skill would complement, not replace, research and analysis surfaces.

1. research gathers and synthesizes external sources.
2. kritik checks which claims are actually licensed by the selected corpus.
3. execution and testing remain necessary for behavioral claims.

A healthy workflow could therefore be:

1. Research or analysis produces candidate conclusions.
2. Kritik classifies their evidential status.
3. Only then are high-confidence conclusions promoted into planning or architectural claims.

## Strong Recommendations

### Do Not Use Proved Lightly
The words proved or demonstrated should be reserved for unusually strong cases such as:

1. Formal entailment.
2. Executable confirmation.
3. Explicit normative requirement.

In most other cases, graded support language is more honest.

### Treat Retrospective Explanations as Clues, Not Ground Truth
When a model says it assumed something, that statement may still be useful as a local diagnosis, but it should not be treated as a privileged introspective trace.

### Separate Generation from Certification
The system that proposes a conclusion should not, by itself, certify that the conclusion is licensed.

## Open Questions
Several design questions remain open.

1. How much NLI should be used versus deterministic span-based rules?
2. Should the skill require claim atomization from the caller, or perform it internally?
3. What is the right confidence calibration scheme for mixed evidence types?
4. Should the skill support executable validators directly for code claims, or delegate those to other surfaces?
5. How should corpus precedence be defined when documents conflict?

## Minimal Version
A coherent v1 of the skill would do only the following:

1. Extract claims.
2. Retrieve exact evidence spans.
3. Classify each claim as entailed, directly supported, reasonably inferred, insufficiently supported, contradicted, or undecidable.
4. Require a one-sentence warrant.
5. Require a one-sentence counterevidence search result.
6. Emit one markdown report.

That would already be useful and would avoid the biggest current error: allowing plausibility to masquerade as evidence.

## Final Summary
The proposal can be stated compactly:

Do not ask a generative AI whether it still believes its own conclusion. Force it to discharge a public burden of proof over a claim-evidence-warrant-rebuttal structure grounded in exact corpus traces.

That is the core design move needed to reduce unsupported but plausible conclusions in an AI system optimized for plausibility.