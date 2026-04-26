import 'package:modular_cli_sdk/modular_cli_sdk.dart';

import 'commands/state.dart';
import 'commands/transition.dart';

void buildFsmModule(ModuleBuilder m) {
  m.command<FsmStateInput, FsmStateOutput>(
    'state',
    (req) => FsmStateCommand(FsmStateInput.fromCliRequest(req)),
    description: 'Show current FSM state, valid transitions, and active APEs',
  );

  m.command<StateTransitionInput, StateTransitionOutput>(
    'transition',
    (req) => StateTransitionCommand(StateTransitionInput.fromCliRequest(req)),
    description:
        'Run deterministic FSM transition by --event (optional --state)',
  );
}
