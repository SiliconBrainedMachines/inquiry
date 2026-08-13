---
id: cli-as-api
title: "CLI as API — skills instruct, commands execute through Inquiry"
date: 2026-04-17
status: active
tags: [architecture, cli, skills, commands, validation, human-usable]
author: socrates
---

# CLI as API Principle

## The Duality

```
Skill (doc-write)           →  Tells the agent WHEN and HOW to write
CLI (`iq` command surface)  →  Does the actual work with validation
```

A skill is documentation. A command is execution. The skill tells the agent what protocol to follow; the CLI enforces the repository's runtime contract where a command exists.

## Design Decisions

### D5: Skills never bypass CLI validation where a command exists

An AI agent does not bypass the CLI for operations that already have an Inquiry command. The CLI enforces:

- YAML frontmatter validation
- Filename conventions
- Index.md updates
- Directory structure rules

This means **skills are pure documentation** and commands are the enforcement layer. Where the command surface is still planned rather than implemented, the documentation should say so explicitly instead of pretending the command already exists.

### D6: Humans can use Inquiry without AI

A developer without any AI tool can still use the implemented Inquiry CLI directly. Today that includes commands such as `iq init`, `iq doctor`, `iq host get`, `iq version`, and `iq fsm transition --event <e>`. The AI is an accelerator, not a requirement.

This is critical for trust: the human understands exactly what the tool does because they can use it themselves.

### D7: No new documentation formats

APE follows existing standards:

- **ADRs**: Michael Nygard format (already in `docs/adr/`)
- **Analysis docs**: Markdown with YAML frontmatter (doc-write conventions)
- **Plans**: Markdown with checklists
- **Code docs**: Standard language conventions

The future `iq memory write` command should enforce these standards without inventing new ones. The agent simply automates compliance with established practices.

## Current State

The current Inquiry CLI already enforces the runtime FSM and deployment operations, but the memory-writing command surface remains partly planned rather than fully materialized. The principle is therefore current, while some of the commands that would complete it still belong to future work in [inquiry-cli-spec.md](inquiry-cli-spec.md).

## Mapping: Skill → Command

| Skill | CLI Command | Primary surface | APE State |
|-------|-------------|-----------------|-----------|
| issue-create | `gh issue list`, `gh issue view`, `gh issue create` (via skill protocol) | GitHub issue tracker during bounded IDLE triage | IDLE |
| inquiry-start | `git` workflow + `iq fsm transition --event start_analyze` | Branch preparation, cleanroom scaffolding, and `.inquiry/state.yaml` handoff | IDLE |
| doc-write | `iq memory write` (planned) | `docs/` and other validated documentation surfaces | ANALYZE |
| doc-read | `iq memory query` (planned) | stdout query results and targeted repository reads | ANALYZE |
| planning | (via DESCARTES sub-agent) | `cleanrooms/{task}/plan.md` | PLAN |
| tdd | (domain skill for ADA / EXECUTE) | Source code + tests | EXECUTE |
| api-design | (domain skill for ADA / EXECUTE) | Source code | EXECUTE |
| db-as-code | (domain skill for ADA / EXECUTE) | Migration files | EXECUTE |
| evolution | `gh issue list`, `gh issue create`, `gh issue comment` | Issues in the Inquiry repository | EVOLUTION |
| transition | `iq fsm transition --event <e>` | `.inquiry/state.yaml` | Any |
| (future) status | `iq status` | stdout (derived from docs/) | Any |

## CLI Commands: Existing and Planned

### Existing

Routes marked **command** change something outside the CLI's own files and take
`--plan` / `--apply`; the rest answer on the spot. The line between the two is
drawn in [ADR 0002](../adr/0002-a-query-may-write-what-the-cli-itself-owns.md).

| Command | Description | Kind |
|---------|-------------|------|
| `iq init` | Initialize Inquiry in a repo (`.inquiry/` runtime files) | query |
| `iq doctor` | Verify prerequisites and environment readiness | query |
| `iq host get` | Deploy skills to every detected host | command |
| `iq host clean` | Remove deployed skills from all known hosts | command |
| `iq fsm transition --event <e>` | Execute a declared FSM transition | query |
| `iq implementation start --issue <N>` | Open a cycle: branch, cleanroom, ANALYZE | command |
| `iq upgrade` | Upgrade CLI binary | command |
| `iq version` | Show version | query |
| `iq uninstall` | Remove Inquiry completely | command |

### Planned

| Command | Description |
|---------|-------------|
| `iq memory query` | Index-aware lookup over repository memory |
| `iq memory validate` | Validate memory artifacts and schema expectations |
| `iq memory write` | Create documentation artifacts with validation |
| `iq task` | Wrap issue/PR workflow with FSM-aware prechecks |
