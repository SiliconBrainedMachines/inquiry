import 'package:path/path.dart' as p;

import 'target_adapter.dart';

class OpenCodeAdapter extends TargetAdapter {
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
