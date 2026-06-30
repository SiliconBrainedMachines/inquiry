import 'dart:io';

import 'package:path/path.dart' as p;

import '../assets.dart';
import 'agent_builder.dart';
import 'host_adapter.dart';
import 'skill_builder.dart';

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

  /// Deploys the inquiry agent + skills GLOBALLY for [hostName], **additively** —
  /// other hosts are left untouched, so one machine can serve multiple hosts
  /// (e.g. OpenCode + Claude) at once. Global host dirs are isolated, so there
  /// is no cross-host duplication (#280).
  ///
  /// Throws [ArgumentError] if [hostName] is not in [adapters].
  void deploy(String hostName) {
    final validNames = adapters.map((a) => a.name).toSet();
    if (!validNames.contains(hostName)) {
      throw ArgumentError(
        'Unknown host: "$hostName". Valid hosts: ${validNames.join(", ")}',
      );
    }
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

    // Generated per-phase skills (iq-analyze, ...) — assembled from the FSM/APE
    // contracts at deploy time so they cannot drift from the gates (#282).
    // Best-effort per phase: a phase whose contract assets are absent is
    // skipped, so deploying from an incomplete asset tree never aborts.
    final skillBuilder = SkillBuilder(assets);
    for (final name in skillBuilder.phaseSkillNames) {
      final phase = name.substring('iq-'.length);
      final String content;
      try {
        content = skillBuilder.build(phase);
      } catch (_) {
        continue;
      }
      final hostFile = File(p.join(hostSkillsDir, name, 'SKILL.md'));
      hostFile.parent.createSync(recursive: true);
      hostFile.writeAsStringSync(content);
    }
  }

  /// Deploys the inquiry agent to the host's agent dir as `inquiry.md`,
  /// assembled from the shared body + the host's frontmatter.
  void _deployAgent(HostAdapter adapter) {
    final content = AgentBuilder(assets).build(adapter);
    final hostFile = File(p.join(adapter.agentDirectory(homeDir), 'inquiry.md'));
    hostFile.parent.createSync(recursive: true);
    hostFile.writeAsStringSync(content);
  }

  void _deleteDirectory(String path) {
    final dir = Directory(path);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  }
}
