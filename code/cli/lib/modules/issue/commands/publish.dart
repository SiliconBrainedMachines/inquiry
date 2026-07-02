/// `iq issue publish <slug> <name> [--plan|--apply]` — turns an "issue as code"
/// file into a real GitHub issue via `gh`.
///
/// Terraform-style: **`--plan`** (the default, safe) parses the front-matter and
/// prints the exact `gh issue create` it would run — nothing is created.
/// **`--apply`** executes it and prints the new issue URL. The `.md`'s
/// front-matter (`repo`, `title`, `labels`) is the single source of truth; only
/// the body (after the front-matter) is published.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../specification/slug.dart';
import '../front_matter.dart';

typedef ProcessRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments,
);

// ─── Input ────────────────────────────────────────────────────────────────

class IssuePublishInput extends Input {
  final String slug;
  final String name;

  /// When true, execute `gh issue create`; otherwise only plan (the default).
  final bool apply;

  IssuePublishInput({required this.slug, required this.name, this.apply = false});

  factory IssuePublishInput.fromCliRequest(CliRequest req) => IssuePublishInput(
        slug: normalizeSlug(req.param('slug') ?? ''),
        name: (req.param('name') ?? '').trim(),
        apply: req.flagBool('apply'),
      );

  @override
  Map<String, dynamic> toJson() =>
      {'slug': slug, 'name': name, 'apply': apply};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class IssuePublishOutput extends Output {
  final String message;
  final bool ok;

  IssuePublishOutput({required this.message, required this.ok});

  @override
  Map<String, dynamic> toJson() => {'ok': ok, 'message': message};

  @override
  int get exitCode => ok ? ExitCode.ok : ExitCode.validationFailed;

  @override
  String? toText() => message;
}

// ─── Command ────────────────────────────────────────────────────────────────

class IssuePublishCommand
    implements Command<IssuePublishInput, IssuePublishOutput> {
  @override
  final IssuePublishInput input;

  final String workingDirectory;
  final ProcessRunner runProcess;

  IssuePublishCommand(
    this.input, {
    required this.workingDirectory,
    ProcessRunner? runProcess,
  }) : runProcess = runProcess ?? Process.run;

  File get _file => File(p.join(
        workingDirectory,
        'requisitions',
        input.slug,
        'issue-${input.name}.md',
      ));

  @override
  String? validate() {
    if (input.slug.isEmpty || input.name.isEmpty) {
      return 'Usage: iq issue publish <slug> <name> [--plan|--apply]';
    }
    if (!_file.existsSync()) {
      return 'No issue found at requisitions/${input.slug}/issue-${input.name}.md'
          ' — run `iq issue new ${input.slug} ${input.name}` first.';
    }
    return null;
  }

  @override
  Future<IssuePublishOutput> execute() async {
    final doc = parseIssueDoc(_file.readAsStringSync());
    if (doc == null) {
      return _fail('The issue file has no valid `---` front-matter block.');
    }

    final repo = doc.repo;
    final title = doc.title;
    final problems = <String>[
      if (repo == null) 'set `repo: owner/repo` in the front-matter',
      if (title == null) 'set `title:` in the front-matter',
      if (doc.covers.isEmpty)
        'list the acceptance criteria in `covers:` (the gate requires it)',
    ];
    if (repo == null || title == null) {
      return _fail('Cannot publish — ${problems.join('; ')}.');
    }

    final args = <String>[
      'issue', 'create',
      '--repo', repo,
      '--title', title,
      for (final l in doc.labels) ...['--label', l],
    ];

    if (!input.apply) {
      final lines = <String>[
        'Plan — issue "${input.name}" → $repo',
        '  title:  $title',
        '  labels: ${doc.labels.isEmpty ? '(none)' : doc.labels.join(', ')}',
        '  covers: ${doc.covers.isEmpty ? '(none)' : doc.covers.join(', ')}',
        '  body:   ${doc.body.split('\n').length} lines',
        if (doc.covers.isEmpty) '  warn    ${problems.last}',
        '',
        'Would run (add --body-file with the body below):',
        '  gh ${_display(args)} --body-file <body>',
        '',
        'Re-run with --apply to create it.',
      ];
      return IssuePublishOutput(ok: true, message: lines.join('\n'));
    }

    // --apply: write the body to a temp file and run gh.
    final bodyFile = File(p.join(
      Directory.systemTemp.createTempSync('iq_issue_').path,
      'body.md',
    ))
      ..writeAsStringSync(doc.body);
    try {
      final result =
          await runProcess('gh', [...args, '--body-file', bodyFile.path]);
      if (result.exitCode != 0) {
        return _fail('gh issue create failed:\n${result.stderr}'.trimRight());
      }
      final url = result.stdout.toString().trim();
      return IssuePublishOutput(
        ok: true,
        message: 'Created issue for "${input.name}" in $repo:\n  $url',
      );
    } finally {
      try {
        bodyFile.parent.deleteSync(recursive: true);
      } catch (_) {}
    }
  }

  IssuePublishOutput _fail(String message) =>
      IssuePublishOutput(ok: false, message: message);

  /// Renders the gh args as a copy-pasteable command (quoting args with spaces).
  String _display(List<String> args) => args
      .map((a) => a.contains(' ') ? '"$a"' : a)
      .join(' ');
}
