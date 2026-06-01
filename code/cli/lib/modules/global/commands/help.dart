/// `inquiry help` — prints the global CLI help summary.
library;

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';

const String inquiryHelpText =
    'Usage:\n'
    '  inquiry                 Display Inquiry status and FSM diagram\n'
    '  inquiry help            Show this help\n'
    '  inquiry --help          Show this help\n'
    '  inquiry -h             Show this help\n'
    '  inquiry <command> ...\n'
    '\n'
    'Root commands:\n'
    '  help       Show available commands\n'
    '  init       Initialize a new .inquiry/ workspace\n'
    '  version    Print the current CLI version\n'
    '  doctor     Verify prerequisites (inquiry, git, gh, gh auth, gh copilot)\n'
    '  upgrade    Download and install the latest Inquiry release\n'
    '  uninstall  Remove Inquiry CLI from the system\n'
    '\n'
    'Modules:\n'
    '  host get           Deploy Inquiry skills to the specified host (default: copilot)\n'
    '  host clean         Remove deployed Inquiry files from all hosts\n'
    '  target get         Legacy alias for host get\n'
    '  target clean       Legacy alias for host clean\n'
    '  fsm state          Show current FSM state, valid transitions, and active APEs\n'
    '  fsm transition     Run deterministic FSM transition by --event (optional --state)\n'
    '  ape prompt         Assemble a sub-agent prompt from YAML + current FSM state\n'
    '  ape state          Show current APE sub-state and valid internal transitions\n'
    '  ape transition     Execute APE internal transition by --event\n';

class HelpInput extends Input {
  HelpInput();

  factory HelpInput.fromCliRequest(CliRequest req) => HelpInput();

  @override
  Map<String, dynamic> toJson() => {};
}

class HelpOutput extends Output {
  final String text;

  HelpOutput({required this.text});

  @override
  Map<String, dynamic> toJson() => {'help': text};

  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() => text;
}

class HelpCommand implements Command<HelpInput, HelpOutput> {
  @override
  final HelpInput input;

  HelpCommand(this.input);

  @override
  String? validate() => null;

  @override
  Future<HelpOutput> execute() async {
    return HelpOutput(text: inquiryHelpText);
  }
}