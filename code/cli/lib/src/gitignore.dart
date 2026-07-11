/// Shared `.gitignore` management for the Inquiry workspace.
///
/// Requisitions live under `docs/requisitions/` but are a **local authoring
/// workspace** — the durable artifacts are the published GitHub issues (plus
/// the code + tests that carry the spec→issue→test spine). Ignoring them keeps
/// the repo clean and removes the "requisitions accumulation" problem entirely,
/// while the `<YYYYMMDD>-<slug>` naming still sorts them chronologically on disk.
library;

import 'dart:io';

/// The `.gitignore` entries Inquiry manages (idempotently).
const inquiryGitignoreEntries = <String>[
  '.inquiry/',
  'cleanrooms/**/.iq.state.yaml',
  'docs/requisitions/',
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
