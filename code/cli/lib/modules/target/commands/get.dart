/// `ape target get` — deploys Inquiry skills to the specified target.
///
/// Only one target is active at a time. Cleans all adapter directories
/// before deploying to the selected target. Agent deploy is repo-scoped
/// via `iq init`, not duplicated here.
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../../targets/deployer.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class TargetGetInput extends Input {
  final String target;

  TargetGetInput({this.target = 'copilot'});

  factory TargetGetInput.fromCliRequest(CliRequest req) =>
      TargetGetInput(target: req.flagString('target') ?? 'copilot');

  @override
  Map<String, dynamic> toJson() => {'target': target};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class TargetGetOutput extends Output {
  final String message;

  TargetGetOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;
}

// ─── Command ────────────────────────────────────────────────────────────────

class TargetGetCommand implements Command<TargetGetInput, TargetGetOutput> {
  @override
  final TargetGetInput input;
  final TargetDeployer deployer;

  TargetGetCommand(this.input, {required this.deployer});

  @override
  String? validate() {
    final validNames = deployer.adapters.map((a) => a.name).toSet();
    if (!validNames.contains(input.target)) {
      return 'Unknown target: "${input.target}". '
          'Valid targets: ${validNames.join(", ")}';
    }
    return null;
  }

  @override
  Future<TargetGetOutput> execute() async {
    deployer.deployExclusive(input.target);
    return TargetGetOutput(
      message: 'Inquiry skills deployed to ${input.target}',
    );
  }
}
