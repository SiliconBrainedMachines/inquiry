---
id: objectives
title: "Objectives for issue #201 - repo-scoped deploy"
date: 2026-05-19
status: active
tags: [objectives, target, repo-scoped, copilot]
author: socrates
issue: [201]
---

# Objectives for issue #201 - repo-scoped deploy

## Purpose

This analysis starts from one architectural premise: Inquiry should behave like `git init`, not like a global takeover of the user's AI customization space. The objective of issue #201 is to redefine deployment so that Inquiry is activated explicitly per repository, while preserving a minimal and safe global surface only where it is genuinely justified.

## Primary objectives

1. **Move the Inquiry scheduler agent to the repository scope.**
   `iq init` should create or update a repo-local agent artifact under `.github/agents/` instead of deploying `inquiry.agent.md` into `~/.copilot/agents/`.

2. **Stop treating `~/.copilot/` as Inquiry-owned territory.**
   `iq target get`, `iq target clean`, and `iq uninstall` must no longer delete shared user directories such as `~/.copilot/agents/` or `~/.copilot/skills/`.

3. **Separate runtime-bound Inquiry capabilities from globally reusable capabilities.**
   Inquiry-specific protocols that require `.inquiry/`, cleanrooms, or FSM state must stop living as permanent global skills. Only genuinely portable capabilities should remain candidates for any user-level installation.

4. **Define the correct repository-scoped delivery surface for private Inquiry protocols.**
   The analysis must determine whether the right repo-local form is `.github/prompts/`, another Copilot-native customization surface, or a hybrid model that keeps private protocols local without losing usability.

5. **Make `iq init` the single explicit activation step for a repository.**
   After the change, a repository that has never run `iq init` should not expose `@inquiry`, Inquiry prompt files, or Inquiry-specific behavior by default.

6. **Align the extension and CLI around the new contract.**
   The VS Code extension, installer, doctor checks, and target commands must all reflect the same deployment model so that there is no hidden post-install global mutation.

## Success criteria

The issue should be considered correctly scoped when the analysis can support these outcomes:

- A fresh machine install of Inquiry does not pollute or erase existing user-level VS Code Agents customizations.
- Running `iq init` in one repository does not make Inquiry appear in unrelated repositories.
- Inquiry-owned files can be added, updated, and removed surgically without recursive deletion of shared directories.
- The deploy model is legible enough to explain in one sentence: "Inquiry is activated per repository, not globally."
- The design remains compatible with the planned distinction between private Inquiry protocols and reusable public capabilities.

## Constraints and non-goals

- This issue is about the deploy model, not about reactivating multi-target support.
- This issue does not need to deliver the full `iq skill` module yet; it only needs a sound boundary that makes that future module coherent.
- This issue should preserve the current `.inquiry/` runtime state model unless analysis proves a direct dependency on changing it.
- This issue should not assume that every Copilot customization surface is interchangeable; the analysis must respect actual VS Code/Copilot discovery rules.

## Questions the analysis must answer

1. Which Inquiry artifacts belong in `.github/agents/`, which belong in `.github/prompts/`, and which, if any, still belong in `~/.copilot/skills/`?
2. Should `iq target get` remain as a meaningful command after this change, and if so, what exact responsibility remains?
3. How should `iq target clean` and `iq uninstall` identify Inquiry-owned files without deleting unrelated user customizations?
4. What is the migration path for users who already have Inquiry assets in user-level target directories?
5. How should `iq doctor` verify readiness once the agent becomes repo-scoped rather than user-scoped?

## Initial framing

The main outcome of this document is not implementation detail but objective clarity. The implementation should only proceed after analysis can prove that the new model is safer, more legible, and more aligned with the methodology-as-code philosophy than the current global deployment approach.
