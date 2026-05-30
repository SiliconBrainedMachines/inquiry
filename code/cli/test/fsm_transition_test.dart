import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

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

    test('returns prompt descriptor for ANALYZE -> PLAN after boundary commit',
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
      expect(_commitCount(tempDir.path), commitsBefore + 1);

      // Verify state.yaml was actually updated
      final stateContent = File(
        p.join(tempDir.path, '.inquiry', 'state.yaml'),
      ).readAsStringSync();
      expect(stateContent, contains('state: PLAN'));
      expect(stateContent, contains('prompt_fragment_id: analyze_to_plan'));
    });

    test('fails precheck when ANALYZE corpus lacks confirmations and index',
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
    });

    test('fails closed when ANALYZE -> PLAN cannot create boundary commit',
        () async {
      const branch = '51-idle-execution-guardrails';

      _initGitRepo(tempDir.path, branch: branch);
      _writeAnalyzeIndex(tempDir.path, branch);
      _writeConfirmations(tempDir.path, branch);
      _writeDiagnosis(tempDir.path, branch, 'diagnosis already committed');
      _git(
        tempDir.path,
        ['add', '--', p.posix.join('cleanrooms', branch, 'analyze')],
      );
      _git(
        tempDir.path,
        [
          'commit',
          '-m',
          'analysis ready',
          '--only',
          '--',
          p.posix.join('cleanrooms', branch, 'analyze'),
        ],
      );
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
        p.join(tempDir.path, '.inquiry', 'state.yaml'),
      ).readAsStringSync();
      expect(stateContent, contains('state: ANALYZE'));
    });

    test('fails precheck when commitment needs issue/branch and issue missing',
        () async {
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
    });

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

    test('blocks IDLE to ANALYZE when issue is ready but branch is not',
        () async {
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
    });

    test('allows IDLE to ANALYZE with issue and feature branch', () async {
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

    test('transitions PLAN -> EXECUTE only after plan boundary commit', () async {
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
      expect(_commitCount(tempDir.path), commitsBefore + 1);

      final stateContent = File(
        p.join(tempDir.path, '.inquiry', 'state.yaml'),
      ).readAsStringSync();
      expect(stateContent, contains('state: EXECUTE'));
      expect(stateContent, contains('prompt_fragment_id: plan_to_execute'));
    });

    test('fails closed when PLAN -> EXECUTE cannot create boundary commit',
        () async {
      const branch = '51-idle-execution-guardrails';
      final planPath = p.posix.join('cleanrooms', branch, 'plan.md');

      _initGitRepo(tempDir.path, branch: branch);
      _writePlan(tempDir.path, branch, '# committed plan\n');
      _git(tempDir.path, ['add', '--', planPath]);
      _git(
        tempDir.path,
        ['commit', '-m', 'plan ready', '--only', '--', planPath],
      );
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
        p.join(tempDir.path, '.inquiry', 'state.yaml'),
      ).readAsStringSync();
      expect(stateContent, contains('state: PLAN'));
    });

    test('continuing EXECUTE does not require startup instructions', () async {
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
      expect(output.requiredInstructions, ['issue-end']);
    });

    test('allows END to create PR and enter EVOLUTION', () async {
      _writeState(tempDir.path, 'END', issue: '51');

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
      expect(output.requiredInstructions, ['issue-end']);
    });

    test('persists --issue flag in state.yaml on transition', () async {
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

      // Verify issue was persisted in state.yaml
      final stateContent = File(
        p.join(tempDir.path, '.inquiry', 'state.yaml'),
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
        p.join(tempDir.path, '.inquiry', 'state.yaml'),
      ).readAsStringSync();
      expect(stateContent, contains('issue: "31"'));
      expect(stateContent, contains('prompt_fragment_id: analyze_to_plan'));
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
  final file = File(
    p.join(root, 'cleanrooms', branch, 'analyze', 'index.md'),
  );
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

void _writeState(String root, String state, {String? issue}) {
  final file = File(p.join(root, '.inquiry', 'state.yaml'));
  file.createSync(recursive: true);
  final issueLine = issue != null ? 'issue: "$issue"' : 'issue: null';
  file.writeAsStringSync('state: $state\n$issueLine\n');
}

void _writeContract(String root) {
  final source = File(
    p.join(
      Directory.current.path,
      'assets',
      'fsm',
      'transition_contract.yaml',
    ),
  );
  final file = File(p.join(root, 'assets', 'fsm', 'transition_contract.yaml'));
  file.createSync(recursive: true);
  file.writeAsStringSync(source.readAsStringSync());
}
