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
    test('deploy copies skills to selected adapter skillsDirectory',
        () {
      deployer.deploy('fake');

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

    test('deploy does NOT copy agent to adapter agentDirectory', () {
      deployer.deploy('fake');

      final agentFile = File(
        p.join(homeDir.path, '.fake', 'agents', 'inquiry.agent.md'),
      );
      expect(agentFile.existsSync(), isFalse);
    });

    test('deploy is idempotent — second run produces same result', () {
      deployer.deploy('fake');
      deployer.deploy('fake');

      final skillFile = File(
        p.join(homeDir.path, '.fake', 'skills', 'doc-read', 'SKILL.md'),
      );
      expect(skillFile.existsSync(), isTrue);
      expect(skillFile.readAsStringSync(), '# Doc Read');
    });

    test('deploy is additive — does not clean before deploying (#280)', () {
      deployer.deploy('fake');

      final extraFile = File(
        p.join(homeDir.path, '.fake', 'skills', 'stale-skill', 'SKILL.md'),
      );
      extraFile.parent.createSync(recursive: true);
      extraFile.writeAsStringSync('# Stale');

      deployer.deploy('fake');

      // Additive: redeploy does not wipe existing files (use `iq host clean`).
      expect(extraFile.existsSync(), isTrue);
    });

    group('clean removes what Inquiry deployed, and only that', () {
      // The rule `_pruneRetiredSkills` has always applied, now applied here
      // too: the `iq-` namespace is Inquiry's, and a skill without it belongs
      // to someone else. `clean` used to delete each adapter's skills and
      // agents directories outright — ten directories across five adapters,
      // taking another tool's skills and anything the user had written with
      // them.

      File otherToolsSkill(String name) {
        final f = File(
          p.join(homeDir.path, '.fake', 'skills', name, 'SKILL.md'),
        );
        f.parent.createSync(recursive: true);
        f.writeAsStringSync('# $name');
        return f;
      }

      /// Planted rather than deployed: `FakeAdapter` inherits
      /// `deploysAgent => false`, and `clean`'s contract is to remove
      /// `inquiry.md` wherever it finds one, not only where this run put it.
      File plantAgentFile(String name) {
        final f = File(p.join(homeDir.path, '.fake', 'agents', name));
        f.parent.createSync(recursive: true);
        f.writeAsStringSync('# $name');
        return f;
      }

      test('removes its own agent file', () {
        final agent = plantAgentFile('inquiry.md');
        deployer.clean();
        expect(agent.existsSync(), isFalse);
      });

      test('removes iq- prefixed skills, which are its namespace', () {
        final legacy = otherToolsSkill('iq-analyze');
        deployer.clean();
        expect(legacy.existsSync(), isFalse);
      });

      test("leaves another tool's skills alone", () {
        final macss = otherToolsSkill('macss-plan');
        final skillwire = otherToolsSkill('legion');

        deployer.clean();

        expect(macss.existsSync(), isTrue);
        expect(skillwire.existsSync(), isTrue);
      });

      test('leaves a skill the user wrote by hand alone', () {
        final mine = otherToolsSkill('my-own-notes');
        deployer.clean();
        expect(mine.existsSync(), isTrue);
      });

      test('never removes the skills directory itself', () {
        // Deleting the directory takes every occupant with it, whoever they
        // belong to. Only named children are removed.
        deployer.deploy('fake');
        otherToolsSkill('macss-plan');

        deployer.clean();

        expect(
          Directory(p.join(homeDir.path, '.fake', 'skills')).existsSync(),
          isTrue,
        );
      });

      test('never removes the agents directory itself', () {
        plantAgentFile('inquiry.md');
        final other = plantAgentFile('someone-else.md');

        deployer.clean();

        expect(other.existsSync(), isTrue);
        expect(
          Directory(p.join(homeDir.path, '.fake', 'agents')).existsSync(),
          isTrue,
        );
      });

      test('does not fail if nothing was deployed', () {
        expect(() => deployer.clean(), returnsNormally);
      });

      test('does not fail when a host directory does not exist at all', () {
        expect(() => deployer.clean(), returnsNormally);
        expect(
          Directory(p.join(homeDir.path, '.fake', 'skills')).existsSync(),
          isFalse,
          reason: 'clean must not create what it came to inspect',
        );
      });

      test('is idempotent', () {
        deployer.deploy('fake');
        deployer.clean();
        expect(() => deployer.clean(), returnsNormally);
      });
    });

    test('deploy can target either of two hosts', () {
      final allDeployer = HostDeployer(
        assets: assets,
        adapters: [
          FakeAdapter(),
          _SecondFakeAdapter(),
        ],
        homeDir: homeDir.path,
      );

      allDeployer.deploy('fake');

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

      // Add fake2 — additive (#280)
      allDeployer.deploy('fake2');

      // fake2 now has skills; fake is KEPT (additive — both coexist).
      expect(
        File(
          p.join(homeDir.path, '.fake2', 'skills', 'doc-read', 'SKILL.md'),
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          p.join(homeDir.path, '.fake', 'skills', 'doc-read', 'SKILL.md'),
        ).existsSync(),
        isTrue,
      );
    });
  });

  // ─── deploy() ────────────────────────────────────────────────────

  group('deploy()', () {
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
      multiDeployer.deploy('fake');

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
      multiDeployer.deploy('fake');

      expect(
        File(p.join(homeDir.path, '.fake', 'agents', 'inquiry.agent.md'))
            .existsSync(),
        isFalse,
      );
    });

    test('is additive — leaves other adapters untouched (#280)', () {
      // Pre-populate both adapters
      for (final a in [adapter, adapter2]) {
        final stale = File(
          p.join(a.skillsDirectory(homeDir.path), 'stale', 'SKILL.md'),
        );
        stale.parent.createSync(recursive: true);
        stale.writeAsStringSync('stale');
      }

      multiDeployer.deploy('fake');

      // The OTHER adapter (fake2) is untouched — additive deploy.
      expect(
        File(p.join(homeDir.path, '.fake2', 'skills', 'stale', 'SKILL.md'))
            .existsSync(),
        isTrue,
      );
    });

    test('is idempotent — second call to same target produces same result', () {
      multiDeployer.deploy('fake');
      multiDeployer.deploy('fake');

      expect(
        File(p.join(homeDir.path, '.fake', 'skills', 'doc-read', 'SKILL.md'))
            .existsSync(),
        isTrue,
      );
    });

    test('throws ArgumentError for unknown host name', () {
      expect(
        () => multiDeployer.deploy('vscode'),
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

      agentDeployer.deploy('agenthost');

      final agentFile =
          File(p.join(homeDir.path, '.agenthost', 'agents', 'inquiry.md'));
      expect(agentFile.existsSync(), isTrue);
      expect(agentFile.readAsStringSync(), contains('mode: primary'));
    });

    test('does not deploy an agent when the host opts out', () {
      deployer.deploy('fake'); // FakeAdapter.deploysAgent == false
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
