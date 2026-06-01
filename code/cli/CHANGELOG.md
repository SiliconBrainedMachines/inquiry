# Changelog
All notable changes to this project will be documented in this file.

The format loosely follows [Keep a Changelog](https://keepachangelog.com/)
and the project adheres to [Semantic Versioning](https://semver.org/).

## [0.7.3]
### Changed
- **EXECUTE cognitive operator**: ADA now replaces BASHŌ as Inquiry's live EXECUTE thinking tool, keeping programming-manifesto cognition separate from the FSM's operational workflow contract
- **Public and architectural surfaces**: README, specs, site pages, and the VS Code END-state fixture now describe the live roster as DEWEY, SOCRATES, DESCARTES, ADA, and DARWIN

### Fixed
- **EXECUTE handoff parity**: prompt assembly, transition contracts, END visibility, doctor integrity checks, and transition coverage now agree that EXECUTE carries `coding-manifesto-review` while END carries no active ape

## [0.7.2]
### Changed
- **Canonical host terminology**: `iq host get` and `iq host clean` are now the primary command surface across the CLI, docs, site, installers, and VS Code integration, while legacy `target` aliases remain supported for compatibility
- **Deployment model clarity**: public docs and architecture now describe the real split between repo-scoped agent install via `iq init` and host-scoped skill deployment via `iq host get`

### Fixed
- **Host module wiring**: the host module builder now routes `iq host get` through the active deployer instead of the cleaner instance

## [0.7.1]
### Changed
- **Release publication guardrail**: the release workflow now keeps GitHub releases in draft until both platform archives are uploaded and explicitly verified, so `latest` can no longer point at a partial CLI release

### Fixed
- **Windows asset resilience for consumers**: the VS Code installer now falls back to the newest published release that actually contains the requested platform asset instead of failing on a transiently incomplete latest release

## [0.7.0]
### Added
- **Harness observability baseline**: `run_trace.yaml`, END pre-PR inspection, and the new observability/eval specs now give the maintainer durable evidence for transitions, sensor runs, retries, host-boundary tool activity, and model-bound prompt assembly cost

### Changed
- **0.6.x harness consolidation closure**: the runtime prompt contract now exposes bounded task identity, evidence-first ANALYZE order, explicit context-policy handoffs, visible sensor stacks, and END-local overhead summaries as the canonical operational model before the 0.7.x line
- **Release closure evidence**: END now refreshes deterministic consistency, completeness, and traceability passes automatically, including minimal attribution across model-bound prompt input, host activity, and remaining remote runtime limits

### Fixed
- **Authority and observability alignment**: source assets, packaged assets, runtime traces, and focused regression coverage now agree on the instruction contract and overhead surfaces that 0.6.x promised

## [0.6.6]
### Added
- **Global help surface**: `inquiry help`, `inquiry --help`, and `inquiry -h` now expose a stable command summary for root commands and module entrypoints, while preserving the status/TUI default for bare `inquiry`

### Changed
- **Authoritative handoff policy visibility**: `inquiry-context` now exposes explicit `retrieval_trigger_rule` and `reread_avoidance_rule` fields for ANALYZE, PLAN, and EXECUTE so later phases can explain when authority may be bypassed and when rereads are harness waste
- **Release QA discipline**: CLI static analysis is now clean again and the packaged binary smoke is verified against the canonical build output and paired asset tree

### Fixed
- **Evidence-first ANALYZE handoff**: `complete_analysis` now blocks when `diagnosis.md` still contains only bootstrap evidence scaffolding, so PLAN cannot inherit an authority artifact with structure but no concrete observed evidence
- **ANALYZE bootstrap alignment**: starting ANALYZE now seeds `diagnosis.md` alongside `index.md` and `confirmations.md`, keeping the required diagnosis structure available from the first cycle bootstrap instead of relying on manual artifact creation

## [0.6.5]
### Changed
- **Instruction contract naming**: live start/end instruction surfaces now use `inquiry-start` and `inquiry-end` across assets, FSM contracts, prompt assembly, and explanatory docs, while preserving `issue-create` as the distinct IDLE triage instruction (#165)

## [0.6.4]
### Fixed
- **Transition text contract visibility**: `iq fsm transition` now exposes `required_role`, `required_instructions`, and `prompt_fragment_id` in human-readable output for instruction-bearing transitions, while keeping long-form instruction summary transport owned by `iq ape prompt` (#208)

## [0.6.3]
### Fixed
- **EVOLUTION cycle-root alignment**: repo-scoped `config.yaml`, metrics files, and repo agent cleanup now resolve from the git root instead of raw cwd, so running Inquiry from nested subdirectories no longer silently skips EVOLUTION or writes cycle artifacts into the wrong tree (#150)
- **DARWIN mutations contract**: EVOLUTION assets and public docs now point to the canonical cycle-local `cleanrooms/<branch>/mutations.md` instead of the stale repo-level `.inquiry/mutations.md` reference (#150)

## [0.6.2]
### Fixed
- **PLAN-owned constructor enumeration**: when a plan phase changes a shared interface or type shape, the PLAN contract now requires enumerating construction sites and naming the search strategy used to find them; this fix lives in PLAN, not in DESCARTES (#139)

## [0.6.1]
### Fixed
- **Windows cycle-root normalization**: `git rev-parse --show-toplevel` paths are now normalized before Inquiry composes cycle-local paths, preventing Windows-only failures in `InquiryState.stateFileFor` and unblocking the Windows release build

## [0.6.0]
### Breaking changes
- **Canonical cycle runtime root**: active cycle state now persists at `cleanrooms/<branch>/.iq.state.yaml`, and cycle mutations now resolve to `cleanrooms/<branch>/mutations.md`; repo-level `.inquiry/state.yaml` is no longer the canonical runtime state surface (#209)
- **`iq init` cycle-local alignment**: init no longer scaffolds repo-level `.inquiry/state.yaml` or `.inquiry/mutations.md`; it keeps project-scoped `.inquiry/config.yaml`, deploys the repo agent, and ensures `cleanrooms/**/.iq.state.yaml` stays ignored (#209)

### Changed
- **Explicit cycle status lifecycle**: cycle state now records `active`, `completed`, or `blocked`, while `IDLE` remains derived; completed and blocked cycles reload as derived `IDLE` instead of persisting `IDLE` directly (#209)
- **VS Code extension cycle resolution**: activation/status handling now follows cleanroom-local cycle resolution and watches `cleanrooms/**/.iq.state.yaml` instead of the old repo-level state path (#209)
- **Metrics scope decision**: metrics surfaces remain at `.inquiry/metrics*.yaml` for now and are explicitly deferred by design until Inquiry has a real consumer, a stable schema, and an explicit scope choice (#209)

## [0.5.3]
### Changed
- **ANALYZE contract ownership**: ANALYZE now owns visibility, participation, required artifacts, and completion proof through the FSM state contract instead of leaking those responsibilities into SOCRATES or generic scheduler assumptions (#180)
- **Runtime installation verification**: `dev-install.ps1` and `dev-install.sh` now verify the `iq` command exposed on PATH instead of only invoking the installed binary directly

### Fixed
- **ANALYZE runtime alignment**: firmware, prompt assembly, analyze bootstrap, and the private write protocol now agree on visible ANALYZE interaction and `confirmations.md` / `confirmations_doc` as the canonical living analysis artifact (#180)
- **APE prompt ownership boundaries**: SOCRATES, DEWEY, DESCARTES, and BASHO now keep methodological identity while dropping the clearest repository-procedure and phase-policy leakage that belongs to the host phase contract (#180)

## [0.5.2]
### Changed
- **EXECUTE startup boundary**: `plan_to_execute` and `execute_continue` no longer inject `issue-start`; the startup protocol remains scoped to the explicit IDLE/DONE handoff into ANALYZE (#181)

### Fixed
- **Scheduler dispatch contract**: firmware dispatch now stays on the generic/current sub-agent path and explicitly forbids deriving `agentName` from `ape.name` (#181)
- **ANALYZE reentry after `_DONE`**: reopening ANALYZE now reinitializes SOCRATES to its initial runnable state instead of leaving the APE stranded at `_DONE` (#181)
- **Clean-state QA bootstrap**: `InquiryState.save` now creates `.inquiry/` before writing `state.yaml`, allowing packaged `fsm transition --event start_analyze` from a truly clean workspace (#181)

## [0.5.1]
### Added
- **Prompt-ready transition instruction summaries**: transition-owned private instruction assets now expose compact runtime summaries for `doc-read`, `doc-write`, `issue-start`, and `issue-end`, so prompt assembly consumes deterministic text instead of raw Markdown (#185)

### Changed
- **FSM prompt fragment contract**: `prompt_fragments` now uses ordered `instructions: [...]` lists, persists `prompt_fragment_id` across transitions, and injects the owning transition summaries into `iq ape prompt` between the state prompt and operational contract (#185)

### Fixed
- **Private instruction boundary**: runtime validation now enforces that transition-owned private protocols resolve from `assets/instructions` while universal thinking tools remain the only assets distributed under `assets/skills` (#185)

## [0.5.0]
### Breaking changes
- `iq init` now deploys `inquiry.agent.md` to `.github/agents/` (repo-scoped, not global).
- `iq target get` no longer deploys the agent — only skills to the specified target.
- `iq doctor` verifies `.github/agents/inquiry.agent.md` (repo-scoped path).
- `iq uninstall` and `iq target clean` now also remove `.github/agents/inquiry.agent.md`.

### Added
- `iq target get --target=[copilot|claude|codex|opencode|gemini]` for exclusive single-target deploy.
- Only one target active at a time — switching targets cleans the previous ones automatically.
- OpenCode adapter: deploys skills to `~/.config/opencode/skills/`.

### Upgrade path
1. `iq uninstall`
2. Install 0.5.0
3. `iq init` (in each repo that uses Inquiry)
4. `iq target get` (to deploy skills to your preferred target)

## [0.4.6]
### Changed
- **Legion routing contract**: the deployed `legion` skill is now explicitly `parallel-first` when isolated parallel sub-agents are available, degrades explicitly to sequential mode when capability is absent or ambiguous, and requires complete fan-in before synthesis (#198)

### Added
- **Legion asset regression coverage**: `assets_test.dart` now asserts the deployed skill text includes the parallel default, degraded fallback trigger, degraded warning, and synthesis wait condition (#198)

### Fixed
- **Routing documentation alignment**: legion research docs now match the verified Copilot runtime behavior and mark the old sequential-only runtime claim as superseded (#198)

## [0.4.5]
### Added
- **Standalone `kritik` skill**: new direct-use SKILL.md for evidential licensing audits over a bounded corpus, with exact evidence spans, explicit warrants, counterevidence search, graded verdicts, and one durable markdown report

### Changed
- **Naming decision**: the epistemic-audit proposal now adopts `kritik` as the canonical skill name, with evidence audit and epistemic audit retained only as explanatory glosses

### Fixed
- **Skill inventory tests**: doctor and asset coverage now include the full distributed skill roster, including `research` and `kritik`, so release validation matches deployed assets

## [0.4.4]
### Added
- **Standalone `research` skill**: new direct-use SKILL.md for staged web investigation with a single durable paper-style markdown report and BibTeX-compatible references (#193)

### Fixed
- **VS Code status bar integration tests**: aligned fixture state files with the flat `.inquiry/state.yaml` contract (`state` / `issue`) so repo-wide extension validation no longer times out (#194)

## [0.4.3]
### Changed
- **Skill renamed**: `Invoke-ExpertCouncil` → `legion` — unified naming for technique and skill (#191)

## [0.4.2]
### Fixed
- **Test suite alignment**: added `Invoke-ExpertCouncil` to hardcoded skill lists in `assets_test.dart` and `doctor_test.dart` to match actual assets (#189)

### Changed
- **PLAN contract**: `plan.yaml` now requires every plan to include a final verification step running the full project test suite (#189)
- **EXECUTE contract**: `execute.yaml` now mandates the full project test suite must pass before any commit, independent of plan.md verification criteria (#189)

## [0.4.1]
### Added
- **Invoke-ExpertCouncil skill**: new standalone SKILL.md implementing the LEGION technique — council of experts via independent sub-agents with isolated context, structured dictamen output, and synthesis persistence as `.md` (#186)

## [0.4.0]
### Changed
- **Prompt-boundary doctrine**: architecture, thinking-tool, lifecycle, finite-state, and target-wrapper docs now describe the validated runtime boundary: APE YAMLs provide thinking-tool identity, FSM state assets provide the phase-owned operational contract, and `iq ape prompt` remains the inspectable assembler (#154)
- **DARWIN exception wording**: docs and firmware now bound DARWIN to abstract-process methodology while EVOLUTION owns issue/metrics repository procedure (#154)

## [0.3.6]
### Added
- **TRIAGE issue creation**: IDLE now uses a dedicated `issue-create` skill for deterministic issue creation or confirmation before operational handoff (#175)

### Changed
- **Clarified IDLE contract**: issue readiness now resets DEWEY inside IDLE/TRIAGE, while explicit start intent alone reaches DONE and triggers `issue-start` plus `start_analyze` (#175)
- **Fast-path ownership**: explicit create-or-select routing now belongs to IDLE/Inquiry CLI orchestration instead of DEWEY's methodology asset (#175, #176)
- **Handoff sequencing**: firmware, docs, and runtime surfaces now agree that TRIAGE produces `issue_selected_or_created`, while `issue-start` produces `feature_branch_selected` before `start_analyze` (#175)

## [0.3.5]
### Changed
- **IDLE operator**: DEWEY is now the active IDLE operator across CLI runtime, prompt resolution, doctor validation, and public roster surfaces (#177)

## [0.3.4]
### Fixed
- **FSM diagram**: TUI now correctly represents the Finite APE Machine — rejection arrows (Analyze→Idle, Plan→Analyze) shown above the main flow; Evolution displayed as a lateral yellow loop with vertical arrows; End→Idle as natural linear continuation (#172)

## [0.3.3]
### Fixed
- **Version check**: semver comparison now uses numeric major.minor.patch ordering instead of string equality — eliminates false "update available" when local version is ahead of remote (#169)

### Changed
- **TUI banner**: redesigned `iq` logo using Unicode half-block characters (`▀▄`) as pixel unit — Gatsby's green light metaphor with green beacon `●` above serif `i` and circular `q` with descender (#169)

## [0.3.2]
### Fixed
- **Firmware v0.3.3**: eliminate false approval gates — scheduler dispatches sub-agents immediately without asking
- **Completion Gate**: separated into explicit Step A (ape done) → Step B (user reviews) → Step C (fsm transition) — prevents collapsing approval into one turn
- **END state**: no longer assigns basho; scheduler executes push + PR directly from instructions
- **EXECUTE state**: instructions now mandate version bump + CHANGELOG as final phase
- **Descartes output**: plan.md must include commit step per phase and version bump as final phase

### Changed
- Firmware description clarified: "User approval only at state completion gates"
- Firmware rules: explicit prohibitions against narration and false approval prompts
- Firmware line-count test threshold raised to 90 (firmware is more explicit by design)

## [0.3.1]
### Added
- **State YAML files** (#160): FSM instructions extracted into `assets/fsm/states/*.yaml` — no more hardcoded strings
- **Doctor asset validation** (#160): `iq doctor` verifies integrity of internal assets (apes, states, skills, contract)
- **Doctor version check** (#160): `iq doctor` and `iq` bare check for newer releases via GitHub API
- **Doctor `--fix`** (#160): `iq doctor --fix` downloads and restores missing assets from GitHub release
- **IDLE doctor-first** (#160): firmware instructs scheduler to run `iq doctor` as first action in IDLE
- **TUI shows Evolution** (#160): diagram displays `[Evolution]` as optional stage
- **Cleanroom auto-creation** (#160): `iq fsm transition --event start_analyze` creates `cleanrooms/<branch>/analyze/index.md` automatically
- **Commit gate** (#160): `iq ape transition --event next_phase` requires at least one commit on the feature branch before advancing to next phase
- **Context injection** (#160): `iq ape prompt` appends fenced YAML `inquiry-context` block with dynamic paths per APE
- **`confirmed.md` template** (#160): `start_analyze` transition also creates `confirmed.md` with pre-filled frontmatter
- **`git_utils.dart`** (#160): shared `getCurrentBranch()` utility for branch resolution

### Changed
- **Firmware v0.3.1** (#160): Outer Loop step 2 runs doctor in IDLE before dispatching sub-agents
- **Skills renamed** (#160): `memory-write` → `doc-write`, `memory-read` → `doc-read` — reflects investigation material, not memory
- **doc-write rewritten** (#160): teaches AI to fill CLI-generated templates, maintain index from inquiry-context paths
- **doc-read rewritten** (#160): index-first protocol reads `index_file` from inquiry-context block
- **SOCRATES prompt** (#160): mandatory `confirmed.md` updates, references inquiry-context for output paths
- **DESCARTES prompt** (#160): reads `analysis_input` and `plan_file` from inquiry-context block
- **Memory as Code spec** (#160): updated to v0.2.0 with Section 11 (Context Injection pattern)

## [0.3.0]
### Changed
- **State encapsulation** (#152): `iq fsm state --json` transitions no longer expose `next_state` — agents see only available events
- **APE sub-FSM encapsulation** (#152): APE transitions no longer expose `to` destination state
- **Mission descriptions** (#152): `instructions` field contains mission objectives, not event names or CLI hints
- **Firmware v0.3.0** (#152): state-agnostic generic dispatch loop — zero state or sub-agent names hardcoded
- **SOCRATES in IDLE** (#152): `socrates-idle` triage sub-agent activates automatically in IDLE state

### Fixed
- **issue-start skill** (#152): uses `iq fsm transition` instead of writing `.inquiry/state.yaml` directly
- **start_analyze prechecks** (#152): requires `issue_selected_or_created` and `feature_branch_selected`

## [0.2.1]
### Added
- **`completion_authority`**: FSM contract and `iq fsm state --json` output now include per-state `completion_authority` field (`user` | `automatic`) — the scheduler reads this to know whether to ask the user or transition immediately
- **END transition filtering**: `iq fsm state` filters END transitions by `evolution.enabled` from `config.yaml` — scheduler sees only one valid path, no choice needed

### Fixed
- **`--issue` flag silently ignored** (#145): `iq fsm transition --event start_analyze --issue 31` now persists issue to `state.yaml`
- **Firmware: Become → Dispatch** (F2, F4): scheduler no longer executes sub-agent work directly; dispatches via `agent` tool
- **Firmware: open-ended approval questions** (F3, F8): restricted to single binary yes/no questions
- **Firmware: over-broad authorization rule** (F6): scoped to `iq fsm transition` and `iq ape transition` only; commits/pushes are autonomous
- **Firmware: EVOLUTION offered as choice** (F9): removed all EVOLUTION knowledge from firmware; `completion_authority: automatic` handles it programmatically
- **Skill: issue-end exposed meta-project** (F7): removed all Dart/Inquiry-specific references; skill is now stack-agnostic

## [0.2.0]
### Added
- **FSM module** (`iq fsm`): renamed from `iq state`, new `iq fsm state --json` command returns full FSM context (state, issue, transitions, APEs, instructions) for machine consumption
- **Effect execution**: `iq fsm transition` now executes CLI-side effects (update_state, reset_mutations, snapshot_metrics, close_cycle, collect_metrics) — skill-side effects reported for agent handling
- **Sub-agent YAMLs**: four versioned APE definitions in `assets/apes/` (socrates, descartes, basho, darwin) with base_prompt + per-state prompts
- **APE prompt assembly** (`iq ape prompt --name <name> [--state <sub_state>]`): reads YAML definition + FSM state, assembles context-aware prompt; auto-reads sub-state from `state.yaml` when `--state` omitted
- **RTOS dual-FSM**: each APE has its own internal FSM with validated transitions, persistence in `state.yaml`, and `_DONE` sentinel for completion
- **APE state** (`iq ape state`): reports active sub-agent's current state and valid internal transitions
- **APE transition** (`iq ape transition --event <e>`): validates and executes internal APE transitions with semantic error codes
- **Auto-activation**: main FSM transitions automatically activate the corresponding APE at its `initial_state`
- **Firmware thin agent**: replaced 554-line monolith `inquiry.agent.md` with ~35-line dual-loop scheduler (outer=FSM, inner=per-APE)
- **InquiryState helper**: centralized read/write of `state.yaml` including `ape:` field with backward compatibility
- **Devcontainer**: `.devcontainer/devcontainer.json` with Dart SDK for Linux e2e testing

### Changed
- **state.yaml format**: now includes `ape: {name, state}` field (backward-compatible with old format)
- **`iq init`**: generates `state.yaml` with `ape: null` field

### Fixed
- **doctor reports "0 skills deployed"** (#145): `Assets` now injected into `DoctorCommand` via `buildGlobalModule`
- **APE domain errors**: `StateError`/`ArgumentError` replaced with `CommandException` using semantic exit codes (conflict=6, notFound=4, validationFailed=7)
- **EXECUTE→END preserves APE state**: same-APE transitions no longer reset sub-state to `initial_state`

## [0.1.3]
### Changed
- **Historical naming boundary** (#134): `APE builds APE` is now preserved only as the historical bootstrap thesis and lore wording from the period when APE was the system's working name; Inquiry remains the current system identity across README, lore, and site bootstrap surfaces
- **Live FSM contract** (#134): the CLI now treats `END` as an explicit runtime state between `EXECUTE` and `EVOLUTION`, with updated transition prompts, TUI output, and distributed FSM assets

### Fixed
- **issue-start skill path drift** (#134): deployed source and build assets now create `cleanrooms/<NNN>-<slug>/analyze/` instead of the stale `docs/issues/` path
- **Asset regression coverage** (#134): `assets_test.dart` now asserts the distributed `issue-start` skill uses `cleanrooms/`
- **FSM verification drift** (#134): transition tests now reuse the live contract asset and cover the `EXECUTE -> END -> EVOLUTION|IDLE` flow explicitly

## [0.1.2]
### Changed
- **Identity unification** (#122): canonical title+subtitle `Inquiry — Analyze. Plan. Execute.` applied uniformly across README, CLI README, agent definition, and site
- **Agent paths** (#122): all `docs/issues/` references in `inquiry.agent.md` updated to `cleanrooms/`
- **Site architecture** (#122): `site/CNAME` removed from repo; `www.si14bm.com` domain transferred to org repo `SiliconBrainedMachines/siliconbrainedmachines`
- **Site content** (#122): `index.html` double-DOCTYPE bug fixed; product site copy updated to Inquiry branding across `index.html`, `agents.html`, `methodology.html`
- **issue-start skill** (#122): `docs/issues/` → `cleanrooms/` path updated

## [0.1.0]
### Changed
- **Rebrand**: APE CLI renamed to Inquiry CLI (`inquiry` binary, `iq` alias)
- Config directory changed from `.ape/` to `.inquiry/`
- Package renamed from `ape_cli` to `inquiry_cli`
- GitHub org: siliconbrainedmachines, repo: siliconbrainedmachines/inquiry

## [0.0.16]
### Added
- **Site validation tests** (`site_test.dart`): 14 tests validating `code/site/` HTML structure, meta tags, install scripts, and secondary pages
- **Triangular version sync test**: `version_sync_test.dart` now checks all three version sources are mutually consistent with actionable error messages

### Fixed
- **CI trigger for site changes** (#103): `ci.yml` now includes `code/site/**` in paths filter so site changes trigger version sync tests
- **Version sync test messages**: Error output now tells the developer exactly which file to fix

## [0.0.15]
### Added
- **Target verification in `ape doctor`** (#96): Verify agent and skill deployment per target
  - Check `.ape/` directory existence with `ape init` remediation suggestion
  - Check agent file existence in `~/.copilot/agents/`
  - Dynamic skill discovery from asset tree (no hardcoded list)
  - Asymmetric verbosity: clean output when OK, detailed errors with remediation
  - Exit code 1 when target checks fail
  - `FileSystemOps` abstraction for testable filesystem access
  - 8 new tests covering Scenarios A-D (all pass, nothing deployed, no init, partial)
  - Cross-platform validated: Windows + Linux (WSL)

## [0.0.14]
### Added
- **EVOLUTION infrastructure** (#68): `.ape/config.yaml` + `.ape/mutations.md` lifecycle
  - `ape init` creates `.ape/config.yaml` with `evolution.enabled: false` default
  - `ape init` creates `.ape/mutations.md` with header template for DARWIN
  - Both files are idempotent (never overwritten if files already exist)
  - `reset_mutations` effect declared in IDLE→ANALYZE and EVOLUTION→IDLE transitions
  - DARWIN prompt updated to include `mutations.md` as input

## [0.0.13]
### Changed
- **Modular structure refactor** (#66): Align ape_cli with modular_cli_sdk conventions
  - Create `lib/modules/{global,target,state}/commands/` directory structure
  - Extract `buildGlobalModule`, `buildTargetModule`, `buildStateModule` builder functions
  - Move 9 command files from flat `lib/commands/` to domain-grouped modules
  - Rewrite `ape_cli.dart` entry point: 117 → 49 lines (3 `cli.module()` registrations)
- **cli_router regression tests**: 7 empty-mount tests added to cli_router

## [0.0.12]
### Added
- **FSM Declarative Transition Contract** (#51): YAML-based state machine contract defining allowed/forbidden transitions and operations
- `ape state transition` command: Programmatic state transitions with precondition validation (issue-first, branch-policy)
- Precondition validation gates: issue_selected, feature_branch_selected checks before irreversible actions
- Fail-closed prompt fragment registry: Explicit error on missing prompt_fragment_id or referenced fragments
- Full-cycle integration tests: Incident replay prevention, full FSM cycle validation (IDLE→ANALYZE→PLAN→EXECUTE→EVOLUTION→IDLE)

### Changed
- IDLE state now supports exploration without issue context, but blocks commitment actions until preconditions validated
- State transitions now use declarative operation definitions (precheck, effects, commit_policy) instead of agent reasoning

## [0.0.11]
### Added
- **Linux support**: PlatformOps abstraction with Windows and Linux implementations
- `install.sh` — Linux installer (`curl | bash`)
- `build.sh` — Linux build script (mirrors `build.ps1`)
- `ci.yml` — CI workflow with `ubuntu-latest` + `windows-latest` matrix
- `ape doctor` now checks VS Code Copilot extension (`code --list-extensions`)
- OS tabs (Windows/Linux) on landing page

### Changed
- FSM rewrite: 6-state model with END state, optional EVOLUTION, retrospective.md, git conventions
- `release.yml` restructured to 3-job pattern: check-version → create-release → build (matrix)
- `ape upgrade` refactored to use PlatformOps (cross-platform archive extraction)
- `ape uninstall` refactored to use PlatformOps (cross-platform env vars and deletion)
- Windows Defender workaround in release.yml now conditional (`if: runner.os == 'Windows'`)

### Fixed
- `ape init` `_relative()` now uses `p.relative()` instead of fragile `replaceFirst`
- Uninstall tests no longer corrupt `dart.exe` (FakePlatformOps injection)

## [0.0.10]
### Fixed
- TUI shows diagram only in text mode (no "version:", "diagram:" field labels)
- Doctor shows formatted checkmarks in text mode (✓/✗) like `flutter doctor`
- Upgrade shows cleaner status message with checkmark

### Changed
- Deps: modular_cli_sdk ^0.2.1 (adds `Output.toText()` for custom text formatting)

### Added
- `Output.toText()` implementations for TuiOutput, DoctorOutput, UpgradeOutput
- 5 new tests for toText() behavior

## [0.0.9]
### Added
- `ape` TUI — displays FSM diagram when invoked without arguments
- Skill `issue-end` — 9-step protocol for completing APE cycles (EXECUTE → EVOLUTION)

### Fixed
- Version inconsistency: unified to single source of truth in `lib/src/version.dart`

### Changed
- `ape doctor` now imports shared version constant
- `ape version` now imports shared version constant

## [0.0.8]
### Added
- `ape doctor` command — verifies prerequisites (ape, git, gh, gh auth, gh copilot)
- Skill `issue-start` — 8-step protocol for transitioning IDLE → ANALYZE
### Changed
- Updated `ape.agent.md` with doctor checks and issue-start skill reference

## [0.0.7]
### Changed
- `ape init` now performs 5 idempotent steps (#21):
  1. Detect `doc/` or `docs/` directory (prefers `docs/`)
  2. Create `{docs}/issues/` for APE cycle artifacts
  3. Add `.ape/` to `.gitignore`
  4. Create `.ape/state.yaml` with IDLE state
  5. Deploy agent to active target (via `ape target get`)
- Rename `docs/ape/` to `docs/issues/` — each APE cycle maps to an issue
### Added
- Future architecture specs moved to `docs/references/`:
  cooperative-multitasking-model, agent-lifecycle,
  signal-based-coordination, cli-as-api

## [0.0.6]
### Fixed
- Revert subsumption (D19): deploy only to Copilot instead of skipping it when Claude exists (#22).
- `target get` now deploys exclusively to `~/.copilot/` (D20: single-target until MVP).
- `target clean` and `uninstall` still clean all 5 target directories for backward compatibility.
### Removed
- `effectiveAdapters` subsumption logic from deployer (D22).

## [0.0.5]
### Added
- `ape uninstall` command (#16).

## [0.0.4]
### Fixed
- `ape upgrade` renames the running executable before extracting the new one (#14).

## [0.0.3]
### Added
- `ape upgrade` command and automatic release on merge (#3).
### Fixed
- `copilot` target is skipped when `claude` coexists (#12).

## [0.0.2]
### Added
- `assets` module with `ape` agent and memory skills.
- Adapter pattern with 5 targets (claude, codex, copilot, crush, gemini).
- Deployer and `ape target get` / `ape target clean` commands.
- `ape version` command.

## [0.0.1]
### Added
- Initial Dart project scaffold with `modular_cli_sdk`.
- `ape init` command.
