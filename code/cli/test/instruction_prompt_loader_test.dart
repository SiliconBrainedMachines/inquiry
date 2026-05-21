import 'dart:io';

import 'package:inquiry_cli/assets.dart';
import 'package:inquiry_cli/modules/ape/instruction_prompt_loader.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('InstructionPromptLoader', () {
    late Directory tempDir;
    late Assets assets;
    late InstructionPromptLoader loader;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync(
        'instruction_prompt_loader_test_',
      );
      Directory(p.join(tempDir.path, 'assets', 'instructions'))
          .createSync(recursive: true);
      assets = Assets(root: tempDir.path);
      loader = InstructionPromptLoader(assets: assets);
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('extracts only the Prompt Summary section', () {
      File(p.join(tempDir.path, 'assets', 'instructions', 'sample.md'))
          .writeAsStringSync('''
---
name: sample
---

# Sample

## Prompt Summary

First line.
Second line.

## Notes

Ignored.
''');

      expect(loader.load('sample'), equals('First line.\nSecond line.'));
    });

    test('throws when Prompt Summary section is missing', () {
      File(p.join(tempDir.path, 'assets', 'instructions', 'sample.md'))
          .writeAsStringSync('''
# Sample

## Notes

Ignored.
''');

      expect(() => loader.load('sample'), throwsA(isA<StateError>()));
    });
  });

  group('InstructionPromptLoader integration', () {
    late InstructionPromptLoader loader;

    setUp(() {
      loader = InstructionPromptLoader(
        assets: Assets(root: Directory.current.path),
      );
    });

    test('loads prompt-ready summary for doc-read', () {
      final summary = loader.load('doc-read');

      expect(
        summary,
        equals(
          'Read index_file first from inquiry-context.\n'
          'Use the index to filter candidate documents.\n'
          'If needed read frontmatter before a full document read.\n'
          'Stop as soon as you have enough evidence.\n'
          'Never scan a directory file by file.',
        ),
      );
      expect(summary, isNot(contains('---')));
      expect(summary, isNot(contains('```')));
      expect(summary, isNot(contains('`')));
    });

    test('loads prompt-ready summary for doc-write', () {
      final summary = loader.load('doc-write');

      expect(
        summary,
        equals(
          'Write inside the CLI-created template and keep frontmatter unchanged.\n'
          'Store documents in output_dir.\n'
          'Update index_file after every write.\n'
          'Keep one topic per document.\n'
          'Use confirmed_doc for confirmed findings when it applies.',
        ),
      );
      expect(summary, isNot(contains('---')));
      expect(summary, isNot(contains('```')));
      expect(summary, isNot(contains('`')));
    });

    test('loads prompt-ready summary for issue-start', () {
      final summary = loader.load('issue-start');

      expect(
        summary,
        equals(
          'Run iq doctor first and stop on any failed check.\n'
          'Verify the issue already exists with gh issue view.\n'
          'Create branch NNN-slug and cleanrooms/NNN-slug/analyze.\n'
          'Create analyze/index.md for the cleanroom.\n'
          'Transition with iq fsm transition --event start_analyze --issue NNN.\n'
          'Confirm iq fsm state reports ANALYZE for that issue.',
        ),
      );
      expect(summary, isNot(contains('---')));
      expect(summary, isNot(contains('```')));
      expect(summary, isNot(contains('`')));
    });

    test('loads prompt-ready summary for issue-end', () {
      final summary = loader.load('issue-end');

      expect(
        summary,
        equals(
          'Only run in EXECUTE after all plan checkboxes and tests are complete.\n'
          'Choose the version bump and update every version file.\n'
          'Update CHANGELOG from the completed plan phases.\n'
          'Commit the release changes.\n'
          'Push the branch and create the pull request.',
        ),
      );
      expect(summary, isNot(contains('---')));
      expect(summary, isNot(contains('```')));
      expect(summary, isNot(contains('`')));
    });
  });
}