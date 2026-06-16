---
id: plan
title: "Plan — Add OpenCode as an Inquiry host"
date: 2026-06-16
status: active
tags: [plan, descartes, evidence-first]
---

# Plan — OpenCode host (#247)

Built from `analyze/diagnosis.md`. Decisions honored: **D1** OpenCode-only agent deploy;
**D2** inquiry emitted as `mode: primary`. Verification per phase is an **executable command**
(no pseudocode) — RED before EXECUTE makes it pass.

## Shared-interface change (enumerated per PLAN constraint)
Phase 2 adds a getter to the abstract `HostAdapter`. Implementors to check (search:
`grep -rn "extends HostAdapter" code/cli/lib code/cli/test`):
`copilot_adapter.dart`, `claude_adapter.dart`, `codex_adapter.dart`, `opencode_adapter.dart`,
`gemini_adapter.dart`, plus test fakes in `test/deployer_test.dart:21` and `test/hosts_test.dart`.
The getter has a default (`false`), so no construction site breaks; only `OpenCodeAdapter` overrides.

---

## Phase 1 — Activate OpenCode as a deploy target
- [ ] `code/cli/lib/hosts/all_adapters.dart:20` → `deployAdapters = [CopilotAdapter(), OpenCodeAdapter()];`
- [ ] `code/cli/test/hosts_test.dart:57` → `hasLength(2)`; `:61` → assert names contain `copilot` and `opencode`.
- **Entry:** diagnosis approved. **Risk:** low.
- **Verification (executable):** `cd code/cli && dart test test/hosts_test.dart` → green.

## Phase 2 — Host capability flag for global agent deploy (host-agnostic; realizes D1)
- [ ] `code/cli/lib/hosts/host_adapter.dart`: add `bool get deploysAgent => false;`
- [ ] `code/cli/lib/hosts/opencode_adapter.dart`: override `bool get deploysAgent => true;`
- Rationale: D1 (opencode-only) without hardcoding the string `'opencode'` in the deployer.
- **Verification (executable):** new test asserting `OpenCodeAdapter().deploysAgent == true` &&
  `CopilotAdapter().deploysAgent == false` → `dart test test/hosts_test.dart` green.

## Phase 3 — Author the OpenCode-tailored inquiry agent asset
- [ ] Add `code/cli/assets/agents/inquiry.opencode.md` with OpenCode frontmatter:
      `description:` (reuse from `inquiry.agent.md`), `mode: primary`; body = inquiry scheduler
      firmware reused from `assets/agents/inquiry.agent.md`, with VSCode-only boot lines
      (`Ctrl+Shift+P → Inquiry: Init`) replaced by host-agnostic `iq init` instructions.
- **Risk:** asset bundling — confirm `Assets.loadString('agents/inquiry.opencode.md')` resolves
  (dev reads from `assets/`; built binary may embed assets → may require rebuild). Verify first.
- **Verification (executable):** `cd code/cli && dart run bin/main.dart` path that loads the asset,
  or a unit test: `assets.loadString('agents/inquiry.opencode.md')` contains `mode: primary`.

## Phase 4 — Deploy the agent in the deployer (gated by `deploysAgent`)
- [ ] `code/cli/lib/hosts/deployer.dart`: in `deployExclusive`, after `_deploySkills(selected)`,
      call `_deployAgent(selected)` only when `selected.deploysAgent`.
- [ ] Add `_deployAgent(adapter)`: load `agents/inquiry.opencode.md`, write to
      `adapter.agentDirectory(homeDir)/inquiry.md` (mkdir -p). `clean()` already wipes
      `agentDirectory` for all adapters (`deployer.dart:42`) → mutual exclusion preserved.
- **Verification (executable):**
  - Copilot unchanged: `dart test test/deployer_test.dart` → existing `:91-93,127-129` still green.
  - New test: fake adapter with `deploysAgent=true` → `agents/inquiry.md` written; assert content
    has `mode: primary`.

## Phase 5 — Integration smoke test with the real `opencode` command
- [ ] Build: `cd code/cli && dart compile exe bin/main.dart -o build/bin/inquiry.exe` (or `scripts/build`).
- [ ] Run `iq host get --host opencode`.
- **Verification (executable):**
  - `test -f ~/.config/opencode/skills/research/SKILL.md` (and legion, kritik).
  - `test -f ~/.config/opencode/agents/inquiry.md` and `grep -q "mode: primary"` it.
  - `opencode agent list` → output contains `inquiry`.
  - (Default `opencode/*` model; no qwen needed, per issue.)

## Phase 6 — (Optional) `iq doctor` OpenCode presence check
- [ ] Locate the doctor command; add an OpenCode-installed check analogous to gh/copilot.
- Scope: optional; does not block the success condition. Defer if time-boxed.
- **Verification:** `iq doctor` lists an OpenCode check; `dart test test/doctor_test.dart` green.

---

## Final verification (mandatory full-suite step)
- [ ] `cd code/cli && dart test` → **entire** suite green (not only changed tests).
- [ ] `iq host get --host opencode` then `opencode agent list` shows `inquiry`, and skills present.
- [ ] `iq host get --host copilot` still deploys skills-only (no Copilot regression).

## Ordering & dependencies
P1 → P2 → P3 → P4 (needs P2+P3) → P5 (needs P1–P4) → P6 (optional, independent).

## Success condition (from issue #247, user-confirmed)
`research`, `legion`, `kritik` skills **and** the `inquiry` agent (as `mode: primary`) are
available in OpenCode after `iq host get --host opencode`, verified via the real `opencode` command.
