# Host-Specific Agent Files

**Inquiry — Architectural Reference**

Date: April 16, 2026
Status: Active

---

## 1. Problem Statement

AI coding tools scope their agent/skill discovery to **their own configuration directory**. A file placed in `~/.claude/agents/` is invisible to GitHub Copilot, and vice versa. This is not a format incompatibility — it is a path-scoping boundary.

### Observed behavior

| Tool | Reads from | Ignores |
|------|-----------|---------|
| GitHub Copilot | `~/.copilot/agents/`, `~/.copilot/skills/` | `~/.claude/`, `~/.codex/`, etc. |
| Claude Code | `~/.claude/agents/`, `~/.claude/skills/` | `~/.copilot/`, `~/.codex/`, etc. |

When `iq host get` deployed the same `inquiry.agent.md` to both `~/.copilot/` and `~/.claude/`, Copilot displayed the agent twice (once from each path it scans). The subsumption fix (D19) — skip Copilot deploy when Claude exists — eliminated the duplicate but made the agent invisible to Copilot entirely, since it only existed in `~/.claude/`.

### Root cause

Each tool only reads files from its own directory. Subsumption assumed tools share visibility across directories. They do not.

---

## 2. Correction: gentle-ai Pattern

The initial adapter design treated gentle-ai as evidence that skills and agents could both be copied uniformly across hosts. That assumption turned out to be wrong.

**This was incorrect.**

gentle-ai itself uses host-specific asset directories (`internal/assets/claude/`, `internal/assets/cursor/agents/`, etc.) and different injection strategies per host (MarkdownSections, FileReplace, AppendToFile). The lesson that "skills are shared, agents are shared" was a misread of the reference. The correct lesson is:

- **Skills:** Content can be shared (plain markdown, no tool-specific metadata). Each host gets a copy in its own directory.
- **Agents:** Content must be host-specific. Each tool has its own frontmatter schema, tool declaration syntax, and behavioral expectations.

---

## 3. What Differs Per Host

| Aspect | Copilot | Claude Code | Codex | Gemini CLI |
|--------|---------|-------------|-------|------------|
| Config dir | `~/.copilot/` | `~/.claude/` | `~/.codex/` | `~/.gemini/` |
| Agent format | `.agent.md` with YAML frontmatter (`tools:`, `description:`) | `.md` with YAML frontmatter (different schema) | TBD | TBD |
| Tool declaration | `tools: [vscode, execute, read, ...]` in frontmatter | Different mechanism | TBD | TBD |
| Skill format | `SKILL.md` (plain markdown) | `SKILL.md` (plain markdown) | TBD | TBD |

The prompt body (instructions, state machine, behavior rules) is the **shared core**. The frontmatter and file structure are **host-specific wrappers**.

For Copilot, that wrapper surrounds the scheduler firmware, not the phase-specific repository procedure. At runtime Inquiry CLI assembles the inspectable sub-agent prompt as APE identity from `assets/apes/*.yaml`, phase-owned operational contract from `assets/fsm/states/*.yaml`, and runtime inquiry-context. `iq ape prompt` prints that effective prompt, so operational procedure is not duplicated inside host wrappers or standard APE YAMLs.

---

## 4. Architectural Decision

### D20: Single-host development until MVP

**Decision:** Develop exclusively for GitHub Copilot until a functional MVP exists. Add other hosts (Claude Code, Codex, Gemini, Crush) after the Copilot experience is validated.

**Rationale:**
- Multi-host deployment adds complexity without value during early development.
- The subsumption mechanism (D19) was a workaround for a problem that shouldn't exist — each host should have its own deploy path with its own content.
- Building for one host first forces us to understand that host's requirements deeply before abstracting.

### D21: Agent files are host-specific, skills are shared

**Decision:** The deployer must generate host-specific agent files. Skills remain identical copies across hosts.

**Rationale:**
- Each AI tool has its own agent file schema (frontmatter, tool declarations, behavioral metadata).
- The shared content is the prompt body — the instructions that define APE's behavior.
- The host-specific content is the wrapper: frontmatter, tool lists, file naming conventions.
- Skills are plain markdown with no tool-specific metadata — they can be copied verbatim.

### D22: Subsumption (D19) reverted for CopilotAdapter

**Decision:** Remove `subsumedBy` override from `CopilotAdapter`. The `subsumedBy` mechanism stays in the `HostAdapter` base class (zero cost, available for future use). No host suppresses another.

**Rationale:**
- D19 was a workaround for duplicate visibility. The real fix is: each tool reads only from its own directory, so duplicates cannot occur if each host deploys to its own path.
- The base class mechanism is preserved for potential future use when multi-host is re-enabled.

### D23: Adapter code preserved, registration limited

**Decision:** All 5 adapter files remain in `lib/hosts/`. Only `CopilotAdapter` is registered for deploy in v0.7.x. `clean()` uses all adapters for backward compatibility (cleans orphaned files from previous deploys).

**Rationale:**
- The adapter code is already written and tested. Deleting it wastes prior work.
- Re-enabling a host is a one-line change in the adapter registry.
- Backward-compatible clean ensures users who previously deployed to other hosts don't have orphaned files.

---

## 5. Implementation Path

### Phase 1 (v0.7.x): Copilot-only

- Keep all adapter files, register only `CopilotAdapter` for deploy
- Remove `subsumedBy` from `CopilotAdapter`
- Deploy `inquiry.agent.md` + skills to `~/.copilot/` only
- `clean()` still operates on all 5 adapters (backward compat)
- Validate that Copilot reads the agent and honors tool declarations

### Phase 2 (post-MVP): Multi-host

- Re-register adapters one at a time in the deploy list
- Each adapter may define its own agent template or transformation
- The deployer becomes a compiler: shared scheduler firmware + host-specific wrapper → host-specific file
- Sub-agent prompt assembly remains CLI-owned and inspectable via `iq ape prompt`
- Skills continue to be copied verbatim

---

## 6. Key Insight

> **The deployer is not a file copier. It is a compiler.**
>
> Input: shared prompt content + host-specific metadata schema.
> Output: one correctly-formatted agent file per host.
>
> For v0.7.x, the "compiler" is trivial — copy one file to one host.
> For later multi-host versions, it must compose host-specific wrappers around shared prompts.
