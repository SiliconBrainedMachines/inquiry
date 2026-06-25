import 'dart:io';

import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/modules/global/commands/uninstall.dart';
import 'package:inquiry_cli/hosts/deployer.dart';
import 'package:inquiry_cli/hosts/host_adapter.dart';

import 'platform_ops_test.dart' show FakePlatformOps;

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
    tempDir = Directory.systemTemp.createTempSync('ape_uninstall_test_');
    homeDir = Directory(p.join(tempDir.path, 'home'))..createSync();

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

  group('UninstallCommand', () {
    test('cleans deployed hosts', () async {
      deployer.deploy('fake');

      expect(
        File(
          p.join(homeDir.path, '.fake', 'skills', 'doc-read', 'SKILL.md'),
        ).existsSync(),
        isTrue,
      );

      final command = UninstallCommand(
        UninstallInput(installDir: tempDir.path),
        deployer: deployer,
        platformOps: FakePlatformOps(),
      );

      final output = await command.execute();

      expect(output.exitCode, ExitCode.ok);
      expect(output.message, contains('uninstalled'));

      // Hosts should be cleaned
      expect(
        Directory(p.join(homeDir.path, '.fake', 'skills')).existsSync(),
        isFalse,
      );
      expect(
        Directory(p.join(homeDir.path, '.fake', 'agents')).existsSync(),
        isFalse,
      );
    });

    test('exits 0 when nothing was deployed', () async {
      final command = UninstallCommand(
        UninstallInput(installDir: tempDir.path),
        deployer: deployer,
        platformOps: FakePlatformOps(),
      );

      final output = await command.execute();
      expect(output.exitCode, ExitCode.ok);
    });

    test('removes bin dir from PATH via platformOps', () async {
      final binDir = p.join(tempDir.path, 'bin');
      final sep = Platform.isWindows ? ';' : ':';
      final otherA = Platform.isWindows ? r'C:\other' : '/other';
      final otherB = Platform.isWindows ? r'C:\more' : '/more';
      final fakePath = '$otherA$sep$binDir$sep$otherB';
      final ops = FakePlatformOps(fakeEnvValue: fakePath);

      final command = UninstallCommand(
        UninstallInput(installDir: tempDir.path),
        deployer: deployer,
        platformOps: ops,
      );

      await command.execute();

      expect(ops.calls, contains('getEnvVariable(PATH)'));
      final expectedNew = '$otherA$sep$otherB';
      expect(
        ops.calls,
        contains('setEnvVariable(PATH, $expectedNew)'),
      );
    });

    test('does not call setEnvVariable when bin dir is not in PATH', () async {
      final sep = Platform.isWindows ? ';' : ':';
      final otherA = Platform.isWindows ? r'C:\other' : '/other';
      final otherB = Platform.isWindows ? r'C:\more' : '/more';
      final ops = FakePlatformOps(fakeEnvValue: '$otherA$sep$otherB');

      final command = UninstallCommand(
        UninstallInput(installDir: tempDir.path),
        deployer: deployer,
        platformOps: ops,
      );

      await command.execute();

      expect(ops.calls, contains('getEnvVariable(PATH)'));
      expect(
        ops.calls.where((c) => c.startsWith('setEnvVariable')),
        isEmpty,
      );
    });

    test('schedules deletion of install directory', () async {
      final ops = FakePlatformOps();

      final command = UninstallCommand(
        UninstallInput(installDir: tempDir.path),
        deployer: deployer,
        platformOps: ops,
      );

      await command.execute();

      expect(ops.calls, contains('scheduleDeletion(${tempDir.path})'));
    });

    test('removes .github/agents/inquiry.agent.md from working directory',
        () async {
      final agentFile = File(
        p.join(tempDir.path, '.github', 'agents', 'inquiry.agent.md'),
      );
      agentFile.parent.createSync(recursive: true);
      agentFile.writeAsStringSync('# APE Agent');

      final command = UninstallCommand(
        UninstallInput(installDir: tempDir.path),
        deployer: deployer,
        workingDirectory: tempDir.path,
        platformOps: FakePlatformOps(),
      );

      await command.execute();

      expect(agentFile.existsSync(), isFalse,
          reason: 'iq uninstall must remove repo-scoped agent');
    });

    test('does not fail if .github/agents/inquiry.agent.md does not exist',
        () async {
      final command = UninstallCommand(
        UninstallInput(installDir: tempDir.path),
        deployer: deployer,
        workingDirectory: tempDir.path,
        platformOps: FakePlatformOps(),
      );

      await expectLater(command.execute(), completes);
    });
  });
}
