import 'package:yaml/yaml.dart';

import '../assets.dart';

/// Per-phase wiring: which APE operator runs the phase, which artifact it must
/// produce, the FSM gate event that closes it, and the artifact-shape template.
/// This small map is the only hand-authored phase data; everything else is
/// derived from the FSM state contract + the embedded template (#280-follow-up).
class PhaseSkillConfig {
  final String phase; // analyze
  final String operator; // socrates
  final String artifact; // diagnosis.md
  final String artifactDir; // analyze
  final String gateEvent; // complete_analysis
  final String artifactTemplateAsset; // artifacts/diagnosis.template.md

  const PhaseSkillConfig({
    required this.phase,
    required this.operator,
    required this.artifact,
    required this.artifactDir,
    required this.gateEvent,
    required this.artifactTemplateAsset,
  });
}

/// Assembles an `iq-<phase>` skill (`SKILL.md`) from the existing contracts —
/// the FSM state contract (goal) + the artifact template (shape) — leaving the
/// cognitive method to `iq ape prompt` at runtime so the skill stays brief.
///
/// Mirrors [AgentBuilder]: one builder, generated at deploy time, so the skills
/// cannot drift from the gates the CLI enforces (Constitution V / SC-005).
class SkillBuilder {
  final Assets assets;

  SkillBuilder(this.assets);

  /// US1 (MVP) ships `analyze`; `plan`/`execute` are added in US2.
  static const Map<String, PhaseSkillConfig> phases = {
    'analyze': PhaseSkillConfig(
      phase: 'analyze',
      operator: 'socrates',
      artifact: 'diagnosis.md',
      artifactDir: 'analyze',
      gateEvent: 'complete_analysis',
      artifactTemplateAsset: 'artifacts/diagnosis.template.md',
    ),
  };

  /// Skill directory names this builder produces (e.g. `iq-analyze`).
  List<String> get phaseSkillNames =>
      phases.keys.map((p) => 'iq-$p').toList(growable: false);

  /// Builds the `SKILL.md` content for [phase]. Throws if [phase] is unknown or
  /// a required contract asset is missing.
  String build(String phase) {
    final cfg = phases[phase];
    if (cfg == null) {
      throw ArgumentError('Unknown phase skill: "$phase"');
    }

    final state = loadYaml(assets.loadString('fsm/states/${cfg.phase}.yaml'));
    final goal = _goal(state);
    final template = assets.loadString(cfg.artifactTemplateAsset).trim();
    final phaseUpper = cfg.phase.toUpperCase();

    return '''---
name: iq-${cfg.phase}
description: Run the ${cfg.phase} phase of an Inquiry cycle by hand — produce ${cfg.artifact} and pass the gate, without the scheduler agent.
---

## Goal
$goal

## Steps
1. `iq fsm state --json` — confirm you are in $phaseUpper and do exactly what its `next` field says. Use only the events `iq fsm state` lists.
2. `iq ape prompt --name ${cfg.operator}` — read the method for this phase and apply it (investigate; gather evidence; do not speculate).
3. Write `cleanrooms/<branch>/${cfg.artifactDir}/${cfg.artifact}` using the **Artifact** shape below. Inputs/outputs are files on disk, not your memory.
4. `iq fsm transition --event ${cfg.gateEvent}` — the CLI verifies the artifact. If it fails, fix exactly what the error reports (do NOT re-run the event unchanged), then retry.
5. When the gate passes, present the result to the human and stop — the human approves moving on.

## Artifact — ${cfg.artifact}
$template

## Done when
- [ ] `${cfg.artifact}` is written with every required section.
- [ ] Every Evidence bullet carries a re-checkable handle (a `file:line`, a URL, or `inline-code`).
- [ ] `iq fsm transition --event ${cfg.gateEvent}` exits 0.
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
}
