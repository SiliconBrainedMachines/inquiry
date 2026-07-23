import 'dart:io';

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
      final out = await command('40').execute();

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

      final out = await command('40').execute();

      expect(out.initialized, isTrue);
      expect(
        File(p.join(tempDir.path, '.inquiry', 'config.yaml')).existsSync(),
        isTrue,
      );
    });

    test('is idempotent: re-running lands on the same branch without error',
        () async {
      await command('40').execute();
      final second = await command('40').execute();

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
        () => cmd.execute(),
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
