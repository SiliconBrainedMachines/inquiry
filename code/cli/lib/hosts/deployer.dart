import 'dart:io';

import 'package:path/path.dart' as p;

import '../assets.dart';
import 'agent_builder.dart';
import 'host_adapter.dart';

/// The prefix Inquiry's own skills carry in a host's skills directory.
///
/// It marks what Inquiry owns and may therefore retire. Skills without it —
/// `kritik`, `legion`, `research`, and anything the user wrote — belong to
/// someone else.
const inquirySkillNamespace = 'iq-';

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
  /// Returns the names of the skills it retired, so the caller can report them.
  ///
  /// Throws [ArgumentError] if [hostName] is not in [adapters].
  List<String> deploy(String hostName) {
    final validNames = adapters.map((a) => a.name).toSet();
    if (!validNames.contains(hostName)) {
      throw ArgumentError(
        'Unknown host: "$hostName". Valid hosts: ${validNames.join(", ")}',
      );
    }
    final selected = adapters.firstWhere((a) => a.name == hostName);
    _deploySkills(selected);
    final retired = _pruneRetiredSkills(selected);
    if (selected.deploysAgent) _deployAgent(selected);
    return retired;
  }

  /// The deploy targets actually present on this machine.
  ///
  /// A host counts as installed when its own config directory exists — the same
  /// signal the host tool itself creates on first run. Deploying to a host the
  /// user does not have writes a tree nothing will ever read, and asking a
  /// third-party tool whether it is installed is what made `iq upgrade` hang
  /// (#300).
  List<HostAdapter> get detectedHosts =>
      adapters.where((a) => a.exists(homeDir)).toList(growable: false);

  /// Removes what Inquiry deployed, from every adapter, and nothing else.
  ///
  /// This used to delete each adapter's skills and agents directories outright.
  /// Across [allAdapters] that is ten directories removed in full, taking with
  /// them another tool's skills and anything the user had written beside them —
  /// while `_pruneRetiredSkills`, six lines below, was scrupulous about exactly
  /// the same question. The narrow path was right and the wide one was not.
  ///
  /// The rule is the one [inquirySkillNamespace] already states: the `iq-`
  /// namespace is Inquiry's, and a skill without it belongs to someone else.
  /// So `clean` removes two things — the agent file Inquiry writes, at a path
  /// it chose, and the `iq-` prefixed skill directories — and never a directory
  /// it does not own.
  ///
  /// It deliberately does **not** remove the skills this release currently
  /// ships. Those names are unprefixed and shared with other consumers, and a
  /// name is not ownership.
  void clean() {
    for (final adapter in adapters) {
      _removeAgentFile(adapter);
      _removeNamespacedSkills(adapter);
    }
  }

  /// Deletes `<agentDirectory>/inquiry.md`, the one file [_deployAgent] writes.
  ///
  /// The file, never the directory: a host's agents directory holds other
  /// tools' agents too.
  void _removeAgentFile(HostAdapter adapter) {
    final file = File(p.join(adapter.agentDirectory(homeDir), 'inquiry.md'));
    if (file.existsSync()) file.deleteSync();
  }

  /// Deletes the `iq-` prefixed skill directories, and only those.
  ///
  /// The skills directory itself survives even when it is left empty. Deleting
  /// it would take every occupant with it, whoever they belong to, and an empty
  /// directory harms nobody.
  void _removeNamespacedSkills(HostAdapter adapter) {
    final dir = Directory(adapter.skillsDirectory(homeDir));
    if (!dir.existsSync()) return;
    for (final entry in dir.listSync().whereType<Directory>()) {
      if (p.basename(entry.path).startsWith(inquirySkillNamespace)) {
        entry.deleteSync(recursive: true);
      }
    }
  }

  /// Deploys inquiry's own skills from the asset tree.
  ///
  /// The lifecycle skills (`specification`, `analyze`, `plan`, `execute`) are no
  /// longer generated here: they belong to MACSS, which ships them as static
  /// assets and installs them with `macss skill deploy`.
  void _deploySkills(HostAdapter adapter) {
    final hostSkillsDir = adapter.skillsDirectory(homeDir);

    for (final skillName in assets.listDirectory('skills')) {
      final content = assets.loadString('skills/$skillName/SKILL.md');
      final hostFile = File(p.join(hostSkillsDir, skillName, 'SKILL.md'));
      hostFile.parent.createSync(recursive: true);
      hostFile.writeAsStringSync(content);
    }
  }

  /// Removes deployed skills that belong to Inquiry's namespace but are no
  /// longer shipped.
  ///
  /// Deployment could add but never retire, so a skill dropped from a release
  /// survived forever as a frozen copy nothing would update again — the
  /// `iq-analyze` / `iq-plan` / `iq-execute` / `iq-specification` left behind
  /// when the lifecycle moved to MACSS (#299). Users then saw both those and
  /// the `macss-*` ones, with no way to tell which was live.
  ///
  /// Scoped by prefix rather than a hand-maintained list of retirements: the
  /// `iq-` namespace is Inquiry's, so anything under it that Inquiry does not
  /// ship is Inquiry's to remove. Skills outside the namespace — `kritik`,
  /// `legion`, `research`, and anything a user wrote — are never touched.
  List<String> _pruneRetiredSkills(HostAdapter adapter) {
    final hostSkillsDir = Directory(adapter.skillsDirectory(homeDir));
    if (!hostSkillsDir.existsSync()) return const [];

    final shipped = assets.listDirectory('skills').toSet();
    final retired = <String>[];

    for (final entry in hostSkillsDir.listSync().whereType<Directory>()) {
      final name = p.basename(entry.path);
      if (!name.startsWith(inquirySkillNamespace)) continue;
      if (shipped.contains(name)) continue;
      entry.deleteSync(recursive: true);
      retired.add(name);
    }

    return retired..sort();
  }

  /// Deploys the inquiry agent to the host's agent dir as `inquiry.md`,
  /// assembled from the shared body + the host's frontmatter.
  void _deployAgent(HostAdapter adapter) {
    final content = AgentBuilder(assets).build(adapter);
    final hostFile = File(p.join(adapter.agentDirectory(homeDir), 'inquiry.md'));
    hostFile.parent.createSync(recursive: true);
    hostFile.writeAsStringSync(content);
  }
}
