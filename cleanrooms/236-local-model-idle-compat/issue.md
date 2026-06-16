---
id: issue
issue: "236"
branch: 236-local-model-idle-compat
date: 2026-06-06
---

# Issue #236

## Summary\nLocal model runs (e.g., gemma4 via Ollama) can derail in IDLE triage due to command/event drift:\n- scheduler attempted unsupported gh issue list --no-defaults\n- scheduler attempted unknown FSM event strings while transitioning from IDLE\n\n## Scope\nApply a minimal, deterministic fix in CLI instruction assets so local and cloud models follow valid commands/events in IDLE.\n\n## Acceptance Criteria\n- IDLE guidance explicitly requires using only events returned by iq fsm state --json.\n- IDLE guidance removes obsolete wording that suggests unknown event names.\n- issue-create protocol documents a strictly compatible gh issue list invocation and warns against unsupported flags.\n- A real local-model CLI run reaches iq fsm transition --event start_analyze --issue <N> without precondition mismatch when issue is provided.\n\n## Non-goals\n- No merge required for this validation PR.\n
