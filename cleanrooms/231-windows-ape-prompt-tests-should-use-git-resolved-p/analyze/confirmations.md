---
id: confirmations
title: "Confirmations"
date: 2026-06-04
status: active
tags: [confirmations, findings]
---

# Confirmations

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: Ape prompt runtime context uses the git-resolved project root — CONFIRMED

- `ApePromptCommand._resolveRuntimeContext` writes `project_root` from
  `cycleContext.projectRoot`, so prompt assembly inherits whatever root git
  resolution produced rather than the caller-entered path alias.
- Evidence:
  - `code/cli/lib/modules/ape/commands/prompt.dart:243-266`

## F2: CycleContext derives project_root from `git rev-parse --show-toplevel` — CONFIRMED

- `CycleContext.resolve` calls `getProjectRoot(workingDirectory)`.
- `getProjectRoot` shells out to `git rev-parse --show-toplevel` and normalizes
  the returned path, making the git-reported repository root authoritative.
- Evidence:
  - `code/cli/lib/src/cycle_context.dart:68-90`
  - `code/cli/lib/src/git_utils.dart:42-55`

## F3: Existing ape prompt expectations are tied to the temp repo path spelling — CONFIRMED

- The current prompt tests interpolate `p.normalize(gitTmpDir.path)` directly in
  `project_root` and related `retrieval_context` assertions.
- Those expectations are stable for direct-root and nested-subdirectory entry,
  but they do not encode the possibility that git may canonicalize an alternate
  Windows path spelling differently.
- Evidence:
  - `code/cli/test/ape_prompt_test.dart:885, 920, 1028, 1057, 1195, 1216, 1378, 1433, 1438`

## F4: The bounded coverage gap is alternate Windows path spelling, not subdirectory anchoring — CONFIRMED

- Existing coverage already proves prompt anchoring when invoked from a nested
  subdirectory.
- No junction- or alternate-path-specific coverage was found in the ape prompt
  tests during bounded search.
- A targeted run of `dart test test\ape_prompt_test.dart --plain-name "task contract stays anchored to project root when invoked from a subdirectory"`
  passed, confirming the current non-junction scenario is green.
- Evidence:
  - `code/cli/test/ape_prompt_test.dart:1405-1443`
  - targeted local test run on 2026-06-04

## F5: Adjacent repository tests already tolerate canonicalized git roots — CONFIRMED

- `CycleContext` coverage does not require the resolved project root to equal the
  entered temp-directory spelling; it explicitly notes that git may surface a
  symlink-resolved root and only asserts existence plus derived paths.
- This pressure-tests the live assumption behind issue #231: treating the
  git-reported root as authoritative is already an accepted repository contract,
  so the brittle element remains the ape prompt test expectation.
- Evidence:
  - `code/cli/test/cycle_context_test.dart:63-78`

## F6: A live Windows junction probe reproduces the alias-versus-git-root mismatch — CONFIRMED

- From a sibling junction alias to the current repository, `git rev-parse
  --show-toplevel` returned the canonical repository root string rather than the
  alias path used to enter the repo.
- The probe output showed:
  - alias:
    `C:\Users\44358590\Code\silicon-brained-machines\inquiry-pilot-t1-h-junction-evidence`
  - gitroot:
    `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h`
  - equality check: `False`
- This confirms the issue premise on the active Windows host without widening
  beyond the bounded prompt-test contract.
- Evidence:
  - targeted local PowerShell junction probe on 2026-06-04
