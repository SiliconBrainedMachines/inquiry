import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/modules/global/commands/init.dart';

void main() {
  group('InitCommand', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('inquiry_init_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    // ─── Step 1: cleanrooms/ directory ───────────────────────────────────

    group('cleanrooms/ directory', () {
      test('creates cleanrooms/ at root if it does not exist', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/cleanrooms').existsSync(), isTrue);
      });

      test('creates cleanrooms/ at root, not under docs/', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(Directory('${tempDir.path}/cleanrooms').existsSync(), isTrue);
        expect(
          Directory('${tempDir.path}/docs/cleanrooms').existsSync(),
          isFalse,
        );
      });

      test('skips cleanrooms/ creation at root if already exists', () async {
        Directory('${tempDir.path}/cleanrooms').createSync(recursive: true);
        // Put a marker file to verify directory is not recreated/destroyed
        File('${tempDir.path}/cleanrooms/marker.md').writeAsStringSync('x');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(
          File('${tempDir.path}/cleanrooms/marker.md').existsSync(),
          isTrue,
        );
      });
    });

    // ─── Step 3: .gitignore ───────────────────────────────────────────

    group('.gitignore management', () {
      test(
        'creates .gitignore with .inquiry/ entry if no .gitignore exists',
        () async {
          final command = InitCommand(
            InitInput(workingDirectory: tempDir.path),
          );
          await command.execute();

          final gitignore = File('${tempDir.path}/.gitignore');
          expect(gitignore.existsSync(), isTrue);
          expect(gitignore.readAsStringSync(), contains('.inquiry/'));
        },
      );

      test('ignores cycle-local state files under cleanrooms/', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File('${tempDir.path}/.gitignore').readAsStringSync();
        expect(content, contains('cleanrooms/**/.iq.state.yaml'));
      });

      test('appends .inquiry/ to existing .gitignore that lacks it', () async {
        File('${tempDir.path}/.gitignore').writeAsStringSync('node_modules/\n');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File('${tempDir.path}/.gitignore').readAsStringSync();
        expect(content, contains('node_modules/'));
        expect(content, contains('.inquiry/'));
        expect(content, contains('cleanrooms/**/.iq.state.yaml'));
      });

      test(
        'does not modify .gitignore if all entries already present',
        () async {
          final original =
              'node_modules/\n.inquiry/\ncleanrooms/**/.iq.state.yaml\nbuild/\n';
          File('${tempDir.path}/.gitignore').writeAsStringSync(original);

          final command = InitCommand(
            InitInput(workingDirectory: tempDir.path),
          );
          await command.execute();

          final content = File('${tempDir.path}/.gitignore').readAsStringSync();
          expect(content, equals(original));
        },
      );
    });

    // ─── Cycle-local model: init no longer scaffolds repo-level runtime ──

    group('cycle-local model', () {
      test('does not create repo-level .inquiry/state.yaml', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(
          File('${tempDir.path}/.inquiry/state.yaml').existsSync(),
          isFalse,
        );
      });

      test('does not create repo-level .inquiry/mutations.md', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        expect(
          File('${tempDir.path}/.inquiry/mutations.md').existsSync(),
          isFalse,
        );
      });
    });

    // ─── Step 4: .inquiry/state.yaml — removed (cycle-local model) ────────

    // ─── Step 5: .inquiry/config.yaml ─────────────────────────────────────

    group('.inquiry/config.yaml', () {
      test('creates .inquiry/config.yaml with default config', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final configFile = File('${tempDir.path}/.inquiry/config.yaml');
        expect(configFile.existsSync(), isTrue);

        final content = configFile.readAsStringSync();
        expect(content, contains('evolution:'));
        expect(content, contains('enabled: false'));
      });

      test('skips .inquiry/config.yaml if already exists', () async {
        Directory('${tempDir.path}/.inquiry').createSync();
        File(
          '${tempDir.path}/.inquiry/config.yaml',
        ).writeAsStringSync('evolution:\n  enabled: true\n');

        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        await command.execute();

        final content = File(
          '${tempDir.path}/.inquiry/config.yaml',
        ).readAsStringSync();
        expect(content, contains('enabled: true'));
      });

      test('initializes repo root when invoked from nested subdir', () async {
        _initGitRepo(tempDir.path);
        final nestedDir = Directory(
          p.join(tempDir.path, 'docs', 'deep'),
        )..createSync(recursive: true);

        final command = InitCommand(
          InitInput(workingDirectory: nestedDir.path),
        );
        await command.execute();

        expect(File('${tempDir.path}/.inquiry/config.yaml').existsSync(), isTrue);
        expect(Directory('${tempDir.path}/cleanrooms').existsSync(), isTrue);
        expect(
          File('${nestedDir.path}/.inquiry/config.yaml').existsSync(),
          isFalse,
        );
      });
    });

    // ─── Step 6: .inquiry/mutations.md ──────────────────────────────────

    // ─── Step 6: .inquiry/mutations.md — removed (cycle-local model) ──────

    // ─── Idempotency ──────────────────────────────────────────────────

    group('idempotency', () {
      test('running init twice produces same result', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));

        await command.execute();
        // Capture state after first run
        final gitignoreAfterFirst = File(
          '${tempDir.path}/.gitignore',
        ).readAsStringSync();
        final configAfterFirst = File(
          '${tempDir.path}/.inquiry/config.yaml',
        ).readAsStringSync();

        await command.execute();
        // Verify state unchanged after second run
        final gitignoreAfterSecond = File(
          '${tempDir.path}/.gitignore',
        ).readAsStringSync();
        final configAfterSecond = File(
          '${tempDir.path}/.inquiry/config.yaml',
        ).readAsStringSync();

        expect(gitignoreAfterSecond, equals(gitignoreAfterFirst));
        expect(configAfterSecond, equals(configAfterFirst));
        expect(Directory('${tempDir.path}/cleanrooms').existsSync(), isTrue);
      });
    });

    // ─── Output ───────────────────────────────────────────────────────

    group('output', () {
      test('exit code is always 0', () async {
        final command = InitCommand(InitInput(workingDirectory: tempDir.path));
        final output = await command.execute();
        expect(output.exitCode, 0);
      });
    });

    // ─── Step 7: repo-scoped, host-aware agent deploy (#272) ─────────────

    group('Step 7: repo-scoped agent deploy', () {
      late Directory assetsRoot;

      // Per-project agent paths by host.
      String openCodeAgent(String root) =>
          p.join(root, '.opencode', 'agent', 'inquiry.md');
      String copilotAgent(String root) =>
          p.join(root, '.github', 'agents', 'inquiry.agent.md');

      setUp(() {
        // Minimal assets tree with the shared body + both host frontmatters.
        assetsRoot = Directory.systemTemp.createTempSync(
          'inquiry_assets_test_',
        );
        final agentDir = Directory(p.join(assetsRoot.path, 'assets', 'agents'));
        agentDir.createSync(recursive: true);
        File(
          p.join(agentDir.path, 'inquiry.body.md'),
        ).writeAsStringSync('Test agent content.');
        final fmDir = Directory(p.join(agentDir.path, 'frontmatter'))
          ..createSync(recursive: true);
        File(p.join(fmDir.path, 'copilot.yaml'))
            .writeAsStringSync('name: inquiry');
        File(p.join(fmDir.path, 'opencode.yaml'))
            .writeAsStringSync('name: inquiry');
      });

      tearDown(() {
        if (assetsRoot.existsSync()) assetsRoot.deleteSync(recursive: true);
      });

      test(
        'default host (opencode): writes .opencode/agent/inquiry.md, not global',
        () async {
          final command = InitCommand(
            InitInput(workingDirectory: tempDir.path),
            assets: Assets(root: assetsRoot.path),
          );
          await command.execute();

          final agentFile = File(openCodeAgent(tempDir.path));
          expect(agentFile.existsSync(), isTrue);
          expect(agentFile.readAsStringSync(), contains('Test agent content.'));
          // Repo-scoped: no copilot agent unless requested.
          expect(File(copilotAgent(tempDir.path)).existsSync(), isFalse);
        },
      );

      test('--host copilot: writes .github/agents/inquiry.agent.md', () async {
        final command = InitCommand(
          InitInput(workingDirectory: tempDir.path, host: 'copilot'),
          assets: Assets(root: assetsRoot.path),
        );
        await command.execute();

        expect(File(copilotAgent(tempDir.path)).existsSync(), isTrue);
        // One host at a time: no opencode agent.
        expect(File(openCodeAgent(tempDir.path)).existsSync(), isFalse);
      });

      test('records the chosen host in .inquiry/config.yaml', () async {
        await InitCommand(
          InitInput(workingDirectory: tempDir.path, host: 'copilot'),
          assets: Assets(root: assetsRoot.path),
        ).execute();

        final config =
            File('${tempDir.path}/.inquiry/config.yaml').readAsStringSync();
        expect(config, contains('host: copilot'));
      });

      test('creates the per-project agent directory if missing', () async {
        await InitCommand(
          InitInput(workingDirectory: tempDir.path),
          assets: Assets(root: assetsRoot.path),
        ).execute();

        expect(
          Directory(p.join(tempDir.path, '.opencode', 'agent')).existsSync(),
          isTrue,
        );
      });

      test('overwrites an existing agent on re-init (idempotent)', () async {
        final agentDir = Directory(p.join(tempDir.path, '.opencode', 'agent'))
          ..createSync(recursive: true);
        File(p.join(agentDir.path, 'inquiry.md'))
            .writeAsStringSync('stale content');

        await InitCommand(
          InitInput(workingDirectory: tempDir.path),
          assets: Assets(root: assetsRoot.path),
        ).execute();

        final content = File(openCodeAgent(tempDir.path)).readAsStringSync();
        expect(content, contains('Test agent content.'));
        expect(content, isNot(contains('stale content')));
      });

      test('skips agent deploy silently when assets is null', () async {
        await InitCommand(
          InitInput(workingDirectory: tempDir.path),
        ).execute();

        expect(File(openCodeAgent(tempDir.path)).existsSync(), isFalse);
      });

      test('rejects an unknown host via validate()', () {
        final err = InitCommand(
          InitInput(workingDirectory: tempDir.path, host: 'bogus'),
        ).validate();
        expect(err, isNotNull);
        expect(err, contains('bogus'));
      });

      test(
          'switching host removes the previous host agent + updates config (#274)',
          () async {
        final assets = Assets(root: assetsRoot.path);
        await InitCommand(
          InitInput(workingDirectory: tempDir.path),
          assets: assets,
        ).execute(); // opencode (default)
        expect(File(openCodeAgent(tempDir.path)).existsSync(), isTrue);

        await InitCommand(
          InitInput(workingDirectory: tempDir.path, host: 'copilot'),
          assets: assets,
        ).execute(); // switch

        // Exactly one host at a time: copilot present, opencode removed.
        expect(File(copilotAgent(tempDir.path)).existsSync(), isTrue);
        expect(File(openCodeAgent(tempDir.path)).existsSync(), isFalse);

        final config =
            File('${tempDir.path}/.inquiry/config.yaml').readAsStringSync();
        expect(config, contains('host: copilot'));
        expect(config, isNot(contains('host: opencode')));
      });

      test('reconciling host preserves other config keys (#274)', () async {
        Directory('${tempDir.path}/.inquiry').createSync(recursive: true);
        File('${tempDir.path}/.inquiry/config.yaml')
            .writeAsStringSync('host: opencode\nevolution:\n  enabled: true\n');

        await InitCommand(
          InitInput(workingDirectory: tempDir.path, host: 'copilot'),
          assets: Assets(root: assetsRoot.path),
        ).execute();

        final config =
            File('${tempDir.path}/.inquiry/config.yaml').readAsStringSync();
        expect(config, contains('host: copilot'));
        expect(config, contains('enabled: true')); // preserved
      });

      test('legacy config without a host line gets one recorded (#274)',
          () async {
        Directory('${tempDir.path}/.inquiry').createSync(recursive: true);
        File('${tempDir.path}/.inquiry/config.yaml')
            .writeAsStringSync('evolution:\n  enabled: false\n');

        await InitCommand(
          InitInput(workingDirectory: tempDir.path),
          assets: Assets(root: assetsRoot.path),
        ).execute();

        final config =
            File('${tempDir.path}/.inquiry/config.yaml').readAsStringSync();
        expect(config, contains('host: opencode'));
        expect(config, contains('enabled: false'));
      });
    });
  });
}

void _initGitRepo(String root) {
  void git(List<String> args) {
    final result = Process.runSync('git', args, workingDirectory: root);
    if (result.exitCode != 0) {
      throw StateError('git ${args.join(' ')} failed: ${result.stderr}');
    }
  }

  git(['init', '-q']);
  git(['config', 'user.email', 'test@example.com']);
  git(['config', 'user.name', 'test']);
  File(p.join(root, 'README.md')).writeAsStringSync('# test\n');
  git(['add', '.']);
  git(['commit', '-q', '-m', 'init']);
}
