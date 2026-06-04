---
id: diagnosis
title: "Diagnosis"
date: 2026-06-04
status: active
tags: [diagnosis, evidence-first]
---

# Diagnosis

## Problem defined

- The active defect is bounded to the Windows ape prompt test surface. The
  runtime prompt contract already publishes `project_root` from
  `cycleContext.projectRoot`, and that value is resolved from
  `git rev-parse --show-toplevel`, not from the literal path spelling used to
  enter the repository.
- Existing ape prompt tests assert `project_root` and related
  `retrieval_context` entries against `p.normalize(gitTmpDir.path)`. That is
  equivalent only when the entered path spelling matches git's resolved root.
- Under a Windows alternate path spelling such as a junction, git can return a
  canonical root string that differs from the alias path, so expectations bound
  to the entered spelling become the brittle part of the contract.

## Decisions taken

- Treat the issue as a test-expectation mismatch, not as a confirmed prompt
  assembly bug, because the prompt assembly path already delegates authority to
  `CycleContext.resolve` and git root resolution.
- Keep the analysis bounded to ape prompt tests and their inquiry-context
  expectations. Adjacent Windows path-normalization history is relevant context
  but not part of the active change surface unless new evidence disproves the
  current diagnosis.
- Do not escalate questions to the user in this clarification pass because the
  bounded repository evidence closes the material uncertainty: the missing
  coverage is the alternate-path case, and the authoritative root source is
  already known.

## Constraints and risks identified

- `project_root` is contractually the git-resolved repository root; changing the
  runtime to preserve an entered alias would contradict the current resolution
  pipeline.
- Windows-specific alternate spellings (junctions, canonicalized drive/path
  forms) make literal-path assertions fragile when they are not derived from the
  same git resolution the product code uses.
- Existing tests already cover direct-root and nested-subdirectory entry, so the
  risk is narrowly focused on adding or updating alternate-path expectations
  without disturbing the broader prompt assembly contract.
- Validation should stay focused on the bounded ape prompt test surface and
  preserve transcript and run-trace behavior already exercised by the harness.

## Implications and consequences

- If the bounded diagnosis is correct, then every inquiry-context path derived
  from `cycleContext.projectRoot` must remain internally consistent with the
  git-resolved root string. A test that asserts only the caller-entered alias
  path would be checking a different contract from the one the runtime
  publishes.
- The consequence is not limited to a cosmetic string mismatch. Because
  `project_root` and branch-relative surfaces share the same root authority, a
  brittle alias-based expectation can make a correct Windows prompt assembly
  look broken while leaving the shipped behavior unchanged.
- If nothing changes, contributors who enter the repository through a junction
  or another alternate Windows spelling will continue to see false-negative ape
  prompt failures. That reduces trust in the bounded test surface and makes it
  harder to distinguish a real prompt-regression from a path-spelling artifact.
- If the test surface continues to encode the alias spelling as truth, it also
  creates cross-surface contract drift with `CycleContext` coverage, which
  already accepts git-canonicalized roots. The longer that drift remains, the
  more likely future changes are to preserve the wrong invariant under test.

## Scope

### In scope

- `code/cli/test/ape_prompt_test.dart` expectations for `project_root` and any
  related inquiry-context strings that currently derive from the entered temp
  repo path spelling.
- A Windows-targeted coverage path that invokes the repository through an
  alternate spelling such as a junction and compares against the git-resolved
  root.
- Evidence around `ApePromptCommand._resolveRuntimeContext`,
  `CycleContext.resolve`, and `getProjectRoot` insofar as they define the
  authoritative path source for the tests.

### Out of scope

- Reworking ape prompt runtime assembly unless new evidence shows it does not
  actually use the git-resolved root.
- Broad path-normalization changes outside the ape prompt test surface.
- Non-Windows aliasing semantics except where they matter for protecting a
  Windows-specific test contract.

## Stakeholder perspectives

- **Runtime contract owner:** The shipped prompt contract is internally
  consistent only if `project_root` continues to mean
  `cycleContext.projectRoot`; prompt assembly and cycle resolution already take
  git's top-level result as authoritative.
- **Ape prompt test and harness maintainer:** The active failure mode is a false
  negative caused by deriving expectations from the entered temp-path spelling
  instead of the same root source the runtime publishes. Preserving inquiry
  context shape, transcript behavior, and run-trace surfaces matters more than
  preserving an alias string that product code does not treat as canonical.
- **Windows contributor entering through a junction or alternate spelling:** The
  behavior that matters is stable repository anchoring across equivalent path
  spellings; a contract that changes with the alias used to enter the repo would
  make the Windows surface non-deterministic.
- **Adjacent repository maintainer:** `CycleContext` coverage already tolerates a
  git-resolved project root whose spelling differs from the entered directory,
  so bringing ape prompt expectations into alignment reduces cross-surface
  contract drift.

## Evidence

1. `ApePromptCommand._resolveRuntimeContext` writes `project_root` from
   `cycleContext.projectRoot` into inquiry-context.
   - Reference: `code/cli/lib/modules/ape/commands/prompt.dart:243-266`
2. `CycleContext.resolve` obtains `projectRoot` from `getProjectRoot`, which
   shells out to git rather than trusting the entered working directory string.
   - References:
     - `code/cli/lib/src/cycle_context.dart:68-90`
     - `code/cli/lib/src/git_utils.dart:42-55`
3. Current ape prompt tests hard-code `p.normalize(gitTmpDir.path)` in multiple
   `project_root` and `retrieval_context` assertions.
   - Reference:
     - `code/cli/test/ape_prompt_test.dart:885, 920, 1028, 1057, 1195, 1216, 1378, 1433, 1438`
4. Current coverage already includes nested-subdirectory invocation but no
   alternate-path-spelling case.
   - Reference:
     - `code/cli/test/ape_prompt_test.dart:1405-1443`
5. Targeted local runtime evidence on the active Windows host reproduces the
   junction-path mismatch: from a sibling junction alias, `git rev-parse
   --show-toplevel` returned the canonical repository root string rather than
   the alias path used to enter the repo.
   - Command:
     - PowerShell junction probe with `git rev-parse --show-toplevel`
   - Observed output:
     - alias:
       `C:\Users\44358590\Code\silicon-brained-machines\inquiry-pilot-t1-h-junction-evidence`
     - gitroot:
       `C:/Users/44358590/Code/silicon-brained-machines/inquiry-pilot-t1-h`
     - equality check: `False`
6. Targeted runtime evidence: the existing subdirectory-anchoring test passes,
   so the bounded gap is not general project-root resolution.
   - Command:
     - `dart test test\ape_prompt_test.dart --plain-name "task contract stays anchored to project root when invoked from a subdirectory"`
7. Adjacent `CycleContext` coverage already treats the git-resolved root as
   potentially canonicalized differently from the entered temp path spelling.
   - Reference:
     - `code/cli/test/cycle_context_test.dart:63-78`

## Hypotheses

- The most strongly supported explanation is that the failing Windows surface is
  a test-contract mismatch: the runtime already publishes the git-resolved root,
  but the bounded ape prompt assertions still treat the caller-entered alias
  path as the expected truth.
- A secondary working hypothesis is that a Windows junction or other alternate
  path spelling is sufficient to trigger the mismatch because `git rev-parse
  --show-toplevel` canonicalizes to the repository root string while the test
  fixture continues to compare against the alias path string.
- No current evidence supports a prompt assembly regression in
  `ApePromptCommand._resolveRuntimeContext`; that remains an unsupported
  hypothesis unless new runtime evidence contradicts the current bounded corpus.

## Open Questions

- None within the bounded clarification scope.

## References

- `cleanrooms\231-windows-ape-prompt-tests-should-use-git-resolved-p\issue.md`
- `cleanrooms\231-windows-ape-prompt-tests-should-use-git-resolved-p\analyze\confirmations.md`
- `code/cli/lib/modules/ape/commands/prompt.dart`
- `code/cli/lib/src/cycle_context.dart`
- `code/cli/lib/src/git_utils.dart`
- `code/cli/test/cycle_context_test.dart`
- `code/cli/test/ape_prompt_test.dart`
