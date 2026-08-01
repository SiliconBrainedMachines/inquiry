import 'dart:io';

import 'package:test/test.dart';

import 'package:inquiry_cli/modules/global/commands/upgrade.dart';
import 'package:inquiry_cli/modules/global/commands/version.dart';

void main() {
  group('inquiry upgrade', () {
    test('UpgradeInput serializes correctly', () {
      final input = UpgradeInput(installDir: '/fake/dir');
      expect(input.toJson(), {'installDir': '/fake/dir'});
    });

    test('UpgradeOutput reports no upgrade when already latest', () {
      final output = UpgradeOutput(
        message: 'Already on the latest version',
        previousVersion: inquiryVersion,
        newVersion: inquiryVersion,
        upgraded: false,
      );
      expect(output.exitCode, 0);
      expect(output.upgraded, isFalse);
      expect(output.toJson()['message'], contains('latest'));
    });

    test('UpgradeOutput reports successful upgrade', () {
      final output = UpgradeOutput(
        message: 'Upgraded from 0.0.1 to 0.0.2',
        previousVersion: '0.0.1',
        newVersion: '0.0.2',
        upgraded: true,
      );
      expect(output.exitCode, 0);
      expect(output.upgraded, isTrue);
      expect(output.previousVersion, '0.0.1');
      expect(output.newVersion, '0.0.2');
    });

    test('toText() returns checkmark message when upgraded', () {
      final output = UpgradeOutput(
        message: 'Upgraded from 0.0.1 to 0.0.2',
        previousVersion: '0.0.1',
        newVersion: '0.0.2',
        upgraded: true,
      );
      expect(output.toText(), contains('✓'));
      expect(output.toText(), contains('0.0.1'));
      expect(output.toText(), contains('0.0.2'));
    });

    test('toText() returns plain message when not upgraded', () {
      final output = UpgradeOutput(
        message: 'Already on the latest version',
        previousVersion: '0.0.2',
        newVersion: '0.0.2',
        upgraded: false,
      );
      expect(output.toText(), equals('Already on the latest version'));
    });
  });

  // `Deploying hosts...` used to be the last thing a user saw: the child's
  // output was captured and thrown away, so deploying to two hosts, to one, or
  // to none all looked identical (#300).
  group('post-install output is echoed', () {
    const nl = '\n';

    test('reports what the child actually deployed', () {
      final lines = postInstallOutputLines(
        ProcessResult(
          0,
          0,
          'deployed to host claude${nl}deployed to host opencode$nl',
          '',
        ),
      );

      expect(lines, ['deployed to host claude', 'deployed to host opencode']);
    });

    test('carries stderr too, so a failure explains itself', () {
      final lines = postInstallOutputLines(
        ProcessResult(0, 1, '', 'Unknown host: "vscode"'),
      );

      expect(lines, ['Unknown host: "vscode"']);
    });

    test('drops blank lines rather than echoing empty rows', () {
      final lines = postInstallOutputLines(
        ProcessResult(0, 0, '$nl${nl}first$nl$nl', nl),
      );

      expect(lines, ['first']);
    });

    test('a deploy to nothing is visible, not silent', () {
      final lines = postInstallOutputLines(
        ProcessResult(0, 0, 'No AI coding host found on this machine', ''),
      );

      expect(lines, ['No AI coding host found on this machine']);
    });
  });
}
