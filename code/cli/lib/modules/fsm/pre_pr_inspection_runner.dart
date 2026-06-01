library;

import 'dart:io';

import 'package:path/path.dart' as p;

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

  void _rewriteSection(
    File file, {
    required List<String> startMarkers,
    required List<String> endMarkers,
    required List<String> checks,
  }) {
    final content = file.readAsStringSync().replaceAll('\r\n', '\n');
    final startMarker = _firstExistingMarker(content, startMarkers);
    final endMarker = _firstExistingMarker(content, endMarkers);
    if (startMarker == null || endMarker == null) return;
    final start = content.indexOf(startMarker);
    final end = content.indexOf(endMarker);
    if (start == -1 || end == -1 || end <= start) return;

    final before = content.substring(0, start + startMarker.length);
    final after = content.substring(end);
    final updated = StringBuffer()
      ..write(before)
      ..write('\n')
      ..writeAll(checks.map((line) => '$line\n'))
      ..write('\n')
      ..write(after);
    file.writeAsStringSync(updated.toString().trimRight() + '\n');
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