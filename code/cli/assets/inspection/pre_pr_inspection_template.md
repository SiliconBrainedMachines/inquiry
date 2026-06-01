verdict: BLOCKED

# END Pre-PR Inspection

issue: "{{ISSUE}}"
branch: "{{BRANCH}}"
generated_at: "{{GENERATED_AT}}"

## Pass 1 — Consistency
- WARN: consistency findings are auto-generated from source/build parity when END is entered and refreshed again at pr_ready

## Pass 2 — Completeness
- WARN: completeness findings include automatic plan.md checkbox review when END is entered and refreshed again at pr_ready; replace or complement this with concrete coverage findings before approval

## Pass 3 — Traceability
- WARN: traceability findings include automatic issue/branch metadata review when END is entered and refreshed again at pr_ready; replace or complement this with concrete issue/plan mapping findings before approval

## Citation Guidance

- Every FAIL must include a repo-relative file:line citation, for example `code/cli/lib/modules/fsm/commands/transition.dart:355`
- WARN findings should cite file:line when they are grounded in a concrete file-backed observation