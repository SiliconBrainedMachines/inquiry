---
id: confirmed
title: "Confirmed findings"
date: 2026-05-29
status: active
tags: [findings, confirmed]
author: socrates
---

# Confirmed Findings

> Living document. Update as findings are confirmed, revised, or invalidated.
> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED

## F1: Legacy scheduler dispatch coupled APE identity to runtime agent naming — CONFIRMED

The legacy scheduler firmware for ANALYZE explicitly instructed named dispatch: it said to invoke SOCRATES via `runSubagent` rather than dispatching through a generic sub-agent path. This means the runtime dispatch path depended on a concrete agent identity instead of treating the assembled APE prompt as the executable contract.

Evidence:
- Legacy firmware instructs named SOCRATES dispatch in [code/cli/assets/archive/inquiry.agent.md.legacy](code/cli/assets/archive/inquiry.agent.md.legacy#L70).
- The branch and cleanroom itself frame the issue as scheduler dispatch using APE name as agent name in [cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md](cleanrooms/181-scheduler-dispatches-ape-name-as-agentname-during/analyze/index.md#L1).

## F2: Current scheduler firmware explicitly decouples dispatch from `ape.name` — CONFIRMED

The active scheduler firmware now treats `iq ape prompt --name <ape.name>` as the exact effective prompt surface, then requires dispatch through a generic/current sub-agent path. It explicitly forbids deriving `agentName` from `ape.name`.

Evidence:
- The active firmware says to inspect the exact effective prompt and then dispatch generically while omitting `agentName` in [code/cli/assets/agents/inquiry.agent.md](code/cli/assets/agents/inquiry.agent.md#L75).
- The generated build asset mirrors the same contract in [code/cli/build/assets/agents/inquiry.agent.md](code/cli/build/assets/agents/inquiry.agent.md#L75).

## F3: The decoupled dispatch contract is enforced by tests and supported by runtime smoke evidence — CONFIRMED

The firmware test suite asserts that the scheduler must not dispatch sub-agents by APE name and must document generic dispatch without APE-bound `agentName`. Repository-scoped QA notes additionally record that named dispatch fails when no matching custom agent exists, while generic dispatch succeeds with the same assembled prompt.

Evidence:
- Firmware tests reject `@<ape.name>` dispatch and require the explicit prohibition on `agentName` derivation in [code/cli/test/firmware_agent_test.dart](code/cli/test/firmware_agent_test.dart#L35).
- Repository QA notes capture the observed runtime difference between named and generic dispatch in /memories/repo/release-qa.md.
