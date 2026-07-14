/// `iq host get` — installs the Inquiry agent + skills GLOBALLY for a host.
///
/// Additive (#280): other hosts are left untouched, so one machine can serve
/// OpenCode + Claude at once. Global host dirs are isolated → no duplication.
/// `iq init` (repo-scoped) only sets up the cleanroom workspace.
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../../hosts/deployer.dart';
import '../../../hosts/opencode_ollama_configurator.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class HostGetInput extends Input {
  final String host;

  HostGetInput({this.host = 'opencode'});

  factory HostGetInput.fromCliRequest(CliRequest req) =>
      HostGetInput(host: req.flagString('host') ?? 'opencode');

  static final List<CliParam> params = [
    CliParam.string(
      'host',
      defaultValue: 'opencode',
      allowed: ['opencode', 'claude'],
      description: 'AI coding host to install the agent + skills into',
    ),
  ];

  @override
  List<CliParam> get schemaFields => params;

  @override
  Map<String, dynamic> toJson() => {'host': host};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class HostGetOutput extends Output {
  final String message;

  HostGetOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class HostGetCommand implements Command<HostGetInput, HostGetOutput> {
  @override
  final HostGetInput input;
  final HostDeployer deployer;

  /// OpenCode-only: ensures the configured Ollama models have an adequate
  /// `num_ctx` (bakes variants + rewrites opencode.jsonc). Null disables it.
  final OpenCodeOllamaConfigurator? configurator;

  HostGetCommand(this.input, {required this.deployer, this.configurator});

  @override
  String? validate() {
    final validNames = deployer.adapters.map((a) => a.name).toSet();
    if (!validNames.contains(input.host)) {
      return 'Unknown host: "${input.host}". '
          'Valid hosts: ${validNames.join(", ")}';
    }
    return null;
  }

  @override
  Future<HostGetOutput> execute() async {
    deployer.deploy(input.host);
    final lines = ['Inquiry agent + skills deployed (global) to host ${input.host}'];
    if (input.host == 'opencode' && configurator != null) {
      lines.addAll(await configurator!.configure());
    }
    return HostGetOutput(message: lines.join('\n'));
  }
}
