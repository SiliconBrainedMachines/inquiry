---
id: diagnosis
title: "Diagnosis: repo-scoped deploy for issue #201"
date: 2026-05-19
status: active
tags: [diagnosis, target, repo-scoped, copilot, risks]
author: socrates
issue: [201]
---

# Diagnosis: repo-scoped deploy for issue #201

## Executive Summary

Issue #201 is not merely a cleanup bug. It is a **deployment-contract mismatch** between Inquiry and the environment it targets.

Inquiry's runtime model is repository-bound: `.inquiry/`, `cleanrooms/`, `diagnosis.md`, and `plan.md` all live inside the current project. But its current Copilot integration is user-global: `CopilotAdapter` points to `~/.copilot/agents/` and `~/.copilot/skills/`, the deployer wipes those directories recursively, and install/init flows trigger that behavior automatically. See `code/cli/lib/targets/copilot_adapter.dart:10-18`, `code/cli/lib/targets/deployer.dart:20-38`, `code/cli/scripts/install.ps1:90-93`, `code/site/install.sh:113-116`, and `code/vscode/src/init.ts:42-54`.

The precise problem is therefore:

> **Inquiry activates globally what only makes sense locally, and it does so by resetting shared directories that it does not actually own.**

That mismatch creates four concrete pathologies:

1. destructive removal of unrelated user customizations,
2. namespace contamination by private Inquiry protocols,
3. global leakage of `@inquiry` into repositories that never opted in,
4. operational coupling across installer, extension, doctor, target-clean, and uninstall.

## 1. Deweyan Problematic Situation

Under a Deweyan reading, the problematic situation is not a single faulty command but a system of tensions that no longer cohere:

### T1. Runtime locality vs deployment globality

- Runtime state is created in the repo by `iq init` (`.inquiry/`, `cleanrooms/`). See `code/cli/lib/modules/global/commands/init.dart:66-88`.
- Agent and skills are deployed globally to `~/.copilot/`. See `code/cli/lib/targets/copilot_adapter.dart:10-18` and `docs/architecture.md:169-189`.

**Tension:** the state that gives Inquiry meaning is local, but the interface that exposes Inquiry is global.

### T2. Shared namespace vs assumed ownership

- The deployer deletes entire `agents/` and `skills/` directories before redeploy. See `code/cli/lib/targets/deployer.dart:23-38` and `code/cli/lib/targets/deployer.dart:67-69`.
- Copilot customizations are a shared user namespace, not an Inquiry-private install root. This is exactly the space where user-level custom agents and skills live. See `cleanrooms/145-extract-inquiry-core/analyze/copilot-target.md:42-67`.

**Tension:** Inquiry uses an idempotent reset strategy appropriate for a private install root on directories that function as a shared customization namespace.

### T3. Private protocols vs public availability

- Inquiry's own research distinguishes private runtime-bound skills from reusable capabilities. See `docs/research/legion.md:49-58`.
- But the current deploy bundle still pushes both classes into the same global skill surface. See `docs/architecture.md:175-186` and `code/cli/lib/targets/deployer.dart:40-49`.

**Tension:** the architecture says some protocols should not be globally registered, while the deploy implementation registers them globally anyway.

### T4. Explicit repository opt-in vs hidden activation

- The extension's `Inquiry: Init` runs `iq init` and immediately follows with `iq target get`. See `code/vscode/src/init.ts:42-46`.
- Both installers also run `target get` automatically. See `code/cli/scripts/install.ps1:90-93` and `code/site/install.sh:113-116`.

**Tension:** the user experience implies local initialization, but the implementation performs global activation as a side effect.

## 2. Socratic Confirmations

The following questions can now be answered with direct evidence:

### Q1. Does Inquiry currently deploy per repository?

**No.**

`iq init` creates local runtime files only and explicitly defers deploy to `iq target get`. See `code/cli/lib/modules/global/commands/init.dart:66-90`. `iq target get` then writes to the user-level paths defined by `CopilotAdapter`. See `code/cli/lib/modules/target/commands/get.dart:49-51` and `code/cli/lib/targets/copilot_adapter.dart:10-18`.

### Q2. Is the clean operation surgical?

**No.**

The deployer deletes the entire skills and agent directories recursively before redeploying. See `code/cli/lib/targets/deployer.dart:32-38` and `code/cli/lib/targets/deployer.dart:67-69`.

### Q3. Are private Inquiry protocols already known to be a namespace problem?

**Yes.**

`docs/research/legion.md` states directly that registering private skills in the target contaminates the namespace because those capabilities do not work outside an active Inquiry runtime. See `docs/research/legion.md:54-58`.

### Q4. Does the current system assume global deployment as part of readiness?

**Yes.**

`iq doctor` verifies `.inquiry/` locally but separately expects `inquiry.agent.md` and every bundled skill in the global target directories, and it tells the user to run `inquiry target get` when they are absent. See `code/cli/lib/modules/global/commands/doctor.dart:135-158`, `code/cli/lib/modules/global/commands/doctor.dart:272-284`, and `code/cli/lib/modules/global/commands/doctor.dart:343-370`.

### Q5. Does Copilot offer repo-scoped surfaces that Inquiry could use instead?

**Yes, partially.**

Copilot supports repo-scoped custom agents in `.github/agents/` and repo-scoped prompt files in `.github/prompts/`, while `SKILL.md` remains a user-level surface. See `cleanrooms/145-extract-inquiry-core/analyze/copilot-target.md:42-71`.

## 3. Precise Diagnosis

### D1. The root problem is an ownership-model mismatch

Inquiry currently behaves as if `~/.copilot/agents/` and `~/.copilot/skills/` were Inquiry-owned install directories. They are not. They are the user's shared customization space for Copilot and VS Code Agents.

This mismatch is encoded concretely in:

- `CopilotAdapter` path definitions (`code/cli/lib/targets/copilot_adapter.dart:10-18`)
- destructive deployer semantics (`code/cli/lib/targets/deployer.dart:20-38`, `67-69`)
- install and extension flows that auto-trigger deploy (`code/cli/scripts/install.ps1:90-93`, `code/site/install.sh:113-116`, `code/vscode/src/init.ts:42-46`)

### D2. The current deployment boundary is on the wrong side of the architecture

Inquiry's real activation boundary is the repository, because that is where:

- state lives,
- cleanroom artifacts live,
- the active cycle lives,
- the methodology is applied.

But the current deploy model places the activation boundary at the user account level instead. This is backwards for a system whose semantics are per-repository and per-cycle.

### D3. Private Inquiry protocols are being delivered in the wrong medium

The project already distinguishes private runtime-bound skills from reusable standalone skills. See `docs/research/legion.md:49-58`. Yet the deployer writes every bundled `SKILL.md` into the same global target namespace. See `code/cli/lib/targets/deployer.dart:40-49`.

The diagnosis is therefore not “skills are bad” but:

> **Private Inquiry protocols are currently packaged as permanent target-level capabilities, even though their meaning depends on repo-local runtime state.**

This is exactly why issue #185 exists in the roadmap. See `docs/roadmap.md:49-50`.

### D4. The current global model is deeply coupled across surfaces

The problem is not isolated to one command. It is coordinated across:

- CLI deploy (`iq target get`)
- CLI clean (`iq target clean`)
- uninstall (`iq uninstall`)
- doctor (`iq doctor`)
- install scripts
- VS Code extension init flow
- architecture docs

That means issue #201 is a contract correction, not a one-file bug fix.

## 4. Risk Inventory

| Risk | Severity | Description | Evidence |
|---|---|---|---|
| R1. Unrelated customization loss | Critical | Running deploy/clean/uninstall can remove the user's own custom agents and skills because the whole directories are deleted. | `code/cli/lib/targets/deployer.dart:32-38,67-69`; `code/cli/lib/modules/global/commands/uninstall.dart:65-74` |
| R2. Namespace contamination | High | Runtime-bound Inquiry protocols are globally registered in the same namespace as user skills. | `code/cli/lib/targets/deployer.dart:40-49`; `docs/architecture.md:175-186`; `docs/research/legion.md:54-58` |
| R3. Global agent leakage | High | `@inquiry` can appear outside repos that explicitly initialized Inquiry because deploy is user-level. | `code/cli/lib/targets/copilot_adapter.dart:10-18`; `code/vscode/src/init.ts:42-54` |
| R4. Hidden global mutation | High | Installer and extension perform global deployment as a side effect of install/init. | `code/cli/scripts/install.ps1:90-93`; `code/site/install.sh:113-116`; `code/vscode/src/init.ts:42-46` |
| R5. Cross-target collateral cleanup | Medium | Cleanup still spans all historical adapters even though deploy is Copilot-only. | `code/cli/lib/targets/all_adapters.dart:8-20`; `code/cli/lib/modules/target/commands/clean.dart:48-50`; `docs/spec/target-specific-agents.md:86-105` |
| R6. Readiness-model migration complexity | Medium | `doctor` currently encodes the old global contract and must be redefined alongside deploy. | `code/cli/lib/modules/global/commands/doctor.dart:135-158,272-284,343-370` |

## 5. Confirmed Boundaries

### B1. This is not primarily a multi-target issue

Multi-target history explains why cleanup still spans multiple adapters, but the core failure already exists in the single-target Copilot-only model. See `docs/spec/target-specific-agents.md:59-76` and `86-105`.

### B2. This is not primarily a `.inquiry/` state-model issue

The local runtime layout created by `iq init` is not the problem. The problem begins where deployment crosses from repository state into shared user target directories. See `code/cli/lib/modules/global/commands/init.dart:66-90`.

### B3. This is not a generic “use repo files everywhere” shortcut

Copilot supports repo-scoped custom agents and prompt files, but not the same repo-scoped `SKILL.md` surface described for user-level skills. See `cleanrooms/145-extract-inquiry-core/analyze/copilot-target.md:42-71`. Planning must therefore decide the correct delivery surface for private Inquiry protocols rather than assuming all existing assets can simply be moved unchanged.

## 6. Final Diagnostic Statement

The fully defined problem is:

> Inquiry currently exposes a repository-bound methodology through a user-global deploy model that assumes ownership of shared Copilot target directories, bundles private and public capabilities together, and triggers deployment automatically from installer and extension flows. This violates least surprise, risks destroying unrelated customizations, and makes Inquiry appear outside repositories that have not explicitly opted in.

That statement is now supported by direct code evidence, repository documentation, and prior architectural research. The problem is sufficiently defined to move from broad concern to concrete planning.
