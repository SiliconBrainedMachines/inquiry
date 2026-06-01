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
}
