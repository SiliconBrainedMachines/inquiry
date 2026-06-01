library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../assets.dart';
import '../../src/cycle_context.dart';
import '../ape/inquiry_state.dart';

class PrePrInspectionRunner {
  final String workingDirectory;
  final Assets? _assets;

  PrePrInspectionRunner({
    required this.workingDirectory,
    Assets? assets,
  }) : _assets = assets;

  late final CycleContext? _cycleContext = _tryResolveCycleContext();

  String get _projectRoot => _cycleContext?.projectRoot ?? workingDirectory;

  String get _inquiryDir => p.join(_cycleContext?.inquiryCliRoot ?? _projectRoot, '.inquiry');

  String? get _branch => _cycleContext?.branch;

  String? get _cleanroomRoot => _cycleContext?.inquiryRoot;

  String? get _cleanroomPlanPath {
    final cleanroomRoot = _cleanroomRoot;
    if (cleanroomRoot == null) return null;
    return p.join(cleanroomRoot, 'plan.md');
  }

  void materializeReport() {
    final branch = _branch;
    final cleanroomRoot = _cleanroomRoot;
    if (branch == null || cleanroomRoot == null) return;

    final file = File(p.join(cleanroomRoot, 'pre_pr_inspection.md'));
    if (!file.existsSync()) {
      final current = InquiryState.load(workingDirectory);
      final issue = current.issue ?? '';
      final template = _loadTemplate()
          .replaceAll('{{ISSUE}}', issue.isEmpty ? 'unassigned' : issue)
          .replaceAll('{{BRANCH}}', branch)
          .replaceAll(
            '{{GENERATED_AT}}',
            DateTime.now().toUtc().toIso8601String(),
          );

      file.parent.createSync(recursive: true);
      file.writeAsStringSync(template);
    }

    refreshDeterministicPasses();
  }

  void refreshDeterministicPasses() {
    refreshConsistency();
    refreshCompleteness();
    refreshTraceability();
  }

  void refreshConsistency() {
    final cleanroomRoot = _cleanroomRoot;
    if (cleanroomRoot == null) return;

    final file = File(p.join(cleanroomRoot, 'pre_pr_inspection.md'));
    if (!file.existsSync()) return;

    _rewriteSection(
      file,
      startMarkers: const ['## Pass 1 — Consistency', '## Consistency'],
      endMarkers: const ['## Pass 2 — Completeness', '## Completeness'],
      checks: _deterministicConsistencyChecks(),
    );
  }

  void refreshCompleteness() {
    final cleanroomRoot = _cleanroomRoot;
    if (cleanroomRoot == null) return;

    final file = File(p.join(cleanroomRoot, 'pre_pr_inspection.md'));
    if (!file.existsSync()) return;

    _rewriteSection(
      file,
      startMarkers: const ['## Pass 2 — Completeness', '## Completeness'],
      endMarkers: const ['## Pass 3 — Traceability', '## Traceability'],
      checks: _automaticCompletenessChecks(),
    );
  }

  void refreshTraceability() {
    final cleanroomRoot = _cleanroomRoot;
    if (cleanroomRoot == null) return;

    final file = File(p.join(cleanroomRoot, 'pre_pr_inspection.md'));
    if (!file.existsSync()) return;

    final content = file.readAsStringSync().replaceAll('\r\n', '\n');
    final preservedManualChecks = _sectionChecks(
      content,
      startMarkers: const ['## Pass 3 — Traceability', '## Traceability'],
      endMarkers: const ['## Citation Guidance'],
      endAtEof: true,
    ).where((check) => !_isAutomaticTraceabilityCheck(check)).toList();

    _rewriteSection(
      file,
      startMarkers: const ['## Pass 3 — Traceability', '## Traceability'],
      endMarkers: const ['## Citation Guidance'],
      checks: [
        ..._automaticTraceabilityChecks(file),
        ...preservedManualChecks,
      ],
      endAtEof: true,
    );
  }

  void _rewriteSection(
    File file, {
    required List<String> startMarkers,
    required List<String> endMarkers,
    required List<String> checks,
    bool endAtEof = false,
  }) {
    final content = file.readAsStringSync().replaceAll('\r\n', '\n');
    final startMarker = _firstExistingMarker(content, startMarkers);
    final endMarker = _firstExistingMarker(content, endMarkers);
    if (startMarker == null) return;
    final start = content.indexOf(startMarker);
    final end = endMarker == null ? content.length : content.indexOf(endMarker);
    if (endMarker == null && !endAtEof) return;
    if (start == -1 || end == -1 || end <= start) return;

    final before = content.substring(0, start + startMarker.length);
    final after = content.substring(end);
    final updated = StringBuffer()
      ..write(before)
      ..write('\n')
      ..writeAll(checks.map((line) => '$line\n'))
      ..write('\n')
      ..write(after);
    file.writeAsStringSync('${updated.toString().trimRight()}\n');
  }

  CycleContext? _tryResolveCycleContext() {
    try {
      return CycleContext.resolve(workingDirectory);
    } on CycleResolutionException {
      return null;
    }
  }

  String _loadTemplate() {
    if (_assets != null) {
      return _assets.loadString('inspection/pre_pr_inspection_template.md');
    }

    final file = File(
      p.join(
        _projectRoot,
        'assets',
        'inspection',
        'pre_pr_inspection_template.md',
      ),
    );
    return file.readAsStringSync();
  }

  List<String> _deterministicConsistencyChecks() {
    final sourceAssetsDir = Directory(p.join(_projectRoot, 'assets'));
    final buildAssetsDir = Directory(p.join(_projectRoot, 'build', 'assets'));
    if (!sourceAssetsDir.existsSync() || !buildAssetsDir.existsSync()) {
      return const [
        '- WARN: no source/build asset mirror detected under assets/ and build/assets; automatic parity skipped for this repo',
      ];
    }

    final sourceFiles = _relativeFiles(sourceAssetsDir.path);
    final buildFiles = _relativeFiles(buildAssetsDir.path);
    final allPaths = {...sourceFiles, ...buildFiles}.toList()..sort();
    final findings = <String>[];

    for (final relativePath in allPaths) {
      final sourceExists = sourceFiles.contains(relativePath);
      final buildExists = buildFiles.contains(relativePath);

      if (sourceExists && !buildExists) {
        findings.add(
          '- FAIL: missing build/assets mirror for assets/$relativePath at assets/$relativePath:1',
        );
        continue;
      }

      if (!sourceExists && buildExists) {
        findings.add(
          '- FAIL: stale build/assets file without source mirror at build/assets/$relativePath:1',
        );
        continue;
      }

      final sourceContent = File(
        p.join(sourceAssetsDir.path, relativePath),
      ).readAsStringSync();
      final buildContent = File(
        p.join(buildAssetsDir.path, relativePath),
      ).readAsStringSync();
      if (sourceContent != buildContent) {
        final line = _firstDifferentLine(sourceContent, buildContent);
        findings.add(
          '- FAIL: mirrored asset content diverges between assets/$relativePath:$line and build/assets/$relativePath:$line',
        );
      }
    }

    if (findings.isEmpty) {
      return [
        '- PASS: asset parity source/build reviewed across ${sourceFiles.length} mirrored files',
      ];
    }

    return findings;
  }

  List<String> _automaticCompletenessChecks() {
    final branch = _branch;
    final planPath = _cleanroomPlanPath;
    if (branch == null || planPath == null) {
      return const [
        '- WARN: no active cleanroom plan resolved; automatic completeness review skipped for this repo',
      ];
    }

    final planFile = File(planPath);
    final relativePlanPath = 'cleanrooms/$branch/plan.md';
    if (!planFile.existsSync()) {
      return [
        '- WARN: plan.md missing for automatic completeness review at $relativePlanPath:1',
      ];
    }

    final lines = planFile.readAsStringSync().replaceAll('\r\n', '\n').split(
      '\n',
    );
    final uncheckedChecks = <String>[];
    var checkedCount = 0;

    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (_uncheckedCheckboxPattern.hasMatch(line)) {
        uncheckedChecks.add(
          '- FAIL: unchecked plan checkbox remains at $relativePlanPath:${index + 1}',
        );
      } else if (_checkedCheckboxPattern.hasMatch(line)) {
        checkedCount += 1;
      }
    }

    if (uncheckedChecks.isNotEmpty) {
      return uncheckedChecks;
    }

    if (checkedCount > 0) {
      return [
        '- PASS: all $checkedCount plan.md checkboxes are complete in $relativePlanPath',
      ];
    }

    return [
      '- WARN: no plan checkboxes found for automatic completeness review at $relativePlanPath:1',
    ];
  }

  List<String> _automaticTraceabilityChecks(File reportFile) {
    final branch = _branch;
    if (branch == null) {
      return const [
        '- WARN: no active branch resolved; automatic traceability review skipped for this repo',
      ];
    }

    final relativeReportPath = 'cleanrooms/$branch/pre_pr_inspection.md';
    final activeIssue = InquiryState.load(workingDirectory).issue?.trim();
    final metadata = _reportMetadata(reportFile.readAsStringSync());
    final findings = <String>[];

    if (metadata.issue.value == null || metadata.issue.value!.isEmpty) {
      findings.add(
        '- FAIL: inspection issue metadata missing at $relativeReportPath:${metadata.issue.lineNumber ?? 1}',
      );
    } else if (activeIssue == null || activeIssue.isEmpty) {
      findings.add(
        '- WARN: active issue missing in state; automatic traceability review degraded at $relativeReportPath:${metadata.issue.lineNumber ?? 1}',
      );
    } else if (metadata.issue.value != activeIssue) {
      findings.add(
        '- FAIL: inspection issue metadata "${metadata.issue.value}" does not match active issue "$activeIssue" at $relativeReportPath:${metadata.issue.lineNumber ?? 1}',
      );
    }

    if (metadata.branch.value == null || metadata.branch.value!.isEmpty) {
      findings.add(
        '- FAIL: inspection branch metadata missing at $relativeReportPath:${metadata.branch.lineNumber ?? 1}',
      );
    } else if (metadata.branch.value != branch) {
      findings.add(
        '- FAIL: inspection branch metadata "${metadata.branch.value}" does not match active branch "$branch" at $relativeReportPath:${metadata.branch.lineNumber ?? 1}',
      );
    }

    if (findings.isEmpty && activeIssue != null && activeIssue.isNotEmpty) {
      findings.add(
        '- PASS: inspection metadata matches active issue "$activeIssue" and branch "$branch"',
      );
    }

    findings.addAll(_automaticOverheadChecks(branch));
    return findings;
  }

  List<String> _automaticOverheadChecks(String branch) {
    final relativeTracePath = 'cleanrooms/$branch/run_trace.yaml';
    final traceFile = File(p.join(_cleanroomRoot!, 'run_trace.yaml'));
    if (!traceFile.existsSync()) {
      return [
        '- WARN: overhead summary could not read run_trace at $relativeTracePath:1',
      ];
    }

    final events = _loadRunTraceEvents(traceFile);
    if (events.isEmpty) {
      return [
        '- WARN: overhead summary found no trace events in $relativeTracePath:1',
      ];
    }

    final counts = <String, int>{
      'transition': 0,
      'sensor_run': 0,
      'block': 0,
      'retry': 0,
      'phase_timing': 0,
      'tool_activity': 0,
      'model_activity': 0,
    };
    final nonApprovedGates = <String, int>{};
    final blockingBoundaries = <String, int>{};
    final retryCounts = <String, int>{};
    final retryReasons = <String, String>{};
    final phaseCosts = <String, double>{};
    final toolClasses = <String, int>{};
    final modelInputTokens = <String, int>{};
    final modelPromptCharacters = <String, int>{};
    final modelAssemblyDurations = <String, double>{};

    for (final event in events) {
      final eventClass = _traceString(event['event_class']);
      if (counts.containsKey(eventClass)) {
        counts[eventClass] = counts[eventClass]! + 1;
      }

      if (eventClass == 'sensor_run') {
        final verdict = _traceString(event['verdict']).toUpperCase();
        final gate = _traceString(event['gate']);
        if (gate.isNotEmpty && verdict.isNotEmpty && verdict != 'APPROVED') {
          nonApprovedGates[gate] = (nonApprovedGates[gate] ?? 0) + 1;
        }
      }

      if (eventClass == 'block') {
        final boundary = _traceString(event['blocking_boundary']);
        if (boundary.isNotEmpty) {
          blockingBoundaries[boundary] = (blockingBoundaries[boundary] ?? 0) + 1;
        }
      }

      if (eventClass == 'retry') {
        final transitionEvent = _traceString(event['transition_event']);
        if (transitionEvent.isNotEmpty) {
          retryCounts[transitionEvent] = (retryCounts[transitionEvent] ?? 0) + 1;
          final reason = _traceString(event['triggering_failure']);
          if (reason.isNotEmpty) {
            retryReasons.putIfAbsent(transitionEvent, () => reason);
          }
        }
      }

      if (eventClass == 'phase_timing') {
        final phase = _traceString(event['phase']);
        final duration = _traceDouble(event['duration_seconds']);
        if (phase.isNotEmpty && duration != null) {
          phaseCosts[phase] = (phaseCosts[phase] ?? 0) + duration;
        }
      }

      if (eventClass == 'tool_activity') {
        final toolClass = _traceString(event['tool_class']);
        if (toolClass.isNotEmpty) {
          toolClasses[toolClass] = (toolClasses[toolClass] ?? 0) + 1;
        }
      }

      if (eventClass == 'model_activity') {
        final label = _traceString(event['ape_name']).isNotEmpty
            ? _traceString(event['ape_name'])
            : _traceString(event['phase']);
        if (label.isEmpty) continue;

        final estimatedTokens = _traceInt(event['estimated_input_tokens']);
        final promptCharacters = _traceInt(event['prompt_characters']);
        final assemblyDuration = _traceDouble(
          event['assembly_duration_seconds'],
        );

        if (estimatedTokens != null && estimatedTokens > 0) {
          modelInputTokens[label] =
              (modelInputTokens[label] ?? 0) + estimatedTokens;
        }
        if (promptCharacters != null && promptCharacters > 0) {
          modelPromptCharacters[label] =
              (modelPromptCharacters[label] ?? 0) + promptCharacters;
        }
        if (assemblyDuration != null && assemblyDuration > 0) {
          modelAssemblyDurations[label] =
              (modelAssemblyDurations[label] ?? 0) + assemblyDuration;
        }
      }
    }

    final lines = <String>[
      '- PASS: overhead summary event counts transition=${counts['transition']}, sensor_run=${counts['sensor_run']}, block=${counts['block']}, retry=${counts['retry']}, phase_timing=${counts['phase_timing']}, tool_activity=${counts['tool_activity']}, model_activity=${counts['model_activity']} at $relativeTracePath:1',
    ];

    final dominantBoundary = _topCount(blockingBoundaries);
    if (dominantBoundary == null) {
      lines.add(
        '- PASS: overhead summary found no blocking boundaries before END in $relativeTracePath:1',
      );
    } else {
      lines.add(
        '- WARN: overhead summary shows blocking concentrated at ${dominantBoundary.key}=${dominantBoundary.value} in $relativeTracePath:1',
      );
    }

    final dominantGate = _topCount(nonApprovedGates);
    if (dominantGate == null) {
      lines.add(
        '- PASS: overhead summary found no non-approved gates before END in $relativeTracePath:1',
      );
    } else {
      lines.add(
        '- WARN: overhead summary shows non-approved gates concentrated at ${dominantGate.key}=${dominantGate.value} in $relativeTracePath:1',
      );
    }

    final dominantRetry = _topCount(retryCounts);
    if (dominantRetry == null) {
      lines.add(
        '- PASS: overhead summary found no retries before END in $relativeTracePath:1',
      );
    } else {
      final reason = retryReasons[dominantRetry.key];
      final reasonSuffix = reason == null || reason.isEmpty
          ? ''
          : ' due to "${reason.replaceAll('"', '\\"')}"';
      lines.add(
        '- WARN: overhead summary shows retry pressure at ${dominantRetry.key}=${dominantRetry.value}$reasonSuffix in $relativeTracePath:1',
      );
    }

    final dominantPhase = _topCost(phaseCosts);
    if (dominantPhase != null) {
      lines.add(
        '- PASS: overhead summary shows highest observed phase cost at ${dominantPhase.key}=${dominantPhase.value.toStringAsFixed(3)}s in $relativeTracePath:1',
      );
    } else {
      final snapshotFile = File(p.join(_inquiryDir, 'metrics_snapshot.yaml'));
      final relativeSnapshotPath = '.inquiry/metrics_snapshot.yaml';
      if (snapshotFile.existsSync()) {
        lines.add(
          '- WARN: overhead summary found no phase_timing events yet; only cycle-start snapshot is available at $relativeSnapshotPath:1',
        );
      } else {
        lines.add(
          '- WARN: overhead summary could not attribute phase cost because both $relativeTracePath:1 and $relativeSnapshotPath:1 lack timing evidence',
        );
      }
    }

    final modelSummary = _modelSummary(
      modelInputTokens,
      modelPromptCharacters,
      modelAssemblyDurations,
    );
    if (modelSummary == null) {
      lines.add(
        '- WARN: overhead summary found no model-bound prompt surfaces before END in $relativeTracePath:1',
      );
    } else {
      lines.add(
        '- PASS: overhead summary estimates model-bound prompt input as [$modelSummary] in $relativeTracePath:1',
      );
    }

    final harnessEventCount = counts.entries
        .where(
          (entry) =>
              entry.key != 'tool_activity' && entry.key != 'model_activity',
        )
        .fold<int>(0, (sum, entry) => sum + entry.value);
    final hostSummary = toolClasses.isEmpty
        ? 'no host-boundary tool_activity events observed'
        : (() {
            final entries = toolClasses.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            return entries
                .map((entry) => '${entry.key}=${entry.value}')
                .join(', ');
          })();
    final totalAssemblySeconds = modelAssemblyDurations.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final assemblySuffix = totalAssemblySeconds > 0
        ? ' plus ${totalAssemblySeconds.toStringAsFixed(3)}s of local prompt assembly time'
        : '';
    if (modelSummary == null) {
      lines.add(
        '- WARN: overhead summary attributes host-boundary activity as [$hostSummary], harness control-path activity as $harnessEventCount trace events, and leaves model-bound plus remote model runtime/caching cost unattributed in local surfaces at $relativeTracePath:1',
      );
    } else {
      lines.add(
        '- WARN: overhead summary attributes host-boundary activity as [$hostSummary], harness control-path activity as $harnessEventCount trace events$assemblySuffix, and leaves only remote model runtime/caching cost unattributed in local surfaces at $relativeTracePath:1',
      );
    }

    return lines;
  }

  List<YamlMap> _loadRunTraceEvents(File traceFile) {
    try {
      final doc = loadYaml(traceFile.readAsStringSync());
      if (doc is! YamlMap) return const [];
      final events = doc['events'];
      if (events is! YamlList) return const [];
      return events.whereType<YamlMap>().toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  String _traceString(Object? value) => value?.toString().trim() ?? '';

  double? _traceDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(_traceString(value));
  }

  int? _traceInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(_traceString(value));
  }

  String? _modelSummary(
    Map<String, int> tokenEstimates,
    Map<String, int> promptCharacters,
    Map<String, double> assemblyDurations,
  ) {
    final labels = <String>{
      ...tokenEstimates.keys,
      ...promptCharacters.keys,
      ...assemblyDurations.keys,
    };
    if (labels.isEmpty) return null;

    final ordered = labels.toList()
      ..sort((a, b) {
        final tokenOrder =
            (tokenEstimates[b] ?? 0).compareTo(tokenEstimates[a] ?? 0);
        if (tokenOrder != 0) return tokenOrder;
        final charOrder =
            (promptCharacters[b] ?? 0).compareTo(promptCharacters[a] ?? 0);
        if (charOrder != 0) return charOrder;
        return a.compareTo(b);
      });

    return ordered.map((label) {
      final parts = <String>[];
      final tokens = tokenEstimates[label] ?? 0;
      final chars = promptCharacters[label] ?? 0;
      final assemblySeconds = assemblyDurations[label] ?? 0;

      if (tokens > 0) parts.add('$tokens est_tokens');
      if (chars > 0) parts.add('$chars chars');
      if (assemblySeconds > 0) {
        parts.add('${assemblySeconds.toStringAsFixed(3)}s assembly');
      }

      return '$label=${parts.join('/')}';
    }).join(', ');
  }

  MapEntry<String, int>? _topCount(Map<String, int> counts) {
    if (counts.isEmpty) return null;
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final countOrder = b.value.compareTo(a.value);
        if (countOrder != 0) return countOrder;
        return a.key.compareTo(b.key);
      });
    return entries.first;
  }

  MapEntry<String, double>? _topCost(Map<String, double> costs) {
    if (costs.isEmpty) return null;
    final entries = costs.entries.toList()
      ..sort((a, b) {
        final costOrder = b.value.compareTo(a.value);
        if (costOrder != 0) return costOrder;
        return a.key.compareTo(b.key);
      });
    return entries.first;
  }

  _InspectionReportMetadata _reportMetadata(String content) {
    final lines = content.replaceAll('\r\n', '\n').split('\n');
    return _InspectionReportMetadata(
      issue: _metadataField(lines, 'issue'),
      branch: _metadataField(lines, 'branch'),
    );
  }

  _InspectionMetadataField _metadataField(List<String> lines, String key) {
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index].trim();
      final prefix = '$key:';
      if (!line.startsWith(prefix)) continue;

      var value = line.substring(prefix.length).trim();
      if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
        value = value.substring(1, value.length - 1);
      }
      return _InspectionMetadataField(value: value, lineNumber: index + 1);
    }
    return const _InspectionMetadataField(value: null, lineNumber: null);
  }

  List<String> _sectionChecks(
    String content, {
    required List<String> startMarkers,
    required List<String> endMarkers,
    bool endAtEof = false,
  }) {
    final startMarker = _firstExistingMarker(content, startMarkers);
    final endMarker = _firstExistingMarker(content, endMarkers);
    if (startMarker == null) return const [];
    final start = content.indexOf(startMarker);
    final end = endMarker == null ? content.length : content.indexOf(endMarker);
    if (endMarker == null && !endAtEof) return const [];
    if (start == -1 || end == -1 || end <= start) return const [];

    final sectionContent = content.substring(start + startMarker.length, end);
    return sectionContent
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith('- '))
        .toList();
  }

  bool _isAutomaticTraceabilityCheck(String check) {
    return check.startsWith('- PASS: inspection metadata matches active issue ') ||
        check.startsWith('- FAIL: inspection issue metadata ') ||
        check.startsWith('- FAIL: inspection branch metadata ') ||
        check.startsWith(
          '- WARN: active issue missing in state; automatic traceability review degraded',
        ) ||
        check.startsWith('- PASS: overhead summary ') ||
        check.startsWith('- WARN: overhead summary ') ||
        check ==
            '- WARN: replace this placeholder with a concrete traceability finding before approval';
  }

  Set<String> _relativeFiles(String root) {
    return Directory(root)
        .listSync(recursive: true)
        .whereType<File>()
        .map(
          (file) => p
              .relative(file.path, from: root)
              .replaceAll('\\', '/')
              .trim(),
        )
        .toSet();
  }

  String? _firstExistingMarker(String content, List<String> markers) {
    for (final marker in markers) {
      if (content.contains(marker)) return marker;
    }
    return null;
  }

  int _firstDifferentLine(String sourceContent, String buildContent) {
    final sourceLines = sourceContent.replaceAll('\r\n', '\n').split('\n');
    final buildLines = buildContent.replaceAll('\r\n', '\n').split('\n');
    final maxLines = sourceLines.length > buildLines.length
        ? sourceLines.length
        : buildLines.length;
    for (var index = 0; index < maxLines; index++) {
      final sourceLine = index < sourceLines.length ? sourceLines[index] : null;
      final buildLine = index < buildLines.length ? buildLines[index] : null;
      if (sourceLine != buildLine) {
        return index + 1;
      }
    }
    return 1;
  }
}

final RegExp _uncheckedCheckboxPattern = RegExp(r'^\s*[-*]\s+\[ \]\s+');

final RegExp _checkedCheckboxPattern = RegExp(r'^\s*[-*]\s+\[[xX]\]\s+');

class _InspectionReportMetadata {
  final _InspectionMetadataField issue;
  final _InspectionMetadataField branch;

  const _InspectionReportMetadata({
    required this.issue,
    required this.branch,
  });
}

class _InspectionMetadataField {
  final String? value;
  final int? lineNumber;

  const _InspectionMetadataField({
    required this.value,
    required this.lineNumber,
  });
}