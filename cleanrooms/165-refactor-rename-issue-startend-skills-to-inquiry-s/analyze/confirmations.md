# Confirmations

## Confirmed From User

- The nomenclature change must be complete toward inquiry for this phase, not just a partial public-facing rename.
- `issue-create` remains as-is; it is not part of the rename.
- The quoting problem is out of scope for issue #165 and should be handled in a separate issue.
- Scope is limited to live repository code: active file names, variables, folders, help text, comments, and live system names.
- Historical artifacts are out of scope.
- There is no external consumer depending on the literal names `issue-start` or `issue-end`.
- Success criterion: no old name should remain exposed in the live system.
- Internal live-code surfaces are in scope even if end users never see them; developers and maintainers do.
- The rigor bar has no exception for strictly internal surviving old names.

## Clarification Status

- Clarification is materially complete.

## Open Assumptions

- The semantic distinction that justifies keeping `issue-create` unchanged while fully renaming `issue-start` and `issue-end`.
- The belief that no non-obvious live dependency on the old names survives inside current runtime/module boundaries.
- The belief that there are no practical exceptions to the rule that no old name may remain exposed anywhere in live code.
id: confirmations
title: "Confirmations"
date: 2026-05-30
status: active
tags: [confirmations, findings]
---

# Confirmations

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED
