import 'dart:io';

/// Returns the current git branch name for [workingDirectory].
///
/// Returns an empty string if git is unavailable or not in a repository.
String getCurrentBranch(String workingDirectory) {
  try {
    final result = Process.runSync('git', [
      'rev-parse',
      '--abbrev-ref',
      'HEAD',
    ], workingDirectory: workingDirectory);
    if (result.exitCode != 0) return '';
    return (result.stdout as String).trim();
  } catch (_) {
    return '';
  }
}

/// Returns the git repository top-level directory for [workingDirectory].
///
/// Returns `null` when [workingDirectory] is not inside a git repository or
/// git is unavailable.
String? getProjectRoot(String workingDirectory) {
  try {
    final result = Process.runSync('git', [
      'rev-parse',
      '--show-toplevel',
    ], workingDirectory: workingDirectory);
    if (result.exitCode != 0) return null;
    final out = (result.stdout as String).trim();
    return out.isEmpty ? null : out;
  } catch (_) {
    return null;
  }
}
