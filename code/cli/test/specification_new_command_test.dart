import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/templates/template_resolver.dart';
import 'package:inquiry_cli/modules/specification/commands/new.dart';

void main() {
  // Real templates ship under the repo's assets/ (Directory.current is code/cli).
  final resolver = TemplateResolver(Assets(root: Directory.current.path));

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('iq_spec_new_');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  SpecificationNewCommand cmd(String slug, {String lang = 'en'}) =>
      SpecificationNewCommand(
        SpecificationNewInput(slug: slug, lang: lang),
        resolver: resolver,
        workingDirectory: tempDir.path,
      );

  String read(String slug, String artifact) => File(
        p.join(tempDir.path, 'requisitions', slug, '$artifact.md'),
      ).readAsStringSync();

  group('SpecificationNewCommand', () {
    test('scaffolds requisitions/<slug>/ with requisition.md + specification.md',
        () async {
      await cmd('invoice-form').execute();

      final dir = Directory(p.join(tempDir.path, 'requisitions', 'invoice-form'));
      expect(dir.existsSync(), isTrue);
      expect(read('invoice-form', 'requisition'), contains('# Requisition'));
      expect(
        read('invoice-form', 'specification'),
        contains('Requirement Specification'),
      );
    });

    test('replaces the {{DATE}} placeholder with today (ISO date)', () async {
      await cmd('dated').execute();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      expect(read('dated', 'requisition'), contains(today));
      expect(read('dated', 'requisition'), isNot(contains('{{DATE}}')));
    });

    test('--lang es scaffolds the Spanish specification', () async {
      await cmd('factura', lang: 'es').execute();
      expect(
        read('factura', 'specification'),
        contains('Especificación de Requerimiento'),
      );
    });

    test('is idempotent: an existing artifact is never clobbered', () async {
      await cmd('keep').execute();
      final file =
          File(p.join(tempDir.path, 'requisitions', 'keep', 'requisition.md'));
      file.writeAsStringSync('EDITED BY HUMAN');

      await cmd('keep').execute();

      expect(file.readAsStringSync(), 'EDITED BY HUMAN');
    });

    test('output lists the created files and the next step', () async {
      final out = await cmd('listed').execute();
      expect(out.message, contains('requisitions/listed/requisition.md'));
      expect(out.message, contains('requisitions/listed/specification.md'));
      expect(out.exitCode, 0);
    });

    test('a fallback language surfaces a one-line notice in the output',
        () async {
      final out = await cmd('fallback', lang: 'pt').execute();
      expect(out.message, contains('pt'));
      expect(out.message, contains('English'));
    });

    test('validate rejects an empty slug', () {
      expect(cmd('').validate(), isNotNull);
    });

    test('validate rejects a slug with illegal characters', () {
      expect(cmd('Bad Slug!').validate(), isNotNull);
    });

    test('validate accepts a kebab-case slug', () {
      expect(cmd('add-invoice-form').validate(), isNull);
    });
  });
}
