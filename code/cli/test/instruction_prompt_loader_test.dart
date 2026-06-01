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
          'Never scan a directory file by file.\n'
          'Trust authoritative_handoff first when the context policy says it is authoritative.\n'
          'Use retrieval_context only for concrete gaps that the authoritative artifact does not resolve.\n'
          'Let retrieval_trigger_rule decide when bounded context may be widened.\n'
          'Treat reread_avoidance_rule as a hard warning against broad rediscovery.',
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
          'Use confirmations_doc for confirmations when it applies.\n'
          'Treat upfront_context as your bounded starting context.\n'
          'Use retrieval_context only when the current uncertainty requires more evidence.\n'
          'Build authoritative_handoff so later phases do not need to reconstruct ANALYZE from scratch.\n'
          'Let retrieval_trigger_rule justify any widening beyond bounded context.\n'
          'Honor reread_avoidance_rule so writing work does not restart discovery by habit.',
        ),
      );
      expect(summary, isNot(contains('---')));
      expect(summary, isNot(contains('```')));
      expect(summary, isNot(contains('`')));
    });

    test('loads prompt-ready summary for inquiry-start', () {
      final summary = loader.load('inquiry-start');

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

    test('loads prompt-ready summary for inquiry-end', () {
      final summary = loader.load('inquiry-end');

      expect(
        summary,
        equals(
          'Only run in EXECUTE after all plan checkboxes and tests are complete.\n'
          'Run the END pre-PR inspection gate and stop on any blocking sensor failure.\n'
          'Confirm the already-proposed semver bump and stop if explicit user approval is still missing.\n'
          'Update every required version file once that approved bump is clear.\n'
          'Update CHANGELOG from the completed plan phases and commit the release changes.\n'
          'Push the branch and create the pull request only after the gate is green.',
        ),
      );
      expect(summary, isNot(contains('---')));
      expect(summary, isNot(contains('```')));
      expect(summary, isNot(contains('`')));
    });
  });
}