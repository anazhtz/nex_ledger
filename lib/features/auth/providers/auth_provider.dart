import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/services/security_service.dart';

class AuthState {
  final bool isUnlocked;
  final bool isConfigured;

  /// False until the PIN file has been checked at startup.
  final bool isReady;
  final String? error;

  const AuthState({
    required this.isUnlocked,
    required this.isConfigured,
    this.isReady = true,
    this.error,
  });

  AuthState copyWith({
    bool? isUnlocked,
    bool? isConfigured,
    bool? isReady,
    String? error,
    bool clearError = false,
  }) =>
      AuthState(
        isUnlocked: isUnlocked ?? this.isUnlocked,
        isConfigured: isConfigured ?? this.isConfigured,
        isReady: isReady ?? this.isReady,
        error: clearError ? null : (error ?? this.error),
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
    state =
        state.copyWith(isUnlocked: true, isConfigured: true, clearError: true);
    return null;
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
