# Inquiry CLI

**Analyze. Plan. Execute.**

The `iq` CLI enforces the Inquiry methodology in your repository — scaffolding the FSM state, deploying agents to your AI tool, and validating transitions.

This README is the CLI package entry surface. For the current runtime model, see [../../docs/architecture.md](../../docs/architecture.md). For forward direction, see [../../docs/roadmap.md](../../docs/roadmap.md). For the broader public overview, see the [root README](../../README.md).

Inquiry names the cycle-level process. APE names the orchestrating methodology. The Finite APE Machine names the engineered finite-state system that the CLI enforces through explicit transitions and persisted artifacts.

## Install

**Windows:**

```powershell
irm https://inquiry.ccisne.dev/install.ps1 | iex
```

**Linux:**

```bash
curl -fsSL https://inquiry.ccisne.dev/install.sh | bash
```

## Commands

| Command | Purpose |
|---|---|
| `iq` | TUI banner with current FSM state |
| `iq init` | Scaffold `cleanrooms/` and repo-scoped `.inquiry/config.yaml` |
| `iq doctor` | Verify prerequisites: `inquiry`, `git`, `gh`, `gh auth` |
| `iq version` | Print CLI version |
| `iq upgrade` | Download and install latest release |
| `iq uninstall` | Remove `inquiry` binary and deployed assets |
| `iq host get` | Deploy Inquiry skills to the active AI host |
| `iq host clean` | Remove deployed Inquiry skills from all known hosts |
| `iq fsm transition --event <e>` | Execute a deterministic FSM transition |
| `iq fsm state [--json]` | Show current FSM state, transitions, and active APE |
| `iq ape prompt --name <name>` | Assemble sub-agent prompt from YAML + current state |
| `iq ape state` | Show active APE sub-state and valid transitions |
| `iq ape transition --event <e>` | Advance the active APE's internal FSM |

## H/F Benchmark (Gemma4)

Use the PowerShell runner to compare Inquiry methodology mode (H) vs freestyle mode (F) with local Copilot CLI routing to Ollama.

```powershell
./scripts/benchmark-hf-gemma4.ps1 -Workspace . -Model gemma4:latest
```

The runner executes both modes with equivalent prompts, stores raw JSONL logs under `tmp/`, and writes `summary.json` with:

- model detection in logs
- evidence that `iq fsm state --json` was executed
- token compliance (`tokenSeen` and `exactTokenMessageSeen`)
- pass/fail booleans for standard and strict literal checks
