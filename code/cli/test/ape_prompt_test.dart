import 'dart:io';

import 'package:inquiry_cli/modules/ape/commands/prompt.dart';
import 'package:inquiry_cli/modules/ape/inquiry_state.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tmpDir;
  late String stateFilePath;

  const branch = '145-test-branch';

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('ape_prompt_test_');

    // Cycle-local state lives at cleanrooms/<branch>/.iq.state.yaml.
    Directory(p.join(tmpDir.path, '.inquiry')).createSync();
    _initGitRepo(tmpDir.path, branch: branch);
    Directory(
      p.join(tmpDir.path, 'cleanrooms', branch),
    ).createSync(recursive: true);
    stateFilePath = p.join(tmpDir.path, 'cleanrooms', branch, kStateFileName);

    // Copy assets/apes/ from real assets
    final apesDir = Directory(p.join(tmpDir.path, 'assets', 'apes'));
    apesDir.createSync(recursive: true);
    for (final name in ['socrates', 'dewey', 'descartes', 'basho', 'darwin']) {
      File(
        'assets/apes/$name.yaml',
      ).copySync(p.join(apesDir.path, '$name.yaml'));
    }

    final statesDir = Directory(p.join(tmpDir.path, 'assets', 'fsm', 'states'));
    statesDir.createSync(recursive: true);
    for (final name in [
      'idle',
      'analyze',
      'plan',
      'execute',
      'end',
      'evolution',
    ]) {
      File(
        'assets/fsm/states/$name.yaml',
      ).copySync(p.join(statesDir.path, '$name.yaml'));
    }

    final fsmDir = Directory(p.join(tmpDir.path, 'assets', 'fsm'));
    fsmDir.createSync(recursive: true);
    File(
      'assets/fsm/transition_contract.yaml',
    ).copySync(p.join(fsmDir.path, 'transition_contract.yaml'));

    final instructionsDir = Directory(
      p.join(tmpDir.path, 'assets', 'instructions'),
    );
    instructionsDir.createSync(recursive: true);
    for (final name in [
      'doc-read',
      'doc-write',
      'issue-create',
      'issue-end',
      'issue-start',
    ]) {
      File(
        'assets/instructions/$name.md',
      ).copySync(p.join(instructionsDir.path, '$name.md'));
    }
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  void writeState(String state, {String? issue, String? promptFragmentId}) {
    File(stateFilePath).writeAsStringSync(
      'state: $state\n'
      'issue: ${issue ?? 'null'}\n',
      mode: FileMode.write,
    );

    if (promptFragmentId != null) {
      File(stateFilePath).writeAsStringSync(
        'prompt_fragment_id: $promptFragmentId\n',
        mode: FileMode.append,
      );
    }
  }

  void writeStateWithApe(
    String state, {
    String? issue,
    String? promptFragmentId,
    required String apeName,
    required String apeState,
  }) {
    File(stateFilePath).writeAsStringSync(
      'state: $state\n'
      'issue: ${issue != null ? '"$issue"' : 'null'}\n'
      '${promptFragmentId != null ? 'prompt_fragment_id: $promptFragmentId\n' : ''}'
      'ape:\n'
      '  name: $apeName\n'
      '  state: $apeState\n',
    );
  }

  group('ApePromptCommand', () {
    group('successful prompt assembly', () {
      test('socrates in ANALYZE returns base prompt', () async {
        writeState('ANALYZE', issue: '99');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('socrates'));
        expect(result.fsmState, equals('ANALYZE'));
        expect(result.subState, isNull);
        expect(result.prompt, contains('SOCRATES'));
        expect(result.prompt, contains('Socratic method'));
      });

      test(
        'socrates with sub-state clarification appends state prompt',
        () async {
          writeState('ANALYZE');
          final cmd = ApePromptCommand(
            ApePromptInput(
              name: 'socrates',
              subState: 'clarification',
              workingDirectory: tmpDir.path,
            ),
          );
          final result = await cmd.execute();

          expect(result.subState, equals('clarification'));
          expect(result.prompt, contains('SOCRATES'));
          expect(result.prompt, contains('Clarification questions'));
        },
      );

      test('descartes in PLAN returns base prompt', () async {
        writeState('PLAN');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'descartes', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('descartes'));
        expect(result.fsmState, equals('PLAN'));
        expect(result.prompt, contains('DESCARTES'));
        expect(result.prompt, contains('scientific method'));
        expect(result.prompt, contains('enumerate every construction site'));
        expect(result.prompt, contains('object literals, factory returns'));
      });

      test(
        'injects transition-owned instruction summary when prompt_fragment_id exists',
        () async {
          writeState('PLAN', issue: '145', promptFragmentId: 'analyze_to_plan');

          final cmd = ApePromptCommand(
            ApePromptInput(
              name: 'descartes',
              subState: 'decomposition',
              workingDirectory: tmpDir.path,
            ),
          );
          final result = await cmd.execute();

          final stateIndex = result.prompt.indexOf('FOCUS: Division.');
          final instructionIndex = result.prompt.indexOf(
            'Write inside the CLI-created template and keep frontmatter unchanged.',
          );
          final contractIndex = result.prompt.indexOf(
            '## Phase-Owned Operational Contract',
          );

          expect(instructionIndex, greaterThan(stateIndex));
          expect(contractIndex, greaterThan(instructionIndex));
          expect(result.prompt, isNot(contains('## When to Use')));
        },
      );

      test(
        'does not inject transition-owned summary when prompt_fragment_id is absent',
        () async {
          writeState('PLAN', issue: '145');

          final cmd = ApePromptCommand(
            ApePromptInput(
              name: 'descartes',
              subState: 'decomposition',
              workingDirectory: tmpDir.path,
            ),
          );
          final result = await cmd.execute();

          expect(
            result.prompt,
            isNot(
              contains(
                'Write inside the CLI-created template and keep frontmatter unchanged.',
              ),
            ),
          );
        },
      );

      test('basho in EXECUTE returns base prompt', () async {
        writeState('EXECUTE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'basho', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('basho'));
        expect(result.fsmState, equals('EXECUTE'));
        expect(result.prompt, contains('BASHŌ'));
      });

      test('basho in END is also active', () async {
        writeState('END');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'basho', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('basho'));
        expect(result.fsmState, equals('END'));
      });

      test('darwin in EVOLUTION returns base prompt', () async {
        writeState('EVOLUTION');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'darwin', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('darwin'));
        expect(result.fsmState, equals('EVOLUTION'));
        expect(result.prompt, contains('DARWIN'));
        expect(result.prompt, contains('natural selection'));
      });

      test('dewey in IDLE returns base prompt', () async {
        writeStateWithApe('IDLE', apeName: 'dewey', apeState: 'evaluate_scope');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'dewey', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.apeName, equals('dewey'));
        expect(result.fsmState, equals('IDLE'));
        expect(result.subState, equals('evaluate_scope'));
        expect(result.prompt, contains('well-formed issue'));
        expect(result.prompt, contains('FOCUS: Scope evaluation.'));
      });
    });

    group('MISSING_NAME', () {
      test('throws CommandException when name flag is null', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: null, workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('MISSING_NAME'))
                .having(
                  (e) => e.exitCode,
                  'exitCode',
                  equals(ExitCode.validationFailed),
                ),
          ),
        );
      });
    });

    group('MISSING_NAME', () {
      test('throws CommandException when name flag is null', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: null, workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('MISSING_NAME'))
                .having(
                  (e) => e.exitCode,
                  'exitCode',
                  equals(ExitCode.validationFailed),
                ),
          ),
        );
      });
    });

    group('APE_NOT_FOUND', () {
      test('throws for nonexistent APE', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'nonexistent', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_FOUND'))
                .having(
                  (e) => e.exitCode,
                  'exitCode',
                  equals(ExitCode.notFound),
                ),
          ),
        );
      });
    });

    group('APE_NOT_ACTIVE', () {
      test('socrates in EXECUTE throws not active', () async {
        writeState('EXECUTE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_ACTIVE'))
                .having(
                  (e) => e.exitCode,
                  'exitCode',
                  equals(ExitCode.conflict),
                ),
          ),
        );
      });

      test('descartes in ANALYZE throws not active', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'descartes', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_ACTIVE'))
                .having(
                  (e) => e.exitCode,
                  'exitCode',
                  equals(ExitCode.conflict),
                ),
          ),
        );
      });

      test('socrates-idle in IDLE throws not active', () async {
        writeStateWithApe('IDLE', apeName: 'dewey', apeState: 'evaluate_scope');
        File(
          p.join(tmpDir.path, 'assets', 'apes', 'socrates-idle.yaml'),
        ).writeAsStringSync(
          File('assets/apes/dewey.yaml').readAsStringSync().replaceFirst(
            'name: dewey',
            'name: socrates-idle',
          ),
        );
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates-idle', workingDirectory: tmpDir.path),
        );

        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_ACTIVE'))
                .having(
                  (e) => e.exitCode,
                  'exitCode',
                  equals(ExitCode.conflict),
                ),
          ),
        );
      });
    });

    group('unknown sub-state', () {
      test('throws for invalid sub-state name', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'nonexistent_state',
            workingDirectory: tmpDir.path,
          ),
        );

        expect(() => cmd.execute(), throwsA(isA<ArgumentError>()));
      });
    });

    group('output format', () {
      test('toJson includes all fields', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'evidence',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();
        final json = result.toJson();

        expect(json['ape'], equals('socrates'));
        expect(json['fsm_state'], equals('ANALYZE'));
        expect(json['sub_state'], equals('evidence'));
        expect(json['prompt'], isA<String>());
      });

      test('toText returns raw prompt', () async {
        writeState('PLAN');
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'descartes', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.toText(), equals(result.prompt));
      });
    });

    group('missing .inquiry/state.yaml', () {
      test('defaults to IDLE when no state file exists', () async {
        // Delete the state file if it exists
        final stateFile = File(stateFilePath);
        if (stateFile.existsSync()) stateFile.deleteSync();

        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );

        // In IDLE, no APE is active → should throw APE_NOT_ACTIVE
        expect(
          () => cmd.execute(),
          throwsA(
            isA<CommandException>()
                .having((e) => e.code, 'code', equals('APE_NOT_ACTIVE'))
                .having(
                  (e) => e.exitCode,
                  'exitCode',
                  equals(ExitCode.conflict),
                ),
          ),
        );
      });
    });

    group('validate', () {
      test('returns null for empty name (validation moved to execute)', () {
        final cmd = ApePromptCommand(
          ApePromptInput(name: '', workingDirectory: tmpDir.path),
        );
        expect(cmd.validate(), isNull);
      });

      test('returns null for valid name', () {
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );
        expect(cmd.validate(), isNull);
      });
    });

    group('prompt fidelity — regression vs monolith', () {
      test('socrates prompt covers key Socratic method concepts', () async {
        writeState('ANALYZE');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'clarification',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('EPISTEMIC HUMILITY'));
        expect(result.prompt, contains('MIDWIFE OF IDEAS'));
        expect(result.prompt, contains('Clarification questions'));
        expect(result.prompt, contains('## Phase-Owned Operational Contract'));
        expect(result.prompt, contains('diagnosis.md'));
      });

      test('descartes prompt covers Cartesian method', () async {
        writeState('PLAN');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'descartes',
            subState: 'decomposition',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('EVIDENCE'));
        expect(result.prompt, contains('DIVISION'));
        expect(result.prompt, contains('experimental plan'));
        expect(result.prompt, contains('Division'));
      });

      test('basho prompt covers implementation principles', () async {
        writeState('EXECUTE');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'basho',
            subState: 'implement',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('用の美'));
        expect(result.prompt, contains('NOTHING WASTED'));
        expect(result.prompt, contains('Implementation'));
      });

      test('darwin prompt covers evolution process', () async {
        writeState('EVOLUTION');
        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'darwin',
            subState: 'observe',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('natural selection'));
        expect(
          result.prompt,
          contains('ideal Analyze -> Plan -> Execute -> End loop'),
        );
        expect(
          result.prompt,
          contains(
            'EVOLUTION owns the repository procedure for issue search/comment/create and metrics collection.',
          ),
        );
        expect(result.prompt, contains('Observation'));
      });
    });

    group('auto-read sub-state from state.yaml', () {
      test('reads ape.state when no --state flag', () async {
        writeStateWithApe(
          'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'evidence',
        );

        final cmd = ApePromptCommand(
          ApePromptInput(name: 'socrates', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.subState, equals('evidence'));
        expect(result.prompt, contains('Evidence'));
      });

      test('--state flag overrides ape.state from state.yaml', () async {
        writeStateWithApe(
          'ANALYZE',
          issue: '145',
          apeName: 'socrates',
          apeState: 'evidence',
        );

        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'clarification',
            workingDirectory: tmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.subState, equals('clarification'));
        expect(result.prompt, contains('Clarification'));
      });

      test('works with basho ape sub-state', () async {
        writeStateWithApe(
          'EXECUTE',
          issue: '145',
          apeName: 'basho',
          apeState: 'test',
        );

        final cmd = ApePromptCommand(
          ApePromptInput(name: 'basho', workingDirectory: tmpDir.path),
        );
        final result = await cmd.execute();

        expect(result.subState, equals('test'));
        expect(result.prompt, contains('Verification'));
      });
    });

    group('inquiry-context injection', () {
      late Directory gitTmpDir;

      void expectExplicitContextAfter(String prompt, String promptFragment) {
        final promptIndex = prompt.indexOf(promptFragment);
        final contextIndex = prompt.indexOf('# --- inquiry-context ---');

        expect(
          promptIndex,
          greaterThanOrEqualTo(0),
          reason: 'Missing assembled prompt fragment: $promptFragment',
        );
        expect(
          contextIndex,
          greaterThan(promptIndex),
          reason: 'inquiry-context should stay explicit after the prompt body',
        );
      }

      void expectOperationalContractBetween(
        String prompt, {
        required String identityFragment,
        required String contractFragment,
      }) {
        final identityIndex = prompt.indexOf(identityFragment);
        final contractIndex = prompt.indexOf(
          '## Phase-Owned Operational Contract',
        );
        final detailIndex = prompt.indexOf(contractFragment);
        final contextIndex = prompt.indexOf('# --- inquiry-context ---');

        expect(
          identityIndex,
          greaterThanOrEqualTo(0),
          reason:
              'Missing assembled prompt identity fragment: $identityFragment',
        );
        expect(
          contractIndex,
          greaterThan(identityIndex),
          reason: 'Operational contract should come after the APE identity',
        );
        expect(
          detailIndex,
          greaterThan(contractIndex),
          reason: 'Operational contract should expose the phase-owned details',
        );
        expect(
          contextIndex,
          greaterThan(detailIndex),
          reason:
              'inquiry-context should stay explicit after the operational contract',
        );
      }

      void expectContextKeyOnlyInInquiryContext(String prompt, String key) {
        final contextIndex = prompt.indexOf('# --- inquiry-context ---');
        final keyIndex = prompt.indexOf(key);

        expect(
          contextIndex,
          greaterThanOrEqualTo(0),
          reason: 'Missing inquiry-context block for key: $key',
        );
        expect(
          keyIndex,
          greaterThan(contextIndex),
          reason:
              '$key should be owned by inquiry-context, not the APE identity',
        );
        expect(
          prompt.indexOf(key, keyIndex + key.length),
          equals(-1),
          reason: '$key should appear only once in the assembled prompt',
        );
      }

      setUp(() {
        gitTmpDir = Directory.systemTemp.createTempSync('ape_ctx_test_');
        Directory(p.join(gitTmpDir.path, '.inquiry')).createSync();

        // Init a git repo with a branch and initial commit
        Process.runSync('git', ['init'], workingDirectory: gitTmpDir.path);
        Process.runSync('git', [
          'config',
          'user.email',
          'test@test.com',
        ], workingDirectory: gitTmpDir.path);
        Process.runSync('git', [
          'config',
          'user.name',
          'Test',
        ], workingDirectory: gitTmpDir.path);
        File(p.join(gitTmpDir.path, '.gitkeep')).writeAsStringSync('');
        Process.runSync('git', ['add', '.'], workingDirectory: gitTmpDir.path);
        Process.runSync('git', [
          'commit',
          '-m',
          'init',
        ], workingDirectory: gitTmpDir.path);
        Process.runSync('git', [
          'checkout',
          '-b',
          '152-test-branch',
        ], workingDirectory: gitTmpDir.path);
        Directory(
          p.join(gitTmpDir.path, 'cleanrooms', '152-test-branch'),
        ).createSync(recursive: true);

        // Copy ape YAMLs
        final apesDir = Directory(p.join(gitTmpDir.path, 'assets', 'apes'));
        apesDir.createSync(recursive: true);
        for (final name in [
          'socrates',
          'dewey',
          'descartes',
          'basho',
          'darwin',
        ]) {
          File(
            'assets/apes/$name.yaml',
          ).copySync(p.join(apesDir.path, '$name.yaml'));
        }

        final statesDir = Directory(
          p.join(gitTmpDir.path, 'assets', 'fsm', 'states'),
        );
        statesDir.createSync(recursive: true);
        for (final name in [
          'idle',
          'analyze',
          'plan',
          'execute',
          'end',
          'evolution',
        ]) {
          File(
            'assets/fsm/states/$name.yaml',
          ).copySync(p.join(statesDir.path, '$name.yaml'));
        }
      });

      tearDown(() {
        gitTmpDir.deleteSync(recursive: true);
      });

      test('socrates prompt includes inquiry-context with output_dir', () async {
        File(
          p.join(
            gitTmpDir.path,
            'cleanrooms',
            '152-test-branch',
            kStateFileName,
          ),
        ).writeAsStringSync('state: ANALYZE\nissue: "152"\n');

        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'socrates',
            subState: 'clarification',
            workingDirectory: gitTmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('diagnosis.md'));
        expect(result.prompt, contains('Clarification questions'));
        expect(result.prompt, contains('# --- inquiry-context ---'));
        expect(
          result.prompt,
          contains('output_dir: cleanrooms/152-test-branch/analyze/'),
        );
        expect(
          result.prompt,
          contains(
            'confirmations_doc: cleanrooms/152-test-branch/analyze/confirmations.md',
          ),
        );
        expect(
          result.prompt,
          contains('index_file: cleanrooms/152-test-branch/analyze/index.md'),
        );
        expect(result.prompt, contains('doc_protocol: doc-write'));
        expect(result.prompt, isNot(contains('confirmed_doc')));
        expect(result.prompt, isNot(contains('confirmed.md')));
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'output_dir: cleanrooms/152-test-branch/analyze/',
        );
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'confirmations_doc: cleanrooms/152-test-branch/analyze/confirmations.md',
        );
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'index_file: cleanrooms/152-test-branch/analyze/index.md',
        );
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'doc_protocol: doc-write',
        );
        expectExplicitContextAfter(result.prompt, 'Clarification questions');
      });

      test('descartes prompt includes analysis_input path', () async {
        File(
          p.join(
            gitTmpDir.path,
            'cleanrooms',
            '152-test-branch',
            kStateFileName,
          ),
        ).writeAsStringSync('state: PLAN\nissue: "152"\n');

        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'descartes',
            subState: 'decomposition',
            workingDirectory: gitTmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('EVIDENCE'));
        expect(result.prompt, contains('FOCUS: Division.'));
        expect(result.prompt, contains('# --- inquiry-context ---'));
        expect(
          result.prompt,
          contains(
            'analysis_input: cleanrooms/152-test-branch/analyze/diagnosis.md',
          ),
        );
        expect(
          result.prompt,
          contains('plan_file: cleanrooms/152-test-branch/plan.md'),
        );
        expect(result.prompt, contains('doc_protocol: doc-read'));
        expect(result.prompt, isNot(contains('Commit:')));
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'analysis_input: cleanrooms/152-test-branch/analyze/diagnosis.md',
        );
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'plan_file: cleanrooms/152-test-branch/plan.md',
        );
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'doc_protocol: doc-read',
        );
        expectExplicitContextAfter(result.prompt, 'FOCUS: Division.');
      });

      test('basho prompt includes plan contract in assembled prompt', () async {
        File(
          p.join(
            gitTmpDir.path,
            'cleanrooms',
            '152-test-branch',
            kStateFileName,
          ),
        ).writeAsStringSync('state: EXECUTE\nissue: "152"\n');

        final cmd = ApePromptCommand(
          ApePromptInput(
            name: 'basho',
            subState: 'implement',
            workingDirectory: gitTmpDir.path,
          ),
        );
        final result = await cmd.execute();

        expect(result.prompt, contains('NOTHING WASTED'));
        expect(
          result.prompt,
          contains('Implement exactly what the plan says. No more, no less.'),
        );
        expect(result.prompt, contains('## Phase-Owned Operational Contract'));
        expect(
          result.prompt,
          contains(
            'Implement the plan phase by phase under its formal constraints.',
          ),
        );
        expect(result.prompt, contains('Follow plan.md phases in order'));
        expect(result.prompt, contains('Allowed actions:'));
        expect(result.prompt, contains('Edit code files'));
        expect(result.prompt, contains('# --- inquiry-context ---'));
        expect(
          result.prompt,
          contains('plan_file: cleanrooms/152-test-branch/plan.md'),
        );
        expect(
          result.prompt,
          contains('output_dir: cleanrooms/152-test-branch/'),
        );
        expect(result.prompt, contains('doc_protocol: doc-read'));
        expect(result.prompt, isNot(contains('Run tests, lint, build')));
        expect(result.prompt, isNot(contains('retrospective.md')));
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'plan_file: cleanrooms/152-test-branch/plan.md',
        );
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'output_dir: cleanrooms/152-test-branch/',
        );
        expectContextKeyOnlyInInquiryContext(
          result.prompt,
          'doc_protocol: doc-read',
        );
        expectOperationalContractBetween(
          result.prompt,
          identityFragment:
              'Implement exactly what the plan says. No more, no less.',
          contractFragment:
              'Implement the plan phase by phase under its formal constraints.',
        );
      });

      test(
        'dewey create_or_select prompt includes IDLE-owned routing context',
        () async {
          File(
            p.join(
              gitTmpDir.path,
              'cleanrooms',
              '152-test-branch',
              kStateFileName,
            ),
          ).writeAsStringSync(
            'state: IDLE\n'
            'issue: null\n'
            'ape:\n'
            '  name: dewey\n'
            '  state: create_or_select\n',
          );

          final cmd = ApePromptCommand(
            ApePromptInput(name: 'dewey', workingDirectory: gitTmpDir.path),
          );
          final result = await cmd.execute();

          expect(result.subState, equals('create_or_select'));
          expect(
            result.prompt,
            contains('FOCUS: Issue formulation. Create or select.'),
          );
          expect(result.prompt, contains('# --- inquiry-context ---'));
          expect(
            result.prompt,
            contains(
              'IDLE owns that fast-path routing contract: triage_objective=create_or_select, deterministic_skill=issue-create, allowed_commands=gh issue list, gh issue view, gh issue create, gh issue edit.',
            ),
          );
          expect(result.prompt, contains('triage_objective: create_or_select'));
          expect(result.prompt, contains('deterministic_skill: issue-create'));
          expect(
            result.prompt,
            contains(
              'allowed_commands: gh issue list, gh issue view, gh issue create, gh issue edit',
            ),
          );
          expectOperationalContractBetween(
            result.prompt,
            identityFragment: 'FOCUS: Issue formulation. Create or select.',
            contractFragment:
                'IDLE owns that fast-path routing contract: triage_objective=create_or_select',
          );
          expectExplicitContextAfter(
            result.prompt,
            'FOCUS: Issue formulation. Create or select.',
          );
        },
      );

      test(
        'dewey search_existing prompt keeps GitHub procedure in the IDLE contract',
        () async {
          File(
            p.join(
              gitTmpDir.path,
              'cleanrooms',
              '152-test-branch',
              kStateFileName,
            ),
          ).writeAsStringSync(
            'state: IDLE\n'
            'issue: null\n'
            'ape:\n'
            '  name: dewey\n'
            '  state: search_existing\n',
          );

          final cmd = ApePromptCommand(
            ApePromptInput(name: 'dewey', workingDirectory: gitTmpDir.path),
          );
          final result = await cmd.execute();

          expect(result.subState, equals('search_existing'));
          expect(
            result.prompt,
            contains('FOCUS: Deduplication. Search before creating.'),
          );
          expect(
            result.prompt,
            isNot(
              contains(
                'Use: `gh issue list --search "<keywords>"` to find existing issues.',
              ),
            ),
          );
          expect(
            result.prompt,
            contains(
              'IDLE owns that fast-path routing contract: triage_objective=create_or_select, deterministic_skill=issue-create, allowed_commands=gh issue list, gh issue view, gh issue create, gh issue edit.',
            ),
          );
          final promptIndex = result.prompt.indexOf(
            'FOCUS: Deduplication. Search before creating.',
          );
          final contractIndex = result.prompt.indexOf(
            '## Phase-Owned Operational Contract',
          );
          final detailIndex = result.prompt.indexOf(
            'IDLE owns that fast-path routing contract: triage_objective=create_or_select',
          );

          expect(promptIndex, greaterThanOrEqualTo(0));
          expect(contractIndex, greaterThan(promptIndex));
          expect(detailIndex, greaterThan(contractIndex));
        },
      );

      test(
        'darwin prompt includes cycle artifact contract in assembled prompt',
        () async {
          File(
            p.join(
              gitTmpDir.path,
              'cleanrooms',
              '152-test-branch',
              kStateFileName,
            ),
          ).writeAsStringSync('state: EVOLUTION\nissue: "152"\n');

          final cmd = ApePromptCommand(
            ApePromptInput(
              name: 'darwin',
              subState: 'observe',
              workingDirectory: gitTmpDir.path,
            ),
          );
          final result = await cmd.execute();

          expect(result.prompt, contains('diagnosis.md'));
          expect(result.prompt, contains('FOCUS: Observation.'));
          expect(
            result.prompt,
            contains(
              'EVOLUTION owns the repository procedure for issue search/comment/create and metrics collection.',
            ),
          );
          expect(result.prompt, contains('# --- inquiry-context ---'));
          expect(
            result.prompt,
            contains('analyze_dir: cleanrooms/152-test-branch/analyze/'),
          );
          expect(
            result.prompt,
            contains('plan_file: cleanrooms/152-test-branch/plan.md'),
          );
          expect(
            result.prompt,
            contains(
              'retrospective_file: cleanrooms/152-test-branch/retrospective.md',
            ),
          );
          expect(
            result.prompt,
            contains('mutations_file: cleanrooms/152-test-branch/mutations.md'),
          );
          expect(
            result.prompt,
            contains('state_file: cleanrooms/152-test-branch/.iq.state.yaml'),
          );
          expect(
            result.prompt,
            contains('metrics_snapshot_file: .inquiry/metrics_snapshot.yaml'),
          );
          expect(
            result.prompt,
            contains('metrics_file: .inquiry/metrics.yaml'),
          );
          expect(
            result.prompt,
            contains('output_dir: cleanrooms/152-test-branch/'),
          );
          expectExplicitContextAfter(result.prompt, 'FOCUS: Observation.');
        },
      );

      test('no context injected when not in a git repo', () async {
        // A fresh directory with no git repo → no cycle resolves.
        final nonGitDir = Directory.systemTemp.createTempSync('ape_nogit_');
        addTearDown(() => nonGitDir.deleteSync(recursive: true));
        final apesDir = Directory(p.join(nonGitDir.path, 'assets', 'apes'));
        apesDir.createSync(recursive: true);
        File(
          'assets/apes/dewey.yaml',
        ).copySync(p.join(apesDir.path, 'dewey.yaml'));
        final statesDir = Directory(
          p.join(nonGitDir.path, 'assets', 'fsm', 'states'),
        );
        statesDir.createSync(recursive: true);
        for (final name in [
          'idle',
          'analyze',
          'plan',
          'execute',
          'end',
          'evolution',
        ]) {
          File(
            'assets/fsm/states/$name.yaml',
          ).copySync(p.join(statesDir.path, '$name.yaml'));
        }

        // Outside any git repo, no cycle resolves → derived IDLE (dewey).
        final cmd = ApePromptCommand(
          ApePromptInput(name: 'dewey', workingDirectory: nonGitDir.path),
        );
        final result = await cmd.execute();

        expect(result.prompt, isNot(contains('# --- inquiry-context ---')));
      });
    });
  });
}

void _initGitRepo(String root, {required String branch}) {
  void git(List<String> args) {
    final result = Process.runSync('git', args, workingDirectory: root);
    if (result.exitCode != 0) {
      throw StateError('git ${args.join(' ')} failed: ${result.stderr}');
    }
  }

  git(['init']);
  git(['config', 'user.email', 'test@test.com']);
  git(['config', 'user.name', 'Test']);
  File(p.join(root, '.gitkeep')).writeAsStringSync('');
  git(['add', '.']);
  git(['commit', '-m', 'init']);
  git(['checkout', '-b', branch]);
}
