import 'dart:io';

import 'package:inquiry_cli/src/cycle_context.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Runs a git command synchronously in [dir], failing the test on error.
void _git(String dir, List<String> args) {
  final r = Process.runSync('git', args, workingDirectory: dir);
  if (r.exitCode != 0) {
    fail('git ${args.join(' ')} failed: ${r.stderr}');
  }
}

void _initRepo(String dir) {
  _git(dir, ['init', '-q']);
  _git(dir, ['config', 'user.email', 'test@example.com']);
  _git(dir, ['config', 'user.name', 'test']);
  _git(dir, ['config', 'commit.gpgsign', 'false']);
  File(p.join(dir, 'README.md')).writeAsStringSync('# test\n');
  _git(dir, ['add', '.']);
  _git(dir, ['commit', '-q', '-m', 'init']);
}

void main() {
  group('CycleContext.normalizeBranch', () {
    test('returns null for detached HEAD token', () {
      expect(CycleContext.normalizeBranch('HEAD'), isNull);
    });

    test('returns null for empty/whitespace', () {
      expect(CycleContext.normalizeBranch(''), isNull);
      expect(CycleContext.normalizeBranch('   '), isNull);
    });

    test('returns the branch name when valid', () {
      expect(
        CycleContext.normalizeBranch('209-cleanroom-canonical-inquiry-root'),
        equals('209-cleanroom-canonical-inquiry-root'),
      );
    });
  });

  group('CycleContext.resolve', () {
    late Directory tmp;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('cycle_context_test_');
    });

    tearDown(() {
      tmp.deleteSync(recursive: true);
    });

    test('throws outside a git repository', () {
      expect(
        () => CycleContext.resolve(tmp.path),
        throwsA(isA<CycleResolutionException>()),
      );
    });

    test(
      'resolves project root, branch and inquiry root on a feature branch',
      () {
        _initRepo(tmp.path);
        _git(tmp.path, ['checkout', '-q', '-b', '209-canonical-root']);

        final ctx = CycleContext.resolve(tmp.path);

        // project root may be a symlink-resolved path on macOS; compare basenames.
        expect(Directory(ctx.projectRoot).existsSync(), isTrue);
        expect(ctx.branch, equals('209-canonical-root'));
        expect(ctx.isIdle, isFalse);
        expect(
          ctx.inquiryRoot,
          equals(p.join(ctx.projectRoot, 'cleanrooms', '209-canonical-root')),
        );
        expect(ctx.inquiryCliRoot, equals(ctx.projectRoot));
      },
    );

    test('rejects a branch name containing a path separator', () {
      _initRepo(tmp.path);
      _git(tmp.path, ['checkout', '-q', '-b', 'feature/foo']);

      expect(
        () => CycleContext.resolve(tmp.path),
        throwsA(isA<CycleResolutionException>()),
      );
    });

    test('detached HEAD resolves to derived IDLE (no inquiry root)', () {
      _initRepo(tmp.path);
      final head =
          Process.runSync('git', [
                'rev-parse',
                'HEAD',
              ], workingDirectory: tmp.path).stdout
              as String;
      _git(tmp.path, ['checkout', '-q', head.trim()]);

      final ctx = CycleContext.resolve(tmp.path);
      expect(ctx.isIdle, isTrue);
      expect(ctx.branch, isNull);
      expect(ctx.inquiryRoot, isNull);
    });
  });
}
