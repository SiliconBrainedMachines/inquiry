import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// The installer people run is the one the site serves, and there is only one.
///
/// This repository carried `install.ps1` twice — `code/cli/scripts/` and
/// `code/site/` — and the two had drifted **in both directions**: the served
/// copy alone had the right usage URL and told the reader to restart their
/// terminal; the repository copy alone read `GITHUB_TOKEN` to lift the
/// unauthenticated GitHub API rate limit. Each had something the other lacked,
/// so neither was simply "the old one".
///
/// That is the general shape rather than an accident: **the drifted copy is
/// always the one in production, because production is the copy nobody edits.**
/// A test that the two agree would have caught it, and would also have left two
/// files to keep agreeing. One file cannot disagree with itself.
///
/// The same defect was found and fixed in `macss`, where the consequence was
/// sharper — its served installer wrote an alias that resolved through PATH.
///
/// These tests **enumerate** the repository rather than naming the paths that
/// exist today, so a third copy added tomorrow fails on the day it is added.
void main() {
  // Tests run from code/cli.
  final repoRoot = Directory(p.join('..', '..'));

  /// Not source: caches, build output, and the VS Code integration test's
  /// downloaded editor, which vendors installers of its own.
  const skipped = {
    '.git',
    '.dart_tool',
    'build',
    'node_modules',
    '.vscode-test',
    'out',
  };

  List<String> findByName(String name) {
    final found = <String>[];

    void walk(Directory dir) {
      for (final entity in dir.listSync(followLinks: false)) {
        final base = p.basename(entity.path);
        if (entity is Directory) {
          if (skipped.contains(base)) continue;
          walk(entity);
        } else if (entity is File && base == name) {
          found.add(p.relative(entity.path, from: repoRoot.path).replaceAll(r'\', '/'));
        }
      }
    }

    walk(repoRoot);
    found.sort();
    return found;
  }

  group('one installer per platform, and the site owns it', () {
    for (final name in const ['install.ps1', 'install.sh']) {
      test('$name exists exactly once', () {
        final found = findByName(name);
        expect(
          found,
          hasLength(1),
          reason: 'Found ${found.length} copies of $name: $found. '
              'The release installer belongs in code/site/, which is the only '
              'place it is served from.',
        );
      });

      test('$name is the one the site serves', () {
        expect(findByName(name), ['code/site/$name']);
      });
    }
  });

  group('what the one copy has to keep', () {
    late String script;
    setUpAll(() {
      script = File(p.join('..', 'site', 'install.ps1')).readAsStringSync();
    });

    test('the iq shim runs the exe beside it, not whatever PATH finds', () {
      final shim = script
          .split('\n')
          .firstWhere(
            (l) => l.contains('iq.cmd') && l.contains('Set-Content'),
            orElse: () => '',
          );

      expect(shim, isNotEmpty, reason: 'install.ps1 no longer writes iq.cmd');
      expect(shim, contains(r'%~dp0'));
    });

    test('it still reads GITHUB_TOKEN, which only the repository copy did', () {
      // Unauthenticated the GitHub API allows 60 requests an hour per address,
      // which a shared network can exhaust. Losing this in the merge would be
      // the collapse quietly taking something away.
      expect(script, contains(r'$env:GITHUB_TOKEN'));
    });

    test('the token is never sent to the download host', () {
      // `browser_download_url` redirects to a different host. Windows
      // PowerShell 5.1 preserves an Authorization header across a redirect, so
      // passing the API headers to the download hands the user's token to a
      // CDN. The repository copy did exactly that; the served copy did not.
      // The merge has to keep the served copy's behaviour here, not the
      // repository copy's.
      final download = script
          .split('\n')
          .firstWhere((l) => l.contains('browser_download_url'), orElse: () => '');

      expect(download, isNotEmpty);
      expect(download, isNot(contains(r'$headers')));
    });
  });
}
