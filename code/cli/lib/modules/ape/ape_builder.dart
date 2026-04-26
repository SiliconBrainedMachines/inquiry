import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../assets.dart';
import 'commands/prompt.dart';

void buildApeModule(ModuleBuilder m, {Assets? assets}) {
  m.command<ApePromptInput, ApePromptOutput>(
    'prompt',
    (req) => ApePromptCommand(ApePromptInput.fromCliRequest(req), assets: assets),
    description: 'Assemble a sub-agent prompt from YAML + current FSM state',
  );
}
