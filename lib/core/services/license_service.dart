import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nex_ledger/firebase_options.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// What the app should do after checking the license.
enum LicenseGate {
  /// Still checking (app just started).
  checking,

  /// No license key has been entered on this computer yet.
  needsKey,

  /// The key typed in does not exist.
  invalidKey,

  /// Everything fine: let the user in.
  active,

  /// The company was blocked (for example non-payment).
  blocked,

  /// This key is already used on the allowed number of other computers.
  deviceLimit,

  /// Maintenance is on, for everyone or for this company.
  maintenance,

  /// Could not reach the license server (and no offline grace is left).
  offline,
}

class LicenseResult {
  final LicenseGate gate;

  /// Text to show the user (blocked / maintenance message, error detail).
  final String message;
  final String companyName;
  final String key;
  final int maxDevices;
  final int deviceCount;
  final String deviceName;
  final String deviceId;

  /// True when we let the user in only because of the offline grace time.
  final bool viaOfflineGrace;

  const LicenseResult({
    required this.gate,
    this.message = '',
    this.companyName = '',
    this.key = '',
    this.maxDevices = 1,
    this.deviceCount = 0,
    this.deviceName = '',
    this.deviceId = '',
    this.viaOfflineGrace = false,
  });

  bool get isActive => gate == LicenseGate.active;
}

/// Checks this computer's license against the Firestore table in the
/// project (see RELEASING.md / firestore.rules). Talks to Firestore through
/// its web (REST) interface because the native SDK is unreliable on desktop.
///
/// Rules of the game:
///  * the app must reach the server to start (unless `offlineGraceHours` in
///    `config/global` allows a short offline period after a good check);
///  * a blocked company is locked out completely;
///  * a key works on at most `maxDevices` computers; the first computers to
///    register win, later ones are locked.
class LicenseService {
  LicenseService({
    http.Client? client,
    this.projectId,
    this.apiKey,
    Directory? directory,
    DateTime Function()? now,
    String? deviceNameOverride,
    String? osOverride,
    this.appVersion = '',
    this.timeout = const Duration(seconds: 8),
  })  : _client = client ?? http.Client(),
        _directory = directory,
        _now = now ?? DateTime.now,
        _deviceNameOverride = deviceNameOverride,
        _osOverride = osOverride;

  final http.Client _client;
  final String? projectId;
  final String? apiKey;
  final Directory? _directory;
  final DateTime Function() _now;
  final String? _deviceNameOverride;
  final String? _osOverride;
  final String appVersion;
  final Duration timeout;

  /// How often the device row is refreshed ("last used").
  static const Duration touchEvery = Duration(hours: 1);

  /// The most computers one license row can list (matches firestore.rules).
  static const int maxListedDevices = 10;

  String get _project =>
      projectId ?? DefaultFirebaseOptions.currentPlatform.projectId;
  String get _apiKey => apiKey ?? DefaultFirebaseOptions.currentPlatform.apiKey;

  // ------------------------------------------------------------ local file

  Future<File> _file() async {
    final dir = _directory ?? await getApplicationSupportDirectory();
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return File(p.join(dir.path, 'license.json'));
  }

  Future<Map<String, dynamic>> _readLocal() async {
    try {
      final f = await _file();
      if (!f.existsSync()) return {};
      final v = jsonDecode(f.readAsStringSync());
      return v is Map<String, dynamic> ? v : {};
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeLocal(Map<String, dynamic> data) async {
    try {
      final f = await _file();
      f.writeAsStringSync(jsonEncode(data));
    } catch (e) {
      debugPrint('LicenseService: could not save license file: $e');
    }
  }

  static String _newDeviceId() {
    final r = Random.secure();
    final hex =
        List.generate(24, (_) => r.nextInt(16).toRadixString(16)).join();
    return 'd$hex'; // starts with a letter so it is a safe field name
  }

  /// The saved license key, if any (for the Settings screen).
  Future<String> savedKey() async =>
      (await _readLocal())['key'] as String? ?? '';

  // ----------------------------------------------------------------- public

  /// Checks the saved key. With no saved key the answer is [LicenseGate.needsKey].
  Future<LicenseResult> verify() async {
    final local = await _readLocal();
    final key = (local['key'] as String? ?? '').trim();
    if (key.isEmpty) return const LicenseResult(gate: LicenseGate.needsKey);
    return _check(key, local);
  }

  /// Checks [rawKey] and, if it exists, saves it on this computer.
  Future<LicenseResult> activate(String rawKey) async {
    final key = normalizeKey(rawKey);
    if (key.isEmpty) {
      return const LicenseResult(
          gate: LicenseGate.invalidKey,
          message: 'Please enter your license key.');
    }
    final local = await _readLocal();
    final previous = (local['key'] as String? ?? '');
    final fresh = {
      'deviceId': local['deviceId'] ?? _newDeviceId(),
      // a different key starts a fresh history
      if (previous == key) ...{
        'lastVerifiedAt': local['lastVerifiedAt'],
        'lastGate': local['lastGate'],
        'graceHours': local['graceHours'],
      },
    };
    final result = await _check(key, fresh, saveKeyOnFound: true);
    return result;
  }

  /// Upper-case, spaces removed: " nex-ab12 " -> "NEX-AB12".
  static String normalizeKey(String raw) =>
      raw.toUpperCase().replaceAll(RegExp(r'\s+'), '');

  // ----------------------------------------------------------------- engine

  Future<LicenseResult> _check(
    String key,
    Map<String, dynamic> local, {
    bool saveKeyOnFound = false,
  }) async {
    final deviceId = (local['deviceId'] as String?) ?? _newDeviceId();
    final deviceName = _deviceNameOverride ?? _safeHostName();
    final os = _osOverride ?? Platform.operatingSystem;

    Map<String, dynamic> save(String gate,
        {bool verified = false, int? grace}) {
      final m = <String, dynamic>{
        'key': key,
        'deviceId': deviceId,
        'lastVerifiedAt': verified
            ? _now().toUtc().toIso8601String()
            : local['lastVerifiedAt'],
        'lastGate': gate,
        'graceHours': grace ?? local['graceHours'] ?? 0,
      };
      return m;
    }

    LicenseResult make(LicenseGate gate,
            {String message = '',
            Map<String, dynamic>? license,
            bool grace = false}) =>
        LicenseResult(
          gate: gate,
          message: message,
          companyName: (license?['companyName'] as String?) ?? '',
          key: key,
          maxDevices: (license?['maxDevices'] as int?) ?? 1,
          deviceCount: ((license?['devices'] as Map?)?.length) ?? 0,
          deviceName: deviceName,
          deviceId: deviceId,
          viaOfflineGrace: grace,
        );

    try {
      final global = await _getDoc('config/global');
      final graceHours = (global?['offlineGraceHours'] as int?) ?? 0;

      var license = await _getDoc('licenses/$key');
      if (license == null) {
        // Unknown key. Forget it so the user is asked again.
        if (!saveKeyOnFound) {
          final f = await _file();
          if (f.existsSync()) {
            await _writeLocal({'deviceId': deviceId});
          }
        }
        return make(LicenseGate.invalidKey,
            message:
                'This license key was not found. Please check it and try again.');
      }
      if (saveKeyOnFound) {
        await _writeLocal(save('checking', grace: graceHours));
      }

      // Make sure this computer is on the list (and keep "last used" fresh).
      license = await _registerDevice(key, license, deviceId, deviceName, os);

      final devices = _devicesOf(license);
      final maxDevices = (license['maxDevices'] as int?) ?? 1;
      final allowed = _isAllowed(devices, deviceId, maxDevices);

      final status = (license['status'] as String?) ?? 'active';
      final companyMsg = (license['blockedMessage'] as String?) ?? '';

      LicenseGate gate;
      var message = '';
      if (status == 'blocked') {
        gate = LicenseGate.blocked;
        message = companyMsg.isNotEmpty
            ? companyMsg
            : 'Your access has been suspended. Please contact Aldrich Energy.';
      } else if (global?['maintenance'] == true) {
        gate = LicenseGate.maintenance;
        message = (global?['maintenanceMessage'] as String?) ??
            'The application is under maintenance. Please try again later.';
      } else if (license['maintenance'] == true) {
        gate = LicenseGate.maintenance;
        message = (license['maintenanceMessage'] as String?) ??
            'The application is under maintenance. Please try again later.';
      } else if (!allowed) {
        gate = LicenseGate.deviceLimit;
        message = 'This license is already in use on another computer. '
            'Please contact Aldrich Energy to add this computer.';
      } else {
        gate = LicenseGate.active;
      }

      await _writeLocal(save(gate.name,
          verified: gate == LicenseGate.active, grace: graceHours));
      return make(gate, message: message, license: license);
    } on _ServerRefused catch (e) {
      return _offline(key, local, make, e.toString());
    } on TimeoutException {
      return _offline(key, local, make, 'The server did not answer in time.');
    } on SocketException {
      return _offline(key, local, make, 'No internet connection.');
    } on http.ClientException {
      return _offline(key, local, make, 'No internet connection.');
    } on FormatException {
      return _offline(key, local, make, 'Unexpected answer from the server.');
    }
  }

  LicenseResult _offline(
    String key,
    Map<String, dynamic> local,
    LicenseResult Function(LicenseGate,
            {String message, Map<String, dynamic>? license, bool grace})
        make,
    String why,
  ) {
    // A short offline period is allowed only after a good check, and never
    // when the last answer was "blocked" or similar.
    final graceHours = (local['graceHours'] as int?) ?? 0;
    final last = DateTime.tryParse((local['lastVerifiedAt'] as String?) ?? '');
    if (graceHours > 0 &&
        local['lastGate'] == LicenseGate.active.name &&
        last != null &&
        _now().toUtc().difference(last) < Duration(hours: graceHours)) {
      return make(LicenseGate.active, grace: true);
    }
    return make(LicenseGate.offline,
        message: 'NexLedger needs an internet connection to start. $why');
  }

  String _safeHostName() {
    try {
      return Platform.localHostname;
    } catch (_) {
      return 'Unknown computer';
    }
  }

  // --------------------------------------------------------------- devices

  /// Devices as `{id: {name, os, appVersion, firstSeen, lastSeen}}`.
  Map<String, Map<String, dynamic>> _devicesOf(Map<String, dynamic> license) {
    final raw = license['devices'];
    if (raw is! Map) return {};
    return {
      for (final e in raw.entries)
        if (e.value is Map)
          '${e.key}': Map<String, dynamic>.from(e.value as Map)
    };
  }

  /// The first [maxDevices] computers (by first-seen time) are allowed.
  bool _isAllowed(Map<String, Map<String, dynamic>> devices, String deviceId,
      int maxDevices) {
    if (!devices.containsKey(deviceId)) return false;
    final order = devices.entries.toList()
      ..sort((a, b) {
        final c =
            ('${a.value['firstSeen']}').compareTo('${b.value['firstSeen']}');
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    final index = order.indexWhere((e) => e.key == deviceId);
    return index >= 0 && index < maxDevices;
  }

  Future<Map<String, dynamic>> _registerDevice(
    String key,
    Map<String, dynamic> license,
    String deviceId,
    String deviceName,
    String os,
  ) async {
    final devices = _devicesOf(license);
    final mine = devices[deviceId];
    final nowIso = _now().toUtc().toIso8601String();

    if (mine == null) {
      if (devices.length >= maxListedDevices) return license; // list is full
      await _patch(key, deviceId, {
        'name': deviceName,
        'os': os,
        'appVersion': appVersion,
        'firstSeen': nowIso,
        'lastSeen': nowIso,
      });
      // read again: another computer may have registered at the same time
      return await _getDoc('licenses/$key') ?? license;
    }

    final last = DateTime.tryParse('${mine['lastSeen']}');
    final stale = last == null || _now().toUtc().difference(last) >= touchEvery;
    final changed =
        mine['appVersion'] != appVersion || mine['name'] != deviceName;
    if (stale || changed) {
      await _patch(key, deviceId, {
        'name': deviceName,
        'os': os,
        'appVersion': appVersion,
        'lastSeen': nowIso,
      });
      final updated = Map<String, dynamic>.from(license);
      final d = Map<String, dynamic>.from(license['devices'] as Map);
      d[deviceId] = {
        ...mine,
        'name': deviceName,
        'os': os,
        'appVersion': appVersion,
        'lastSeen': nowIso
      };
      updated['devices'] = d;
      return updated;
    }
    return license;
  }

  // ------------------------------------------------------------ Firestore

  Uri _uri(String path, [Map<String, dynamic>? query]) => Uri.https(
        'firestore.googleapis.com',
        '/v1/projects/$_project/databases/(default)/documents/$path',
        {'key': _apiKey, ...?query},
      );

  /// A document as plain Dart values, or null when it does not exist.
  Future<Map<String, dynamic>?> _getDoc(String path) async {
    final res = await _client.get(_uri(path)).timeout(timeout);
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw _ServerRefused('Server answered ${res.statusCode}.');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return _decodeFields(
        (body['fields'] as Map?)?.cast<String, dynamic>() ?? {});
  }

  Future<void> _patch(
      String key, String deviceId, Map<String, String> fields) async {
    final base = _uri('licenses/$key');
    final withMask = Uri(
      scheme: base.scheme,
      host: base.host,
      path: base.path,
      query: [
        'key=${Uri.encodeQueryComponent(_apiKey)}',
        for (final f in fields.keys)
          'updateMask.fieldPaths=${Uri.encodeQueryComponent('devices.$deviceId.$f')}',
      ].join('&'),
    );
    final body = {
      'fields': {
        'devices': {
          'mapValue': {
            'fields': {
              deviceId: {
                'mapValue': {
                  'fields': {
                    for (final e in fields.entries)
                      e.key: {'stringValue': e.value}
                  }
                }
              }
            }
          }
        }
      }
    };
    final res = await _client
        .patch(withMask,
            headers: {'content-type': 'application/json'},
            body: jsonEncode(body))
        .timeout(timeout);
    if (res.statusCode != 200) {
      throw _ServerRefused(
          'Could not register this computer (${res.statusCode}).');
    }
  }

  static Map<String, dynamic> _decodeFields(Map<String, dynamic> fields) => {
        for (final e in fields.entries)
          e.key: _decodeValue((e.value as Map).cast<String, dynamic>())
      };

  static dynamic _decodeValue(Map<String, dynamic> v) {
    if (v.containsKey('stringValue')) return v['stringValue'];
    if (v.containsKey('booleanValue')) return v['booleanValue'];
    if (v.containsKey('integerValue')) {
      return int.tryParse('${v['integerValue']}') ?? 0;
    }
    if (v.containsKey('doubleValue')) return (v['doubleValue'] as num).toInt();
    if (v.containsKey('timestampValue')) return v['timestampValue'];
    if (v.containsKey('mapValue')) {
      final f =
          ((v['mapValue'] as Map)['fields'] as Map?)?.cast<String, dynamic>();
      return _decodeFields(f ?? {});
    }
    return null;
  }
}

class _ServerRefused implements Exception {
  final String message;
  _ServerRefused(this.message);
  @override
  String toString() => message;
}
