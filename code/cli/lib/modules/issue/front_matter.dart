/// Parses an "issue as code" markdown document: a YAML front-matter block
/// (between two `---` fences) followed by the markdown body.
///
/// The front-matter carries everything needed to create the GitHub issue —
/// `title`, `repo` (owner/repo), `labels`, `spec`, `covers` (the AC ids), `lang`
/// — so the `.md` is the single source of truth. The body (everything after the
/// closing fence) is what gets published; the front-matter is not.
library;

import 'package:yaml/yaml.dart';

class IssueDoc {
  final Map<String, dynamic> meta;
  final String body;

  IssueDoc(this.meta, this.body);

  String? get title => _string('title');
  String? get repo => _string('repo');
  String? get lang => _string('lang');

  List<String> get labels => _stringList('labels');
  List<String> get covers => _stringList('covers');

  String? _string(String key) {
    final v = meta[key];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  List<String> _stringList(String key) {
    final v = meta[key];
    if (v is List) {
      return v.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}

/// Parses [content] into an [IssueDoc], or returns `null` when it has no
/// well-formed leading `---` front-matter fence.
IssueDoc? parseIssueDoc(String content) {
  final lines = content.split('\n');
  if (lines.isEmpty || lines.first.trim() != '---') return null;

  var end = -1;
  for (var i = 1; i < lines.length; i++) {
    if (lines[i].trim() == '---') {
      end = i;
      break;
    }
  }
  if (end == -1) return null;

  final fm = lines.sublist(1, end).join('\n');
  final body = lines.sublist(end + 1).join('\n').trim();

  final meta = <String, dynamic>{};
  try {
    final parsed = loadYaml(fm);
    if (parsed is YamlMap) {
      parsed.forEach((k, v) => meta[k.toString()] = _plain(v));
    }
  } catch (_) {
    return null;
  }

  return IssueDoc(meta, body);
}

dynamic _plain(dynamic v) {
  if (v is YamlList) return v.map(_plain).toList();
  if (v is YamlMap) {
    return v.map((k, val) => MapEntry(k.toString(), _plain(val)));
  }
  return v;
}
