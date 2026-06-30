import 'dart:io';

import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/modules/specification/specification_gate.dart';

/// A fully-filled specification that satisfies every rule.
const _filledSpec = '''
# Requirement Specification

## Metadata

| Field | Value |
| ----- | ----- |
| ID    | REQ-2026-06-30-001 |
| Date  | 2026-06-30 |

## 1. User Stories

### US-1: Register an invoice

**As a** billing analyst,
**I want** to register an invoice through a form,
**So that** records are never lost.

#### Acceptance Criteria

| #    | Given (context)        | When (action)     | Then (expected result) |
| ---- | ---------------------- | ----------------- | ---------------------- |
| AC-1 | the form is open       | I submit valid data | the invoice is stored |
| AC-2 | a duplicate number     | I submit it       | it is rejected         |

## 2. Testing Strategy

| Type | What it must validate | Related AC |
| ---- | --------------------- | ---------- |
| Unit | the no-duplicate rule | AC-2       |

## 3. Explicit Scope

### Includes

- Invoice registration form with no-duplicate validation.

### Does NOT include

- Invoice approval workflow.

## 4. Decisions (evidence)

- **Decision**: store invoices in the existing `billing` table. **Evidence**: `psql -c "\\d billing"` shows the columns already exist (run 2026-06-30).

## Annexes
''';

void main() {
  final gate = SpecificationGate();

  group('SpecificationGate', () {
    test('the unfilled scaffold (template) is rejected with violations', () {
      final template =
          Assets(root: Directory.current.path)
              .loadString('artifacts/specification.template.en.md')
              .replaceAll('{{DATE}}', '2026-06-30');

      final r = gate.evaluate(template, issueFiles: const []);
      expect(r.passed, isFalse);
      // Many things are unfilled — at minimum the AC, scope, decision, issue.
      expect(r.violations, isNotEmpty);
    });

    test('a fully-filled spec with one issue passes', () {
      final r = gate.evaluate(_filledSpec, issueFiles: const ['issue-x.md']);
      expect(r.passed, isTrue, reason: r.violations.join('\n'));
      expect(r.violations, isEmpty);
    });

    test('no derived issue → SPEC_NO_ISSUE', () {
      final r = gate.evaluate(_filledSpec, issueFiles: const []);
      expect(r.passed, isFalse);
      expect(r.violations.map((v) => v.code), contains('SPEC_NO_ISSUE'));
    });

    test('a user story with no acceptance criterion → SPEC_STORY_MISSING_AC', () {
      final noAc = _filledSpec.replaceAll(
        RegExp(r'\| AC-\d+ .*\n'),
        '',
      );
      final r = gate.evaluate(noAc, issueFiles: const ['issue-x.md']);
      expect(r.violations.map((v) => v.code), contains('SPEC_STORY_MISSING_AC'));
    });

    test('an empty scope half → SPEC_SCOPE_INCOMPLETE', () {
      final noExcludes = _filledSpec.replaceAll(
        '- Invoice approval workflow.',
        '<!-- what is explicitly out of scope -->',
      );
      final r = gate.evaluate(noExcludes, issueFiles: const ['issue-x.md']);
      expect(r.violations.map((v) => v.code), contains('SPEC_SCOPE_INCOMPLETE'));
    });

    test('a decision without evidence → SPEC_DECISION_EVIDENCE_MISSING', () {
      final noEvidence = _filledSpec.replaceAll(
        RegExp(r'\*\*Evidence\*\*:.*'),
        '**Evidence**: <!-- experiment + result -->.',
      );
      final r = gate.evaluate(noEvidence, issueFiles: const ['issue-x.md']);
      expect(r.violations.map((v) => v.code),
          contains('SPEC_DECISION_EVIDENCE_MISSING'));
    });

    test('no user story at all → SPEC_NO_USER_STORY', () {
      const empty = '# Requirement Specification\n\n## 1. User Stories\n';
      final r = gate.evaluate(empty, issueFiles: const ['issue-x.md']);
      expect(r.violations.map((v) => v.code), contains('SPEC_NO_USER_STORY'));
    });

    test('missing testing strategy rows → SPEC_NO_TESTING_STRATEGY', () {
      final noStrategy = _filledSpec.replaceAll(
        '| Unit | the no-duplicate rule | AC-2       |',
        '| Unit | <!-- e.g. field validation --> | AC-2 |',
      );
      final r = gate.evaluate(noStrategy, issueFiles: const ['issue-x.md']);
      expect(r.violations.map((v) => v.code),
          contains('SPEC_NO_TESTING_STRATEGY'));
    });
  });
}
