import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import '../../assets.dart';
import 'commands/state.dart';
import 'commands/transition.dart';

void buildFsmModule(ModuleBuilder m, {Assets? assets}) {
  m.command<FsmStateInput, FsmStateOutput>(
    'state',
    (req) => FsmStateCommand(FsmStateInput.fromCliRequest(req), assets: assets),
    description: 'Show current FSM state, valid transitions, and active APEs',
    params: FsmStateInput.params,
  );

  m.command<StateTransitionInput, StateTransitionOutput>(
    'transition',
    (req) => StateTransitionCommand(StateTransitionInput.fromCliRequest(req), assets: assets),
    description:
        'Run a deterministic FSM transition',
    params: StateTransitionInput.params,
  );
}
