import 'package:inquiry_cli/inquiry_cli.dart';
import 'package:inquiry_cli/modules/global/commands/help.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('HelpCommand', () {
    test('returns the global CLI help summary', () async {
      final output = await HelpCommand(HelpInput()).execute();

      expect(output.exitCode, ExitCode.ok);
      expect(output.toText(), contains('Usage:'));
      expect(output.toText(), contains('inquiry help'));
      expect(output.toText(), contains('Root commands:'));
      expect(output.toText(), contains('Modules:'));
      expect(output.toText(), contains('host get'));
      expect(output.toText(), isNot(contains('target get')));
      expect(output.toText(), contains('fsm transition'));
      expect(output.toText(), contains('ape prompt'));
    });

    test('normalizes global help flags to the help command', () {
      expect(normalizeInquiryArgs(const ['--help']), equals(const ['help']));
      expect(normalizeInquiryArgs(const ['-h']), equals(const ['help']));
      expect(normalizeInquiryArgs(const ['help']), equals(const ['help']));
      expect(
        normalizeInquiryArgs(const ['fsm', 'state']),
        equals(const ['fsm', 'state']),
      );
    });
  });
}