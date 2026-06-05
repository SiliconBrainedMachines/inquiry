# T1 Pilot Pair — First Scoring Pass

> **Type:** evidence
> **Status:** draft
> **Depends on:** [../constructs-and-measures.md](../constructs-and-measures.md), [../experimental-protocol.md](../experimental-protocol.md), [../scoring-rubrics.md](../scoring-rubrics.md), [../t1-pilot-runbook.md](../t1-pilot-runbook.md)
> **Used by:** [../first-paper-checklist.md](../first-paper-checklist.md), future results section

This file records the first investigator coding pass required immediately after the
completion of the reformulated T1 Harness/Freestyle pair.

## Pair scope

- **Task:** T1 reformulated Windows ape prompt path task.
- **Harness condition (H):** full Inquiry harness run in `inquiry-pilot-t1-h`.
- **Freestyle condition (F):** host-native Copilot CLI run in `inquiry-pilot-t1-f`.

## Evidence used

### Harness

- Exported session share: `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h/pilot-records/t1-harness-share-v0.7.7.md`
- Durable cleanroom artifact set:
  - `cleanrooms/231-windows-ape-prompt-tests-should-use-git-resolved-p/analyze/confirmations.md`
  - `cleanrooms/231-windows-ape-prompt-tests-should-use-git-resolved-p/analyze/diagnosis.md`
  - `cleanrooms/231-windows-ape-prompt-tests-should-use-git-resolved-p/plan.md`
  - `cleanrooms/231-windows-ape-prompt-tests-should-use-git-resolved-p/run_trace.yaml`
  - `cleanrooms/231-windows-ape-prompt-tests-should-use-git-resolved-p/pre_pr_inspection.md`
  - `cleanrooms/231-windows-ape-prompt-tests-should-use-git-resolved-p/pull_request.md`
- Git and PR corroboration:
  - branch `231-windows-ape-prompt-tests-should-use-git-resolved-p`
  - PR `#233`

### Freestyle

- PowerShell transcript: `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-f/pilot-records/t1-freestyle-transcript.txt`
- Final material change surface:
  - working-tree diff in `code/cli/test/ape_prompt_test.dart`
- Live session handoff observed directly in the host-native Copilot CLI session:
  - focused validation passed (`dart analyze && dart test test/ape_prompt_test.dart`)
  - full CLI suite passed (`dart test`)
  - final change remained in `code/cli/test/ape_prompt_test.dart`

### Evidence limitation

Freestyle did not leave a durable markdown session export. The available
`t1-freestyle-transcript.txt` mostly captures the outer PowerShell shell and later
monitoring commands rather than the internal Copilot CLI dialogue. This affects C3
directly and weakens C2/C4 confidence for F.

## C1 — Premature clarification

### Event record

- **H:** no observed question event to the user after the task packet. The run begins
  with state reads, `iq doctor`, prompt inspection, repository search, and analysis
  artifact generation before any clarification is considered.
- **F:** no observed question event to the user in the visible run. The live session
  moved from file reads/searches into baseline validation before editing.

### First-pass coding

- **H strict premature-clarification count:** `0`
- **F strict premature-clarification count:** `0 observed`

### Notes

This T1 pair does not show an observable C1 advantage for either condition. The result
is still provisional for F because the durable transcript does not preserve the full
internal dialogue.

## C2 — Evidence-disciplined claim

### Claim-level coding record

| Condition | Action-justifying claim | Concrete evidence present before action? | Score |
|---|---|---|---|
| H | The bounded problem is a test-expectation mismatch, not a prompt-assembly runtime bug. | Yes. The run cites `prompt.dart`, `git_utils.dart`, `cycle_context.dart`, `ape_prompt_test.dart`, and a targeted passing subdirectory test before committing to the diagnosis/plan path. | 2 |
| H | Phase-local execution is complete enough to advance and commit because the named tests and sensor gates passed. | Yes. The run records focused tests, `dart analyze`, full-suite gates, and phase artifacts before each phase commit and before END handoff. | 2 |
| F | The mismatch is that the test hard-codes the temp repo path while prompt assembly uses git's normalized top-level root. | Yes, in the observed live run. The claim followed reads/searches across `ape_prompt_test.dart`, `prompt.dart`, and `git_utils.dart` before the edit. | 2 (provisional) |
| F | The final change is safe because focused validation and then the full suite passed on the final formatted tree. | Yes, in the observed live run. The claim followed `dart analyze && dart test test/ape_prompt_test.dart` and `dart test`. | 2 (provisional) |

### Summary judgment

- **H:** strong evidence-disciplined behavior.
- **F:** observed evidence-disciplined behavior as well, but the coding confidence is
  lower because the detailed host-native dialogue was not durably exported.

### Provisional run-level summary

- **H C2 tendency:** `2`
- **F C2 tendency:** `2`, but lower-confidence than H because the preserved record is thinner.

This T1 pair does not yet show a clear C2 advantage for H on the bounded bug-fix
itself. The main asymmetry appears in record quality, not in the visible discipline of
the concrete code/test move.

## C3 — Reconstructability

### Harness

**Score: 2 — High reconstructability**

The H artifact set permits a third party to recover all four major segments with minimal
guesswork:

- **problem framing** via `analyze/diagnosis.md`
- **evidence base** via `analyze/confirmations.md`, code/test citations, and `run_trace.yaml`
- **justification chain** via diagnosis -> plan -> phase commits -> `pre_pr_inspection.md`
- **action sequence** via `run_trace.yaml`, commit history, PR artifact, and exported session share

### Freestyle

**Score: 0 — Low reconstructability**

The F artifact set does not reliably preserve the full decision trail:

- **problem framing** is only partially recoverable from the final handoff and diff
- **evidence base** is incompletely recoverable because the internal dialogue was not exported
- **justification chain** is underdetermined from artifacts alone
- **action sequence** is only partially recoverable from the shell transcript and final diff

The key failure is not that F produced no useful work. It is that the retained artifacts
do not let a third party reconstruct the run without leaning on observer memory.

## C4 — Overhead

### Raw record preserved

#### Harness

- Exported session duration: `129m 10s`
- Observed Copilot response turns in exported share: `192`
- Observed tool-result sections in exported share: `730`
- Durable artifact expansion included analysis corpus, plan, per-phase trace, END gate,
  PR artifact, release preparation, and version/changelog work.

#### Freestyle

- Observable wall-clock window from transcript start to last full-suite completion:
  `27m 59s`
- Exact turn count: not durably preserved
- Exact tool-call count: not durably preserved
- Durable artifact set remained narrow: one changed test file plus the outer shell transcript

#### Relative wall-clock comparison

- H/F wall-clock ratio from preserved numbers: `4.62x`

### Interpretive band

**Pair score: 2 — High relative overhead**

The H condition imposed substantial extra cost relative to F. That cost was not only
instrumentation overhead; it also included real task expansion into release preparation,
version synchronization, END artifacts, PR creation, and remote handoff.

## Protocol ambiguities exposed by T1

1. **Success-target drift across conditions.**
   H did more than the bounded bug-fix task because the harness closure contract required
   release preparation, version bump surfaces, changelog work, END artifacts, and PR
   creation. F stayed close to the original bounded test-only task. This weakens the
   protocol's same-success-target control.

2. **Freestyle transcript capture gap.**
   Host-native Copilot CLI did not automatically leave a durable markdown export for F.
   Post-run export was not successfully materialized from the surviving session prompt.
   This leaves C3 and parts of C4 structurally asymmetric.

3. **Contaminated durable shell transcript for F.**
   The preserved `t1-freestyle-transcript.txt` records outer-shell setup and later
   monitoring activity, not the full internal Copilot CLI interaction. That weakens
   post hoc claim-level coding even when the live run itself looked evidence-first.

## Provisional judgment after the first pass

- **C1:** no observed difference in this task pair; both conditions show `0` observed strict positives.
- **C2:** no clear H advantage on the bounded bug-fix itself; both runs looked evidence-disciplined in the observed decision points.
- **C3:** clear H advantage because the harness leaves a reconstructable decision trail and F does not.
- **C4:** clear H cost; overhead is high relative to F in both time and artifact/process expansion.

## Implication for the pilot method

This T1 pair produced interpretable evidence, but it also exposed enough asymmetry that
the method should **not** be treated as freeze-ready yet. At minimum, the next protocol
revision should guarantee:

1. a condition-neutral success target,
2. a durable export path for host-native freestyle sessions,
3. and an overhead record that is symmetrical enough to compare H and F without relying
   on live observer notes.