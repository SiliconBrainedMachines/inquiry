# Contract: SkillBuilder + generated skill

## SkillBuilder API (mirrors AgentBuilder)

```dart
class SkillBuilder {
  SkillBuilder(Assets assets);
  /// Assemble the SKILL.md content for one phase from its contract.
  String build(String phase); // phase ∈ {analyze, plan, execute}
  /// All phase skill names this builder produces.
  List<String> get phaseSkillNames; // [iq-analyze, iq-plan, iq-execute]
}
```

- Reads: `fsm/states/<phase>.yaml`, `apes/<operator>.yaml`, `artifacts/<artifact>.template.md`.
- Returns: a complete `SKILL.md` string (frontmatter + body). Throws if a required contract asset is missing.
- Deploy integration: `HostDeployer` writes `<skillsDir>/iq-<phase>/SKILL.md` for each phase, next to the static skills, during `iq host get`.

## Generated SKILL.md — required sections (every phase)

1. Frontmatter: `name: iq-<phase>`, `description:` (one line).
2. `## Goal` — from `fsm/states/<phase>.yaml` instructions.
3. `## Steps` — ordered `iq` commands (mechanics); "use only events `iq fsm state` lists".
4. `## Artifact` — embedded `artifacts/<artifact>.template.md` (the shape).
5. `## Done when` — checklist: required artifact written, shape rules met (e.g. handles), `iq fsm transition --event <gate>` exits 0.

## Acceptance (tests)

- `build('analyze')` output contains: `name: iq-analyze`, `iq fsm state`, the diagnosis template's section headers, `complete_analysis`, a Done-when checklist.
- Builder throws on a missing contract asset.
- The embedded diagnosis template, written to a cycle, **passes** `complete_analysis` (template ⇄ gate consistency).
- `iq host get` deploys `iq-analyze/SKILL.md` (+ plan/execute) into the host skills dir.
