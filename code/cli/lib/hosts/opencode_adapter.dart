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

  // OpenCode discovers global agents in `~/.config/opencode/agent/` (singular).
  // A plural `agents/` directory is ignored, so `opencode agent list` never sees
  // the deployed agent and `opencode run --agent inquiry` silently falls back to
  // the default agent (#247).
  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.config', 'opencode', 'agent');

  @override
  bool get deploysAgent => true;
}
