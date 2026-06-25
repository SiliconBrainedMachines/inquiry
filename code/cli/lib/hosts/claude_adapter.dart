import 'package:path/path.dart' as p;

import 'host_adapter.dart';

class ClaudeAdapter extends HostAdapter {
  @override
  String get name => 'claude';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.claude');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.claude', 'skills');

  // Claude Code discovers global agents in `~/.claude/agents/`; run as the
  // primary driver with `claude --agent inquiry`. `iq host get --host claude`
  // installs the agent here (global, #280). Dispatch tool is `Agent`.
  @override
  String agentDirectory(String homeDir) => p.join(homeDir, '.claude', 'agents');

  @override
  bool get deploysAgent => true;

  @override
  Map<String, String> get agentSubstitutions => const {
        'INIT_HINT': 'Run `iq host get --host claude`',
        'DISPATCH_TOOL': 'Agent',
      };
}
