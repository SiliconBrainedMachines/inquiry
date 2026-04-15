import 'dart:io';

import 'package:test/test.dart';

import 'package:ape_cli/commands/init.dart';

void main() {
  group('InitCommand', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('ape_init_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('creates .ape/ when it does not exist', () async {
      final command = InitCommand(InitInput(workingDirectory: tempDir.path));

      expect(command.validate(), isNull);

      final output = await command.execute();

      final apeDir = Directory('${tempDir.path}/.ape');
      expect(apeDir.existsSync(), isTrue);
      expect(output.exitCode, 0);
      expect(output.toJson()['message'], contains('created'));
    });

    test('returns informational message when .ape/ already exists', () async {
      // Pre-create .ape/
      Directory('${tempDir.path}/.ape').createSync();

      final command = InitCommand(InitInput(workingDirectory: tempDir.path));
      final output = await command.execute();

      // .ape/ still exists — not destroyed
      final apeDir = Directory('${tempDir.path}/.ape');
      expect(apeDir.existsSync(), isTrue);
      expect(output.exitCode, 0);
      expect(output.toJson()['message'], contains('already exists'));
    });
  });
}
