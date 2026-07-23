/// Deterministic branch-name derivation for a cycle.
///
/// The `<NNN>-<slug>` convention is what the FSM's `feature_branch_selected`
/// precheck validates (`fsm/commands/transition.dart` → `_isIssueLinkedFeatureBranch`).
/// Historically the LLM derived this by hand following `assets/instructions/
/// inquiry-start.md`; moving it here makes it a deterministic CLI step (a
/// "mechanical process is an `iq` command", not an instruction).
library;

/// Common Spanish/Latin accented letters folded to ASCII, so a title like
/// "incluir código" yields `incluir-codigo`, not `incluir-c-digo`.
const Map<String, String> _accentFolds = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ñ': 'n', 'ç': 'c',
};

/// Derives a kebab-case slug from an issue [title].
///
/// Rules (matching the documented convention, now enforced in code): lowercase,
/// fold accents, replace every run of non-alphanumerics with a single hyphen,
/// trim leading/trailing hyphens, cap at 50 characters (re-trimming any hyphen
/// the cut leaves dangling). Returns an empty string when the title has no
/// alphanumeric content.
String deriveSlug(String title) {
  final lowered = title.toLowerCase();
  final folded = StringBuffer();
  for (final ch in lowered.split('')) {
    folded.write(_accentFolds[ch] ?? ch);
  }

  var slug = folded
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  if (slug.length > 50) {
    slug = slug.substring(0, 50).replaceAll(RegExp(r'-+$'), '');
  }
  return slug;
}

/// Left-pads an issue number to at least three digits, matching the convention
/// (`#37 → 037`, `#142 → 142`, `#295 → 295`).
String padIssueNumber(String issue) {
  final n = int.tryParse(issue.trim());
  if (n == null) return issue.trim();
  return n.toString().padLeft(3, '0');
}

/// The full branch name for an [issue] with the given [title]:
/// `<NNN>-<slug>`. Throws [ArgumentError] when the title yields no slug.
String branchNameFor({required String issue, required String title}) {
  final slug = deriveSlug(title);
  if (slug.isEmpty) {
    throw ArgumentError(
      'issue title "$title" has no alphanumeric content to build a branch slug from',
    );
  }
  return '${padIssueNumber(issue)}-$slug';
}
