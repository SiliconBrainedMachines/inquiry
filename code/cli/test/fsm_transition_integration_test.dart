import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/modules/ape/inquiry_state.dart';
import 'package:inquiry_cli/modules/fsm/commands/transition.dart';

void main() {
  group('state transition integration', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_state_integration_');
      _copyContractFromWorkspace(tempDir.path);
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'IDLE', issue: '51');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'incident replay is prevented: IDLE cannot go_execute directly',
      () async {
        _writeState(tempDir.path, 'IDLE');

        final command = StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'go_execute',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => 'main',
        );

        final output = await command.execute();
        expect(output.allowed, isFalse);
        expect(output.exitCode, 64);
        expect(output.toText(), equals(output.message));
      },
    );

    test(
      'IDLE leaves only after the explicit-start handoff is prepared',
      () async {
        _writeState(tempDir.path, 'IDLE', issue: '51');

        final blocked = await StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'start_analyze',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => 'main',
        ).execute();

        expect(blocked.allowed, isFalse);
        expect(blocked.nextState, isNull);
        expect(blocked.toText(), equals(blocked.message));
        expect(
          File(
            p.join(
              tempDir.path,
              'cleanrooms',
              '51-idle-execution-guardrails',
              kStateFileName,
            ),
          ).readAsStringSync(),
          contains('state: IDLE'),
        );

        final allowed = await StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'start_analyze',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => '51-idle-execution-guardrails',
        ).execute();

        expect(allowed.allowed, isTrue);
        expect(allowed.nextState, 'ANALYZE');
        expect(allowed.promptFragmentId, 'idle_to_analyze');
        expect(allowed.requiredInstructions, ['doc-read']);
        expect(allowed.toText(), contains('doc-read'));
        expect(allowed.toText(), contains('idle_to_analyze'));
      },
    );

    test('IDLE→ANALYZE bootstraps the full cycle', () async {
      const branch = '51-idle-execution-guardrails';

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'start_analyze',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => branch,
      ).execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'ANALYZE');

      final cycleDir = p.join(tempDir.path, 'cleanrooms', branch);
      expect(
        File(p.join(cycleDir, 'analyze', 'index.md')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(cycleDir, 'analyze', 'confirmations.md')).existsSync(),
        isTrue,
      );
      expect(
        File(p.join(cycleDir, 'analyze', 'diagnosis.md')).existsSync(),
        isTrue,
      );
      expect(File(p.join(cycleDir, 'issue.md')).existsSync(), isTrue);

      final diagnosisContent = File(
        p.join(cycleDir, 'analyze', 'diagnosis.md'),
      ).readAsStringSync();
      expect(diagnosisContent, contains('## Evidence'));
      expect(diagnosisContent, contains('## Hypotheses'));
      expect(diagnosisContent, contains('## Constraints'));
      expect(diagnosisContent, contains('## Open Questions'));

      final state = InquiryState.loadFrom(p.join(cycleDir, kStateFileName));
      expect(state.state, 'ANALYZE');
      expect(state.status, 'active');

      // The freshly created cycle resolves as active (not derived IDLE).
      expect(InquiryState.load(tempDir.path).state, 'ANALYZE');
    });

    test('full cycle uses transition command on each step', () async {
      String current = 'IDLE';
      final branch = '51-idle-execution-guardrails';

      Future<StateTransitionOutput> transition(String event) {
        return StateTransitionCommand(
          StateTransitionInput(
            currentState: current,
            event: event,
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => branch,
        ).execute();
      }

      final t1 = await transition('start_analyze');
      expect(t1.allowed, isTrue);
      expect(t1.nextState, 'ANALYZE');
      expect(t1.promptFragmentId, isNotNull);
      current = t1.nextState!;

      final analysisCommitsBefore = _commitCount(tempDir.path);
      _writeDiagnosis(tempDir.path, branch, 'diagnosis ready');
      final t2 = await transition('complete_analysis');
      expect(t2.allowed, isTrue);
      expect(t2.nextState, 'PLAN');
      expect(t2.promptFragmentId, isNotNull);
      expect(_commitCount(tempDir.path), analysisCommitsBefore + 1);
      current = t2.nextState!;

      final planCommitsBefore = _commitCount(tempDir.path);
      _writePlan(tempDir.path, branch, '# plan\n');
      final t3 = await transition('approve_plan');
      expect(t3.allowed, isTrue);
      expect(t3.nextState, 'EXECUTE');
      expect(t3.promptFragmentId, isNotNull);
      expect(_commitCount(tempDir.path), planCommitsBefore + 1);
      current = t3.nextState!;

      final t4 = await transition('finish_execute');
      expect(t4.allowed, isTrue);
      expect(t4.nextState, 'END');
      expect(t4.promptFragmentId, isNotNull);
      final inspectionTemplate = File(
        p.join(tempDir.path, 'cleanrooms', branch, 'pre_pr_inspection.md'),
      );
      expect(inspectionTemplate.existsSync(), isTrue);
      final templateText = inspectionTemplate.readAsStringSync();
      expect(
        templateText,
        contains('PASS: asset parity source/build reviewed'),
      );
      expect(
        templateText,
        contains('PASS: overhead summary event counts transition='),
      );
      expect(
        templateText,
        contains('WARN: overhead summary attributes host-boundary activity as ['),
      );
      expect(templateText, contains('## Pass 1 — Consistency'));
      expect(templateText, contains('## Pass 2 — Completeness'));
      expect(templateText, contains('## Pass 3 — Traceability'));
      current = t4.nextState!;

      _writePrePrInspection(tempDir.path, branch, verdict: 'APPROVED');
      final t5 = await transition('pr_ready');
      expect(t5.allowed, isTrue);
      expect(t5.nextState, 'EVOLUTION');
      expect(t5.promptFragmentId, isNotNull);

      current = t5.nextState!;

      final t6 = await transition('finish_evolution');
      expect(t6.allowed, isTrue);
      expect(t6.nextState, 'IDLE');
      expect(t6.promptFragmentId, isNotNull);

      final runTrace = File(
        p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
      );
      expect(runTrace.existsSync(), isTrue);
      final traceContent = runTrace.readAsStringSync();
      expect(traceContent, contains('event_class: transition'));
      expect(traceContent, contains('event_class: sensor_run'));
      expect(traceContent, contains('event_class: phase_timing'));
      expect(traceContent, contains('event_class: tool_activity'));
      expect(traceContent, contains('transition_event: start_analyze'));
      expect(traceContent, contains('command_family: issue_view'));
      expect(traceContent, contains('transition_event: complete_analysis'));
      expect(traceContent, contains('transition_event: approve_plan'));
      expect(traceContent, contains('transition_event: finish_execute'));
      expect(traceContent, contains('transition_event: pr_ready'));
      expect(traceContent, contains('transition_event: finish_evolution'));
    });
  });
}

void _writeState(String root, String state, {String? issue}) {
  final r = Process.runSync('git', [
    'rev-parse',
    '--abbrev-ref',
    'HEAD',
  ], workingDirectory: root);
  final branch = r.exitCode == 0 ? r.stdout.toString().trim() : '';
  if (branch.isEmpty || branch == 'HEAD') return;
  final file = File(p.join(root, 'cleanrooms', branch, kStateFileName));
  file.createSync(recursive: true);
  final issueLine = issue != null ? 'issue: "$issue"' : 'issue: null';
  file.writeAsStringSync(
    'version: 1\nstate: $state\n$issueLine\nstatus: active\n',
  );
}

void _copyContractFromWorkspace(String root) {
  final source = File(
    p.join(Directory.current.path, 'assets', 'fsm', 'transition_contract.yaml'),
  );
  final destination = File(
    p.join(root, 'assets', 'fsm', 'transition_contract.yaml'),
  );
  destination.createSync(recursive: true);
  destination.writeAsStringSync(source.readAsStringSync());
  final buildDestination = File(
    p.join(root, 'build', 'assets', 'fsm', 'transition_contract.yaml'),
  );
  buildDestination.createSync(recursive: true);
  buildDestination.writeAsStringSync(source.readAsStringSync());

  final inspectionTemplateSource = File(
    p.join(
      Directory.current.path,
      'assets',
      'inspection',
      'pre_pr_inspection_template.md',
    ),
  );
  final inspectionTemplateDestination = File(
    p.join(root, 'assets', 'inspection', 'pre_pr_inspection_template.md'),
  );
  inspectionTemplateDestination.createSync(recursive: true);
  inspectionTemplateDestination.writeAsStringSync(
    inspectionTemplateSource.readAsStringSync(),
  );
  final buildInspectionTemplateDestination = File(
    p.join(root, 'build', 'assets', 'inspection', 'pre_pr_inspection_template.md'),
  );
  buildInspectionTemplateDestination.createSync(recursive: true);
  buildInspectionTemplateDestination.writeAsStringSync(
    inspectionTemplateSource.readAsStringSync(),
  );
}

void _writeDiagnosis(String root, String branch, String content) {
  final file = File(
    p.join(root, 'cleanrooms', branch, 'analyze', 'diagnosis.md'),
  );
  file.createSync(recursive: true);
  file.writeAsStringSync(
    '# Diagnosis\n'
    '\n'
    '## Evidence\n'
    '$content\n'
    '\n'
    '## Hypotheses\n'
    '- Working hypothesis\n'
    '\n'
    '## Constraints\n'
    '- No additional constraints\n'
    '\n'
    '## Open Questions\n'
    '- None\n',
  );
}

void _writePlan(String root, String branch, String content) {
  final file = File(p.join(root, 'cleanrooms', branch, 'plan.md'));
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void _writePrePrInspection(String root, String branch, {required String verdict}) {
  final file = File(p.join(root, 'cleanrooms', branch, 'pre_pr_inspection.md'));
  file.createSync(recursive: true);
  final issue = branch.split('-').first;
  file.writeAsStringSync(
    [
      'verdict: $verdict',
      '',
      '# END Pre-PR Inspection',
      '',
      'issue: "$issue"',
      'branch: "$branch"',
      'generated_at: "2026-06-01T00:00:00Z"',
      '',
      '## Pass 1 — Consistency',
      '- PASS: asset parity source/build reviewed',
      '',
      '## Pass 2 — Completeness',
      '- PASS: changed behavior covered by tests',
      '',
      '## Pass 3 — Traceability',
      '- PASS: every code change maps to plan.md',
      '',
    ].join('\n'),
  );
}

void _initGitRepo(String root, {required String branch}) {
  _git(root, ['init']);
  _git(root, ['config', 'user.email', 'test@test.com']);
  _git(root, ['config', 'user.name', 'Test']);
  File(p.join(root, '.gitkeep')).writeAsStringSync('');
  _git(root, ['add', '.']);
  _git(root, ['commit', '-m', 'init']);
  _git(root, ['checkout', '-b', branch]);
}

int _commitCount(String root) {
  final result = _git(root, ['rev-list', '--count', 'HEAD']);
  return int.parse(result.stdout.trim());
}

ProcessResult _git(String root, List<String> args) {
  final result = Process.runSync('git', args, workingDirectory: root);
  if (result.exitCode != 0) {
    fail('git ${args.join(' ')} failed: ${result.stderr}');
  }
  return result;
}
