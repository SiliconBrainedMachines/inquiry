import 'package:test/test.dart';

import 'package:inquiry_cli/modules/specification/slug.dart';

void main() {
  group('normalizeSlug', () {
    test('a bare slug is unchanged', () {
      expect(normalizeSlug('ticket-purchase'), 'ticket-purchase');
    });

    test('strips a trailing path separator (tab-completion adds one)', () {
      expect(normalizeSlug('ticket-purchase/'), 'ticket-purchase');
      expect(normalizeSlug(r'ticket-purchase\'), 'ticket-purchase');
    });

    test('accepts a requisitions/<slug> path (so tab-completion works)', () {
      expect(normalizeSlug('requisitions/ticket-purchase'), 'ticket-purchase');
      expect(normalizeSlug(r'requisitions\ticket-purchase'), 'ticket-purchase');
    });

    test('accepts the Windows tab-completion form .\\requisitions\\<slug>\\', () {
      expect(
        normalizeSlug(r'.\requisitions\ticket-purchase\'),
        'ticket-purchase',
      );
    });

    test('accepts a leading ./ on a bare slug', () {
      expect(normalizeSlug('./ticket-purchase'), 'ticket-purchase');
    });

    test('extracts the slug when the path points inside the dir', () {
      expect(
        normalizeSlug('requisitions/ticket-purchase/specification.md'),
        'ticket-purchase',
      );
    });

    test('takes the last requisitions/ segment of an absolute-ish path', () {
      expect(
        normalizeSlug('C:/Users/x/impulsa/requisitions/ticket-purchase/'),
        'ticket-purchase',
      );
    });

    test('trims surrounding whitespace', () {
      expect(normalizeSlug('  ticket-purchase  '), 'ticket-purchase');
    });

    test('empty stays empty', () {
      expect(normalizeSlug(''), '');
    });
  });
}
