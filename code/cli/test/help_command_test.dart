import 'package:inquiry_cli/inquiry_cli.dart';
import 'package:inquiry_cli/modules/global/commands/help.dart';
import 'package:test/test.dart';

void main() {
  group('inquiry help', () {
    late String text;

    setUp(() async {
      final sink = StringIOSink();
      await runInquiry(const ['help'], stdout: sink);
      text = sink.toString();
    });

    test('shows the usage header', () {
      expect(text, contains('Usage:'));
      expect(text, contains('iq <command>'));
    });

    /// `iq` with no arguments is NOT a help request — it is a registered route:
    /// the banner + FSM diagram. modular_cli_sdk 0.3.0 rewrites the empty
    /// invocation into `help` unconditionally, which silently replaced the TUI.
    test('bare `iq` runs the TUI, not the help', () async {
      final sink = StringIOSink();
      final code = await runInquiry(const [], stdout: sink);
      final out = sink.toString();

      expect(code, 0);
      expect(out, contains('Inquiry'), reason: 'the banner should be printed');
      expect(out, contains('Analyze'), reason: 'the FSM diagram should be printed');
      expect(out, isNot(contains('Available commands')),
          reason: 'the empty invocation was hijacked by the help command');
    });

    /// The help used to be a hand-written string, and it silently drifted: the
    /// `specification` and `issue` modules shipped and were never listed in it.
    /// It is now rendered from the router's own registry, so a registered
    /// command cannot be absent.
    test('lists every registered command', () {
      const registered = [
        'help',
        'init',
        'version',
        'doctor',
        'upgrade',
        'uninstall',
        'host get',
        'host clean',
        'fsm state',
        'fsm transition',
        'ape prompt',
        'ape state',
        'ape transition',
        'specification new',
        'specification check',
        'issue new',
        'issue publish',
      ];

      for (final route in registered) {
        expect(
          text,
          contains(route),
          reason: '`$route` is registered but missing from the help',
        );
      }
    });

    /// The bare `iq` route registers as the empty string, which the router
    /// renders as a listing line with no command — an orphan dash. It is
    /// already documented in the usage header.
    test('has no listing line with an empty command', () {
      for (final line in text.split('\n')) {
        expect(
          line,
          isNot(matches(RegExp(r'^\s+-\s'))),
          reason: 'orphan description with no command: "$line"',
        );
      }
    });

    test('carries each command description, not just its route', () {
      expect(text, contains('Print the current CLI version'));
      expect(text, contains('specification_ready gate'));
    });

    /// The `specification new` description still pointed at the pre-0.19.0
    /// layout (`requisitions/<slug>/`), which no longer exists.
    test('describes specification new with the path it actually creates', () {
      expect(text, contains('docs/requisitions/'));
      expect(text, isNot(contains('requisitions/<slug>/')));
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
