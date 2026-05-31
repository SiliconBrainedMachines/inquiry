import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/modules/ape/inquiry_state.dart';
import 'package:inquiry_cli/modules/fsm/commands/transition.dart';

void main() {
  group('state transition command', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_state_transition_');
      _writeContract(tempDir.path);
      _writeState(tempDir.path, 'IDLE');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('rejects illegal transition IDLE + go_execute', () async {
      final input = StateTransitionInput(
        currentState: 'IDLE',
        event: 'go_execute',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => 'main',
      );

      final output = await command.execute();

      expect(output.allowed, isFalse);
      expect(output.exitCode, 64);
      expect(output.message, contains('forbidden'));
    });

    test(
      'returns prompt descriptor for ANALYZE -> PLAN after boundary commit',
      () async {
        const branch = '51-idle-execution-guardrails';
        _initGitRepo(tempDir.path, branch: branch);
        _writeState(tempDir.path, 'ANALYZE', issue: '51');
        _writeAnalyzeIndex(tempDir.path, branch);
        _writeConfirmations(tempDir.path, branch);
        _writeDiagnosis(tempDir.path, branch, 'diagnosis draft');
        final commitsBefore = _commitCount(tempDir.path);

        final input = StateTransitionInput(
          currentState: null,
          event: 'complete_analysis',
          workingDirectory: tempDir.path,
        );
        final command = StateTransitionCommand(
          input,
          branchProvider: (_) async => '51-idle-execution-guardrails',
        );

        final output = await command.execute();

        expect(output.allowed, isTrue);
        expect(output.nextState, 'PLAN');
        expect(output.promptFragmentId, 'analyze_to_plan');
        expect(output.requiredRole, 'DESCARTES');
        expect(output.requiredInstructions, ['doc-write']);
        expect(output.toText(), contains('DESCARTES'));
        expect(output.toText(), contains('doc-write'));
        expect(output.toText(), contains('analyze_to_plan'));
        expect(_commitCount(tempDir.path), commitsBefore + 1);

        // Verify state was actually updated
        final stateContent = File(
          _cycleStatePath(tempDir.path, branch),
        ).readAsStringSync();
        expect(stateContent, contains('state: PLAN'));
        expect(stateContent, contains('prompt_fragment_id: analyze_to_plan'));
      },
    );

    test(
      'fails precheck when ANALYZE corpus lacks confirmations and index',
      () async {
        const branch = '51-idle-execution-guardrails';
        _initGitRepo(tempDir.path, branch: branch);
        _writeState(tempDir.path, 'ANALYZE', issue: '51');
        _writeDiagnosis(tempDir.path, branch, 'diagnosis draft');

        final output = await StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'complete_analysis',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => branch,
        ).execute();

        expect(output.allowed, isFalse);
        expect(output.message, contains('ERROR_PRECONDITION'));
      },
    );

    test(
      'fails closed when ANALYZE -> PLAN cannot create boundary commit',
      () async {
        const branch = '51-idle-execution-guardrails';

        _initGitRepo(tempDir.path, branch: branch);
        _writeAnalyzeIndex(tempDir.path, branch);
        _writeConfirmations(tempDir.path, branch);
        _writeDiagnosis(tempDir.path, branch, 'diagnosis already committed');
        _git(tempDir.path, [
          'add',
          '--',
          p.posix.join('cleanrooms', branch, 'analyze'),
        ]);
        _git(tempDir.path, [
          'commit',
          '-m',
          'analysis ready',
          '--only',
          '--',
          p.posix.join('cleanrooms', branch, 'analyze'),
        ]);
        _writeState(tempDir.path, 'ANALYZE', issue: '51');
        final commitsBefore = _commitCount(tempDir.path);

        final output = await StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'complete_analysis',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => branch,
        ).execute();

        expect(output.allowed, isFalse);
        expect(output.nextState, isNull);
        expect(output.message, contains('commit'));
        expect(_commitCount(tempDir.path), commitsBefore);

        final stateContent = File(
          _cycleStatePath(tempDir.path, branch),
        ).readAsStringSync();
        expect(stateContent, contains('state: ANALYZE'));
      },
    );

    test(
      'fails precheck when commitment needs issue/branch and issue missing',
      () async {
        const branch = '51-idle-execution-guardrails';
        _initGitRepo(tempDir.path, branch: branch);
        _writeState(tempDir.path, 'PLAN');

        final input = StateTransitionInput(
          currentState: null,
          event: 'approve_plan',
          workingDirectory: tempDir.path,
        );
        final command = StateTransitionCommand(
          input,
          branchProvider: (_) async => '51-idle-execution-guardrails',
        );

        final output = await command.execute();

        expect(output.allowed, isFalse);
        expect(output.exitCode, 7);
        expect(output.message, contains('ERROR_PRECONDITION_ISSUE_FIRST'));
      },
    );

    test('blocks IDLE to ANALYZE without issue context', () async {
      _writeState(tempDir.path, 'IDLE');

      final input = StateTransitionInput(
        currentState: null,
        event: 'start_analyze',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => '152-feature-branch',
      );

      final output = await command.execute();

      expect(output.allowed, isFalse);
      expect(output.message, contains('ERROR_PRECONDITION_ISSUE_FIRST'));
    });

    test(
      'blocks IDLE to ANALYZE when issue is ready but branch is not',
      () async {
        _initGitRepo(tempDir.path, branch: '152-feature-branch');
        _writeState(tempDir.path, 'IDLE', issue: '152');

        final input = StateTransitionInput(
          currentState: null,
          event: 'start_analyze',
          workingDirectory: tempDir.path,
        );
        final command = StateTransitionCommand(
          input,
          branchProvider: (_) async => 'main',
        );

        final output = await command.execute();

        expect(output.allowed, isFalse);
        expect(output.message, contains('ERROR_PRECONDITION_BRANCH_POLICY'));
      },
    );

    test('allows IDLE to ANALYZE with issue and feature branch', () async {
      _initGitRepo(tempDir.path, branch: '152-feature-branch');
      _writeState(tempDir.path, 'IDLE');

      final input = StateTransitionInput(
        currentState: null,
        event: 'start_analyze',
        issue: '152',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => '152-feature-branch',
      );

      final output = await command.execute();

      expect(output.allowed, isTrue);
      expect(output.exitCode, 0);
      expect(output.nextState, 'ANALYZE');
      expect(output.promptFragmentId, 'idle_to_analyze');
      expect(output.requiredInstructions, ['doc-read']);
    });

    test('blocks commitment transition on main branch', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'PLAN', issue: '51');

      final input = StateTransitionInput(
        currentState: null,
        event: 'approve_plan',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => 'main',
      );

      final output = await command.execute();

      expect(output.allowed, isFalse);
      expect(output.exitCode, 7);
      expect(output.message, contains('ERROR_PRECONDITION_BRANCH_POLICY'));
    });

    test(
      'transitions PLAN -> EXECUTE only after plan boundary commit',
      () async {
        const branch = '51-idle-execution-guardrails';
        _initGitRepo(tempDir.path, branch: branch);
        _writeState(tempDir.path, 'PLAN', issue: '51');
        _writePlan(tempDir.path, branch, '# plan\n');
        final commitsBefore = _commitCount(tempDir.path);

        final output = await StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'approve_plan',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => branch,
        ).execute();

        expect(output.allowed, isTrue);
        expect(output.nextState, 'EXECUTE');
        expect(output.promptFragmentId, 'plan_to_execute');
        expect(output.requiredInstructions, isEmpty);
        expect(output.toText(), equals(output.message));
        expect(_commitCount(tempDir.path), commitsBefore + 1);

        final stateContent = File(
          _cycleStatePath(tempDir.path, branch),
        ).readAsStringSync();
        expect(stateContent, contains('state: EXECUTE'));
        expect(stateContent, contains('prompt_fragment_id: plan_to_execute'));
      },
    );

    test(
      'fails closed when PLAN -> EXECUTE cannot create boundary commit',
      () async {
        const branch = '51-idle-execution-guardrails';
        final planPath = p.posix.join('cleanrooms', branch, 'plan.md');

        _initGitRepo(tempDir.path, branch: branch);
        _writePlan(tempDir.path, branch, '# committed plan\n');
        _git(tempDir.path, ['add', '--', planPath]);
        _git(tempDir.path, [
          'commit',
          '-m',
          'plan ready',
          '--only',
          '--',
          planPath,
        ]);
        _writeState(tempDir.path, 'PLAN', issue: '51');
        final commitsBefore = _commitCount(tempDir.path);

        final output = await StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'approve_plan',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => branch,
        ).execute();

        expect(output.allowed, isFalse);
        expect(output.nextState, isNull);
        expect(output.message, contains('commit'));
        expect(_commitCount(tempDir.path), commitsBefore);

        final stateContent = File(
          _cycleStatePath(tempDir.path, branch),
        ).readAsStringSync();
        expect(stateContent, contains('state: PLAN'));
      },
    );

    test('continuing EXECUTE does not require startup instructions', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'EXECUTE', issue: '51');

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'go_execute',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'EXECUTE');
      expect(output.promptFragmentId, 'execute_continue');
      expect(output.requiredInstructions, isEmpty);
    });

    test('routes EXECUTE through END before PR creation', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'EXECUTE', issue: '51');

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'finish_execute',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'END');
      expect(output.promptFragmentId, 'execute_to_end');
      expect(output.requiredRole, 'APE');
      expect(output.requiredInstructions, ['inquiry-end']);
      final inspectionReport = File(
        p.join(
          tempDir.path,
          'cleanrooms',
          '51-idle-execution-guardrails',
          'pre_pr_inspection.md',
        ),
      ).readAsStringSync();
      expect(
        inspectionReport,
        contains('PASS: asset parity source/build reviewed'),
      );
    });

    test('seeded END inspection report records automatic consistency failures', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'EXECUTE', issue: '51');
      File(
        p.join(
          tempDir.path,
          'build',
          'assets',
          'fsm',
          'transition_contract.yaml',
        ),
      ).writeAsStringSync('mismatch\n');

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'finish_execute',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isTrue);
      final inspectionReport = File(
        p.join(
          tempDir.path,
          'cleanrooms',
          '51-idle-execution-guardrails',
          'pre_pr_inspection.md',
        ),
      ).readAsStringSync();
      expect(inspectionReport, contains('FAIL: mirrored asset content diverges'));
      expect(
        inspectionReport,
        contains('assets/fsm/transition_contract.yaml:1'),
      );
    });

    test('allows END to create PR and enter EVOLUTION', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');
      _writePrePrInspection(
        tempDir.path,
        '51-idle-execution-guardrails',
        verdict: 'APPROVED',
      );

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'pr_ready',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'EVOLUTION');
      expect(output.promptFragmentId, 'end_to_evolution');
      expect(output.requiredRole, 'DARWIN');
      expect(output.requiredInstructions, ['inquiry-end']);
    });

    test('allows END pr_ready from a nested working directory when inspection is approved', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');
      _writePrePrInspection(
        tempDir.path,
        '51-idle-execution-guardrails',
        verdict: 'APPROVED',
      );
      final nestedDir = Directory(
        p.join(tempDir.path, 'subdir', 'deep'),
      )..createSync(recursive: true);

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'pr_ready',
          workingDirectory: nestedDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'EVOLUTION');
      expect(output.promptFragmentId, 'end_to_evolution');
    });

    test('blocks END pr_ready when pre-PR inspection report is missing', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'pr_ready',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isFalse);
      expect(
        output.message,
        contains('ERROR_PRECONDITION_PRE_PR_INSPECTION_MISSING'),
      );
    });

    test('blocks END pr_ready when inspection report lacks required pass sections', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');
      _writePrePrInspection(
        tempDir.path,
        '51-idle-execution-guardrails',
        verdict: 'APPROVED',
        rawContent: 'verdict: APPROVED\n',
      );

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'pr_ready',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isFalse);
      expect(
        output.message,
        contains('ERROR_PRECONDITION_PRE_PR_INSPECTION_INVALID'),
      );
    });

    test('blocks END pr_ready when pre-PR inspection verdict is BLOCKED', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');
      _writePrePrInspection(
        tempDir.path,
        '51-idle-execution-guardrails',
        verdict: 'BLOCKED',
        consistencyChecks: const ['PASS: asset parity source/build reviewed'],
        completenessChecks: const ['PASS: changed behavior covered by tests'],
        traceabilityChecks: const ['FAIL: undocumented change in lib/foo.dart:10'],
      );

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'pr_ready',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isFalse);
      expect(
        output.message,
        contains('ERROR_PRECONDITION_PRE_PR_INSPECTION_BLOCKED'),
      );
    });

    test('blocks END pr_ready when APPROVED report still contains FAIL checks', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');
      _writePrePrInspection(
        tempDir.path,
        '51-idle-execution-guardrails',
        verdict: 'APPROVED',
        consistencyChecks: const ['PASS: asset parity source/build reviewed'],
        completenessChecks: const ['PASS: changed behavior covered by tests'],
        traceabilityChecks: const ['FAIL: undocumented change in lib/foo.dart:10'],
      );

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'pr_ready',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isFalse);
      expect(
        output.message,
        contains('ERROR_PRECONDITION_PRE_PR_INSPECTION_INVALID'),
      );
    });

    test('blocks END pr_ready when FAIL check lacks file line citation', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');
      _writePrePrInspection(
        tempDir.path,
        '51-idle-execution-guardrails',
        verdict: 'BLOCKED',
        consistencyChecks: const ['PASS: asset parity source/build reviewed'],
        completenessChecks: const ['PASS: changed behavior covered by tests'],
        traceabilityChecks: const ['FAIL: undocumented change without citation'],
      );

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'pr_ready',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isFalse);
      expect(
        output.message,
        contains('ERROR_PRECONDITION_PRE_PR_INSPECTION_INVALID'),
      );
      expect(output.message, contains('file:line'));
    });

    test('blocks END pr_ready when automatic consistency check detects mirror divergence', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');
      _writePrePrInspection(
        tempDir.path,
        '51-idle-execution-guardrails',
        verdict: 'APPROVED',
        consistencyChecks: const ['PASS: asset parity source/build reviewed'],
        completenessChecks: const ['PASS: changed behavior covered by tests'],
        traceabilityChecks: const ['PASS: every code change maps to plan.md'],
      );
      File(
        p.join(
          tempDir.path,
          'build',
          'assets',
          'fsm',
          'transition_contract.yaml',
        ),
      ).writeAsStringSync('mismatch\n');

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'pr_ready',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => '51-idle-execution-guardrails',
      ).execute();

      expect(output.allowed, isFalse);
      expect(
        output.message,
        contains('ERROR_PRECONDITION_PRE_PR_INSPECTION_INVALID'),
      );
      final inspectionReport = File(
        p.join(
          tempDir.path,
          'cleanrooms',
          '51-idle-execution-guardrails',
          'pre_pr_inspection.md',
        ),
      ).readAsStringSync();
      expect(inspectionReport, contains('FAIL: mirrored asset content diverges'));
      expect(
        inspectionReport,
        contains('assets/fsm/transition_contract.yaml:1'),
      );
    });

    test('persists --issue flag in state.yaml on transition', () async {
      const branch = '31-feature-branch';
      _initGitRepo(tempDir.path, branch: branch);
      _writeState(tempDir.path, 'IDLE');

      final input = StateTransitionInput(
        currentState: null,
        event: 'start_analyze',
        issue: '31',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => '31-feature-branch',
      );

      final output = await command.execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'ANALYZE');

      // Verify issue was persisted in state
      final stateContent = File(
        _cycleStatePath(tempDir.path, branch),
      ).readAsStringSync();
      expect(stateContent, contains('issue: "31"'));
      expect(stateContent, contains('prompt_fragment_id: idle_to_analyze'));
    });

    test('preserves existing issue when --issue not provided', () async {
      const branch = '31-fix-phase-not-saved';
      _initGitRepo(tempDir.path, branch: branch);
      _writeState(tempDir.path, 'ANALYZE', issue: '31');
      _writeAnalyzeIndex(tempDir.path, branch);
      _writeConfirmations(tempDir.path, branch);
      _writeDiagnosis(tempDir.path, branch, 'updated diagnosis');

      final input = StateTransitionInput(
        currentState: null,
        event: 'complete_analysis',
        workingDirectory: tempDir.path,
      );
      final command = StateTransitionCommand(
        input,
        branchProvider: (_) async => '31-fix-phase-not-saved',
      );

      final output = await command.execute();

      expect(output.allowed, isTrue);
      expect(output.nextState, 'PLAN');

      // Issue should still be there
      final stateContent = File(
        _cycleStatePath(tempDir.path, branch),
      ).readAsStringSync();
      expect(stateContent, contains('issue: "31"'));
      expect(stateContent, contains('prompt_fragment_id: analyze_to_plan'));
    });
  });

  group('StateTransitionOutput.toText()', () {
    test('keeps message-only output when requiredInstructions is null or empty', () {
      final nullInstructionsOutput = StateTransitionOutput(
        allowed: false,
        currentState: 'IDLE',
        event: 'go_execute',
        nextState: null,
        operationsExecuted: const ['validate_transition'],
        promptFragmentId: null,
        requiredRole: null,
        requiredInstructions: null,
        message: 'Transition IDLE --go_execute--> EXECUTE forbidden',
        code: 64,
      );

      final emptyInstructionsOutput = StateTransitionOutput(
        allowed: true,
        currentState: 'PLAN',
        event: 'approve_plan',
        nextState: 'EXECUTE',
        operationsExecuted: const ['validate_transition'],
        promptFragmentId: 'plan_to_execute',
        requiredRole: 'BASHO',
        requiredInstructions: const [],
        message: 'Transition PLAN --approve_plan--> EXECUTE',
        code: 0,
      );

      expect(
        nullInstructionsOutput.toText(),
        equals('Transition IDLE --go_execute--> EXECUTE forbidden'),
      );
      expect(
        emptyInstructionsOutput.toText(),
        equals('Transition PLAN --approve_plan--> EXECUTE'),
      );
    });

    test('surfaces structured metadata for instruction-bearing transitions', () {
      final output = StateTransitionOutput(
        allowed: true,
        currentState: 'ANALYZE',
        event: 'complete_analysis',
        nextState: 'PLAN',
        operationsExecuted: const [
          'validate_transition',
          'validate_prechecks',
        ],
        promptFragmentId: 'analyze_to_plan',
        requiredRole: 'DESCARTES',
        requiredInstructions: const ['doc-write'],
        message: 'Transition ANALYZE --complete_analysis--> PLAN',
        code: 0,
      );

      final text = output.toText();

      expect(text, contains('Transition ANALYZE --complete_analysis--> PLAN'));
      expect(text, contains('required_role'));
      expect(text, contains('DESCARTES'));
      expect(text, contains('required_instructions'));
      expect(text, contains('doc-write'));
      expect(text, contains('prompt_fragment_id'));
      expect(text, contains('analyze_to_plan'));
      expect(
        text,
        isNot(
          contains(
            'Write inside the CLI-created template and keep frontmatter unchanged.',
          ),
        ),
      );
    });
  });
}

void _writeDiagnosis(String root, String branch, String content) {
  final file = File(
    p.join(root, 'cleanrooms', branch, 'analyze', 'diagnosis.md'),
  );
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void _writeAnalyzeIndex(String root, String branch) {
  final file = File(p.join(root, 'cleanrooms', branch, 'analyze', 'index.md'));
  file.createSync(recursive: true);
  file.writeAsStringSync('# Analyze Phase — Index\n');
}

void _writeConfirmations(String root, String branch) {
  final file = File(
    p.join(root, 'cleanrooms', branch, 'analyze', 'confirmations.md'),
  );
  file.createSync(recursive: true);
  file.writeAsStringSync('# Confirmations\n');
}

void _writePlan(String root, String branch, String content) {
  final file = File(p.join(root, 'cleanrooms', branch, 'plan.md'));
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
}

void _writePrePrInspection(
  String root,
  String branch, {
  required String verdict,
  List<String>? consistencyChecks,
  List<String>? completenessChecks,
  List<String>? traceabilityChecks,
  String? rawContent,
}) {
  final file = File(p.join(root, 'cleanrooms', branch, 'pre_pr_inspection.md'));
  file.createSync(recursive: true);
  if (rawContent != null) {
    file.writeAsStringSync(rawContent);
    return;
  }

  final consistency =
      consistencyChecks ?? const ['PASS: asset parity source/build reviewed'];
  final completeness =
      completenessChecks ?? const ['PASS: changed behavior covered by tests'];
  final traceability =
      traceabilityChecks ?? const ['PASS: every code change maps to plan.md'];

  String renderSection(String title, List<String> checks) {
    final buffer = StringBuffer()..writeln('## $title');
    for (final check in checks) {
      buffer.writeln('- $check');
    }
    return buffer.toString().trimRight();
  }

  file.writeAsStringSync(
    [
      'verdict: $verdict',
      '',
      renderSection('Consistency', consistency),
      '',
      renderSection('Completeness', completeness),
      '',
      renderSection('Traceability', traceability),
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

void _writeState(String root, String state, {String? issue, String? branch}) {
  final b = branch ?? _currentBranch(root);
  if (b == null) return; // IDLE / no cycle — nothing to persist.
  final file = File(p.join(root, 'cleanrooms', b, kStateFileName));
  file.createSync(recursive: true);
  final issueLine = issue != null ? 'issue: "$issue"' : 'issue: null';
  file.writeAsStringSync(
    'version: 1\nstate: $state\n$issueLine\nstatus: active\n',
  );
}

String? _currentBranch(String root) {
  final r = Process.runSync('git', [
    'rev-parse',
    '--abbrev-ref',
    'HEAD',
  ], workingDirectory: root);
  if (r.exitCode != 0) return null;
  final b = r.stdout.toString().trim();
  if (b.isEmpty || b == 'HEAD') return null;
  return b;
}

String _cycleStatePath(String root, String branch) =>
    p.join(root, 'cleanrooms', branch, kStateFileName);

void _writeContract(String root) {
  final source = File(
    p.join(Directory.current.path, 'assets', 'fsm', 'transition_contract.yaml'),
  );
  final file = File(p.join(root, 'assets', 'fsm', 'transition_contract.yaml'));
  file.createSync(recursive: true);
  file.writeAsStringSync(source.readAsStringSync());
  final buildMirror = File(
    p.join(root, 'build', 'assets', 'fsm', 'transition_contract.yaml'),
  );
  buildMirror.createSync(recursive: true);
  buildMirror.writeAsStringSync(source.readAsStringSync());

  final inspectionTemplateSource = File(
    p.join(
      Directory.current.path,
      'assets',
      'inspection',
      'pre_pr_inspection_template.md',
    ),
  );
  final inspectionTemplateFile = File(
    p.join(root, 'assets', 'inspection', 'pre_pr_inspection_template.md'),
  );
  inspectionTemplateFile.createSync(recursive: true);
  inspectionTemplateFile.writeAsStringSync(
    inspectionTemplateSource.readAsStringSync(),
  );
  final buildInspectionTemplateFile = File(
    p.join(root, 'build', 'assets', 'inspection', 'pre_pr_inspection_template.md'),
  );
  buildInspectionTemplateFile.createSync(recursive: true);
  buildInspectionTemplateFile.writeAsStringSync(
    inspectionTemplateSource.readAsStringSync(),
  );
}
