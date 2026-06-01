import 'package:path/path.dart' as p;

import 'host_adapter.dart';

class GeminiAdapter extends HostAdapter {
  @override
  String get name => 'gemini';

  @override
  String baseDirectory(String homeDir) => p.join(homeDir, '.gemini');

  @override
  String skillsDirectory(String homeDir) =>
      p.join(homeDir, '.gemini', 'skills');

  @override
  String agentDirectory(String homeDir) => p.join(homeDir, '.gemini', 'agents');
}
