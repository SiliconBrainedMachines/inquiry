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

    // ─── Step 7: .github/agents/inquiry.agent.md ──────────────────────

    group('Step 7: repo-scoped agent deploy', () {
      late Directory assetsRoot;

      setUp(() {
        // Minimal assets tree with an agent file
        assetsRoot = Directory.systemTemp.createTempSync(
          'inquiry_assets_test_',
        );
        final agentDir = Directory(p.join(assetsRoot.path, 'assets', 'agents'));
        agentDir.createSync(recursive: true);
        File(
          p.join(agentDir.path, 'inquiry.agent.md'),
        ).writeAsStringSync('---\nname: inquiry\n---\nTest agent content.');
      });

      tearDown(() {
        if (assetsRoot.existsSync()) assetsRoot.deleteSync(recursive: true);
      });

      test(
        'writes inquiry.agent.md to .github/agents/ when assets provided',
        () async {
          final assets = Assets(root: assetsRoot.path);
          final command = InitCommand(
            InitInput(workingDirectory: tempDir.path),
            assets: assets,
          );
          await command.execute();

          final agentFile = File(
            p.join(tempDir.path, '.github', 'agents', 'inquiry.agent.md'),
          );
          expect(agentFile.existsSync(), isTrue);
          expect(agentFile.readAsStringSync(), contains('Test agent content.'));
        },
      );

      test('creates .github/agents/ directory if missing', () async {
        final assets = Assets(root: assetsRoot.path);
        final command = InitCommand(
          InitInput(workingDirectory: tempDir.path),
          assets: assets,
        );
        await command.execute();

        expect(
          Directory(p.join(tempDir.path, '.github', 'agents')).existsSync(),
          isTrue,
        );
      });

      test(
        'overwrites existing inquiry.agent.md on re-init (idempotent)',
        () async {
          // Write stale content first
          final agentDir = Directory(p.join(tempDir.path, '.github', 'agents'))
            ..createSync(recursive: true);
          File(
            p.join(agentDir.path, 'inquiry.agent.md'),
          ).writeAsStringSync('stale content');

          final assets = Assets(root: assetsRoot.path);
          final command = InitCommand(
            InitInput(workingDirectory: tempDir.path),
            assets: assets,
          );
          await command.execute();

          final content = File(
            p.join(tempDir.path, '.github', 'agents', 'inquiry.agent.md'),
          ).readAsStringSync();
          expect(content, contains('Test agent content.'));
          expect(content, isNot(contains('stale content')));
        },
      );

      test('skips agent deploy silently when assets is null', () async {
        final command = InitCommand(
          InitInput(workingDirectory: tempDir.path),
          // no assets param
        );
        await command.execute();

        expect(
          File(
            p.join(tempDir.path, '.github', 'agents', 'inquiry.agent.md'),
          ).existsSync(),
          isFalse,
        );
      });
    });
  });
}
