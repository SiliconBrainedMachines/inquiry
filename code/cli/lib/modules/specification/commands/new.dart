/// `iq specification new <slug> [--lang <lang>]` — scaffolds a QA specification
/// workspace.
///
/// The CLI is the **hands** (Constitution I): it creates `requisitions/<slug>/`
/// and fills `requisition.md` + `specification.md` from the single-source
/// templates. The brain (QA analyst or model) then writes the actual content —
/// the requisition's AS-IS/TO-BE and the specification's user stories +
/// acceptance criteria. Idempotent: an artifact that already exists is left
/// untouched, so re-running never overwrites human work.
library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;

import '../../../templates/template_resolver.dart';
import '../slug.dart';

// ─── Input ──────────────────────────────────────────────────────────────────

class SpecificationNewInput extends Input {
  /// The kebab-case workspace name → `requisitions/<slug>/`.
  final String slug;

  /// Template language for the localized artifacts (`en` default, `es`).
  final String lang;

  SpecificationNewInput({required this.slug, this.lang = 'en'});

  factory SpecificationNewInput.fromCliRequest(CliRequest req) =>
      SpecificationNewInput(
        slug: normalizeSlug(req.param('slug') ?? ''),
        lang: req.flagString('lang') ?? 'en',
      );

  @override
  Map<String, dynamic> toJson() => {'slug': slug, 'lang': lang};
}

// ─── Output ─────────────────────────────────────────────────────────────────

class SpecificationNewOutput extends Output {
  final String message;

  SpecificationNewOutput({required this.message});

  @override
  Map<String, dynamic> toJson() => {'message': message};

  @override
  int get exitCode => ExitCode.ok;

  @override
  String? toText() => message;
}

// ─── Command ────────────────────────────────────────────────────────────────

class SpecificationNewCommand
    implements Command<SpecificationNewInput, SpecificationNewOutput> {
  @override
  final SpecificationNewInput input;

  final TemplateResolver resolver;

  /// Where `requisitions/` is rooted — the QA workspace (repo root in prod).
  final String workingDirectory;

  /// The localized artifacts this phase scaffolds, in display order.
  static const _artifacts = ['requisition', 'specification'];

  static final _slugPattern = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  SpecificationNewCommand(
    this.input, {
    required this.resolver,
    required this.workingDirectory,
  });

  @override
  String? validate() {
    if (input.slug.isEmpty) {
      return 'A <slug> is required: iq specification new <slug>';
    }
    if (!_slugPattern.hasMatch(input.slug)) {
      return 'Invalid slug "${input.slug}": use lowercase letters, digits, and '
          'single hyphens (e.g. add-invoice-form).';
    }
    return null;
  }

  @override
  Future<SpecificationNewOutput> execute() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final dir = p.join(workingDirectory, 'requisitions', input.slug);
    Directory(dir).createSync(recursive: true);

    final created = <String>[];
    final skipped = <String>[];
    final notices = <String>[];

    for (final artifact in _artifacts) {
      final relPath = p.posix.join('requisitions', input.slug, '$artifact.md');
      final file = File(p.join(dir, '$artifact.md'));

      final resolution = resolver.resolve(artifact, lang: input.lang);
      if (resolution.notice != null) {
        notices.add('$artifact.md: ${resolution.notice}');
      }

      if (file.existsSync()) {
        skipped.add(relPath);
        continue;
      }
      file.writeAsStringSync(resolution.content.replaceAll('{{DATE}}', today));
      created.add(relPath);
    }

    return SpecificationNewOutput(
      message: _renderMessage(created, skipped, notices),
    );
  }

  String _renderMessage(
    List<String> created,
    List<String> skipped,
    List<String> notices,
  ) {
    final lines = <String>[];
    if (created.isNotEmpty) {
      lines.add('Specification workspace scaffolded for "${input.slug}":');
      for (final f in created) {
        lines.add('  created  $f');
      }
    }
    for (final f in skipped) {
      lines.add('  kept     $f (already exists)');
    }
    for (final n in notices) {
      lines.add('  note     $n');
    }
    lines.add('');
    lines.add(
      'Next: fill requisitions/${input.slug}/requisition.md (the need, '
      'AS-IS/TO-BE), then specification.md (user stories + acceptance '
      'criteria), then derive the issues.',
    );
    return lines.join('\n');
  }
}
