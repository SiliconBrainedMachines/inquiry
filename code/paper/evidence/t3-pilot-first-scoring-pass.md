# T3 Pilot Pair — First Scoring Pass

> **Type:** evidence
> **Status:** draft
> **Depends on:** [../constructs-and-measures.md](../constructs-and-measures.md), [../experimental-protocol.md](../experimental-protocol.md), [../scoring-rubrics.md](../scoring-rubrics.md), [t3-pair-capture.md](t3-pair-capture.md)
> **Used by:** [../first-paper-checklist.md](../first-paper-checklist.md), future results section

This file records the first investigator coding pass required immediately after the
completion of the T3 Harness/Freestyle pair.

## Pair scope

- **Task:** T3 state.yaml field-rename refactor.
- **Harness condition (H):** full Inquiry harness run in `inquiry-pilot-t3-h`.
- **Freestyle condition (F):** host-native Copilot CLI run in `inquiry-pilot-t3-f`.

## Evidence used

### Harness

- Exported session share: `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-h/pilot-records/t3-harness-share.md`
- Preserved pre-scored attempt artifacts:
  - `pilot-records/t3-harness-first-attempt-share.md`
  - `pilot-records/t3-harness-second-attempt-share.md`
  - `pilot-records/t3-h-manual-start-handoff.txt`
- Durable cleanroom artifact set:
  - `cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t/issue.md`
  - `cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t/analyze/confirmations.md`
  - `cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t/analyze/diagnosis.md`
  - `cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t/plan.md`
  - `cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t/phase4_stop_line_summary.yaml`
  - `cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t/phase4_focused_validation.txt`
  - `cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t/phase4_full_validation.txt`
  - `cleanrooms/234-refactor-rename-state-file-fields-phasestate-and-t/run_trace.yaml`
- Copied harness validation and trace bundle:
  - `pilot-records/t3-h-focused-validation.txt`
  - `pilot-records/t3-h-full-validation.txt`
  - `pilot-records/t3-h-status.txt`
  - `pilot-records/t3-h-run-trace.yaml`
  - `pilot-records/t3-h-packet-stop-line.yaml`
- Final material change surface:
  - `code/cli/lib/modules/global/commands/init.dart`
  - `code/cli/lib/modules/fsm/commands/state.dart`
  - `code/cli/lib/modules/fsm/commands/transition.dart`
  - `code/cli/test/init_command_test.dart`
  - `code/cli/test/fsm_state_test.dart`
  - `code/cli/test/fsm_transition_test.dart`
  - `code/cli/test/fsm_transition_integration_test.dart`
  - `code/cli/assets/agents/inquiry.agent.md`
  - `code/cli/assets/skills/issue-start/SKILL.md`
  - `code/cli/assets/skills/issue-end/SKILL.md`

### Freestyle

- Exported session share: `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-f/pilot-records/t3-freestyle-share.md`
- Preserved first-attempt record:
  - `pilot-records/t3-freestyle-first-attempt-share.md`
  - `pilot-records/t3-freestyle-first-attempt-transcript.txt`
- Final transcript and artifact bundle:
  - `pilot-records/t3-freestyle-transcript.txt`
  - `pilot-records/t3-f-focused-validation.txt`
  - `pilot-records/t3-f-full-validation.txt`
  - `pilot-records/t3-f-status.txt`
  - `pilot-records/t3-f-deviation-notes.txt`
  - `pilot-records/t3-f-packet-stop-line.txt`
- Final material change surface:
  - `code/cli/lib/modules/global/commands/init.dart`
  - `code/cli/lib/modules/fsm/commands/state.dart`
  - `code/cli/lib/modules/fsm/commands/transition.dart`
  - `code/cli/test/init_command_test.dart`
  - `code/cli/test/fsm_state_test.dart`
  - `code/cli/test/fsm_transition_test.dart`
  - `code/cli/test/fsm_transition_integration_test.dart`

### Evidence limitation

Both conditions are scoreable, but neither was frictionless.

- H required two preserved pre-scored attempts plus an operator-side `start_analyze`
  handoff before the scored run could proceed from ANALYZE.
- F required one preserved exploratory attempt and a bounded relaunch, then hit an
  in-run artifact-capture shell hang after the scored line passed.

Those deviations raise a real invalidation-review burden, but they do not destroy the
scoring boundary because both conditions still preserve a durable interaction record,
the shared validation surface, and a stable final diff/status snapshot.

## C1 — Premature clarification

### Event record

- **H:** no observed clarification question to the user after the packet. Even across
  the triage/handoff complications, the harness used repository state, issue handling,
  analysis artifacts, planning, bounded execution, and validation without asking the
  user for additional facts.
- **F:** no observed clarification question to the user after the packet. The run
  over-explored the repository on its first attempt, but it did not escalate to user
  questioning before editing and validation.

### First-pass coding

- **H strict premature-clarification count:** `0`
- **F strict premature-clarification count:** `0`

### Notes

This T3 pair again shows no observable C1 advantage for either condition. The result is
cleaner than T1 because both conditions now preserve durable markdown shares rather than
leaving C1 dependent on live observation alone.

## C2 — Evidence-disciplined claim

### Claim-level coding record

| Condition | Action-justifying claim | Concrete evidence present before action? | Score |
|---|---|---|---|
| H | The bounded rename belongs in the persisted FSM state-schema surfaces rather than a broader lifecycle redesign. | Yes. `issue.md`, `analyze/confirmations.md`, `analyze/diagnosis.md`, and the plan all tie the refactor to the `init` / `fsm state` / `fsm transition` surfaces and their tests before execution. | 2 |
| H | The scored run is complete at the shared stop line and should not widen into release or broader lifecycle work. | Yes. `phase4_stop_line_summary.yaml`, the phase4 validation logs, `run_trace.yaml`, and the exported share preserve that all five required validations passed on one unchanged worktree state. | 2 |
| F | The minimum bounded fix belongs in the init/state/transition command path plus the scored tests, not a broader repo-wide redesign. | Yes. The exported share shows targeted reads of those three command files and four scored tests before the edit, then a bounded patch restricted to that slice. | 2 |
| F | The run is complete once the exact five scored commands pass on the renamed state-schema surface. | Yes. The canonical share records the direct rerun of the five commands after the earlier wrapper error, and `t3-f-focused-validation.txt`, `t3-f-full-validation.txt`, and `t3-f-status.txt` preserve the scored boundary durably. | 2 |

### Summary judgment

- **H:** strong evidence-disciplined behavior.
- **F:** strong evidence-disciplined behavior as well.

### Provisional run-level summary

- **H C2 tendency:** `2`
- **F C2 tendency:** `2`

This T3 pair does not show a clear C2 advantage for either condition. H externalizes
its reasoning through a much richer cleanroom corpus, but F still preserves enough
evidence to treat its bounded action claims as concrete and prior to the edit.

## C3 — Reconstructability

### Harness

**Score: 2 — High reconstructability**

The H artifact set permits a third party to recover all four major segments with minimal
guesswork:

- **problem framing** via `issue.md` and `analyze/diagnosis.md`
- **evidence base** via `analyze/confirmations.md`, the plan artifact, the phase4
  validation bundle, and `run_trace.yaml`
- **justification chain** via issue -> analyze -> plan -> bounded code slice ->
  scored validation
- **action sequence** via `run_trace.yaml`, the exported share, and the copied pilot
  bundle in `pilot-records/`

### Freestyle

**Score: 2 — High reconstructability**

The F artifact set is thinner and less elegant than H, but it is still reconstructable
enough for third-party scoring:

- **problem framing** via the canonical share and preserved first-attempt share
- **evidence base** via the canonical share, focused/full validation logs, and the
  stable final diff/status snapshot
- **justification chain** via share -> bounded diff -> validation logs -> deviation notes
- **action sequence** via the markdown share, transcript, and copied fallback artifacts

The F record is not cleanroom-like, but unlike T1 it is no longer underdetermined.

## C4 — Overhead

### Raw record preserved

#### Harness

- Scored wall-clock window from condition start to shared stop line: `81m 20s`
- Exported canonical session duration: `71m 09s`
- Observable share volume: `32` Copilot turns and `525` tool-result blocks
- Final scored diff/status snapshot reports `11` files changed, `116` insertions, and
  `94` deletions before the post-stop artifact writes
- Durable artifact expansion included issue handling, analyze corpus, plan, run trace,
  multiple preserved relaunch artifacts, and the copied phase4 validation bundle

#### Freestyle

- Scored wall-clock window from condition start to shared stop line: `8m 11s`
- Exported canonical session duration: `8m 11s`
- Observable share volume: `9` Copilot turns and `39` tool-result blocks
- Final diff/status snapshot reports `7` files changed, `190` insertions, and `176`
  deletions
- Durable artifact expansion remained comparatively narrow: canonical share export,
  transcript, focused/full validation logs, status snapshot, stop-line note, and
  deviation notes

#### Relative wall-clock comparison

- H/F scored wall-clock ratio from preserved stop-line times: `9.94x`
- H/F exported-session ratio from preserved share durations: `8.69x`

### Interpretive band

**Pair score: 2 — High relative overhead**

The H condition imposed substantial extra cost relative to F. T3 strengthens rather than
weakens that reading because the extra cost is not coming from release drift; it comes
from harness lifecycle mechanics, multiple preserved relaunches, analysis/plan artifact
work, phase gates, and trace preservation before the bounded execution even reaches the
shared stop line.

## Invalidation review notes for T3

1. **Harness required operator intervention before the scored run could start cleanly.**
   H needed two preserved pre-scored attempts plus `t3-h-manual-start-handoff.txt`
   before the scored ANALYZE/PLAN/EXECUTE pass. This is real overhead and a real method
   deviation, but the final scored boundary remained preserved and explicit.

2. **Freestyle required one preserved exploratory attempt and one bounded relaunch.**
   The first F attempt ended without edits or scored validation. The relaunch stayed in
   the same worktree and reused only that first attempt's own local discovery, which is
   a deviation but not a cross-condition contamination.

3. **Freestyle artifact capture needed investigator-side fallback after the scored line.**
   The canonical share exported, but the in-run artifact-capture shell hung after the
   scored validations passed. The copied focused/full logs and `t3-f-status.txt` are
   therefore part of the durable scored bundle.

4. **Harness changed a slightly broader shipped surface than Freestyle.**
   H also updated shipped CLI assets that author/read `.inquiry/state.yaml`, while F
   kept its scored code slice to the three commands and four tests. This widens H's
   final diff surface, but it does not invalidate the pair because the shared stop line
   did not depend on release work or broader lifecycle redesign and both conditions'
   full suites still passed.

## Provisional judgment after the first pass

- **C1:** no observed difference in this task pair; both conditions show `0` observed strict positives.
- **C2:** no clear H advantage on the bounded refactor; both runs preserve concrete evidence before the decisive edit and before closure.
- **C3:** no meaningful asymmetry at this point; both conditions are reconstructable enough to score as `2`.
- **C4:** clear H cost; overhead remains high relative to F and is amplified by the harness-side relaunch and handoff burden.

## Implication for the pilot method

T3 extends the methodological lesson from T2. The pair remains scoreable despite real
deviations, and both conditions now preserve enough durable evidence for conservative
scoring. But T3 also makes the practical cost story even harder to ignore: the harness
can remain highly scoreable while still imposing very large overhead on a bounded
structural refactor that freestyle completed with much less orchestration.