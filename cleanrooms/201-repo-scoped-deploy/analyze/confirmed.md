---
id: confirmed
title: "Confirmed findings for issue #201 - repo-scoped deploy"
date: 2026-05-19
status: active
tags: [findings, confirmed, target, repo-scoped, copilot]
author: socrates
issue: [201]
---

# Confirmed findings for issue #201 - repo-scoped deploy

## Context

The objective of issue #201 is to determine whether Inquiry's deployment model is incorrectly global for a runtime that is otherwise repository-bound, and to establish the exact shape of the problem before planning any implementation.

## Confirmed findings

### F1. The current Copilot target is user-scoped, not repo-scoped

**Claim:** Inquiry currently treats GitHub Copilot deployment as a user-level installation rooted in `~/.copilot/`, not as a repository customization.

**Evidence:**

- `CopilotAdapter.baseDirectory()` resolves to `~/.copilot`, while `skillsDirectory()` and `agentDirectory()` resolve to `~/.copilot/skills` and `~/.copilot/agents` respectively. See `code/cli/lib/targets/copilot_adapter.dart:10-18`.
- `iq init` does not deploy any agent artifact itself; it explicitly leaves deployment to `iq target get`. See `code/cli/lib/modules/global/commands/init.dart:66-90`.
- The architecture document states that `iq target get` cleans `~/.copilot/{agents,skills}` and then copies `inquiry.agent.md` plus all skills into those directories. See `docs/architecture.md:169-189`.

**Confirmation:** Inquiry activation is currently modeled as a user-level target deployment layered on top of a repo-local `.inquiry/` runtime.

### F2. `iq target get` performs a destructive clean before every deploy

**Claim:** The deployer achieves idempotence by deleting the target directories recursively before rewriting assets.

**Evidence:**

- `TargetDeployer.deploy()` calls `clean()` before copying any skills or agents. See `code/cli/lib/targets/deployer.dart:20-29`.
- `TargetDeployer.clean()` deletes `adapter.skillsDirectory(homeDir)` and `adapter.agentDirectory(homeDir)` for every adapter. See `code/cli/lib/targets/deployer.dart:32-38`.
- `_deleteDirectory()` performs `dir.deleteSync(recursive: true)`, which removes the entire directory tree rather than only Inquiry-owned files. See `code/cli/lib/targets/deployer.dart:67-69`.

**Confirmation:** Inquiry does not currently perform surgical removal. It resets the whole target directories.

### F3. Deployment includes all bundled skills, without separating runtime-bound and reusable capabilities

**Claim:** Inquiry copies every bundled skill in `assets/skills/` into the shared target namespace.

**Evidence:**

- `_deploySkills()` enumerates every skill name from `assets.listDirectory('skills')` and writes each one to `<target>/skills/<name>/SKILL.md`. See `code/cli/lib/targets/deployer.dart:40-49`.
- The architecture document shows that the deployed set includes both runtime-bound protocols (`issue-create`, `issue-start`, `issue-end`, `doc-read`, `doc-write`, `inquiry-install`) and reusable capabilities (`legion`, `research`, `kritik`) in the same deploy surface. See `docs/architecture.md:175-186`.
- The repository's own LEGION research states that private Inquiry skills such as `doc-read`, `issue-create`, `issue-start`, and `issue-end` only make sense when the Inquiry runtime is active, and that registering them in the target contaminates the agent namespace. See `docs/research/legion.md:51-58`.

**Confirmation:** The current deploy model does not distinguish private Inquiry protocols from globally reusable capabilities.

### F4. Global deployment is triggered automatically by both installers and the VS Code extension

**Claim:** The current user experience reaches `iq target get` automatically rather than through an explicit, narrowly-scoped deploy step.

**Evidence:**

- The Windows installer documents and executes `inquiry target get` as part of installation. See `code/cli/scripts/install.ps1:6-13` and `code/cli/scripts/install.ps1:90-93`.
- The Linux installer does the same. See `code/site/install.sh:7-14` and `code/site/install.sh:113-116`.
- The VS Code extension command `Inquiry: Init` sends both `iq init` and `iq target get` into a terminal, then prompts for window reload so Copilot can detect `@inquiry`. See `code/vscode/src/init.ts:42-54`.

**Confirmation:** Inquiry's current install/init path mutates global Copilot target directories as a default behavior.

### F5. Cleanup and uninstall are broader than the active Copilot-only deploy surface

**Claim:** The cleanup model still spans all known adapters, not only the currently active Copilot deploy path.

**Evidence:**

- `allAdapters` includes `CopilotAdapter`, `ClaudeAdapter`, `CodexAdapter`, `CrushAdapter`, and `GeminiAdapter`, while `deployAdapters` includes only `CopilotAdapter`. See `code/cli/lib/targets/all_adapters.dart:8-20`.
- `TargetCleanCommand` simply calls `deployer.clean()` and reports that Inquiry was cleaned from all targets. See `code/cli/lib/modules/target/commands/clean.dart:36-50`.
- `UninstallCommand.execute()` also calls `deployer.clean()` as its first step, and the file header states that uninstall removes deployed targets (agents + skills). See `code/cli/lib/modules/global/commands/uninstall.dart:1-5` and `code/cli/lib/modules/global/commands/uninstall.dart:65-74`.
- The target-specific agent spec explicitly records D23: deploy is limited, but clean still operates on all adapters for backward compatibility. See `docs/spec/target-specific-agents.md:86-105`.

**Confirmation:** The destructive cleanup behavior is not confined to Copilot; it can affect other historical target roots too.

### F6. `iq doctor` encodes the current global deployment contract

**Claim:** The readiness model in `iq doctor` assumes a local `.inquiry/` runtime plus a user-level target deployment of `inquiry.agent.md` and all bundled skills.

**Evidence:**

- `DoctorCommand` checks `.inquiry/` locally via `directoryExists('.inquiry')`. See `code/cli/lib/modules/global/commands/doctor.dart:272-284`.
- It then verifies target deployment by checking `inquiry.agent.md` under `adapter.agentDirectory(homeDir)` and every skill under `adapter.skillsDirectory(homeDir)`. See `code/cli/lib/modules/global/commands/doctor.dart:343-370`.
- When target deployment is incomplete, the doctor output tells the user to run `inquiry target get`. See `code/cli/lib/modules/global/commands/doctor.dart:135-158`.

**Confirmation:** Inquiry currently combines repo-local runtime state with user-global target installation as one expected ready state.

### F7. The repository already recognizes the private-skill delivery problem

**Claim:** Issue #201 is not introducing a foreign concern; it is escalating an architectural inconsistency already identified inside the project.

**Evidence:**

- The LEGION research document explicitly distinguishes between permanently deployed reusable skills and private Inquiry skills that should not live in the target by default. See `docs/research/legion.md:49-58`.
- The roadmap records issue `#185` to introduce an `iq skill` module so Inquiry CLI private skills are no longer left as static deployed markdown only. See `docs/roadmap.md:49-50`.
- The architecture document currently still says private skills are Inquiry-bound while also showing them in the global deploy bundle. See `docs/architecture.md:165-186`.

**Confirmation:** The repository already contains both the diagnosis and the unresolved tension: private Inquiry protocols are conceptually local, but operationally still deployed globally.

### F8. Copilot already supports repo-scoped surfaces for agents and prompt files

**Claim:** GitHub Copilot exposes repository-level customization surfaces that can host at least part of the Inquiry deploy contract without using `~/.copilot/agents/`.

**Evidence:**

- The Copilot target analysis states that custom agents can be repository files under `.github/agents/<name>.agent.md` or user-level files under `~/.copilot/agents/<name>.agent.md`. See `cleanrooms/145-extract-inquiry-core/analyze/copilot-target.md:42-54`.
- The same analysis states that prompt files live under `.github/prompts/<name>.prompt.md`. See `cleanrooms/145-extract-inquiry-core/analyze/copilot-target.md:68-71`.
- It also records that skills are user-level under `~/.copilot/skills/<name>/SKILL.md`. See `cleanrooms/145-extract-inquiry-core/analyze/copilot-target.md:56-67`.

**Confirmation:** Repo-scoped deployment is natively supported for the agent surface and for prompt-file-based reusable task surfaces, but not for `SKILL.md` in the same way.

## Interim conclusion

The code and repository documentation agree on four facts:

1. Inquiry runtime state is repository-local.
2. Inquiry target deployment is currently user-global.
3. The deployer assumes ownership of shared global directories and resets them destructively.
4. The repository already contains conceptual pressure to separate private Inquiry protocols from globally reusable capabilities.

These confirmations are sufficient to support a precise diagnosis in `diagnosis.md`.
