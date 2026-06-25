import 'dart:io';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/modules/global/commands/doctor.dart';
import 'package:inquiry_cli/src/version_check.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Mock filesystem for testing doctor host checks.
class MockFileSystemOps implements FileSystemOps {
  final Map<String, bool> _files = {};
  final Map<String, bool> _dirs = {};
  final Map<String, String> _contents = {};
  String _home = '/home/testuser';

  void setFileExists(String path, bool exists) => _files[path] = exists;
  void setDirectoryExists(String path, bool exists) => _dirs[path] = exists;
  void setHome(String home) => _home = home;
  void setFileContents(String path, String content) {
    _contents[path] = content;
    _files[path] = true;
  }

  @override
  bool fileExists(String path) => _files[path] ?? false;

  @override
  bool directoryExists(String path) => _dirs[path] ?? false;

  @override
  String homeDirectory() => _home;

  @override
  String? readFile(String path) => _contents[path];
}

void main() {
  group('DoctorCommand', () {
    // Helper to create a fake ProcessRunner
    ProcessRunner fakeRunner({
      bool gitFails = false,
      bool ghFails = false,
      bool ghAuthFails = false,
      Map<String, int?>? ollamaCtx,
    }) {
      return (
        String executable,
        List<String> arguments, {
        String? workingDirectory,
      }) async {
        // ollama show <model> --modelfile
        if (executable == 'ollama' && arguments.contains('show')) {
          final model = arguments.firstWhere(
            (a) => a != 'show' && a != '--modelfile',
            orElse: () => '',
          );
          final ctx = ollamaCtx?[model];
          if (ctx == null) {
            // No num_ctx PARAMETER → Ollama default (4096)
            return ProcessResult(0, 0, 'FROM $model\n', '');
          }
          return ProcessResult(
            0,
            0,
            'FROM $model\nPARAMETER num_ctx $ctx\n',
            '',
          );
        }

        // git --version
        if (executable == 'git' && arguments.contains('--version')) {
          if (gitFails) {
            return ProcessResult(1, 1, '', 'git: command not found');
          }
          return ProcessResult(0, 0, 'git version 2.43.0', '');
        }

        // gh auth status
        if (executable == 'gh' && arguments.contains('auth')) {
          if (ghAuthFails) {
            return ProcessResult(
              1,
              1,
              '',
              'You are not logged into any GitHub hosts.',
            );
          }
          return ProcessResult(
            0,
            0,
            'Logged in to github.com as user (oauth_token)',
            '',
          );
        }

        // gh --version
        if (executable == 'gh' && arguments.contains('--version')) {
          if (ghFails) {
            return ProcessResult(1, 1, '', 'gh: command not found');
          }
          return ProcessResult(0, 0, 'gh version 2.45.0 (2024-03-01)', '');
        }

        // Default: success
        return ProcessResult(0, 0, 'v1.0.0', '');
      };
    }

    // Constants for test paths
    const workingDir = '/repo/current';
    const homeDir = '/home/testuser';

    /// Creates a mock FS where `.inquiry/` exists and OpenCode is installed
    /// GLOBALLY (agent + skills) — the default active host (#280).
    MockFileSystemOps allPassFs(String wd, String home, List<String> skills) {
      final fs = MockFileSystemOps()..setHome(home);
      fs.setDirectoryExists('.inquiry', true);
      fs.setFileExists(
        p.join(home, '.config', 'opencode', 'agent', 'inquiry.md'),
        true,
      );
      for (final skill in skills) {
        fs.setFileExists(
          p.join(home, '.config', 'opencode', 'skills', skill, 'SKILL.md'),
          true,
        );
      }
      return fs;
    }

    /// Creates a temp Assets directory with the given skill names.
    late Directory tempDir;
    late Assets testAssets;
    final testSkills = [
      'doc-read',
      'doc-write',
      'inquiry-install',
      'kritik',
      'legion',
      'research',
      'issue-create',
      'inquiry-start',
      'inquiry-end',
    ];

    Assets seedAssets(Directory root, {required List<String> apes}) {
      final skillsDir = Directory(p.join(root.path, 'assets', 'skills'));
      for (final skill in testSkills) {
        final skillDir = Directory(p.join(skillsDir.path, skill));
        skillDir.createSync(recursive: true);
        File(p.join(skillDir.path, 'SKILL.md')).writeAsStringSync('---\nname: $skill\n---');
      }

      final agentsDir = Directory(p.join(root.path, 'assets', 'agents'));
      agentsDir.createSync(recursive: true);
      File(p.join(agentsDir.path, 'inquiry.agent.md')).writeAsStringSync('# Agent');

      final apesDir = Directory(p.join(root.path, 'assets', 'apes'));
      apesDir.createSync(recursive: true);
      for (final ape in apes) {
        File(p.join(apesDir.path, '$ape.yaml')).writeAsStringSync('name: $ape\n');
      }

      final statesDir = Directory(p.join(root.path, 'assets', 'fsm', 'states'));
      statesDir.createSync(recursive: true);
      for (final state in ['idle', 'analyze', 'plan', 'execute', 'end', 'evolution']) {
        File(p.join(statesDir.path, '$state.yaml')).writeAsStringSync('name: $state\ninstructions: "test"\n');
      }

      final fsmDir = Directory(p.join(root.path, 'assets', 'fsm'));
      File(p.join(fsmDir.path, 'transition_contract.yaml')).writeAsStringSync('metadata:\n  version: "1.0.0"\n');

      return Assets(root: root.path);
    }

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('doctor_test_');
      testAssets = seedAssets(
        tempDir,
        apes: ['socrates', 'dewey', 'descartes', 'ada', 'darwin'],
      );
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    DoctorCommand makeCmd({
      ProcessRunner? runProcess,
      String version = '0.0.9',
      MockFileSystemOps? fs,
      Assets? assets,
      String? wd,
    }) {
      final resolvedWd = wd ?? workingDir;
      return DoctorCommand(
        DoctorInput(),
        runProcess: runProcess ?? fakeRunner(),
        inquiryVersionOverride: version,
        fileSystemOps: fs ?? allPassFs(resolvedWd, homeDir, testSkills),
        assets: assets ?? testAssets,
        versionChecker: ({required String currentVersion}) async =>
            const VersionCheckResult(updateAvailable: false),
      );
    }

    test('all checks pass → exit 0', () async {
      final cmd = makeCmd();
      final output = await cmd.execute();

      expect(output.passed, isTrue);
      expect(output.exitCode, 0);
      expect(output.checks.length, 5);
      expect(output.checks.every((c) => c.passed), isTrue);
    });

    test('assets check reports missing dewey when bundled APEs omit it', () async {
      final customDir = Directory.systemTemp.createTempSync('doctor_missing_dewey_');
      addTearDown(() {
        customDir.deleteSync(recursive: true);
      });

      final cmd = makeCmd(
        assets: seedAssets(
          customDir,
          apes: ['socrates', 'descartes', 'ada', 'darwin'],
        ),
      );
      final output = await cmd.execute();
      final assetsCheck = output.checks.firstWhere((c) => c.name == 'assets');

      expect(assetsCheck.error ?? '', contains('apes/dewey.yaml'));
      expect(assetsCheck.error ?? '', isNot(contains('apes/socrates-idle.yaml')));
    });

    test('assets check does not require socrates-idle when dewey is present', () async {
      final customDir = Directory.systemTemp.createTempSync('doctor_without_socrates_idle_');
      addTearDown(() {
        customDir.deleteSync(recursive: true);
      });

      final cmd = makeCmd(
        assets: seedAssets(
          customDir,
          apes: ['socrates', 'dewey', 'descartes', 'ada', 'darwin'],
        ),
      );
      final output = await cmd.execute();
      final assetsCheck = output.checks.firstWhere((c) => c.name == 'assets');

      expect(assetsCheck.error ?? '', isNot(contains('apes/socrates-idle.yaml')));
      expect(assetsCheck.passed, isTrue);
    });

    test('git missing → exit 1, stopped at git', () async {
      final cmd = makeCmd(runProcess: fakeRunner(gitFails: true));
      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final gitCheck = output.checks.firstWhere((c) => c.name == 'git');
      expect(gitCheck.passed, isFalse);
      expect(gitCheck.error, isNotNull);
    });

    test('gh missing → exit 1', () async {
      final cmd = makeCmd(runProcess: fakeRunner(ghFails: true));
      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final ghCheck = output.checks.firstWhere((c) => c.name == 'gh');
      expect(ghCheck.passed, isFalse);
    });

    test('gh auth fails → exit 1', () async {
      final cmd = makeCmd(runProcess: fakeRunner(ghAuthFails: true));
      final output = await cmd.execute();

      expect(output.passed, isFalse);
      expect(output.exitCode, 1);

      final authCheck = output.checks.firstWhere((c) => c.name == 'gh auth');
      expect(authCheck.passed, isFalse);
    });

    test('toJson() returns correct structure', () async {
      final cmd = makeCmd();
      final output = await cmd.execute();
      final json = output.toJson();

      expect(json, containsPair('passed', true));
      expect(json['checks'], isList);
      expect((json['checks'] as List).length, 5);
      expect(json['hostChecks'], isList);
      expect((json['hostChecks'] as List).length, 2);

      final firstCheck = (json['checks'] as List).first as Map<String, dynamic>;
      expect(firstCheck, containsPair('name', 'inquiry'));
      expect(firstCheck, containsPair('passed', true));
      expect(firstCheck, containsPair('version', '0.0.9'));
    });

    test('DoctorInput.toJson() returns fix field', () {
      final input = DoctorInput();
      expect(input.toJson(), equals({'fix': false}));
    });

    test('DoctorCheck.toJson() includes error when present', () {
      final check = DoctorCheck(name: 'git', passed: false, error: 'not found');

      final json = check.toJson();

      expect(json, containsPair('name', 'git'));
      expect(json, containsPair('passed', false));
      expect(json, containsPair('error', 'not found'));
      expect(json.containsKey('version'), isFalse);
    });

    test('toText() returns formatted checkmarks when all pass', () async {
      final cmd = makeCmd(version: '0.0.10');
      final output = await cmd.execute();
      final text = output.toText()!;

      expect(text, contains('Checking prerequisites...'));
      expect(text, contains('✓ inquiry'));
      expect(text, contains('✓ git'));
      expect(text, contains('✓ gh'));
      expect(text, contains('All checks passed.'));
    });

    test('toText() shows failure indicators when check fails', () async {
      final cmd = makeCmd(runProcess: fakeRunner(gitFails: true));
      final output = await cmd.execute();
      final text = output.toText()!;

      expect(text, contains('✓ inquiry'));
      expect(text, contains('✗ git'));
      expect(text, contains('Some checks failed.'));
    });

    group('Host verification', () {
      test('Scenario A: active host (opencode) deployed → exit 0', () async {
        final cmd = makeCmd();
        final output = await cmd.execute();

        expect(output.passed, isTrue);
        expect(output.exitCode, 0);
        expect(output.hostChecks.length, 2);
        final opencode =
            output.hostChecks.firstWhere((h) => h.hostName == 'opencode');
        expect(opencode.active, isTrue);
        expect(opencode.passed, isTrue);
        expect(opencode.agentExists, isTrue);
        expect(opencode.missingSkills, isEmpty);
        // Claude is simply not deployed here — not a failure.
        final claude =
            output.hostChecks.firstWhere((h) => h.hostName == 'claude');
        expect(claude.active, isFalse);

        final text = output.toText()!;
        expect(text, contains('Checking hosts...'));
        expect(text, contains('✓ opencode: agent + 9 skills deployed'));
        expect(text, contains('- claude: not deployed (inactive)'));
        expect(text, contains('All checks passed.'));
      });

      test('Scenario B: nothing deployed → exit 1', () async {
        final fs = MockFileSystemOps()..setHome(homeDir);
        fs.setDirectoryExists('.inquiry', true);
        // Agent and skills do NOT exist

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();

        expect(output.passed, isFalse);
        expect(output.exitCode, 1);
        // No host has skills → none active.
        expect(output.hostChecks.every((h) => !h.active), isTrue);

        final text = output.toText()!;
        expect(text, contains('✗ no host deployed'));
        expect(text,
            contains("Run 'inquiry host get --host <opencode|claude>'"));
        expect(text, contains('Some checks failed.'));
      });

      test('Scenario C: no .inquiry/ directory → exit 1', () async {
        final fs = MockFileSystemOps()..setHome(homeDir);
        // .inquiry does NOT exist, hosts do NOT exist

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();

        expect(output.passed, isFalse);
        expect(output.exitCode, 1);

        // Init check failed
        final initCheck = output.checks.firstWhere(
          (c) => c.name == 'inquiry init',
        );
        expect(initCheck.passed, isFalse);

        final text = output.toText()!;
        expect(text, contains('✗ inquiry init'));
        expect(text, contains("Run 'inquiry init' to initialize"));
        // Nothing deployed → no active host.
        expect(text, contains('✗ no host deployed'));
      });

      test('Scenario D: partial deployment → exit 1', () async {
        final fs = MockFileSystemOps()..setHome(homeDir);
        fs.setDirectoryExists('.inquiry', true);
        // OpenCode global agent present
        fs.setFileExists(
          p.join(homeDir, '.config', 'opencode', 'agent', 'inquiry.md'),
          true,
        );
        // Deploy everything except issue-create (global skills).
        for (final skill in [
          'doc-read',
          'doc-write',
          'inquiry-install',
          'kritik',
          'legion',
          'research',
          'inquiry-start',
          'inquiry-end',
        ]) {
          fs.setFileExists(
            p.join(homeDir, '.config', 'opencode', 'skills', skill, 'SKILL.md'),
            true,
          );
        }
        // issue-create is MISSING

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();

        expect(output.passed, isFalse);
        expect(output.exitCode, 1);
        final opencode =
            output.hostChecks.firstWhere((h) => h.hostName == 'opencode');
        expect(opencode.active, isTrue);
        expect(opencode.agentExists, isTrue);
        expect(opencode.missingSkills, ['issue-create']);

        final text = output.toText()!;
        expect(text, contains('✓ opencode: agent deployed'));
        expect(text, contains('✗ opencode: missing skills: issue-create'));
        expect(text,
            contains("Run 'inquiry host get --host opencode' to deploy skills"));
      });

      test('HostCheck.toJson() includes all fields', () {
        final check = HostCheck(
          hostName: 'copilot',
          agentExists: true,
          missingSkills: ['doc-read'],
          totalSkills: 9,
        );

        final json = check.toJson();
        expect(json['hostName'], 'copilot');
        expect(json['agentExists'], true);
        expect(json['missingSkills'], ['doc-read']);
        expect(json['totalSkills'], 9);
      });

      test('HostCheck.passed is true when agent exists and no missing skills', () {
        final passing = HostCheck(
          hostName: 'copilot',
          agentExists: true,
          missingSkills: [],
          totalSkills: 9,
        );
        expect(passing.passed, isTrue);

        final failing = HostCheck(
          hostName: 'copilot',
          agentExists: false,
          missingSkills: ['x'],
          totalSkills: 1,
        );
        expect(failing.passed, isFalse);
      });

      test('DoctorCheck.toJson() includes remediation when present', () {
        final check = DoctorCheck(
          name: 'ape init',
          passed: false,
          error: 'not initialized',
          remediation: "Run 'ape init' to initialize",
        );

        final json = check.toJson();
        expect(json['remediation'], "Run 'ape init' to initialize");
      });

      // ─── E3: repo-scoped agent tests ───────────────────────────────────────

      test('doctor passes when inquiry.agent.md is in .github/agents/', () async {
        final fs = allPassFs(workingDir, homeDir, testSkills);
        final cmd = makeCmd(fs: fs);

        final output = await cmd.execute();

        expect(output.hostChecks.first.agentExists, isTrue);
        expect(output.passed, isTrue);
      });

      test('doctor fails when inquiry.agent.md is NOT in .github/agents/', () async {
        final fs = MockFileSystemOps()..setHome(homeDir);
        fs.setDirectoryExists('.inquiry', true);
        // Agent absent — no file set

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();

        expect(output.hostChecks.first.agentExists, isFalse);
        expect(output.passed, isFalse);
      });

      test('doctor ignores agent at old path ~/.copilot/agents/', () async {
        final fs = MockFileSystemOps()..setHome(homeDir);
        fs.setDirectoryExists('.inquiry', true);
        // Agent at OLD global path (pre-0.5.0)
        fs.setFileExists(
          p.join(homeDir, '.copilot', 'agents', 'inquiry.agent.md'),
          true,
        );
        // NOT in new repo-scoped path

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();

        expect(output.hostChecks.first.agentExists, isFalse,
            reason: 'Old global path is no longer valid — must run iq init');
      });

      test('doctor remediation suggests host get when no host is deployed', () async {
        final fs = MockFileSystemOps()..setHome(homeDir);
        fs.setDirectoryExists('.inquiry', true);
        // No agent, no skills → no active host

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();
        final text = output.toText()!;

        expect(text, contains('✗ no host deployed'));
        expect(text, contains('inquiry host get --host'));
        expect(text, isNot(contains("'inquiry target get'")));
      });

      test('Scenario E: OpenCode active (global), Claude inactive → exit 0', () async {
        final fs = MockFileSystemOps()..setHome(homeDir);
        fs.setDirectoryExists('.inquiry', true);
        // OpenCode installed globally: agent + skills (#280).
        fs.setFileExists(
          p.join(homeDir, '.config', 'opencode', 'agent', 'inquiry.md'),
          true,
        );
        for (final skill in testSkills) {
          fs.setFileExists(
            p.join(homeDir, '.config', 'opencode', 'skills', skill, 'SKILL.md'),
            true,
          );
        }

        final cmd = makeCmd(fs: fs);
        final output = await cmd.execute();

        expect(output.passed, isTrue,
            reason: 'OpenCode is fully deployed → healthy');
        expect(output.exitCode, 0);
        final opencode =
            output.hostChecks.firstWhere((h) => h.hostName == 'opencode');
        expect(opencode.active, isTrue);
        expect(opencode.passed, isTrue);
        final claude =
            output.hostChecks.firstWhere((h) => h.hostName == 'claude');
        expect(claude.active, isFalse,
            reason: 'Claude not deployed → inactive, not a failure');

        final text = output.toText()!;
        expect(text, contains('✓ opencode: agent + 9 skills deployed'));
        expect(text, contains('- claude: not deployed (inactive)'));
        expect(text, contains('All checks passed.'));
      });

      test('no assets available → hosts still checked, 0 skills expected', () async {
        final fs = allPassFs(workingDir, homeDir, []);
        // Assets with empty skills dir
        final emptyTempDir = Directory.systemTemp.createTempSync('empty_assets_');
        Directory(p.join(emptyTempDir.path, 'assets', 'skills')).createSync(recursive: true);
        final emptyAssets = Assets(root: emptyTempDir.path);

        final cmd = makeCmd(fs: fs, assets: emptyAssets);
        final output = await cmd.execute();

        // Agent exists, 0 skills expected → passes
        expect(output.hostChecks.first.totalSkills, 0);
        expect(output.hostChecks.first.agentExists, isTrue);
        expect(output.hostChecks.first.passed, isTrue);

        emptyTempDir.deleteSync(recursive: true);
      });
    });

    group('OpenCode/Ollama context check (#259)', () {
      const jsonc = '''
{
  // local Ollama provider
  "\$schema": "https://opencode.ai/config.json",
  "provider": { "ollama": { "models": {
    "qwen3-coder:30b": {},
    "qwen3-coder:30b-16k": {}
  } } }
}
''';

      // Filesystem where OpenCode is the active/deployed host (global, #280).
      MockFileSystemOps opencodeActiveFs() {
        final fs = MockFileSystemOps()..setHome(homeDir);
        fs.setDirectoryExists('.inquiry', true);
        fs.setFileExists(
          p.join(homeDir, '.config', 'opencode', 'agent', 'inquiry.md'),
          true,
        );
        for (final s in testSkills) {
          fs.setFileExists(
            p.join(homeDir, '.config', 'opencode', 'skills', s, 'SKILL.md'),
            true,
          );
        }
        fs.setFileContents(
          p.join(homeDir, '.config', 'opencode', 'opencode.jsonc'),
          jsonc,
        );
        return fs;
      }

      test('FAILS when a configured Ollama model defaults to num_ctx 4096', () async {
        // 30b-16k is fine; 30b is omitted → fakeRunner emits no num_ctx → 4096.
        final cmd = makeCmd(
          fs: opencodeActiveFs(),
          runProcess: fakeRunner(ollamaCtx: {'qwen3-coder:30b-16k': 16384}),
        );
        final output = await cmd.execute();

        expect(output.passed, isFalse);
        final ctx = output.checks.firstWhere(
          (c) => c.name == 'opencode/ollama context',
        );
        expect(ctx.passed, isFalse);
        expect(ctx.error, contains('qwen3-coder:30b'));
        expect(ctx.error, contains('4096'));
        // the adequate model must NOT be flagged
        expect(ctx.error, isNot(contains('30b-16k (num_ctx')));
      });

      test('PASSES when all Ollama models have num_ctx >= 16384', () async {
        final cmd = makeCmd(
          fs: opencodeActiveFs(),
          runProcess: fakeRunner(ollamaCtx: {
            'qwen3-coder:30b': 16384,
            'qwen3-coder:30b-16k': 32768,
          }),
        );
        final output = await cmd.execute();

        expect(output.passed, isTrue);
        expect(
          output.checks.any((c) => c.name == 'opencode/ollama context'),
          isFalse,
        );
      });

      test('is SKIPPED when OpenCode is not the active host', () async {
        // Claude active; OpenCode inactive. A 4096 Ollama model must not fail.
        final fs = MockFileSystemOps()..setHome(homeDir);
        fs.setDirectoryExists('.inquiry', true);
        fs.setFileExists(
          p.join(homeDir, '.claude', 'agents', 'inquiry.md'),
          true,
        );
        for (final s in testSkills) {
          fs.setFileExists(
            p.join(homeDir, '.claude', 'skills', s, 'SKILL.md'),
            true,
          );
        }
        fs.setFileContents(
          p.join(homeDir, '.config', 'opencode', 'opencode.jsonc'),
          jsonc,
        );
        final cmd = makeCmd(fs: fs, runProcess: fakeRunner(ollamaCtx: {}));
        final output = await cmd.execute();

        expect(output.passed, isTrue);
        expect(
          output.checks.any((c) => c.name == 'opencode/ollama context'),
          isFalse,
        );
      });
    });
  });
}
