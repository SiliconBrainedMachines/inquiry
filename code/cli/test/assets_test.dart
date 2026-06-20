import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/assets.dart';

void main() {
  group('Assets', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_assets_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('path resolves under assets/', () {
      final assets = Assets(root: tempDir.path);
      final resolved = assets.path('agents/inquiry.body.md');

      expect(
        resolved,
        p.join(tempDir.path, 'assets', 'agents', 'inquiry.body.md'),
      );
    });

    test('loadString reads file content relative to root', () {
      final assetsDir = Directory(p.join(tempDir.path, 'assets', 'agents'));
      assetsDir.createSync(recursive: true);
      final file = File(p.join(assetsDir.path, 'inquiry.body.md'));
      file.writeAsStringSync('# APE Agent');

      final assets = Assets(root: tempDir.path);
      final content = assets.loadString('agents/inquiry.body.md');

      expect(content, '# APE Agent');
    });

    test('loadString throws FileSystemException for missing file', () {
      final assets = Assets(root: tempDir.path);

      expect(
        () => assets.loadString('nonexistent.md'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('listDirectory returns relative paths of files in a directory', () {
      final skillsDir = Directory(
        p.join(tempDir.path, 'assets', 'skills', 'doc-read'),
      );
      skillsDir.createSync(recursive: true);
      File(p.join(skillsDir.path, 'SKILL.md')).writeAsStringSync('# Skill');

      final skillsDir2 = Directory(
        p.join(tempDir.path, 'assets', 'skills', 'doc-write'),
      );
      skillsDir2.createSync(recursive: true);
      File(p.join(skillsDir2.path, 'SKILL.md')).writeAsStringSync('# Skill 2');

      final assets = Assets(root: tempDir.path);
      final dirs = assets.listDirectory('skills');

      expect(dirs, unorderedEquals(['doc-read', 'doc-write']));
    });
  });

  group('Assets integration (real files)', () {
    late Assets assets;

    setUp(() {
      assets = Assets(root: Directory.current.path);
    });

    test('reads agents/inquiry.body.md (shared firmware body)', () {
      final content = assets.loadString('agents/inquiry.body.md');
      expect(content, contains('Inquiry Scheduler'));
      expect(content, contains('{{INIT_HINT}}'));
      expect(content, isNotEmpty);
    });

    test('reads instructions/doc-read.md', () {
      final content = assets.loadString('instructions/doc-read.md');
      expect(content, contains('doc-read'));
      expect(content, isNotEmpty);
    });

    test('reads instructions/doc-write.md', () {
      final content = assets.loadString('instructions/doc-write.md');
      expect(content, contains('doc-write'));
      expect(content, contains('confirmations_doc'));
      expect(content, contains('confirmations.md'));
      expect(content, isNot(contains('confirmed_doc')));
      expect(content, isNot(contains('confirmed.md')));
      expect(content, isNotEmpty);
    });

    test('reads instructions/inquiry-end.md', () {
      final content = assets.loadString('instructions/inquiry-end.md');
      expect(content, contains('inquiry-end'));
      expect(content, contains('EXECUTE'));
      expect(content, isNotEmpty);
    });

    test('reads instructions/issue-create.md for TRIAGE issue creation', () {
      final content = assets.loadString('instructions/issue-create.md');
      expect(content, contains('issue-create'));
      expect(content, contains('TRIAGE'));
      expect(content, isNotEmpty);
    });

    test('reads instructions/inquiry-start.md as operational handoff only', () {
      final content = assets.loadString('instructions/inquiry-start.md');
      expect(content, contains('issue already exists'));
      expect(content, contains('start_analyze'));
      expect(content, contains('cleanrooms/<NNN>-<slug>/analyze/'));
      expect(content, isNot(contains('gh issue create')));
      expect(content, isNotEmpty);
    });

    test('reads skills/kritik/SKILL.md', () {
      final content = assets.loadString('skills/kritik/SKILL.md');
      expect(content, contains('kritik'));
      expect(content, contains('bounded corpus'));
      expect(content, isNotEmpty);
    });

    test('reads skills/legion/SKILL.md with explicit routing contract', () {
      final content = assets.loadString('skills/legion/SKILL.md');
      expect(
        content,
        contains(
          'Parallel-first is the default when the runtime supports isolated parallel sub-agent invocation.',
        ),
      );
      expect(
        content,
        contains(
          'If parallel capability is absent or ambiguous, explicitly degrade to sequential mode and tell the user.',
        ),
      );
      expect(
        content,
        contains(
          'Warning: legion running in degraded sequential mode because parallel subagents are unavailable.',
        ),
      );
      expect(
        content,
        contains('Do not begin synthesis until every expert has finished.'),
      );
      expect(content, isNotEmpty);
    });

    test('standard APE identity assets do not own runtime contract markers', () {
      final disallowedMarkers = {
        'socrates': ['output_dir', 'confirmed_doc', 'index_file', 'doc-write'],
        'descartes': ['analysis_input', 'plan_file', 'Commit:'],
        'ada': [
          'plan_file',
          'pre_pr_inspection_report',
          'release_gate',
          'result_metrics_surface',
        ],
        'darwin': [
          'gh issue list',
          'gh issue comment',
          'gh issue create',
          'diagnosis.md',
          'plan.md',
          'retrospective.md',
          '.inquiry/',
          'metrics.yaml',
        ],
      };

      for (final entry in disallowedMarkers.entries) {
        final content = assets.loadString('apes/${entry.key}.yaml');
        for (final marker in entry.value) {
          expect(
            content,
            isNot(contains(marker)),
            reason:
                '${entry.key}.yaml should leave "$marker" to runtime-owned prompt surfaces',
          );
        }
      }
    });

    test('instructions asset inventory contains the private runtime docs', () {
      final instructionFiles = [
        'instructions/doc-read.md',
        'instructions/doc-write.md',
        'instructions/coding-manifesto-review.md',
        'instructions/issue-create.md',
        'instructions/inquiry-end.md',
        'instructions/inquiry-start.md',
      ];

      for (final file in instructionFiles) {
        final content = assets.loadString(file);
        expect(content, isNotEmpty, reason: '$file should exist and be readable');
      }
    });

    test('listDirectory skills returns all skill directories', () {
      final dirs = assets.listDirectory('skills');
      expect(
        dirs,
        unorderedEquals([
          'kritik',
          'legion',
          'research',
        ]),
      );
    });
  });
}
