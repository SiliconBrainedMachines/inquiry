import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:inquiry_cli/modules/specification/workspace.dart';

void main() {
  late Directory tempDir;
  String root() => tempDir.path;

  Directory mkReq(String rel) {
    final d = Directory(p.join(tempDir.path, p.joinAll(rel.split('/'))));
    d.createSync(recursive: true);
    return d;
  }

  setUp(() => tempDir = Directory.systemTemp.createTempSync('iq_ws_'));
  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('datedFolder / dateStamp', () {
    test('date stamp is compact YYYYMMDD, zero-padded', () {
      expect(dateStamp(DateTime(2026, 7, 9)), '20260709');
      expect(datedFolder('motores-fase-8', DateTime(2026, 12, 31)),
          '20261231-motores-fase-8');
    });
  });

  group('writeActiveRequisition / activeRequisitionPath', () {
    test('round-trips the active pointer', () {
      writeActiveRequisition(root(),
          slug: 'x',
          relDir: 'docs/requisitions/20260709-x',
          lang: 'es',
          isoDate: '2026-07-09');
      expect(activeRequisitionPath(root()), 'docs/requisitions/20260709-x');
    });

    test('returns null when the pointer is absent', () {
      expect(activeRequisitionPath(root()), isNull);
    });
  });

  group('resolveRequisitionDir', () {
    test('no slug → follows the active pointer', () {
      final dir = mkReq('docs/requisitions/20260709-alpha');
      writeActiveRequisition(root(),
          slug: 'alpha',
          relDir: 'docs/requisitions/20260709-alpha',
          lang: 'en',
          isoDate: '2026-07-09');
      expect(resolveRequisitionDir(root()), dir.path);
    });

    test('explicit slug → matches the dated folder', () {
      final dir = mkReq('docs/requisitions/20260709-beta');
      expect(resolveRequisitionDir(root(), 'beta'), dir.path);
    });

    test('explicit slug → exact (undated) folder also matches', () {
      final dir = mkReq('docs/requisitions/gamma');
      expect(resolveRequisitionDir(root(), 'gamma'), dir.path);
    });

    test('multiple dated matches → newest (lexically last) wins', () {
      mkReq('docs/requisitions/20260101-dup');
      final newer = mkReq('docs/requisitions/20261231-dup');
      expect(resolveRequisitionDir(root(), 'dup'), newer.path);
    });

    test('falls back to legacy repo-root requisitions/<slug>/', () {
      final dir = mkReq('requisitions/legacy');
      expect(resolveRequisitionDir(root(), 'legacy'), dir.path);
    });

    test('returns null when nothing matches', () {
      expect(resolveRequisitionDir(root(), 'missing'), isNull);
      expect(resolveRequisitionDir(root()), isNull);
    });
  });
}
