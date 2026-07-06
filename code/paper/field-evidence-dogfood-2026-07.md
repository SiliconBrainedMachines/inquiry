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

Both requirements evolved the tool itself: Inquiry went **0.15.0 → 0.18.0 (8 releases)**, each
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

Across two real requirements, Inquiry behaved as a **coherent methodology for evidence-based,
traceable delivery** whose separation of *definedness* (specification) from *construction*
(TDD-applied FSM) held — and it is earning that design by use, which is precisely the claim an
agentic-development paper must substantiate.
