/// Shared `.gitignore` management for the Inquiry workspace.
library;

import 'dart:io';

/// The `.gitignore` entries Inquiry manages (idempotently).
///
/// `docs/requisitions/` is deliberately absent: the requisitions workspace is
/// created by MACSS, which manages that entry itself.
const inquiryGitignoreEntries = <String>[
  '.inquiry/',
  // The cleanroom is a per-cycle working area, not documentation: the durable
  // artifacts of a cycle are the published issue, the code and the tests. The
  // whole directory is local — previously only `.iq.state.yaml` was ignored,
  // which left diagnosis.md / plan.md accumulating in the repo.
  'cleanrooms/',
];

const _header = '# Inquiry — local workspace & cycle state';

/// Ensures [entries] exist in `<root>/.gitignore` under the Inquiry header.
/// Idempotent — only missing entries are appended. Returns a one-line status
/// when the file changed, otherwise `null`.
String? ensureGitignoreEntries(
  String root, {
  List<String> entries = inquiryGitignoreEntries,
}) {
  final gitignore = File('$root/.gitignore');

  if (!gitignore.existsSync()) {
    gitignore.writeAsStringSync('$_header\n${entries.join('\n')}\n');
    return 'Created .gitignore with Inquiry entries';
  }

  var content = gitignore.readAsStringSync();
  final missing = entries.where((e) => !content.contains(e)).toList();
  if (missing.isEmpty) return null;

  if (!content.endsWith('\n')) content = '$content\n';
  content = '$content$_header\n${missing.join('\n')}\n';
  gitignore.writeAsStringSync(content);
  return 'Added Inquiry entries to .gitignore';
}
