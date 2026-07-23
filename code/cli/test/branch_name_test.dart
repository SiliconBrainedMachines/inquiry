import 'package:test/test.dart';

import 'package:inquiry_cli/modules/implementation/branch_name.dart';

void main() {
  group('deriveSlug', () {
    test('lowercases and hyphenates a simple title', () {
      expect(deriveSlug('Fix login timeout'), 'fix-login-timeout');
    });

    test('collapses punctuation and specials into single hyphens', () {
      expect(deriveSlug('Add dark mode support!!!'), 'add-dark-mode-support');
      expect(deriveSlug('URGENT: Database migration script'),
          'urgent-database-migration-script');
    });

    test('folds Spanish accents to ASCII instead of dropping them', () {
      expect(deriveSlug('incluir código grupal'), 'incluir-codigo-grupal');
      expect(deriveSlug('renovación del comité'), 'renovacion-del-comite');
    });

    test('strips a leading bracketed tag into a clean segment', () {
      expect(deriveSlug('[api] Recordatorio preventivo'),
          'api-recordatorio-preventivo');
    });

    test('caps at 50 chars without leaving a dangling hyphen', () {
      final slug = deriveSlug('a ' * 40); // many single-letter words
      expect(slug.length, lessThanOrEqualTo(50));
      expect(slug.endsWith('-'), isFalse);
    });

    test('returns empty when the title has no alphanumerics', () {
      expect(deriveSlug('!!! ---'), '');
    });
  });

  group('padIssueNumber', () {
    test('pads to three digits', () {
      expect(padIssueNumber('40'), '040');
      expect(padIssueNumber('7'), '007');
    });

    test('leaves 3+ digit numbers unchanged', () {
      expect(padIssueNumber('295'), '295');
      expect(padIssueNumber('1101'), '1101');
    });
  });

  group('branchNameFor', () {
    test('composes <NNN>-<slug>', () {
      expect(
        branchNameFor(issue: '40', title: 'Fix login timeout'),
        '040-fix-login-timeout',
      );
    });

    test('throws when the title yields no slug', () {
      expect(
        () => branchNameFor(issue: '40', title: '###'),
        throwsArgumentError,
      );
    });
  });
}
