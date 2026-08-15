import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:nex_ledger/firebase_options.dart';

class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  bool _isInitialized = false;
  FirebaseRemoteConfig? _remoteConfig;

  // Local fallback values in case Firebase fails to initialize or fetch via native SDK
  bool _fallbackIsUnderMaintenance = false;
  String _fallbackTitle = 'System Under Maintenance';
  String _fallbackMessage =
      'This application is currently unavailable or undergoing maintenance. Please contact your system administrator.';

  // Software update parameters
  String _fallbackLatestVersion = '1.0.0';
  String _fallbackReleaseNotes = 'Bug fixes and performance improvements.';
  String _fallbackDownloadUrlWindows = '';
  String _fallbackDownloadUrlMacos = '';

  final StreamController<void> _updateController =
      StreamController<void>.broadcast();
  Stream<void> get onConfigUpdated => _updateController.stream;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set default parameters
      await _remoteConfig!.setDefaults({
        'is_under_maintenance': false,
        'maintenance_title': _fallbackTitle,
        'maintenance_message': _fallbackMessage,
        'latest_version': _fallbackLatestVersion,
        'release_notes': _fallbackReleaseNotes,
        'download_url_windows': _fallbackDownloadUrlWindows,
        'download_url_macos': _fallbackDownloadUrlMacos,
      });

      // Configure fetch settings
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(seconds: 10)
              : const Duration(hours: 1),
        ),
      );

      // Fetch and activate initial values
      await fetchAndActivate();

      // Subscribe to real-time updates if supported
      _remoteConfig!.onConfigUpdated.listen((event) async {
        await _remoteConfig!.activate();
        _updateController.add(null);
      }, onError: (err) {
        debugPrint('RemoteConfig stream error: $err');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('Firebase RemoteConfig initialization warning: $e');
      await _fetchViaRestApi();
      _isInitialized = true;
    }
  }

  bool get isUnderMaintenance {
    if (_fallbackIsUnderMaintenance) return true;
    if (_remoteConfig != null) {
      try {
        return _remoteConfig!.getBool('is_under_maintenance');
      } catch (e) {
        debugPrint('Error reading is_under_maintenance: $e');
      }
    }
    return _fallbackIsUnderMaintenance;
  }

  String get maintenanceTitle {
    if (_remoteConfig != null) {
      try {
        final val = _remoteConfig!.getString('maintenance_title');
        if (val.isNotEmpty) return val;
      } catch (e) {
        debugPrint('Error reading maintenance_title: $e');
      }
    }
    return _fallbackTitle;
  }

  String get maintenanceMessage {
    if (_remoteConfig != null) {
      try {
        final val = _remoteConfig!.getString('maintenance_message');
        if (val.isNotEmpty) return val;
      } catch (e) {
        debugPrint('Error reading maintenance_message: $e');
      }
    }
    return _fallbackMessage;
  }

  String get latestVersion {
    if (_remoteConfig != null) {
      try {
        final val = _remoteConfig!.getString('latest_version');
        if (val.isNotEmpty) return val;
      } catch (_) {}
    }
    return _fallbackLatestVersion;
  }

  String get releaseNotes {
    if (_remoteConfig != null) {
      try {
        final val = _remoteConfig!.getString('release_notes');
        if (val.isNotEmpty) return val;
      } catch (_) {}
    }
    return _fallbackReleaseNotes;
  }

  String get downloadUrlWindows {
    if (_remoteConfig != null) {
      try {
        final val = _remoteConfig!.getString('download_url_windows');
        if (val.isNotEmpty) return val;
      } catch (_) {}
    }
    return _fallbackDownloadUrlWindows;
  }

  String get downloadUrlMacos {
    if (_remoteConfig != null) {
      try {
        final val = _remoteConfig!.getString('download_url_macos');
        if (val.isNotEmpty) return val;
      } catch (_) {}
    }
    return _fallbackDownloadUrlMacos;
  }

  String get currentPlatformDownloadUrl {
    if (Platform.isWindows) {
      return downloadUrlWindows.isNotEmpty
          ? downloadUrlWindows
          : downloadUrlMacos;
    } else if (Platform.isMacOS) {
      return downloadUrlMacos.isNotEmpty
          ? downloadUrlMacos
          : downloadUrlWindows;
    }
    return downloadUrlWindows;
  }

  Future<bool> fetchAndActivate() async {
    bool nativeSuccess = false;
    if (_remoteConfig != null) {
      try {
        nativeSuccess = await _remoteConfig!.fetchAndActivate();
        if (nativeSuccess) {
          _updateController.add(null);
          return true;
        }
      } catch (e) {
        debugPrint('RemoteConfig native fetch error: $e');
      }
    }

    // Fallback to Firebase Remote Config REST API if native SDK fails on desktop
    final restSuccess = await _fetchViaRestApi();
    return restSuccess || nativeSuccess;
  }

  Future<bool> _fetchViaRestApi() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      final url = Uri.parse(
        'https://firebaseremoteconfig.googleapis.com/v1/projects/${options.projectId}/namespaces/firebase:fetch?key=${options.apiKey}',
      );

      final client = HttpClient();
      final request = await client.postUrl(url);
      request.headers.set('content-type', 'application/json');

      final bodyData = jsonEncode({
        'sdkVersion': '2.0.0',
        'appId': options.appId,
        'appInstanceId': 'desktop-client-instance',
      });
      request.write(bodyData);

      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;

        if (json.containsKey('entries')) {
          final entries = json['entries'] as Map<String, dynamic>;
          if (entries.containsKey('is_under_maintenance')) {
            final rawVal = entries['is_under_maintenance'];
            _fallbackIsUnderMaintenance =
                rawVal == 'true' || rawVal == true || rawVal == '1';
          }
          if (entries.containsKey('maintenance_title')) {
            _fallbackTitle = entries['maintenance_title'].toString();
          }
          if (entries.containsKey('maintenance_message')) {
            _fallbackMessage = entries['maintenance_message'].toString();
          }
          if (entries.containsKey('latest_version')) {
            _fallbackLatestVersion = entries['latest_version'].toString();
          }
          if (entries.containsKey('release_notes')) {
            _fallbackReleaseNotes = entries['release_notes'].toString();
          }
          if (entries.containsKey('download_url_windows')) {
            _fallbackDownloadUrlWindows =
                entries['download_url_windows'].toString();
          }
          if (entries.containsKey('download_url_macos')) {
            _fallbackDownloadUrlMacos =
                entries['download_url_macos'].toString();
          }

          debugPrint('RemoteConfig REST API fetch successful!');
          _updateController.add(null);
          return true;
        }
      } else {
        debugPrint(
            'RemoteConfig REST API returned HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('RemoteConfig REST API fetch error: $e');
    }
    return false;
  }

  // Debug helper to manually set local maintenance mode (for testing without Firebase Console)
  void setLocalMaintenanceOverride(bool enabled, {String? title, String? message}) {
    _fallbackIsUnderMaintenance = enabled;
    if (title != null) _fallbackTitle = title;
    if (message != null) _fallbackMessage = message;
    _updateController.add(null);
  }
}
