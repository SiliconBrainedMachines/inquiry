# Inquiry

**Analyze. Plan. Execute.**

A methodology for AI-assisted software development that models coding agents as a cooperative finite state machine — **Analyze → Plan → Execute → End → [Evolution] → Idle** — where the value is in the process, not the model.

**Status:** `v0.14.0` · Windows + Linux · OpenCode + Claude runtime

This README is the public entry surface. The living repository doctrine is intentionally small in `docs/architecture.md` and `docs/roadmap.md`.

Inquiry now also carries its long-form book manuscript inside [`code/book/README.md`](code/book/README.md). The book is the canonical doctrinal treatment of the project; the runtime contract remains governed by the CLI assets, tests, and specifications in this repository.

## What is Inquiry?

Inquiry is a structured methodology that turns AI coding assistants into disciplined engineering partners. Instead of letting an LLM freestream solutions, Inquiry forces a cycle: understand the problem first (Analyze), design the solution second (Plan), then implement mechanically (Execute). Each phase has constraints, artifacts, and a clear exit condition.

The insight: **AI capability only becomes trustworthy when governed by rigorous thinking tools and explicit process.** The durable asset is the method that turns philosophical discipline into operational practice.

### Key principles

- **Thinking tools before improvisation** — quality comes from disciplined inquiry, not from unstructured prompting
- **Memory as Code** — project memory lives as version-controlled markdown, readable by both humans and AI. No vector DB, no hosted memory service
- **Agents as FSM states** — each phase activates one specialized agent; transitions are declarative, total, and validated
- **The model is the brain; the CLI is the tool** — the CLI does the established mechanics (scaffolds each phase's artifact from a single-source template, injects context, runs the gates); the model or human does the thinking. The CLI prescribes and verifies; it does not decide
- **Antifragile by design** — if tools change, the methodology remains legible and portable; if tools improve, the methodology amplifies gains

## The Inquiry cycle

| State | Agent | Method | Artifact |
|---|---|---|---|
| **IDLE** | DEWEY | Deweyan problematization — scope, deduplicate, prepare issue handoff | selected issue + `inquiry-start` handoff |
| **ANALYZE** | SOCRATES | Socratic questioning — clarify, challenge, evidence | `confirmed.md` → `diagnosis.md` |
| **PLAN** | DESCARTES | Scientific method — divide, order, verify, enumerate | `plan.md` |
| **EXECUTE** | ADA | Programming manifesto — intention-first construction and slice review | code + commits |
| **END** | — | PR gate — review, merge | merged PR |
| **EVOLUTION** | DARWIN | Natural selection — propose methodology mutations | issues on this repo |

DEWEY stays bounded to issue triage in IDLE. Branch preparation and the `start_analyze` transition remain in the `inquiry-start` protocol.

Each agent receives a prompt assembled by the CLI that includes:
- Its philosophical mandate (from YAML definitions)
- Its current sub-state within the phase
- An `inquiry-context` block with resolved paths (where to write, what to read)

The agent never guesses where things go. The CLI tells it.

## Documentation as runtime evidence

During ANALYZE, SOCRATES writes investigation material to `cleanrooms/<branch>/analyze/`:

- **`confirmations.md`** — bounded analysis corpus and confirmations
- **Topic documents** — optional bounded evidence threads when needed
- **`diagnosis.md`** — final synthesis that references all findings

DESCARTES reads `diagnosis.md` as its authoritative planning input. ADA inherits `plan.md` as the execution baseline, while EXECUTE and END rely on `pre_pr_inspection.md` and `run_trace.yaml` as the closure and observability surfaces that now define the 0.7.x baseline.

This ensures that analysis survives context windows, session resets, and model swaps. The investigation is in the files, not in the chat.

## Philosophy

### AAD / AAE / AAM

The collaboration model draws from manufacturing: **Agent-Aided Design, Engineering, and Manufacturing.** Humans design with AI assistance, co-engineer with AI execution, and delegate mechanical work to automation. A semantic risk matrix calibrates where each action falls on that spectrum.

### DARWIN and antifragility

EVOLUTION is an optional phase where DARWIN — a meta-agent — reviews the completed cycle and proposes mutations to the methodology itself. Bad cycles produce lessons; lessons produce better methodology. The system improves from failure, not despite it.

### Why a finite state machine?

An FSM eliminates ambiguity. At any point, the system is in exactly one state, with a finite set of valid transitions. There is no "figure out what to do next." The agent reads its state, receives its mandate, and executes within constraints. This is not a limitation — it is the source of reliability.

## Quick start

```bash
# Install (Windows)
irm https://inquiry.ccisne.dev/install.ps1 | iex

# Install (Linux)
curl -fsSL https://inquiry.ccisne.dev/install.sh | bash

# Setup
iq doctor                # verify prerequisites
iq host get --plan       # what deploying would change — nothing is touched
iq host get --apply      # show it, ask for approval, then do it (or: --host claude)
cd your-repo
iq init                  # scaffold .inquiry/ workspace
iq                       # show current state

# Run a phase by hand (no scheduler agent): use the MACSS lifecycle skills
#   /macss-analyze   /macss-plan   /macss-execute
#   installed with: macss skill deploy
```

For the current system model, see [`docs/architecture.md`](docs/architecture.md). For forward direction, see [`docs/roadmap.md`](docs/roadmap.md).

## Architecture

- **CLI:** Dart, single cross-platform binary, built on [`modular_cli_sdk`](https://github.com/ccisnedev/modular_cli_sdk)
- **FSM:** declarative `transition_contract.yaml` — every (state, event) pair is total
- **Context injection:** `iq ape prompt` assembles base prompt + sub-state + dynamic paths as fenced YAML
- **Skills:** operational protocols such as `issue-create`, `inquiry-start`, `inquiry-end`, `doc-read`, `doc-write`, `inquiry-install`, plus direct-use skills such as `research`, `legion`, and `kritik`. The per-phase skills that drive a cycle by hand now ship with [MACSS](https://github.com/ccisnedev/macss) as `macss-analyze` / `macss-plan` / `macss-execute`; they delegate the mechanics back to `iq fsm state` and `iq fsm transition`, so this CLI stays the authority on the gates
- **Memory:** `.inquiry/` (runtime state) and `cleanrooms/` (per-cycle artifacts the CLI scaffolds from single-source templates)
- **Book:** Markdown-first manuscript and editorial pipeline under [`code/book/`](code/book)
- **Host:** OpenCode and Claude — `iq host get` deploys the agent + skills globally and additively, to the hosts actually present on the machine. It writes into those tools' own directories, so like `upgrade`, `uninstall`, `host clean` and `implementation start` it says what it would do and takes approval first (`--plan` / `--apply`); every other route answers on the spot. See [ADR 0002](docs/adr/0002-a-query-may-write-what-the-cli-itself-owns.md)

## Documentation

| Document | Purpose |
|----------|---------|
| [`code/book/README.md`](code/book/README.md) | Canonical long-form book manuscript and editorial surface |
| [`docs/architecture.md`](docs/architecture.md) | Current runtime model and operating doctrine |
| [`docs/roadmap.md`](docs/roadmap.md) | Strategic direction |
| `cleanrooms/<branch>/...` | Cycle-local evidence created only when a cycle is active |

## License

MIT

## Related work

The idea of a CLI that **installs prompts and skills** into whatever AI coding agent you use — instead of keeping custom agents and skills scattered across each tool's config — comes from [gentle-ai](https://github.com/Gentleman-Programming/gentle-ai) (Gentleman Programming). Inquiry takes that packaging idea in a different direction: a single-host deterministic FSM contract enforced by the CLI, with the methodology itself as the durable artifact.
