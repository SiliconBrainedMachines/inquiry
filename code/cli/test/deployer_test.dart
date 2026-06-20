import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/hosts/deployer.dart';
import 'package:inquiry_cli/hosts/host_adapter.dart';

class FakeAdapter extends HostAdapter {
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
  late Assets assets;
  late FakeAdapter adapter;
  late HostDeployer deployer;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('ape_deployer_test_');
    homeDir = Directory(p.join(tempDir.path, 'home'))..createSync();

    // Create asset files
    final skillDir = Directory(
      p.join(tempDir.path, 'assets', 'skills', 'doc-read'),
    );
    skillDir.createSync(recursive: true);
    File(p.join(skillDir.path, 'SKILL.md')).writeAsStringSync('# Doc Read');

    final skillDir2 = Directory(
      p.join(tempDir.path, 'assets', 'skills', 'doc-write'),
    );
    skillDir2.createSync(recursive: true);
    File(
      p.join(skillDir2.path, 'SKILL.md'),
    ).writeAsStringSync('# Doc Write');

    final agentDir = Directory(p.join(tempDir.path, 'assets', 'agents'));
    agentDir.createSync(recursive: true);
    File(
      p.join(agentDir.path, 'inquiry.agent.md'),
    ).writeAsStringSync('# APE Agent');

    assets = Assets(root: tempDir.path);
    adapter = FakeAdapter();
    deployer = HostDeployer(
      assets: assets,
      adapters: [adapter],
      homeDir: homeDir.path,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('HostDeployer', () {
    test('deployExclusive copies skills to selected adapter skillsDirectory',
        () {
      deployer.deployExclusive('fake');

      final skillFile = File(
        p.join(homeDir.path, '.fake', 'skills', 'doc-read', 'SKILL.md'),
      );
      expect(skillFile.existsSync(), isTrue);
      expect(skillFile.readAsStringSync(), '# Doc Read');

      final skillFile2 = File(
        p.join(homeDir.path, '.fake', 'skills', 'doc-write', 'SKILL.md'),
      );
      expect(skillFile2.existsSync(), isTrue);
      expect(skillFile2.readAsStringSync(), '# Doc Write');
    });

    test('deployExclusive does NOT copy agent to adapter agentDirectory', () {
      deployer.deployExclusive('fake');

      final agentFile = File(
        p.join(homeDir.path, '.fake', 'agents', 'inquiry.agent.md'),
      );
      expect(agentFile.existsSync(), isFalse);
    });

    test('deployExclusive is idempotent — second run produces same result', () {
      deployer.deployExclusive('fake');
      deployer.deployExclusive('fake');

      final skillFile = File(
        p.join(homeDir.path, '.fake', 'skills', 'doc-read', 'SKILL.md'),
      );
      expect(skillFile.existsSync(), isTrue);
      expect(skillFile.readAsStringSync(), '# Doc Read');
    });

    test('deployExclusive cleans before deploying', () {
      deployer.deployExclusive('fake');

      // Create an extra file that shouldn't survive redeploy
      final extraFile = File(
        p.join(homeDir.path, '.fake', 'skills', 'stale-skill', 'SKILL.md'),
      );
      extraFile.parent.createSync(recursive: true);
      extraFile.writeAsStringSync('# Stale');

      deployer.deployExclusive('fake');

      expect(extraFile.existsSync(), isFalse);
    });

    test('clean removes deployed files from all adapters', () {
      deployer.deployExclusive('fake');
      deployer.clean();

      final skillsDir = Directory(p.join(homeDir.path, '.fake', 'skills'));
      final agentsDir = Directory(p.join(homeDir.path, '.fake', 'agents'));
      expect(skillsDir.existsSync(), isFalse);
      expect(agentsDir.existsSync(), isFalse);
    });

    test('clean does not fail if nothing was deployed', () {
      expect(() => deployer.clean(), returnsNormally);
    });

    test('deployExclusive can target either of two hosts', () {
      final allDeployer = HostDeployer(
        assets: assets,
        adapters: [
          FakeAdapter(),
          _SecondFakeAdapter(),
        ],
        homeDir: homeDir.path,
      );

      allDeployer.deployExclusive('fake');

      // Only 'fake' received skills
      expect(
        File(
          p.join(homeDir.path, '.fake', 'skills', 'doc-read', 'SKILL.md'),
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(homeDir.path, '.fake2', 'skills')).existsSync(),
        isFalse,
      );

      // Switch to fake2
      allDeployer.deployExclusive('fake2');

      // fake2 now has skills; fake is cleaned
      expect(
        File(
          p.join(homeDir.path, '.fake2', 'skills', 'doc-read', 'SKILL.md'),
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(homeDir.path, '.fake', 'skills')).existsSync(),
        isFalse,
      );
    });
  });

  // ─── deployExclusive() ────────────────────────────────────────────────────

  group('deployExclusive()', () {
    late HostDeployer multiDeployer;
    late _SecondFakeAdapter adapter2;

    setUp(() {
      adapter2 = _SecondFakeAdapter();
      multiDeployer = HostDeployer(
        assets: assets,
        adapters: [adapter, adapter2],
        homeDir: homeDir.path,
      );
    });

    test('deploys skills to the selected adapter only', () {
      multiDeployer.deployExclusive('fake');

      expect(
        File(p.join(homeDir.path, '.fake', 'skills', 'doc-read', 'SKILL.md'))
            .existsSync(),
        isTrue,
      );
      expect(
        Directory(p.join(homeDir.path, '.fake2', 'skills')).existsSync(),
        isFalse,
      );
    });

    test('does NOT write agent to adapter agentDirectory', () {
      multiDeployer.deployExclusive('fake');

      expect(
        File(p.join(homeDir.path, '.fake', 'agents', 'inquiry.agent.md'))
            .existsSync(),
        isFalse,
      );
    });

    test('cleans all adapters before deploying to selected', () {
      // Pre-populate both adapters
      for (final a in [adapter, adapter2]) {
        final stale = File(
          p.join(a.skillsDirectory(homeDir.path), 'stale', 'SKILL.md'),
        );
        stale.parent.createSync(recursive: true);
        stale.writeAsStringSync('stale');
      }

      multiDeployer.deployExclusive('fake');

      // Stale files cleaned from BOTH adapters
      expect(
        File(p.join(homeDir.path, '.fake', 'skills', 'stale', 'SKILL.md'))
            .existsSync(),
        isFalse,
      );
      expect(
        File(p.join(homeDir.path, '.fake2', 'skills', 'stale', 'SKILL.md'))
            .existsSync(),
        isFalse,
      );
    });

    test('is idempotent — second call to same target produces same result', () {
      multiDeployer.deployExclusive('fake');
      multiDeployer.deployExclusive('fake');

      expect(
        File(p.join(homeDir.path, '.fake', 'skills', 'doc-read', 'SKILL.md'))
            .existsSync(),
        isTrue,
      );
    });

    test('throws ArgumentError for unknown host name', () {
      expect(
        () => multiDeployer.deployExclusive('vscode'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('agent deploy (deploysAgent capability)', () {
    setUp(() {
      // Shared body + per-host frontmatter (assembled by AgentBuilder).
      File(p.join(tempDir.path, 'assets', 'agents', 'inquiry.body.md'))
          .writeAsStringSync('# Inquiry');
      final fmDir = Directory(
        p.join(tempDir.path, 'assets', 'agents', 'frontmatter'),
      )..createSync(recursive: true);
      File(p.join(fmDir.path, 'agenthost.yaml'))
          .writeAsStringSync('mode: primary');
    });

    test('deploys inquiry.md when the host opts in', () {
      final agentDeployer = HostDeployer(
        assets: assets,
        adapters: [_AgentHostAdapter()],
        homeDir: homeDir.path,
      );

      agentDeployer.deployExclusive('agenthost');

      final agentFile =
          File(p.join(homeDir.path, '.agenthost', 'agents', 'inquiry.md'));
      expect(agentFile.existsSync(), isTrue);
      expect(agentFile.readAsStringSync(), contains('mode: primary'));
    });

    test('does not deploy an agent when the host opts out', () {
      deployer.deployExclusive('fake'); // FakeAdapter.deploysAgent == false
      expect(
        Directory(p.join(homeDir.path, '.fake', 'agents')).existsSync(),
        isFalse,
      );
    });
  });
}

class _AgentHostAdapter extends HostAdapter {
  @override
  String get name => 'agenthost';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.agenthost');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.agenthost', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.agenthost', 'agents');

  @override
  bool get deploysAgent => true;
}

class _SecondFakeAdapter extends HostAdapter {
  @override
  String get name => 'fake2';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.fake2');

  @override
  String skillsDirectory(String homeDir) => p.join(homeDir, '.fake2', 'skills');

  @override
  String agentDirectory(String homeDir) => p.join(homeDir, '.fake2', 'agents');
}
