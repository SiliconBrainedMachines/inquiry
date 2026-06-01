/// `iq host clean` — removes deployed Inquiry files from all hosts.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../src/git_utils.dart';
import '../../../hosts/deployer.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class HostCleanInput extends Input {
  HostCleanInput();

  factory HostCleanInput.fromCliRequest(CliRequest req) => HostCleanInput();

  @override
  Map<String, dynamic> toJson() => {};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class HostCleanOutput extends Output {
  final String message;

  HostCleanOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class HostCleanCommand
    implements Command<HostCleanInput, HostCleanOutput> {
  @override
  final HostCleanInput input;
  final HostDeployer deployer;
  final String _workingDirectory;

  HostCleanCommand(
    this.input, {
    required this.deployer,
    String? workingDirectory,
  }) : _workingDirectory = workingDirectory ?? Directory.current.path;

  @override
  String? validate() => null;

  @override
  Future<HostCleanOutput> execute() async {
    deployer.clean();
    _cleanRepoScopedAgent();
    return HostCleanOutput(message: 'Inquiry cleaned from all hosts');
  }

  void _cleanRepoScopedAgent() {
    final projectRoot = getProjectRoot(_workingDirectory) ?? _workingDirectory;
    final agentFile = File(
      p.join(projectRoot, '.github', 'agents', 'inquiry.agent.md'),
    );
    if (agentFile.existsSync()) agentFile.deleteSync();
  }
}
