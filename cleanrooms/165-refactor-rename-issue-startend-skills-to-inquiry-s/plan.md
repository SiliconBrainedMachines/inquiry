---
title: "Plan: Rename issue-start / issue-end to inquiry-start / inquiry-end"
status: active
tags: [plan, rename, instructions, nomenclature]
---

# Plan: Rename issue-start / issue-end to inquiry-start / inquiry-end

**Issue:** #165  
**Decision Reference:** [diagnosis.md](analyze/diagnosis.md)  
**Analysis Index:** [index.md](analyze/index.md)

**Scope note:** [issue.md](issue.md) still lists a separate quoting and github-issue-create skill track, but the approved diagnosis explicitly excludes that concern. This plan follows diagnosis decisions only: exhaustively rename live-code `issue-start` and `issue-end` surfaces to `inquiry-start` and `inquiry-end`, keep `issue-create` unchanged, and leave historical artifacts frozen.

## Hypothesis

If execution first classifies every old-name hit as live, preserved, or historical, then turns the shared instruction-contract tests RED, then renames the canonical source and build/runtime instruction identifiers, and only then updates live explanatory surfaces, the repository will reach zero live `issue-start` and `issue-end` exposures without changing behavior or overreaching into `issue-create`.

## TDD Applicability

- Phase 1 is not a RED -> GREEN phase; it establishes the verified inventory, freeze set, and narrow test slice that later phases depend on.
- Phase 2 is a mandatory RED phase: rename-sensitive tests change first, runtime/build assets stay untouched, and the selected test slice must fail specifically on old-name contract drift.
- Phase 3 is the matching GREEN phase: the exact same narrow test slice from Phase 2 must pass only after runtime/build emitters and consumers are renamed.
- Phase 4 is not a separate TDD phase; verification is search-driven after the runtime contract is already GREEN, with mixed current/historical prose handled section by section.
- Phase 5 is the closure gate, not a new design phase: rerun narrow checks only if later prompt/help edits changed asserted text, then require the full suite `cd code/cli && dart test` as the terminal proof.

## Phase Dependencies

- Phase 2 depends on Phase 1.
- Phase 3 depends on Phase 2.
- Phase 4 depends on Phase 3.
- Phase 5 depends on Phases 1 through 4.

## Shared-Name Enumeration Applicability

- The constructor/consumer enumeration obligation applies directly in Phases 2 and 3 because those phases rename shared live instruction identifiers that tests, loaders, assets, and FSM contracts construct or consume.
- Phases 1, 4, and 5 do not change a shared type shape or identifier-construction surface; they inventory, update explanatory text, and validate closure, so search coverage there is verification-oriented rather than constructor-edit-oriented.

## Phase 1: Inventory and Scope Lock

**Entry criteria:**

- Diagnosis decisions in [analyze/diagnosis.md](analyze/diagnosis.md) are accepted as authoritative.
- Execution understands that this is a nomenclature refactor, not a behavior change.
- Execution understands that `issue-create` and the quoting problem are explicitly out of scope for this issue.

**Dependencies:** None beyond the approved diagnosis and issue boundary already captured in the entry criteria.

**Execution steps:**

- [ ] Run a filename inventory for live surfaces that still expose the old names.
  - Search strategy: `rg --files -g "*issue-start*" -g "*issue-end*" code .github docs README.md code/site`
- [ ] Run a content inventory across live repository surfaces.
  - Search strategy: `rg -n "issue-start|issue-end|inquiry-start|inquiry-end|issue-create" code/cli .github README.md docs code/site`
- [ ] Classify every hit into exactly one bucket before any rename work starts.
  - `rename`: active runtime, test, prompt, site, or maintainership-facing surface that must adopt `inquiry-start` or `inquiry-end`
  - `preserve`: live `issue-create` references that describe the distinct IDLE triage skill and must remain unchanged
  - `freeze`: historical or archived material that remains out of scope
- [ ] Mark mixed files hit by the search as either current-contract text or retrospective text section by section; do not assume an entire file is in or out of scope because one match appears there.
- [ ] Explicitly record that [issue.md](issue.md) is stale for planning purposes where it asks for a new github-issue-create skill; the approved diagnosis supersedes that acceptance criterion for this cycle.
- [ ] Define the exclusion set up front so the final search does not confuse expected historical residue with live regressions.
  - Expected exclusions: `cleanrooms/**`, `code/cli/assets/archive/**`, `code/cli/build/assets/archive/**`, and genuinely retrospective timeline or changelog history entries

**Verification:**

- [ ] Every old-name hit found by the inventory has a recorded disposition and a rationale grounded in diagnosis decision 1, 2, or 3.
- [ ] Mixed files are classified at section granularity rather than by whole-file guesswork.
- [ ] No `issue-create` hit is scheduled for rename.
- [ ] No live current-contract hit is left unclassified.
- [ ] The exclusion set is explicit enough to explain any final residual old-name matches.

**Test Definitions (Pseudocode):**

```text
hits = search_live_and_adjacent_surfaces("issue-start|issue-end|inquiry-start|inquiry-end|issue-create")
for each hit in hits:
  assert hit.disposition in {rename, preserve, freeze}
  assert hit.reason references one_of({D1, D2, D3})
  if hit.file_is_mixed:
    assert hit.section_id is not null
  if hit.contains("issue-create"):
    assert hit.disposition == preserve
  if hit.describes_current_runtime_behavior:
    assert hit.disposition in {rename, preserve}
assert no hit has disposition == undecided
```

**Risk note:** The main failure mode is false closure from an unclassified hit in a mixed current-plus-historical document.

## Phase 2: RED - Shared Contract Tests First

**Entry criteria:**

- Phase 1 inventory is complete.
- The execution inventory identifies the test files and contract assertions that still encode the old names.

**Dependencies:**

- Phase 1 completed, including the live/freeze/preserve classification and explicit exclusion set.
- The narrow test slice is chosen from the Phase 1 inventory rather than ad hoc during editing.

**Execution steps:**

- [ ] Update narrow test expectations to encode the target contract names before renaming runtime assets.
  - Candidate files already evidenced in diagnosis-adjacent reads: `code/cli/test/instruction_prompt_loader_test.dart`, `code/cli/test/assets_test.dart`, `code/cli/test/ape_prompt_test.dart`, `code/cli/test/fsm_contract_test.dart`, `code/cli/test/fsm_state_test.dart`, `code/cli/test/fsm_transition_test.dart`, `code/cli/test/firmware_agent_test.dart`, and `code/cli/test/doctor_test.dart`
- [ ] Update both kinds of shared identifier sites inside those tests.
  - Construction sites: seeded skill/instruction lists such as `testSkills`, expected instruction arrays, and `requiredInstructions` expectations
  - Consumer sites: `loader.load(...)`, asset path strings such as `instructions/issue-start.md`, and human-facing text assertions that still mention the old names
- [ ] Use one concrete search strategy to enumerate those test constructors and consumers before editing.
  - Search strategy: `rg -n "testSkills|requiredInstructions|issue-start|issue-end|issue-create|instructions/issue-(start|end)\\.md|loader\\.load\\(" code/cli/test`
- [ ] Add or preserve explicit assertions that `issue-create` remains present and semantically distinct where tests already encode that boundary.
- [ ] Run only the touched tests to establish RED before the runtime assets are renamed.
  - Narrow command pattern: `dart test test/<touched_file>.dart ...`

**Verification:**

- [ ] The RED command exits non-zero before any runtime/build asset rename.
- [ ] Every observed failure belongs to the touched rename-sensitive test slice and points at old-name mismatch, asset-path drift, or adjacent wording changed by the rename.
- [ ] Tests that guard the `issue-create` distinction still pass or fail only where the start/end rename legitimately changes adjacent wording.
- [ ] The RED failures identify the concrete runtime surfaces that still need the rename.

**Test Definitions (Pseudocode):**

```text
red = run_targeted_tests(after_updating_tests_only = true)
assert red.exit_code != 0
assert every failure in red.failures belongs_to touched_test_slice
assert red.failures contains_one(message_mentions("inquiry-start") or
                                 message_mentions("inquiry-end") or
                                 message_mentions("instructions/inquiry-start.md") or
                                 message_mentions("instructions/inquiry-end.md"))
assert red.failures none_match(message_mentions("rename issue-create"))
assert expected_runtime_contract still_contains("issue-create")
```

**Risk note:** Tests cover the contract well, but not every docs-only or site-only surface; Phase 4 still matters even if Phase 2 and Phase 3 go green.

## Phase 3: GREEN - Canonical Runtime Assets and Shared Identifier Sites

**Entry criteria:**

- Phase 2 established the RED contract.
- The execution inventory distinguishes live runtime surfaces from frozen historical ones.

**Dependencies:**

- Phase 2 has already produced a failing rename-sensitive test slice that can be rerun unchanged as the GREEN gate.
- Phase 1 freeze decisions remain available so runtime edits do not spill into historical material.

**Execution steps:**

- [ ] Treat this as a shared identifier contract rename even though no behavior changes.
- [ ] Enumerate every construction site before editing.
  - Instruction filenames in committed source assets
  - Instruction filenames in committed build assets
  - Frontmatter `name:` fields inside the instruction documents
  - FSM `instructions:` arrays and other YAML fields that emit the instruction identifiers
  - Any non-test fixture, adapter, or generated list in live runtime/build assets that still emits the old identifiers after the Phase 2 RED slice is fixed
- [ ] Enumerate every consumer site before editing.
  - Asset path lookups such as `instructions/issue-start.md` and `instructions/issue-end.md`
  - `loader.load(...)` call sites and prompt-summary lookups
  - Firmware or agent text that tells operators which instruction to invoke
  - Runtime descriptions and transition text that still expose the old names
- [ ] Keep the dependency boundary explicit while executing GREEN.
  - Phase 2 already owns direct test-constructor and expectation renames so RED can fail on the intended contract drift.
  - Phase 3 updates runtime/build emitters and consumers, then reuses the Phase 2 slice only as the GREEN confirmation pass.
- [ ] Use one concrete search strategy to keep those enumerations exhaustive.
  - Search strategy: `rg -n "name: issue-(start|end)|issue-start|issue-end|instructions/issue-(start|end)\\.md|load\('issue-(start|end)'\)|requiredInstructions|testSkills|instructions: \[.*issue-(start|end)" code/cli .github README.md docs code/site`
- [ ] Rename the canonical source instruction files.
  - `code/cli/assets/instructions/issue-start.md` -> `code/cli/assets/instructions/inquiry-start.md`
  - `code/cli/assets/instructions/issue-end.md` -> `code/cli/assets/instructions/inquiry-end.md`
- [ ] Rename the committed build mirrors to keep distributed assets aligned.
  - `code/cli/build/assets/instructions/issue-start.md` -> `code/cli/build/assets/instructions/inquiry-start.md`
  - `code/cli/build/assets/instructions/issue-end.md` -> `code/cli/build/assets/instructions/inquiry-end.md`
- [ ] Update the renamed documents' internal metadata and headings.
  - Frontmatter `name:` values
  - H1 titles and prompt-ready summaries
- [ ] Update source runtime contract surfaces already evidenced by the analysis.
  - `code/cli/assets/fsm/states/idle.yaml`
  - `code/cli/assets/fsm/transition_contract.yaml`
  - `code/cli/assets/agents/inquiry.agent.md`
- [ ] Update the matching committed build/runtime mirrors.
  - `code/cli/build/assets/fsm/states/idle.yaml`
  - `code/cli/build/assets/fsm/transition_contract.yaml`
  - `code/cli/build/assets/agents/inquiry.agent.md`
- [ ] Keep `issue-create` unchanged in filenames, content, semantics, and contract references.
- [ ] Re-run the same narrow tests from Phase 2 until they turn GREEN.

**Verification:**

- [ ] The targeted tests from Phase 2 pass GREEN.
- [ ] The canonical source and committed build assets contain `inquiry-start` and `inquiry-end` in the relevant runtime surfaces.
- [ ] A constructor-focused search over live source/build emitters returns zero old-name hits outside the Phase 1 freeze set.
- [ ] A consumer-focused search over loaders, agents, FSM surfaces, and prompt/help text returns zero old-name hits outside the Phase 1 freeze set.
- [ ] `issue-create` remains present only where the distinct IDLE triage contract requires it.

**Test Definitions (Pseudocode):**

```text
constructors = rg(old_or_new_names, source_and_build_emitter_paths)
consumers = rg(old_or_new_names, runtime_consumer_paths)
assert file_exists("code/cli/assets/instructions/inquiry-start.md")
assert file_exists("code/cli/assets/instructions/inquiry-end.md")
assert file_exists("code/cli/build/assets/instructions/inquiry-start.md")
assert file_exists("code/cli/build/assets/instructions/inquiry-end.md")
assert not file_exists("code/cli/assets/instructions/issue-start.md")
assert not file_exists("code/cli/assets/instructions/issue-end.md")
assert constructors.old_name_hits == 0
assert consumers.old_name_hits == 0
assert constructors contains_expected_names({"inquiry-start", "inquiry-end"})
assert consumers contains_expected_names({"inquiry-start", "inquiry-end"})
green = run_targeted_tests()
assert green.exit_code == 0
```

**Risk note:** The highest-risk defect is source/build drift, where one committed mirror keeps the old name after the canonical source is updated.

## Phase 4: Live Docs, Site, and Deployment-Facing Explanatory Surfaces

**Entry criteria:**

- Phase 3 runtime surfaces are GREEN.
- The exclusion set from Phase 1 is still available to separate current contract text from frozen history.

**Dependencies:**

- Phase 3 completed the runtime/build rename, so explanatory text can now align to the settled live contract.
- Phase 1 mixed-file and freeze classifications remain authoritative for section-by-section doc handling.

**Execution steps:**

- [ ] Update maintainership-facing and public explanatory surfaces that describe the current live contract.
  - `README.md`
  - `docs/architecture.md`
  - `docs/lore.md`
  - `docs/philosophy.md`
  - `docs/roadmap.md` for current-contract references only
  - `docs/thinking-tools.md`
  - `docs/spec/agent-lifecycle.md`
  - `docs/spec/cli-as-api.md`
  - `docs/spec/cooperative-multitasking-model.md`
  - `docs/spec/inquiry-cli-spec.md`
  - `docs/spec/state-encapsulation.md`
  - `docs/spec/signal-based-coordination.md`
  - `code/site/methodology.html`
  - `.github/agents/inquiry.agent.md`
- [ ] Re-run the Phase 1 search over `docs/**`, `.github/**`, `README.md`, and `code/site/**` to catch any additional live explanatory hits not listed above.
- [ ] Handle mixed historical/current documents carefully.
  - Update current runtime descriptions that still instruct or describe the active contract.
  - Do not rewrite retrospective entries whose job is to preserve historical chronology.
- [ ] Leave all frozen historical buckets unchanged.
  - `cleanrooms/**`
  - `code/cli/assets/archive/**`
  - `code/cli/build/assets/archive/**`
  - retrospective timeline, changelog, and release-history entries that are not active runtime/help text
- [ ] Confirm that any surviving `issue-create` references still describe the distinct issue creation/selection behavior in IDLE and were not swept into the start/end rename.

**Verification:**

- [ ] A search over live docs, site, and deployment-facing explanatory surfaces returns zero old-name hits outside the documented freeze set.
- [ ] Every touched current-contract document either rewrites the active concept to `inquiry-start` / `inquiry-end` or removes the stale section entirely; no mixed active terminology remains.
- [ ] Current docs that still mention `issue-create` do so only to describe the distinct IDLE triage behavior preserved by diagnosis decision 2.
- [ ] No doc or site update changes the diagnosed behavior boundary; the rename remains nomenclature-only.

**Test Definitions (Pseudocode):**

```text
live_docs_hits = rg("issue-start|issue-end", "README.md docs .github code/site")
assert every hit in live_docs_hits belongs_to freeze_set or was updated
for each doc in touched_current_contract_docs:
  assert doc contains no mixed old_and_new_names for the same active concept
issue_create_hits = rg("issue-create", "README.md docs .github code/site code/cli")
assert every hit in issue_create_hits still describes triage_or_issue_selection
```

**Risk note:** Mixed current-plus-historical documents can tempt a blanket replace. That would violate the approved historical boundary.

## Phase 5: Final Verification and Closure Gate

**Entry criteria:**

- Phases 1 through 4 are complete.
- The execution inventory and freeze set are still available to interpret final search residue.

**Dependencies:**

- Phase 2 and Phase 3 provide the narrow test slice and GREEN baseline reused for any last prompt-sensitive reruns.
- Phase 1 provides the freeze set needed to judge residual search hits.
- Phase 4 provides the final list of touched explanatory surfaces that must be included in closure checks.

**Execution steps:**

- [ ] Re-run the narrow rename-sensitive tests touched in Phases 2 and 3 if any additional doc or prompt surface edits altered prompt content.
- [ ] Run a final absence search across live surfaces.
  - Search strategy: `rg -n "issue-start|issue-end" code/cli .github README.md docs code/site`
- [ ] Interpret any remaining hits against the Phase 1 freeze set; if a hit is not clearly historical, treat it as a regression and return to analysis/execution rather than declaring completion.
- [ ] Run a positive search to prove the new names are now the live contract.
  - Search strategy: `rg -n "inquiry-start|inquiry-end" code/cli .github README.md docs code/site`
- [ ] Run a preservation search to confirm `issue-create` survived unchanged where the diagnosis says it must.
  - Search strategy: `rg -n "issue-create" code/cli .github README.md docs code/site`
- [ ] If an existing smoke path is available, run one deployment-facing sanity check such as doctor or prompt assembly to ensure the renamed instructions are the ones surfaced to operators.
- [ ] Run the full project test suite required by the PLAN contract as the terminal closure gate after the residual searches are clean; completion without this command is invalid.
  - Command: `cd code/cli && dart test`

**Verification:**

- [ ] No live non-historical `issue-start` or `issue-end` hits remain.
- [ ] `inquiry-start` and `inquiry-end` appear across the expected live runtime surfaces and at least one Phase 4 explanatory surface.
- [ ] `issue-create` remains present and unchanged where its distinct semantics are required.
- [ ] Any available smoke path used in this cycle succeeds against the renamed assets.
- [ ] `dart test` passes for the full project suite as the mandatory final closure gate.
- [ ] The finished diff reflects a nomenclature refactor only, not a behavior change.

**Test Definitions (Pseudocode):**

```text
remaining_old_hits = rg("issue-start|issue-end", live_surfaces)
assert every hit in remaining_old_hits belongs_to freeze_set
new_hits = rg("inquiry-start|inquiry-end", live_surfaces)
assert new_hits includes_paths({
  "code/cli/assets/instructions/inquiry-start.md",
  "code/cli/assets/instructions/inquiry-end.md",
  "code/cli/build/assets/instructions/inquiry-start.md",
  "code/cli/build/assets/instructions/inquiry-end.md"
})
assert new_hits includes_at_least_one_path_from(phase4_touched_explanatory_surfaces)
issue_create_hits = rg("issue-create", live_surfaces)
assert every hit in issue_create_hits context_matches_triage_or_issue_selection
if smoke_path_available:
  smoke = run_smoke_path()
  assert smoke.exit_code == 0
suite = shell("cd code/cli && dart test")
assert suite.exit_code == 0
```

**Risk note:** The final search must include hidden and deployment-facing live surfaces such as `.github` and committed build assets; otherwise the rename can look complete while a live prompt path still exposes the old names.