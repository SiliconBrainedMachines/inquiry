---
name: inquiry-start
description: 'Protocol for starting work on an existing GitHub issue. Verifies the issue and opens the cycle with a single command, which prepares the branch and cleanroom and transitions to ANALYZE.'
---

# inquiry-start - Operational Start Protocol

## Prompt Summary

Run iq doctor first and stop on any failed check.
Verify the issue already exists with gh issue view.
Open the implementation with iq implementation start --issue NNN --apply --autoapprove, which derives the NNN-slug branch, checks it out, scaffolds the cleanroom, and transitions to ANALYZE.
Confirm iq fsm state reports ANALYZE for that issue.

## When to Use

- When the scheduler APE is in IDLE/DONE
- After explicit start intent
- After TRIAGE has confirmed that the issue already exists
- Before transitioning from IDLE to ANALYZE

## Prerequisites

Run `iq doctor` and confirm all checks pass:

- ✓ inquiry version
- ✓ git
- ✓ gh
- ✓ gh auth
- ✓ gh copilot

If any check fails, follow the on-screen instructions to install the missing tool before proceeding.

## Steps

### Step 1: Verify Prerequisites

```bash
iq doctor
```

All checks must pass. Do not proceed if any check fails.

### Step 2: Verify Existing Issue

```bash
gh issue view <NNN> --json number,title,state
```

Confirm the issue already exists. You do NOT need to read the title to build a
branch name — `iq implementation start` derives it from the issue itself.

### Step 3: Open the Cycle

```bash
iq implementation start --issue <NNN> --apply --autoapprove
```

This single command owns every mechanical step of the bootstrap — there is no
`git checkout -b`, no `mkdir`, no hand-writing of scaffold files:

1. Initializes the Inquiry workspace if it is missing (no separate `iq init`).
2. Reads the issue title and derives the branch `<NNN>-<slug>` (issue number
   left-padded to three digits, e.g. `#37 → 037-fix-login-timeout`).
3. Creates and checks out that branch (or checks it out if it already exists).
4. Fires the `start_analyze` transition, whose effect scaffolds
   `cleanrooms/<NNN>-<slug>/analyze/` (index.md, confirmations.md, diagnosis.md)
   and the issue mirror.

The command reports the branch, the cleanroom path, and the new state. Do NOT
write `.inquiry` state directly — all state mutations go through `iq` commands.

**Why `--apply --autoapprove`.** This command writes into the user's own
repository — a branch and a cleanroom — so it will not act unless told which of
`--plan` (say what would happen, change nothing) and `--apply` (say it, take
approval, then do it) was meant. `--autoapprove` carries the approval, because
the scheduler has no terminal to be asked on; Inquiry gates at state completion,
not at every command. Run it with `--plan` alone first if you want to see the
branch name it derived before anything is created.

### Step 4: Verify

```bash
iq fsm state
```

Confirm the state is now ANALYZE with the correct issue number.

## Verification

After completing all steps, verify:

- [ ] The issue already exists and `gh issue view <NNN> --json number,title,state` succeeds
- [ ] `iq implementation start --issue <NNN> --apply --autoapprove` reported ANALYZE
- [ ] Branch exists: `git branch --show-current` returns `<NNN>-<slug>`
- [ ] Directory exists: `cleanrooms/<NNN>-<slug>/analyze/`
- [ ] State updated: `iq fsm state` shows ANALYZE with the issue number

## Notes

- This skill is executed by the scheduler APE, not by a human
- TRIAGE owns issue creation or confirmation through `issue-create`
- Mechanical bootstrap (slug, branch, cleanroom, transition) is owned by
  `iq implementation start` — the scheduler invokes it, it does not reproduce those steps
- If any step fails, the scheduler should report the error and remain in IDLE
