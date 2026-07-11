/// Normalizes the `<slug>` argument of the `iq specification` commands.
///
/// The commands resolve a slug to `requisitions/<slug>/`. To let the shell's
/// tab-completion fill the path, the argument may also be the path itself —
/// `requisitions/<slug>`, with a leading `./` and/or a trailing separator, in
/// either `/` or `\` form. This extracts the bare slug from any of those:
///
///   ticket-purchase                                  → ticket-purchase
///   requisitions/ticket-purchase                     → ticket-purchase
///   .\requisitions\ticket-purchase\                  → ticket-purchase
///   requisitions/ticket-purchase/specification.md    → ticket-purchase
library;

/// The `--slug` override for downstream commands (`issue new/publish`,
/// `specification check`): `null` when absent/blank (→ use the active
/// requisition pointer), otherwise the normalized bare slug.
String? optionalSlug(String? raw) =>
    (raw == null || raw.trim().isEmpty) ? null : normalizeSlug(raw);

String normalizeSlug(String raw) {
  var s = raw.trim().replaceAll('\\', '/');
  // Drop a leading "./" and any trailing slashes (tab-completion adds one).
  s = s.replaceAll(RegExp(r'^\./'), '').replaceAll(RegExp(r'/+$'), '');

  // If the path goes through a `requisitions/` segment, the slug is the first
  // path segment after the last such marker.
  const marker = 'requisitions/';
  final idx = s.lastIndexOf(marker);
  if (idx >= 0) {
    s = s.substring(idx + marker.length);
    final slash = s.indexOf('/');
    if (slash >= 0) s = s.substring(0, slash);
  }
  return s;
}
