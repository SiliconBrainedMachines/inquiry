import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/hosts/skill_builder.dart';
import 'package:inquiry_cli/modules/fsm/commands/transition.dart';

void main() {
  group('SkillBuilder', () {
    final builder = SkillBuilder(Assets(root: Directory.current.path));

    test('phaseSkillNames ships analyze, plan, execute (US2)', () {
      expect(builder.phaseSkillNames,
          containsAll(<String>['iq-analyze', 'iq-plan', 'iq-execute']));
    });

    test('phaseSkillNames ships the QA specification skill', () {
      expect(builder.phaseSkillNames, contains('iq-specification'));
    });

    test('throws on an unknown phase', () {
      expect(() => builder.build('bogus'), throwsArgumentError);
    });

    group("build('specification') — QA phase, outside the dev FSM", () {
      late String md;
      setUp(() => md = builder.build('specification'));

      test('frontmatter names the skill', () {
        expect(md, startsWith('---\nname: iq-specification\n'));
      });

      test('mechanics: scaffolds via the CLI command + DEWEY operator', () {
        expect(md, contains('iq specification new'));
        expect(md, contains('iq ape prompt --name dewey'));
      });

      test('runs the specification_ready gate via the CLI', () {
        expect(md, contains('iq specification check <slug>'));
        expect(md, contains('specification_ready'));
      });

      test('is outside the dev FSM — no fsm transition gate', () {
        expect(md, isNot(contains('iq fsm transition')));
      });

      test('decides by evidence — throwaway experiments, not inference', () {
        expect(md.toLowerCase(), contains('experiment'));
        expect(md.toLowerCase(), contains('evidence'));
      });

      test('lists the specification.md sections (from template, not embedded)',
          () {
        for (final section in const [
          '- **Context and ground rules**',
          '- **1. Commitment date**',
          '- **2. User Stories**',
          '- **3. Testing Strategy**',
          '- **4. Explicit Scope**',
          '- **5. Decisions (evidence)**',
        ]) {
          expect(md, contains(section));
        }
      });

      test('derives + dedup-checks issues via gh', () {
        expect(md, contains('gh issue list --search'));
        expect(md, contains('issue-<slug>.md'));
      });

      test('has a Done-when checklist and presents to the human', () {
        expect(md, contains('## Done when'));
        expect(md.toLowerCase(), contains('human'));
      });

      test('stays brief (SC-004)',
          () => expect(md.split('\n').length, lessThan(45)));
    });

    group("build('plan') — CLI scaffolds plan.md, brain fills", () {
      late String md;
      setUp(() => md = builder.build('plan'));

      test('frontmatter, descartes operator, plan gate', () {
        expect(md, startsWith('---\nname: iq-plan\n'));
        expect(md, contains('iq ape prompt --name descartes'));
        expect(md, contains('iq fsm transition --event approve_plan'));
        expect(md, contains('Use only the events `iq fsm state` lists'));
      });

      test('references the scaffolded plan.md (not embedded)', () {
        expect(md, contains('The CLI already scaffolded'));
        expect(md, contains('cleanrooms/<branch>/plan.md'));
      });

      test('stays brief', () => expect(md.split('\n').length, lessThan(45)));
    });

    group("build('execute') — implement the plan, no scaffolded artifact", () {
      late String md;
      setUp(() => md = builder.build('execute'));

      test('frontmatter, ada operator, execute gate', () {
        expect(md, startsWith('---\nname: iq-execute\n'));
        expect(md, contains('iq ape prompt --name ada'));
        expect(md, contains('iq fsm transition --event finish_execute'));
      });

      test('guides implementing the plan phase by phase (no artifact to fill)', () {
        expect(md.toLowerCase(), contains('phase by phase'));
        expect(md, isNot(contains('fill these sections')));
      });
    });

    group("build('analyze') — generated from contracts", () {
      late String md;
      setUp(() => md = builder.build('analyze'));

      test('frontmatter names the skill', () {
        expect(md, startsWith('---\nname: iq-analyze\n'));
      });

      test('mechanics layer: the exact iq commands for the phase', () {
        expect(md, contains('iq fsm state --json'));
        expect(md, contains('iq ape prompt --name socrates'));
        expect(md, contains('iq fsm transition --event complete_analysis'));
        // Events are read at runtime, never hardcoded as a guess (Principle I).
        expect(md, contains('Use only the events `iq fsm state` lists'));
      });

      test('shape layer: lists the artifact sections (from template, not embedded)', () {
        for (final section in const [
          '- **Evidence**',
          '- **Hypotheses**',
          '- **Constraints**',
          '- **Open Questions**',
        ]) {
          expect(md, contains(section));
        }
        // The CLI scaffolds the file; the skill points at it, not embeds it.
        expect(md, contains('The CLI already scaffolded'));
      });

      test('judgment layer: goal derived from the FSM state contract', () {
        // analyze.yaml description / first instruction line.
        expect(md, contains('## Goal'));
        expect(md, contains('diagnosis.md'));
      });

      test('has a Done-when checklist tied to the gate', () {
        expect(md, contains('## Done when'));
        expect(md, contains('exits 0'));
      });

      test('methodology core stays brief (SC-004) — whole skill is short', () {
        // The part the reader reasons over (everything before the embedded
        // artifact template) must be short.
        final core = md;
        expect(core.split('\n').length, lessThan(40));
      });
    });

    test('scaffold ⇄ gate: the UNFILLED diagnosis template is rejected until '
        'filled (the CLI scaffolds, the brain fills) (T009)', () async {
      final tempDir = Directory.systemTemp.createTempSync('iq_skill_gate_');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      const branch = '901-fix';
      _initGitRepo(tempDir.path, branch: branch);
      _copyAsset('fsm/transition_contract.yaml', tempDir.path);
      _writeState(tempDir.path, 'ANALYZE', branch: branch, issue: '901');
      _write(tempDir.path, branch, 'index.md', '# Analyze — Index\n');
      _write(tempDir.path, branch, 'confirmations.md', '# Confirmations\n');

      // The CLI scaffolds diagnosis.md from this template; unfilled, the gate
      // must reject it (its Evidence bullet IS the gate's bootstrap placeholder).
      final template = Assets(root: Directory.current.path)
          .loadString('artifacts/diagnosis.template.md')
          .replaceAll('{{DATE}}', '2026-01-01');
      _write(tempDir.path, branch, 'diagnosis.md', template);

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'complete_analysis',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => branch,
      ).execute();

      expect(output.allowed, isFalse,
          reason: 'the unfilled scaffold must require filling:\n'
              '${output.message}');
      expect(output.message, contains('DIAGNOSIS_EVIDENCE_MISSING'));
    });

    test('scaffold ⇄ gate: the UNFILLED plan template is rejected by the plan '
        'gate until filled with executable checks', () async {
      final tempDir = Directory.systemTemp.createTempSync('iq_plan_gate_');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      const branch = '901-fix';
      _initGitRepo(tempDir.path, branch: branch);
      _copyAsset('fsm/transition_contract.yaml', tempDir.path);
      _writeState(tempDir.path, 'PLAN', branch: branch, issue: '901');

      final template = Assets(root: Directory.current.path)
          .loadString('artifacts/plan.template.md')
          .replaceAll('{{DATE}}', '2026-01-01');
      File(p.join(tempDir.path, 'cleanrooms', branch, 'plan.md'))
        ..createSync(recursive: true)
        ..writeAsStringSync(template);

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'approve_plan',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => branch,
      ).execute();

      expect(output.allowed, isFalse,
          reason: 'unfilled plan (no real executable check) must be rejected:\n'
              '${output.message}');
      expect(output.message, contains('PLAN_CHECKS_NOT_EXECUTABLE'));
    });
  });
}

void _copyAsset(String rel, String root) {
  final src = File(p.join(Directory.current.path, 'assets', rel));
  final dst = File(p.join(root, 'assets', rel));
  dst.createSync(recursive: true);
  dst.writeAsStringSync(src.readAsStringSync());
}

void _write(String root, String branch, String name, String content) {
  final file = File(p.join(root, 'cleanrooms', branch, 'analyze', name));
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void _writeState(String root, String state,
    {required String branch, String? issue}) {
  final file = File(p.join(root, 'cleanrooms', branch, '.iq.state.yaml'));
  file.createSync(recursive: true);
  final issueLine = issue != null ? 'issue: "$issue"' : 'issue: null';
  file.writeAsStringSync('version: 1\nstate: $state\n$issueLine\nstatus: active\n');
}

void _initGitRepo(String root, {required String branch}) {
  void git(List<String> args) {
    final r = Process.runSync('git', args, workingDirectory: root);
    if (r.exitCode != 0) throw StateError('git ${args.join(' ')}: ${r.stderr}');
  }

  git(['init']);
  git(['config', 'user.email', 'test@test.com']);
  git(['config', 'user.name', 'Test']);
  File(p.join(root, '.gitkeep')).writeAsStringSync('');
  git(['add', '.']);
  git(['commit', '-m', 'init']);
  git(['checkout', '-b', branch]);
}
