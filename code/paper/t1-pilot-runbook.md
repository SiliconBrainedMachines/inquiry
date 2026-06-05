# T1 Pilot Runbook — Fresh Session Execution

> **Type:** method
> **Status:** draft
> **Depends on:** [task-packet-t1.md](task-packet-t1.md), [experimental-protocol.md](experimental-protocol.md), [scoring-rubrics.md](scoring-rubrics.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), ongoing pilot workflow

This runbook turns the reformulated T1 packet into an executable paired run without
using the current design chat as evidence.

## Non-negotiable control

The current chat already knows the historical fix, the first failed preflight, and the
junction-based reformulation of T1. It is therefore methodologically contaminated and
must not be counted as either the Harness transcript or the Freestyle transcript.

The actual paired run must be executed in two fresh chat sessions:

- one fresh session rooted only at the Harness worktree,
- one fresh session rooted only at the Freestyle worktree.

No transcript, artifact, or post hoc insight from one condition should be shown to the
other.

## Canonical worktrees

Use these two isolated repositories only:

- **Harness worktree:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h`
- **Freestyle worktree:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-f`
- **Required base revision for both:** `e078f36577e704fa2eec09bd520501a512cdf60b`

Each condition should be run in its own VS Code window so that the active chat sees
only one worktree.

For this stage, the recommended host is GitHub Copilot CLI (`copilot`), because it can
run an interactive agent session in a worktree-local directory and can load the custom
`inquiry` agent after repository initialization.

Before the fresh sessions begin, create one local branch per worktree so that each
condition has a stable local head and, for Harness, a stable cleanroom path.

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h"
git switch -c t1-pilot-h
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-f"
git switch -c t1-pilot-f
```

## Pre-run checks

Run these checks before starting either fresh session.

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h/code/cli"
git rev-parse HEAD
git status --short
dart pub get
dart run bin/main.dart version
```

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-f/code/cli"
git rev-parse HEAD
git status --short
dart pub get
dart run bin/main.dart version
```

```powershell
iq version
copilot --version
```

Expected control outcome:

- both worktrees report the same commit `e078f36577e704fa2eec09bd520501a512cdf60b`,
- both worktrees are clean before the run begins,
- the local CLI is invocable through `dart run bin/main.dart`,
- the installed harness runtime and Copilot CLI are available.

## Pair capture sheet

Before launching either condition, create one investigator-side capture sheet outside
both active worktrees:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry"
Copy-Item ".\\code\\paper\\paired-run-capture-template.md" ".\\code\\paper\\evidence\\t1-pair-capture.md"
```

Fill the header, the shared scored stop line, and the planned artifact paths before the
first fresh session starts. Keep this sheet outside both active chat windows so it does
not become cross-condition guidance.

## Condition-neutral baseline fact

The paired runs may use the following baseline fact from the approved T1 packet and no
more than that:

- on Windows, a repository entered through a junction path can yield a canonical root
  from `git rev-parse --show-toplevel` that differs from the entered path alias.

That fact is allowed baseline context because it is already frozen in
[task-packet-t1.md](task-packet-t1.md). The current design chat's extra reasoning about
that fact is not allowed carry-over.

## Shared scored stop line for T1

For the primary H/F comparison, T1 is scored at the following shared boundary:

- the change remains bounded to `code/cli/test/ape_prompt_test.dart`,
- the prompt expectations use the git-resolved root rather than the entered alias path,
- a Windows alternate-path or junction-path regression is present,
- `dart analyze` passes from `code/cli`,
- `dart test` passes from `code/cli`,
- and the final diff, final status, validation outputs, transcript, and session export
  paths are recorded in the pair capture sheet.

The following are **outside** the primary T1 comparison and must be recorded as
post-target extension work if they occur at all:

- version bumping,
- CHANGELOG edits,
- release preparation,
- PR creation or merge,
- issue closure,
- and harness END or EVOLUTION closure work that happens after the shared stop line.

## Harness condition: H

### Decision gate before launch

Do not treat `copilot --agent inquiry` as an immediate entry into the T1 debugging
task. The installed Inquiry scheduler starts in `IDLE`, and the declared FSM contract
requires `issue_selected_or_created` plus `feature_branch_selected` before
`start_analyze` can legally enter `ANALYZE`.

That means the current Harness implementation supports two distinct interpretations,
and they should not be conflated:

- **Full scheduler Harness.** Count the full Inquiry runtime as the treatment,
  including IDLE triage, issue selection or creation, and the explicit start handoff.
  This is the faithful implementation of the current scheduler, but it adds issue
  workflow overhead to H.
- **Phase-level Harness proxy.** Try to compare only the operator-bearing work phases
  without the issue-triage entry boundary. This may be attractive methodologically, but
  it is not what the current deployed `inquiry` scheduler does by default and should
  not be improvised mid-run.

For the current pilot, do not launch the custom agent until the investigator explicitly
chooses which interpretation is being measured.

### Setup

In the Harness worktree only, initialize the repository with the installed `iq`
runtime:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h"
iq init
```

Then deploy Inquiry to the Copilot host for the Harness run:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h"
iq host get
```

The historical base revision's source CLI can report its own version through
`dart run bin/main.dart`, but it cannot load bundled assets for `init` and `fsm state`
when run directly from source. For this stage, the Harness runtime therefore comes from
the installed `iq` binary rather than the historical source tree. Record that as a
deviation when scoring the pair.

Before starting the fresh Harness session, start a shell transcript so the run can be
scored later without manual reconstruction:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h"
New-Item -ItemType Directory -Force -Path .\pilot-records | Out-Null
Start-Transcript -Path .\pilot-records\t1-harness-transcript.txt -Force
```

### Fresh-session seed

If the study chooses the **Full scheduler Harness** interpretation, start a brand-new
interactive Copilot CLI session in the Harness worktree:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h"
copilot -C . --agent inquiry --name "t1-harness"
```

Then provide only this bounded brief:

```text
Run condition H for the approved T1 pilot packet.

Use Inquiry's explicit harness rather than freestyle work. Keep the run bounded to the
T1 packet and preserve durable artifacts required by the harness.

Task statement: Make the Windows ape prompt test expectations match the git-resolved
project root when the repository is accessed through an alternate path spelling such as
 a junction.

Starting revision: e078f36577e704fa2eec09bd520501a512cdf60b.

Allowed baseline context: this is a Windows-oriented bug-fix task in the ape prompt
 test surface; on Windows, a repository entered through a junction path can yield a
 canonical root from `git rev-parse --show-toplevel` that differs from the entered path
 alias.

Do not use any outputs from other conditions, historical fix commits, or prior chats.
 Preserve transcript, durable artifacts, focused validation output, and any run_trace
 evidence produced by the harness.

For paired scoring, stop at the shared T1 scored stop line once `dart analyze` and the
full `dart test` suite pass on the bounded test change. Do not continue into version
bump, CHANGELOG, release, PR, merge, or other repository-integration work as part of
the scored run. If the harness enters such work anyway, report it as post-target
extension rather than treating it as the primary task completion.
```

### Automated-observation fallback

In this Windows environment, the interactive Copilot CLI TUI was not reliably
capturable through terminal automation: alt-screen behavior and transcript capture did
not preserve the actual conversation content. When the run must be observed under
automation, prefer a non-interactive launch that writes a share artifact and leaves
session-state evidence:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h"
$brief = @'
Run condition H for the approved T1 pilot packet.

Use Inquiry's explicit harness rather than freestyle work. Keep the run bounded to the
T1 packet and preserve durable artifacts required by the harness.

Task statement: Make the Windows ape prompt test expectations match the git-resolved
project root when the repository is accessed through an alternate path spelling such as
a junction.

Starting revision: e078f36577e704fa2eec09bd520501a512cdf60b.

Allowed baseline context: this is a Windows-oriented bug-fix task in the ape prompt
test surface; on Windows, a repository entered through a junction path can yield a
canonical root from `git rev-parse --show-toplevel` that differs from the entered path
alias.

Do not use any outputs from other conditions, historical fix commits, or prior chats.
Preserve transcript, durable artifacts, focused validation output, and any run_trace
evidence produced by the harness.

For paired scoring, stop at the shared T1 scored stop line once `dart analyze` and the
full `dart test` suite pass on the bounded test change. Do not continue into version
bump, CHANGELOG, release, PR, merge, or other repository-integration work as part of
the scored run. If the harness enters such work anyway, report it as post-target
extension rather than treating it as the primary task completion.
'@
copilot -C . --agent inquiry --name "t1-harness" -p $brief --allow-all --share ".\pilot-records\t1-harness-share.md" --no-color
```

If that fallback is used, preserve both the requested share file and the Copilot CLI
process evidence under `~/.copilot/session-state/` and `~/.copilot/logs/`.

### Expected Harness records

Preserve at minimum:

- the fresh-session transcript,
- the Copilot CLI share file when the non-interactive fallback is used,
- the interactive Copilot CLI share export `pilot-records/t1-harness-share.md`, or a
  capture-sheet note that interactive export failed,
- the matching Copilot session-state and process-log evidence when the share file is
  missing or incomplete,
- any `cleanrooms/<branch>/` artifacts created during the run,
- `cleanrooms/<branch>/run_trace.yaml` if it is produced,
- focused validation output,
- final diff or patch,
- deviation notes.

Before closing an interactive Harness session, invoke `/share`, choose Markdown, write
the export to `pilot-records/t1-harness-share.md`, and verify that the file exists on
disk. If no file appears, keep the fallback session-state/log evidence and record the
export failure in the pair capture sheet.

### Observed full-scheduler pilot blockage

The first observed full-scheduler Harness launch for T1 on Windows produced a bounded
issue-selection result, then failed before task execution:

- it created GitHub issue #231 for the junction-path variant of T1,
- it emitted `EVENT: issue_selected_or_created`,
- the next explicit handoff attempt `iq ape transition --event issue_selected_or_created`
  failed with `Error: No APE is active in state IDLE [NO_ACTIVE_APE]`,
- `iq fsm state --json` still reported `state: IDLE`, `issue: null`, and `dewey`
  `RUNNING`.

Treat that run as pilot evidence about scheduler overhead and Harness fragility, not as
an ordinary unsuccessful T1 task attempt. The bounded task itself had not yet entered
ANALYZE.

When the Harness session finishes, stop the PowerShell transcript:

```powershell
Stop-Transcript
```

## Freestyle condition: F

### Setup

After condition H finishes, close the Harness chat and remove host-scoped Inquiry
deployment before the Freestyle run begins.

If the preceding full-scheduler Harness run created or edited a real GitHub issue for
T1, pause before launching F. That repository-level side effect is visible outside the
local worktree and may contaminate the Freestyle condition. In that case, either treat
the pilot as a protocol-refinement result and stop the pair, or explicitly decide how
F will be insulated from that issue-level carry-over before restarting from a clean
baseline.

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h"
iq host clean
```

In the Freestyle worktree only, do not initialize or deploy Inquiry for the run.

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-f/code/cli"
dart pub get
```

Before starting the fresh Freestyle session, start a separate shell transcript:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-f"
New-Item -ItemType Directory -Force -Path .\pilot-records | Out-Null
Start-Transcript -Path .\pilot-records\t1-freestyle-transcript.txt -Force
```

### Fresh-session seed

Start a brand-new interactive Copilot CLI session in the Freestyle worktree without a
custom Inquiry agent:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-f"
copilot -C . --name "t1-freestyle"
```

Then provide only this bounded brief:

```text
Run condition F for the approved T1 pilot packet.

Use the same host and model interface, but do not use Inquiry's explicit harness, FSM,
 named operators, or durable cleanroom artifacts.

Task statement: Make the Windows ape prompt test expectations match the git-resolved
project root when the repository is accessed through an alternate path spelling such as
 a junction.

Starting revision: e078f36577e704fa2eec09bd520501a512cdf60b.

Allowed baseline context: this is a Windows-oriented bug-fix task in the ape prompt
 test surface; on Windows, a repository entered through a junction path can yield a
 canonical root from `git rev-parse --show-toplevel` that differs from the entered path
 alias.

Do not use any outputs from other conditions, historical fix commits, or prior chats.
 Preserve transcript, focused validation output, final diff, and deviation notes.
```

For paired scoring, stop at the shared T1 scored stop line once the bounded test change
is in place and `dart analyze` plus the full `dart test` suite pass from `code/cli`.
Do not continue into version bump, changelog, PR, merge, or other repository
integration work as part of the scored run.

### Automated-observation fallback

If interactive Freestyle export is not reliable on this host, prefer a non-interactive
Copilot CLI launch that still stays host-native and emits a durable share artifact:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-f"
$brief = @'
Run condition F for the approved T1 pilot packet.

Use the same host and model interface, but do not use Inquiry's explicit harness, FSM,
named operators, or durable cleanroom artifacts.

Task statement: Make the Windows ape prompt test expectations match the git-resolved
project root when the repository is accessed through an alternate path spelling such as
a junction.

Starting revision: e078f36577e704fa2eec09bd520501a512cdf60b.

Allowed baseline context: this is a Windows-oriented bug-fix task in the ape prompt
test surface; on Windows, a repository entered through a junction path can yield a
canonical root from `git rev-parse --show-toplevel` that differs from the entered path
alias.

Do not use any outputs from other conditions, historical fix commits, or prior chats.
Preserve transcript, focused validation output, final diff, and deviation notes.

For paired scoring, stop at the shared T1 scored stop line once the bounded test change
is in place and `dart analyze` plus the full `dart test` suite pass from `code/cli`.
Do not continue into version bump, changelog, PR, merge, or other repository
integration work as part of the scored run.
'@
copilot -C . --name "t1-freestyle" -p $brief --allow-all --share ".\pilot-records\t1-freestyle-share.md" --no-color
```

### Expected Freestyle records

Preserve at minimum:

- the fresh-session transcript,
- the Copilot CLI share export `pilot-records/t1-freestyle-share.md`, or a
  capture-sheet note that interactive export failed,
- focused validation output,
- final diff or patch,
- overhead notes,
- deviation notes.

Before closing an interactive Freestyle session, invoke `/share`, choose Markdown,
write the export to `pilot-records/t1-freestyle-share.md`, and verify that the file
exists on disk. If no file appears, record the export failure in the pair capture sheet
and preserve the shell transcript plus any host-side fallback traces.

When the Freestyle session finishes, stop the PowerShell transcript:

```powershell
Stop-Transcript
```

## Post-run bundle

After both conditions complete, bundle the following for scoring:

- the paired-run capture sheet,
- H transcript,
- F transcript,
- H artifact set,
- F artifact set,
- focused validation outputs for both conditions,
- overhead notes for both conditions,
- a short deviation log stating whether any condition saw out-of-packet guidance.

## Immediate scoring consequence

Once the pair is complete, the next operation is not discussion prose. It is a first
coding pass against [scoring-rubrics.md](scoring-rubrics.md), with explicit notes about
C1 through C4 and any ambiguity the pilot exposes.
