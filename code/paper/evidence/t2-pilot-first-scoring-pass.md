# T2 Pilot Pair — First Scoring Pass

> **Type:** evidence
> **Status:** draft
> **Depends on:** [../constructs-and-measures.md](../constructs-and-measures.md), [../experimental-protocol.md](../experimental-protocol.md), [../scoring-rubrics.md](../scoring-rubrics.md), [t2-pair-capture.md](t2-pair-capture.md)
> **Used by:** [../first-paper-checklist.md](../first-paper-checklist.md), future results section

This file records the first investigator coding pass required immediately after the
completion of the T2 Harness/Freestyle pair.

## Pair scope

- **Task:** T2 root-version-flag feature slice.
- **Harness condition (H):** full Inquiry harness run in `inquiry-pilot-t2-h`.
- **Freestyle condition (F):** host-native Copilot CLI run in `inquiry-pilot-t2-f`.

## Evidence used

### Harness

- Exported session share: `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t2-h/pilot-records/t2-harness-share.md`
- Durable cleanroom artifact set:
  - `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand/issue.md`
  - `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand/analyze/confirmations.md`
  - `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand/analyze/diagnosis.md`
  - `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand/plan.md`
  - `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand/validation/packet_stop_line_output.txt`
  - `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand/validation/focused_validation_output.txt`
  - `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand/validation/full_validation_output.txt`
  - `cleanrooms/170-feat-version-v-flag-on-iq-tuicommand/run_trace.yaml`
- Final material change surface:
  - `code/cli/lib/inquiry_cli.dart`
  - `code/cli/test/version_test.dart`

### Freestyle

- Exported session share: `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t2-f/pilot-records/t2-freestyle-share.md`
- Durable Copilot interaction record copied from session-state:
  - `pilot-records/t2-f-session-transcript.txt`
- Focused/full validation and status artifacts:
  - `pilot-records/t2-f-focused-validation.txt`
  - `pilot-records/t2-f-full-validation.txt`
  - `pilot-records/t2-f-status.txt`
  - `pilot-records/t2-f-deviation-notes.txt`
- Final material change surface:
  - `code/cli/lib/inquiry_cli.dart`
  - `code/cli/lib/modules/global/commands/help.dart`
  - `code/cli/test/help_command_test.dart`
  - `code/cli/test/version_test.dart`

### Evidence limitation

Freestyle still retains a weak outer PowerShell transcript, but unlike T1 this no longer
drives the coding outcome because the durable markdown share and copied session-state
artifacts preserve the internal run. Harness also required one pre-run remediation
(`inquiry init` after the first launch failed due to missing repo-scoped agent files),
but the scored timing for H starts only after that relaunch.

## C1 — Premature clarification

### Event record

- **H:** no observed clarification question to the user after the packet. The run moved
  through issue confirmation, `inquiry-start`, analysis artifacts, planning, bounded
  code edits, and validation without requesting additional user input.
- **F:** no observed clarification question to the user after the packet. The run
  inspected the CLI surface, identified the owning entrypoint, edited the bounded
  slice, and ran the required validations directly.

### First-pass coding

- **H strict premature-clarification count:** `0`
- **F strict premature-clarification count:** `0`

### Notes

This T2 pair does not show an observable C1 advantage for either condition. The result
is materially cleaner than T1 because both conditions now preserve durable share
exports, so the `0` coding is not leaning on observer memory alone.

## C2 — Evidence-disciplined claim

### Claim-level coding record

| Condition | Action-justifying claim | Concrete evidence present before action? | Score |
|---|---|---|---|
| H | The bounded fix belongs in root-argument normalization rather than a wider router or SDK redesign. | Yes. `issue.md`, `analyze/diagnosis.md`, and the inspected CLI/test surfaces establish that the existing `version` command already works and that the bounded missing behavior is root alias dispatch. | 2 |
| H | The scored run is complete at the bounded stop line and should not continue into release work. | Yes. `validation/packet_stop_line_output.txt`, `validation/focused_validation_output.txt`, `validation/full_validation_output.txt`, and `run_trace.yaml` preserve that all required validations passed on one unchanged tree state before closure. | 2 |
| F | `normalizeInquiryArgs` is the correct local entrypoint for handling root `--version` and `-v`. | Yes. The durable share shows targeted inspection of `main.dart`, `inquiry_cli.dart`, `version.dart`, and existing tests before the edit, followed by a bounded patch to `inquiry_cli.dart`. | 2 |
| F | The bounded slice is complete once the four shared validations pass, without broader router redesign or release work. | Yes. `t2-f-focused-validation.txt`, `t2-f-full-validation.txt`, and `t2-f-status.txt` preserve the passing validation surface and the final bounded diff before export. | 2 |

### Summary judgment

- **H:** strong evidence-disciplined behavior.
- **F:** strong evidence-disciplined behavior as well.

### Provisional run-level summary

- **H C2 tendency:** `2`
- **F C2 tendency:** `2`

This T2 pair does not show a clear C2 advantage for either condition. H externalizes its
reasoning more formally through cleanroom artifacts, but F still preserves enough
evidence to treat its bounded action claims as concrete and prior to the edit.

## C3 — Reconstructability

### Harness

**Score: 2 — High reconstructability**

The H artifact set permits a third party to recover all four major segments with minimal
guesswork:

- **problem framing** via `issue.md` and `analyze/diagnosis.md`
- **evidence base** via `analyze/confirmations.md`, the validation logs, and `run_trace.yaml`
- **justification chain** via issue -> analyze -> plan -> bounded code slice -> validation
- **action sequence** via `run_trace.yaml`, cleanroom artifacts, and the exported share

### Freestyle

**Score: 2 — High reconstructability**

Unlike T1, the F artifact set now preserves the decision trail sufficiently well for a
third party to reconstruct the run with minimal guesswork:

- **problem framing** via the exported share and final status snapshot
- **evidence base** via the exported share, copied session-state transcript, and focused/full validation logs
- **justification chain** via share -> bounded diff -> validation artifacts -> deviation notes
- **action sequence** via the markdown share, copied transcript, and final status snapshot

The F record is still thinner than H because it lacks a cleanroom-style analysis corpus,
but it is no longer underdetermined in the way T1 was.

## C4 — Overhead

### Raw record preserved

#### Harness

- Scored wall-clock window from run start to shared stop line: `68m 09s`
- Exported session duration: `70m 18s`
- Observable share volume: `119` Copilot turns and `491` tool-result blocks
- Final bounded code diff: `2` files changed, `35` insertions, `3` deletions
- Durable artifact expansion included issue selection, analysis artifacts, plan,
  run trace, and three validation logs before closure

#### Freestyle

- Scored wall-clock window from run start to shared stop line: `6m 56s`
- Exported session duration: `7m 36s`
- Observable share volume: `7` Copilot turns and `46` tool-result blocks
- Final bounded code diff: `4` files changed, `65` insertions, `6` deletions
- Durable artifact expansion remained comparatively narrow: share export, copied
  session transcript, focused/full validation, status snapshot, and deviation notes

#### Relative wall-clock comparison

- H/F scored wall-clock ratio from preserved stop-line times: `9.83x`
- H/F exported-session ratio from preserved share durations: `9.25x`

### Interpretive band

**Pair score: 2 — High relative overhead**

The H condition imposed substantial extra cost relative to F. Unlike T1, that cost is
no longer primarily explained by post-target release drift. The preserved run trace and
pair-capture record show that the overhead now comes mainly from the harness lifecycle
itself: issue confirmation, branch and cleanroom setup, ANALYZE/PLAN artifact work,
precondition gates, and bounded validation/closure mechanics.

## Invalidation review notes for T2

1. **Freestyle changed a broader user-facing slice than Harness.**
   F also updated help text and help coverage, while H kept the scored code change to
   `inquiry_cli.dart` plus `version_test.dart`. This does not invalidate the pair because
   F stayed inside the approved top-level CLI surface and the shared stop line did not
   depend on the help edits.

2. **Harness absorbed one structured-transition retry inside ANALYZE.**
   H initially blocked on `diagnosis.md` structure before moving from ANALYZE to PLAN.
   This is real overhead and should count toward C4, but it does not contaminate the
   stop line or the bounded code slice.

3. **No pair-invalidating asymmetry remains at the scoring boundary.**
   The shared stop line, durable exports, validation surface, and final status snapshots
   are all preserved for both conditions.

## Provisional judgment after the first pass

- **C1:** no observed difference in this task pair; both conditions show `0` observed strict positives.
- **C2:** no clear H advantage on the bounded feature slice; both runs preserve concrete evidence before the decisive edit and before closure.
- **C3:** no meaningful asymmetry at this point; both conditions are reconstructable enough to score as `2`.
- **C4:** clear H cost; overhead remains high relative to F even after protocol cleanup.

## Implication for the pilot method

This T2 pair is materially cleaner than T1. The shared scored stop line, symmetric
non-interactive share fallback, and explicit validation surface successfully repaired
the reconstructability asymmetry that made T1 harder to interpret. The main remaining
method question is therefore narrower: whether the harness overhead can be reduced
without sacrificing the bounded evidence trail that T2 now preserves cleanly.