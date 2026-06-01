/// Executes FSM transition side-effects that touch `.inquiry/`.
///
/// Effects like `push_branch`, `create_pull_request`, `generate_plan` etc.
/// are skill-side and NOT executed here — they are reported in the transition
/// output for the agent/skill to handle.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../src/cycle_context.dart';

import '../ape/ape_definition.dart';
import '../ape/inquiry_state.dart';
import 'pre_pr_inspection_runner.dart';
import '../../assets.dart';

/// CLI-side effects that modify `.inquiry/` files.
const cliEffects = {
  'update_state',
  'reset_mutations',
  'snapshot_metrics',
  'close_cycle',
  'collect_metrics',
  'open_analysis_context',
  'seed_pre_pr_inspection_template',
};

/// Resolves the body of a GitHub issue for the `issue.md` mirror.
///
/// Returns `null` when the body cannot be fetched (best-effort; non-fatal).
typedef IssueBodyProvider =
    String? Function(String issue, String workingDirectory);

class EffectExecutor {
  final String workingDirectory;
  final Assets? _assets;
  final IssueBodyProvider _issueBodyProvider;

  EffectExecutor({
    required this.workingDirectory,
    Assets? assets,
    IssueBodyProvider? issueBodyProvider,
  }) : _assets = assets,
       _issueBodyProvider = issueBodyProvider ?? _defaultIssueBodyProvider;

  late final CycleContext? _cycleContext = _tryResolveCycleContext();
  late final PrePrInspectionRunner _prePrInspectionRunner =
      PrePrInspectionRunner(workingDirectory: workingDirectory, assets: _assets);

  String get _projectRoot => _cycleContext?.projectRoot ?? workingDirectory;

  String get _inquiryDir => p.join(
    _cycleContext?.inquiryCliRoot ?? _projectRoot,
    '.inquiry',
  );

  String? get _branch => _cycleContext?.branch;

  String? get _cleanroomRoot => _cycleContext?.inquiryRoot;

  /// Maps FSM states to their active sub-agent names.
  static const _stateApes = <String, String>{
    'IDLE': 'dewey',
    'ANALYZE': 'socrates',
    'PLAN': 'descartes',
    'EXECUTE': 'basho',
    'END': 'basho',
    'EVOLUTION': 'darwin',
  };

  /// Update the cycle-local `.iq.state.yaml` with [newState], including APE
  /// auto-activation.
  ///
  /// If the new state has an associated APE, loads its YAML to find `initial_state`
  /// and writes `ape: {name, state}`. Otherwise clears the `ape:` field.
  void updateState(String newState, {String? issue, String? promptFragmentId}) {
    if (newState == 'IDLE') {
      _markCompleted();
      return;
    }

    final currentState = InquiryState.load(workingDirectory);
    String? resolvedIssue = issue;
    String? resolvedPromptFragmentId = promptFragmentId;
    resolvedIssue ??= currentState.issue;

    // Auto-activate APE
    String? apeName;
    String? apeInitialState;
    final ape = _stateApes[newState];
    if (ape != null) {
      apeName = ape;
      if (currentState.apeName == ape && currentState.apeState != null) {
        if (currentState.state == newState &&
            currentState.apeState == '_DONE') {
          apeInitialState = _resolveInitialState(ape);
        } else {
          apeInitialState = currentState.apeState;
        }
      } else {
        apeInitialState = _resolveInitialState(ape);
      }
    }

    final updated = InquiryState(
      state: newState,
      issue: resolvedIssue,
      promptFragmentId: resolvedPromptFragmentId,
      apeName: apeName,
      apeState: apeInitialState,
      version: currentState.version,
      status: 'active',
      createdAt: currentState.createdAt,
    );
    updated.save(workingDirectory);
  }

  /// Mark the active cycle as `completed` (IDLE is derived, never persisted).
  void _markCompleted() => _markStatus('completed');

  /// Mark the active cycle as `blocked` (IDLE is derived, never persisted).
  void _markBlocked() => _markStatus('blocked');

  /// Centralized terminal-status write for the active cycle.
  ///
  /// IDLE is never persisted: the cycle file keeps its last phase but records
  /// [status] (`completed` or `blocked`) so `load()` derives IDLE. Clears any
  /// active APE sub-state. No-op when already at [status].
  void _markStatus(String status) {
    final path = InquiryState.stateFileFor(workingDirectory);
    if (path == null) return;
    if (!File(path).existsSync()) return;
    final raw = InquiryState.loadFrom(path);
    if (raw.status == status) return;
    final marked = raw.copyWith(status: status, clearApe: true);
    marked.saveTo(path);
  }

  /// Create `cleanrooms/<branch>/analyze/index.md` and `confirmations.md` for ANALYZE phase.
  void openAnalysisContext() {
    final branch = _branch;
    final cleanroomRoot = _cleanroomRoot;
    if (branch == null || cleanroomRoot == null) return;

    final issue = InquiryState.load(workingDirectory).issue ?? '';
    final cleanroomDir = p.join(cleanroomRoot, 'analyze');
    final dir = Directory(cleanroomDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);

    final indexFile = File(p.join(cleanroomDir, 'index.md'));
    if (!indexFile.existsSync()) {
      indexFile.writeAsStringSync(
        '# Analyze Phase — Index\n'
        '\n'
        '**Issue:** #$issue\n'
        '**Branch:** $branch\n'
        '**Phase:** ANALYZE\n'
        '**Status:** In progress\n'
        '\n'
        '---\n'
        '\n'
        '## Documents\n'
        '\n'
        '| # | File | Title | Status | Tags |\n'
        '|---|------|-------|--------|------|\n'
        '| 1 | confirmations.md | Confirmations | active | confirmations, findings |\n',
      );
    }

    final confirmationsFile = File(p.join(cleanroomDir, 'confirmations.md'));
    if (!confirmationsFile.existsSync()) {
      confirmationsFile.writeAsStringSync(
        '---\n'
        'id: confirmations\n'
        'title: "Confirmations"\n'
        'date: $today\n'
        'status: active\n'
        'tags: [confirmations, findings]\n'
        '---\n'
        '\n'
        '# Confirmations\n'
        '\n'
        '> Living document. Update as findings are confirmed, revised, or invalidated.\n'
        '> Format: ## F<N>: <title> — CONFIRMED|REVISED|INVALIDATED\n',
      );
    }

    _writeIssueMirror(cleanroomRoot, branch, issue, today);
  }

  /// Best-effort `cleanrooms/<branch>/issue.md` mirror of the GitHub issue.
  ///
  /// Idempotent: never clobbers an existing mirror. A failed/empty body fetch
  /// is non-fatal — the mirror is still written with the available metadata.
  void _writeIssueMirror(
    String cleanroomRoot,
    String branch,
    String issue,
    String today,
  ) {
    final issueFile = File(p.join(cleanroomRoot, 'issue.md'));
    if (issueFile.existsSync()) return;

    String? body;
    if (issue.isNotEmpty) {
      try {
        body = _issueBodyProvider(issue, _projectRoot);
      } catch (_) {
        body = null;
      }
    }

    final issueRef = issue.isNotEmpty ? '#$issue' : '(unassigned)';
    final buffer = StringBuffer()
      ..write('---\n')
      ..write('id: issue\n')
      ..write('issue: "$issue"\n')
      ..write('branch: $branch\n')
      ..write('date: $today\n')
      ..write('---\n')
      ..write('\n')
      ..write('# Issue $issueRef\n')
      ..write('\n');
    if (body != null && body.trim().isNotEmpty) {
      buffer.write(body.trim());
      buffer.write('\n');
    } else {
      buffer.write('> Issue body unavailable (fetched best-effort).\n');
    }

    issueFile.parent.createSync(recursive: true);
    issueFile.writeAsStringSync(buffer.toString());
  }

  static String? _defaultIssueBodyProvider(
    String issue,
    String workingDirectory,
  ) {
    try {
      final result = Process.runSync('gh', [
        'issue',
        'view',
        issue,
        '--json',
        'body',
        '-q',
        '.body',
      ], workingDirectory: workingDirectory);
      if (result.exitCode != 0) return null;
      final body = result.stdout.toString().trim();
      return body.isEmpty ? null : body;
    } catch (_) {
      return null;
    }
  }

  CycleContext? _tryResolveCycleContext() {
    try {
      return CycleContext.resolve(workingDirectory);
    } on CycleResolutionException {
      return null;
    }
  }

  /// Reset the cycle-local `cleanrooms/<branch>/mutations.md` to empty template.
  void resetMutations() {
    final file = File(_mutationsPath());
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      '# Mutations\n'
      '\n'
      'Notes for DARWIN. Write observations about the current cycle here.\n'
      'This file is read during EVOLUTION and cleared afterwards.\n',
    );
  }

  /// Resolve the cycle-local `mutations.md` path.
  ///
  /// Falls back to repo-level `.inquiry/mutations.md` only when no cycle
  /// resolves (derived IDLE / not a git repo).
  String _mutationsPath() {
    final cleanroomRoot = _cleanroomRoot;
    if (cleanroomRoot == null) {
      return p.join(_inquiryDir, 'mutations.md');
    }
    return p.join(cleanroomRoot, 'mutations.md');
  }

  /// Resolve the initial_state for an APE by loading its YAML definition.
  String? _resolveInitialState(String apeName) {
    try {
      final yamlPath = _assets != null
          ? _assets.path('apes/$apeName.yaml')
          : p.join(workingDirectory, 'assets', 'apes', '$apeName.yaml');
      final content = File(yamlPath).readAsStringSync();
      final def = ApeDefinition.parse(content);
      return def.initialState;
    } catch (_) {
      return null;
    }
  }

  /// Create/overwrite `.inquiry/metrics_snapshot.yaml` with current state.
  void snapshotMetrics() {
    final current = InquiryState.load(workingDirectory);

    final issueLine = current.issue != null
        ? 'issue: "${current.issue}"'
        : 'issue: null';
    Directory(_inquiryDir).createSync(recursive: true);
    final snapshot = File(p.join(_inquiryDir, 'metrics_snapshot.yaml'));
    snapshot.writeAsStringSync(
      'snapshot_at: "${DateTime.now().toUtc().toIso8601String()}"\n'
      'state: ${current.state}\n'
      '$issueLine\n',
    );
  }

  /// Reset state to IDLE and clear issue.
  void closeCycle() {
    updateState('IDLE');
  }

  /// Append a cycle completion entry to `.inquiry/metrics.yaml`.
  void collectMetrics() {
    final current = InquiryState.load(workingDirectory);

    final issueLine = current.issue != null
        ? 'issue: "${current.issue}"'
        : 'issue: null';
    final entry =
        '  - $issueLine\n'
        '    completed_at: "${DateTime.now().toUtc().toIso8601String()}"\n';

    Directory(_inquiryDir).createSync(recursive: true);
    final metricsFile = File(p.join(_inquiryDir, 'metrics.yaml'));
    if (metricsFile.existsSync()) {
      metricsFile.writeAsStringSync(entry, mode: FileMode.append);
    } else {
      metricsFile.writeAsStringSync('cycles:\n$entry');
    }
  }

  void materializePrePrInspectionReport() {
    _prePrInspectionRunner.materializeReport();
  }

  void refreshPrePrInspectionConsistency() {
    _prePrInspectionRunner.refreshDeterministicPasses();
  }

  /// Execute all CLI-side effects for a transition.
  ///
  /// Always executes `update_state` first (every valid transition updates state).
  /// Then executes any CLI-side effects from [effects].
  /// Skill-side effects (git, PR, analysis context, etc.) are skipped.
  ///
  /// Returns the list of effects actually executed.
  List<String> executeAll({
    required List<String> effects,
    required String newState,
    String? issue,
    String? promptFragmentId,
  }) {
    final executed = <String>[];

    // Always update state on valid transition
    updateState(newState, issue: issue, promptFragmentId: promptFragmentId);
    executed.add('update_state');

    for (final effect in effects) {
      switch (effect) {
        case 'open_analysis_context':
          openAnalysisContext();
          executed.add(effect);
        case 'reset_mutations':
          resetMutations();
          executed.add(effect);
        case 'snapshot_metrics':
          snapshotMetrics();
          executed.add(effect);
        case 'close_cycle':
          closeCycle();
          executed.add(effect);
        case 'collect_metrics':
          collectMetrics();
          executed.add(effect);
        case 'seed_pre_pr_inspection_template':
          materializePrePrInspectionReport();
          executed.add(effect);
        case 'pause_analysis':
        case 'pause_plan':
          _markBlocked();
          executed.add(effect);
        // Skill-side effects — not executed by CLI
        default:
          break;
      }
    }

    return executed;
  }
}
