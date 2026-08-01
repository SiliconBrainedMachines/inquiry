/// `iq host get [--host <host>] [--configure-ollama]` — installs the Inquiry
/// agent + skills GLOBALLY for a host.
///
/// Additive (#280): other hosts are left untouched, so one machine can serve
/// OpenCode + Claude at once. Global host dirs are isolated → no duplication.
/// `iq init` (repo-scoped) only sets up the cleanroom workspace.
///
/// With no `--host`, every deploy target **detected on this machine** is
/// installed. With `--host`, that one is installed whether or not it looks
/// present, so a fresh setup can be primed before the tool first runs.
///
/// This used to default to `opencode` and assume it (#300), which deployed to a
/// host the user might not have and dragged the OpenCode/Ollama configurator
/// into every `iq upgrade`.
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../../hosts/deployer.dart';
import '../../../hosts/opencode_ollama_configurator.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class HostGetInput extends Input {
  /// `null` → every detected host.
  final String? host;

  /// Bake `num_ctx` variants of the configured Ollama models (OpenCode only).
  ///
  /// Opt-in: it shells out to `ollama create`, which is slow and blocks when the
  /// daemon is not running. That is an optimization, not part of installing a
  /// CLI.
  final bool configureOllama;

  HostGetInput({this.host, this.configureOllama = false});

  factory HostGetInput.fromCliRequest(CliRequest req) => HostGetInput(
        host: req.flagString('host'),
        configureOllama: req.flagBool('configure-ollama'),
      );

  static final List<CliParam> params = [
    CliParam.string(
      'host',
      allowed: ['opencode', 'claude'],
      description:
          'AI coding host to install into; defaults to every one detected',
    ),
    CliParam.boolean(
      'configure-ollama',
      description:
          'OpenCode only: bake num_ctx variants of the configured Ollama models',
    ),
  ];

  @override
  List<CliParam> get schemaFields => params;

  @override
  Map<String, dynamic> toJson() =>
      {'host': host, 'configureOllama': configureOllama};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class HostGetOutput extends Output {
  final String message;

  /// The hosts actually installed into. Empty is a valid outcome: a machine may
  /// carry the CLI and no AI assistant at all.
  final List<String> hosts;

  HostGetOutput({required this.message, this.hosts = const []});

  @override
  Map<String, dynamic> toJson() => {'message': message, 'hosts': hosts};

  /// Deploying to nothing is not a failure — see [hosts].
  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() => message;
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
    if (input.host == null) return null;
    final validNames = deployer.adapters.map((a) => a.name).toSet();
    if (!validNames.contains(input.host)) {
      return 'Unknown host: "${input.host}". '
          'Valid hosts: ${validNames.join(", ")}';
    }
    return null;
  }

  @override
  Future<HostGetOutput> execute() async {
    final targets = input.host != null
        ? [input.host!]
        : deployer.detectedHosts.map((a) => a.name).toList();

    if (targets.isEmpty) {
      return HostGetOutput(
        message: 'No AI coding host found on this machine — nothing deployed.\n'
            'Supported: ${deployer.adapters.map((a) => a.name).join(', ')}.\n'
            'Pass --host <host> to install into one anyway.',
      );
    }

    final lines = <String>[];
    for (final host in targets) {
      final retired = deployer.deploy(host);
      lines.add('Inquiry agent + skills deployed (global) to host $host');
      for (final skill in retired) {
        lines.add('  removed  $skill (no longer shipped)');
      }

      if (host == 'opencode' && input.configureOllama && configurator != null) {
        lines.addAll(await configurator!.configure());
      }
    }

    return HostGetOutput(message: lines.join('\n'), hosts: targets);
  }
}
