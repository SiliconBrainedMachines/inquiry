---
name: kritik
description: 'Audit whether conclusions are authorized by a bounded corpus through exact evidence, sources, warrants, counterevidence, and inferential limits, and produce one durable markdown report.'
---

# kritik - Evidential Licensing Protocol

## When to Use

- You need to audit whether candidate conclusions are actually licensed by a bounded corpus
- A plausible answer must be separated from its public burden of proof
- You need a durable, auditable report rather than only chat output
- The problem requires exact evidence spans, explicit warrants, and counterevidence search
- You suspect a conclusion may be overextended, support-laundered, or only weakly inferred

## Invocation Scope

- This skill is standalone and user-invoked directly.
- v1 scope is direct invocation only.
- Do not couple this protocol to automatic routing, phase-specific flows, or hidden certification steps.
- `kritik` complements `research`, analysis, and executable validation. It does not replace them.

## Inputs

Required:
- Bounded corpus
- Candidate conclusions, claims, or source text to audit

Optional:
- Desired proof standard
- Claim type hints
- Output path
- Context and constraints

## Output Contract

Produce exactly one markdown artifact (`.md`) with this mandatory structure:

```markdown
# <Title>

## Corpus Definition
## Audit Standard
## Claim Inventory
## Claim-by-Claim Audit
### Claim 1 - <short label>
#### Claim
#### Type
#### Evidence
#### Support Relation
#### Warrant
#### Counterevidence
#### Verdict
#### Confidence
## Unsupported or Weakly Supported Claims
## Contradicted Claims
## Undecidable Claims
## Aggregate Summary
## Methodological Limitations
```

Rules:
1. The output is a single durable artifact.
2. Every substantial judgment must be anchored to exact evidence spans, executable artifacts, or an explicit statement that no adequate anchor was found.
3. Every claim must include a typed support relation and an explicit warrant.
4. Every claim must include a counterevidence search result, even when none is found.
5. Verdicts must use the approved v1 labels only: `entailed`, `directly supported`, `reasonably inferred`, `insufficiently supported`, `contradicted`, `undecidable`.
6. The report must distinguish evidence from interpretation.
7. The report must state methodological limitations explicitly, including bounded-corpus limits.

Persist the report as a `.md` file in the appropriate project directory. Use a descriptive filename such as `kritik-<topic>.md`.

## Staged Protocol

Follow stages in order and do not skip forward.

### Stage 1: Corpus Framing

- Normalize the corpus boundary.
- Identify what is in scope and out of scope.
- If the corpus is ambiguous, unbounded, or only implied, ask for clarification before continuing.
- State the proof standard to be used.

Exit condition:
- Corpus boundary and audit standard are explicit.

### Stage 2: Claim Extraction and Atomization

- Extract candidate conclusions or normalize user-provided claims.
- Decompose compound statements into atomic claims.
- Assign each claim an identifier and a claim type.

Claim type options:
- Descriptive corpus claim
- Normative claim
- Historical or repository-state claim
- Causal claim
- Code behavior claim
- Empirical claim
- Interpretive claim
- Hypothesis or abductive explanation

Exit condition:
- The claim inventory is complete and each claim is atomic enough to audit.

### Stage 3: Evidence Retrieval and Anchoring

- Retrieve candidate evidence spans for each claim.
- Prefer exact quotations, narrow artifacts, and executable outputs over broad document references.
- If no exact anchor can be found, record that absence explicitly.

Exit condition:
- Each claim has either a candidate evidence set or an explicit no-anchor finding.

### Stage 4: Relation and Warrant Analysis

- Classify the claim-evidence relation.
- State the warrant that connects the evidence to the claim.
- Do not present an abductive bridge as if it were quotation or entailment.

Support relation options:
- Direct quotation
- Close textual entailment
- Structural inference
- Executable confirmation
- Inductive summary
- Abductive explanation
- Analogy
- Interpretive synthesis

Exit condition:
- The inferential bridge is explicit for every claim.

### Stage 5: Counterevidence Search

- Search for contradictions, exceptions, nearby limit clauses, missing conditions, and relevant silences.
- Look for defeat as actively as you look for support.
- Record whether the corpus contains counterevidence, unresolved tension, or silence.

Exit condition:
- Each claim has an explicit defeater search result.

### Stage 6: Verdict Assignment and Report Generation

- Assign one graded verdict per claim.
- State confidence as high, medium, or low with brief rationale.
- Produce the final report with aggregate summary and limitations.

Exit condition:
- The report is durable, traceable, and explicit about uncertainty.

## Quality Gate Checklist

Before finishing, verify:

- Exactly one markdown report was produced
- Corpus boundary is explicit
- Claim inventory is atomized
- Every claim has exact evidence or an explicit no-anchor finding
- Every claim has a support relation and warrant
- Every claim has a counterevidence search result
- Every verdict uses the approved v1 labels
- Methodological limitations explicitly state that `kritik` is not a truth oracle

## Non-Goals (v1)

- No automatic scheduler integration
- No hidden certification of generated conclusions
- No claim that a reported warrant is thereby proven sound in the strongest philosophical sense
- No replacement of executable validation where executable checks exist
- No binary collapse of all claims into true or false

## Canonical Definition

`kritik` is the skill that audits whether a conclusion is authorized by the available evidence, sources, warrant, counterevidence, and limits of inference within a bounded corpus.

Short formula:

`kritik` places a conclusion before a tribunal of evidence, source, warrant, counterevidence, and limit.