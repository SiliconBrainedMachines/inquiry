/// Abstract base class for target AI coding tool adapters.
///
/// Each adapter knows the global config paths for a specific AI coding tool.
abstract class TargetAdapter {
  /// Human-readable name of the target tool.
  String get name;

  /// Returns the directory path where skills should be deployed.
  String skillsDirectory(String homeDir);

  /// Returns the directory path where agents should be deployed.
  String agentDirectory(String homeDir);
}
