# Diagnosis

## Problem Defined

Issue #165 is a nomenclature refactor, not a behavior change. The problem is to eliminate the live-code names `issue-start` and `issue-end` in favor of `inquiry-start` and `inquiry-end` everywhere they remain exposed in the current repository, including internal maintainership-facing surfaces. The analysis established that success is not a partial public rename; it is the absence of the old names across live code.

## Decisions Taken

1. The rename scope is exhaustive across live code for `issue-start` and `issue-end`.
   - Justification: the confirmed success criterion is that no old name survives anywhere exposed in the live system, including internal surfaces.
2. `issue-create` remains unchanged.
   - Justification: live-code evidence shows it is semantically distinct from the start/end protocols. It performs deterministic issue selection or creation in IDLE/TRIAGE and does not collapse into the start/end runtime contract.
3. Historical artifacts are out of scope.
   - Justification: the issue is bounded to active repository surfaces rather than retrospective consistency across archived or historical materials.
4. No further meta-level objection blocks closing ANALYZE.
   - Justification: clarification is materially complete, the user-confirmed boundaries are stable, and no contradictory evidence was found in the analysis corpus.

## Constraints And Risks

- User-confirmed scope governs the analysis: only live repository code counts.
- Internal surfaces remain in scope even where end users never see them.
- The main risk is false closure from a non-obvious live dependency or internal surface that still exposes the old names.
- The main semantic risk is accidental overreach into `issue-create`, whose meaning is distinct and therefore excluded from the rename.
- The quoting problem is a separate concern and must not be folded into issue #165.

## Scope

In scope: active file names, variables, folders, help text, comments, tests, prompts, instructions, and other live system names that expose `issue-start` or `issue-end`.

Out of scope: historical artifacts, unrelated quoting behavior, and any rename of `issue-create`.

## References

- [confirmations.md](./confirmations.md)
- [evidence.md](./evidence.md)
- [index.md](./index.md)