import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../hosts/deployer.dart';
import 'commands/clean.dart';

/// `iq host` now exposes only `clean` (migration: remove stale global deploys
/// from older versions). Agent + skills are deployed repo-locally by `iq init`;
/// the old global `iq host get` was removed in 0.12.0 (#278).
void buildHostModule(
  ModuleBuilder m, {
  required HostDeployer cleaner,
}) {
  m.command<HostCleanInput, HostCleanOutput>(
    'clean',
    (req) => HostCleanCommand(
      HostCleanInput.fromCliRequest(req),
      deployer: cleaner,
    ),
    description:
        'Remove all globally-deployed Inquiry files (migration from pre-0.12.0)',
  );
}
