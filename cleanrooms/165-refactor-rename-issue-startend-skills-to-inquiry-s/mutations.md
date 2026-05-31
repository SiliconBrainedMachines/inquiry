# Mutations

Notes for DARWIN. Write observations about the current cycle here.
This file is read during EVOLUTION and cleared afterwards.

## 2026-05-31 - Phase 1 inventory and scope lock (#165)

### Phase decision

- Active implementation phase: Phase 1 - Inventory and Scope Lock.
- `cleanrooms/165-refactor-rename-issue-startend-skills-to-inquiry-s/issue.md` is stale for execution. Its github-issue-create acceptance track is superseded by diagnosis decisions D2 and D4; this cycle only renames live `issue-start` / `issue-end` surfaces and preserves `issue-create`.
- Live repository surfaces still expose only the old names. The initial inventory found no live `inquiry-start` or `inquiry-end` hits.

### Inventory commands run

- `rg --files -g "*issue-start*" -g "*issue-end*" code .github docs README.md code/site`
- `rg -n "issue-start|issue-end|inquiry-start|inquiry-end|issue-create" code/cli .github README.md docs code/site`
- Supplemental build scan because committed build mirrors are ignored by the broad content sweep: `rg -n --no-ignore "issue-start|issue-end|inquiry-start|inquiry-end|issue-create" code/cli/build/assets`

### Decision legend

- D1 / rename: exhaustive live rename of `issue-start` and `issue-end`
- D2 / preserve: `issue-create` remains a distinct IDLE/TRIAGE contract
- D3 / freeze: historical, archived, or retrospective material stays unchanged

### Explicit exclusion set

- `cleanrooms/**`
- `code/cli/assets/archive/**`
- `code/cli/build/assets/archive/**`
- Historical release entries in `code/cli/CHANGELOG.md`
- Historical chronology in `docs/timeline.md`
- Backlog/history entries inside `docs/roadmap.md` that name the rename issue itself rather than the live contract
- Sections in `docs/spec/state-encapsulation.md` explicitly marked historical or superseded
- Research dictamina and retrospective naming analysis such as `docs/research/council-synthesis-kritik-skill-name.md`

### Filename inventory

- rename (D1): `code/cli/assets/instructions/issue-start.md`
- rename (D1): `code/cli/assets/instructions/issue-end.md`
- rename (D1): `code/cli/build/assets/instructions/issue-start.md`
- rename (D1): `code/cli/build/assets/instructions/issue-end.md`
- Note: `README.md` appeared in the raw `rg --files` output only because it was passed as a direct path argument, not because its filename matched the old names.

### Content classification

#### rename (D1)

- `README.md` L31,L38 - current IDLE handoff text still exposes `issue-start`.
- `README.md` L97 - live skill roster still lists `issue-start` and `issue-end`.
- `code/site/methodology.html` L54 - public methodology text still names `issue-start`.
- `docs/thinking-tools.md` L28 - current thinking-tool boundary text still names `issue-start`.
- `docs/philosophy.md` L37 - live philosophy summary still names `issue-start`.
- `.github/agents/inquiry.agent.md` L64,L65 - deployment-facing agent text still names `issue-start`.
- `docs/lore.md` L19,L31,L33,L180 - live lore and roster text still name `issue-start`.
- `docs/spec/cli-as-api.md` L60 - current CLI/API contract still names `issue-start`.
- `docs/roadmap.md` L9,L155 - current-contract roster notes still name `issue-start`.
- `code/cli/test/instruction_prompt_loader_test.dart` L111,L112,L130,L131 - loader tests still expect `issue-start` / `issue-end`.
- `docs/spec/cooperative-multitasking-model.md` L74,L76 - current runtime model still names `issue-start`.
- `docs/spec/state-encapsulation.md` L15,L164,L171 - current live-runtime mapping inside this mixed historical note still names `issue-start`.
- `docs/spec/agent-lifecycle.md` L31,L110 - current lifecycle contract still names `issue-start`.
- `code/cli/test/assets_test.dart` L100,L102,L114,L115,L192,L193 - asset-path tests still expect `issue-start` / `issue-end`.
- `code/cli/test/fsm_transition_test.dart` L375,L395 - transition tests still expect `issue-end`.
- `docs/research/legion.md` L56 - live architectural draft still names `issue-start` and `issue-end` in the private-skill roster.
- `docs/architecture.md` L33,L57,L58,L140,L148,L152,L164,L165,L192,L193,L210,L217 - live architecture text and tree still name `issue-start` / `issue-end`.
- `docs/spec/inquiry-cli-spec.md` L1376 - current CLI spec still names `issue-start`.
- `code/cli/test/fsm_state_test.dart` L300 - FSM state test still expects `issue-start`.
- `code/cli/test/ape_prompt_test.dart` L64,L65 - prompt test skill arrays still list `issue-start` / `issue-end`.
- `code/cli/test/fsm_contract_test.dart` L170,L232 - contract tests still expose `issue-start` / `issue-end`.
- `code/cli/test/doctor_test.dart` L115,L116,L396,L397 - doctor tests still list `issue-start` / `issue-end` as deployed skills.
- `code/cli/assets/agents/inquiry.agent.md` L64,L65 - source firmware text still names `issue-start`.
- `code/cli/assets/instructions/issue-start.md` filename,L2,L6 - source instruction filename, frontmatter, and H1 still expose `issue-start`.
- `code/cli/test/firmware_agent_test.dart` L107,L122 - firmware tests still assert `issue-start` text.
- `code/cli/assets/fsm/transition_contract.yaml` L449,L492,L508,L512 - source transition contract still exposes `issue-start` / `issue-end`.
- `code/cli/assets/instructions/issue-create.md` L12,L72 - live `issue-create` protocol still points to `issue-start` by the old name.
- `code/cli/assets/instructions/issue-end.md` filename,L2,L6 - source instruction filename, frontmatter, and H1 still expose `issue-end`.
- `code/cli/assets/fsm/states/idle.yaml` L12 - source IDLE contract still consumes `issue-start`.
- `code/cli/build/assets/instructions/issue-start.md` filename,L2,L6 - committed build mirror still exposes `issue-start`.
- `code/cli/build/assets/fsm/transition_contract.yaml` L449,L492,L508,L512 - committed build transition contract still exposes `issue-start` / `issue-end`.
- `code/cli/build/assets/agents/inquiry.agent.md` L64,L65 - committed build firmware text still names `issue-start`.
- `code/cli/build/assets/instructions/issue-create.md` L12,L72 - committed build `issue-create` protocol still points to `issue-start`.
- `code/cli/build/assets/fsm/states/idle.yaml` L12 - committed build IDLE contract still consumes `issue-start`.
- `code/cli/build/assets/instructions/issue-end.md` filename,L2,L6 - committed build mirror still exposes `issue-end`.

#### preserve (D2)

- `README.md` L97 - `issue-create` remains part of the live skill roster and must stay distinct.
- `docs/spec/cli-as-api.md` L59 - CLI/API table correctly preserves `issue-create` as the IDLE/TRIAGE skill.
- `docs/spec/cooperative-multitasking-model.md` L66,L71 - current runtime model correctly preserves `issue-create` in DEWEY/TRIAGE.
- `docs/spec/state-encapsulation.md` L15,L130 - mixed historical note still contains current live-runtime mapping where `issue-create` remains distinct.
- `docs/spec/agent-lifecycle.md` L31,L49 - current lifecycle contract correctly preserves `issue-create`.
- `code/cli/test/assets_test.dart` L107,L109,L191 - asset tests correctly preserve `issue-create` while separating it from start/end assets.
- `docs/research/legion.md` L16,L56 - live architectural draft correctly preserves `issue-create` as a private skill distinct from start/end.
- `docs/architecture.md` L33,L56,L152,L163,L191,L209 - live architecture text and tree correctly preserve `issue-create`.
- `docs/spec/inquiry-cli-spec.md` L1375 - current CLI spec correctly preserves `issue-create` in IDLE.
- `code/cli/test/fsm_state_test.dart` L298 - FSM state test correctly preserves `issue-create`.
- `code/cli/test/ape_prompt_test.dart` L63,L973,L977,L1036 - prompt tests correctly preserve `issue-create`.
- `code/cli/test/fsm_contract_test.dart` L99,L234 - contract tests correctly preserve the `issue-create` boundary.
- `code/cli/test/doctor_test.dart` L114,L388,L404,L412,L416 - doctor tests correctly preserve `issue-create` as a distinct deployment/runtime requirement.
- `code/cli/assets/instructions/issue-start.md` L137 - source `issue-start` doc correctly references separate `issue-create` ownership.
- `code/cli/assets/instructions/issue-create.md` L2,L6 - `issue-create` filename metadata and title remain correct and unchanged.
- `code/cli/assets/fsm/states/idle.yaml` L7,L9,L35 - source IDLE contract correctly preserves `issue-create`.
- `code/cli/build/assets/instructions/issue-start.md` L137 - committed build `issue-start` mirror correctly references distinct `issue-create` ownership.
- `code/cli/build/assets/instructions/issue-create.md` L2,L6 - committed build `issue-create` metadata and title remain correct and unchanged.
- `code/cli/build/assets/fsm/states/idle.yaml` L7,L9,L35 - committed build IDLE contract correctly preserves `issue-create`.

#### freeze (D3)

- `docs/timeline.md` L90 - historical timeline entry.
- `docs/roadmap.md` L78 - backlog item naming the rename issue itself, not the live runtime contract.
- `docs/research/council-synthesis-kritik-skill-name.md` L78 - research dictamen example of prior skill naming.
- `code/cli/CHANGELOG.md` L45,L54,L130,L133,L135,L197,L211,L242,L243,L252,L348,L360,L362 - historical release notes and examples.
- `code/cli/assets/archive/inquiry.agent.md.legacy` L45,L190,L231 - archived legacy firmware.
- `code/cli/assets/instructions/issue-end.md` L110 - historical example commit message inside a live instruction file; freeze this section while renaming the rest of the file.
- `code/cli/build/assets/archive/inquiry.agent.md.legacy` L45,L190,L231 - archived build legacy firmware.
- `code/cli/build/assets/instructions/issue-end.md` L110 - historical example commit message mirrored in build output.

### Phase 2 narrow test slice selected from the inventory

- `code/cli/test/instruction_prompt_loader_test.dart` - `loader.load(...)` contract for start/end summaries.
- `code/cli/test/assets_test.dart` - source asset paths and deployed asset list.
- `code/cli/test/ape_prompt_test.dart` - seeded skill rosters and prompt text.
- `code/cli/test/fsm_contract_test.dart` - runtime protocol exposure and start/end descriptions.
- `code/cli/test/fsm_state_test.dart` - state instruction arrays.
- `code/cli/test/fsm_transition_test.dart` - `requiredInstructions` expectations for END.
- `code/cli/test/firmware_agent_test.dart` - operator-facing firmware text.
- `code/cli/test/doctor_test.dart` - deployed-skill roster and missing-skill diagnostics.

### Phase 1 closure check

- No hit remains unclassified.
- No `issue-create` hit is scheduled for rename.
- Mixed files are classified section by section through separate D1/D2/D3 entries.
- The exclusion set is explicit enough to explain every expected residual old-name hit after live renames.
