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

Most routes answer on the spot. Five change something outside the CLI's own
files — they install, remove, or write into your repository — and those refuse
to act until you say which of `--plan` and `--apply` you meant. They are marked
below.

| Command | Purpose |
|---|---|
| `iq` | TUI banner with current FSM state |
| `iq init` | Scaffold `cleanrooms/` and repo-scoped `.inquiry/config.yaml` |
| `iq doctor` | Verify prerequisites: `inquiry`, `git`, `gh`, `gh auth` |
| `iq version` | Print CLI version |
| `iq upgrade` | Download and install the latest release — `--plan`/`--apply` |
| `iq uninstall` | Remove the `inquiry` binary and deployed assets — `--plan`/`--apply` |
| `iq host get` | Deploy Inquiry skills to every detected AI host — `--plan`/`--apply` |
| `iq host clean` | Remove deployed Inquiry skills from all known hosts — `--plan`/`--apply` |
| `iq implementation start --issue <N>` | Open a cycle: branch, cleanroom, ANALYZE — `--plan`/`--apply` |
| `iq fsm transition --event <e>` | Execute a deterministic FSM transition |
| `iq fsm state [--json]` | Show current FSM state, transitions, and active APE |
| `iq ape prompt --name <name>` | Assemble sub-agent prompt from YAML + current state |
| `iq ape state` | Show active APE sub-state and valid transitions |
| `iq ape transition --event <e>` | Advance the active APE's internal FSM |

### `--plan` and `--apply`

```bash
iq host get --plan               # say what would change; change nothing
iq host get --apply              # say it, ask for approval, then do it
iq host get --apply --autoapprove  # act without asking — for agents and CI
```

Neither is the default: a command that changes things does not decide for you
which one you wanted. See
[ADR 0002](../../docs/adr/0002-a-query-may-write-what-the-cli-itself-owns.md)
for where the line between the two kinds falls.

## H/F Full-Flow Benchmark (Gemma4)

Use the full-flow runner to compare Inquiry methodology mode (H) vs freestyle mode (F) on the longer IDLE -> ANALYZE -> PLAN -> EXECUTE -> END path with local Copilot CLI routing to Ollama.

```powershell
./scripts/benchmark-fullflow-gemma4.ps1 -Workspace . -Model gemma4:latest -IssueNumber 242
```

The runner prepares a benchmark cleanroom, executes both modes against the same issue/branch context, and writes `summary.json` with:

- per-mode tool-call counts
- per-mode session and API duration
- whether each state was reached (`IDLE`, `ANALYZE`, `PLAN`, `EXECUTE`, `END`)
- exact-token compliance for the final run marker
