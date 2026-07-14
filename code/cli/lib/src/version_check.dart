/// Shared utility for checking the latest available version from GitHub releases.
library;

import 'dart:convert';
import 'dart:io';

const String _repo = 'ccisnedev/inquiry';

/// Result of a version check against GitHub releases.
class VersionCheckResult {
  final String? latestVersion;
  final bool updateAvailable;
  final String? error;

  const VersionCheckResult({
    this.latestVersion,
    required this.updateAvailable,
    this.error,
  });
}

/// Default deadline for the whole version check. This is advisory telemetry on
/// the side of `iq doctor` / `iq upgrade` — it must never delay the user.
const Duration kVersionCheckTimeout = Duration(seconds: 5);

/// Checks if a newer version is available on GitHub releases.
///
/// Returns [VersionCheckResult] with [updateAvailable] = true if
/// [currentVersion] differs from the latest release tag.
/// Silent on network failures — returns [updateAvailable] = false.
///
/// [timeout] bounds the **entire** exchange, not just the TCP handshake:
/// `HttpClient.connectionTimeout` alone leaves a connection that is accepted but
/// never answered waiting forever, which hung `iq doctor` indefinitely.
Future<VersionCheckResult> checkLatestVersion({
  required String currentVersion,
  HttpClient? httpClient,
  Duration timeout = kVersionCheckTimeout,
}) async {
  final client = httpClient ?? HttpClient();
  final ownsClient = httpClient == null;
  try {
    client.connectionTimeout = timeout;
    return await _fetchLatest(client, currentVersion).timeout(timeout);
  } catch (_) {
    // Network failure, stalled response, timeout, DNS, etc. — silent.
    return const VersionCheckResult(updateAvailable: false);
  } finally {
    // force: a plain close() waits for in-flight connections to finish, which
    // is precisely what a stalled request never does.
    if (ownsClient) client.close(force: true);
  }
}

Future<VersionCheckResult> _fetchLatest(
  HttpClient client,
  String currentVersion,
) async {
  final releaseUrl = Uri.parse(
    'https://api.github.com/repos/$_repo/releases/latest',
  );
  final request = await client.getUrl(releaseUrl);
  request.headers.set('Accept', 'application/vnd.github+json');
  request.headers.set('User-Agent', 'inquiry-cli/$currentVersion');
  final response = await request.close();

  if (response.statusCode != 200) {
    await response.drain<void>();
    return const VersionCheckResult(updateAvailable: false);
  }

  final body = await response.transform(utf8.decoder).join();
  final release = jsonDecode(body) as Map<String, dynamic>;
  final tagName = release['tag_name'] as String;
  final latestVersion =
      tagName.startsWith('v') ? tagName.substring(1) : tagName;

  return VersionCheckResult(
    latestVersion: latestVersion,
    updateAvailable: _isNewerVersion(latestVersion, currentVersion),
  );
}

/// Returns true only if [remote] is strictly greater than [current]
/// using semantic versioning (major.minor.patch).
bool _isNewerVersion(String remote, String current) {
  final r = _parseSemver(remote);
  final c = _parseSemver(current);
  if (r == null || c == null) return false;
  if (r[0] != c[0]) return r[0] > c[0];
  if (r[1] != c[1]) return r[1] > c[1];
  return r[2] > c[2];
}

List<int>? _parseSemver(String version) {
  final parts = version.split('.');
  if (parts.length != 3) return null;
  final nums = parts.map(int.tryParse).toList();
  if (nums.any((n) => n == null)) return null;
  return nums.cast<int>();
}
