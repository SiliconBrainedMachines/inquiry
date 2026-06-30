---
id: plan
title: "Plan"
date: {{DATE}}
status: active
tags: [plan]
---

# Plan

<!--
  Designed from diagnosis.md. RULES:
  - Every phase MUST carry an executable verification check — a real test-runner
    command or a test-file reference, not pseudocode. The plan_executable_checks
    gate rejects phases without one. Add a final phase that runs the FULL suite.
  - Trace to the specification: each phase SHOULD cite the AC-id(s) from
    specification.md it satisfies (omit only if the issue has no specification),
    and its Verify check is the test that proves that AC (test-first / TDD).
-->

## Phase 1
- **Change**: Describe the smallest first slice of the fix here.
- **Covers**: AC-N from specification.md this phase satisfies (omit if the issue has no specification).
- **Verify**: Replace with a real executable verification check (a test-runner command or a test-file reference) that proves the AC above.

## Final verification
- **Verify**: Replace with the command that runs the full project test suite.
