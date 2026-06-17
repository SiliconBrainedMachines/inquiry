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
        expect(
          output.toText(),
          contains('Write inside the CLI-created template and keep frontmatter unchanged.'),
        );
        expect(_commitCount(tempDir.path), commitsBefore + 1);

        // Verify state was actually updated
        final stateContent = File(
          _cycleStatePath(tempDir.path, branch),
        ).readAsStringSync();
        expect(stateContent, contains('state: PLAN'));
        expect(stateContent, contains('prompt_fragment_id: analyze_to_plan'));

        final runTrace = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
        );
        expect(runTrace.existsSync(), isTrue);
        final traceContent = runTrace.readAsStringSync();
        expect(traceContent, contains('event_class: sensor_run'));
        expect(traceContent, contains('event_class: tool_activity'));
        expect(traceContent, contains('tool_class: git'));
        expect(traceContent, contains('command_family: add'));
        expect(traceContent, contains('command_family: commit'));
        expect(traceContent, contains('gate: commit_analysis_boundary'));
        expect(traceContent, contains('verdict: APPROVED'));
        expect(
          traceContent,
          contains(
            'authority: "cleanrooms/51-idle-execution-guardrails/analyze"',
          ),
        );
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

        final runTrace = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
        );
        expect(runTrace.existsSync(), isTrue);
        final traceContent = runTrace.readAsStringSync();
        expect(traceContent, contains('event_class: sensor_run'));
        expect(traceContent, contains('gate: diagnosis_exists'));
        expect(traceContent, contains('gate: index_exists'));
        expect(traceContent, contains('sensor_category: pre_transition'));
        expect(traceContent, contains('verdict: APPROVED'));
        expect(traceContent, contains('verdict: MISSING'));
        expect(traceContent, contains('transition_event: complete_analysis'));
        expect(traceContent, contains('outcome: blocked'));
      },
    );

    test('fails precheck when diagnosis lacks evidence-first structure', () async {
      const branch = '51-idle-execution-guardrails';
      _initGitRepo(tempDir.path, branch: branch);
      _writeState(tempDir.path, 'ANALYZE', issue: '51');
      _writeAnalyzeIndex(tempDir.path, branch);
      _writeConfirmations(tempDir.path, branch);
      final diagnosisFile = File(
        p.join(tempDir.path, 'cleanrooms', branch, 'analyze', 'diagnosis.md'),
      )..createSync(recursive: true);
      diagnosisFile.writeAsStringSync('# Diagnosis\n\nUnstructured draft\n');

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'complete_analysis',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => branch,
      ).execute();

      expect(output.allowed, isFalse);
      expect(
        output.message,
        contains('ERROR_PRECONDITION_DIAGNOSIS_STRUCTURE_INVALID'),
      );
      expect(output.message, contains('Evidence'));
      expect(output.message, contains('Hypotheses'));

      final traceContent = File(
        p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
      ).readAsStringSync();
      expect(traceContent, contains('gate: diagnosis_structured'));
      expect(traceContent, contains('verdict: INVALID'));
      expect(
        traceContent,
        contains(
          'authority: "cleanrooms/51-idle-execution-guardrails/analyze/diagnosis.md"',
        ),
      );
    });

    test(
      'fails precheck when diagnosis evidence still contains only bootstrap placeholder',
      () async {
        const branch = '51-idle-execution-guardrails';
        _initGitRepo(tempDir.path, branch: branch);
        _writeState(tempDir.path, 'ANALYZE', issue: '51');
        _writeAnalyzeIndex(tempDir.path, branch);
        _writeConfirmations(tempDir.path, branch);
        final diagnosisFile = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'analyze', 'diagnosis.md'),
        )..createSync(recursive: true);
        diagnosisFile.writeAsStringSync(
          '# Diagnosis\n\n'
          '## Evidence\n'
          '- Record observed repo, artifact, test, runtime, or research evidence here.\n\n'
          '## Hypotheses\n'
          '- Working hypothesis\n\n'
          '## Constraints\n'
          '- No additional constraints\n\n'
          '## Open Questions\n'
          '- None\n',
        );

        final output = await StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'complete_analysis',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => branch,
        ).execute();

        expect(output.allowed, isFalse);
        expect(
          output.message,
          contains('ERROR_PRECONDITION_DIAGNOSIS_EVIDENCE_MISSING'),
        );

        final traceContent = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
        ).readAsStringSync();
        expect(traceContent, contains('gate: diagnosis_evidence_present'));
        expect(traceContent, contains('verdict: INVALID'));
        expect(
          traceContent,
          contains(
            'authority: "cleanrooms/51-idle-execution-guardrails/analyze/diagnosis.md"',
          ),
        );
      },
    );

    test(
      'fails precheck when diagnosis evidence has no verifiable handle',
      () async {
        const branch = '51-idle-execution-guardrails';
        _initGitRepo(tempDir.path, branch: branch);
        _writeState(tempDir.path, 'ANALYZE', issue: '51');
        _writeAnalyzeIndex(tempDir.path, branch);
        _writeConfirmations(tempDir.path, branch);
        final diagnosisFile = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'analyze', 'diagnosis.md'),
        )..createSync(recursive: true);
        // Evidence is concrete prose but cites no re-checkable handle
        // (no file:line, URL, or inline code).
        diagnosisFile.writeAsStringSync(
          '# Diagnosis\n\n'
          '## Evidence\n'
          '- Observed that the benchmark run did not reach the END state.\n\n'
          '## Hypotheses\n'
          '- Working hypothesis\n\n'
          '## Constraints\n'
          '- No additional constraints\n\n'
          '## Open Questions\n'
          '- None\n',
        );

        final output = await StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'complete_analysis',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => branch,
        ).execute();

        expect(output.allowed, isFalse);
        expect(
          output.message,
          contains('ERROR_PRECONDITION_DIAGNOSIS_EVIDENCE_UNVERIFIABLE'),
        );

        final traceContent = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
        ).readAsStringSync();
        expect(traceContent, contains('gate: diagnosis_evidence_verifiable'));
        expect(traceContent, contains('verdict: INVALID'));
      },
    );

    test(
      'passes when each evidence bullet carries a verifiable handle',
      () async {
        const branch = '51-idle-execution-guardrails';
        _initGitRepo(tempDir.path, branch: branch);
        _writeState(tempDir.path, 'ANALYZE', issue: '51');
        _writeAnalyzeIndex(tempDir.path, branch);
        _writeConfirmations(tempDir.path, branch);
        final diagnosisFile = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'analyze', 'diagnosis.md'),
        )..createSync(recursive: true);
        diagnosisFile.writeAsStringSync(
          '# Diagnosis\n\n'
          '## Evidence\n'
          '- OpenCode adapter paths match the docs — `lib/hosts/opencode_adapter.dart:10`.\n'
          '- OpenCode docs confirm the skill path — https://opencode.ai/docs/skills/.\n\n'
          '## Hypotheses\n'
          '- Working hypothesis\n\n'
          '## Constraints\n'
          '- No additional constraints\n\n'
          '## Open Questions\n'
          '- None\n',
        );

        final output = await StateTransitionCommand(
          StateTransitionInput(
            currentState: null,
            event: 'complete_analysis',
            workingDirectory: tempDir.path,
          ),
          branchProvider: (_) async => branch,
        ).execute();

        expect(output.allowed, isTrue);
      },
    );

    test('records retry trace when a blocked ANALYZE handoff is attempted again', () async {
      const branch = '51-idle-execution-guardrails';
      _initGitRepo(tempDir.path, branch: branch);
      _writeState(tempDir.path, 'ANALYZE', issue: '51');
      _writeAnalyzeIndex(tempDir.path, branch);
      _writeConfirmations(tempDir.path, branch);
      final diagnosisFile = File(
        p.join(tempDir.path, 'cleanrooms', branch, 'analyze', 'diagnosis.md'),
      )..createSync(recursive: true);
      diagnosisFile.writeAsStringSync('# Diagnosis\n\nUnstructured draft\n');

      final first = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'complete_analysis',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => branch,
      ).execute();
      expect(first.allowed, isFalse);

      _writeDiagnosis(tempDir.path, branch, 'diagnosis repaired');

      final second = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'complete_analysis',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => branch,
      ).execute();
      expect(second.allowed, isTrue);

      final traceContent = File(
        p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
      ).readAsStringSync();
      expect(traceContent, contains('event_class: retry'));
      expect(traceContent, contains('phase: ANALYZE'));
      expect(traceContent, contains('transition_event: complete_analysis'));
      expect(traceContent, contains('retry_count: 1'));
      expect(
        traceContent,
        contains(
          'triggering_failure: "ERROR_PRECONDITION_DIAGNOSIS_STRUCTURE_INVALID: diagnosis.md must contain Evidence, Hypotheses, Constraints, and Open Questions sections for current issue branch; missing: Evidence, Hypotheses, Constraints, Open Questions"',
        ),
      );
    });

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

        final runTrace = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
        );
        expect(runTrace.existsSync(), isTrue);
        final traceContent = runTrace.readAsStringSync();
        expect(traceContent, contains('event_class: sensor_run'));
        expect(traceContent, contains('gate: commit_analysis_boundary'));
        expect(traceContent, contains('verdict: FAILED'));
        expect(
          traceContent,
          contains(
            'authority: "cleanrooms/51-idle-execution-guardrails/analyze"',
          ),
        );
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

    test(
      'blocks IDLE to ANALYZE when branch does not match active issue',
      () async {
        _initGitRepo(tempDir.path, branch: 't1-pilot-h');
        _writeState(tempDir.path, 'IDLE', issue: '231');

        final input = StateTransitionInput(
          currentState: null,
          event: 'start_analyze',
          workingDirectory: tempDir.path,
        );
        final command = StateTransitionCommand(
          input,
          branchProvider: (_) async => 't1-pilot-h',
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

      final runTrace = File(
        p.join(
          tempDir.path,
          'cleanrooms',
          '152-feature-branch',
          'run_trace.yaml',
        ),
      );
      expect(runTrace.existsSync(), isTrue);
      final traceContent = runTrace.readAsStringSync();
      expect(traceContent, contains('task_id: "152"'));
      expect(traceContent, contains('event_class: sensor_run'));
      expect(traceContent, contains('event_class: tool_activity'));
      expect(traceContent, contains('gate: issue_selected_or_created'));
      expect(traceContent, contains('gate: feature_branch_selected'));
      expect(traceContent, contains('sensor_category: runtime'));
      expect(traceContent, contains('verdict: APPROVED'));
      expect(traceContent, contains('transition_event: start_analyze'));
      expect(traceContent, contains('tool_class: gh'));
      expect(traceContent, contains('command_family: issue_view'));
      expect(traceContent, contains('outcome: allowed'));
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
        expect(output.requiredInstructions, ['coding-manifesto-review']);
        expect(output.toText(), startsWith(output.message));
        expect(_commitCount(tempDir.path), commitsBefore + 1);

        final stateContent = File(
          _cycleStatePath(tempDir.path, branch),
        ).readAsStringSync();
        expect(stateContent, contains('state: EXECUTE'));
        expect(stateContent, contains('prompt_fragment_id: plan_to_execute'));

        final runTrace = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
        );
        expect(runTrace.existsSync(), isTrue);
        final traceContent = runTrace.readAsStringSync();
        expect(traceContent, contains('task_id: "51"'));
        expect(traceContent, contains('event_class: sensor_run'));
        expect(traceContent, contains('event_class: tool_activity'));
        expect(traceContent, contains('tool_class: git'));
        expect(traceContent, contains('command_family: add'));
        expect(traceContent, contains('command_family: commit'));
        expect(traceContent, contains('gate: plan_approved'));
        expect(traceContent, contains('gate: commit_plan_boundary'));
        expect(traceContent, contains('sensor_category: pre_transition'));
        expect(traceContent, contains('verdict: APPROVED'));
        expect(
          traceContent,
          contains(
            'authority: "cleanrooms/51-idle-execution-guardrails/plan.md"',
          ),
        );
        expect(traceContent, contains('transition_event: approve_plan'));
        expect(traceContent, contains('outcome: allowed'));
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

        final runTrace = File(
          p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
        );
        expect(runTrace.existsSync(), isTrue);
        final traceContent = runTrace.readAsStringSync();
        expect(traceContent, contains('event_class: transition'));
        expect(traceContent, contains('event_class: sensor_run'));
        expect(traceContent, contains('event_class: tool_activity'));
        expect(traceContent, contains('tool_class: git'));
        expect(traceContent, contains('command_family: add'));
        expect(traceContent, contains('command_family: commit'));
        expect(traceContent, contains('outcome: failed'));
        expect(traceContent, contains('transition_event: approve_plan'));
        expect(traceContent, contains('gate: commit_plan_boundary'));
        expect(traceContent, contains('verdict: FAILED'));
        expect(traceContent, contains('to_state: EXECUTE'));
        expect(traceContent, contains('outcome: blocked'));
        expect(traceContent, contains('event_class: block'));
        expect(traceContent, contains('blocking_boundary: boundary_commit'));
        expect(
          traceContent,
          contains(
            'authoritative_surface: "cleanrooms/51-idle-execution-guardrails/plan.md"',
          ),
        );
      },
    );

    test(
      'blocks PLAN -> EXECUTE on non-main branch that is not issue-linked',
      () async {
        const branch = 't1-pilot-h';

        _initGitRepo(tempDir.path, branch: branch);
        _writePlan(tempDir.path, branch, '# plan\n');
        _writeState(tempDir.path, 'PLAN', issue: '231');

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
        expect(output.message, contains('ERROR_PRECONDITION_BRANCH_POLICY'));
      },
    );

    test('continuing EXECUTE carries the manifesto review instruction', () async {
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
      expect(output.requiredInstructions, ['coding-manifesto-review']);
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
      expect(
        output.toText(),
        contains(
          'Confirm the already-proposed semver bump and stop if explicit user approval is still missing.',
        ),
      );
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
      expect(
        inspectionReport,
        contains(
          'PASS: inspection metadata matches active issue "51" and branch "51-idle-execution-guardrails"',
        ),
      );
      expect(
        inspectionReport,
        contains('PASS: overhead summary event counts transition='),
      );
      expect(
        inspectionReport,
        contains('PASS: overhead summary found no blocking boundaries before END'),
      );
      expect(
        inspectionReport,
        contains('WARN: overhead summary attributes host-boundary activity as ['),
      );
    });

    test('END inspection report summarizes model-bound prompt input when traced', () async {
      const branch = '51-idle-execution-guardrails';
      _initGitRepo(tempDir.path, branch: branch);
      _writeState(tempDir.path, 'EXECUTE', issue: '51');
      File(
        p.join(tempDir.path, 'cleanrooms', branch, 'run_trace.yaml'),
      ).writeAsStringSync(
        'events:\n'
        '  - recorded_at: "2026-05-31T10:00:00.000Z"\n'
        '    task_id: "51"\n'
        '    branch: $branch\n'
        '    event_class: model_activity\n'
        '    phase: ANALYZE\n'
        '    ape_name: socrates\n'
        '    model_surface: prompt_input\n'
        '    prompt_characters: 840\n'
        '    estimated_input_tokens: 210\n'
        '    token_estimate_basis: chars_div_4_ceil\n'
        '    assembly_duration_seconds: 0.012\n'
        '  - recorded_at: "2026-05-31T10:00:01.000Z"\n'
        '    task_id: "51"\n'
        '    branch: $branch\n'
        '    event_class: tool_activity\n'
        '    phase: ANALYZE\n'
        '    transition_event: start_analyze\n'
        '    tool_class: gh\n'
        '    command_family: issue_view\n'
        '    outcome: succeeded\n',
      );

      final output = await StateTransitionCommand(
        StateTransitionInput(
          currentState: null,
          event: 'finish_execute',
          workingDirectory: tempDir.path,
        ),
        branchProvider: (_) async => branch,
      ).execute();

      expect(output.allowed, isTrue);
      final inspectionReport = File(
        p.join(tempDir.path, 'cleanrooms', branch, 'pre_pr_inspection.md'),
      ).readAsStringSync();
      expect(inspectionReport, contains('model_activity=1'));
      expect(
        inspectionReport,
        contains(
          'PASS: overhead summary estimates model-bound prompt input as [socrates=210 est_tokens/840 chars/0.012s assembly]',
        ),
      );
      expect(
        inspectionReport,
        contains('leaves only remote model runtime/caching cost unattributed'),
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

    test('seeded END inspection report records automatic completeness failures', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'EXECUTE', issue: '51');
      _writePlan(
        tempDir.path,
        '51-idle-execution-guardrails',
        '# Plan\n- [ ] pending execution step\n',
      );

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
      expect(
        inspectionReport,
        contains('FAIL: unchecked plan checkbox remains'),
      );
      expect(
        inspectionReport,
        contains('cleanrooms/51-idle-execution-guardrails/plan.md:2'),
      );
      expect(
        inspectionReport,
        contains('PASS: overhead summary event counts transition='),
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

      final runTrace = File(
        p.join(
          tempDir.path,
          'cleanrooms',
          '51-idle-execution-guardrails',
          'run_trace.yaml',
        ),
      );
      expect(runTrace.existsSync(), isTrue);
      final traceContent = runTrace.readAsStringSync();
      expect(traceContent, contains('event_class: sensor_run'));
      expect(traceContent, contains('gate: pre_pr_inspection_approved'));
      expect(traceContent, contains('verdict: APPROVED'));
      expect(
        traceContent,
        contains(
          'authority: "cleanrooms/51-idle-execution-guardrails/pre_pr_inspection.md"',
        ),
      );
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

      final runTrace = File(
        p.join(
          tempDir.path,
          'cleanrooms',
          '51-idle-execution-guardrails',
          'run_trace.yaml',
        ),
      );
      expect(runTrace.existsSync(), isTrue);
      final traceContent = runTrace.readAsStringSync();
      expect(traceContent, contains('event_class: transition'));
      expect(traceContent, contains('event_class: sensor_run'));
      expect(traceContent, contains('transition_event: pr_ready'));
      expect(traceContent, contains('gate: pre_pr_inspection_approved'));
      expect(traceContent, contains('verdict: MISSING'));
      expect(traceContent, contains('to_state: EVOLUTION'));
      expect(traceContent, contains('outcome: blocked'));
      expect(traceContent, contains('event_class: block'));
      expect(traceContent, contains('blocking_boundary: end_pre_pr_gate'));
      expect(
        traceContent,
        contains(
          'authoritative_surface: "cleanrooms/51-idle-execution-guardrails/pre_pr_inspection.md"',
        ),
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

    test('blocks END pr_ready when automatic completeness check detects unfinished plan work', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');
      _writePlan(
        tempDir.path,
        '51-idle-execution-guardrails',
        '# Plan\n- [ ] pending execution step\n',
      );
      _writePrePrInspection(
        tempDir.path,
        '51-idle-execution-guardrails',
        verdict: 'APPROVED',
        consistencyChecks: const ['PASS: asset parity source/build reviewed'],
        completenessChecks: const ['PASS: changed behavior covered by tests'],
        traceabilityChecks: const ['PASS: every code change maps to plan.md'],
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
        contains('FAIL: unchecked plan checkbox remains'),
      );
      expect(
        inspectionReport,
        contains('cleanrooms/51-idle-execution-guardrails/plan.md:2'),
      );
    });

    test('blocks END pr_ready when automatic traceability check detects stale report metadata', () async {
      _initGitRepo(tempDir.path, branch: '51-idle-execution-guardrails');
      _writeState(tempDir.path, 'END', issue: '51');
      _writePlan(
        tempDir.path,
        '51-idle-execution-guardrails',
        '# Plan\n- [x] completed execution step\n',
      );
      _writePrePrInspection(
        tempDir.path,
        '51-idle-execution-guardrails',
        verdict: 'APPROVED',
        reportIssue: '99',
        reportBranch: '99-other-branch',
        consistencyChecks: const ['PASS: asset parity source/build reviewed'],
        completenessChecks: const ['PASS: changed behavior covered by tests'],
        traceabilityChecks: const ['PASS: every code change maps to plan.md'],
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
        contains('FAIL: inspection issue metadata "99" does not match active issue "51"'),
      );
      expect(
        inspectionReport,
        contains('FAIL: inspection branch metadata "99-other-branch" does not match active branch "51-idle-execution-guardrails"'),
      );
      expect(
        inspectionReport,
        contains('cleanrooms/51-idle-execution-guardrails/pre_pr_inspection.md:5'),
      );
      expect(
        inspectionReport,
        contains('cleanrooms/51-idle-execution-guardrails/pre_pr_inspection.md:6'),
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
        requiredRole: 'ADA',
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
        instructionSummary:
            'Write inside the CLI-created template and keep frontmatter unchanged.',
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
      expect(text, contains('instruction_summary:'));
      expect(
        text,
        contains(
          'Write inside the CLI-created template and keep frontmatter unchanged.',
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
  file.writeAsStringSync(
    '# Diagnosis\n'
    '\n'
    '## Evidence\n'
    '- $content (`lib/example.dart:1`)\n'
    '\n'
    '## Hypotheses\n'
    '- Hypothesis placeholder\n'
    '\n'
    '## Constraints\n'
    '- Constraint placeholder\n'
    '\n'
    '## Open Questions\n'
    '- None\n',
  );
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
  String? reportIssue,
  String? reportBranch,
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

    final issue = reportIssue ?? branch.split('-').first;
    final branchMetadata = reportBranch ?? branch;
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
      '# END Pre-PR Inspection',
      '',
      'issue: "$issue"',
      'branch: "$branchMetadata"',
      'generated_at: "2026-06-01T00:00:00Z"',
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
