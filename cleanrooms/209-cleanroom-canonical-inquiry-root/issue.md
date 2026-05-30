---
id: issue-209-reference
title: "Issue #209 Reference"
date: 2026-05-30
status: active
tags: [issue, reference, architecture, inquiry-root]
author: socrates
---

# Issue #209

## Metadata

- Number: 209
- Title: architecture: make cleanrooms/<slug> the canonical inquiry root with cycle-local state
- URL: https://github.com/ccisnedev/inquiry/issues/209

## Summary

This cycle focuses on making `cleanrooms/<slug>/` the canonical root of an inquiry while separating that cycle root from `project_root`.

The issue consolidates the main pressures already visible in:

- #150 — `mutations.md` belongs with the active cleanroom
- #178 — `iq` must stop depending on ambient cwd to resolve context
- worktree-first usage — ignored runtime files do not carry over across newly created worktrees

## Scope

The issue is about cycle-root architecture and active-cycle resolution.

It is not approval to migrate every adjacent runtime surface in a single step.