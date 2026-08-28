import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nex_ledger/core/services/remote_config_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Information about a detected app update.
class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String releaseNotes;
  final String htmlUrl;
  final String? downloadUrl;
  final DateTime? publishedAt;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.releaseNotes,
    required this.htmlUrl,
    this.downloadUrl,
    this.publishedAt,
  });
}

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  static const String repoOwner = 'anazhtz';
  static const String repoName = 'nex_ledger';

  /// Check for updates via Firebase Remote Config first (works with 100% private repo),
  /// with fallback to GitHub Releases API.
  Future<AppUpdateInfo?> checkForUpdates() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return null;
    String currentVersion = '1.0.0';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version;
    } catch (_) {}

    // 1. Check Firebase Remote Config
    final firebaseResult = await _checkFirebaseRemoteConfig(currentVersion);
    if (firebaseResult != null && firebaseResult.hasUpdate) {
      return firebaseResult;
    }

    // 2. Try GitHub Releases API
    final githubResult = await _checkGitHubReleases(currentVersion);
    if (githubResult != null) {
      return githubResult;
    }

    return firebaseResult ??
        AppUpdateInfo(
          currentVersion: currentVersion,
          latestVersion: currentVersion,
          hasUpdate: false,
          releaseNotes: 'You are on the latest version.',
          htmlUrl: 'https://github.com/$repoOwner/$repoName/releases',
          downloadUrl: null,
          publishedAt: null,
        );
  }

  Future<AppUpdateInfo?> _checkFirebaseRemoteConfig(String currentVersion) async {
    try {
      await RemoteConfigService.instance.fetchAndActivate();
      final remoteVersion = RemoteConfigService.instance.latestVersion;
      final releaseNotes = RemoteConfigService.instance.releaseNotes;
      final downloadUrl = RemoteConfigService.instance.currentPlatformDownloadUrl;

      final hasUpdate = isVersionHigher(remoteVersion, currentVersion);

      return AppUpdateInfo(
        currentVersion: currentVersion,
        latestVersion: remoteVersion,
        hasUpdate: hasUpdate,
        releaseNotes: releaseNotes,
        htmlUrl: downloadUrl.isNotEmpty ? downloadUrl : 'https://github.com/$repoOwner/$repoName/releases',
        downloadUrl: downloadUrl.isNotEmpty ? downloadUrl : null,
        publishedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('UpdateService RemoteConfig check notice: $e');
      return null;
    }
  }

  Future<AppUpdateInfo?> _checkGitHubReleases(String currentVersion) async {
    try {
      final url = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
      );

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'NexLedger-App',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) {
        debugPrint('UpdateService: GitHub returned HTTP ${response.statusCode}');
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rawTag = (json['tag_name'] as String? ?? '').replaceFirst('v', '');
      final releaseNotes = json['body'] as String? ?? 'Bug fixes and performance improvements.';
      final htmlUrl = json['html_url'] as String? ?? 'https://github.com/$repoOwner/$repoName/releases';
      final publishedAtStr = json['published_at'] as String?;
      final publishedAt = publishedAtStr != null ? DateTime.tryParse(publishedAtStr) : null;

      // Find appropriate asset for current OS
      String? downloadUrl;
      final assets = (json['assets'] as List<dynamic>?) ?? [];
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        final browserUrl = asset['browser_download_url'] as String?;

        if (Platform.isWindows && (name.endsWith('.exe') || name.endsWith('.msix') || name.endsWith('.zip'))) {
          downloadUrl = browserUrl;
          break;
        } else if (Platform.isMacOS && (name.endsWith('.dmg') || name.endsWith('.zip'))) {
          downloadUrl = browserUrl;
          break;
        }
      }

      downloadUrl ??= htmlUrl;
      final hasUpdate = isVersionHigher(rawTag, currentVersion);

      return AppUpdateInfo(
        currentVersion: currentVersion,
        latestVersion: rawTag,
        hasUpdate: hasUpdate,
        releaseNotes: releaseNotes,
        htmlUrl: htmlUrl,
        downloadUrl: downloadUrl,
        publishedAt: publishedAt,
      );
    } catch (e) {
      debugPrint('UpdateService GitHub check notice: $e');
      return null;
    }
  }

  /// Launch download URL or release page in default browser.
  Future<bool> openReleasePage(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Compares semantic versions (e.g. 1.0.1 > 1.0.0).
  bool isVersionHigher(String remote, String local) {
    if (remote.isEmpty || local.isEmpty) return false;
    final remoteClean = remote.replaceFirst('v', '').split('+').first;
    final localClean = local.replaceFirst('v', '').split('+').first;

    final remoteParts = remoteClean.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final localParts = localClean.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (remoteParts.length < 3) {
      remoteParts.add(0);
    }
    while (localParts.length < 3) {
      localParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (remoteParts[i] > localParts[i]) return true;
      if (remoteParts[i] < localParts[i]) return false;
    }
    return false;
  }
}
