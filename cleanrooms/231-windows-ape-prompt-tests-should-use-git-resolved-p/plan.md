---
id: plan
title: "Plan"
date: 2026-06-04
status: active
tags: [plan, decomposition]
---

# Plan

## Decision anchors from diagnosis.md

- Treat this issue as a bounded test-expectation fix in `code\cli\test\ape_prompt_test.dart`, not as a prompt-assembly or runtime-behavior change.
- Keep the authoritative root source aligned with `CycleContext.resolve` -> `getProjectRoot` -> `git rev-parse --show-toplevel`.
- Preserve inquiry-context shape, transcript behavior, and run-trace surfaces; only re-anchor brittle alias-based expectations.
- Shared interface/type-shape note: no `inquiry-context` key set or `CycleContext` field shape change is authorized by the diagnosis. If execution discovers that a schema change is required, return to analysis before editing constructors or consumers.

## Enumeration completeness guardrails

- No planned phase changes a shared interface or type shape. The diagnosis authorizes only expectation updates inside `code\cli\test\ape_prompt_test.dart`; `CycleContext`, `getProjectRoot`, `ApePromptCommand._resolveRuntimeContext`, and inquiry-context key names stay unchanged unless new evidence falsifies the diagnosis.
- [ ] Alias-root search inventory: run `rg "p\.normalize\(gitTmpDir\.path\)" code\cli\test\ape_prompt_test.dart -n` to enumerate every literal repo-root expectation still tied to the entered path spelling.
- [ ] Retrieval-context search inventory: run `rg "retrieval_context:" code\cli\test\ape_prompt_test.dart -n`, then use `rg "test\('" code\cli\test\ape_prompt_test.dart -n` plus nearby line reads to map each hit to its enclosing scenario before editing.
- [ ] Fixture-reuse search: run `rg "nested|workingDirectory:|createSync\(recursive: true\)" code\cli\test\ape_prompt_test.dart -n` so the Windows alternate-path case stays inside the existing harness shape instead of inventing a new scaffold.
- [ ] Schema-change guard: if any step appears to require changing `CycleContext` fields or inquiry-context key names, stop and return to analysis before editing. Use `rg "const CycleContext\(|return CycleContext\(" code\cli\lib code\cli\test -n` to enumerate type construction sites, `rg "'project_root':|retrieval_context|authoritative_handoff|upfront_context" code\cli\lib code\cli\test -n` to enumerate inquiry-context object-literal or adapter sites, and `rg "cycleContext\.projectRoot|getProjectRoot\(" code\cli\lib code\cli\test -n` to enumerate authority consumers.

## Bounded assertion inventory

- [ ] `socrates prompt includes inquiry-context with output_dir` — update `project_root` and ANALYZE `retrieval_context` expectations to the helper-derived git root.
- [ ] `descartes prompt includes analysis_input path` — update `project_root` and PLAN `retrieval_context` expectations to the helper-derived git root.
- [ ] `task contract stays anchored to project root when invoked from a subdirectory` — update both direct and inquiry-context-only `project_root` assertions to the helper-derived git root.
- [ ] `basho prompt includes plan contract in assembled prompt` — update EXECUTE `retrieval_context` expectations, including both raw prompt and inquiry-context-only assertions, to the helper-derived git root where the repo-root element appears.

## Phase dependencies

- Phase 1 has no upstream dependency because every later assertion must use one authoritative git-resolved root source.
- Phase 2 depends on Phase 1 so the alternate-path reproducer checks against the same canonical-root expectation authority later phases will reuse.
- Phase 3 depends on Phases 1 and 2 so the broad assertion sweep happens only after one focused Windows alternate-path case has already proven the contract.
- Phase 4 depends on Phases 1 through 3 because focused and full-suite validation are only meaningful after the helper, reproducer, and assertion sweep are all in place.

## Ordered execution path

1. Phase 1 establishes the single expected-root authority for the test file.
2. Phase 2 adds the Windows-specific alternate-path reproducer while the change surface is still narrow and easy to falsify.
3. Phase 3 re-anchors every remaining bounded ape prompt expectation to the Phase 1 authority, using the Phase 2 case as proof of the intended contract.
4. Phase 4 runs focused validation first and the required full `dart test` suite last.

## Verification matrix

| Phase | TDD mode | Phase-complete evidence |
|---|---|---|
| 1 | GREEN setup | One git-backed helper yields the same expected root for direct-root and nested entry paths and is ready to replace literal repo-root expectations. |
| 2 | RED→GREEN Windows reproducer | A Windows-only alternate-path test is red under alias-root expectations and green under helper-derived git-root expectations. |
| 3 | Guarded GREEN sweep | Every in-scope ape prompt consumer uses the helper-derived root while branch-relative cleanroom paths remain unchanged. |
| 4 | Regression gate | Focused ape prompt tests, `dart analyze`, and the full `dart test` suite all pass, with the full suite run last. |

## Phase 1 — Establish canonical-root expectation fixture

**Dependencies:** None  
**TDD applicability:** GREEN-only setup — establish the authoritative expected-root source for direct and nested entry paths first; the first genuine RED for alias-versus-git-root behavior belongs to Phase 2.

### Entry criteria

- [x] `cleanrooms\231-windows-ape-prompt-tests-should-use-git-resolved-p\analyze\diagnosis.md` remains the authoritative handoff and its test-only diagnosis still stands.
- [x] A bounded assertion inventory is prepared from `rg "p\.normalize\(gitTmpDir\.path\)" code\cli\test\ape_prompt_test.dart -n`, limited to expectation sites rather than setup paths.
- [x] The schema guard remains green: no planned edit is required in `code\cli\lib\src\cycle_context.dart`, `code\cli\lib\src\git_utils.dart`, or the inquiry-context map literal in `code\cli\lib\modules\ape\commands\prompt.dart`.

### Execution steps

- [x] Import and reuse `getProjectRoot` from `package:inquiry_cli/src/git_utils.dart` as the authoritative expected-root helper for test expectations, because it already shells out to `git rev-parse --show-toplevel` and applies `normalizeGitRootPath` before `p.normalize`.
- [x] Reuse that helper anywhere the prompt contract expects the authoritative repository root string instead of repeating literal `p.normalize(gitTmpDir.path)` expectations.
- [x] If a direct `getProjectRoot` import proves impossible for a bounded test reason, use `normalizeGitRootPath` as the normalization primitive in any fallback helper; do not reimplement the helper with bare `p.normalize`, because that would miss MSYS-style `/c/...` git output on Windows.
- [x] Keep the helper bounded to the ape prompt test surface; do not change `ApePromptCommand._resolveRuntimeContext`, `CycleContext.resolve`, or `getProjectRoot` unless new evidence disproves the diagnosis.

### Verification

- [x] Direct-root invocation and nested-subdirectory invocation both yield the same helper-derived root string for the same repository.
- [x] On Windows, the helper can represent a canonical git root even when the working-directory spelling differs from the entered alias path.
- [x] Any helper path normalization still matches production behavior for both `C:/...` and MSYS-style `/c/...` git output.
- [x] The helper can be consumed by the existing bounded prompt scenarios (`socrates prompt includes inquiry-context with output_dir`, `descartes prompt includes analysis_input path`, and the nested-subdirectory anchor test) without changing any runtime production code.
- [x] No shared interface/type-shape change is introduced: helper derivation stays test-local and does not require new `CycleContext` fields or inquiry-context keys.

### Test definition (pseudocode)

```text
SETUP / GREEN:
repo = createTempGitRepo()
nested = repo\lib\nested\deeper
expectedRoot = resolveGitRoot(repo.path)
assert resolveGitRoot(nested) == expectedRoot
assert helperExpectedRoot(repo.path) == expectedRoot
assert helperExpectedRoot(msysStyleRootIfAvailable) == expectedRoot
```

### Risk notes

- Git may emit slash or case normalization that differs from the entered path spelling; the helper must normalize once, consistently, and become the only expected-root authority inside this test file.
- Reusing the full prompt assembly path to compute expectations would weaken coverage; prefer `getProjectRoot` or, if absolutely necessary, a fallback helper that still delegates to `normalizeGitRootPath` rather than reimplementing root normalization from scratch.
- If a helper-only change cannot satisfy the assertions, the diagnosis is falsified and the work must return to analysis before touching constructors or prompt-shape emitters.

## Phase 2 — Add Windows alternate-path coverage

**Dependencies:** Phase 1  
**TDD applicability:** Yes — RED with one Windows-only alternate-path reproducer that still expects the alias spelling, then GREEN by switching that single reproducer to the helper-derived git root before any broad sweep.

### Entry criteria

- [x] Phase 1's helper exists and can compute the canonical root independently of the entered path spelling.
- [x] The acceptance criterion for Windows alternate-path coverage is still bounded to the ape prompt test surface.
- [x] The fixture-reuse search has identified the existing nested-working-directory setup in `ape_prompt_test.dart`, so the Windows alias case can be inserted without inventing a second harness pattern.

### Execution steps

- [x] Add a Windows-only fixture that enters the same repository through an alternate spelling such as a junction, or another alias path that reproduces `git rev-parse --show-toplevel != entered path`.
- [x] Create the junction with `Process.runSync('cmd', ['/c', 'mklink', '/J', junctionPath, targetPath])` and assert `exitCode == 0`, because `mklink` is a `cmd.exe` built-in rather than a standalone executable.
- [x] Add a focused ape prompt test that invokes prompt assembly from the alias path and asserts that inquiry-context uses the helper-derived git root instead of the alias spelling.
- [x] Reuse the existing subdirectory-anchoring pattern where possible so the new coverage stays inside the current harness shape.
- [x] Register `addTearDown(() => Process.runSync('cmd', ['/c', 'rmdir', junctionPath]))` inside the test so the junction link is removed before the enclosing `gitTmpDir.deleteSync(recursive: true)` teardown runs; do not rely on recursive directory deletion while the junction still exists.
- [x] Keep junction setup and cleanup local to `code\cli\test\ape_prompt_test.dart`; do not introduce a shared filesystem utility for a single bounded reproducer.

### Verification

- [x] The planned focused test `task contract uses git-resolved project root when invoked through a Windows junction` is red when expectations are tied to the alias path and green when expectations use the helper-derived git root.
- [x] The Windows-only fixture cleans up deterministically after the test run.
- [x] The junction cleanup order is safe: the junction link is removed first, and only then does the enclosing temp repo teardown delete the target tree.
- [x] The negative alias-vs-git-root comparison is performed on normalized strings so the failure signal reflects root authority drift rather than slash-format noise.

### Test definition (pseudocode)

```text
RED:
repo = createTempGitRepo()
alias = createWindowsJunctionWith("cmd /c mklink /J", repo.path)
addTearDown(removeJunctionLinkFirstWith("cmd /c rmdir"))
assert normalize(alias.path) != resolveGitRoot(alias.path)
prompt = runApePrompt(workingDirectory: alias.path, ape: 'socrates', subState: 'clarification')
assert prompt contains "project_root: ${normalize(alias.path)}"   // expected to fail

GREEN:
expectedRoot = resolveGitRoot(alias.path)
assert prompt contains "project_root: ${expectedRoot}"
assert prompt does not contain "project_root: ${normalize(alias.path)}"
```

### Risk notes

- Junction creation and cleanup can be host-sensitive; guard the fixture with `Platform.isWindows` and keep non-Windows behavior unchanged.
- Git may canonicalize slash direction as well as path spelling, so the negative assertion must compare normalized forms.
- `Directory.deleteSync(recursive: true)` must not be trusted to clean a tree that still contains the junction; remove the junction link first to avoid dangling links or unintended traversal into the target.
- No existing test helper currently creates Windows junctions, so the fixture plan must stay deliberately local and disposable.

## Phase 3 — Re-anchor all alias-based ape prompt assertions

**Dependencies:** Phases 1 and 2  
**TDD applicability:** Guarded GREEN sweep — after Phase 2 establishes the RED/ GREEN proof point, this phase converts the remaining bounded assertions under that protection without introducing new product behavior.

### Entry criteria

- [x] The canonical-root helper is the single expected-root source in `code\cli\test\ape_prompt_test.dart`.
- [x] The Phase 2 alternate-path test exists as the proving case for the alias-vs-git-root mismatch and is ready to guard the broader sweep.
- [x] The full assertion inventory is available from `rg "p\.normalize\(gitTmpDir\.path\)" code\cli\test\ape_prompt_test.dart -n` plus `rg "retrieval_context:" code\cli\test\ape_prompt_test.dart -n`.
- [x] The inventory is classified into the four bounded scenarios listed in `## Bounded assertion inventory`, with each hit tagged as `project_root`, repo-root `retrieval_context`, or setup-only.

### Execution steps

- [x] Replace alias-based `project_root` expectations in the diagnosis-cited ANALYZE and PLAN tests with helper-derived git-root assertions.
- [x] Replace alias-based `retrieval_context` expectations that include the repository root in ANALYZE, PLAN, and EXECUTE prompt contexts with helper-derived git-root assertions.
- [x] For each matched `retrieval_context` string, update only the repository-root element and leave cleanroom-relative entries such as `cleanrooms\<branch>\...` untouched.
- [x] Keep intentionally branch-relative or cleanroom-relative expectations such as `output_dir`, `plan_file`, and `cleanrooms\<branch>\...` unchanged.
- [x] Review every remaining `p.normalize(gitTmpDir.path)` hit in `ape_prompt_test.dart` and confirm it is either an updated in-scope expectation or an out-of-scope setup path that should stay literal.
- [x] Rerun both inventory searches after the sweep and classify every surviving match as setup-only or intentionally unchanged before leaving the phase.

### Verification

- [x] No in-scope assertion still encodes the entered alias spelling as the authoritative repository root.
- [x] Existing direct-root and nested-subdirectory prompt tests still assert the same inquiry-context structure, with only the expected root source changed.
- [x] The bounded consumer set is exhausted: `socrates prompt includes inquiry-context with output_dir`, `descartes prompt includes analysis_input path`, `task contract stays anchored to project root when invoked from a subdirectory`, and `basho prompt includes plan contract in assembled prompt` no longer rely on `p.normalize(gitTmpDir.path)` for repo-root expectations.
- [x] No unclassified `p.normalize(gitTmpDir.path)` or repo-root `retrieval_context` hit remains in `ape_prompt_test.dart`; every surviving literal path is setup-only or intentionally branch-relative.

### Test definition (pseudocode)

```text
expectedRoot = resolveGitRoot(currentWorkingDirectoryOrAlias)
focusedScenarios = [
    "socrates prompt includes inquiry-context with output_dir",
    "descartes prompt includes analysis_input path",
    "task contract stays anchored to project root when invoked from a subdirectory",
    "basho prompt includes plan contract in assembled prompt",
]
for each scenario in focusedScenarios:
    prompt = runScenario(scenario)
    assert prompt contains expectedRoot in every repo-root field
    assert branch-relative fields still use cleanrooms\<branch>\...
```

### Risk notes

- The search sweep must distinguish repository-root fields from entered-working-directory setup values; blindly replacing setup paths could break fixtures instead of fixing expectations.
- EXECUTE retrieval-context expectations also depend on `cycleContext.projectRoot`; omitting them would preserve cross-state contract drift in the same test file.
- Missing the inquiry-context-only assertions inside already-named tests would leave a partial fix even if the raw prompt string assertions turn green.

## Phase 4 — Validate the bounded contract and full suite

**Dependencies:** Phases 1 through 3  
**TDD applicability:** Regression gate — once the GREEN sweep is complete, prove the bounded fix did not widen into a prompt-assembly or suite regression.

### Entry criteria

- [x] Phases 1 through 3 are complete and the modified prompt tests are internally consistent.
- [x] No runtime-schema change was introduced outside the bounded test surface.
- [x] The post-edit inventory reruns are clean: any remaining `p.normalize(gitTmpDir.path)` or repo-root `retrieval_context` hit has been explicitly classified before validation starts.

### Execution steps

- [x] Run focused ape prompt coverage in `code\cli` for the named scenarios: `socrates prompt includes inquiry-context with output_dir`, `descartes prompt includes analysis_input path`, `task contract stays anchored to project root when invoked from a subdirectory`, `basho prompt includes plan contract in assembled prompt`, and the new Windows alternate-path case.
- [x] Run `dart analyze` in `code\cli` because the same package is gated by CI static analysis.
- [x] Run the full existing CLI project test suite from `code\cli` with `dart test` as the final verification step.

### Verification

- [x] The focused ape prompt tests pass on the Windows host, including the new alternate-path case, and preserve transcript or run-trace behavior.
- [x] `dart analyze` completes without new diagnostics.
- [x] `dart test` passes for the full `code\cli` suite, not just the ape prompt subset.
- [x] The validation transcript preserves the focused test output and the existing `cleanrooms\231-windows-ape-prompt-tests-should-use-git-resolved-p\run_trace.yaml` evidence rather than replacing them with ad hoc artifacts.

### Test definition (pseudocode)

```text
cd code\cli
run dart test test\ape_prompt_test.dart --plain-name "socrates prompt includes inquiry-context with output_dir"
run dart test test\ape_prompt_test.dart --plain-name "descartes prompt includes analysis_input path"
run dart test test\ape_prompt_test.dart --plain-name "task contract stays anchored to project root when invoked from a subdirectory"
run dart test test\ape_prompt_test.dart --plain-name "basho prompt includes plan contract in assembled prompt"
run dart test test\ape_prompt_test.dart --plain-name "task contract uses git-resolved project root when invoked through a Windows junction"
run dart analyze
run dart test
assert all commands exit 0
```

### Risk notes

- If full-suite failures appear outside the bounded ape prompt surface, compare them against baseline before treating them as regressions caused by this fix.
