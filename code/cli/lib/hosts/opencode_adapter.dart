import 'package:path/path.dart' as p;

import 'host_adapter.dart';

class OpenCodeAdapter extends HostAdapter {
  @override
  String get name => 'opencode';

  @override
  String baseDirectory(String homeDir) =>
      p.join(homeDir, '.config', 'opencode');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.config', 'opencode', 'skills');

  // OpenCode discovers global agents in `~/.config/opencode/agent/` (singular,
  // #247). `iq host get --host opencode` installs the agent here (global, #280).
  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.config', 'opencode', 'agent');

  @override
  bool get deploysAgent => true;

  // OpenCode is a headless CLI: the install hint points at `iq host get`.
  // OpenCode's sub-agent dispatch tool is `task` (there is no `agent` tool).
  @override
  Map<String, String> get agentSubstitutions => const {
        'INIT_HINT': 'Run `iq host get --host opencode`',
        'DISPATCH_TOOL': 'task',
      };
}
