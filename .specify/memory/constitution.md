<!--
Sync Impact Report
- 2.0.0 (2026-06-26): MAJOR — Principle I redefined from "CLI is the brain;
  model is the hands" to "Model is the brain; CLI is the tool/hands" (the CLI
  does the established mechanics — scaffold structure, generate templates, run
  gates — so a capable model/human can think). Driven by the SC-003 evidence
  (local 12GB model insufficient) + pivot to capable-model/human use.
- Version change: (template) → 1.0.0 (initial ratification)
- Principles defined: I. CLI Is the Brain; II. The Model Never Decides;
  III. Evidence Over Inference (NON-NEGOTIABLE); IV. Artifact-as-Function;
  V. Structure Over Prose; VI. Accessible Models Are the Target
- Added sections: Quality Gates; Development Workflow; Governance
- Templates reviewed: plan-template.md (Constitution Check aligns ✅),
  spec-template.md (no mandatory-section changes ✅),
  tasks-template.md (no principle-driven task types to add ✅)
- Deferred TODOs: none
-->

# Inquiry Constitution

Inquiry is a methodology tool: a multi-layer finite-state-machine CLI (`iq`) that
governs an AI coding agent through ANALYZE → PLAN → EXECUTE with verifiable gates.
These principles are non-negotiable and supersede convenience.

## Core Principles

### I. The Model Is the Brain; the CLI Is the Tool (Hands)

The model (or the human) is the **brain** — it does the thinking: investigate,
diagnose, plan, judge, write the actual content. The `iq` CLI is the **tool /
hands** — it does the established, repetitive mechanics of the method so the
brain never spends judgment on plumbing: scaffold the cleanroom folder
structure, generate the artifact templates on disk, track FSM state, run the
gates, and tell you the next command. The CLI prescribes and verifies; it does
not think. **Rationale**: the harness's value is realized with a capable model
or a human (a 12GB-GPU local model tops out ~46% — see the experiment record);
the tool should remove drudgery, not replace the brain. (This supersedes the
v1.0.0 "CLI is the brain" framing, which over-rotated toward making an
unreliable weak model usable; the tool still computes the next action and the
gates, but as guidance for a thinking brain, not as a substitute for one.)

### II. The Model Never Decides — Decisions Go to the Human

LLM choices are unreliable, and decisions carry consequences and require
responsibility. Wherever a real choice exists (a `completion_authority: user`
gate, or more than one forward path), the system MUST surface the information and
hand the decision to a human; it MUST NOT decide on the human's behalf. The
model's job at a decision point is to gather and present, not to choose.

### III. Evidence Over Inference (NON-NEGOTIABLE)

Claims MUST be verified by execution, never asserted from model knowledge or
reasoning. Every diagnosis/plan claim MUST carry a re-checkable handle (a
`file:line`, a URL, or an inline-code command/test id) so it can be reopened and
verified. The system distrusts the model's confidence and trusts only what a gate
can re-check. "Plausible" is not "verified."

### IV. Artifact-as-Function

Each phase and each dispatched sub-agent is a function whose inputs and outputs
are `.md` files on disk — not the model's context or memory. An operator's
deliverable IS writing its phase artifact (e.g. `diagnosis.md`) before returning;
returning prose without writing the artifact is a failure. State and handoffs
live in files, so the system does not depend on a model remembering anything
between turns.

### V. Structure Over Prose

Required behavior MUST be enforced by the FSM/CLI — gates, computed events, the
prescribed `next`, verify-before-advance — not by firmware text the model can
ignore. When the model misbehaves, the fix is a structural one in the CLI, not a
longer instruction. The firmware stays thin; detail lives in on-demand,
contract-generated artifacts.

### VI. Accessible Models Are the Target

Inquiry exists to make a simple, accessible model (one the general public can buy
or afford to run) work reliably — a capable model does not need the harness. Every
design MUST be evaluated by whether a weak model can follow it, and that judgment
MUST be backed by evidence (conducted runs), not assumption. Testing only with a
strong model measures the wrong thing.

## Quality Gates

Trust transfers to the verifier, not the phase. Every phase handoff is gated by
the CLI, which re-checks the produced artifact and returns an actionable error.
A failed gate MUST NOT be retried unchanged (no blind retries): the operator
re-does the artifact to address the reported error, then the transition is
retried. A cycle that only emits a success token without verifiable artifacts is
not done.

## Development Workflow

Work proceeds one issue → PR → merge at a time, following ANALYZE → PLAN →
EXECUTE with strict QA: `dart analyze` clean and the full test suite green before
any release; behavior verified end-to-end with the real binary, not only unit
tests. Test-Driven Development is the default (a failing test as each phase's
acceptance check). All issues, PRs, code, and documentation are written in
English. Deployment is a global tool install (agent + skills per host, additive)
separate from the per-repo workspace (`iq init`). Findings are recorded as
evidence (gate outputs, conducted-run data), never as inference.

## Governance

This constitution supersedes other practices when they conflict. Amendments are
made by editing this file with a Sync Impact Report and a semantic-version bump
(MAJOR: principle removal/redefinition; MINOR: new principle/section; PATCH:
clarification). Every PR and review SHOULD verify compliance with these
principles; deviations MUST be justified in the PR. The `inquiry` agent firmware
and the `iq-*` phase skills are the runtime expression of these principles and
MUST stay consistent with them.

**Version**: 2.0.0 | **Ratified**: 2026-06-26 | **Last Amended**: 2026-06-26
