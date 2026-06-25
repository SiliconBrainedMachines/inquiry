import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
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

  group('iq host clean', () {
    test('exits 0 and removes deployed files', () async {
      // Deploy first using deployExclusive
      deployer.deployExclusive('fake');

      final command = HostCleanCommand(
        HostCleanInput(),
        deployer: deployer,
      );

      final output = await command.execute();

      expect(output.exitCode, ExitCode.ok);
      expect(
        Directory(p.join(homeDir.path, '.fake', 'skills')).existsSync(),
        isFalse,
      );
    });

    test('exits 0 when nothing to clean', () async {
      final command = HostCleanCommand(
        HostCleanInput(),
        deployer: deployer,
      );

      final output = await command.execute();

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

      await command.execute();

      expect(agentFile.existsSync(), isFalse,
      reason: 'iq host clean must remove repo-scoped agent');
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

      await command.execute();

      expect(agentFile.existsSync(), isFalse);
    });

    test('does not fail if .github/agents/inquiry.agent.md does not exist',
        () async {
      final command = HostCleanCommand(
        HostCleanInput(),
        deployer: deployer,
        workingDirectory: tempDir.path,
      );

      await expectLater(command.execute(), completes);
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
