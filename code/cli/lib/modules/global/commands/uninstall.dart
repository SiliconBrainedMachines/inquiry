/// `inquiry uninstall` — removes Inquiry CLI from the system.
///
/// 1. Cleans all deployed hosts (agents + skills).
/// 2. Removes inquiry\bin\ from the user PATH.
/// 3. Spawns a background process to delete the install directory.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../hosts/deployer.dart';
import '../../../hosts/platform_ops.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class UninstallInput extends Input {
  final String installDir;

  UninstallInput({required this.installDir});

  factory UninstallInput.fromCliRequest(CliRequest req) {
    final installDir = p.dirname(p.dirname(Platform.resolvedExecutable));
    return UninstallInput(installDir: installDir);
  }

  @override
  Map<String, dynamic> toJson() => {'installDir': installDir};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class UninstallOutput extends Output {
  final String message;

  UninstallOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class UninstallCommand implements Command<UninstallInput, UninstallOutput> {
  @override
  final UninstallInput input;
  final HostDeployer deployer;
  final PlatformOps platformOps;
  final String _workingDirectory;

  UninstallCommand(
    this.input, {
    required this.deployer,
    PlatformOps? platformOps,
    String? workingDirectory,
  }) : platformOps = platformOps ?? PlatformOps.current(),
       _workingDirectory = workingDirectory ?? Directory.current.path;

  @override
  String? validate() => null;

  @override
  Future<UninstallOutput> execute() async {
    // 1. Clean all hosts (adapter paths + old global agent paths)
    deployer.clean();

    // 2. Clean repo-scoped agent
    _cleanRepoScopedAgent();

    // 3. Remove ape\bin\ from user PATH (via PlatformOps)
    _removeFromPath(p.join(input.installDir, 'bin'));

    // 4. Spawn background process to delete install directory
    await platformOps.scheduleDeletion(input.installDir);

    return UninstallOutput(
      message: 'Inquiry uninstalled. Restart your terminal to apply PATH changes.',
    );
  }

  void _cleanRepoScopedAgent() {
    final agentFile = File(
      p.join(_workingDirectory, '.github', 'agents', 'inquiry.agent.md'),
    );
    if (agentFile.existsSync()) agentFile.deleteSync();
  }

  void _removeFromPath(String binDir) {
    final userPath = platformOps.getEnvVariable('PATH') ?? '';
    final parts = userPath
        .split(Platform.isWindows ? ';' : ':')
        .where((p) => p.isNotEmpty)
        .where((p) => !_pathEquals(p, binDir))
        .toList();
    final newPath = parts.join(Platform.isWindows ? ';' : ':');

    if (newPath != userPath) {
      platformOps.setEnvVariable('PATH', newPath);
    }
  }

  bool _pathEquals(String a, String b) =>
      p.normalize(a).toLowerCase() == p.normalize(b).toLowerCase();
}
