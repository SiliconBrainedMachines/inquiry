import 'package:path/path.dart' as p;

import 'host_adapter.dart';

/// Copilot is no longer an active deploy target (#280 — hosts are opencode +
/// claude). This adapter is retained only so `iq host clean` removes Copilot
/// files from older versions.
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
