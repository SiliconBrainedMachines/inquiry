---
id: diagnosis
title: "Diagnosis"
date: 2026-06-16
status: active
tags: [diagnosis, evidence-first]
---

# Diagnosis

## Evidence
- `OpenCodeAdapter` exists with paths matching OpenCode's real layout — `code/cli/lib/hosts/opencode_adapter.dart:10-19`; cross-checked against https://opencode.ai/docs/skills/ and https://opencode.ai/docs/agents/ and runtime (`~/.config/opencode/` present, `opencode 1.17.7`). [F1]
- OpenCode is in `allAdapters` but NOT in `deployAdapters` (Copilot-only, D20) — `code/cli/lib/hosts/all_adapters.dart:14,20`. [F2]
- `iq host get` deploys skills only and never the agent; `clean()` deletes the agent dir but nothing writes it — `code/cli/lib/hosts/deployer.dart:35,42,46-56`; asserted by `code/cli/test/deployer_test.dart:91-93,127-129`. [F3]
- The three skills (`research`, `legion`, `kritik`) already carry `name`+`description` frontmatter, the exact OpenCode SKILL.md schema — `assets/skills/{research,legion,kritik}/SKILL.md:1-3`. [F4]
- The inquiry agent lacks OpenCode's `mode:` field and uses Copilot/VSCode `tools` names + VSCode-only body affordances — `assets/agents/inquiry.agent.md:1-4`. [F5]
- OpenCode CLI is installed and usable with default free `opencode/*` models (no qwen needed for tests) — runtime `opencode --version` / `opencode agent --help` / `opencode models`. [F6]
- Single-host contract is encoded in tests that will break — `code/cli/test/hosts_test.dart:57,61`. [F7]
- OpenCode supports activate/deactivate for `mode: primary` agents (Tab/`switch_agent` + `disable: true` config) — https://opencode.ai/docs/agents/. [F8]

## Hypotheses
- The feature is **mostly pre-wired**: the host abstraction, the OpenCode adapter, the skills, and the deploy/clean plumbing already exist. The change is therefore **activation + one missing capability**, not a new subsystem. [licensed by F1,F2,F3]
- Two blocking gaps remain to satisfy the issue's success condition ("inquiry subagent + research/legion/kritik available in opencode"):
  1. **Activation gap** — OpenCode is excluded from `deployAdapters`. [F2]
  2. **Agent-deploy gap** — `host get` deploys skills but not the agent, yet the success condition requires the inquiry subagent present in `~/.config/opencode/agents/`. This requires (a) new deploy logic and (b) emitting the agent in OpenCode's frontmatter schema (`mode:` etc.). [F3,F5]
- Skills require **no transformation**; they deploy as-is. [F4]

## Constraints
- Do not change the FSM contract (issue out-of-scope).
- Keep Copilot's behavior unchanged — `deployer_test.dart:91-93` encodes "host get does not deploy agents" for the Copilot path; any agent-deploy must not regress Copilot.
- One host active at a time — `deployExclusive` cleans all adapters then deploys to one (`deployer.dart:33-35`). OpenCode must obey the same mutual-exclusion model.
- Tests are the acceptance gate — `hosts_test.dart:57,61` and the deployer tests must be updated/extended, not bypassed.
- Verification must use the real `opencode` command with a default model (per user direction); qwen3-coder is not required for tests.

## Decisions (user-confirmed 2026-06-16)
- **D1 — Agent-deploy scope: OpenCode-only.** `host get` deploys the inquiry agent only when `--host opencode`; Copilot stays skills-only so `deployer_test.dart:91-93` does not regress. [resolves former OQ on scope]
- **D2 — Agent mode: `primary`.** Emit inquiry with `mode: primary` (faithful to its orchestrator nature). Activate/deactivate is satisfied by OpenCode's Tab/`switch_agent` + `disable` config. [F8] Requires emitting an OpenCode-tailored agent file (add `mode:`; the verbatim Copilot file lacks it).

## Open Questions
- **`iq doctor` check (optional):** issue lists an optional OpenCode presence check; the doctor command location was not located in this analysis corpus. Scope as optional in PLAN; does not block the success condition.
