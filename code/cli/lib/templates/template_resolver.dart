import '../assets.dart';

/// The outcome of resolving an artifact template for a language: the [content]
/// to scaffold, plus an optional one-line [notice] when a fallback happened.
class TemplateResolution {
  final String content;
  final String? notice;

  const TemplateResolution(this.content, [this.notice]);
}

/// Resolves an artifact's Markdown template for a requested language.
///
/// Lookup order for artifact `a`, language `lang`:
///   1. `artifacts/a.template.<lang>.md` — the localized template.
///   2. `artifacts/a.template.en.md` — the English default (localized artifacts).
///   3. `artifacts/a.template.md` — the language-neutral template (e.g. the
///      dev-cycle `diagnosis`/`plan`, which are English-only).
/// If a non-English language was requested but only English exists, the result
/// carries a one-line [TemplateResolution.notice]. Throws [ArgumentError] when no
/// template exists for the artifact at all.
class TemplateResolver {
  final Assets assets;

  TemplateResolver(this.assets);

  TemplateResolution resolve(String artifact, {String lang = 'en'}) {
    final localized = _tryLoad('artifacts/$artifact.template.$lang.md');
    if (localized != null) return TemplateResolution(localized);

    final fallbackNotice = lang == 'en'
        ? null
        : 'template not available for "$lang", using English';

    final english = _tryLoad('artifacts/$artifact.template.en.md');
    if (english != null) return TemplateResolution(english, fallbackNotice);

    final neutral = _tryLoad('artifacts/$artifact.template.md');
    if (neutral != null) return TemplateResolution(neutral, fallbackNotice);

    throw ArgumentError('No template for artifact "$artifact"');
  }

  String? _tryLoad(String path) {
    try {
      return assets.loadString(path);
    } catch (_) {
      return null;
    }
  }
}
