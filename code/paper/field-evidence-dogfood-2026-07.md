# Field evidence: dogfooding Inquiry on two real requirements (2026-07)

Companion to the pre-registered controlled study
([exp-design-abductive-governance](exp-design-abductive-governance.md)). That study asks
whether the harness governs the *abductive machine* of a **weak** local model (qwen3-coder:30b)
on synthetic traps. This note records the complementary arm: **naturalistic field evidence**
of the same methodology driving a **capable** model (Claude) end-to-end on two real, messy,
multi-system requirements. N is small and uncontrolled by design — it is a case record of the
harness *in production use*, not a claim of effect size.

## Cases

- **Impulsa — "ticket purchase from credit history"** (`--lang es`): a full feature; 2 user
  stories, 23 AC; issues fanned out to `impulsa_{db,api,app}` + an external ERP prerequisite.
  Specification phase closed green; handed to a Dev.
- **Socia — "observaciones-ahorro-canasta"** (`--lang es`): a 3-observation refinement of an
  existing screen, taken **all the way through development**. Specification → 2 issues → 2 PRs,
  every AC covered by a passing test. Cross-**org**: the app fix lives in `bitstream-sac/socia`,
  the API fix in `cacsi-dev/impulsa_api`.
- **modular_cli_sdk — "native help command"** (`--lang en`): a requirement on the *dependency*
  Inquiry's own CLI is built on. 3 user stories, 15 AC, one issue, one PR. Run with Inquiry
  v0.19.0 against a foreign repo — the first time the tool was pointed at a package it does not
  live in.

All three requirements evolved the tool itself: Inquiry went **0.15.0 → 0.20.0**, each release
driven by a concrete friction surfaced by real use — not by speculation.

## Observations relevant to the thesis

1. **Specification is a *definedness* gate, and it is separated on purpose.** The FSM
   (ANALYZE → PLAN → EXECUTE) is for **complex** problems; the specification phase is lifted out
   of it because its job is prior and different: decide whether a problem is *defined enough to
   build*. `specification_ready` mechanically enforces that (commitment date, ≥1 Given-When-Then
   AC per story, explicit scope, ≥1 traced issue). ANALYZE/PLAN/EXECUTE are **TDD applied**; for a
   small, already-defined change we ran the TDD essence directly without the full state machine.
   The lesson is not "the FSM is overhead" — it is that **definedness and construction are
   separate concerns, and the tool models them as separate stages.**

2. **A stable 3-layer model held under stress.** Specification = the business contract in domain
   language (DDD); issues = the technical layer (where + how, with code handles); tests =
   verification (one per AC). Under two real requirements — including cross-repo and cross-org
   fan-out — the boundary never leaked: the spec stayed business-level, the technical decisions
   and code handles stayed in the issues.

3. **The traceability spine closed end-to-end.** requisition → AC → issue (`covers:`) → test.
   In Socia this was literal: from an annotated screenshot to a green gate to two PRs where
   **every one of 7 AC is verified by a passing test**. The discipline lived in the tool
   (gate + template + controlled vocabulary), not in the operator's memory.

4. **"The story is the actor's; the issue points at the repo."** A user story is written in the
   voice of whoever receives the value (the socia member), independent of which repo implements
   it. That decoupling is what let one requirement span two organizations without deforming the
   method — the same shape as an external-ERP prerequisite.

5. **Evidence-over-inference repeatedly pre-empted abductive failure — the paper's exact
   mechanism, observed with a capable model.** Concrete instances this cycle:
   - *Thin-premise / stale belief:* the operator "remembered" the amount-colour was already
     fixed; execution against the code showed it was not (single commit, no sign logic). Verified
     before acting.
   - *Guess-to-edit:* both change sites were pinpointed by evidence (`detalle_canasta.dart:263`,
     `cuenta.controllers.js:157`) **before** any edit.
   - *Hallucinated risk assessment:* the "is this a breaking change?" question was answered by
     `grep` (blast radius = one branch; zero other consumers of the literal), not by "probably
     fine." This is the abductive-governance thesis operating on a strong model, self-imposed via
     the methodology rather than forced by a weak-model harness.

6. **CLI = hands, model = brain, empirically.** The gate is mechanical (is the field present?).
   The thinking — Deweyan investigation, authoring, the content-vs-presentation layer decision —
   was the model's. The tool never reasoned; it enforced completeness and left a reviewable trail.

7. **Use is a discovery procedure that tests and review are not.** The `modular_cli_sdk` case is
   the sharpest datum in this record, because the defects it surfaced were *unreachable* by the
   two methods a normal project would trust. The SDK was **already published**, with **102 green
   tests** and a passing review. Integrating it into a real consumer — Inquiry's 18 commands —
   surfaced **three defects in three days**, each shipped upstream as a release:
   - **0.3.1** — the bare invocation (`iq`) hijacked a *registered root route*. The SDK's own
     `example/` had no root command, so no test could see it. Found the moment a real CLI whose
     bare form is a TUI took the dependency.
   - **0.3.2** — an **empty** parameter contract was inexpressible (`params: []` was
     indistinguishable from "declares nothing"), so a zero-option command could not be enforced.
     This is the *original* reported bug: `iq init --host claude` accepted a parameter it does not
     have and exited 0 — "I ran something, but it did something else."
   - **0.3.3** — a command with positionals could not answer `--help` without being handed the
     very argument the user was asking about (`iq specification new --help` → exit 64).
   None of the three is a coding error visible in isolation; each is a **contract error at the
   integration boundary**, and the boundary is the only place it exists. The SDK's tests were green
   *and correct* — they tested the CLI the example described, not the CLI a user builds. This is
   the empirical form of the paper's own commitment: **evidence over inference**. A green suite is
   inference about a system's behaviour; use is evidence of it. Dogfood is not a virtue signal
   here, it is the measuring instrument.

8. **The requirement propagated the right way: upstream, not around.** The requisition targeted a
   *dependency*, and the three defects were fixed **in the SDK and published**, not patched around
   in the consumer. Two of them (0.3.2, 0.3.3) then became enforced behaviour for every command in
   Inquiry v0.20.0 — an unknown parameter now *fails* instead of being silently accepted. The
   traceability spine held across the repository boundary (spec → AC → issue in *another* repo →
   test → release), which is the same shape as the cross-org Socia case and the external-ERP
   prerequisite in Impulsa: the method does not require the work to live where the story does.

## Honest limitations and open items (antifragility inputs)

- **Field N is tiny and uncontrolled.** These cases show the method *delivering*; they do not
  measure it against a freestyle baseline. That is what the controlled qwen study is for. The two
  arms answer different questions: *does the harness rescue a weak model from traps* (controlled)
  vs *does the methodology deliver coherent, traceable work with a strong model* (field).
- **`requisitions/` will accumulate.** Over time the per-requirement artifact directory grows and
  may become noise. Needs an archival / lifecycle answer (open design question).
- **`iq issue publish --plan` should validate labels** against the target repo and, when one is
  missing, print the `gh label create …` command to fix it (surfaced twice; currently fails late
  at `--apply`).
- **Capability floor.** The method's value is realised *with* strong reasoning. Local-model runs
  remain gated on a future version capable enough to clear the abductive traps; until then the
  live dogfood runs on capable models, and CLI improvements continue in parallel.

## One-line takeaway

Across three real requirements — one of them against the tool's own dependency — Inquiry behaved
as a **coherent methodology for evidence-based, traceable delivery** whose separation of
*definedness* (specification) from *construction* (TDD-applied FSM) held; and in the SDK case the
methodology *found what a green test suite could not*, which is the claim an agentic-development
paper must substantiate: not that the harness produces confidence, but that it produces evidence.
