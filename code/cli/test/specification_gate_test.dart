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

## 1. Commitment date

| Milestone          | Date       |
| ------------------ | ---------- |
| Committed delivery | 2026-08-15 |

## 2. User Stories

### US-1: Register an invoice

**As a** billing analyst,
**I want** to register an invoice through a form,
**So that** records are never lost.

#### Acceptance Criteria

| #    | Given (context)        | When (action)     | Then (expected result) |
| ---- | ---------------------- | ----------------- | ---------------------- |
| AC-1 | the form is open       | I submit valid data | the invoice is stored |
| AC-2 | a duplicate number     | I submit it       | it is rejected         |

## 3. Testing Strategy

| Type | What it must validate | Related AC |
| ---- | --------------------- | ---------- |
| Unit | the no-duplicate rule | AC-2       |

## 4. Explicit Scope

### Includes

- Invoice registration form with no-duplicate validation.

### Does NOT include

- Invoice approval workflow.

## 5. Decisions (evidence)

- **Decision**: store invoices in the existing `billing` table. **Evidence**: `psql -c "\\d billing"` shows the columns already exist (run 2026-06-30).

## Annexes
''';

/// A fully-filled Spanish (`--lang es`) specification — the gate must accept it
/// (section headers, scope subheadings and Decision/Evidence markers are all in
/// Spanish). Regression for the dogfood finding that the gate was English-only.
const _filledSpecEs = '''
# Especificación de Requerimiento

## Metadatos

| Campo | Valor |
| ----- | ----- |
| ID    | REQ-2026-06-30-001 |

## 1. Fecha de compromiso

| Hito                 | Fecha      |
| -------------------- | ---------- |
| Entrega comprometida | 2026-08-15 |

## 2. Historias de Usuario

### HU-1: Registrar una factura

**As a (Como)** analista de facturación,
**I want (Quiero)** registrar una factura desde un formulario,
**So that (Para)** no se pierdan registros.

#### Acceptance Criteria

| #    | Given (Dado que)   | When (Cuando)        | Then (Entonces)        |
| ---- | ------------------ | -------------------- | ---------------------- |
| AC-1 | el formulario abre | envío datos válidos  | la factura se almacena |

## 3. Estrategia de Testing

| Tipo | Qué debe validar          | AC asociados |
| ---- | ------------------------- | ------------ |
| Unit | la regla de no-duplicados | AC-1         |

## 4. Alcance Explícito

### Incluye

- Formulario de registro de facturas.

### NO incluye

- El flujo de aprobación de facturas.

## 5. Decisiones (evidencia)

- **Decisión**: reusar la tabla `billing`. **Evidencia**: `psql -c "\\d billing"` muestra las columnas (corrido 2026-06-30).

## Anexos
''';

void main() {
  final gate = SpecificationGate();

  group('SpecificationGate', () {
    // An issue body that traces both ACs of _filledSpec (AC-1, AC-2).
    const tracingIssues = ['# Issue\n\nCovers AC-1 and AC-2.\n'];

    test('the unfilled scaffold (template) is rejected with violations', () {
      final template =
          Assets(root: Directory.current.path)
              .loadString('artifacts/specification.template.en.md')
              .replaceAll('{{DATE}}', '2026-06-30');

      final r = gate.evaluate(template, issues: const []);
      expect(r.passed, isFalse);
      // Many things are unfilled — at minimum the AC, scope, decision, issue.
      expect(r.violations, isNotEmpty);
    });

    test('a fully-filled spec with one tracing issue passes', () {
      final r = gate.evaluate(_filledSpec, issues: tracingIssues);
      expect(r.passed, isTrue, reason: r.violations.join('\n'));
      expect(r.violations, isEmpty);
    });

    test('a fully-filled Spanish (--lang es) spec passes (bilingual gate)', () {
      final r = gate.evaluate(_filledSpecEs, issues: const ['Cubre AC-1.']);
      expect(r.passed, isTrue, reason: r.violations.join('\n'));
      expect(r.violations, isEmpty);
    });

    test('numeric AC column (header "AC", cell "1") is read as AC-1', () {
      // The rendered table uses a short numeric id cell so a narrow PDF column
      // does not wrap "AC-1" character by character; the gate reconstructs AC-1.
      final numericAc = _filledSpec.replaceAll('| AC-1 |', '| 1    |').replaceAll(
            '| # ',
            '| AC ',
          );
      final r = gate.evaluate(numericAc, issues: const ['traces AC-1 and AC-2']);
      expect(r.violations.map((v) => v.code),
          isNot(contains('SPEC_STORY_MISSING_AC')));
      // AC-1 (now cell "1") must still be traceable as "AC-1".
      final notTraced = gate.evaluate(numericAc, issues: const ['only AC-2 here']);
      expect(notTraced.violations.map((v) => v.code),
          contains('SPEC_AC_NOT_TRACED'));
    });

    test('no derived issue → SPEC_NO_ISSUE', () {
      final r = gate.evaluate(_filledSpec, issues: const []);
      expect(r.passed, isFalse);
      expect(r.violations.map((v) => v.code), contains('SPEC_NO_ISSUE'));
    });

    test('an AC referenced by no issue → SPEC_AC_NOT_TRACED', () {
      // Issue traces AC-1 only; AC-2 is left untraced.
      final r = gate.evaluate(_filledSpec, issues: const ['Covers AC-1.']);
      final traced = r.violations.where((v) => v.code == 'SPEC_AC_NOT_TRACED');
      expect(traced, isNotEmpty);
      expect(traced.first.message, contains('AC-2'));
    });

    test('every AC traced by some issue → no SPEC_AC_NOT_TRACED', () {
      final r = gate.evaluate(_filledSpec, issues: tracingIssues);
      expect(r.violations.map((v) => v.code),
          isNot(contains('SPEC_AC_NOT_TRACED')));
    });

    test('a user story with no acceptance criterion → SPEC_STORY_MISSING_AC', () {
      final noAc = _filledSpec.replaceAll(
        RegExp(r'\| AC-\d+ .*\n'),
        '',
      );
      final r = gate.evaluate(noAc, issues: tracingIssues);
      expect(r.violations.map((v) => v.code), contains('SPEC_STORY_MISSING_AC'));
    });

    test('an empty scope half → SPEC_SCOPE_INCOMPLETE', () {
      final noExcludes = _filledSpec.replaceAll(
        '- Invoice approval workflow.',
        '<!-- what is explicitly out of scope -->',
      );
      final r = gate.evaluate(noExcludes, issues: tracingIssues);
      expect(r.violations.map((v) => v.code), contains('SPEC_SCOPE_INCOMPLETE'));
    });

    test('a decision without evidence → SPEC_DECISION_EVIDENCE_MISSING', () {
      final noEvidence = _filledSpec.replaceAll(
        RegExp(r'\*\*Evidence\*\*:.*'),
        '**Evidence**: <!-- experiment + result -->.',
      );
      final r = gate.evaluate(noEvidence, issues: tracingIssues);
      expect(r.violations.map((v) => v.code),
          contains('SPEC_DECISION_EVIDENCE_MISSING'));
    });

    test('no user story at all → SPEC_NO_USER_STORY', () {
      const empty = '# Specification\n\n## 2. User Stories\n';
      final r = gate.evaluate(empty, issues: const ['issue']);
      expect(r.violations.map((v) => v.code), contains('SPEC_NO_USER_STORY'));
    });

    test('no committed delivery date → SPEC_NO_COMMITMENT_DATE', () {
      // Strip the ISO date from §1 (leave the section, remove the real date).
      final noDate = _filledSpec.replaceAll('2026-08-15', '<!-- YYYY-MM-DD -->');
      final r = gate.evaluate(noDate, issues: tracingIssues);
      expect(r.passed, isFalse);
      expect(r.violations.map((v) => v.code),
          contains('SPEC_NO_COMMITMENT_DATE'));
    });

    test('a committed delivery date in §1 → no SPEC_NO_COMMITMENT_DATE', () {
      final r = gate.evaluate(_filledSpec, issues: tracingIssues);
      expect(r.violations.map((v) => v.code),
          isNot(contains('SPEC_NO_COMMITMENT_DATE')));
    });

    test('missing testing strategy rows → SPEC_NO_TESTING_STRATEGY', () {
      final noStrategy = _filledSpec.replaceAll(
        '| Unit | the no-duplicate rule | AC-2       |',
        '| Unit | <!-- e.g. field validation --> | AC-2 |',
      );
      final r = gate.evaluate(noStrategy, issues: tracingIssues);
      expect(r.violations.map((v) => v.code),
          contains('SPEC_NO_TESTING_STRATEGY'));
    });
  });
}
