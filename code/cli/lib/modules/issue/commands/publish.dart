/// `iq issue publish <name> [--slug <slug>] [--plan|--apply]` — turns an
/// "issue as code" file (in the active requisition) into a real GitHub issue via
/// `gh`.
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
import '../../specification/workspace.dart';
import '../front_matter.dart';

typedef ProcessRunner = Future<ProcessResult> Function(
  String executable,
  List<String> arguments,
);

// ─── Input ────────────────────────────────────────────────────────────────

class IssuePublishInput extends Input {
  /// The requisition workspace override; `null` → the active requisition
  /// recorded in `.inquiry/specification.yaml`.
  final String? slug;
  final String name;

  /// When true, execute `gh issue create`; otherwise only plan (the default).
  final bool apply;

  IssuePublishInput({this.slug, required this.name, this.apply = false});

  static final List<CliParam> params = [
    CliParam.positional('name', description: 'Name of the issue → issue-<name>.md'),
    CliParam.string(
      'slug',
      description: 'Requisition to publish from; defaults to the active one',
    ),
    // `--plan` is the default and carries no value the command reads, but it is
    // a documented way to ask for it — declared so it is accepted, not refused.
    CliParam.boolean('plan', description: 'Preview the gh issue create (default)'),
    CliParam.boolean('apply', description: 'Actually create the GitHub issue'),
  ];

  factory IssuePublishInput.fromCliRequest(CliRequest req) => IssuePublishInput(
        slug: optionalSlug(req.flagString('slug')),
        name: (req.param('name') ?? '').trim(),
        apply: req.flagBool('apply'),
      );

  @override
  List<CliParam> get schemaFields => params;

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

  File? get _file {
    final d = resolveRequisitionDir(workingDirectory, input.slug);
    return d == null ? null : File(p.join(d, 'issue-${input.name}.md'));
  }

  @override
  String? validate() {
    if (input.name.isEmpty) {
      return 'Usage: iq issue publish <name> [--slug <slug>] [--plan|--apply]';
    }
    final f = _file;
    if (f == null || !f.existsSync()) {
      return 'No issue "issue-${input.name}.md" found in the active requisition '
          '— run `iq issue new ${input.name}` first, or pass --slug <slug>.';
    }
    return null;
  }

  @override
  Future<IssuePublishOutput> execute() async {
    final doc = parseIssueDoc(_file!.readAsStringSync());
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
