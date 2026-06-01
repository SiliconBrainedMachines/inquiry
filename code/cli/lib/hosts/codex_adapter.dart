import 'package:path/path.dart' as p;

import 'host_adapter.dart';

class CodexAdapter extends HostAdapter {
  @override
  String get name => 'codex';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.codex');

  @override
  String skillsDirectory(String homeDir) => p.join(homeDir, '.codex', 'skills');

  @override
  String agentDirectory(String homeDir) => p.join(homeDir, '.codex', 'agents');
}
