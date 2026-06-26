# Specification Quality Checklist: iq-* phase skills

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-06-25
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs) — SkillBuilder/codegen deferred to plan
- [x] Focused on user value and business needs (weak-model/manual operability)
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable (gate exit codes, crossing rate, read-time)
- [x] Success criteria are technology-agnostic
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified (wrong phase, no cycle, repeated gate failure)
- [x] Scope is clearly bounded (3 phases; no start/end/idle/end/evolution skills in v1)
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

- Passed on first iteration. Ready for `/speckit-plan`.
- One scope decision worth confirming at plan time: SC-003 (weak model passes gate more often *with* the skill) is the project's real hypothesis — the plan should include an experiment to measure it.
