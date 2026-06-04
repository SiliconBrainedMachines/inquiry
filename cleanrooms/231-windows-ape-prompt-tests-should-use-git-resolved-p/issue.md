---
id: issue
issue: "231"
branch: 231-windows-ape-prompt-tests-should-use-git-resolved-p
date: 2026-06-04
---

# Issue #231

## Problem

On Windows, the ape prompt test surface assumes the repository root path matches the spelling used to enter the repository in the test.

When the repository is accessed through an alternate path spelling such as a junction, `git rev-parse --show-toplevel` can resolve a different canonical root string. The current ape prompt expectations then fail even though the prompt is anchored to the git-resolved root.

## Scope

This issue is limited to the Windows ape prompt test surface and the `project_root` expectations used in that bounded contract.

## Desired behavior

Windows ape prompt expectations should match the project root string resolved by git for the active repository, even when the repository was entered through a junction or another alternate path spelling.

## Acceptance criteria

- A Windows-targeted ape prompt test covers entering the repository through an alternate path spelling such as a junction.
- The relevant ape prompt expectations assert the git-resolved project root instead of the entered alias path.
- The bounded T1 ape prompt test surface passes under that scenario.

## Related

- Adjacent to #178, but scoped to alternate Windows path spellings rather than nested-directory cwd drift.
