import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/services/remote_config_service.dart';

class MaintenanceState {
  final bool isUnderMaintenance;
  final String title;
  final String message;
  final bool isChecking;

  const MaintenanceState({
    required this.isUnderMaintenance,
    required this.title,
    required this.message,
    this.isChecking = false,
  });

  MaintenanceState copyWith({
    bool? isUnderMaintenance,
    String? title,
    String? message,
    bool? isChecking,
  }) {
    return MaintenanceState(
      isUnderMaintenance: isUnderMaintenance ?? this.isUnderMaintenance,
      title: title ?? this.title,
      message: message ?? this.message,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

class MaintenanceNotifier extends StateNotifier<MaintenanceState> {
  StreamSubscription? _subscription;

  MaintenanceNotifier()
      : super(
          MaintenanceState(
            isUnderMaintenance: RemoteConfigService.instance.isUnderMaintenance,
            title: RemoteConfigService.instance.maintenanceTitle,
            message: RemoteConfigService.instance.maintenanceMessage,
          ),
        ) {
    _init();
  }

  void _init() {
    _subscription = RemoteConfigService.instance.onConfigUpdated.listen((_) {
      _syncWithService();
    });
    _syncWithService();
  }

  void _syncWithService() {
    state = state.copyWith(
      isUnderMaintenance: RemoteConfigService.instance.isUnderMaintenance,
      title: RemoteConfigService.instance.maintenanceTitle,
      message: RemoteConfigService.instance.maintenanceMessage,
    );
  }

  Future<void> checkStatus() async {
    state = state.copyWith(isChecking: true);
    await RemoteConfigService.instance.fetchAndActivate();
    _syncWithService();
    state = state.copyWith(isChecking: false);
  }

  void toggleLocalOverride(bool enabled) {
    RemoteConfigService.instance.setLocalMaintenanceOverride(enabled);
    _syncWithService();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final maintenanceProvider =
    StateNotifierProvider<MaintenanceNotifier, MaintenanceState>((ref) {
  return MaintenanceNotifier();
});
