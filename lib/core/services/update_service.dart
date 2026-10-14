import 'dart:io';
import 'package:flutter/foundation.dart';
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

  /// Checks for a newer version through Firebase Remote Config (the keys
  /// `latest_version`, `release_notes`, `download_url_windows`,
  /// `download_url_macos`). Returns null when the check itself fails.
  Future<AppUpdateInfo?> checkForUpdates() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return null;
    String currentVersion = '1.0.0';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      currentVersion = packageInfo.version;
    } catch (_) {}

    try {
      await RemoteConfigService.instance.fetchAndActivate();
      final remoteVersion = RemoteConfigService.instance.latestVersion;
      final downloadUrl =
          RemoteConfigService.instance.currentPlatformDownloadUrl;
      return AppUpdateInfo(
        currentVersion: currentVersion,
        latestVersion: remoteVersion,
        hasUpdate: isVersionHigher(remoteVersion, currentVersion),
        releaseNotes: RemoteConfigService.instance.releaseNotes,
        htmlUrl: downloadUrl,
        downloadUrl: downloadUrl.isNotEmpty ? downloadUrl : null,
        publishedAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('UpdateService check notice: $e');
      return null;
    }
  }

  /// Launch download URL or release page in default browser.
  Future<bool> openReleasePage(String url) async {
    if (url.trim().isEmpty) return false;
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

    final remoteParts =
        remoteClean.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final localParts =
        localClean.split('.').map((e) => int.tryParse(e) ?? 0).toList();

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
