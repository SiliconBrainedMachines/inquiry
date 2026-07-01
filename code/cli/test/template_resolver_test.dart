import 'dart:io';

import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/templates/template_resolver.dart';

void main() {
  final resolver = TemplateResolver(Assets(root: Directory.current.path));

  group('TemplateResolver', () {
    test('localized artifact: es returns the Spanish template, no notice', () {
      final r = resolver.resolve('specification', lang: 'es');
      expect(r.content, contains('# Especificación'));
      expect(r.notice, isNull);
    });

    test('localized artifact: en (default) returns English, no notice', () {
      final r = resolver.resolve('specification');
      expect(r.content, contains('# Specification'));
      expect(r.notice, isNull);
    });

    test('localized artifact: an unsupported lang falls back to English + notice',
        () {
      final r = resolver.resolve('specification', lang: 'pt');
      expect(r.content, contains('# Specification'));
      expect(r.notice, contains('pt'));
      expect(r.notice, contains('English'));
    });

    test('English-only artifact: en returns the no-lang template, no notice', () {
      final r = resolver.resolve('plan', lang: 'en');
      expect(r.content, contains('# Plan'));
      expect(r.notice, isNull);
    });

    test('English-only artifact: a requested lang falls back to English + notice',
        () {
      final r = resolver.resolve('plan', lang: 'es');
      expect(r.content, contains('# Plan'));
      expect(r.notice, contains('es'));
    });

    test('unknown artifact throws', () {
      expect(() => resolver.resolve('bogus'), throwsArgumentError);
    });
  });
}
