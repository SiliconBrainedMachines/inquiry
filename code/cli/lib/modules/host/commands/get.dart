/// `iq host get` — deploys Inquiry skills to the specified host.
///
/// Only one host is active at a time. Cleans all adapter directories
/// before deploying to the selected host. Agent deploy is repo-scoped
/// via `iq init`, not duplicated here.
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../../hosts/deployer.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class HostGetInput extends Input {
  final String host;

  HostGetInput({this.host = 'copilot'});

  factory HostGetInput.fromCliRequest(CliRequest req) =>
      HostGetInput(
        host: req.flagString('host') ?? req.flagString('target') ?? 'copilot',
      );

  @override
  Map<String, dynamic> toJson() => {'host': host, 'target': host};
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

  HostGetCommand(this.input, {required this.deployer});

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
    deployer.deployExclusive(input.host);
    return HostGetOutput(
      message: 'Inquiry skills deployed to host ${input.host}',
    );
  }
}
