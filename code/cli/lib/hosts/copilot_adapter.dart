import 'package:path/path.dart' as p;

import 'host_adapter.dart';

class CopilotAdapter extends HostAdapter {
  @override
  String get name => 'copilot';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.copilot');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.copilot', 'skills');

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.copilot', 'agents');

  // Copilot discovers repo agents in `.github/agents/`.
  @override
  String get projectAgentRelPath => p.join('.github', 'agents', 'inquiry.agent.md');

  // Copilot runs inside VS Code: the install hint points at the command palette.
  // Copilot's sub-agent dispatch tool is `agent`.
  @override
  Map<String, String> get agentSubstitutions => const {
        'INIT_HINT': 'Tell the user to press `Ctrl+Shift+P` → **Inquiry: Init**',
        'DISPATCH_TOOL': 'agent',
      };
}
