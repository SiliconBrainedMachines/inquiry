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

  @override
  String agentDirectory(String homeDir) => p.join(homeDir, '.claude', 'agents');

  // Claude Code discovers repo agents in `.claude/agents/`; run as the primary
  // driver with `claude --agent inquiry`. Its sub-agent dispatch tool is `Agent`.
  @override
  String get projectAgentRelPath => p.join('.claude', 'agents', 'inquiry.md');

  @override
  Map<String, String> get agentSubstitutions => const {
        'INIT_HINT': 'Run `iq init --host claude`',
        'DISPATCH_TOOL': 'Agent',
      };
}
