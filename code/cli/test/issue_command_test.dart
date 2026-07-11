import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/templates/template_resolver.dart';
import 'package:inquiry_cli/modules/issue/front_matter.dart';
import 'package:inquiry_cli/modules/issue/commands/new.dart';
import 'package:inquiry_cli/modules/issue/commands/publish.dart';
import 'package:inquiry_cli/modules/specification/workspace.dart';

void main() {
  final resolver = TemplateResolver(Assets(root: Directory.current.path));

  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('iq_issue_test_'));
  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  // Scaffolds a LEGACY requisition workspace (repo-root requisitions/<slug>/).
  void seedSpec(String slug, {String lang = 'es'}) {
    final f = File(p.join(tempDir.path, 'requisitions', slug, 'specification.md'));
    f.createSync(recursive: true);
    f.writeAsStringSync('# Especificación\n\n<!-- iq:lang=$lang -->\n');
  }

  // Seeds a dated requisition under docs/requisitions/ + the active pointer.
  void seedActive(String slug, {String lang = 'es'}) {
    final folder = '20260709-$slug';
    final f = File(
        p.join(tempDir.path, 'docs', 'requisitions', folder, 'specification.md'));
    f.createSync(recursive: true);
    f.writeAsStringSync('# Especificación\n\n<!-- iq:lang=$lang -->\n');
    writeActiveRequisition(tempDir.path,
        slug: slug,
        relDir: 'docs/requisitions/$folder',
        lang: lang,
        isoDate: '2026-07-09');
  }

  String issuePath(String slug, String name) =>
      p.join(tempDir.path, 'requisitions', slug, 'issue-$name.md');

  IssueNewCommand newCmd(String? slug, String name, {String? repo, String? lang}) =>
      IssueNewCommand(
        IssueNewInput(slug: slug, name: name, repo: repo, lang: lang),
        resolver: resolver,
        workingDirectory: tempDir.path,
      );

  group('front matter', () {
    test('parses title/repo/labels/covers and splits the body', () {
      final doc = parseIssueDoc('''
---
kind: iq-issue
lang: es
title: "[db] Historial de tickets"
repo: "owner/impulsa-db"
labels: [tickets, db]
covers: [AC-1, AC-2]
---

# Body heading

Some content.
''');
      expect(doc, isNotNull);
      expect(doc!.title, '[db] Historial de tickets');
      expect(doc.repo, 'owner/impulsa-db');
      expect(doc.labels, ['tickets', 'db']);
      expect(doc.covers, ['AC-1', 'AC-2']);
      expect(doc.body, startsWith('# Body heading'));
      expect(doc.body, isNot(contains('kind: iq-issue')));
    });

    test('returns null without a front-matter fence', () {
      expect(parseIssueDoc('# just markdown\n'), isNull);
    });
  });

  group('IssueNewCommand', () {
    test('scaffolds issue-<name>.md inheriting the spec language (es)', () async {
      seedSpec('feature', lang: 'es');
      final out = await newCmd('feature', 'db').execute();
      expect(out.message, contains('(es)'));
      final content = File(issuePath('feature', 'db')).readAsStringSync();
      expect(content, contains('lang: es'));
      expect(content, contains('spec: "requisitions/feature/specification.md"'));
      expect(content, contains('kind: iq-issue'));
    });

    test('--repo pre-fills the front-matter repo', () async {
      seedSpec('feature');
      await newCmd('feature', 'api', repo: 'owner/impulsa-api').execute();
      final doc = parseIssueDoc(File(issuePath('feature', 'api')).readAsStringSync());
      expect(doc!.repo, 'owner/impulsa-api');
    });

    test('--lang overrides the inherited spec language', () async {
      seedSpec('feature', lang: 'es');
      await newCmd('feature', 'app', lang: 'en').execute();
      expect(File(issuePath('feature', 'app')).readAsStringSync(),
          contains('lang: en'));
    });

    test('is idempotent — an existing issue file is kept', () async {
      seedSpec('feature');
      final path = issuePath('feature', 'db');
      await newCmd('feature', 'db').execute();
      File(path).writeAsStringSync('EDITED');
      final out = await newCmd('feature', 'db').execute();
      expect(out.message, contains('already exists'));
      expect(File(path).readAsStringSync(), 'EDITED');
    });

    test('validate rejects a missing workspace', () {
      expect(newCmd('nope', 'db').validate(), contains('No requisition workspace'));
    });

    test('resolves the active requisition from the pointer (no --slug)',
        () async {
      seedActive('feat', lang: 'es');
      final out = await newCmd(null, 'db').execute();
      expect(out.message, contains('(es)'));
      final file = File(p.join(
          tempDir.path, 'docs', 'requisitions', '20260709-feat', 'issue-db.md'));
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(),
          contains('spec: "docs/requisitions/20260709-feat/specification.md"'));
    });
  });

  group('IssuePublishCommand', () {
    void writeIssue(String slug, String name, String content) {
      final f = File(issuePath(slug, name));
      f.createSync(recursive: true);
      f.writeAsStringSync(content);
    }

    IssuePublishCommand pub(String? slug, String name,
            {bool apply = false, ProcessRunner? runner}) =>
        IssuePublishCommand(
          IssuePublishInput(slug: slug, name: name, apply: apply),
          workingDirectory: tempDir.path,
          runProcess: runner,
        );

    const filled = '''
---
kind: iq-issue
lang: es
title: "[db] Historial de tickets"
repo: "owner/impulsa-db"
labels: [tickets, db]
covers: [AC-1, AC-2]
---

# [db] Historial de tickets

Cuerpo.
''';

    test('--plan previews the gh command without running it', () async {
      writeIssue('feature', 'db', filled);
      var ran = false;
      final out = await pub('feature', 'db', runner: (e, a) async {
        ran = true;
        return ProcessResult(0, 0, '', '');
      }).execute();
      expect(ran, isFalse);
      expect(out.ok, isTrue);
      expect(out.message, contains('gh issue create'));
      expect(out.message, contains('--repo owner/impulsa-db'));
      expect(out.message, contains('AC-1, AC-2'));
    });

    test('--apply runs gh and reports the URL', () async {
      writeIssue('feature', 'db', filled);
      late List<String> gotArgs;
      final out = await pub('feature', 'db', apply: true, runner: (e, a) async {
        gotArgs = a;
        return ProcessResult(0, 0, 'https://github.com/owner/impulsa-db/issues/7', '');
      }).execute();
      expect(out.ok, isTrue);
      expect(out.message, contains('issues/7'));
      expect(gotArgs, containsAllInOrder(['issue', 'create', '--repo', 'owner/impulsa-db']));
      expect(gotArgs, containsAllInOrder(['--label', 'tickets']));
      expect(gotArgs, contains('--body-file'));
    });

    test('fails when the front-matter has no repo', () async {
      writeIssue('feature', 'db', '''
---
kind: iq-issue
title: "no repo"
repo: ""
covers: [AC-1]
---
body
''');
      final out = await pub('feature', 'db').execute();
      expect(out.ok, isFalse);
      expect(out.message, contains('repo: owner/repo'));
    });

    test('publishes from the active requisition pointer (no --slug)', () async {
      seedActive('feat');
      File(p.join(tempDir.path, 'docs', 'requisitions', '20260709-feat',
          'issue-db.md'))
        ..createSync(recursive: true)
        ..writeAsStringSync(filled);
      final out = await pub(null, 'db').execute();
      expect(out.ok, isTrue);
      expect(out.message, contains('--repo owner/impulsa-db'));
    });
  });
}
