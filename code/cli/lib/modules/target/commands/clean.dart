/// `ape target clean` — removes deployed APE files from all targets.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../targets/deployer.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class TargetCleanInput extends Input {
  TargetCleanInput();

  factory TargetCleanInput.fromCliRequest(CliRequest req) => TargetCleanInput();

  @override
  Map<String, dynamic> toJson() => {};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class TargetCleanOutput extends Output {
  final String message;

  TargetCleanOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class TargetCleanCommand
    implements Command<TargetCleanInput, TargetCleanOutput> {
  @override
  final TargetCleanInput input;
  final TargetDeployer deployer;
  final String _workingDirectory;

  TargetCleanCommand(
    this.input, {
    required this.deployer,
    String? workingDirectory,
  }) : _workingDirectory = workingDirectory ?? Directory.current.path;

  @override
  String? validate() => null;

  @override
  Future<TargetCleanOutput> execute() async {
    deployer.clean();
    _cleanRepoScopedAgent();
    return TargetCleanOutput(message: 'Inquiry cleaned from all targets');
  }

  void _cleanRepoScopedAgent() {
    final agentFile = File(
      p.join(_workingDirectory, '.github', 'agents', 'inquiry.agent.md'),
    );
    if (agentFile.existsSync()) agentFile.deleteSync();
  }
}
