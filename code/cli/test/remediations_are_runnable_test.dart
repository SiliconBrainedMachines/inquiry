/// Every command this CLI tells someone to run must be runnable as written.
///
/// Five routes refuse to act until they are told which of `--plan` and
/// `--apply` was meant. A message that says "run `iq host get`" therefore hands
/// the reader — or the agent acting on it — something that will fail. That is
/// worse than saying nothing: it reads as instruction and behaves as a dead
/// end.
///
/// This is a whole-source sweep rather than a per-message assertion because the
/// mistake is not one anybody makes on purpose. It was made six times in the
/// 0.25.0 release, in files nobody thought of as documentation: an adapter's
/// substitution map, the update banner, a route description, and the upgrade's
/// own remediation — the last of which a user read on screen, followed, and
/// found broken.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// The routes that take `--plan` / `--apply`. See ADR 0002.
const _commands = [
  'host get',
  'host clean',
  'upgrade',
  'uninstall',
  'implementation start',
];

/// `iq upgrade`, `inquiry host get`, … — the shapes a message uses to name one.
final _namesACommand = RegExp(
  '(iq|inquiry) (${_commands.join('|')})',
);

final _namesAMode = RegExp(r'--plan|--apply');

bool _isComment(String line) {
  final t = line.trimLeft();
  return t.startsWith('//') || t.startsWith('*') || t.startsWith('/*');
}

void main() {
  test('no message tells someone to run a command without a mode', () {
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
        if (!_namesACommand.hasMatch(line)) continue;

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
