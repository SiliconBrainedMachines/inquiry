# Supplement: local-host experiments on the harness (Exp A) — corrected record

Prepared 2026-06-17/18 to complement `manuscript.tex` (agenticdev-2026). This note
records TWO studies and **a corrected interpretation**: the first was run autonomously
and therefore mis-measures the harness on outcome; the second introduces a conductor and
an abductive-trap task to test the harness's actual purpose.

## Common setup

- Artifact: Inquiry v0.10.0 (OpenCode host + ANALYZE/PLAN verifiability gates).
- Host/model: OpenCode headless; local `ollama/qwen3-coder:30b-16k`. **Reproducibility
  finding:** OpenCode tool-calling with Ollama needs `num_ctx >= 16384`; at the 4K default
  the model behaves as if it has no tools and cannot drive any harness.

## Study 1 — autonomous H vs F, outcome-only, N=30 (PARTIALLY RETRACTED)

Each condition fixed a one-line off-by-one bug 30×; only the final code was scored by a
hidden test. Result: F 29/30 (97%), H 14/30 (47%); H/F overhead ~12x (wall-clock and
tool-calls); H reached END 0/30.

**What stands:** overhead. The ~12x H/F asymmetry replicates and strengthens the paper's
most stable result (4.6–9.9x on Windows/Copilot) on a second host and a local model.

**What is RETRACTED:** the outcome and completion numbers do **not** measure harness value.
The harness is **human-in-the-loop by design** — ANALYZE is a conductor↔harness dialogue,
and ANALYZE→PLAN, PLAN→EXECUTE, EXECUTE→END each require explicit conductor confirmation.
Study 1 ran the harness **autonomously, with no conductor**. The "stuck in ANALYZE / 0-END"
behavior is therefore the *correct* behavior of a system waiting for a conductor that was
never present, not a failure of the method. Comparing autonomous-F (a model's native mode)
to autonomous-H (a system that cannot legitimately advance without a human) is a category
error. The 97%→47% "outcome" gap is an artifact of removing the conductor and is withdrawn.

## Study 2 — conductor-in-the-loop, abductive-trap task (preliminary, qualitative)

The harness exists to govern the *abductive machine*: to stop it acting on thin premises.
That can only be tested on a task where the plausible action is **wrong**, with a conductor
present. Task: `average(nums)` "sometimes crashes — fix it." Hidden requirement (known only
to the conductor, revealed if asked): the data contains `None` values that must be ignored,
and empty/all-None must return `None` (not 0, not crash).

- **Freestyle (F), N=3: 3/3 FAIL**, all with `TypeError: int + NoneType`. The model patched
  its assumption (empty-list guard) and never discovered the `None` requirement — the
  predicted abductive failure: acting on a thin premise without asking.
- **Harness (H), conducted, turn 1 (qualitative):** the model did **not** patch-and-assume.
  Under ANALYZE it **investigated**: wrote a probe, reproduced the failure modes empirically
  (empty → `ZeroDivisionError`; non-numeric → `TypeError`), i.e. it **gathered evidence
  before acting** — the discipline the harness is meant to induce. (It was slow and had not
  yet reached a diagnosis/conductor question when the turn timed out.)

**Reading:** the directional signal is in the harness's favour on the *right* question —
freestyle assumes and fails; the harness makes the same model investigate. This is
preliminary (N small, one task, single turn observed) and not yet an outcome result.

## Honest limits / next steps

- Study 1's overhead is real but contaminated by autonomous spin; overhead is explicitly
  *not* the current priority.
- Study 2 needs full conducted runs to a verified outcome. The local model is too slow for
  tractable turn-by-turn conducting; the plan is to put a **faster model in the
  harness-driven role** while a strong conductor (Claude) answers ANALYZE and approves gates,
  then run complete H-vs-F pairs on abductive-trap tasks.
- Still required before any generalization: operator-isolation arm (Exp B) and a model
  matrix (Exp C).

## One-line status

Overhead replicates (~12x); the autonomous outcome comparison is withdrawn as a category
error; with a conductor and an abductive-trap task, the harness shows the predicted
behavioural difference (investigate vs assume) — to be confirmed with full conducted runs.
