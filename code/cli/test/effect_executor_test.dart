import 'dart:io';

import 'package:inquiry_cli/modules/ape/inquiry_state.dart';
import 'package:inquiry_cli/modules/fsm/effect_executor.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String stateFilePath;

  const branch = '145-test-branch';

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('effect_executor_test_');
    Directory('${tempDir.path}/.inquiry').createSync(recursive: true);
    _initGitRepo(tempDir.path, branch: branch);
    final cycleDir = Directory(p.join(tempDir.path, 'cleanrooms', branch))
      ..createSync(recursive: true);
    stateFilePath = p.join(cycleDir.path, kStateFileName);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('EffectExecutor', () {
    group('update_state', () {
      test('writes new state and issue to state.yaml', () {
        File(stateFilePath).writeAsStringSync('state: IDLE\nissue: null\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState(
          'ANALYZE',
          issue: '145',
          promptFragmentId: 'idle_to_analyze',
        );

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('state: ANALYZE'));
        expect(content, contains('issue: "145"'));
        expect(content, contains('prompt_fragment_id: idle_to_analyze'));
      });

      test('preserves issue when not provided', () {
        File(stateFilePath).writeAsStringSync('state: ANALYZE\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('PLAN', promptFragmentId: 'analyze_to_plan');

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('state: PLAN'));
        expect(content, contains('issue: "145"'));
        expect(content, contains('prompt_fragment_id: analyze_to_plan'));
      });

      test('marks cycle completed when transitioning to IDLE', () {
        File(
          stateFilePath,
        ).writeAsStringSync('state: EVOLUTION\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('IDLE');

        // IDLE is derived: the cycle file is marked completed, not rewritten to
        // a persisted IDLE record. load() maps completed -> derived IDLE.
        final raw = InquiryState.loadFrom(stateFilePath);
        expect(raw.status, 'completed');
        final derived = InquiryState.load(tempDir.path);
        expect(derived.state, 'IDLE');
        expect(derived.issue, isNull);
      });
    });

    group('reset_mutations', () {
      test('resets mutations.md to empty template', () {
        File(
          '${tempDir.path}/cleanrooms/$branch/mutations.md',
        ).writeAsStringSync(
          '# Mutations\n\nNotes for DARWIN.\n- old observation\n- another one\n',
        );

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.resetMutations();

        final content = File(
          '${tempDir.path}/cleanrooms/$branch/mutations.md',
        ).readAsStringSync();
        expect(content, contains('# Mutations'));
        expect(content, contains('Notes for DARWIN'));
        expect(content, isNot(contains('old observation')));
      });

      test('creates mutations.md if missing', () {
        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.resetMutations();

        expect(
          File('${tempDir.path}/cleanrooms/$branch/mutations.md').existsSync(),
          isTrue,
        );
      });
    });

    group('snapshot_metrics', () {
      test('creates metrics_snapshot.yaml with timestamp', () {
        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.snapshotMetrics();

        final file = File('${tempDir.path}/.inquiry/metrics_snapshot.yaml');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        expect(content, contains('snapshot_at:'));
        expect(content, contains('state: IDLE'));
      });

      test('captures current state in snapshot', () {
        File(stateFilePath).writeAsStringSync('state: ANALYZE\nissue: "99"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.snapshotMetrics();

        final content = File(
          '${tempDir.path}/.inquiry/metrics_snapshot.yaml',
        ).readAsStringSync();
        expect(content, contains('state: ANALYZE'));
        expect(content, contains('issue: "99"'));
      });
    });

    group('close_cycle', () {
      test('marks cycle completed and derives IDLE', () {
        File(
          stateFilePath,
        ).writeAsStringSync('state: EVOLUTION\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.closeCycle();

        final raw = InquiryState.loadFrom(stateFilePath);
        expect(raw.status, 'completed');
        final derived = InquiryState.load(tempDir.path);
        expect(derived.state, 'IDLE');
        expect(derived.issue, isNull);
      });
    });

    group('collect_metrics', () {
      test('appends cycle entry to metrics.yaml', () {
        File(
          stateFilePath,
        ).writeAsStringSync('state: EVOLUTION\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.collectMetrics();

        final file = File('${tempDir.path}/.inquiry/metrics.yaml');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        expect(content, contains('issue: "145"'));
        expect(content, contains('completed_at:'));
      });

      test('appends to existing metrics.yaml', () {
        File(
          '${tempDir.path}/.inquiry/metrics.yaml',
        ).writeAsStringSync('cycles:\n  - issue: "100"\n');
        File(
          stateFilePath,
        ).writeAsStringSync('state: EVOLUTION\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.collectMetrics();

        final content = File(
          '${tempDir.path}/.inquiry/metrics.yaml',
        ).readAsStringSync();
        expect(content, contains('issue: "100"'));
        expect(content, contains('issue: "145"'));
      });
    });

    group('executeAll', () {
      test('executes multiple effects in order', () {
        File(stateFilePath).writeAsStringSync('state: IDLE\nissue: null\n');
        File(
          '${tempDir.path}/cleanrooms/$branch/mutations.md',
        ).writeAsStringSync('# Mutations\n- old stuff\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        final executed = executor.executeAll(
          effects: ['reset_mutations', 'snapshot_metrics'],
          newState: 'ANALYZE',
          issue: '145',
          promptFragmentId: 'idle_to_analyze',
        );

        expect(
          executed,
          containsAll(['update_state', 'reset_mutations', 'snapshot_metrics']),
        );

        // State updated
        final stateContent = File(stateFilePath).readAsStringSync();
        expect(stateContent, contains('state: ANALYZE'));
        expect(stateContent, contains('prompt_fragment_id: idle_to_analyze'));

        // Mutations reset
        final mutContent = File(
          '${tempDir.path}/cleanrooms/$branch/mutations.md',
        ).readAsStringSync();
        expect(mutContent, isNot(contains('old stuff')));
      });

      test('skips unknown effects gracefully', () {
        File(stateFilePath).writeAsStringSync('state: IDLE\nissue: null\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        final executed = executor.executeAll(
          effects: ['noop', 'push_branch', 'generate_plan'],
          newState: 'ANALYZE',
        );

        // Only update_state is a CLI effect; the rest are skill-side
        expect(executed, contains('update_state'));
        expect(executed, isNot(contains('noop')));
        expect(executed, isNot(contains('push_branch')));
      });
    });

    group('openAnalysisContext', () {
      test('creates analyze bootstrap with confirmations.md', () {
        File(stateFilePath).writeAsStringSync('state: ANALYZE\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.openAnalysisContext();

        final indexFile = File(
          '${tempDir.path}/cleanrooms/$branch/analyze/index.md',
        );
        final confirmationsFile = File(
          '${tempDir.path}/cleanrooms/$branch/analyze/confirmations.md',
        );

        expect(indexFile.existsSync(), isTrue);
        expect(confirmationsFile.existsSync(), isTrue);
        expect(indexFile.readAsStringSync(), contains('confirmations.md'));
      });

      test('creates methodology-neutral confirmations bootstrap', () {
        File(stateFilePath).writeAsStringSync('state: ANALYZE\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.openAnalysisContext();

        final confirmationsFile = File(
          '${tempDir.path}/cleanrooms/$branch/analyze/confirmations.md',
        );
        final content = confirmationsFile.readAsStringSync();

        expect(content, contains('title: "Confirmations"'));
        expect(content, isNot(contains('author: socrates')));
      });

      test('writes issue.md mirror with fetched body', () {
        File(stateFilePath).writeAsStringSync('state: ANALYZE\nissue: "145"\n');

        final executor = EffectExecutor(
          workingDirectory: tempDir.path,
          issueBodyProvider: (issue, _) => 'Body for issue $issue',
        );
        executor.openAnalysisContext();

        final issueFile = File('${tempDir.path}/cleanrooms/$branch/issue.md');
        expect(issueFile.existsSync(), isTrue);
        final content = issueFile.readAsStringSync();
        expect(content, contains('Body for issue 145'));
        expect(content, contains('#145'));
      });

      test('issue.md is non-fatal when body fetch returns null', () {
        File(stateFilePath).writeAsStringSync('state: ANALYZE\nissue: "145"\n');

        final executor = EffectExecutor(
          workingDirectory: tempDir.path,
          issueBodyProvider: (issue, _) => null,
        );

        expect(executor.openAnalysisContext, returnsNormally);

        // Analyze bootstrap still created despite missing body.
        expect(
          File(
            '${tempDir.path}/cleanrooms/$branch/analyze/index.md',
          ).existsSync(),
          isTrue,
        );
      });

      test('does not clobber an existing issue.md', () {
        File(stateFilePath).writeAsStringSync('state: ANALYZE\nissue: "145"\n');
        final issueFile = File('${tempDir.path}/cleanrooms/$branch/issue.md')
          ..createSync(recursive: true);
        issueFile.writeAsStringSync('CUSTOM CONTENT');

        final executor = EffectExecutor(
          workingDirectory: tempDir.path,
          issueBodyProvider: (issue, _) => 'Body for issue $issue',
        );
        executor.openAnalysisContext();

        expect(issueFile.readAsStringSync(), 'CUSTOM CONTENT');
      });
    });

    group('APE auto-activation', () {
      test('writes ape field when transitioning to ANALYZE', () {
        File(stateFilePath).writeAsStringSync('state: IDLE\nissue: null\n');

        // Copy APE assets so _resolveInitialState can find them
        final apesDir = Directory('${tempDir.path}/assets/apes');
        apesDir.createSync(recursive: true);
        File(
          'assets/apes/socrates.yaml',
        ).copySync('${apesDir.path}/socrates.yaml');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('ANALYZE', issue: '145');

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('state: ANALYZE'));
        expect(content, contains('ape:'));
        expect(content, contains('name: socrates'));
        expect(content, contains('state: clarification'));
      });

      test('activates descartes when transitioning to PLAN', () {
        File(stateFilePath).writeAsStringSync('state: ANALYZE\nissue: "145"\n');

        final apesDir = Directory('${tempDir.path}/assets/apes');
        apesDir.createSync(recursive: true);
        File(
          'assets/apes/descartes.yaml',
        ).copySync('${apesDir.path}/descartes.yaml');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('PLAN');

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('name: descartes'));
        expect(content, contains('state: decomposition'));
      });

      test('activates basho when transitioning to EXECUTE', () {
        File(stateFilePath).writeAsStringSync('state: PLAN\nissue: "145"\n');

        final apesDir = Directory('${tempDir.path}/assets/apes');
        apesDir.createSync(recursive: true);
        File('assets/apes/basho.yaml').copySync('${apesDir.path}/basho.yaml');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('EXECUTE');

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('name: basho'));
        expect(content, contains('state: implement'));
      });

      test('activates darwin when transitioning to EVOLUTION', () {
        File(stateFilePath).writeAsStringSync('state: END\nissue: "145"\n');

        final apesDir = Directory('${tempDir.path}/assets/apes');
        apesDir.createSync(recursive: true);
        File('assets/apes/darwin.yaml').copySync('${apesDir.path}/darwin.yaml');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('EVOLUTION');

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('name: darwin'));
        expect(content, contains('state: observe'));
      });

      test('graceful fallback when APE YAML not found', () {
        File(stateFilePath).writeAsStringSync('state: IDLE\nissue: null\n');

        // No APE assets copied
        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('ANALYZE', issue: '145');

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('state: ANALYZE'));
        expect(content, contains('name: socrates'));
        // initialState is null when YAML not found — still writes the name
      });

      test('preserves APE sub-state when same APE continues (EXECUTE→END)', () {
        final apesDir = Directory('${tempDir.path}/assets/apes');
        apesDir.createSync(recursive: true);
        File('assets/apes/basho.yaml').copySync('${apesDir.path}/basho.yaml');

        // basho is at _DONE in EXECUTE
        File(stateFilePath).writeAsStringSync(
          'state: EXECUTE\nissue: "145"\nape:\n  name: basho\n  state: _DONE\n',
        );

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('END');

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('name: basho'));
        expect(content, contains('state: _DONE'));
      });

      test('re-initializes socrates when ANALYZE continues from _DONE', () {
        final apesDir = Directory('${tempDir.path}/assets/apes');
        apesDir.createSync(recursive: true);
        File(
          'assets/apes/socrates.yaml',
        ).copySync('${apesDir.path}/socrates.yaml');

        File(stateFilePath).writeAsStringSync(
          'state: ANALYZE\nissue: "145"\nape:\n  name: socrates\n  state: _DONE\n',
        );

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('ANALYZE');

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('name: socrates'));
        expect(content, contains('state: clarification'));
        expect(content, isNot(contains('state: _DONE')));
      });

      test('re-initializes APE when transitioning to state with different APE', () {
        final apesDir = Directory('${tempDir.path}/assets/apes');
        apesDir.createSync(recursive: true);
        File(
          'assets/apes/descartes.yaml',
        ).copySync('${apesDir.path}/descartes.yaml');

        // socrates is active in ANALYZE, transitioning to PLAN activates descartes
        File(stateFilePath).writeAsStringSync(
          'state: ANALYZE\nissue: "145"\nape:\n  name: socrates\n  state: _DONE\n',
        );

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('PLAN');

        final content = File(stateFilePath).readAsStringSync();
        expect(content, contains('name: descartes'));
        expect(content, contains('state: decomposition'));
      });
    });
  });
}

void _initGitRepo(String root, {required String branch}) {
  _git(root, ['init']);
  _git(root, ['config', 'user.email', 'test@test.com']);
  _git(root, ['config', 'user.name', 'Test']);
  File('$root/.gitkeep').writeAsStringSync('');
  _git(root, ['add', '.']);
  _git(root, ['commit', '-m', 'init']);
  _git(root, ['checkout', '-b', branch]);
}

void _git(String root, List<String> args) {
  final result = Process.runSync('git', args, workingDirectory: root);
  if (result.exitCode != 0) {
    throw StateError(
      'git ${args.join(' ')} failed: ${result.stderr}\n${result.stdout}',
    );
  }
}
