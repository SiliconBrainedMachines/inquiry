---
id: confirmations
title: "Confirmations"
date: 2026-06-16
status: active
tags: [confirmations, findings]
---

# Confirmations

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: OpenCodeAdapter already exists and its paths match OpenCode's real layout — CONFIRMED
- evidence: `code/cli/lib/hosts/opencode_adapter.dart:10-19` — `baseDirectory` = `~/.config/opencode`, `skillsDirectory` = `~/.config/opencode/skills`, `agentDirectory` = `~/.config/opencode/agents`.
- evidence (official): https://opencode.ai/docs/skills/ — skills load from `~/.config/opencode/skills/<name>/SKILL.md`; https://opencode.ai/docs/agents/ — global markdown agents load from `~/.config/opencode/agents/` (plural).
- evidence (runtime): `~/.config/opencode/` exists on this machine with `opencode.jsonc`; `opencode --version` → `1.17.7`.

## F2: OpenCode is registered but excluded from active deploy targets — CONFIRMED
- evidence: `code/cli/lib/hosts/all_adapters.dart:14` (present in `allAdapters`) vs `:20` `deployAdapters = [CopilotAdapter()]`, comment `// For v0.0.x only Copilot is active (D20).`

## F3: `iq host get` deploys skills only and never deploys the agent — CONFIRMED
- evidence: `code/cli/lib/hosts/deployer.dart:35` (`deployExclusive` calls only `_deploySkills`), `:46-56` (`_deploySkills` copies `skills/<n>/SKILL.md`), `:42` (`clean()` deletes `agentDirectory` but nothing writes it).
- evidence: `code/cli/test/deployer_test.dart:91-93` asserts `inquiry.agent.md` is NOT deployed; `:127-129` asserts the agents dir is not created.

## F4: The three skills are OpenCode-compatible as-is — CONFIRMED
- evidence: `assets/skills/research/SKILL.md:1-3`, `assets/skills/legion/SKILL.md:1-3`, `assets/skills/kritik/SKILL.md:1-3` each have YAML frontmatter with `name` + `description` — exactly the fields required by https://opencode.ai/docs/skills/ ("Only these fields are recognized... Unknown frontmatter fields are ignored").

## F5: The inquiry agent needs format adaptation for OpenCode — CONFIRMED
- evidence: `assets/agents/inquiry.agent.md:1-4` frontmatter has `name`, `description`, `tools: [vscode, execute, read, agent, edit, search, web, browser, todo]` — but lacks `mode:` (OpenCode needs `mode: subagent|primary` per https://opencode.ai/docs/agents/), and the `tools` values are Copilot/VSCode names. Body references VSCode-only affordances (`Ctrl+Shift+P → Inquiry: Init`).

## F6: OpenCode CLI is installed and usable with default models — CONFIRMED
- evidence (runtime): `opencode --version` → `1.17.7`; `opencode agent --help` exposes `agent create` / `agent list`; `opencode models` lists default `opencode/*` free models (e.g. `opencode/big-pickle`) — no qwen3-coder required for tests.

## F7: Existing tests encode the single-host contract and will break — CONFIRMED
- evidence: `code/cli/test/hosts_test.dart:57` `expect(deployAdapters, hasLength(1));` and `:61` `expect(deployAdapters.single.name, equals('copilot'));`.

## F8: OpenCode supports Copilot-style activate/deactivate for a primary agent — CONFIRMED
- evidence (official): https://opencode.ai/docs/agents/ — primary agents are switched at runtime with `Tab` / `switch_agent` keybind; persistent disable via config `{"agent": {"<name>": {"disable": true}}}` ("Set to `true` to disable the agent").
- decision (user, 2026-06-16): emit inquiry as `mode: primary` (most faithful to its orchestrator nature); activate/deactivate is covered by Tab/switch_agent + `disable`.

