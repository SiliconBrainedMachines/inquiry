/// Every command this CLI tells someone to run must be runnable as written.
///
/// A command refuses to act until it is told which of `--plan` and `--apply`
/// was meant. A message that says "run `iq host get`" therefore hands the
/// reader — or the agent acting on it — something that will fail. That is worse
/// than saying nothing: it reads as instruction and behaves as a dead end.
///
/// This is a whole-source sweep rather than a per-message assertion because the
/// mistake is not one anybody makes on purpose. It was made twelve times in the
/// 0.25.0 release, in files nobody thinks of as documentation: an adapter's
/// substitution map, the update banner, a route description, and the upgrade's
/// own remediation — the last of which a user read on screen, followed, and
/// found broken.
///
/// **Which commands to check is asked of the CLI, not written down here.** A
/// hand-kept list is a second place the truth lives, and it goes quietly blind
/// exactly when the CLI grows: register `iq analyze start` tomorrow and a
/// literal list keeps passing while the new command's messages go unchecked.
/// `iq help --json` publishes `kind` for every route, so the sweep reads the
/// same contract a user or an agent reads.
library;

import 'dart:convert';
import 'dart:io';

import 'package:inquiry_cli/inquiry_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/string_io_sink.dart';

final _namesAMode = RegExp(r'--plan|--apply');

/// Strips positional placeholders, so `records show <id>` is named `records
/// show` — the tokens a message would actually contain.
String _nameOf(String route) =>
    route.replaceAll(RegExp(r'\s*<[^>]+>'), '').trim();

bool _isComment(String line) {
  final t = line.trimLeft();
  return t.startsWith('//') || t.startsWith('*') || t.startsWith('/*');
}

Future<List<String>> _commandNames() async {
  final out = StringIOSink();
  final code = await runInquiry(const ['help', '--json'], stdout: out);
  expect(code, 0, reason: 'help --json is how the contract is published');

  final catalog = jsonDecode(out.toString()) as Map<String, dynamic>;
  return (catalog['commands'] as List)
      .cast<Map<String, dynamic>>()
      .where((c) => c['kind'] == 'command')
      .map((c) => _nameOf(c['route'] as String))
      .where((name) => name.isNotEmpty)
      .toList();
}

void main() {
  test('the CLI publishes which routes take a mode', () async {
    // The sweep below is only as good as this. If `kind` ever stopped being
    // published, the sweep would silently check nothing and still pass.
    final names = await _commandNames();

    expect(names, isNotEmpty);
    expect(names, contains('host get'));
    expect(names, contains('implementation start'));
  });

  test('no message tells someone to run a command without a mode', () async {
    final names = await _commandNames();
    final namesACommand = RegExp('(iq|inquiry) (${names.map(RegExp.escape).join('|')})');

    final offenders = <String>[];
    final files = Directory(p.join(Directory.current.path, 'lib'))
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (_isComment(line)) continue;
        if (!namesACommand.hasMatch(line)) continue;

        // A long message wraps, so the flag may sit on the next line — the
        // adjacent line counts as part of the same sentence.
        final context = [
          line,
          if (i + 1 < lines.length) lines[i + 1],
        ].join(' ');
        if (_namesAMode.hasMatch(context)) continue;

        offenders.add(
          '${p.relative(file.path)}:${i + 1}\n      ${line.trim()}',
        );
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These name a command that refuses to run without --plan or --apply, '
          'so the reader is handed something that fails:\n\n'
          '  ${offenders.join('\n\n  ')}\n\n'
          'Add the mode the reader should use: --apply for a person at a '
          'terminal, --apply --autoapprove where an agent or installer acts '
          'unattended, --plan to only look.',
    );
  });
}
