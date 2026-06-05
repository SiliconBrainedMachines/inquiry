# Constructs and Measures — First Paper

> **Type:** method
> **Status:** draft
> **Depends on:** [thesis.md](thesis.md), [research-question.md](research-question.md), [evidence/evidence-plan.md](evidence/evidence-plan.md)
> **Used by:** future protocol document, future scoring-rubrics document, ongoing investigator workflow

This document defines the paper's core constructs in operational terms. Its purpose is
to prevent drift between the conceptual claim and the empirical method. The first paper
does not test whether the harness is "good" in a vague sense; it tests whether specific
constructs move in the predicted direction under stated conditions.

## Units of analysis

The first paper works with five basic units.

- **Task** — one bounded software-work item executed under one condition.
- **Run** — one full attempt to complete a task under a single condition.
- **Question event** — one explicit request to the user for missing information or a decision.
- **Claim** — one explicit assertion used to justify a next step, plan element, or code action.
- **Artifact set** — the durable record left by the run: diagnosis, plan, traces, metrics, and closure artifacts.

These units are intentionally simple. The first paper should prefer coarse, robust
measurement over fine-grained pseudo-precision.

## Core constructs

### Evidence-gathering event

An **evidence-gathering event** is an observable act of inspecting the task's available
record before asking the user or taking action. In the first paper, this includes:

- reading repository files,
- searching repository text,
- reading issue or PR context already in scope,
- reading prior cycle artifacts,
- and executing bounded inspection commands whose purpose is to reveal repo state.

It does **not** include speculative reasoning, rhetorical restatement of the task, or a
question to the user.

### Premature clarification

**Premature clarification** is a question event issued before any qualifying
evidence-gathering event has occurred for the active task, or after only superficial
inspection that does not materially reduce uncertainty.

For the first paper, the primary measure is:

- **Pre-evidence clarification count** — number of question events issued before the run
  establishes a genuine evidence-gathering event.

This construct operationalizes claim C1 in [research-question.md](research-question.md).

### Action-justifying claim

An **action-justifying claim** is an explicit assertion that licenses a concrete next
step. Examples include claims used to justify:

- a diagnosis,
- a plan item,
- a code modification,
- a state transition,
- or a closure judgment.

Not every sentence in a run is an action-justifying claim. The construct is limited to
claims that actually authorize movement in the task.

### Concrete evidence citation

A **concrete evidence citation** is a traceable pointer to an external support surface
for an action-justifying claim. For the first paper, acceptable citation forms include:

- a repository path,
- a code location,
- a prior artifact,
- a command result,
- a test result,
- an issue or PR record,
- or a trace/metrics record.

Generic phrases such as "the code suggests" or "it seems" do not count as citations.

### Evidence-disciplined claim

An **evidence-disciplined claim** is an action-justifying claim that includes at least
one concrete evidence citation before the corresponding action is taken.

For the first paper, the primary measure is:

- **Evidence-cited claim share** — the proportion of action-justifying claims that are
  evidence-disciplined within a run.

This construct operationalizes claim C2 in [research-question.md](research-question.md).

### Decision trail

A **decision trail** is the reconstructable sequence by which a run moves from task
statement to action. At minimum it includes:

- what problem framing was adopted,
- what evidence was treated as relevant,
- what claims were used to justify movement,
- and what actions followed from those claims.

The paper does not require full cognitive transparency. It requires a durable trail rich
enough that an informed third party can reconstruct why the run moved as it did.

### Reconstructability

**Reconstructability** is the degree to which a third party, given only the artifact set,
can recover the decision trail of a run.

For the first paper, the primary measure is:

- **Decision-trail reconstruction completeness** — a rubric-based score indicating how
  much of the task framing, evidence base, justification chain, and action sequence can
  be recovered from the artifacts alone.

This construct operationalizes claim C3 in [research-question.md](research-question.md).

### Overhead

**Overhead** is the observable cost imposed by the harness relative to freestyle use of
the same model on the same task.

For the first paper, the overhead profile includes at least:

- tool calls,
- turns,
- wall-clock time,
- and token or token-proxy measures when available.

The paper treats overhead as a first-class construct, not as a nuisance variable to hide.
This construct operationalizes claim C4 in [research-question.md](research-question.md).

## Measures table

| Claim | Construct | Primary measure |
|---|---|---|
| C1 | Premature clarification | Pre-evidence clarification count |
| C2 | Evidence-disciplined claim | Evidence-cited claim share |
| C3 | Reconstructability | Decision-trail reconstruction completeness |
| C4 | Overhead | Tool calls, turns, wall-clock, token / token-proxy profile |

## Boundary notes

- This document defines **what** is being measured, not yet **how** raters score it in
  detail. That belongs in the future scoring-rubrics document.
- This document does not yet define task selection or run invalidation rules. That
  belongs in the future protocol document.
- If the pilot shows that a construct cannot be measured cleanly, the construct must be
  revised before the protocol is frozen.