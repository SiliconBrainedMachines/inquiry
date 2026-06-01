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
}
