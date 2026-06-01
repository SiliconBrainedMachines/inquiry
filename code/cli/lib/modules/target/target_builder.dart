import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../hosts/deployer.dart';
import 'commands/clean.dart';
import 'commands/get.dart';

void buildTargetModule(
  ModuleBuilder m, {
  required HostDeployer deployer,
  required HostDeployer cleaner,
}) {
  m.command<TargetGetInput, TargetGetOutput>(
    'get',
    (req) => TargetGetCommand(
      TargetGetInput.fromCliRequest(req),
      deployer: deployer,
    ),
    description: 'Deploy Inquiry skills to the specified host (default: copilot)',
  );

  m.command<TargetCleanInput, TargetCleanOutput>(
    'clean',
    (req) => TargetCleanCommand(
      TargetCleanInput.fromCliRequest(req),
      deployer: cleaner,
    ),
    description: 'Remove deployed Inquiry files from all hosts',
  );
}
