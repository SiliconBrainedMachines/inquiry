import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:modular_cli_sdk/testing.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/modules/host/commands/get.dart';
import 'package:inquiry_cli/modules/host/commands/clean.dart';
import 'package:inquiry_cli/hosts/deployer.dart';
import 'package:inquiry_cli/hosts/host_adapter.dart';

class _FakeAdapter extends HostAdapter {
  @override
  String get name => 'fake';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.fake');

  @override
  String skillsDirectory(String homeDir) => p.join(homeDir, '.fake', 'skills');

  @override
  String agentDirectory(String homeDir) => p.join(homeDir, '.fake', 'agents');
}

void main() {
  late Directory tempDir;
  late Directory homeDir;
  late HostDeployer deployer;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ape_host_cmd_test_');
    homeDir = Directory(p.join(tempDir.path, 'home'))..createSync();

    // Create asset files
    final skillDir = Directory(
      p.join(tempDir.path, 'assets', 'skills', 'doc-read'),
    );
    skillDir.createSync(recursive: true);
    File(p.join(skillDir.path, 'SKILL.md')).writeAsStringSync('# Doc Read');

    final agentDir = Directory(p.join(tempDir.path, 'assets', 'agents'));
    agentDir.createSync(recursive: true);
    File(
      p.join(agentDir.path, 'inquiry.agent.md'),
    ).writeAsStringSync('# APE Agent');

    deployer = HostDeployer(
      assets: Assets(root: tempDir.path),
      adapters: [_FakeAdapter()],
      homeDir: homeDir.path,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('iq host get', () {
    test('exits 0 and sweeps the legacy namespace on the selected host', () async {
      Directory(p.join(homeDir.path, '.fake', 'skills', 'iq-legacy'))
          .createSync(recursive: true);

      final command = HostGetCommand(
        HostGetInput(host: 'fake'),
        deployer: deployer,
      );

      final output = await applyCommand(command);

      expect(output.exitCode, ExitCode.ok);
      expect(
        Directory(p.join(homeDir.path, '.fake', 'skills', 'iq-legacy'))
            .existsSync(),
        isFalse,
        reason: 'host get sweeps the iq- namespace it once deployed into',
      );
      // FakeAdapter.deploysAgent is false → no global agent for it.
      expect(
        File(
          p.join(homeDir.path, '.fake', 'agents', 'inquiry.md'),
        ).existsSync(),
        isFalse,
      );
    });

    test(
      'HostGetInput defaults to no host, meaning every detected one (#300)',
      () {
        // Defaulting to opencode deployed into a host the user might not have,
        // and dragged the OpenCode/Ollama configurator into every `iq upgrade`.
        expect(HostGetInput().host, isNull);
        expect(HostGetInput().configureOllama, isFalse);
      },
    );

    group('host detection (#300)', () {
      /// The host tool is present when its own config directory exists — the
      /// directory the tool itself creates on first run.
      void installFakeHost() =>
          Directory(p.join(homeDir.path, '.fake')).createSync(recursive: true);

      test(
        'no host installed → nothing deployed, and that is not a failure',
        () async {
          final out = await applyCommand(
            HostGetCommand(HostGetInput(), deployer: deployer),
          );

          expect(out.exitCode, ExitCode.ok);
          expect(out.hosts, isEmpty);
          expect(out.toText(), contains('No AI coding host found'));
          expect(out.toText(), contains('--host'));
          expect(
            Directory(p.join(homeDir.path, '.fake', 'skills')).existsSync(),
            isFalse,
          );
        },
      );

      /// Something for the sweep to find, so the assertion is about the host
      /// that was chosen rather than about an empty directory.
      Directory seedLegacy() =>
          Directory(p.join(homeDir.path, '.fake', 'skills', 'iq-legacy'))
            ..createSync(recursive: true);

      test('a detected host is acted on without being named', () async {
        installFakeHost();
        final legacy = seedLegacy();

        final out = await applyCommand(
          HostGetCommand(HostGetInput(), deployer: deployer),
        );

        expect(out.hosts, ['fake']);
        expect(legacy.existsSync(), isFalse);
      });

      test('--host acts even when the host looks absent', () async {
        // Priming a machine before the host tool has ever run.
        final legacy = seedLegacy();

        final out = await applyCommand(
          HostGetCommand(HostGetInput(host: 'fake'), deployer: deployer),
        );

        expect(out.hosts, ['fake']);
        expect(legacy.existsSync(), isFalse);
      });

      test('detectedHosts reports only what exists on disk', () {
        expect(deployer.detectedHosts, isEmpty);
        installFakeHost();
        expect(deployer.detectedHosts.map((a) => a.name), ['fake']);
      });
    });

    group('retiring skills the CLI no longer ships', () {
      /// Writes a skill directly into the host, as an older release would have.
      void seedDeployed(String name) {
        final f = File(
          p.join(homeDir.path, '.fake', 'skills', name, 'SKILL.md'),
        );
        f.createSync(recursive: true);
        f.writeAsStringSync('# frozen copy from an older release');
      }

      bool deployed(String name) =>
          Directory(p.join(homeDir.path, '.fake', 'skills', name)).existsSync();

      test('removes namespaced skills that are no longer shipped', () async {
        // Exactly the state a user upgrading from before the lifecycle moved
        // to MACSS was left in: frozen copies nothing would update again.
        for (final name in const [
          'iq-analyze',
          'iq-plan',
          'iq-execute',
          'iq-specification',
        ]) {
          seedDeployed(name);
        }

        final out = await applyCommand(
          HostGetCommand(HostGetInput(host: 'fake'), deployer: deployer),
        );

        expect(deployed('iq-analyze'), isFalse);
        expect(deployed('iq-specification'), isFalse);
        expect(
          out.toText(),
          contains('removed  iq-analyze (no longer shipped)'),
        );
      });

      test('never touches skills outside the namespace', () async {
        // Inquiry's own direct-use skills, and anything a user wrote.
        seedDeployed('kritik');
        seedDeployed('legion');
        seedDeployed('my-own-skill');
        seedDeployed('iq-analyze');

        await applyCommand(
          HostGetCommand(HostGetInput(host: 'fake'), deployer: deployer),
        );

        expect(deployed('kritik'), isTrue);
        expect(deployed('legion'), isTrue);
        expect(deployed('my-own-skill'), isTrue);
        expect(deployed('iq-analyze'), isFalse);
      });

      test('takes the whole namespace, because none of it is shipped now', () {
        // The old rule was "prefixed and no longer shipped". Inquiry ships no
        // skills at all, so the second half is always true and the sweep is
        // simply the namespace. What still holds is the first half: the prefix
        // is what makes a directory provably Inquiry's.
        seedDeployed('iq-analyze');
        seedDeployed('iq-plan');

        expect(deployer.deploy('fake'), ['iq-analyze', 'iq-plan']);
        expect(deployed('iq-analyze'), isFalse);
        expect(deployed('iq-plan'), isFalse);
      });

      test('reports nothing when there is nothing to retire', () {
        expect(deployer.deploy('fake'), isEmpty);
      });
    });

    test('validate() returns error for unknown host', () {
      final command = HostGetCommand(
        HostGetInput(host: 'vscode'),
        deployer: deployer,
      );
      expect(command.validate(), isNotNull);
    });

    test('validate() returns null for valid host', () {
      final command = HostGetCommand(
        HostGetInput(host: 'fake'),
        deployer: deployer,
      );
      expect(command.validate(), isNull);
    });

    test('exits 0 on idempotent re-run', () async {
      final command = HostGetCommand(
        HostGetInput(host: 'fake'),
        deployer: deployer,
      );

      await applyCommand(command);
      final output = await applyCommand(command);

      expect(output.exitCode, ExitCode.ok);
    });
  });

  group('iq host clean', () {
    test('exits 0, takes the iq- namespace, and leaves the rest', () async {
      final skills = Directory(p.join(homeDir.path, '.fake', 'skills'));
      final ours = Directory(p.join(skills.path, 'iq-analyze'))
        ..createSync(recursive: true);
      final theirs = Directory(p.join(skills.path, 'legion'))
        ..createSync(recursive: true);

      final output = await applyCommand(
        HostCleanCommand(HostCleanInput(), deployer: deployer),
      );

      expect(output.exitCode, ExitCode.ok);
      expect(ours.existsSync(), isFalse);

      // The directory survives, and so does everything in it Inquiry cannot
      // prove is its own. A skill's *name* is not ownership: another consumer
      // may have deployed the same one.
      expect(theirs.existsSync(), isTrue);
      expect(skills.existsSync(), isTrue);
    });

    test('exits 0 when nothing to clean', () async {
      final command = HostCleanCommand(HostCleanInput(), deployer: deployer);

      final output = await applyCommand(command);

      expect(output.exitCode, ExitCode.ok);
    });

    test('removes .github/agents/inquiry.agent.md from repo', () async {
      final agentFile = File(
        p.join(tempDir.path, '.github', 'agents', 'inquiry.agent.md'),
      );
      agentFile.parent.createSync(recursive: true);
      agentFile.writeAsStringSync('# APE Agent');

      final command = HostCleanCommand(
        HostCleanInput(),
        deployer: deployer,
        workingDirectory: tempDir.path,
      );

      await applyCommand(command);

      expect(
        agentFile.existsSync(),
        isFalse,
        reason: 'iq host clean must remove repo-scoped agent',
      );
    });

    test('removes repo-scoped agent when invoked from nested subdir', () async {
      _initGitRepo(tempDir.path);
      final agentFile = File(
        p.join(tempDir.path, '.github', 'agents', 'inquiry.agent.md'),
      );
      agentFile.parent.createSync(recursive: true);
      agentFile.writeAsStringSync('# APE Agent');

      final nestedDir = Directory(p.join(tempDir.path, 'sub', 'deep'))
        ..createSync(recursive: true);

      final command = HostCleanCommand(
        HostCleanInput(),
        deployer: deployer,
        workingDirectory: nestedDir.path,
      );

      await applyCommand(command);

      expect(agentFile.existsSync(), isFalse);
    });

    test(
      'does not fail if .github/agents/inquiry.agent.md does not exist',
      () async {
        final command = HostCleanCommand(
          HostCleanInput(),
          deployer: deployer,
          workingDirectory: tempDir.path,
        );

        await expectLater(applyCommand(command), completes);
      },
    );
  });

  // What `--plan` shows. `iq host get` deploys into whatever this machine
  // happens to carry, which is exactly the kind of thing a user wants named
  // before it happens: two assistants, one, or none look nothing alike.
  group('under --plan', () {
    void installFakeHost() =>
        Directory(p.join(homeDir.path, '.fake')).createSync(recursive: true);

    test('host get names one step per host it would deploy to', () async {
      installFakeHost();

      final previews = await previewCommand(
        HostGetCommand(HostGetInput(), deployer: deployer),
      );

      expect(previews.map((p) => p.verb).toList(), ['deploy']);
      expect(previews.single.target, 'host fake');
    });

    test('host get plans nothing when no host is detected', () async {
      final previews = await previewCommand(
        HostGetCommand(HostGetInput(), deployer: deployer),
      );

      expect(previews, isEmpty);
    });

    test('host get touches nothing: no skill reaches the host', () async {
      await previewCommand(
        HostGetCommand(HostGetInput(host: 'fake'), deployer: deployer),
      );

      expect(
        Directory(p.join(homeDir.path, '.fake', 'skills')).existsSync(),
        isFalse,
      );
    });

    test('host clean names the hosts and the repo-scoped agent', () async {
      final previews = await previewCommand(
        HostCleanCommand(
          HostCleanInput(),
          deployer: deployer,
          workingDirectory: tempDir.path,
        ),
      );

      expect(previews.map((p) => p.verb).toList(), ['clean', 'absent']);
    });

    test('host clean touches nothing: the deployment survives', () async {
      deployer.deploy('fake');

      await previewCommand(
        HostCleanCommand(
          HostCleanInput(),
          deployer: deployer,
          workingDirectory: tempDir.path,
        ),
      );

      expect(
        Directory(p.join(homeDir.path, '.fake', 'skills', 'iq-legacy'))
            .existsSync(),
        isFalse,
        reason: 'host get sweeps the iq- namespace it once deployed into',
      );
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
