import 'dart:io';

import 'package:inquiry_cli/src/git_utils.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('normalizeGitRootPath', () {
    test('normalizes standard git paths', () {
      expect(
        normalizeGitRootPath('C:/work/inquiry'),
        equals(p.normalize('C:/work/inquiry')),
      );
    });

    test('rewrites MSYS-style Windows roots before normalizing', () {
      final normalized = normalizeGitRootPath('/d/work/inquiry');

      if (Platform.isWindows) {
        expect(normalized, equals(p.normalize('D:/work/inquiry')));
      } else {
        expect(normalized, equals(p.normalize('/d/work/inquiry')));
      }
    });
  });
}