/// Shared helpers for the **requisitions workspace**.
///
/// Requisitions are historical documentation —like ADRs— so they live under
/// `docs/requisitions/` (Constitution: the CLI is the *hands*; this centralizes
/// the one location every command agrees on). Each requisition folder is named
/// `<YYYYMMDD>-<slug>` so an alphabetical listing sorts **chronologically**
/// (the compact, hyphen-free date sorts cleanly and is good for ~7 more
/// millennia). The **active** requisition is recorded in
/// `.inquiry/specification.yaml` so downstream commands (`issue new`,
/// `specification check`, `issue publish`) need not repeat the slug.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

/// The two path segments under the project root where requisitions live.
const _base = ['docs', 'requisitions'];

/// Compact, hyphen-free date stamp that sorts chronologically: `YYYYMMDD`.
String dateStamp(DateTime now) =>
    now.year.toString().padLeft(4, '0') +
    now.month.toString().padLeft(2, '0') +
    now.day.toString().padLeft(2, '0');

/// The folder name for a new requisition: `<YYYYMMDD>-<slug>`.
String datedFolder(String slug, DateTime now) => '${dateStamp(now)}-$slug';

/// Absolute path of a requisition folder under `<root>/docs/requisitions/`.
String requisitionDir(String root, String folder) =>
    p.join(root, _base[0], _base[1], folder);

/// Repo-relative (posix) path of a requisition folder — for messages and the
/// active-requisition pointer.
String requisitionRelDir(String folder) => p.posix.join(_base[0], _base[1], folder);

/// The repo-relative (posix) path of the active requisition, read from
/// `.inquiry/specification.yaml`, or null when the pointer is absent.
String? activeRequisitionPath(String root) {
  final f = File(p.join(root, '.inquiry', 'specification.yaml'));
  if (!f.existsSync()) return null;
  final m = RegExp(r'^path:\s*(.+)$', multiLine: true)
      .firstMatch(f.readAsStringSync());
  return m?.group(1)?.trim();
}

/// Resolves a requisition folder to an absolute path, or null when none exists.
///
/// With no [slug], it follows the active pointer (`.inquiry/specification.yaml`).
/// With a [slug], it prefers a folder under `docs/requisitions/` whose name is
/// exactly `<slug>` or ends in `-<slug>` (the dated form; newest wins), then
/// falls back to the **legacy** repo-root `requisitions/<slug>/`.
String? resolveRequisitionDir(String root, [String? slug]) {
  if (slug == null || slug.isEmpty) {
    final rel = activeRequisitionPath(root);
    if (rel == null) return null;
    final dir = p.joinAll([root, ...p.posix.split(rel)]);
    return Directory(dir).existsSync() ? dir : null;
  }

  final base = Directory(p.join(root, _base[0], _base[1]));
  if (base.existsSync()) {
    final exact = p.join(base.path, slug);
    if (Directory(exact).existsSync()) return exact;

    final dated = base
        .listSync()
        .whereType<Directory>()
        .where((d) => p.basename(d.path).endsWith('-$slug'))
        .toList()
      // YYYYMMDD sorts lexically == chronologically; newest last → pick it.
      ..sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    if (dated.isNotEmpty) return dated.last.path;
  }

  final legacy = p.join(root, 'requisitions', slug);
  return Directory(legacy).existsSync() ? legacy : null;
}

/// Records the **active** requisition in `.inquiry/specification.yaml` so other
/// commands can resolve the folder without repeating the slug. Overwrites any
/// previous pointer (the newest `specification new` wins).
void writeActiveRequisition(
  String root, {
  required String slug,
  required String relDir,
  required String lang,
  required String isoDate,
}) {
  final dir = Directory(p.join(root, '.inquiry'));
  if (!dir.existsSync()) dir.createSync(recursive: true);
  File(p.join(root, '.inquiry', 'specification.yaml')).writeAsStringSync(
    '# Inquiry — active requisition pointer (local; git-ignored)\n'
    'slug: $slug\n'
    'path: $relDir\n'
    'lang: $lang\n'
    'created: $isoDate\n',
  );
}
