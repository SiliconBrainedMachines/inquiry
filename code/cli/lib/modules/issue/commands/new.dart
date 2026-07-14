/// `iq issue new <name> [--slug <slug>] [--repo owner/repo] [--lang <lang>]` —
/// scaffolds an "issue as code" file `issue-<name>.md` in the active requisition
/// (`.inquiry/specification.yaml`; `--slug` overrides).
///
/// The CLI is the **hands** (Constitution I): it writes the issue skeleton from
/// the single-source bilingual template, **inheriting the language** from the
/// specification's `iq:lang` directive (so a Spanish spec yields Spanish issues)
/// unless `--lang` overrides it. The brain then fills the body from evidence.
/// Idempotent: an issue file that already exists is left untouched.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../templates/template_resolver.dart';
import '../../specification/slug.dart';
import '../../specification/workspace.dart';

// ─── Input ────────────────────────────────────────────────────────────────

class IssueNewInput extends Input {
  /// The requisition workspace override; `null` → the active requisition
  /// recorded in `.inquiry/specification.yaml`.
  final String? slug;

  /// The issue name → `issue-<name>.md`.
  final String name;

  /// Optional GitHub target repo (`owner/repo`) — pre-fills the front-matter.
  final String? repo;

  /// Optional language override; when null it is inherited from the spec.
  final String? lang;

  IssueNewInput({this.slug, required this.name, this.repo, this.lang});

  static final List<CliParam> params = [
    CliParam.positional('name', description: 'Name of the issue → issue-<name>.md'),
    CliParam.string(
      'slug',
      description: 'Requisition to scaffold into; defaults to the active one',
    ),
    CliParam.string('repo', description: 'Target GitHub repo, as owner/repo'),
    CliParam.string(
      'lang',
      allowed: ['en', 'es'],
      description: "Language of the issue; inherits the specification's when omitted",
    ),
  ];

  factory IssueNewInput.fromCliRequest(CliRequest req) => IssueNewInput(
        slug: optionalSlug(req.flagString('slug')),
        name: (req.param('name') ?? '').trim(),
        repo: req.flagString('repo'),
        lang: req.flagString('lang'),
      );

  @override
  List<CliParam> get schemaFields => params;

  @override
  Map<String, dynamic> toJson() =>
      {'slug': slug, 'name': name, 'repo': repo, 'lang': lang};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class IssueNewOutput extends Output {
  final String message;

  IssueNewOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() => message;
}

// ─── Command ────────────────────────────────────────────────────────────────

class IssueNewCommand implements Command<IssueNewInput, IssueNewOutput> {
  @override
  final IssueNewInput input;

  final TemplateResolver resolver;
  final String workingDirectory;

  static final _namePattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  IssueNewCommand(
    this.input, {
    required this.resolver,
    required this.workingDirectory,
  });

  /// The active requisition folder (absolute), or null when none resolves.
  String? get _dir => resolveRequisitionDir(workingDirectory, input.slug);

  @override
  String? validate() {
    if (input.name.isEmpty) {
      return 'Usage: iq issue new <name> [--slug <slug>] [--repo owner/repo]';
    }
    if (!_namePattern.hasMatch(input.name)) {
      return 'Invalid name "${input.name}": use lowercase letters, digits and '
          'single hyphens (e.g. db, api, app, erp).';
    }
    if (_dir == null) {
      return 'No requisition workspace found — run `iq specification new '
          '<slug>` first, or point at one with --slug <slug>.';
    }
    return null;
  }

  @override
  Future<IssueNewOutput> execute() async {
    final dir = _dir;
    if (dir == null) {
      return IssueNewOutput(
        message: 'No requisition workspace found — run `iq specification new '
            '<slug>` first, or point at one with --slug <slug>.',
      );
    }
    final relDir =
        p.posix.joinAll(p.split(p.relative(dir, from: workingDirectory)));
    final relPath = p.posix.join(relDir, 'issue-${input.name}.md');
    final file = File(p.join(dir, 'issue-${input.name}.md'));

    if (file.existsSync()) {
      return IssueNewOutput(message: '  kept     $relPath (already exists)');
    }

    final lang = input.lang ?? _specLang(dir) ?? 'en';
    final resolution = resolver.resolve('issue', lang: lang);

    final content = resolution.content
        .replaceAll('{{SPEC}}', p.posix.join(relDir, 'specification.md'))
        .replaceAll('{{SLUG}}', input.slug ?? p.basename(dir))
        .replaceAll('{{REPO}}', input.repo ?? '');
    file.writeAsStringSync(content);

    final lines = <String>[
      'Issue scaffolded ($lang):',
      '  created  $relPath',
      if (resolution.notice != null) '  note     ${resolution.notice}',
      '',
      'Next: fill its Contexto/Alcance/Decisiones from evidence, set `repo:` and '
          '`covers:` in the front-matter, then `iq issue publish ${input.name} '
          '--plan`.',
    ];
    return IssueNewOutput(message: lines.join('\n'));
  }

  /// The language declared by the spec's `<!-- iq:lang=xx -->` directive, if any.
  String? _specLang(String dir) {
    final spec = File(p.join(dir, 'specification.md'));
    if (!spec.existsSync()) return null;
    final m = RegExp(r'iq:lang\s*=\s*([A-Za-z-]+)')
        .firstMatch(spec.readAsStringSync());
    return m?.group(1)?.toLowerCase();
  }
}
