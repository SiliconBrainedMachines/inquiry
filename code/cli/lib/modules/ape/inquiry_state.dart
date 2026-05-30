/// Reads and writes the cycle-local FSM state file `.iq.state.yaml`.
///
/// The state file lives inside the active cycle root
/// (`cleanrooms/<branch>/.iq.state.yaml`), resolved via [CycleContext].
/// `IDLE` is never persisted: it is the absence of a resolved active cycle, or a
/// cycle whose `status` is `completed`.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../src/cycle_context.dart';

/// Canonical cycle-local state file name.
const kStateFileName = '.iq.state.yaml';

/// Represents the full contents of a cycle's `.iq.state.yaml`.
class InquiryState {
  final String state;
  final String? issue;
  final String? promptFragmentId;
  final String? apeName;
  final String? apeState;

  /// Schema version of the state file.
  final int version;

  /// Lifecycle status: `active`, `completed`, or `blocked`. `null` is treated
  /// as `active` for backward tolerance.
  final String? status;

  /// ISO-8601 creation timestamp, preserved across saves.
  final String? createdAt;

  /// ISO-8601 timestamp of the last save.
  final String? updatedAt;

  const InquiryState({
    required this.state,
    this.issue,
    this.promptFragmentId,
    this.apeName,
    this.apeState,
    this.version = 1,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Resolves the cycle-local state file path for [workingDirectory].
  ///
  /// Returns `null` when no active cycle resolves (not a git repository,
  /// detached HEAD, or no branch), which maps to derived IDLE.
  static String? stateFileFor(String workingDirectory) {
    try {
      final ctx = CycleContext.resolve(workingDirectory);
      final root = ctx.inquiryRoot;
      if (root == null) return null;
      return p.join(root, kStateFileName);
    } on CycleResolutionException {
      return null;
    }
  }

  /// Reads state from an explicit [stateFilePath] without IDLE mapping.
  ///
  /// Returns a raw IDLE placeholder when the file is missing or malformed.
  static InquiryState loadFrom(String stateFilePath) {
    final file = File(stateFilePath);
    if (!file.existsSync()) {
      return const InquiryState(state: 'IDLE');
    }

    final yaml = loadYaml(file.readAsStringSync());
    if (yaml is! YamlMap) {
      return const InquiryState(state: 'IDLE');
    }

    final state =
        (yaml['state'] as String?) ?? (yaml['fsm_state'] as String?) ?? 'IDLE';
    final rawIssue = yaml['issue'];
    final issue = (rawIssue is String && rawIssue.isNotEmpty)
        ? rawIssue
        : (rawIssue is int)
        ? rawIssue.toString()
        : null;
    final rawPromptFragmentId = yaml['prompt_fragment_id'];
    final promptFragmentId =
        (rawPromptFragmentId is String && rawPromptFragmentId.isNotEmpty)
        ? rawPromptFragmentId
        : null;

    String? apeName;
    String? apeState;
    final apeMap = yaml['ape'];
    if (apeMap is YamlMap) {
      apeName = apeMap['name'] as String?;
      apeState = apeMap['state'] as String?;
    }

    final rawVersion = yaml['version'];
    final version = rawVersion is int ? rawVersion : 1;
    final status = yaml['status'] as String?;
    final createdAt = yaml['created_at'] as String?;
    final updatedAt = yaml['updated_at'] as String?;

    return InquiryState(
      state: state,
      issue: issue,
      promptFragmentId: promptFragmentId,
      apeName: apeName,
      apeState: apeState,
      version: version,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Reads the active cycle state for [workingDirectory].
  ///
  /// Returns derived IDLE when no cycle resolves, the file is missing, or the
  /// cycle's `status` is `completed` or `blocked` (every closing/pausing
  /// transition targets IDLE, which is never persisted).
  static InquiryState load(String workingDirectory) {
    final path = stateFileFor(workingDirectory);
    if (path == null) {
      return const InquiryState(state: 'IDLE');
    }
    final raw = loadFrom(path);
    if (raw.status == 'completed' || raw.status == 'blocked') {
      return const InquiryState(state: 'IDLE');
    }
    return raw;
  }

  /// Writes this state to an explicit [stateFilePath].
  void saveTo(String stateFilePath) {
    final file = File(stateFilePath);
    file.parent.createSync(recursive: true);
    final now = DateTime.now().toUtc().toIso8601String();
    final created = createdAt ?? now;

    final buf = StringBuffer();
    buf.writeln('version: $version');
    buf.writeln('state: $state');
    buf.writeln(issue != null ? 'issue: "$issue"' : 'issue: null');
    buf.writeln(
      promptFragmentId != null
          ? 'prompt_fragment_id: $promptFragmentId'
          : 'prompt_fragment_id: null',
    );
    buf.writeln('status: ${status ?? 'active'}');
    if (apeName != null) {
      buf.writeln('ape:');
      buf.writeln('  name: $apeName');
      buf.writeln('  state: ${apeState ?? "null"}');
    } else {
      buf.writeln('ape: null');
    }
    buf.writeln('created_at: "$created"');
    buf.writeln('updated_at: "$now"');
    file.writeAsStringSync(buf.toString());
  }

  /// Writes the active cycle state for [workingDirectory].
  ///
  /// Throws [StateError] when no cycle resolves (IDLE is never persisted).
  void save(String workingDirectory) {
    final path = stateFileFor(workingDirectory);
    if (path == null) {
      throw StateError(
        'cannot persist FSM state: no active cycle resolves for '
        '"$workingDirectory" (IDLE is derived, not stored)',
      );
    }
    saveTo(path);
  }

  InquiryState copyWith({
    String? state,
    String? issue,
    String? promptFragmentId,
    String? apeName,
    String? apeState,
    int? version,
    String? status,
    String? createdAt,
    String? updatedAt,
    bool clearApe = false,
  }) {
    return InquiryState(
      state: state ?? this.state,
      issue: issue ?? this.issue,
      promptFragmentId: promptFragmentId ?? this.promptFragmentId,
      apeName: clearApe ? null : (apeName ?? this.apeName),
      apeState: clearApe ? null : (apeState ?? this.apeState),
      version: version ?? this.version,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
