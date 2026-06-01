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

  @override
  String agentDirectory(String homeDir) =>
      p.join(homeDir, '.config', 'opencode', 'agents');
}
