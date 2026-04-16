/// Reads framework assets (agents, skills) from disk.
///
/// Assets live alongside the compiled binary in an `assets/` folder.
/// In production, [root] is derived from `Platform.resolvedExecutable`.
/// In tests, [root] is a temporary directory.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

class Assets {
  final String root;

  Assets({required this.root});

  /// Resolves [relativePath] under `<root>/assets/`.
  String path(String relativePath) =>
      p.join(root, 'assets', p.joinAll(relativePath.split('/')));

  /// Reads the file at [relativePath] as a UTF-8 string.
  String loadString(String relativePath) =>
      File(path(relativePath)).readAsStringSync();

  /// Lists immediate child directory names under `<root>/assets/[dirPath]`.
  List<String> listDirectory(String dirPath) {
    final dir = Directory(path(dirPath));
    return dir
        .listSync()
        .whereType<Directory>()
        .map((d) => p.basename(d.path))
        .toList();
  }
}
