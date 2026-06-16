---
id: benchmark-findings
title: "Benchmark Findings — H vs F (gemma4, local)"
date: 2026-06-15
status: active
tags: [benchmark, findings, evidence-first, gemma4]
---

# Benchmark Findings — Full Inquiry Flow, H (guided) vs F (freestyle)

> Distilled conclusion from the `fullflow-hf-gemma4` benchmark runs. The raw per-run
> session logs under `code/cli/tmp/` were scaffolding for this analysis and have been
> removed (now gitignored). Reproducer of record: `code/cli/scripts/benchmark-fullflow-gemma4.ps1`.
> Numbers below are from the final representative run `fullflow-hf-20260607-041759`
> (model `gemma4:latest`, provider `http://localhost:11434/v1`).

## Evidence (final run, 2026-06-07T04:22)

| Metric | H (Inquiry-guided) | F (freestyle) |
|---|---|---|
| Exit | 124 — **timed out** at 93.76s | 0 — clean exit, ~149s session |
| FSM states reached | ANALYZE + PLAN (real transitions) | ANALYZE only (text-detected) |
| EXECUTE / END reached | no / **no** | no / **no** |
| Tool calls | **22** | **52** |
| Completion token emitted | no (`FULLFLOW_H_OK` never seen) | yes (`FULLFLOW_F_OK`) |

## Findings

- **Neither mode completed the full IDLE→END flow on gemma4.** The end-to-end claim of the
  methodology remains empirically unproven on a local model.
- **Guided (H) was ~2.4× more tool-efficient** (22 vs 52 tool calls) and produced *real* FSM
  transitions (ANALYZE→PLAN with `outcome: allowed`), but the local model was too slow to
  finish inside the 93.76s timeout.
- **Freestyle (F) "completed" only trivially** — it exited and printed its token, but with far
  more tool churn and **no verifiable structured progression** beyond ANALYZE.

## Caveats (honest bounds on the above)

- **Single run, single model** (`gemma4:latest`). Not a distribution.
- **Timeout confound:** H's failure is a *speed* failure (timed out), not necessarily a
  *capability* failure. A faster/more capable local model could change the H result.
- **F state-detection is heuristic:** F bypasses `iq` state commands (`stateCommandSeen: false`),
  so "reached ANALYZE only" undercounts — the F/H state comparison is partly apples-to-oranges.
- The benchmark measures *that the flow ran* (tool counts, states, a literal token), **not the
  verifiable correctness of the work produced** — see the verifiability-gate improvement issues.

## Consequence

This motivates moving the local-harness target from `gemma4` toward a faster, more capable
coder model (`qwen3-coder:30b`, measured ~30 tok/s locally) driven through OpenCode with
Inquiry as the guiding harness.
