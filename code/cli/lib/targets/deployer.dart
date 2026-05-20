import 'dart:io';

import 'package:path/path.dart' as p;

import '../assets.dart';
import 'target_adapter.dart';

/// Orchestrates deploying skills to target tool directories.
class TargetDeployer {
  final Assets assets;
  final List<TargetAdapter> adapters;
  final String homeDir;

  TargetDeployer({
    required this.assets,
    required this.adapters,
    required this.homeDir,
  });

  /// Deploys skills exclusively to the named adapter, cleaning all adapters first.
  ///
  /// Only one target is active at a time — all other adapter directories are
  /// cleaned before deploying to the selected one.
  ///
  /// Throws [ArgumentError] if [targetName] is not in [adapters].
  void deployExclusive(String targetName) {
    final validNames = adapters.map((a) => a.name).toSet();
    if (!validNames.contains(targetName)) {
      throw ArgumentError(
        'Unknown target: "$targetName". Valid targets: ${validNames.join(", ")}',
      );
    }
    clean();
    final selected = adapters.firstWhere((a) => a.name == targetName);
    _deploySkills(selected);
  }

  /// Removes all deployed files from **all** adapter directories.
  void clean() {
    for (final adapter in adapters) {
      _deleteDirectory(adapter.skillsDirectory(homeDir));
      _deleteDirectory(adapter.agentDirectory(homeDir));
    }
  }

  void _deploySkills(TargetAdapter adapter) {
    final skillNames = assets.listDirectory('skills');
    final targetSkillsDir = adapter.skillsDirectory(homeDir);

    for (final skillName in skillNames) {
      final content = assets.loadString('skills/$skillName/SKILL.md');
      final targetFile = File(p.join(targetSkillsDir, skillName, 'SKILL.md'));
      targetFile.parent.createSync(recursive: true);
      targetFile.writeAsStringSync(content);
    }
  }

  void _deleteDirectory(String path) {
    final dir = Directory(path);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}
