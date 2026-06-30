import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/modules/specification/commands/check.dart';

const _filledSpec = '''
# Requirement Specification

## 1. User Stories

### US-1: Register an invoice

**As a** billing analyst,
**I want** to register an invoice,
**So that** records are never lost.

#### Acceptance Criteria

| #    | Given            | When           | Then            |
| ---- | ---------------- | -------------- | --------------- |
| AC-1 | the form is open | I submit data  | it is stored    |

## 2. Testing Strategy

| Type | What it must validate | Related AC |
| ---- | --------------------- | ---------- |
| Unit | the no-duplicate rule | AC-1       |

## 3. Explicit Scope

### Includes

- The registration form.

### Does NOT include

- The approval workflow.

## 4. Decisions (evidence)

- **Decision**: reuse the billing table. **Evidence**: `psql -c "\\d billing"` (run 2026-06-30).
''';

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('iq_spec_check_'));
  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  void writeSpec(String slug, String content) {
    final f = File(p.join(tempDir.path, 'requisitions', slug, 'specification.md'));
    f.createSync(recursive: true);
    f.writeAsStringSync(content);
  }

  void writeIssue(String slug, String name, {String covers = 'AC-1'}) {
    File(p.join(tempDir.path, 'requisitions', slug, name))
      ..createSync(recursive: true)
      ..writeAsStringSync('# issue\n\nCovers $covers.\n');
  }

  SpecificationCheckCommand cmd(String slug) => SpecificationCheckCommand(
        SpecificationCheckInput(slug: slug),
        workingDirectory: tempDir.path,
      );

  group('SpecificationCheckCommand', () {
    test('passes (exit 0) for a filled spec with an issue', () async {
      writeSpec('ok', _filledSpec);
      writeIssue('ok', 'issue-ok.md');

      final out = await cmd('ok').execute();
      expect(out.exitCode, 0);
      expect(out.message.toLowerCase(), contains('ready'));
    });

    test('fails (non-zero) and lists violation codes for an incomplete spec',
        () async {
      writeSpec('bad', _filledSpec); // no issue derived

      final out = await cmd('bad').execute();
      expect(out.exitCode, isNot(0));
      expect(out.message, contains('SPEC_NO_ISSUE'));
    });

    test('validate fails when the specification.md is missing', () {
      expect(cmd('ghost').validate(), isNotNull);
    });

    test('issue-<slug>.md files are discovered as derived issues', () async {
      writeSpec('disc', _filledSpec);
      writeIssue('disc', 'issue-disc.md');
      final out = await cmd('disc').execute();
      expect(out.exitCode, 0);
    });

    test('an issue that does not reference the AC → SPEC_AC_NOT_TRACED',
        () async {
      writeSpec('trace', _filledSpec); // declares AC-1
      writeIssue('trace', 'issue-trace.md', covers: 'nothing');
      final out = await cmd('trace').execute();
      expect(out.exitCode, isNot(0));
      expect(out.message, contains('SPEC_AC_NOT_TRACED'));
    });
  });
}
