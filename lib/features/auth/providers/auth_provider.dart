import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/services/security_service.dart';

class AuthState {
  final bool isUnlocked;
  final bool isConfigured;

  /// False until the PIN file has been checked at startup.
  final bool isReady;
  final String? error;

  /// A freshly created recovery key waiting to be shown to the user. While it
  /// is set the app stays locked, so the key cannot be skipped by accident.
  final String? recoveryKeyToShow;

  const AuthState({
    required this.isUnlocked,
    required this.isConfigured,
    this.isReady = true,
    this.error,
    this.recoveryKeyToShow,
  });

  AuthState copyWith({
    bool? isUnlocked,
    bool? isConfigured,
    bool? isReady,
    String? error,
    bool clearError = false,
    String? recoveryKeyToShow,
    bool clearRecoveryKey = false,
  }) =>
      AuthState(
        isUnlocked: isUnlocked ?? this.isUnlocked,
        isConfigured: isConfigured ?? this.isConfigured,
        isReady: isReady ?? this.isReady,
        error: clearError ? null : (error ?? this.error),
        recoveryKeyToShow: clearRecoveryKey
            ? null
            : (recoveryKeyToShow ?? this.recoveryKeyToShow),
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(const AuthState(
            isUnlocked: false, isConfigured: true, isReady: false)) {
    _init();
  }

  Future<void> _init() async {
    final configured = await SecurityService.isPasscodeConfigured();
    state = state.copyWith(
        isUnlocked: false, isConfigured: configured, isReady: true);
  }

  /// First-run (or legacy default-PIN) setup: save the new PIN and unlock.
  Future<String?> setupPin(String pin) async {
    final problem = SecurityService.validateNewPin(pin);
    if (problem != null) return problem;
    await SecurityService.updatePin(pin);
    // Show the recovery key before letting the user in.
    final key = await SecurityService.createRecoveryKey();
    state = state.copyWith(
        isUnlocked: false,
        isConfigured: true,
        recoveryKeyToShow: key,
        clearError: true);
    return null;
  }

  /// The user has written the recovery key down — finish unlocking.
  void acknowledgeRecoveryKey() {
    state = state.copyWith(
        isUnlocked: true, clearRecoveryKey: true, clearError: true);
  }

  /// Forgotten PIN: set a new one using the recovery key. Returns an error
  /// message, or null on success (a replacement key is then shown).
  Future<String?> resetPinWithRecoveryKey(String key, String newPin) async {
    final weak = SecurityService.validateNewPin(newPin);
    if (weak != null) return weak;
    final newKey = await SecurityService.resetPinWithRecoveryKey(key, newPin);
    if (newKey == null) {
      return 'That recovery key is not correct. Check it and try again.';
    }
    state = state.copyWith(
        isUnlocked: false,
        isConfigured: true,
        recoveryKeyToShow: newKey,
        clearError: true);
    return null;
  }

  /// Settings: create a replacement recovery key (needs the current PIN).
  /// Returns the new key, or null when the PIN is wrong.
  Future<String?> regenerateRecoveryKey(String currentPin) async {
    if (!await SecurityService.verifyPin(currentPin)) return null;
    return SecurityService.createRecoveryKey();
  }

  /// Verify Security PIN and unlock app
  Future<bool> unlock(String pin) async {
    final valid = await SecurityService.verifyPin(pin);
    if (valid) {
      state = state.copyWith(isUnlocked: true, clearError: true);
      return true;
    } else {
      state = state.copyWith(
        isUnlocked: false,
        error: 'Invalid Security PIN. Please try again.',
      );
      return false;
    }
  }

  /// Lock app immediately
  void lock() {
    state = state.copyWith(isUnlocked: false, clearError: true);
  }

  /// Update Master Security PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    final valid = await SecurityService.verifyPin(oldPin);
    if (!valid) return false;
    if (SecurityService.validateNewPin(newPin) != null) return false;
    await SecurityService.updatePin(newPin);
    return true;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
