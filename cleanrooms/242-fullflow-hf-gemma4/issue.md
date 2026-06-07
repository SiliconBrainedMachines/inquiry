---
id: issue
issue: "242"
branch: 242-fullflow-hf-gemma4
date: 2026-06-06
---

# Issue #242

## Goal\nCreate a reproducible benchmark that compares Inquiry methodology mode (H) vs freestyle mode (F) on a full flow: IDLE -> ANALYZE -> PLAN -> EXECUTE -> END using local gemma4 via Copilot CLI.\n\n## Acceptance\n- A script runs both H and F against the same prepared issue/branch context.\n- The benchmark captures tool-call counts, durations, final FSM state, and whether the run reached END.\n- Documentation explains how to reproduce the comparison.\n
