/// Resolves the distinct roots an Inquiry invocation depends on.
///
/// The CLI historically overloaded a single cwd-derived `workingDirectory` for
/// the repository root, the cycle root, the config home, and the git execution
/// base. [CycleContext] separates those concerns:
///
/// - [projectRoot]    — the git repository / worktree root.
/// - [inquiryRoot]    — the active cycle root, `cleanrooms/<branch>/`, or `null`
///   when no cycle resolves (derived IDLE).
/// - [inquiryCliRoot] — the home for CLI/project-level config (`config.yaml`).
///
/// `IDLE` is never persisted: it is the absence of a resolved [inquiryRoot].
library;

import 'package:path/path.dart' as p;

import 'git_utils.dart';

/// Raised when repository context cannot be resolved into a [CycleContext].
class CycleResolutionException implements Exception {
  final String message;
  const CycleResolutionException(this.message);

  @override
  String toString() => 'CycleResolutionException: $message';
}

/// The resolved roots for a single CLI invocation.
class CycleContext {
  /// The git repository / worktree root.
  final String projectRoot;

  /// The current branch, or `null` for derived IDLE (detached HEAD / no branch).
  final String? branch;

  /// The active cycle root `cleanrooms/<branch>/`, or `null` for derived IDLE.
  final String? inquiryRoot;

  /// The home for CLI/project-level configuration.
  final String inquiryCliRoot;

  const CycleContext({
    required this.projectRoot,
    required this.branch,
    required this.inquiryRoot,
    required this.inquiryCliRoot,
  });

  /// Whether no active cycle resolves from the current repository context.
  bool get isIdle => inquiryRoot == null;

  /// Normalizes a raw branch token into an active branch name.
  ///
  /// Returns `null` for an empty token or the detached-HEAD sentinel `HEAD`,
  /// both of which map to derived IDLE.
  static String? normalizeBranch(String raw) {
    final b = raw.trim();
    if (b.isEmpty || b == 'HEAD') return null;
    return b;
  }

  /// Resolves the context for [workingDirectory] using git.
  ///
  /// Throws [CycleResolutionException] when:
  /// - [workingDirectory] is not inside a git repository, or
  /// - the current branch name contains a path separator (`/`), which the
  ///   `<issue>-<slug>` convention forbids.
  static CycleContext resolve(String workingDirectory) {
    final root = getProjectRoot(workingDirectory);
    if (root == null) {
      throw const CycleResolutionException('not a git repository');
    }

    final branch = normalizeBranch(getCurrentBranch(workingDirectory));
    if (branch != null && (branch.contains('/') || branch.contains(r'\'))) {
      throw CycleResolutionException(
        'branch name must be a single path segment: $branch',
      );
    }

    final inquiryRoot = branch == null
        ? null
        : p.join(root, 'cleanrooms', branch);

    return CycleContext(
      projectRoot: root,
      branch: branch,
      inquiryRoot: inquiryRoot,
      inquiryCliRoot: root,
    );
  }
}
