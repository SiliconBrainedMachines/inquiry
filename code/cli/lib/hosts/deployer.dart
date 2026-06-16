import 'dart:io';

import 'package:path/path.dart' as p;

import '../assets.dart';
import 'host_adapter.dart';

/// Orchestrates deploying skills to host tool directories.
class HostDeployer {
  final Assets assets;
  final List<HostAdapter> adapters;
  final String homeDir;

  HostDeployer({
    required this.assets,
    required this.adapters,
    required this.homeDir,
  });

  /// Deploys skills exclusively to the named adapter, cleaning all adapters first.
  ///
  /// Only one host is active at a time — all other adapter directories are
  /// cleaned before deploying to the selected one.
  ///
  /// Throws [ArgumentError] if [hostName] is not in [adapters].
  void deployExclusive(String hostName) {
    final validNames = adapters.map((a) => a.name).toSet();
    if (!validNames.contains(hostName)) {
      throw ArgumentError(
        'Unknown host: "$hostName". Valid hosts: ${validNames.join(", ")}',
      );
    }
    clean();
    final selected = adapters.firstWhere((a) => a.name == hostName);
    _deploySkills(selected);
    if (selected.deploysAgent) _deployAgent(selected);
  }

  /// Removes all deployed files from **all** adapter directories.
  void clean() {
    for (final adapter in adapters) {
      _deleteDirectory(adapter.skillsDirectory(homeDir));
      _deleteDirectory(adapter.agentDirectory(homeDir));
    }
  }

  void _deploySkills(HostAdapter adapter) {
    final skillNames = assets.listDirectory('skills');
    final hostSkillsDir = adapter.skillsDirectory(homeDir);

    for (final skillName in skillNames) {
      final content = assets.loadString('skills/$skillName/SKILL.md');
      final hostFile = File(p.join(hostSkillsDir, skillName, 'SKILL.md'));
      hostFile.parent.createSync(recursive: true);
      hostFile.writeAsStringSync(content);
    }
  }

  /// Deploys the inquiry agent (OpenCode-tailored) to the host's agent dir as `inquiry.md`.
  void _deployAgent(HostAdapter adapter) {
    final content = assets.loadString('agents/inquiry.opencode.md');
    final hostFile = File(p.join(adapter.agentDirectory(homeDir), 'inquiry.md'));
    hostFile.parent.createSync(recursive: true);
    hostFile.writeAsStringSync(content);
  }

  void _deleteDirectory(String path) {
    final dir = Directory(path);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}
