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
  final fixedNow = DateTime(2026, 7, 9);

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
        now: () => fixedNow,
      );

  String read(String slug, String artifact) => File(
        p.join(tempDir.path, 'docs', 'requisitions', '20260709-$slug',
            '$artifact.md'),
      ).readAsStringSync();

  group('SpecificationNewCommand', () {
    test(
        'scaffolds docs/requisitions/<YYYYMMDD>-<slug>/ with requisition.md + '
        'specification.md', () async {
      await cmd('invoice-form').execute();

      final dir = Directory(
          p.join(tempDir.path, 'docs', 'requisitions', '20260709-invoice-form'));
      expect(dir.existsSync(), isTrue);
      expect(read('invoice-form', 'requisition'), contains('# Requisition'));
      expect(
        read('invoice-form', 'specification'),
        contains('# Specification'),
      );
    });

    test('the dated folder prefix is compact YYYYMMDD (no hyphens in the date)',
        () async {
      await cmd('order').execute();
      final base = Directory(p.join(tempDir.path, 'docs', 'requisitions'));
      final names = base.listSync().map((e) => p.basename(e.path)).toList();
      expect(names, contains('20260709-order'));
    });

    test('records the active requisition in .inquiry/specification.yaml',
        () async {
      await cmd('pointer', lang: 'es').execute();
      final yaml =
          File(p.join(tempDir.path, '.inquiry', 'specification.yaml'))
              .readAsStringSync();
      expect(yaml, contains('slug: pointer'));
      expect(yaml, contains('path: docs/requisitions/20260709-pointer'));
      expect(yaml, contains('lang: es'));
    });

    test('ensures .inquiry/ and docs/requisitions/ are git-ignored', () async {
      await cmd('ignored').execute();
      final gitignore =
          File(p.join(tempDir.path, '.gitignore')).readAsStringSync();
      expect(gitignore, contains('.inquiry/'));
      expect(gitignore, contains('docs/requisitions/'));
    });

    test('replaces the {{DATE}} placeholder with today (ISO date)', () async {
      await cmd('dated').execute();
      expect(read('dated', 'requisition'), contains('2026-07-09'));
      expect(read('dated', 'requisition'), isNot(contains('{{DATE}}')));
    });

    test('--lang es scaffolds the Spanish specification', () async {
      await cmd('factura', lang: 'es').execute();
      expect(
        read('factura', 'specification'),
        contains('# Especificación'),
      );
    });

    test('is idempotent: an existing artifact is never clobbered', () async {
      await cmd('keep').execute();
      final file = File(p.join(
          tempDir.path, 'docs', 'requisitions', '20260709-keep',
          'requisition.md'));
      file.writeAsStringSync('EDITED BY HUMAN');

      await cmd('keep').execute();

      expect(file.readAsStringSync(), 'EDITED BY HUMAN');
    });

    test('output lists the created files and the next step', () async {
      final out = await cmd('listed').execute();
      expect(out.message,
          contains('docs/requisitions/20260709-listed/requisition.md'));
      expect(out.message,
          contains('docs/requisitions/20260709-listed/specification.md'));
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
