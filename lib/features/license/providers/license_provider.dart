import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/services/license_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LicenseState {
  final LicenseGate gate;
  final String message;
  final String companyName;
  final String key;
  final int maxDevices;
  final int deviceCount;
  final String deviceName;
  final bool viaOfflineGrace;

  /// A check or activation is running right now.
  final bool busy;

  const LicenseState({
    this.gate = LicenseGate.checking,
    this.message = '',
    this.companyName = '',
    this.key = '',
    this.maxDevices = 1,
    this.deviceCount = 0,
    this.deviceName = '',
    this.viaOfflineGrace = false,
    this.busy = false,
  });

  LicenseState copyWith({LicenseResult? result, bool? busy}) => LicenseState(
        gate: result?.gate ?? gate,
        message: result?.message ?? message,
        companyName: result?.companyName ?? companyName,
        key: result?.key ?? key,
        maxDevices: result?.maxDevices ?? maxDevices,
        deviceCount: result?.deviceCount ?? deviceCount,
        deviceName: result?.deviceName ?? deviceName,
        viaOfflineGrace: result?.viaOfflineGrace ?? viaOfflineGrace,
        busy: busy ?? this.busy,
      );
}

/// Whether this run must check the license. Developers running from the IDE
/// (debug) and automatic tests skip it; pass `--dart-define=FORCE_LICENSE=true`
/// to try the real flow in debug.
bool licenseEnforcedByDefault() {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
  if (const bool.fromEnvironment('FORCE_LICENSE')) return true;
  return !kDebugMode;
}

class LicenseNotifier extends StateNotifier<LicenseState> {
  LicenseNotifier({LicenseService? service, bool? enforce})
      : _service = service,
        super(const LicenseState()) {
    if (enforce ?? licenseEnforcedByDefault()) {
      _enforce = true;
      check();
      // keep checking while the app stays open
      _timer = Timer.periodic(recheckEvery, (_) => check(silent: true));
    } else {
      state = const LicenseState(
          gate: LicenseGate.active, companyName: 'Developer (not checked)');
    }
  }

  /// How often the license is checked while the app is running.
  static const Duration recheckEvery = Duration(hours: 6);

  LicenseService? _service;
  Timer? _timer;
  bool _enforce = false;

  Future<LicenseService> _svc() async {
    if (_service != null) return _service!;
    var version = '';
    try {
      version = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    return _service = LicenseService(appVersion: version);
  }

  /// Checks the saved key. [silent] keeps the current screen (no spinner).
  Future<void> check({bool silent = false}) async {
    if (!_enforce && state.gate == LicenseGate.active) return;
    if (!silent) state = state.copyWith(busy: true);
    final result = await (await _svc()).verify();
    if (!mounted) return;
    state = state.copyWith(result: result, busy: false);
  }

  Future<void> activate(String key) async {
    state = state.copyWith(busy: true);
    final result = await (await _svc()).activate(key);
    if (!mounted) return;
    state = state.copyWith(result: result, busy: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final licenseProvider =
    StateNotifierProvider<LicenseNotifier, LicenseState>((ref) {
  return LicenseNotifier();
});
