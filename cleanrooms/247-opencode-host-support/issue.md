---
id: issue
issue: "247"
branch: 247-opencode-host-support
date: 2026-06-16
---

# Issue #247

## Goal

Add **OpenCode** as a supported Inquiry host, alongside the current Copilot-only runtime (`docs/architecture.md`: *\"Host: Copilot only at present. Multi-host deferred until reactivation\"*). This unlocks driving the APE FSM with a **local model** — specifically `qwen3-coder:30b` via Ollama (measured ~30 tok/s locally on a 12GB GPU) — using Inquiry as the guiding harness.

## Why

- The gemma4 fullflow benchmark (#242) showed neither H nor F completed IDLE→END, with H bottlenecked on local-model speed. A faster, more capable local coder (qwen3-coder:30b) is the better harness target.
- OpenCode is open and scriptable, a natural fit for a deterministic FSM driver.

## Scope (to be refined in ANALYZE/PLAN)

- `iq host get --host opencode`: deploy Inquiry skills/agents into OpenCode's config layout.
- Map the `host` module abstraction (currently Copilot-specific) to a host-agnostic interface; implement an OpenCode adapter under `code/cli/lib/hosts/`.
- Provider config for local Ollama (`http://localhost:11434/v1`, model `qwen3-coder:30b`).
- `iq doctor` checks for OpenCode presence/auth analogous to the gh/copilot checks.

## Out of scope

- Changing the FSM contract itself.
- Multi-host orchestration beyond Copilot + OpenCode.

## Notes

This issue is also being used as a guided walkthrough of the Inquiry CLI itself (ANALYZE → PLAN → EXECUTE) to validate the harness end-to-end on a real feature.
