# Tasks: iq-* phase skills

**Input**: Design documents from `/specs/001-iq-phase-skills/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/skillbuilder.md
**Tests**: included (requested by spec — gate consistency + the SC-003 experiment).
**Organization**: by user story; US1 is the MVP.

## Format: `[ID] [P?] [Story] Description`
- **[P]**: parallelizable (different files, no dependency). Paths are repo-relative.

---

## Phase 1: Setup

- [ ] T001 Create `code/cli/assets/artifacts/` directory for first-class artifact templates (research R1).

## Phase 2: Foundational (blocking — no story can start until done)

- [ ] T002 Create `code/cli/lib/hosts/skill_builder.dart`: `SkillBuilder(Assets)` with `build(String phase)` and `phaseSkillNames` per `contracts/skillbuilder.md`; reads `fsm/states/<phase>.yaml`, `apes/<operator>.yaml`, `artifacts/<artifact>.template.md`.
- [ ] T003 [P] In `skill_builder.dart`, encode the phase→operator→artifact→gate map (data-model.md): analyze→socrates→diagnosis.md→complete_analysis; plan→descartes→plan.md→approve_plan/go_execute; execute→ada→(code)→finish_execute.
- [ ] T004 [P] Create `code/cli/test/skill_builder_test.dart` scaffold.

**Checkpoint**: builder + test harness exist.

---

## Phase 3 (US1, P1): `iq-analyze` end-to-end — MVP

**Goal**: a user/weak model takes a cycle from ANALYZE to a passing `complete_analysis` using only `/iq-analyze`.
**Independent test**: deploy, follow `/iq-analyze`, gate exits 0 — no scheduler agent.

- [ ] T005 [P] [US1] Author `code/cli/assets/artifacts/diagnosis.template.md` — Evidence/Hypotheses/Constraints/Open Questions with the "every Evidence bullet carries a re-checkable handle" rule, consistent with the `complete_analysis` gate.
- [ ] T006 [US1] Implement `SkillBuilder.build('analyze')`: assemble `SKILL.md` (frontmatter `iq-analyze`; `## Goal` from `analyze.yaml`; `## Steps` = `iq fsm state` → `iq ape prompt --name socrates` → write diagnosis → `iq fsm transition --event complete_analysis`, "use only events `iq fsm state` lists"; `## Artifact` = embedded template; `## Done when` checklist). Core ≤ ~40 lines (SC-004).
- [ ] T007 [US1] Wire `HostDeployer` to write `<skillsDir>/iq-analyze/SKILL.md` (via SkillBuilder) during `iq host get`, beside the static skills.
- [ ] T008 [US1] Test (`skill_builder_test.dart`): `build('analyze')` contains `name: iq-analyze`, `iq fsm state`, the diagnosis template headers, `complete_analysis`, and a Done-when checklist; core line count ≤ budget.
- [ ] T009 [US1] Test: the `diagnosis.template.md`, written into a real cycle, **passes** `iq fsm transition --event complete_analysis` (template ⇄ gate consistency).
- [ ] T010 [US1] Test/verify: `iq host get` deploys `iq-analyze/SKILL.md` into the host skills dir (real-binary check).

**Checkpoint**: `/iq-analyze` shippable on its own.

---

## Phase 4 (US2, P2): `iq-plan` + `iq-execute`

- [ ] T011 [P] [US2] Author `code/cli/assets/artifacts/plan.template.md` (executable-check rule, per-phase), consistent with the PLAN→EXECUTE gate.
- [ ] T012 [US2] Implement `SkillBuilder.build('plan')` and `build('execute')` (reusing the shared assembly from T006).
- [ ] T013 [US2] Deploy `iq-plan` + `iq-execute` (extend T007 to all `phaseSkillNames`).
- [ ] T014 [P] [US2] Tests: plan/execute skill content + `plan.template.md` ⇄ PLAN gate consistency.

**Checkpoint**: full manual ANALYZE→PLAN→EXECUTE path.

---

## Phase 5 (US3, P2): no-drift (generated from contracts)

- [ ] T015 [US3] Test: editing a contract (e.g. add a required section to `analyze.yaml`) changes `build('analyze')` output with **no** manual skill edit (SC-005 / Principle V).

---

## Phase 6: Polish & cross-cutting

- [ ] T016 [P] **SC-003 experiment**: conducted run — same task on qwen-30b, once driving the scheduler agent unaided, once following `/iq-analyze`; measure `complete_analysis` pass rate; record evidence (per Constitution: evidence, not inference).
- [ ] T017 [P] CHANGELOG entry + version bump (`pubspec.yaml`/`version.dart`/site badge) + `quickstart.md` link from docs.
- [ ] T018 `dart analyze` clean + full `dart test` green + build & deploy verify with the real binary; open PR.

---

## Dependencies & order
- Phase 2 (T002–T004) blocks all stories.
- **US1 (P1)** is the MVP and must land first; **US2** reuses US1's assembly; **US3** is a test over the builder; Phase 6 polish last.
- Parallel within a story: `[P]` tasks touch different files (e.g. T005 template vs T008/T009 tests).

## Implementation strategy
Ship **US1 (`/iq-analyze`) as the first PR** (MVP — proves the 3-layer pattern + template⇄gate consistency + the SC-003 experiment on the hardest phase). Then US2 (plan/execute) and US3 (no-drift) in a follow-up.
