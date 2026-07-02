/// `iq issue new <slug> <name> [--repo owner/repo] [--lang <lang>]` — scaffolds
/// an "issue as code" file `requisitions/<slug>/issue-<name>.md`.
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

// ─── Input ────────────────────────────────────────────────────────────────

class IssueNewInput extends Input {
  /// The requisition workspace: `requisitions/<slug>/`.
  final String slug;

  /// The issue name → `issue-<name>.md`.
  final String name;

  /// Optional GitHub target repo (`owner/repo`) — pre-fills the front-matter.
  final String? repo;

  /// Optional language override; when null it is inherited from the spec.
  final String? lang;

  IssueNewInput({required this.slug, required this.name, this.repo, this.lang});

  factory IssueNewInput.fromCliRequest(CliRequest req) => IssueNewInput(
        slug: normalizeSlug(req.param('slug') ?? ''),
        name: (req.param('name') ?? '').trim(),
        repo: req.flagString('repo'),
        lang: req.flagString('lang'),
      );

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

  String get _dir => p.join(workingDirectory, 'requisitions', input.slug);

  @override
  String? validate() {
    if (input.slug.isEmpty || input.name.isEmpty) {
      return 'Usage: iq issue new <slug> <name> [--repo owner/repo]';
    }
    if (!_namePattern.hasMatch(input.name)) {
      return 'Invalid name "${input.name}": use lowercase letters, digits and '
          'single hyphens (e.g. db, api, app, erp).';
    }
    if (!Directory(_dir).existsSync()) {
      return 'No requisition workspace at requisitions/${input.slug}/ — run '
          '`iq specification new ${input.slug}` first.';
    }
    return null;
  }

  @override
  Future<IssueNewOutput> execute() async {
    final relPath = p.posix.join('requisitions', input.slug, 'issue-${input.name}.md');
    final file = File(p.join(_dir, 'issue-${input.name}.md'));

    if (file.existsSync()) {
      return IssueNewOutput(message: '  kept     $relPath (already exists)');
    }

    final lang = input.lang ?? _specLang() ?? 'en';
    final resolution = resolver.resolve('issue', lang: lang);

    final content = resolution.content
        .replaceAll('{{SLUG}}', input.slug)
        .replaceAll('{{REPO}}', input.repo ?? '');
    file.writeAsStringSync(content);

    final lines = <String>[
      'Issue scaffolded ($lang):',
      '  created  $relPath',
      if (resolution.notice != null) '  note     ${resolution.notice}',
      '',
      'Next: fill its Contexto/Alcance/Decisiones from evidence, set `repo:` and '
          '`covers:` in the front-matter, then `iq issue publish ${input.slug} '
          '${input.name} --plan`.',
    ];
    return IssueNewOutput(message: lines.join('\n'));
  }

  /// The language declared by the spec's `<!-- iq:lang=xx -->` directive, if any.
  String? _specLang() {
    final spec = File(p.join(_dir, 'specification.md'));
    if (!spec.existsSync()) return null;
    final m = RegExp(r'iq:lang\s*=\s*([A-Za-z-]+)')
        .firstMatch(spec.readAsStringSync());
    return m?.group(1)?.toLowerCase();
  }
}
