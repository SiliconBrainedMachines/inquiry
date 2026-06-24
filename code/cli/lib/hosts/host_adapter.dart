import 'dart:io';

/// Abstract base class for host AI coding tool adapters.
///
/// Each adapter knows the global config paths for a specific AI coding host.
abstract class HostAdapter {
  /// Human-readable name of the host tool.
  String get name;

  /// Returns the base directory path for this host (e.g. `~/.claude`).
  String baseDirectory(String homeDir);

  /// Returns the directory path where skills should be deployed.
  String skillsDirectory(String homeDir);

  /// Returns the directory path where agents should be deployed.
  String agentDirectory(String homeDir);

  /// Whether this host's base directory exists on disk.
  bool exists(String homeDir) => Directory(baseDirectory(homeDir)).existsSync();

  /// Whether `host get` should also deploy the inquiry agent to this host.
  ///
  /// Most hosts receive skills only; the inquiry agent is repo-scoped via
  /// `iq init`. Hosts that expose a global agent directory may opt in.
  bool get deploysAgent => false;

  /// Repo-relative path of this host's per-project agent file, e.g.
  /// `.opencode/agent/inquiry.md` or `.github/agents/inquiry.agent.md`.
  ///
  /// `null` when this host has no per-project agent location. Used by `iq init`
  /// (to deploy, repo-scoped like `git init`) and `iq doctor` (to verify).
  String? get projectAgentRelPath => null;

  /// Asset path of this host's agent frontmatter YAML.
  ///
  /// [AgentBuilder] assembles it with the shared firmware body
  /// (`agents/inquiry.body.md`). Defaults to a per-host file named after [name].
  String get agentFrontmatterAsset => 'agents/frontmatter/$name.yaml';

  /// Host-specific substitutions applied to the shared firmware body.
  ///
  /// Keys are matched as `{{KEY}}`. Lets a single body carry the one or two
  /// genuinely host-specific lines (e.g. the install/init hint) without
  /// duplicating the whole firmware per host.
  Map<String, String> get agentSubstitutions => const {};

  /// Names of other hosts that make this one redundant.
  ///
  /// When any listed target exists, this adapter should be skipped
  /// during deploy (but still cleaned).
  List<String> get subsumedBy => const [];
}
