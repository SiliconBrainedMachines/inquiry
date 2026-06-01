# Architecture

> This document is the current canonical system-level explanation of Inquiry as the orchestrating methodology.
>
> How Inquiry orchestrates AI coding hosts through a finite state machine.

Inquiry is best read as an **outer harness** around the host coding tool. The host runtime contributes the model, baseline tool invocation surface, and vendor-specific prompt substrate. Inquiry CLI contributes the repository-local control system layered on top of that substrate: explicit FSM state, inspectable prompt assembly, deployable skills, Memory as Code artifacts, human-gated transitions, and durable handoff documents. The point is not to replace the host's built-in harness, but to add a stricter and more inspectable one optimized for disciplined software work.

The 0.7.x architectural stance is simple: keep the harness small, explicit, and evidence-backed. Inquiry should prefer a narrow core that can survive host changes over a sprawling documentation and feature surface that preserves every historical branch of thought.

## The five-layer model

Inquiry is easiest to reason about as **five stacked layers**. Higher layers constrain lower layers. Lower layers contribute capability, but they do not self-authorize changes to the layer above them.

1. **Host layer** — the external coding host that provides the model, chat runtime, and tool surface. Today this is Copilot. Future hosts may include Claude, Codex, Gemini, or OpenCode.
2. **Harness layer** — the repository-local engineering system: Inquiry CLI, bundled assets, `.inquiry/`, `cleanrooms/`, deployment adapters, and the host-visible orchestrator prompt. This is the durable engineering component.
3. **FSM layer** — the explicit problem-solving control algorithm: `IDLE -> ANALYZE -> PLAN -> EXECUTE -> END -> EVOLUTION`, with total `(state, event)` transitions, prechecks, and artifact expectations.
4. **Protocol layer** — the operational procedures. This includes private Inquiry runtime protocols such as `issue-create`, `inquiry-start`, `inquiry-end`, `doc-read`, `doc-write`, and `inquiry-install`, plus public reusable skills such as `research`, `legion`, and `kritik`.
5. **Cognitive layer** — the phase-specific thinking operators: DEWEY, SOCRATES, DESCARTES, ADA, and DARWIN. They contribute a mode of reasoning, not control authority.

The important consequence is that `inquiry.agent.md` is **part of the harness layer, not the whole harness**. It is the host-visible dispatcher that reads state, invokes the right protocol, and routes work to the active cognitive operator under FSM constraints.

| Layer | Owns | Must not own |
|---|---|---|
| Host | Model runtime, chat surface, tools | Inquiry's repository-local methodology |
| Harness | State, prompt assembly, deployment, durable artifacts | Phase-specific cognition |
| FSM | Which phase is active and which transitions are legal | Ad hoc reasoning about the task |
| Protocols | Repeatable operating procedures | Global state authority |
| Cognitive operators | How to think within the current phase | Transition authority, deployment, or repo-wide control |

## The system in one diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│  Human (developer)                                                  │
│    ↕ authorizes transitions, writes cycle mutations, reviews PRs    │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│  Inquiry CLI                                                        │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  FSM Engine (transition_contract.yaml)                        │  │
│  │                                                               │  │
│  │  (state, event) → allowed? → prechecks → effects → new state  │  │
│  │                                                               │  │
│  │  Total matrix: every (state × event) pair is explicit         │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌──────────────────────┐    ┌─────────────────────────────────────────┐   │
│  │ .inquiry/            │    │ Host Deployer (`iq host get`)          │   │
│  │  config.yaml         │    │                                         │   │
│  │ cleanrooms/<branch>/ │    │  binds Inquiry to the active host      │   │
│  │  .iq.state.yaml      │    │  by copying skills into it             │   │
│  │  mutations.md        │    │  (`iq init` owns the repo agent)       │   │
│  └──────────────────────┘    └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                          deploys host-visible agent + skills
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│  AI Coding Host (Copilot now; future Claude/Codex/Gemini/OpenCode) │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  inquiry.agent.md (host-visible orchestrator)                 │  │
│  │                                                               │  │
│  │  Reads the active cycle state → knows current FSM state       │  │
│  │  Activates the agent for that state:                          │  │
│  │                                                               │  │
│  │    IDLE     → DEWEY     (bounded triage, issue-ready only)    │  │
│  │    ANALYZE  → SOCRATES  (evidence-first analysis, produces diagnosis.md) │  │
│  │    PLAN     → DESCARTES (method, produces plan.md)            │  │
│  │    EXECUTE  → ADA       (programming manifesto, produces code under phase contract) │  │
│  │    END      → (PR gate: gh pr create + gh pr merge)           │  │
│  │    EVOLUTION→ DARWIN    (mutations, produces issues)          │  │
│  │                                                               │  │
│  │  Invokes skills as needed:                                    │  │
│  │    issue-create → IDLE create-or-confirm issue                │  │
│  │    inquiry-start → explicit handoff into ANALYZE              │  │
│  │    inquiry-end  → EXECUTE / END completion protocol           │  │
│  │    doc-read     → structured doc retrieval                    │  │
│  │    doc-write    → structured doc creation                     │  │
│  │    skills       → research / legion / kritik                  │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  The agent has NO knowledge of other states' agents.                │
│  It only sees: current state + transition contract + memory.        │
└─────────────────────────────────────────────────────────────────────┘

Sub-agent prompt delivery is explicit and inspectable. `iq ape prompt --name <ape>` prints the exact effective prompt as APE identity from `assets/apes/<name>.yaml`, phase-owned operational contract from `assets/fsm/states/<state>.yaml`, and runtime `inquiry-context` resolved by the CLI. Standard APE YAMLs no longer own the primary repository procedure. DARWIN is the bounded exception: EVOLUTION may provide the abstract observe/compare/select standard that DARWIN consumes, but issue search/comment/create and metrics procedure remain state-owned.

                                   │
                          reads/writes
                                   │
┌──────────────────────────────────▼──────────────────────────────────┐
│  Repository (Memory as Code)                                        │
│                                                                     │
│  cleanrooms/<branch>/.iq.state.yaml ← current FSM state (IDLE, ANALYZE, etc.) │
│  .inquiry/config.yaml             ← project-scoped config (evolution.enabled, etc.) │
│  cleanrooms/<branch>/mutations.md ← human notes for DARWIN              │
│  cleanrooms/NNN-slug/             ← per-cycle artifacts created only for active cycles │
│  docs/                 ← intentionally minimal doctrine              │
└─────────────────────────────────────────────────────────────────────┘
```

## FSM: the transition contract

The core of APE is a **declarative, total** finite state machine. "Total" means every `(state, event)` pair has an explicit entry — no implicit behavior.

```yaml
# transition_contract.yaml (excerpt)
- from: IDLE
  event: start_analyze
  to: ANALYZE
  allowed: true
  operations:
    prechecks: []
    effects: [open_analysis_context, reset_mutations]
    artifacts: [analysis/index.md]
    commit_policy: none
    prompt_fragment_id: idle_to_analyze

- from: IDLE
  event: approve_plan
  to: ILLEGAL
  allowed: false
  reason: "IDLE cannot approve plan directly"
```

Each allowed transition carries:

| Field | Purpose |
|---|---|
| `prechecks` | Conditions that must be true before transition fires |
| `effects` | Side effects to execute (reset_mutations, open_analysis_context) |
| `artifacts` | Files that this transition should produce |
| `commit_policy` | When to commit (none, after_effects, after_artifacts) |
| `prompt_fragment_id` | Links to agent prompt section for this transition |

The CLI enforces this via `iq fsm transition --event <e>`: reads `cleanrooms/<branch>/.iq.state.yaml`, looks up `(current_state, event)` in the contract, validates prechecks, applies effects, writes the new cycle state.

## Inquiry as outer harness

Viewed through the current research taxonomy, Inquiry spans all four agent-engineering layers but concentrates its force in **Harness Engineering**:

- **Prompt Engineering**: APE identities, state prompts, and skill protocols shape how the operator is instructed.
- **Context Engineering**: `iq ape prompt`, `inquiry-context`, `.inquiry/`, and `cleanrooms/` control what the operator sees and what survives across turns.
- **Eval Engineering**: PR gates, transition prechecks, state-owned artifact expectations, and cycle metrics provide partial but real evaluation structure.
- **Harness Engineering**: the CLI, FSM, deployer, state files, skills, and human authorization rules form the actual control system around the host agent.

That distinction matters because it clarifies what Inquiry already is and what it should not regress into. Inquiry is no longer just a methodology described in markdown or a pack of prompts deployed into Copilot. It already functions as a repository-local harness. The current bar is to keep the live contract explicit in code, assets, tests, and a minimal amount of doctrine instead of carrying every historical explanation forever.

## 0.7.x operating baseline

The live 0.7.x baseline is:

- **Task contract first.** The runtime injects explicit task identity, bounded surfaces, expected outputs, and done criteria.
- **Evidence-first ANALYZE.** SOCRATES is expected to gather bounded repo and cycle evidence before questioning the user.
- **Authoritative handoffs.** `diagnosis.md` and `plan.md` are phase-owned operational authority, not optional narrative summaries.
- **Sensorized closure.** END is a visible gate with deterministic checks, pre-PR inspection, and release closure discipline.
- **Observability.** `run_trace.yaml`, `metrics.yaml`, `metrics_snapshot.yaml`, and `pre_pr_inspection.md` provide enough local evidence to explain cost, retries, blocks, and closure state.

## Agent architecture

There is **one agent file** (`inquiry.agent.md`) that acts as orchestrator. It is NOT 4 separate agents — it is one prompt that **behaves differently depending on FSM state**:

The scheduler does not inline each phase runbook itself. It reads state, inspects the exact assembled sub-agent prompt through `iq ape prompt`, and dispatches the active thinking tool against that inspectable runtime surface.

```
inquiry.agent.md
├── Reads cleanrooms/<branch>/.iq.state.yaml → determines active phase
├── IDLE: becomes DEWEY (bounded issue triage; handoff via inquiry-start)
├── ANALYZE: becomes SOCRATES (gathers evidence, asks only if needed, writes diagnosis.md)
├── PLAN: becomes DESCARTES (decomposes, writes plan.md with phases)
├── EXECUTE: becomes ADA (frames intent, locates the control surface, composes the change, reviews the slice)
├── END: executes PR creation protocol
└── EVOLUTION: becomes DARWIN (reads cleanrooms/<branch>/mutations.md, proposes issues)
```

DEWEY determines whether the situation is ready to become or select a GitHub issue. It does not prepare branches, write `diagnosis.md`, or anticipate downstream phases; `inquiry-start` owns that explicit handoff.

The agent **never decides** state transitions on its own. Transitions are authorized by:
1. The human (explicitly)
2. A skill protocol (`issue-create`, `inquiry-start`, `inquiry-end`)
3. The CLI contract (prechecks must pass)

## Skills as protocols

Skills are **step-by-step protocols** invoked by the agent at specific moments. In the current repository they fall into two groups.

### Private skills

| Skill | When | Does |
|---|---|---|
| `issue-create` | IDLE triage needs to create or confirm the operative GitHub issue | Deterministic issue selection/creation during bounded triage |
| `inquiry-start` | Human says "start working on issue #N" | Creates branch, reads issue, transitions IDLE → ANALYZE |
| `inquiry-end` | All plan checkboxes complete | Pushes, creates PR, merges, transitions → END → IDLE |
| `doc-read` | Agent needs project context | Index scan → filter → partial read → full read |
| `doc-write` | Agent produces documentation | YAML frontmatter, one topic per doc, index maintenance |
| `inquiry-install` | First-time setup | Bootstraps `.inquiry/` workspace structure |

### Skills

| Skill | When | Does |
|---|---|---|
| `research` | A staged web investigation is required | Gathers web evidence into one durable markdown report with references |
| `legion` | Multiple isolated expert viewpoints are needed | Runs a council of sub-agents and persists a synthesized dictamen |
| `kritik` | A bounded-corpus claim audit is required | Audits whether conclusions are licensed by evidence, warrant, and counterevidence |

Private skills are tied to Inquiry CLI concepts and only make sense inside the Inquiry runtime. Skills such as `research`, `legion`, and `kritik` are reusable protocols that can be invoked from any phase or directly by the user.

SKILL.md files are **shared across hosts** (same SKILL.md for Copilot, Claude, etc.). The agent file is **host-specific** because prompt format differs per host. Legacy `iq target ...` aliases remain accepted for compatibility, but `host` is the canonical term.

## Host deployment model

The canonical command surface is `iq host get`. Legacy `iq target get` remains accepted as a compatibility alias, but the operational model is host-bound.

```
iq host get
    │
    ├── Reads bundled assets/ from alongside the inquiry binary
  ├── Cleans ~/.copilot/skills/  (idempotent reset)
  └── Copies skills/ → ~/.copilot/skills/
         ├── issue-create/SKILL.md
         ├── inquiry-start/SKILL.md
         ├── inquiry-end/SKILL.md
         ├── doc-read/SKILL.md
         ├── doc-write/SKILL.md
         ├── inquiry-install/SKILL.md
         ├── legion/SKILL.md
         ├── research/SKILL.md
         └── kritik/SKILL.md

iq init
  └── Ensures .github/agents/inquiry.agent.md exists in the repo
```

Only **Copilot** is currently active. Adapters for other hosts remain deferred until Inquiry has a cleaner host-boundary contract and evidence that reactivation improves the harness instead of diluting it.

## Cycle lifecycle

A complete APE cycle from issue to merge:

```
1. Human and DEWEY clarify/select the GitHub issue in IDLE, using `issue-create` when the issue must be created or confirmed
2. Human invokes inquiry-start skill
3. CLI: IDLE → ANALYZE (start_analyze event)
4. Agent (SOCRATES): gathers repo and artifact evidence first, asks clarifying questions only if needed, produces diagnosis.md
5. Human authorizes: ANALYZE → PLAN (complete_analysis)
6. Agent (DESCARTES): writes plan.md with phased checkboxes
7. Human authorizes: PLAN → EXECUTE (approve_plan)
8. Agent (ADA): implements phase by phase under the plan and reviews each changed slice against the coding manifesto; commits and release closure remain phase-owned contract obligations
9. Human invokes inquiry-end skill when plan complete
10. CLI: EXECUTE → END (finish_execute) → git push + gh pr create
11. PR merged → END → EVOLUTION or END → IDLE (per config)
12. If EVOLUTION: DARWIN reads `cleanrooms/<branch>/mutations.md`, proposes improvement issues
13. CLI: EVOLUTION → IDLE (finish_evolution), resets `cleanrooms/<branch>/mutations.md`
```

## Key design decisions

| Decision | Choice | Why |
|---|---|---|
| **Inquiry is an outer harness** | The host tool provides base model/runtime behavior; Inquiry adds repository-local control, memory, and gates | Keeps the system inspectable, portable, and methodology-first instead of vendor-first |
| **One agent, many behaviors** | Single inquiry.agent.md, state-driven | Simpler deployment, no inter-agent coordination needed |
| **Total FSM** | Every (state,event) explicit | No undefined behavior, contract is auditable |
| **CLI enforces, agent proposes** | Transitions go through CLI | Agent can't corrupt state; human is gate |
| **Skills are protocols** | Step-by-step markdown, not code | Portable across any LLM that reads markdown |
| **Memory in repo** | .inquiry/ + docs/, no external DB | Version-controlled, survives any infrastructure change |
| **Single host until MVP** | Copilot only (D20) | Prove methodology on one tool before fragmenting |
| **Prompt delivery is explicit** | `iq ape prompt` prints identity + contract + context | The effective prompt stays inspectable; no hidden glue in standard APE YAMLs |
| **EVOLUTION is opt-in** | config.yaml flag | Self-modification is powerful but must be conscious |