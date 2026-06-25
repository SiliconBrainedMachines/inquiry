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

  // OpenCode's global agent dir (singular `agent/`, #247). The agent is no
  // longer deployed here — it is repo-scoped via `iq init` (#272) — but `clean()`
  // still targets this path to remove any stale global agent from older versions.
  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.config', 'opencode', 'agent');

  // The agent is repo-scoped (per-project), like git init — never global (#272).
  @override
  bool get deploysAgent => false;

  // OpenCode discovers repo agents in `.opencode/agent/`.
  @override
  String get projectAgentRelPath => p.join('.opencode', 'agent', 'inquiry.md');

  // OpenCode is a headless CLI: the install hint points at `iq init`.
  // OpenCode's sub-agent dispatch tool is `task` (there is no `agent` tool).
  @override
  Map<String, String> get agentSubstitutions => const {
        'INIT_HINT': 'Run `iq init`',
        'DISPATCH_TOOL': 'task',
      };
}
