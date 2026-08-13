/// Doctor command — verifies prerequisites and host deployment.
///
/// Checks: inquiry version, git, gh, gh auth, .inquiry/ init, host deployment.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../assets.dart';
import '../../../src/version.dart' as version_lib;
import '../../../src/version_check.dart';
import '../../../hosts/all_adapters.dart';
import '../../../hosts/host_adapter.dart';
import '../../../hosts/ollama_context.dart';

/// Function type for running external processes.
///
/// Allows injection of a mock for testing.
typedef ProcessRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

/// Result of a single prerequisite check.
class DoctorCheck {
  final String name;
  final bool passed;
  final String? version;
  final String? error;
  final String? remediation;

  DoctorCheck({
    required this.name,
    required this.passed,
    this.version,
    this.error,
    this.remediation,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'passed': passed,
    if (version != null) 'version': version,
    if (error != null) 'error': error,
    if (remediation != null) 'remediation': remediation,
  };
}

/// Result of checking a host's deployment status.
class HostCheck {
  final String hostName;
  final bool agentExists;
  final List<String> missingSkills;
  final int totalSkills;
  final String? error;

  /// Whether this host is the active/deployed one (its skills are present).
  /// Under the exclusive deploy model exactly one host is active at a time; an
  /// inactive host is not a failure (it was simply not the chosen host).
  final bool active;

  /// Whether the host tool itself is present on this machine.
  ///
  /// `iq host get` only deploys to hosts that are installed, so "not installed"
  /// is the reason an absent deployment is fine — and reporting it here is what
  /// makes that legible instead of looking like a missing step (#300).
  final bool installed;

  HostCheck({
    required this.hostName,
    required this.agentExists,
    required this.missingSkills,
    required this.totalSkills,
    this.error,
    this.active = true,
    this.installed = true,
  });

  /// A host that is not installed, or not the active one, never fails the
  /// doctor. An active, installed host must be complete.
  bool get passed =>
      !installed ||
      !active ||
      (agentExists && missingSkills.isEmpty && error == null);

  Map<String, dynamic> toJson() => {
    'hostName': hostName,
    'agentExists': agentExists,
    'missingSkills': missingSkills,
    'totalSkills': totalSkills,
    'active': active,
    'installed': installed,
    if (error != null) 'error': error,
  };
}

/// Input for the doctor command.
///
/// Accepts an optional `--fix` flag to auto-remediate failures.
class DoctorInput extends Input {
  final bool fix;

  DoctorInput({this.fix = false});

  static final List<CliParam> params = [
    CliParam.boolean(
      'fix',
      description: 'Re-download the internal assets when they are missing',
    ),
  ];

  factory DoctorInput.fromCliRequest(CliRequest req) =>
      DoctorInput(fix: req.flagBool('fix'));

  @override
  List<CliParam> get schemaFields => params;

  @override
  Map<String, dynamic> toJson() => {'fix': fix};
}

/// Output for the doctor command.
class DoctorOutput extends Output {
  final List<DoctorCheck> checks;
  final List<HostCheck> hostChecks;
  final bool passed;

  DoctorOutput({
    required this.checks,
    this.hostChecks = const [],
    required this.passed,
  });

  @override
  Map<String, dynamic> toJson() => {
    'checks': checks.map((c) => c.toJson()).toList(),
    'hostChecks': hostChecks.map((c) => c.toJson()).toList(),
    'passed': passed,
  };

  @override
  int get exitCode => passed ? ExitCode.ok : ExitCode.genericError;

  /// Returns formatted checkmarks for text mode (like flutter doctor).
  @override
  String? toText() {
    final buffer = StringBuffer('Checking prerequisites...\n');
    for (final check in checks) {
      final icon = check.passed ? '✓' : '✗';
      final suffix = check.version ?? check.error ?? '';
      if (suffix.isNotEmpty) {
        buffer.writeln('  $icon ${check.name} $suffix');
      } else {
        buffer.writeln('  $icon ${check.name}');
      }
      if (!check.passed && check.remediation != null) {
        buffer.writeln("    → ${check.remediation}");
      }
    }

    if (hostChecks.isNotEmpty) {
      buffer.writeln('Checking hosts...');
      for (final tc in hostChecks) {
        if (tc.error != null) {
          buffer.writeln('  ✗ ${tc.hostName}: ${tc.error}');
        } else if (!tc.installed) {
          // The host tool is not on this machine. Nothing to deploy into, and
          // nothing wrong: a machine may carry the CLI and no AI assistant.
          buffer.writeln('  - ${tc.hostName}: not installed');
        } else if (!tc.active) {
          // Not the active host — informational, not a failure.
          buffer.writeln('  - ${tc.hostName}: not deployed (inactive)');
        } else if (tc.passed) {
          final deployed = tc.totalSkills - tc.missingSkills.length;
          buffer.writeln(
            '  ✓ ${tc.hostName}: agent + $deployed skills deployed',
          );
        } else {
          if (!tc.agentExists) {
            buffer.writeln('  ✗ ${tc.hostName}: agent not deployed');
            buffer.writeln(
              "    → Run 'iq host get --host ${tc.hostName} --apply' to install the agent",
            );
          } else {
            buffer.writeln('  ✓ ${tc.hostName}: agent deployed');
          }
          if (tc.missingSkills.isNotEmpty) {
            buffer.writeln(
              '  ✗ ${tc.hostName}: missing skills: '
              '${tc.missingSkills.join(', ')}',
            );
            // Only suggest host get when agent is already deployed
            if (tc.agentExists) {
              buffer.writeln(
                "    → Run 'iq host get --host ${tc.hostName} --apply' to deploy skills",
              );
            }
          }
        }
      }
      if (!hostChecks.any((hc) => hc.installed)) {
        buffer.writeln('  - no AI coding host installed on this machine');
      } else if (!hostChecks.any((hc) => hc.active)) {
        buffer.writeln('  ✗ no host deployed');
        buffer.writeln("    → Run 'iq host get --apply'");
      }
    }

    buffer.writeln();
    buffer.write(passed ? 'All checks passed.' : 'Some checks failed.');
    return buffer.toString();
  }
}

/// Abstraction for filesystem operations (testable).
abstract class FileSystemOps {
  bool fileExists(String path);
  bool directoryExists(String path);
  String homeDirectory();

  /// Reads a text file, or returns null if it does not exist.
  String? readFile(String path);
}

/// Production implementation using dart:io.
class RealFileSystemOps implements FileSystemOps {
  @override
  bool fileExists(String path) => File(path).existsSync();

  @override
  bool directoryExists(String path) => Directory(path).existsSync();

  @override
  String homeDirectory() {
    final home =
        Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home != null && home.isNotEmpty) return home;
    return Directory.current.path;
  }

  @override
  String? readFile(String path) {
    final f = File(path);
    return f.existsSync() ? f.readAsStringSync() : null;
  }
}

/// Command that verifies all prerequisites and host deployment.
class DoctorCommand implements Query<DoctorInput, DoctorOutput> {
  @override
  final DoctorInput input;

  final ProcessRunner _runProcess;
  final FileSystemOps _fileSystem;
  final Assets? _assets;
  final List<HostAdapter> _activeAdapters;
  final Future<VersionCheckResult> Function({required String currentVersion})?
      _versionChecker;

  /// Current Inquiry version (injected for testability).
  final String inquiryVersion;

  DoctorCommand(
    this.input, {
    ProcessRunner? runProcess,
    String? inquiryVersionOverride,
    FileSystemOps? fileSystemOps,
    Assets? assets,
    List<HostAdapter>? activeAdapters,
    Future<VersionCheckResult> Function({required String currentVersion})?
        versionChecker,
  }) : _runProcess = runProcess ?? Process.run,
       _fileSystem = fileSystemOps ?? RealFileSystemOps(),
       _assets = assets,
       _activeAdapters = activeAdapters ?? deployAdapters,
       _versionChecker = versionChecker,
       inquiryVersion = inquiryVersionOverride ?? version_lib.inquiryVersion;

  @override
  String? validate() => null;

  @override
  Future<DoctorOutput> execute() async {
    final checks = <DoctorCheck>[];
    var prereqPassed = true;

    // Check 1: APE version (always passes, internal)
    checks.add(DoctorCheck(name: 'inquiry', passed: true, version: inquiryVersion));

    // Check 2: git --version
    final gitCheck = await _checkCommand(
      name: 'git',
      executable: 'git',
      arguments: ['--version'],
      versionExtractor: _extractGitVersion,
    );
    checks.add(gitCheck);
    if (!gitCheck.passed) {
      prereqPassed = false;
      return DoctorOutput(checks: checks, passed: false);
    }

    // Check 3: gh --version
    final ghCheck = await _checkCommand(
      name: 'gh',
      executable: 'gh',
      arguments: ['--version'],
      versionExtractor: _extractGhVersion,
    );
    checks.add(ghCheck);
    if (!ghCheck.passed) {
      prereqPassed = false;
      return DoctorOutput(checks: checks, passed: false);
    }

    // Check 4: gh auth status
    final authCheck = await _checkCommand(
      name: 'gh auth',
      executable: 'gh',
      arguments: ['auth', 'status'],
      versionExtractor: (_) => null,
    );
    checks.add(authCheck);
    if (!authCheck.passed) {
      prereqPassed = false;
    }

    // Check 5: .inquiry/ directory (init)
    final initExists = _fileSystem.directoryExists('.inquiry');
    if (!initExists) {
      checks.add(
        DoctorCheck(
          name: 'inquiry init',
          passed: false,
          error: 'not initialized',
          remediation: "Run 'inquiry init' to initialize",
        ),
      );
      prereqPassed = false;
    }

    // Check 6: Internal assets integrity
    final assetCheck = _checkInternalAssets();
    if (assetCheck != null) {
      checks.add(assetCheck);
      if (!assetCheck.passed) {
        if (input.fix) {
          final fixResult = await _fixAssets();
          checks.add(fixResult);
          if (fixResult.passed) {
            // Re-check after fix
            final recheck = _checkInternalAssets();
            if (recheck == null || recheck.passed) {
              // Remove the failed check, it's been fixed
              checks.remove(assetCheck);
            } else {
              prereqPassed = false;
            }
          } else {
            prereqPassed = false;
          }
        } else {
          prereqPassed = false;
        }
      }
    }

    // Check 7: Version check (non-blocking)
    final versionCheck = await _checkVersion();
    if (versionCheck != null) {
      checks.add(versionCheck);
    }

    // Host checks
    final hostChecks = <HostCheck>[];
    for (final adapter in _activeAdapters) {
      hostChecks.add(_verifyHost(adapter));
    }

    // At least one host must be active (deployed); inactive hosts never fail.
    final anyActive = hostChecks.any((hc) => hc.active);
    final hostsPassed = anyActive && hostChecks.every((hc) => hc.passed);

    // OpenCode + Ollama context check (only when OpenCode is the active host):
    // a too-small num_ctx silently truncates the firmware and breaks the harness.
    var ctxPassed = true;
    final opencodeActive =
        hostChecks.any((hc) => hc.hostName == 'opencode' && hc.active);
    if (opencodeActive) {
      final ctxCheck = await _checkOllamaContext();
      if (ctxCheck != null) {
        checks.add(ctxCheck);
        if (!ctxCheck.passed) ctxPassed = false;
      }
    }

    return DoctorOutput(
      checks: checks,
      hostChecks: hostChecks,
      passed: prereqPassed && hostsPassed && ctxPassed,
    );
  }

  /// Verifies every Ollama model configured for OpenCode has an effective
  /// `num_ctx >= kInquiryMinNumCtx`. Returns a failing check if any is too
  /// small, or null when there is nothing to verify (no config / no Ollama
  /// provider / Ollama not installed).
  Future<DoctorCheck?> _checkOllamaContext() async {
    final cfgPath = p.join(
      _fileSystem.homeDirectory(),
      '.config',
      'opencode',
      'opencode.jsonc',
    );
    final raw = _fileSystem.readFile(cfgPath);
    if (raw == null) return null;

    final models = ollamaModelsFromConfig(raw);
    if (models.isEmpty) return null;

    final tooSmall = <String>[];
    for (final model in models) {
      final ctx = await effectiveNumCtx(_runProcess, model);
      if (ctx == null) continue; // can't determine (Ollama absent) — skip
      if (ctx < kInquiryMinNumCtx) tooSmall.add('$model (num_ctx=$ctx)');
    }
    if (tooSmall.isEmpty) return null;

    return DoctorCheck(
      name: 'opencode/ollama context',
      passed: false,
      error: 'num_ctx < $kInquiryMinNumCtx for: ${tooSmall.join(', ')}',
      remediation:
          "Inquiry's prompt needs ~8K tokens; at 4096 it is truncated and the "
          "harness fails silently. Bake a variant — Modelfile 'FROM <model>\\n"
          "PARAMETER num_ctx 16384' then 'ollama create <model>-16k -f Modelfile' "
          "(32768 recommended) — and point opencode.jsonc at it. "
          "Or run 'iq host get --host opencode --configure-ollama --apply' to configure it.",
    );
  }

  /// The skills a deployed host is expected to carry — exactly what the
  /// deployer installs from the asset tree (see deployer.dart `_deploySkills`).
  ///
  /// The lifecycle skills are deliberately absent: they moved to MACSS, which
  /// installs them with `macss skill deploy`. Expecting them here would report
  /// every host as unhealthy for a deployment inquiry no longer performs.
  List<String> _getExpectedSkills() {
    final assets = _assets;
    if (assets == null) return [];
    try {
      return assets.listDirectory('skills');
    } catch (_) {
      return [];
    }
  }

  /// Verifies a single host adapter's deployment.
  HostCheck _verifyHost(HostAdapter adapter) {
    final homeDir = _fileSystem.homeDirectory();
    final expectedSkills = _getExpectedSkills();
    final installed = _fileSystem.directoryExists(adapter.baseDirectory(homeDir));

    // Agent + skills are installed GLOBALLY per host by `iq host get` (#280).
    final agentExists = _fileSystem.fileExists(
      p.join(adapter.agentDirectory(homeDir), 'inquiry.md'),
    );

    // Check skills — adapter-scoped
    final missingSkills = <String>[];
    for (final skill in expectedSkills) {
      final skillPath = p.join(
        adapter.skillsDirectory(homeDir),
        skill,
        'SKILL.md',
      );
      if (!_fileSystem.fileExists(skillPath)) {
        missingSkills.add(skill);
      }
    }

    // Active = this host's skills are deployed. Under the exclusive deploy
    // model exactly one host is active; with no expected skills (assets
    // unavailable) fall back to agent presence.
    final active = expectedSkills.isEmpty
        ? agentExists
        : missingSkills.length < expectedSkills.length;

    return HostCheck(
      hostName: adapter.name,
      agentExists: agentExists,
      missingSkills: missingSkills,
      totalSkills: expectedSkills.length,
      active: active,
      installed: installed,
    );
  }

  /// Checks that all expected internal assets exist on disk.
  ///
  /// Returns null if no [_assets] is available (cannot verify).
  DoctorCheck? _checkInternalAssets() {
    if (_assets == null) return null;

    final missing = <String>[];

    // FSM state instruction files
    const stateFiles = ['idle', 'analyze', 'plan', 'execute', 'end', 'evolution'];
    for (final state in stateFiles) {
      final path = _assets.path('fsm/states/$state.yaml');
      if (!File(path).existsSync()) {
        missing.add('fsm/states/$state.yaml');
      }
    }

    // APE definition files
    const apeFiles = ['socrates', 'dewey', 'descartes', 'ada', 'darwin'];
    for (final ape in apeFiles) {
      final path = _assets.path('apes/$ape.yaml');
      if (!File(path).existsSync()) {
        missing.add('apes/$ape.yaml');
      }
    }

    // Transition contract
    final contractPath = _assets.path('fsm/transition_contract.yaml');
    if (!File(contractPath).existsSync()) {
      missing.add('fsm/transition_contract.yaml');
    }

    // Skills
    try {
      final skills = _assets.listDirectory('skills');
      for (final skill in skills) {
        final path = _assets.path('skills/$skill/SKILL.md');
        if (!File(path).existsSync()) {
          missing.add('skills/$skill/SKILL.md');
        }
      }
    } catch (_) {
      missing.add('skills/ (directory missing)');
    }

    if (missing.isEmpty) {
      return DoctorCheck(name: 'assets', passed: true);
    }

    return DoctorCheck(
      name: 'assets',
      passed: false,
      error: '${missing.length} missing: ${missing.join(', ')}',
      remediation: "Run 'iq doctor --fix' to restore missing assets",
    );
  }

  /// Downloads and restores missing assets from the current version's release.
  Future<DoctorCheck> _fixAssets() async {
    if (_assets == null) {
      return DoctorCheck(
        name: 'fix',
        passed: false,
        error: 'Cannot determine asset location',
      );
    }

    try {
      stderr.writeln('Downloading assets for v$inquiryVersion...');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);

      final assetName = Platform.isWindows
          ? 'inquiry-windows-x64.zip'
          : 'inquiry-linux-x64.tar.gz';

      final downloadUrl = Uri.parse(
        'https://github.com/ccisnedev/inquiry/releases/download/v$inquiryVersion/$assetName',
      );

      final request = await client.getUrl(downloadUrl);
      request.headers.set('User-Agent', 'inquiry-cli/$inquiryVersion');
      request.followRedirects = true;
      final response = await request.close();

      if (response.statusCode != 200) {
        await response.drain<void>();
        client.close();
        return DoctorCheck(
          name: 'fix',
          passed: false,
          error: 'Failed to download assets (HTTP ${response.statusCode})',
        );
      }

      // Save to temp and extract
      final tempDir = Directory.systemTemp.createTempSync('iq_fix_');
      final archiveFile = File(p.join(tempDir.path, assetName));
      final sink = archiveFile.openWrite();
      await response.pipe(sink);
      client.close();

      // Extract to the asset root's parent (which is the install dir)
      final installDir = p.dirname(_assets.path(''));
      // Remove trailing 'assets' from path to get install root
      final installRoot = installDir.endsWith('assets${p.separator}') ||
              installDir.endsWith('assets')
          ? p.dirname(installDir)
          : p.dirname(p.dirname(installDir));

      stderr.writeln('Extracting to: $installRoot');

      if (Platform.isWindows) {
        final result = await Process.run('powershell', [
          '-NoProfile',
          '-Command',
          'Expand-Archive',
          '-Path', archiveFile.path,
          '-DestinationPath', installRoot,
          '-Force',
        ]);
        if (result.exitCode != 0) {
          tempDir.deleteSync(recursive: true);
          return DoctorCheck(
            name: 'fix',
            passed: false,
            error: 'Extraction failed: ${result.stderr}',
          );
        }
      } else {
        final result = await Process.run('tar', [
          '-xzf', archiveFile.path,
          '-C', installRoot,
        ]);
        if (result.exitCode != 0) {
          tempDir.deleteSync(recursive: true);
          return DoctorCheck(
            name: 'fix',
            passed: false,
            error: 'Extraction failed: ${result.stderr}',
          );
        }
      }

      tempDir.deleteSync(recursive: true);
      stderr.writeln('✓ Assets restored successfully');
      return DoctorCheck(name: 'fix', passed: true, version: 'restored');
    } on Exception catch (e) {
      return DoctorCheck(
        name: 'fix',
        passed: false,
        error: 'Fix failed: $e',
      );
    }
  }

  /// Checks if a newer version is available. Non-blocking.
  ///
  /// Returns a passing check with update info, or null on failure/timeout.
  Future<DoctorCheck?> _checkVersion() async {
    try {
      final checker = _versionChecker ??
          ({required String currentVersion}) =>
              checkLatestVersion(currentVersion: currentVersion);
      final result = await checker(currentVersion: inquiryVersion);
      if (result.updateAvailable && result.latestVersion != null) {
        return DoctorCheck(
          name: 'update',
          passed: true,
          version: '${result.latestVersion} available',
          remediation: "Run 'iq upgrade' to update",
        );
      }
      return null; // No update, no check to show
    } catch (_) {
      return null; // Silent on failure
    }
  }

  /// Runs a command and returns a [DoctorCheck] with the result.
  Future<DoctorCheck> _checkCommand({
    required String name,
    required String executable,
    required List<String> arguments,
    required String? Function(String stdout) versionExtractor,
  }) async {
    try {
      final result = await _runProcess(executable, arguments);
      if (result.exitCode == 0) {
        final version = versionExtractor(result.stdout.toString());
        return DoctorCheck(name: name, passed: true, version: version);
      } else {
        return DoctorCheck(
          name: name,
          passed: false,
          error: result.stderr.toString().trim(),
        );
      }
    } catch (e) {
      return DoctorCheck(name: name, passed: false, error: e.toString());
    }
  }

  /// Extracts version from "git version X.Y.Z".
  String? _extractGitVersion(String stdout) {
    final match = RegExp(r'git version (\d+\.\d+\.\d+)').firstMatch(stdout);
    return match?.group(1);
  }

  /// Extracts version from "gh version X.Y.Z (...)".
  String? _extractGhVersion(String stdout) {
    final match = RegExp(r'gh version (\d+\.\d+\.\d+)').firstMatch(stdout);
    return match?.group(1);
  }
}
