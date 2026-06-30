import 'package:yaml/yaml.dart';

import '../assets.dart';

/// Per-phase wiring. `artifact*` are set for phases the CLI scaffolds a
/// fill-in artifact for (analyze, plan); `implementGuide` is set for phases
/// that produce code instead (execute).
class PhaseSkillConfig {
  final String phase; // analyze
  final String operator; // socrates
  final String gateEvent; // complete_analysis

  // Scaffolded-artifact phases (analyze, plan):
  final String? artifact; // diagnosis.md
  final String? artifactDir; // analyze
  final String? artifactTemplateAsset; // artifacts/diagnosis.template.md
  final String? fillRule; // the phase-specific gate rule

  // Implementation phase (execute):
  final String? implementGuide;

  const PhaseSkillConfig({
    required this.phase,
    required this.operator,
    required this.gateEvent,
    this.artifact,
    this.artifactDir,
    this.artifactTemplateAsset,
    this.fillRule,
    this.implementGuide,
  });
}

/// Assembles an `iq-<phase>` skill (`SKILL.md`) from the existing contracts.
/// Under Constitution I ("the model is the brain; the CLI is the tool"), the CLI
/// scaffolds the artifact on disk; this skill is a brief guide that points the
/// brain at the scaffolded file (or the implementation) and the phase's gate.
class SkillBuilder {
  final Assets assets;

  SkillBuilder(this.assets);

  static const Map<String, PhaseSkillConfig> phases = {
    'analyze': PhaseSkillConfig(
      phase: 'analyze',
      operator: 'socrates',
      gateEvent: 'complete_analysis',
      artifact: 'diagnosis.md',
      artifactDir: 'analyze',
      artifactTemplateAsset: 'artifacts/diagnosis.template.md',
      fillRule:
          'Every **Evidence** bullet MUST end with a re-checkable handle (a `file:line`, a URL, or `inline-code`); a bullet with no handle is rejected.',
    ),
    'plan': PhaseSkillConfig(
      phase: 'plan',
      operator: 'descartes',
      gateEvent: 'approve_plan',
      artifact: 'plan.md',
      // plan.md lives at the cleanroom root (no subdir), where the gate reads it.
      artifactDir: null,
      artifactTemplateAsset: 'artifacts/plan.template.md',
      fillRule:
          'Every phase MUST carry an executable verification check (a test-runner command or a test-file reference), plus a final full-suite check; otherwise the gate rejects it.',
    ),
    'execute': PhaseSkillConfig(
      phase: 'execute',
      operator: 'ada',
      gateEvent: 'finish_execute',
      implementGuide:
          'Implement plan.md **phase by phase**: for each phase, write the test FIRST (it must prove the AC the phase `Covers`), then the code, keep the full test suite green, and commit. Then do the release prep the plan specifies.',
    ),
  };

  /// Skill directory names this builder produces (e.g. `iq-analyze`).
  ///
  /// The dev-cycle phases (analyze/plan/execute) plus the QA-facing
  /// `specification` phase, which precedes the cycle and lives outside the FSM.
  List<String> get phaseSkillNames =>
      [...phases.keys.map((p) => 'iq-$p'), 'iq-specification'];

  /// Builds the `SKILL.md` content for [phase]. Throws if [phase] is unknown or
  /// a required contract asset is missing.
  String build(String phase) {
    if (phase == 'specification') return _buildSpecification();

    final cfg = phases[phase];
    if (cfg == null) {
      throw ArgumentError('Unknown phase skill: "$phase"');
    }

    final state = loadYaml(assets.loadString('fsm/states/${cfg.phase}.yaml'));
    final goal = _goal(state);
    final phaseUpper = cfg.phase.toUpperCase();
    final descAction =
        cfg.artifact != null ? 'fill ${cfg.artifact}' : 'implement the plan';

    final header = '''---
name: iq-${cfg.phase}
description: Run the ${cfg.phase} phase of an Inquiry cycle by hand — $descAction and pass the gate, without the scheduler agent.
---

## Goal
$goal
''';

    final artifactPath = cfg.artifactDir != null
        ? 'cleanrooms/<branch>/${cfg.artifactDir}/${cfg.artifact}'
        : 'cleanrooms/<branch>/${cfg.artifact}';
    final step3 = cfg.artifact != null
        ? 'The CLI already scaffolded `$artifactPath` — **open it and fill each section** with real content (replace every placeholder). Inputs/outputs are files on disk, not your memory.'
        : cfg.implementGuide!;

    final steps = '''
## Steps
1. `iq fsm state --json` — confirm you are in $phaseUpper and do exactly what its `next` field says. Use only the events `iq fsm state` lists.
2. `iq ape prompt --name ${cfg.operator}` — read the method for this phase and apply it.
3. $step3
4. `iq fsm transition --event ${cfg.gateEvent}` — the CLI verifies the result. If it fails, fix exactly what the error reports (do NOT re-run the event unchanged), then retry.
5. When the gate passes, present the result to the human and stop — the human approves moving on.
''';

    final shape = cfg.artifact != null
        ? '''
## ${cfg.artifact} — fill these sections
${_sectionHeaders(assets.loadString(cfg.artifactTemplateAsset!)).map((s) => '- **$s**').join('\n')}

${cfg.fillRule}
'''
        : '';

    final doneArtifact = cfg.artifact != null
        ? '- [ ] `${cfg.artifact}` is filled — no scaffold placeholders remain.\n'
        : '- [ ] The plan is implemented and the full test suite passes.\n';

    final done = '''
## Done when
$doneArtifact- [ ] `iq fsm transition --event ${cfg.gateEvent}` exits 0.
''';

    return '$header\n$steps${shape.isEmpty ? '' : '\n$shape'}\n$done';
  }

  /// Builds the `iq-specification` skill — the QA-facing specification phase.
  ///
  /// Unlike the dev-cycle skills, this phase is **outside the FSM**: there is no
  /// `iq fsm transition` gate. The CLI is still the hands — `iq specification
  /// new <slug>` scaffolds the workspace — and DEWEY is the method. The sections
  /// are read from the single-source `specification` template so the skill never
  /// drifts from what the CLI scaffolds.
  String _buildSpecification() {
    final sections = _sectionHeaders(
      assets.loadString('artifacts/specification.template.en.md'),
    ).where((s) => s != 'Metadata' && s != 'Annexes');

    return '''---
name: iq-specification
description: Run the QA specification phase by hand — turn a raw requisition into a healthy specification + issues, deciding by evidence (throwaway experiments), without the scheduler agent.
---

## Goal
Turn a raw requisition (email, document, chat) into a coherent, actionable specification and the issues it yields — every key decision licensed by evidence from a throwaway experiment, not by inference.

## Steps
1. `iq specification new <slug>` (add `--lang es` for Spanish) — the CLI scaffolds `requisitions/<slug>/requisition.md` + `specification.md`. Inputs/outputs are files on disk, not your memory.
2. `iq ape prompt --name dewey` — read the method (Deweyan inquiry) and apply it.
3. Gather the raw requisition from ALL its sources into `requisition.md` (AS-IS / TO-BE). Capture exactly what was asked — do not invent scope.
4. For every decision you are unsure of, run a **throwaway experiment** to decide by EVIDENCE, not inference: read the DB, run code in a container, probe the API. These validate spec decisions; they are NOT product code. Record each under **Decisions (evidence)** with a re-checkable handle.
5. Fill `specification.md` (see sections below). Each user story needs ≥1 Given-When-Then acceptance criterion; state the testing strategy and the explicit scope (includes / does NOT include).
6. Derive the issues: one tracked `issue-<slug>.md` per unit of work, each tracing to its acceptance criteria.
7. `iq specification check <slug>` — the CLI runs the `specification_ready` gate. Fix exactly what it reports (do NOT skip a violation) until it exits 0.
8. Dedup-check before creating: `gh issue list --search "<keywords>"`. If a too-similar issue exists, prepare a `gh issue edit` instead of a new one.
9. Print the `gh issue create` / `gh issue edit` commands (do NOT run them blind) and present the specification + issues to the human. Stop — the human reviews and approves; the doc lands on `main` via a PR (the QA review gate).

## specification.md — fill these sections
${sections.map((s) => '- **$s**').join('\n')}

Each user story MUST carry ≥1 Given-When-Then AC; each key decision MUST cite its experiment evidence; the scope MUST state what is excluded; and ≥1 issue MUST be derived.

## Done when
- [ ] `requisition.md` captures the need (AS-IS / TO-BE) from all sources.
- [ ] `specification.md` is filled — every user story has ≥1 Given-When-Then AC, explicit scope, testing strategy, and Decisions (evidence) with handles.
- [ ] `iq specification check <slug>` exits 0.
- [ ] At least one `issue-<slug>.md` is derived, dedup-checked, with its `gh` command printed.
- [ ] The specification is presented to the human for review.
''';
  }

  /// A short goal from the FSM state contract — the `description` plus the first
  /// sentence of `instructions` — kept brief per SC-004.
  String _goal(dynamic state) {
    final desc = (state['description'] as String?)?.trim() ?? '';
    final instr = (state['instructions'] as String?)?.trim() ?? '';
    final firstSentence = instr.split('\n').first.trim();
    if (desc.isEmpty) return firstSentence;
    if (firstSentence.isEmpty) return desc;
    return '$desc. $firstSentence';
  }

  /// The `## ` section headers of the artifact template, in order — so the skill
  /// lists exactly the sections the CLI scaffolds (no drift).
  List<String> _sectionHeaders(String template) => template
      .split('\n')
      .where((l) => l.startsWith('## '))
      .map((l) => l.substring(3).trim())
      .toList(growable: false);
}
