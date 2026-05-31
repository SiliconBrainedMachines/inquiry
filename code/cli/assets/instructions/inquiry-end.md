---
name: inquiry-end
description: 'Protocol for ending an APE cycle. Use when: all plan.md checkboxes are complete, ready to release. Guides: version bump, changelog, END gate, PR, and EVOLUTION transition.'
---

# inquiry-end — Cycle Completion Protocol

## Prompt Summary

Only run in EXECUTE after all plan checkboxes and tests are complete.
Run the END pre-PR inspection gate and stop on any blocking sensor failure.
Choose the version bump and update every version file.
Update CHANGELOG from the completed plan phases and commit the release changes.
Push the branch and create the pull request only after the gate is green.

## When to Use

- When the scheduler APE is in EXECUTE state
- After all plan.md checkboxes are checked `- [x]`
- After all tests pass
- Ready to release and create PR

## Prerequisites

- Phase must be EXECUTE
- All plan.md checkboxes must be complete
- All tests must pass
- Static analysis must pass with no errors

## Sensor Model

END is not just a final mechanical push. It is the pre-PR gate where the harness evaluates the minimum closure sensor stack:

- `pre_pr` — blocking release-discipline checks before push or PR creation
- `ci_required` — merge-authoritative remote checks that remain binding after PR creation
- `runtime` — blocking checks when repo, branch, CLI, or target state looks inconsistent
- `inferential_optional` — non-blocking review findings unless stronger evidence upgrades them

## Steps

### Step 1: Verify Phase

Confirm current phase is EXECUTE:

```bash
# Check state (if using .inquiry/state.yaml)
cat .inquiry/state.yaml
```

Expected: `phase: EXECUTE`

If not EXECUTE, abort with message:
> "Cannot end cycle: current phase is {phase}, expected EXECUTE"

### Step 2: Verify Plan Completion

Read `cleanrooms/{slug}/plan.md` and verify:
- All checkboxes `- [ ]` are now `- [x]`

```bash
# Count incomplete checkboxes
grep -c "\- \[ \]" cleanrooms/{slug}/plan.md
```

Expected: 0 incomplete checkboxes.

If incomplete checkboxes remain, list them and abort.

### Step 3: Determine Version Bump

If the project uses semantic versioning, ask user to confirm bump type:

| Type | When to Use |
|------|-------------|
| PATCH | Bug fixes only, no new features |
| MINOR | New features, backward compatible |
| MAJOR | Breaking changes |

Locate the project's version file (e.g. `package.json`, `pubspec.yaml`, `pyproject.toml`, `Cargo.toml`) and read the current version.

**Examples:**
- Current: 0.0.8, PATCH → 0.0.9
- Current: 0.0.9, MINOR → 0.1.0
- Current: 0.1.0, MAJOR → 1.0.0

### Step 4: Update Version Files

Update all project files that contain the version string. Common patterns:
- Package manifest (`package.json`, `pubspec.yaml`, `pyproject.toml`)
- Version constants in source code
- Lock files (if applicable)

### Step 5: Update CHANGELOG

Add entry at top of `CHANGELOG.md` (after header):

```markdown
## [X.Y.Z]
### Added
- {list new features from plan.md phases}
### Changed
- {list changes from plan.md phases}
### Fixed
- {list bug fixes from plan.md phases}
```

Derive content from plan.md phases. Only include sections that apply.

### Step 6: Commit Release

```bash
git add -A
git commit -m "vX.Y.Z: {summary from issue title}"
```

Commit message format: `vX.Y.Z: <issue-title-summary>`

**Examples:**
- `v0.0.9: fix version inconsistency + inquiry-end + TUI ape`
- `v0.1.0: add authentication module`

### Step 7: Transition to END

Update `.inquiry/state.yaml` (if using state tracking):

```yaml
phase: END
issue: {issue-number}
branch: {branch}
version: X.Y.Z
```

Announce state change:
> `[APE: END]`

### Step 8: Run END Pre-PR Inspection Gate

Before pushing or creating the PR, evaluate the minimum END sensor stack:

- `pre_pr`: version files updated, CHANGELOG updated, release commit present, no declared execution work left unfinished
- `runtime`: branch, issue, FSM state, and target tool state are coherent
- `ci_required`: required remote checks are identified even though they will run after PR creation
- `inferential_optional`: any review concerns are recorded, but they do not block by themselves

Record the local END gate result in `cleanrooms/{slug}/pre_pr_inspection.md`.
`iq fsm transition --event finish_execute` now seeds this report automatically from the END inspection template so the gate starts from a structured scaffold instead of a blank file.
The report must include a top-level verdict and the three formal inspection passes:

```md
verdict: APPROVED

## Pass 1 — Consistency
- PASS: asset parity source/build reviewed

## Pass 2 — Completeness
- PASS: changed behavior covered by tests

## Pass 3 — Traceability
- PASS: every code change maps to the approved issue/plan
```

Each pass must contain one or more `- PASS:`, `- FAIL:`, or `- WARN:` checks.
Every `FAIL` check must include a repo-relative `file:line` citation such as `code/cli/lib/modules/fsm/commands/transition.dart:355`.
Allowed verdicts for this gate are `APPROVED` and `BLOCKED`.
`APPROVED` is only valid when no pass contains a `FAIL` check.
`iq fsm transition --event pr_ready` refuses to create the PR when the report is missing, lacks the required pass structure, contains any `FAIL` without `file:line`, declares any non-`APPROVED` verdict, or claims `APPROVED` while still containing a `FAIL` check.

If any blocking `pre_pr` or `runtime` sensor fails, abort PR creation and return to the failing evidence.

### Step 9: Push Branch

```bash
git push -u origin {branch}
```

### Step 10: Create Pull Request

```bash
gh pr create \
  --title "vX.Y.Z: {issue-title}" \
  --body "Closes #{issue-number}

## Summary
{brief summary of changes from diagnosis.md}

## Checklist
- [ ] All tests pass
- [ ] CHANGELOG updated
- [ ] Version bumped
"
```

**Important:** PR creation happens only after the END gate is green.

- PR merge is an **external event** (happens later, possibly with CI checks)
- Do not wait for PR merge to leave END
- After PR creation, the scheduler transitions to the next state automatically.

## After PR Merge

When the PR is merged:
1. The APE cycle terminates
2. State returns to IDLE
3. DARWIN may run process evaluation (if enabled)

## Quick Reference

```
1. Verify EXECUTE phase
2. Verify plan completion (all checkboxes checked)
3. Determine semver bump (PATCH/MINOR/MAJOR)
4. Update version files (project-specific)
5. Update CHANGELOG.md
6. Commit: git add -A && git commit -m "vX.Y.Z: ..."
7. Transition to END
8. Run END pre-PR inspection gate
9. Push: git push -u origin {branch}
10. Create PR: gh pr create --title "vX.Y.Z: ..."
11. Scheduler transitions automatically after PR creation
```