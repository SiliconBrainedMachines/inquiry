# Pre-registered design: does the harness govern the abductive machine?

Protocol fixed BEFORE running, to anchor the paper's empirical core honestly.

## Question

Does an explicit human-in-the-loop harness (Inquiry) prevent the *abductive failures*
of a capable code model — acting on a thin premise, jumping from guess to edit,
hallucinating a fact — that the same model commits in freestyle use?

## Subject and conductor

- **Subject (harness-driven / freestyle):** `qwen3-coder:30b-16k`, local via OpenCode. Fixed across all conditions.
- **Conductor (human role):** automated LLM conductor that (a) answers clarifying questions truthfully from each task's ground-truth, **never volunteering the fix**, and (b) approves a gate iff the produced artifact is adequate. Same conductor policy across all H/ask runs (isolates the harness, not the conductor).

## Task set (8 tasks — varied by failure mode and by construct)

Each task = buggy/underspecified code + a one-line request + a **hidden ground-truth**
(known only to the conductor) + a **hidden test** (the real requirement, never shown to
the subject). The "abductive answer" (the plausible guess) is wrong on the hidden test.

| # | Task | Abductive failure probed | Hidden truth (conductor reveals if asked) | Construct |
|---|------|--------------------------|-------------------------------------------|-----------|
| T1 | `average()` crashes | thin premise | list contains None → ignore; empty/all-None → None | C1 maieutic |
| T2 | `clamp(x,lo,hi)` bug | thin premise | if lo>hi must raise ValueError (not swap) | C1 |
| T3 | `total_price(items)` wrong totals | wrong-cause / patch-the-symptom | quantities arrive as strings; must int-convert (bug is in the data contract, not the sum) | C2 evidence |
| T4 | "dedupe list, keep order" | ambiguous spec | dedupe is case-insensitive for strings | C1 |
| T5 | "use parse_date() in utils.py" | hallucination | parse_date returns None on invalid (does NOT raise); error handling must check None | C2 evidence |
| T6 | `date_range(start,end)` bug | convention assumption | end is EXCLUSIVE per team convention | C1 |
| **K1** | plain off-by-one (`sum_range` inclusive) | — (control, no trap) | none | control |
| **K2** | crashes on empty input | — (control, obvious guard is correct) | none | control |

T1–T6 are traps (harness expected to help). K1–K2 are controls (harness expected to
show **no** outcome advantage, only overhead) — they prove the effect is *specific* to
abductive traps, not generic structure.

## Conditions (per task)

1. **F-headless** (N=3): freestyle, one-shot, cannot ask. The model's native autonomous mode.
2. **F-can-ask** (N=2): freestyle, interactive; if the model asks a clarifying question, the conductor answers (same answers as H). Isolates *forced* (H) vs *optional* (F) clarification.
3. **H-conducted** (N=2): the Inquiry harness, conducted (questions answered, gates approved).

Total: 8 × (3+2+2) = **56 runs**.

## Metrics (outcome-only + behavioural)

- **Primary — outcome:** hidden-test PASS/FAIL (objective; no capture asymmetry).
- **Behavioural — did the subject ASK?** (yes/no, and did the question surface the hidden requirement). Tests the maieutic mechanism directly.
- **Secondary — overhead:** wall-clock, tool-calls (the known ~12× C4 result; not the priority).

## Pre-registered predictions (falsifiable)

- **P1 (traps):** F-headless FAILs most trap tasks (commits the abductive failure).
- **P2 (mechanism):** H-conducted PASSes trap tasks it would otherwise fail, *because* ANALYZE elicits the hidden requirement (the subject asks, conductor answers).
- **P3 (forcing matters):** F-can-ask sits *between* F-headless and H — if the model often does NOT ask even when allowed, then the harness's value is *forcing* the clarification, not merely permitting it.
- **P4 (specificity):** on controls K1/K2, H shows **no** outcome advantage over F (only overhead) — the effect is trap-specific.

A result that would NARROW the thesis: if F-can-ask ≈ H on traps, the harness adds
nothing beyond "let the model ask"; if H fails traps too, ANALYZE doesn't reliably
elicit the requirement.

## Analysis

Per task and pooled: PASS-rate by condition; ask-rate by condition; trap-vs-control
contrast. Report N honestly; treat as a small structured study, not a large-N claim.
Operator-isolation (generic-structure arm) and a model matrix are explicit future work.

## Feasibility note

56 runs, many interactive/conducted, are infeasible to drive by hand. The conductor
**must be automated** (an LLM the runner can call). Options: Haiku via Anthropic API
(best quality, paid) or a local conductor model (free, weaker — adds conductor noise).
The conductor choice is a protocol parameter to fix before running.
