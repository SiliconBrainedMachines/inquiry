/// The `specification_ready` gate — the CLI's check that a `specification.md`
/// is healthy, coherent, and actionable before it leaves the QA phase.
///
/// The specification phase is outside the dev FSM, so this gate is not an
/// `iq fsm transition` event; it is run by `iq specification check <slug>`. The
/// rules mirror the locked design: each user story carries ≥1 Given-When-Then
/// acceptance criterion; the testing strategy and explicit scope are filled; at
/// least one decision cites evidence; and at least one issue is derived.
library;

/// One failed rule, with a stable [code] (mirrors the dev-cycle gate codes such
/// as `DIAGNOSIS_EVIDENCE_MISSING`) and a human-readable [message].
class SpecificationViolation {
  final String code;
  final String message;

  const SpecificationViolation(this.code, this.message);

  @override
  String toString() => '$code: $message';
}

class SpecificationGateResult {
  final List<SpecificationViolation> violations;

  const SpecificationGateResult(this.violations);

  bool get passed => violations.isEmpty;
}

class SpecificationGate {
  /// Evaluates [specificationMd] (the file content) plus the [issues] derived
  /// for the slug — the **contents** of each `issue-<slug>.md`, so the gate can
  /// verify that every acceptance criterion is traced to an issue (the QA→Dev
  /// handoff: AC → issue).
  SpecificationGateResult evaluate(
    String specificationMd, {
    required List<String> issues,
  }) {
    final violations = <SpecificationViolation>[];
    final sections = _splitSections(specificationMd);

    _checkUserStories(sections, violations);
    _checkTestingStrategy(sections, violations);
    _checkScope(sections, violations);
    _checkDecisions(sections, violations);

    final realIssues = issues.where((i) => i.trim().isNotEmpty).toList();
    if (realIssues.isEmpty) {
      violations.add(const SpecificationViolation(
        'SPEC_NO_ISSUE',
        'No issue derived — create at least one issue-<slug>.md tracing to the '
            'acceptance criteria.',
      ));
    } else {
      _checkAcTraceability(sections, realIssues, violations);
    }

    return SpecificationGateResult(violations);
  }

  // ─── Rules ──────────────────────────────────────────────────────────────

  void _checkUserStories(
    Map<String, String> sections,
    List<SpecificationViolation> violations,
  ) {
    final body = _sectionStartingWith(sections, '1. User Stories');
    if (body == null) {
      violations.add(const SpecificationViolation(
        'SPEC_NO_USER_STORY', 'No "User Stories" section found.'));
      return;
    }

    final stories = _splitStories(body);
    if (stories.isEmpty) {
      violations.add(const SpecificationViolation(
        'SPEC_NO_USER_STORY',
        'No user story is filled — add at least one US-N with As a / I want / '
            'So that.',
      ));
      return;
    }

    for (final story in stories) {
      if (_acRows(story.body).isEmpty) {
        violations.add(SpecificationViolation(
          'SPEC_STORY_MISSING_AC',
          'User story "${story.title}" has no filled Given-When-Then '
              'acceptance criterion.',
        ));
      }
    }
  }

  void _checkTestingStrategy(
    Map<String, String> sections,
    List<SpecificationViolation> violations,
  ) {
    final body = _sectionStartingWith(sections, '2. Testing Strategy');
    final hasFilledRow = body != null &&
        _tableDataRows(body).any((cells) =>
            cells.length >= 2 && _isFilled(cells[1]));
    if (!hasFilledRow) {
      violations.add(const SpecificationViolation(
        'SPEC_NO_TESTING_STRATEGY',
        'Testing strategy has no filled row — state at least one test type and '
            'what it must validate.',
      ));
    }
  }

  void _checkScope(
    Map<String, String> sections,
    List<SpecificationViolation> violations,
  ) {
    final body = _sectionStartingWith(sections, '3. Explicit Scope');
    final includes = body == null ? false : _hasFilledBullet(body, 'Includes');
    final excludes =
        body == null ? false : _hasFilledBullet(body, 'Does NOT include');
    if (!includes || !excludes) {
      violations.add(const SpecificationViolation(
        'SPEC_SCOPE_INCOMPLETE',
        'Explicit scope is incomplete — both "Includes" and "Does NOT include" '
            'need at least one real bullet.',
      ));
    }
  }

  void _checkDecisions(
    Map<String, String> sections,
    List<SpecificationViolation> violations,
  ) {
    final body = _sectionStartingWith(sections, '4. Decisions');
    final hasEvidence = body != null &&
        body.split('\n').any((line) {
          if (!line.contains('**Decision**') ||
              !line.contains('**Evidence**')) {
            return false;
          }
          final decision = _valueAfter(line, '**Decision**');
          final evidence = _valueAfter(line, '**Evidence**');
          return _isFilled(decision) && _isFilled(evidence);
        });
    if (!hasEvidence) {
      violations.add(const SpecificationViolation(
        'SPEC_DECISION_EVIDENCE_MISSING',
        'No decision cites evidence — at least one Decisions (evidence) bullet '
            'must carry a filled Decision and Evidence (an experiment handle).',
      ));
    }
  }

  /// Every filled AC declared in the User Stories must be referenced by at least
  /// one derived issue — the AC → issue link of the traceability spine. An AC
  /// `AC-N` is "traced" when the token `AC-N` appears in some issue body.
  void _checkAcTraceability(
    Map<String, String> sections,
    List<String> issues,
    List<SpecificationViolation> violations,
  ) {
    final body = _sectionStartingWith(sections, '1. User Stories');
    if (body == null) return;

    final declared = <String>{};
    for (final story in _splitStories(body)) {
      for (final row in _acRows(story.body)) {
        declared.add(row.first); // the AC-id cell, e.g. "AC-1"
      }
    }

    for (final ac in declared) {
      final token = RegExp('\\b${RegExp.escape(ac)}\\b', caseSensitive: false);
      final traced = issues.any((issue) => token.hasMatch(issue));
      if (!traced) {
        violations.add(SpecificationViolation(
          'SPEC_AC_NOT_TRACED',
          '$ac is declared in specification.md but no derived issue references '
              'it — every acceptance criterion must trace to an issue.',
        ));
      }
    }
  }

  // ─── Parsing helpers ──────────────────────────────────────────────────────

  /// Splits the doc into `## ` sections, keyed by the trimmed header text.
  Map<String, String> _splitSections(String md) {
    final sections = <String, String>{};
    String? current;
    final buffer = StringBuffer();
    void flush() {
      final c = current;
      if (c != null) sections[c] = buffer.toString();
      buffer.clear();
    }

    for (final line in md.split('\n')) {
      if (line.startsWith('## ')) {
        flush();
        current = line.substring(3).trim();
      } else if (current != null) {
        buffer.writeln(line);
      }
    }
    flush();
    return sections;
  }

  String? _sectionStartingWith(Map<String, String> sections, String prefix) {
    for (final entry in sections.entries) {
      if (entry.key.startsWith(prefix)) return entry.value;
    }
    return null;
  }

  /// Splits a User Stories body into `### US-` blocks that are actually filled
  /// (As a / I want / So that all have content).
  List<({String title, String body})> _splitStories(String body) {
    final stories = <({String title, String body})>[];
    final lines = body.split('\n');
    String? title;
    final buffer = StringBuffer();
    void flush() {
      final t = title;
      if (t == null) return;
      final block = buffer.toString();
      if (_storyIsFilled(t, block)) {
        stories.add((title: t, body: block));
      }
      buffer.clear();
    }

    for (final line in lines) {
      if (line.startsWith('### ')) {
        flush();
        title = line.substring(4).trim();
      } else if (title != null) {
        buffer.writeln(line);
      }
    }
    flush();
    return stories;
  }

  bool _storyIsFilled(String title, String block) {
    // The title after "US-N:" must be real, and the three role lines filled.
    final titleValue = title.contains(':')
        ? title.substring(title.indexOf(':') + 1).trim()
        : title;
    if (!_isFilled(titleValue)) return false;
    for (final marker in const ['**As a**', '**I want**', '**So that**']) {
      final line = block
          .split('\n')
          .firstWhere((l) => l.contains(marker), orElse: () => '');
      if (line.isEmpty || !_isFilled(_valueAfter(line, marker))) return false;
    }
    return true;
  }

  /// Filled acceptance-criteria rows in a block: `| AC-N | given | when | then |`
  /// with all three cells filled.
  List<List<String>> _acRows(String block) {
    final rows = <List<String>>[];
    for (final line in block.split('\n')) {
      if (!RegExp(r'^\s*\|\s*AC-\d+', caseSensitive: false).hasMatch(line)) {
        continue;
      }
      final cells = _cells(line);
      // cells: [AC-N, given, when, then]
      if (cells.length >= 4 &&
          _isFilled(cells[1]) &&
          _isFilled(cells[2]) &&
          _isFilled(cells[3])) {
        rows.add(cells);
      }
    }
    return rows;
  }

  /// Data rows of any markdown table in [block] (skips header + separator).
  List<List<String>> _tableDataRows(String block) {
    final rows = <List<String>>[];
    for (final line in block.split('\n')) {
      final t = line.trim();
      if (!t.startsWith('|')) continue;
      if (RegExp(r'^\|[\s\-:|]+\|?$').hasMatch(t)) continue; // separator
      final cells = _cells(line);
      if (cells.isEmpty) continue;
      // Skip the header row (first cell is a known column label).
      final first = cells.first.toLowerCase();
      if (first == 'type' || first == '#' || first == 'field') continue;
      rows.add(cells);
    }
    return rows;
  }

  bool _hasFilledBullet(String scopeBody, String subheading) {
    final lines = scopeBody.split('\n');
    var inSub = false;
    for (final line in lines) {
      if (line.startsWith('### ')) {
        inSub = line.substring(4).trim().startsWith(subheading);
        continue;
      }
      if (inSub && line.trimLeft().startsWith('- ')) {
        final value = line.trimLeft().substring(2);
        if (_isFilled(value)) return true;
      }
    }
    return false;
  }

  List<String> _cells(String row) => row
      .trim()
      .replaceAll(RegExp(r'^\||\|$'), '')
      .split('|')
      .map((c) => c.trim())
      .toList();

  String _valueAfter(String line, String marker) {
    final i = line.indexOf(marker);
    if (i < 0) return '';
    var rest = line.substring(i + marker.length);
    if (rest.startsWith(':')) rest = rest.substring(1);
    // Stop at the next bold marker on the same line (e.g. **Evidence**).
    final next = rest.indexOf('**');
    if (next >= 0) rest = rest.substring(0, next);
    return rest;
  }

  /// A value is "filled" when, after removing HTML comments and trailing
  /// punctuation/whitespace, something real remains.
  bool _isFilled(String value) {
    final stripped = value
        .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '')
        .replaceAll(RegExp(r'[.\s]+$'), '')
        .trim();
    return stripped.isNotEmpty;
  }
}
