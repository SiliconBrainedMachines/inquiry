import 'dart:convert';

import 'package:inquiry_cli/inquiry_cli.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:test/test.dart';

import 'support/string_io_sink.dart';

/// Every `iq` command declares its parameters, so the help *is* the contract and
/// the contract *is* what gets parsed — they cannot drift. An option the command
/// never declared is refused instead of silently ignored, which is how
/// `iq init --host claude` used to run while doing nothing the flag implied.
Future<({int code, String out, String err})> _run(List<String> args) async {
  final out = StringIOSink();
  final err = StringIOSink();
  final code = await runInquiry(args, stdout: out, stderr: err);
  return (code: code, out: out.toString(), err: err.toString());
}

void main() {
  group('a command refuses what it never declared', () {
    test('`iq init --host claude` is rejected, not silently accepted', () async {
      final r = await _run(const ['init', '--host', 'claude']);

      expect(r.code, ExitCode.validationFailed);
      expect(r.err, contains('unknown option --host'));
    });

    test('`iq specification check --bogus x` is rejected', () async {
      final r = await _run(const ['specification', 'check', '--bogus', 'x']);

      expect(r.code, ExitCode.validationFailed);
      expect(r.err, contains('unknown option --bogus'));
    });

    test('the global options stay accepted everywhere', () async {
      final r = await _run(const ['version', '--json']);

      expect(r.code, 0);
      expect(jsonDecode(r.out), isA<Map<String, dynamic>>());
    });
  });

  group('the help renders each command contract', () {
    test('`iq specification new --help` shows --lang, its default and its values',
        () async {
      final r = await _run(const ['specification', 'new', '--help']);

      expect(r.code, 0);
      expect(r.out, contains('--lang'));
      expect(r.out, contains('default: en'));
      expect(r.out, contains('es'));
      expect(r.out, contains('<slug>'));
    });

    test('`iq host get --help` shows the allowed hosts', () async {
      final r = await _run(const ['host', 'get', '--help']);

      expect(r.code, 0);
      expect(r.out, contains('--host'));
      expect(r.out, contains('opencode'));
      expect(r.out, contains('claude'));
    });

    test('`iq fsm --help` describes every command in the module', () async {
      final r = await _run(const ['fsm', '--help']);

      expect(r.code, 0);
      expect(r.out, contains('fsm state'));
      expect(r.out, contains('fsm transition'));
      expect(r.out, contains('--event'));
    });
  });

  group('iq help --json is the machine-readable contract', () {
    test('every command appears with its declared parameters', () async {
      final r = await _run(const ['help', '--json']);

      expect(r.code, 0);
      final catalog = jsonDecode(r.out) as Map<String, dynamic>;
      final commands = (catalog['commands'] as List).cast<Map<String, dynamic>>();
      final routes = commands.map((c) => c['route']).toList();

      expect(routes, contains('specification new <slug>'));
      expect(routes, contains('issue publish <name>'));

      final specNew = commands.firstWhere(
        (c) => c['route'] == 'specification new <slug>',
      );
      final params = (specNew['params'] as List).cast<Map<String, dynamic>>();
      final lang = params.firstWhere((p) => p['name'] == 'lang');

      expect(lang['default'], 'en');
      expect(lang['allowed'], containsAll(<String>['en', 'es']));
      expect(params.any((p) => p['kind'] == 'positional'), isTrue);
    });
  });
}
