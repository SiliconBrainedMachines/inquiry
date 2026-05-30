/// Test support: build a resolvable cycle (git repo + branch + cleanroom) so
/// that `CycleContext.resolve` / `InquiryState.load`/`save` operate against a
/// real cycle-local `.iq.state.yaml`.
library;

import 'dart:io';

import 'package:inquiry_cli/modules/ape/inquiry_state.dart';
import 'package:path/path.dart' as p;

ProcessResult _git(String root, List<String> args) {
  final r = Process.runSync('git', args, workingDirectory: root);
  if (r.exitCode != 0) {
    throw StateError('git ${args.join(' ')} failed: ${r.stderr}');
  }
  return r;
}

/// Initializes a git repository at [root] on [branch] with a cleanroom dir.
///
/// Returns the resolved cycle-local state file path
/// (`<root>/cleanrooms/<branch>/.iq.state.yaml`).
String setupCycle(String root, {required String branch}) {
  _git(root, ['init', '-q']);
  _git(root, ['config', 'user.email', 'test@example.com']);
  _git(root, ['config', 'user.name', 'Test']);
  // An initial commit is required so `git rev-parse --abbrev-ref HEAD` reports
  // the branch name rather than the unborn-branch sentinel `HEAD`.
  File(p.join(root, '.gitkeep')).writeAsStringSync('');
  _git(root, ['add', '.gitkeep']);
  _git(root, ['commit', '-q', '-m', 'init']);
  _git(root, ['checkout', '-q', '-b', branch]);
  final cleanroom = Directory(p.join(root, 'cleanrooms', branch));
  cleanroom.createSync(recursive: true);
  return p.join(cleanroom.path, kStateFileName);
}

/// Resolves the cycle-local state file path for a [root] on [branch] without
/// creating the cleanroom directory.
String cycleStateFile(String root, String branch) =>
    p.join(root, 'cleanrooms', branch, kStateFileName);
