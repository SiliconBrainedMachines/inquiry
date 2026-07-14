import 'dart:async';
import 'dart:io';

import 'package:inquiry_cli/src/version_check.dart';
import 'package:test/test.dart';

/// An [HttpClient] whose connection is *established* but which never produces a
/// response — the real-world failure that hung `iq doctor` for 1m40s. Only
/// `getUrl`/`close` are meaningful; everything else is unreachable in this path.
class _StallingHttpClient implements HttpClient {
  bool closed = false;

  /// A real field: the code under test sets it, and a `noSuchMethod` fallback
  /// would throw and make the test pass for the wrong reason.
  @override
  Duration? connectionTimeout;

  @override
  Future<HttpClientRequest> getUrl(Uri url) => Completer<HttpClientRequest>().future;

  @override
  void close({bool force = false}) => closed = true;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('checkLatestVersion', () {
    test('gives up when the server accepts but never responds (no hang)', () async {
      final client = _StallingHttpClient();

      final result = await checkLatestVersion(
        currentVersion: '0.19.0',
        httpClient: client,
        timeout: const Duration(milliseconds: 200),
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () => fail(
          'checkLatestVersion never returned — the request has no overall '
          'deadline (connectionTimeout only bounds the TCP handshake).',
        ),
      );

      expect(result.updateAvailable, isFalse);
      expect(result.latestVersion, isNull);
    });

    test('a stalled check is silent — it reports no update, not an error', () async {
      final result = await checkLatestVersion(
        currentVersion: '0.19.0',
        httpClient: _StallingHttpClient(),
        timeout: const Duration(milliseconds: 200),
      ).timeout(const Duration(seconds: 5));

      expect(result.updateAvailable, isFalse);
    });
  });
}
