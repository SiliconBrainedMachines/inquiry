import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../hosts/deployer.dart';
import 'commands/clean.dart';
import 'commands/get.dart';

void buildHostModule(
  ModuleBuilder m, {
  required HostDeployer deployer,
  required HostDeployer cleaner,
}) {
  m.command<HostGetInput, HostGetOutput>(
    'get',
    (req) => HostGetCommand(
      HostGetInput.fromCliRequest(req),
      deployer: deployer,
    ),
    description: 'Deploy Inquiry skills to the specified host (default: copilot)',
  );

  m.command<HostCleanInput, HostCleanOutput>(
    'clean',
    (req) => HostCleanCommand(
      HostCleanInput.fromCliRequest(req),
      deployer: cleaner,
    ),
    description: 'Remove deployed Inquiry files from all hosts',
  );
}
