# APE Prompt for AI Agents — Analysis

**What:** A system prompt that configures any AI agent (GitHub Copilot, Claude, Gemini, Codex) to follow the APE methodology.
**Goal:** The agent knows the three states, respects transitions, and never acts outside its current state's permissions.
**Format:** A single text that works as system prompt, custom instructions, or pasted as a user message.
**Filename decision pending:** `AGENT.md` (recommended — platform-agnostic, follows `CLAUDE.md` convention) vs `APE.md` (method-centric).

---

## Requirements (from analysis)

### The State Machine

```
States: ANALYZE → PLAN → EXECUTE

Transitions (all require explicit user authorization):

  ANALYZE → PLAN          User says to move to plan
  PLAN → ANALYZE          User says to return to analysis
  PLAN → EXECUTE          User approves the plan
  EXECUTE → ANALYZE       User interrupts or execution completes

Illegal transitions:
  ANALYZE → EXECUTE       Always illegal (no skipping Plan)
  EXECUTE → PLAN          Always illegal (must go through Analyze)

Initial state: always ANALYZE

Fast-forward: User declares a plan inline during Analyze.
  Agent documents the plan → user approves → Execute.
  All three states are respected; Analyze was implicit in the user's mind.

Interruption: User can halt Execute and return to Analyze at any time.
```

### Permissions per State

**ANALYZE — Think together**
- CAN: dialogue, debate, question, propose, challenge, research
- CAN: create/modify files in `docs/ape/<current-task>/analyze/` only
- CANNOT: create or modify code, entregables, or files outside analyze/
- CANNOT: transition to another state without user authorization

**PLAN — Structure together**
- CAN: propose a plan, structure sequences, estimate, identify risks
- CAN: write `docs/ape/<current-task>/plan.md` only
- CANNOT: execute the plan or create deliverables
- CANNOT: transition without user authorization

**EXECUTE — Agent works, user reviews**
- CAN: create, modify, build, test — whatever the approved plan specifies
- CAN: write `docs/ape/<current-task>/execute.md` as execution log
- CANNOT: deviate from the approved plan without returning to Analyze
- MUST: log significant decisions and deviations in execute.md

### Transition Signals

**Explicit signals (recognized as transitions):**
- "Pasamos a Plan" / "Move to Plan"
- "Aprobado, procede" / "Approved, execute"
- "Volvamos a Analyze" / "Back to Analyze"
- "Ejecuta" / "Execute" / "Procede" / "Proceed"

**NOT transition signals (require clarification):**
- "Ok" / "Me gusta" / "Bien" — may be feedback, not authorization
- "Suena bien" / "Sounds good" — acknowledgment, not approval
- Urgency language: "do it now", "emergency", "my grandmother will die" — never bypasses the state machine

**Rule:** When in doubt, ask. "¿Quieres que pasemos a [next state], o seguimos en [current state]?"

### Directory Structure (Convention)

```
docs/ape/NNN-<slug>/
├── analyze/          ← multiple .md files (analysis is expansive)
├── plan.md           ← single file (plan is one approved document)
└── execute.md        ← single file, optional (execution log / post-mortem)
```

- NNN is a global sequential number, corresponds to GitHub issue number
- Numbers are never reused (abandoned work keeps its number)
- The slug describes the work: `001-user-auth`, `014-fix-memory-leak`, `027-chapter-one`
- This is memory as code — the full reasoning history lives in the repo

### Design Principles for the Prompt

1. **Short.** Every token the prompt uses is context the agent can't use for work. Maximum density per line.
2. **No justifications.** The prompt says what to do, not why. "Do not execute in Analyze" — no "because the methodology establishes..."
3. **Redundant on critical points.** The abductive mind needs repetition to treat something as a hard constraint. State boundaries must be stated more than once.
4. **Platform-agnostic.** Works as system prompt (Claude, Gemini API), custom instructions (GitHub Copilot), or pasted as first user message. No platform-specific syntax.
5. **Bilingual signals.** Recognizes transitions in English and Spanish.
6. **Pessimistic.** Assumes the agent will try to be helpful by skipping ahead. The prompt must make clear that "helpful" means staying in state.

### What the Prompt Is NOT

- Not a tutorial on APE (that's the book's job)
- Not a coding standard or style guide
- Not a personality prompt ("be friendly", "be concise")
- Not a complete agent system (it doesn't handle tool selection, output format, etc.)

It is purely the **state machine contract** between user and agent.

---

## Risks

| Risk | Mitigation |
|------|-----------|
| Agent ignores the prompt under strong contextual pressure | Redundancy on critical rules; explicit "even if the user seems to want X, do not Y" |
| Prompt too long, agent loses focus on it | Keep under 500 words. Every word must earn its place |
| Different platforms interpret differently | Test on Copilot, Claude, Gemini after writing. Adjust wording for lowest-common-denominator compliance |
| User forgets to declare transitions | Agent's default behavior in doubt is to ASK, not to assume |
| Fast-forward path is ambiguous | Agent must still write plan.md before executing, even in fast-forward |

---

## Open Questions for Plan Phase

1. **Filename:** `AGENT.md` vs `APE.md` — decide before writing
2. **Where it lives in the repo:** Root (`/AGENT.md`) or in a config directory (`.github/AGENT.md`)?
3. **Word count target:** 300? 500? Need to test minimum viable prompt
4. **Testing protocol:** How do we verify the prompt works? Scenarios to test on each platform
5. **Versioning:** Does the prompt evolve with APE? SemVer?

---

## Connection to Philo SophIA

This prompt is the **first real-world artifact** of the book's thesis: philosophical thinking tools applied to AI communication. It is:

- A **skill.md for the abductive mind** (configures the machine)
- A living example of **cognitive transparency** (precise language reducing Δ to zero)
- An application of **formal logic** (state machine), **philosophy of language** (explicit signals vs ambiguous feedback), and **ethics** (authority and agency)
- Candidate material for the book — Chapter 8 (Freedom/Agency) or the Skill chapter

The pair is: `AGENT.md` configures the machine. The book's skill chapter configures the human. Together they are the complete thinking-tools stack.
