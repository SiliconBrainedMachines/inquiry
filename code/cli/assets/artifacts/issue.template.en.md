---
kind: iq-issue
lang: en
title: "[repo] Short issue title"
repo: "{{REPO}}"
labels: []
spec: "{{SPEC}}"
covers: []
---

<!-- "Issue as code": this .md is the source of truth. Edit and review it here;
     `iq issue publish <slug> <name> --plan` shows the `gh issue create` it would
     assemble from the front-matter; `--apply` creates it. The body (everything
     after the second `---`) is what gets published; the front-matter is NOT.
     `covers:` must list the AC this issue covers, each qualified by its user
     story — `covers: [US1-AC1, US1-AC2, US2-AC3]`. The gate enforces it; a bare
     `AC-1` is ambiguous (every story restarts at 1) and traces nothing. -->

# [repo] Short issue title

## Context

<!-- What exists today and what is missing, with re-checkable handles (file:line). -->

## Scope

- <!-- What this issue builds -->

## Technical decisions (evidence)

- **Decision**: <!-- the decision -->. **Evidence**: <!-- re-checkable handle: a query, a command, `inline-code`, or file:line -->.

## Acceptance criteria covered

<!-- Echo here, for human reading, the AC listed in the front-matter `covers:`. The gate's traceability reads `covers:`, not this text. -->
