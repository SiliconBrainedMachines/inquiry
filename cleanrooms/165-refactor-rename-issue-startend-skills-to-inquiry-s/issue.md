---
id: issue
issue: "165"
branch: 165-refactor-rename-issue-startend-skills-to-inquiry-s
date: 2026-05-30
---

# Issue #165

## Problem

Two related issues with the current skill set:

1. **issue-start / issue-end naming**: These skills should be renamed to inquiry-start / inquiry-end to align with the Inquiry brand and avoid confusion with GitHub issues as a concept.

2. **Missing skill for issue creation**: The agent frequently fails when creating GitHub issues via gh issue create because of shell quoting problems (especially on PowerShell). A dedicated skill should instruct the agent to use a temp file for the body instead of inline quotes.

## Acceptance Criteria

- [ ] Rename issue-start skill to inquiry-start
- [ ] Rename issue-end skill to inquiry-end
- [ ] Update all references in CLI code, assets, and deployed targets
- [ ] Create new skill (e.g. github-issue-create) documenting the temp-file pattern for gh issue create --body-file
- [ ] Tests pass
