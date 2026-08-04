import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/services/security_service.dart';

class AuthState {
  final bool isUnlocked;
  final bool isConfigured;
  final String? error;

  const AuthState({
    required this.isUnlocked,
    required this.isConfigured,
    this.error,
  });

  AuthState copyWith({
    bool? isUnlocked,
    bool? isConfigured,
    String? error,
    bool clearError = false,
  }) =>
      AuthState(
        isUnlocked: isUnlocked ?? this.isUnlocked,
        isConfigured: isConfigured ?? this.isConfigured,
        error: clearError ? null : (error ?? this.error),
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(const AuthState(isUnlocked: false, isConfigured: true)) {
    _init();
  }

  Future<void> _init() async {
    await SecurityService.ensureInitialized();
    state = state.copyWith(isUnlocked: false, isConfigured: true);
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
    await SecurityService.updatePin(newPin);
    return true;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
