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
  /// `iq init`. Hosts that expose a global agent directory (OpenCode) opt in.
  bool get deploysAgent => false;

  /// Names of other hosts that make this one redundant.
  ///
  /// When any listed target exists, this adapter should be skipped
  /// during deploy (but still cleaned).
  List<String> get subsumedBy => const [];
}
