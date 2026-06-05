# T3 Pilot Runbook - Fresh Session Execution

> **Type:** method
> **Status:** draft
> **Depends on:** [task-packet-t3.md](task-packet-t3.md), [experimental-protocol.md](experimental-protocol.md), [scoring-rubrics.md](scoring-rubrics.md), [paired-run-capture-template.md](paired-run-capture-template.md)
> **Used by:** [first-paper-checklist.md](first-paper-checklist.md), ongoing pilot workflow

This runbook turns the approved T3 packet into an executable paired run while keeping
the T2 protocol refinements intact.

## Non-negotiable control

The current chat already knows the historical T3 refactor surface and the T1/T2 pilot
adjustments. It must not be counted as either the Harness transcript or the Freestyle
transcript.

The actual paired run should therefore be executed only through fresh Copilot CLI
sessions rooted at isolated T3 worktrees. As in T2, both conditions should use the
same non-interactive share-producing mode so that the retained record is durable and
condition-symmetric.

## Canonical worktrees

Use these two isolated repositories only:

- **Harness worktree:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-h`
- **Freestyle worktree:** `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-f`
- **Required base revision for both:** `07d369215a2c64c80426278369253cfd89f03ff8`

If the worktrees do not exist yet, create them from the main repository:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry"
git worktree add "../inquiry-pilot-t3-h" 07d369215a2c64c80426278369253cfd89f03ff8
git worktree add "../inquiry-pilot-t3-f" 07d369215a2c64c80426278369253cfd89f03ff8
```

Before the fresh sessions begin, create one local branch per worktree so each
condition has a stable local head:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-h"
git switch -c t3-pilot-h
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-f"
git switch -c t3-pilot-f
```

## Pre-run checks

Run these checks before starting either fresh session.

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-h/code/cli"
git rev-parse HEAD
git status --short
dart pub get
dart run bin/main.dart version
```

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-f/code/cli"
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

- both worktrees report the same commit `07d369215a2c64c80426278369253cfd89f03ff8`,
- both worktrees are clean before the run begins,
- the local CLI is invocable through `dart run bin/main.dart`,
- the installed Inquiry runtime and Copilot CLI are available.

## Pair capture sheet

Before launching either condition, create one investigator-side capture sheet outside
both active worktrees:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry"
Copy-Item ".\\code\\paper\\paired-run-capture-template.md" ".\\code\\paper\\evidence\\t3-pair-capture.md"
```

Fill the header, shared scored stop line, planned artifact paths, and timing fields
before the first fresh session starts.

## Shared scored stop line for T3

For the primary H/F comparison, T3 is scored at the first worktree state where:

- `.inquiry/state.yaml` uses `state` and `issue`,
- `init`, `fsm state`, and `fsm transition` align with that naming,
- the change remains bounded to the state-file rename and related CLI state-handling
  surfaces,
- and all of the following pass from `code/cli` in the same worktree state:
  - `dart test test/init_command_test.dart`
  - `dart test test/fsm_state_test.dart`
  - `dart test test/fsm_transition_test.dart`
  - `dart test test/fsm_transition_integration_test.dart`
  - `dart test`

The following are outside the primary T3 comparison and must be recorded as post-target
extension work if they occur at all:

- broader FSM or lifecycle redesign,
- config-schema cleanup beyond the bounded field rename,
- compatibility shims not required by the bounded refactor,
- version bumping, release preparation, PR work, merge, or issue closure,
- and docs cleanup not required by the scored change surface.

## Harness condition: H

### Repository setup

In the Harness worktree only, initialize the repository with the installed Inquiry
runtime:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-h"
iq init
```

Then prepare a pilot-records directory for local copies of the retained artifacts:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-h"
New-Item -ItemType Directory -Force -Path .\pilot-records | Out-Null
```

### Non-interactive launch

Run H through Copilot CLI in non-interactive mode with share export enabled:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-h"
$brief = @'
Run condition H for the approved T3 pilot packet.

Use Inquiry's explicit harness rather than freestyle work. Keep the run bounded to the
T3 packet and preserve durable artifacts required by the harness.

Task statement: Rename the state-tracking fields from phase to state and from task to
issue, and align the related CLI state-handling surfaces with that unified naming.

Starting revision: 07d369215a2c64c80426278369253cfd89f03ff8.

Allowed baseline context: this is a bounded structural refactor of state-file field
naming and related CLI state-handling surfaces.

Do not use any outputs from other conditions, historical fix commits, or prior chats.
Preserve transcript, durable artifacts, focused validation output, full validation
output, final diff/status snapshot, and any run_trace evidence produced by the harness.

For paired scoring, stop at the shared T3 scored stop line once all of the following
pass from code/cli in the same worktree state:
- dart test test/init_command_test.dart
- dart test test/fsm_state_test.dart
- dart test test/fsm_transition_test.dart
- dart test test/fsm_transition_integration_test.dart
- dart test

Do not continue into broader FSM or lifecycle redesign, compatibility shims, release,
PR, merge, docs cleanup, or issue hygiene as part of the scored run. If the harness
enters such work anyway, report it as post-target extension rather than treating it as
primary completion.
'@
copilot -C . --agent inquiry --name "t3-harness" --allow-all-tools --allow-all-paths --no-ask-user -p $brief --share ".\pilot-records\t3-harness-share.md"
```

## Freestyle condition: F

### Repository setup

Prepare the same local artifact directory in the Freestyle worktree:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-f"
New-Item -ItemType Directory -Force -Path .\pilot-records | Out-Null
```

### Non-interactive launch

Run F through the same host in non-interactive share mode, but without the Inquiry
agent:

```powershell
Set-Location "C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t3-f"
$brief = @'
Run condition F for the approved T3 pilot packet.

Use the same host and model interface, but do not use Inquiry's explicit harness, FSM,
named operators, or durable cleanroom artifacts.

Task statement: Rename the state-tracking fields from phase to state and from task to
issue, and align the related CLI state-handling surfaces with that unified naming.

Starting revision: 07d369215a2c64c80426278369253cfd89f03ff8.

Allowed baseline context: this is a bounded structural refactor of state-file field
naming and related CLI state-handling surfaces.

Do not use any outputs from other conditions, historical fix commits, or prior chats.
Preserve transcript, durable share export, focused validation output, full validation
output, final diff/status snapshot, and deviation notes.

For paired scoring, stop at the shared T3 scored stop line once all of the following
pass from code/cli in the same worktree state:
- dart test test/init_command_test.dart
- dart test test/fsm_state_test.dart
- dart test test/fsm_transition_test.dart
- dart test test/fsm_transition_integration_test.dart
- dart test

Do not continue into broader FSM or lifecycle redesign, compatibility shims, release,
PR, merge, docs cleanup, or unrelated state-handling redesign as part of the scored
run.
'@
copilot -C . --name "t3-freestyle" --allow-all-tools --allow-all-paths --no-ask-user -p $brief --share ".\pilot-records\t3-freestyle-share.md"
```

## Post-run artifact harvest

After each non-interactive session completes, copy the retained Copilot session-state
files into the matching `pilot-records` directory so that the scored record does not
depend on external cache retention.

Minimum local copies to retain per condition:

- transcript
- focused validation output
- full validation output
- final diff/status snapshot
- deviation notes or run-trace equivalent
- share export markdown

Use T2 naming as the template for the copied files:

- `t3-h-focused-validation.txt`, `t3-h-full-validation.txt`, `t3-h-status.txt`,
  `t3-h-run-trace.yaml`
- `t3-f-focused-validation.txt`, `t3-f-full-validation.txt`, `t3-f-status.txt`,
  `t3-f-deviation-notes.txt`

## Scoring note

The scored transcript for each condition is the exported share plus the copied durable
artifact set, not this preparation chat. The current chat may help launch or harvest
the run, but it must not be treated as the empirical record for either condition.