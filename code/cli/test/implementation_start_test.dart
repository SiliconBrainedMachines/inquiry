import 'dart:io';

import 'package:modular_cli_sdk/testing.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/modules/implementation/commands/start.dart';

void main() {
  group('ImplementationStartCommand', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('inquiry_impl_start_');
      _copyAssets(tempDir.path);
      _initGitRepo(tempDir.path);
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    ImplementationStartCommand command(String issue) => ImplementationStartCommand(
          ImplementationStartInput(issue: issue, workingDirectory: tempDir.path),
          assets: Assets(root: tempDir.path),
          issueInfoProvider: (_, _) => (title: 'Fix login timeout', state: 'OPEN'),
        );

    test('creates the linked branch, scaffolds the cleanroom, enters ANALYZE',
        () async {
      final out = await applyCommand(command('40'));

      expect(out.branch, '040-fix-login-timeout');
      expect(out.branchCreated, isTrue);

      // Branch really checked out.
      final branch = Process.runSync(
        'git',
        ['rev-parse', '--abbrev-ref', 'HEAD'],
        workingDirectory: tempDir.path,
      ).stdout.toString().trim();
      expect(branch, '040-fix-login-timeout');

      // Cleanroom scaffolded by the transition's open_analysis_context effect.
      final analyzeDir =
          p.join(tempDir.path, 'cleanrooms', '040-fix-login-timeout', 'analyze');
      expect(File(p.join(analyzeDir, 'diagnosis.md')).existsSync(), isTrue);
      expect(File(p.join(analyzeDir, 'index.md')).existsSync(), isTrue);
      expect(File(p.join(analyzeDir, 'confirmations.md')).existsSync(), isTrue);

      // State advanced to ANALYZE.
      final stateFile = File(p.join(
          tempDir.path, 'cleanrooms', '040-fix-login-timeout', '.iq.state.yaml'));
      expect(stateFile.existsSync(), isTrue);
      expect(stateFile.readAsStringSync(), contains('ANALYZE'));
    });

    test('auto-initializes the workspace when .inquiry is missing', () async {
      expect(
        File(p.join(tempDir.path, '.inquiry', 'config.yaml')).existsSync(),
        isFalse,
      );

      final out = await applyCommand(command('40'));

      expect(out.initialized, isTrue);
      expect(
        File(p.join(tempDir.path, '.inquiry', 'config.yaml')).existsSync(),
        isTrue,
      );
    });

    test('is idempotent: re-running lands on the same branch without error',
        () async {
      await applyCommand(command('40'));
      final second = await applyCommand(command('40'));

      expect(second.branch, '040-fix-login-timeout');
      expect(second.branchCreated, isFalse);
    });

    test('fails with a teaching message when the issue cannot be read',
        () async {
      final cmd = ImplementationStartCommand(
        ImplementationStartInput(issue: '999', workingDirectory: tempDir.path),
        assets: Assets(root: tempDir.path),
        issueInfoProvider: (_, _) => null, // simulate gh failure / missing issue
      );

      expect(
        () => applyCommand(cmd),
        throwsA(predicate((e) =>
            e.toString().contains('gh issue view') &&
            e.toString().contains('gh auth status'))),
      );
    });

    test('rejects a non-numeric issue at validation', () {
      final cmd = ImplementationStartCommand(
        ImplementationStartInput(issue: 'abc', workingDirectory: tempDir.path),
      );
      final error = cmd.validate();
      expect(error, isNotNull);
      expect(error, contains('iq implementation start --issue 40'));
    });

    // What `--plan` shows. Opening a cycle creates a branch and writes a
    // cleanroom into the user's repository, so the branch name derived from the
    // issue title is the thing to see before it happens — a wrong slug is a
    // cycle opened somewhere nobody asked for.
    group('under --plan', () {
      test('names the three steps in order', () async {
        final previews = await previewCommand(command('40'));

        expect(previews.map((p) => p.verb).toList(), [
          'initialize',
          'create',
          'transition',
        ]);
      });

      test(
        'says the branch it would create and the cleanroom it would scaffold',
        () async {
          final previews = await previewCommand(command('40'));

          expect(
            previews.map((p) => p.target).toList(),
            contains('branch 040-fix-login-timeout'),
          );
          expect(
            previews.last.detail,
            contains('cleanrooms/040-fix-login-timeout/analyze/'),
          );
        },
      );

      test('touches nothing: no branch, no workspace, no cleanroom', () async {
        await previewCommand(command('40'));

        final branch = _git(tempDir.path, [
          'rev-parse',
          '--abbrev-ref',
          'HEAD',
        ]).stdout.toString().trim();
        expect(branch, isNot('040-fix-login-timeout'));
        expect(
          File(p.join(tempDir.path, '.inquiry', 'config.yaml')).existsSync(),
          isFalse,
        );
        expect(
          Directory(p.join(tempDir.path, 'cleanrooms')).existsSync(),
          isFalse,
        );
      });

      // The precondition fails before a single step is built, so no plan is
      // ever shown for work that will not happen.
      test('refuses to plan an issue GitHub cannot see', () async {
        final cmd = ImplementationStartCommand(
          ImplementationStartInput(
            issue: '999',
            workingDirectory: tempDir.path,
          ),
          assets: Assets(root: tempDir.path),
          issueInfoProvider: (_, _) => null,
        );

        expect(
          () => previewCommand(cmd),
          throwsA(predicate((e) => e.toString().contains('gh issue view'))),
        );
      });
    });
  });
}

void _initGitRepo(String root) {
  _git(root, ['init']);
  _git(root, ['config', 'user.email', 'test@test.com']);
  _git(root, ['config', 'user.name', 'Test']);
  File(p.join(root, '.gitkeep')).writeAsStringSync('');
  _git(root, ['add', '.']);
  _git(root, ['commit', '-m', 'init']);
}

ProcessResult _git(String root, List<String> args) =>
    Process.runSync('git', args, workingDirectory: root);

/// Copies the assets the transition needs (contract + inspection template) into
/// the temp repo so `Assets(root: tempDir)` resolves them.
void _copyAssets(String root) {
  for (final rel in const [
    'fsm/transition_contract.yaml',
    'inspection/pre_pr_inspection_template.md',
  ]) {
    final source = File(p.join(Directory.current.path, 'assets', rel));
    final destination = File(p.join(root, 'assets', rel));
    destination.createSync(recursive: true);
    destination.writeAsStringSync(source.readAsStringSync());
  }
}
