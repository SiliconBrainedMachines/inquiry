/// The `specification_ready` gate — the CLI's check that a `specification.md`
/// is healthy, coherent, and actionable before it leaves the QA phase.
///
/// The specification phase is outside the dev FSM, so this gate is not an
/// `iq fsm transition` event; it is run by `iq specification check <slug>`. The
/// rules mirror the locked design: each user story carries ≥1 Given-When-Then
/// acceptance criterion; the testing strategy and explicit scope are filled; at
/// least one decision cites evidence; and at least one issue is derived.
library;

import '../issue/front_matter.dart';

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

    _checkCommitmentDate(sections, violations);
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

  /// §1 must carry a committed delivery date — an ISO `YYYY-MM-DD` — so scope
  /// and schedule are both first-class. A mini-schedule (milestones + dates) is
  /// welcome; it just has to contain at least one real date.
  void _checkCommitmentDate(
    Map<String, String> sections,
    List<SpecificationViolation> violations,
  ) {
    final body = _section(sections, 1);
    final stripped = body == null
        ? ''
        : body.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    if (!RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(stripped)) {
      violations.add(const SpecificationViolation(
        'SPEC_NO_COMMITMENT_DATE',
        'No committed delivery date — section "1. Commitment date" needs a real '
            'ISO date (YYYY-MM-DD).',
      ));
    }
  }

  void _checkUserStories(
    Map<String, String> sections,
    List<SpecificationViolation> violations,
  ) {
    final body = _section(sections, 2);
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
    final body = _section(sections, 3);
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
    final body = _section(sections, 4);
    final includes =
        body == null ? false : _hasFilledBullet(body, _includesHeadings);
    final excludes =
        body == null ? false : _hasFilledBullet(body, _excludesHeadings);
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
    final body = _section(sections, 5);
    final hasEvidence = body != null &&
        body.split('\n').any((line) {
          final decision = _valueAfterAnyMarker(line, _decisionMarkers);
          final evidence = _valueAfterAnyMarker(line, _evidenceMarkers);
          return decision != null &&
              evidence != null &&
              _isFilled(decision) &&
              _isFilled(evidence);
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
  /// one derived issue — the AC → issue link of the traceability spine. For an
  /// "issue as code" file (with `---` front-matter) the trace comes from its
  /// declared `covers:` list — the canonical, machine-readable source — so prose
  /// or template examples in the body never trace falsely. A freehand issue (no
  /// front-matter) falls back to a raw-text scan.
  void _checkAcTraceability(
    Map<String, String> sections,
    List<String> issues,
    List<SpecificationViolation> violations,
  ) {
    final body = _section(sections, 2);
    if (body == null) return;

    final declared = <String>{};
    for (final story in _splitStories(body)) {
      declared.addAll(_acRows(story.body)); // canonical AC-N ids
    }

    final traceTexts = issues.map((issue) {
      final doc = parseIssueDoc(issue);
      return doc != null ? doc.covers.join(' ') : issue;
    }).toList();

    for (final ac in declared) {
      final token = RegExp('\\b${RegExp.escape(ac)}\\b', caseSensitive: false);
      final traced = traceTexts.any((t) => token.hasMatch(t));
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

  /// Looks up a section by its leading number (`## 1. …`). The templates number
  /// the sections identically in every language (`1.` Commitment date / Fecha de
  /// compromiso, `2.` User Stories / Historias de Usuario, `3.` Testing Strategy
  /// / Estrategia de Testing, `4.` Scope, `5.` Decisions), so this is
  /// language-agnostic — the gate works on `--lang es` specs too.
  String? _section(Map<String, String> sections, int number) {
    for (final entry in sections.entries) {
      if (entry.key.startsWith('$number.')) return entry.value;
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
    // Role keywords are English in both templates (the es template embeds them:
    // `**As a (Como)**`), so matching the English keyword finds the line in
    // either language; the value is whatever follows the bold label.
    for (final keyword in const ['As a', 'I want', 'So that']) {
      final line = block
          .split('\n')
          .firstWhere((l) => l.contains('**') && l.contains(keyword),
              orElse: () => '');
      if (line.isEmpty || !_isFilled(_valueAfterBold(line))) return false;
    }
    return true;
  }

  /// The canonical AC ids of the **filled** acceptance-criteria rows in [block]
  /// (`| id | given | when | then |` with the three cells filled). The id cell
  /// is read in either form — inline `AC-3`, or a bare number `3` under an "AC"
  /// column header — and normalized to `AC-3`, so the rendered table can use the
  /// short numeric form (which survives a narrow PDF column) without breaking
  /// traceability.
  List<String> _acRows(String block) {
    final ids = <String>[];
    for (final line in block.split('\n')) {
      if (!line.trimLeft().startsWith('|')) continue;
      final cells = _cells(line);
      if (cells.length < 4) continue;
      final id = _acId(cells[0]);
      if (id == null) continue; // header / separator / non-AC row
      if (_isFilled(cells[1]) && _isFilled(cells[2]) && _isFilled(cells[3])) {
        ids.add(id);
      }
    }
    return ids;
  }

  /// Normalizes an AC-id cell to its canonical `AC-N` form: `AC-3` → `AC-3`,
  /// `3` → `AC-3`. Returns null for headers, separators, or other cells.
  String? _acId(String cell) {
    final inline = RegExp(r'^AC-(\d+)$', caseSensitive: false).firstMatch(cell);
    if (inline != null) return 'AC-${inline.group(1)}';
    final numeric = RegExp(r'^(\d+)$').firstMatch(cell);
    if (numeric != null) return 'AC-${numeric.group(1)}';
    return null;
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
      // Skip the header row (first cell is a known column label, en or es).
      final first = cells.first.toLowerCase();
      if (const {'type', 'tipo', '#', 'field', 'campo'}.contains(first)) {
        continue;
      }
      rows.add(cells);
    }
    return rows;
  }

  bool _hasFilledBullet(String scopeBody, List<String> subheadings) {
    final lines = scopeBody.split('\n');
    var inSub = false;
    for (final line in lines) {
      if (line.startsWith('### ')) {
        final heading = line.substring(4).trim();
        inSub = subheadings.any((s) => heading.startsWith(s));
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

  /// The text after the first `**…**` bold span on [line] (a role label such as
  /// `**As a**` / `**As a (Como)**`), up to the next bold span. Language-neutral.
  String _valueAfterBold(String line) {
    final open = line.indexOf('**');
    if (open < 0) return '';
    final close = line.indexOf('**', open + 2);
    if (close < 0) return '';
    var rest = line.substring(close + 2);
    if (rest.startsWith(':')) rest = rest.substring(1);
    final next = rest.indexOf('**');
    if (next >= 0) rest = rest.substring(0, next);
    return rest;
  }

  /// The value after the first matching bold [markers] label (e.g. `**Decision**`
  /// or `**Decisión**`), stopping at the next bold span. Returns null when no
  /// marker is present on the line.
  String? _valueAfterAnyMarker(String line, List<String> markers) {
    for (final marker in markers) {
      final token = '**$marker**';
      final i = line.indexOf(token);
      if (i < 0) continue;
      var rest = line.substring(i + token.length);
      if (rest.startsWith(':')) rest = rest.substring(1);
      final next = rest.indexOf('**');
      if (next >= 0) rest = rest.substring(0, next);
      return rest;
    }
    return null;
  }

  // Bilingual headings/markers (en + es) the templates ship.
  static const _includesHeadings = ['Includes', 'Incluye'];
  static const _excludesHeadings = ['Does NOT include', 'NO incluye'];
  static const _decisionMarkers = ['Decision', 'Decisión'];
  static const _evidenceMarkers = ['Evidence', 'Evidencia'];

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
