import 'dart:io';

import 'package:path/path.dart' as p;

final RegExp _windowsMsysRootPattern = RegExp(r'^/([a-zA-Z])/(.*)$');

/// Normalizes a git-reported repository root into a platform path.
///
/// On Git for Windows, `rev-parse --show-toplevel` may return either
/// `D:/repo` or the MSYS-style `/d/repo`. The latter must be rewritten before
/// `package:path` can normalize it into a stable Windows path.
String normalizeGitRootPath(String rawPath) {
  var path = rawPath.trim();
  if (Platform.isWindows) {
    final match = _windowsMsysRootPattern.firstMatch(path);
    if (match != null) {
      final drive = match.group(1)!.toUpperCase();
      final rest = match.group(2)!;
      path = '$drive:/$rest';
    }
  }
  return p.normalize(path);
}

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
    return out.isEmpty ? null : normalizeGitRootPath(out);
  } catch (_) {
    return null;
  }
}
