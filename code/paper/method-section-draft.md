# Method Section Draft

> **Type:** method
> **Status:** draft
> **Depends on:** [experimental-protocol.md](experimental-protocol.md), [constructs-and-measures.md](constructs-and-measures.md), [task-corpus.md](task-corpus.md), [scoring-rubrics.md](scoring-rubrics.md), [evidence/evidence-plan.md](evidence/evidence-plan.md), [protocol-freeze-decision.md](protocol-freeze-decision.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), future manuscript draft

This document is the manuscript-facing method draft for the first paper. It translates
the frozen protocol and the pilot's scoring rules into prose that can be carried into a
paper draft without reopening the study design by accident.

## Study design

The first paper uses a small comparative pilot to test the method before claiming broad
substantive results. The design compares the same model under two conditions on the same
repository tasks: Inquiry's explicit harness versus host-native freestyle use of the
same model. The pilot's purpose is methodological first. It asks whether the study can
produce interpretable evidence about clarification behavior, evidence-discipline,
reconstructability, and overhead without letting uncontrolled variation dominate the
comparison.

Across paired runs, the protocol holds constant the starting repository revision, the
task packet, the host environment, the model family, and the human-availability rule as
far as the environment permits. Condition order is counterbalanced across tasks so that
the pilot does not confound every outcome with a fixed Harness-first or Freestyle-first
sequence.

## Conditions

Condition H executes the task through Inquiry's explicit harness: FSM structure, named
operators, durable intermediate artifacts, and trace-producing workflow. Condition F
executes the same task in the host's native model interface without the Inquiry harness
and without feeding stateful harness artifacts into the run.

The comparison is therefore not "tooling versus no tooling" in the abstract. It is the
same model on the same bounded task with and without the explicit harness rules that
Inquiry imposes.

## Pilot corpus

The pilot corpus contains three historical tasks from the repository, each small enough
to be executed in a single session but different enough to stress the method across more
than one task type.

| Task | Type | Historical anchor | Role in the pilot |
|---|---|---|---|
| T1 | bug fix | commit `4739cf1` | corrective debugging case after Windows-path preflight refinement |
| T2 | feature slice | issue `#170`, commit `3e0f2d8` | bounded user-facing behavior addition |
| T3 | refactor | commit `447cf29` | structural rename without new outward functionality |

This corpus is intentionally small. Its job is not broad generalization. Its job is to
stress the protocol across a minimal range of software-work types while keeping the
artifact trail interpretable enough for pilot scoring.

## Task packet and run execution rules

Each paired run is governed by a condition-neutral task packet. The packet specifies the
task statement, the starting revision, the intended success target, and a shared scored
stop line. That stop line is crucial: it defines the point at which the primary paired
comparison is judged complete for C1 through C4. Each packet also fixes the shared
validation surface and names any work that is explicitly outside the primary paired
comparison.

Before either scored run begins, the investigator performs a condition-neutral preflight
from the packet's starting revision to verify that the task is still scorable in the
stated form. If preflight or packet repair reveals a likely solution path, the scored
conditions then restart in fresh host sessions so that setup discovery is not silently
counted as part of either condition's transcript.

Both conditions begin from materially equivalent repository state. Outputs from one
condition may not be fed into the other as guidance. If capture reliability forces one
condition to use a share-producing fallback mode, the paired condition must use its own
documented fallback as well unless host mode itself is being treated as a study
variable.

The human investigator may answer direct questions from the active system, stop a run
for safety or obvious protocol breakdown, and record observations outside the run. The
investigator may not volunteer hints, redirect the solution path, or provide unsolicited
repair guidance during a valid run.

## Shared completion boundary and post-target separation

The protocol separates the shared scored stop line from later integration work. Once the
paired conditions reach the concrete success target and the packet's shared validations
pass in the same worktree state, the primary scoring boundary has been reached.

Any subsequent release preparation, versioning, changelog work, PR packaging, END or
EVOLUTION mechanics, or other repository integration tasks are recorded as post-target
extension rather than folded into the main comparison. This separation was introduced to
prevent the harness from appearing costlier merely because it continued into workflow
machinery that the paired freestyle run never needed to mirror.

## Records retained for scoring

The protocol is artifact-forward. For each paired run, the retained record includes the
task packet, the paired-run capture sheet, the transcript or equivalent interaction
record for each condition, a durable session export or an explicit export-failure note,
the produced artifact set, shared stop-line validation outputs, final diff/status
snapshots, and the available overhead record.

In the pilot corpus, the harness condition usually left a richer artifact set,
including issue selection state, analysis and plan artifacts, validation bundles, and
trace records. The freestyle condition could leave a thinner trail, but under the
revised protocol it still had to leave enough durable material for later scoring rather
than relying on observer memory.

## Constructs and measures

The pilot evaluates four claims.

| Claim | Construct | Primary measure | Main scoring unit |
|---|---|---|---|
| C1 | premature clarification | pre-evidence clarification count | question event |
| C2 | evidence-disciplined claim | evidence-cited claim share | action-justifying claim |
| C3 | reconstructability | decision-trail reconstruction completeness | run |
| C4 | overhead | tool calls, turns, wall-clock, token or token-proxy profile | run pair |

An evidence-gathering event is any observable act of inspecting repository state before
asking the user or taking action. A clarification counts as premature when it occurs
before such evidence gathering, or after only superficial inspection that does not
materially narrow the uncertainty blocking the next step. Evidence-disciplined claims
are action-justifying claims that cite concrete support before the corresponding action.
Reconstructability is judged from the artifact set alone, not from live observer memory.
Overhead is treated as a first-class construct rather than a nuisance variable.

## Scoring procedure

The pilot uses a shared `0-1-2` rubric across constructs, where `0` denotes absent or
weak support, `1` partial or ambiguous support, and `2` strong or complete support. C1
is scored at the question-event level, C2 at the claim level, and C3/C4 at the run or
run-pair level.

The primary pilot coding pass is performed by the investigator immediately after each
pair completes. Because the pilot's purpose is methodological, this first pass is used
to test whether the study can generate interpretable evidence at all. A conservative
second pass then re-reads the retained record using a stricter durable-artifact-first
rule: when live observation and preserved artifacts do not support the same confidence
level, the weaker durable reading controls. In the current pilot, the second-pass
codings are the controlling readings for synthesis and manuscript-facing results prose.

## Invalidation and deviation handling

Runs are marked for invalidation review when the starting state is not comparable, when
the shared scored stop line is missing or inseparable from later work, when essential
artifacts are missing, when model or host conditions differ across the pair, when one
condition is contaminated by outputs from the other, or when the human provides
substantive unsolicited guidance.

Not every broken run is useless. Invalidated or rescue-heavy runs still inform protocol
refinement. Under the frozen protocol, however, such events must be surfaced explicitly
as deviations rather than normalized away inside narrative prose.

## Reporting stance

The study adopts three reporting constraints.

First, evidence outranks retrospective narrative: durable traces, validation outputs,
and authoritative artifacts control interpretation. Second, null and mixed findings are
reported as findings rather than softened into rhetorical support. Third, overhead is
reported unconditionally, including cases where the harness appears practically costly.

These constraints matter because the current pilot does not justify a broad strong-path
claim. The pilot's most stable result is overhead, while the evidence on clarification,
evidence-discipline, and reconstructability remains null or mixed once baseline capture
quality is made durable enough to score conservatively.

## Method status after the pilot

Following T1 through T3, the revised protocol is now frozen for the next evidence-
collection stage. This freeze does not imply that the study is threat-free or that the
harness has already been validated on all claims. It means the pilot has done its
methodological job: the rule set is now strong enough to support disciplined evidence
collection without another preemptive redesign.