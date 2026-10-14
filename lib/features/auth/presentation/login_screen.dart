import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/services/security_service.dart';
import 'package:nex_ledger/features/auth/presentation/widgets/recovery_key_widgets.dart';
import 'package:nex_ledger/features/auth/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _pinCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  /// First PIN typed during setup; non-null while the user is confirming it.
  String? _firstPin;
  String? _localError;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    if (_pinCtrl.text.isEmpty) return;
    final auth = ref.read(authProvider);
    if (!auth.isReady) return;
    if (!auth.isConfigured) {
      await _submitSetup();
      return;
    }
    setState(() => _loading = true);

    try {
      final success =
          await ref.read(authProvider.notifier).unlock(_pinCtrl.text);
      if (success && mounted) {
        context.go('/');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Two-step PIN creation: enter, then confirm.
  Future<void> _submitSetup() async {
    final entered = _pinCtrl.text;
    if (_firstPin == null) {
      final problem = SecurityService.validateNewPin(entered);
      setState(() {
        _localError = problem;
        if (problem == null) _firstPin = entered;
        _pinCtrl.clear();
      });
      return;
    }
    if (entered != _firstPin) {
      setState(() {
        _localError = 'PINs do not match. Start again.';
        _firstPin = null;
        _pinCtrl.clear();
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final problem = await ref.read(authProvider.notifier).setupPin(entered);
      if (problem != null) {
        setState(() {
          _localError = problem;
          _firstPin = null;
          _pinCtrl.clear();
        });
      } else if (mounted) {
        // The recovery-key screen takes over (see build); reset local state.
        setState(() {
          _localError = null;
          _firstPin = null;
          _pinCtrl.clear();
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _appendNum(String num) {
    if (_pinCtrl.text.length < 8) {
      setState(() {
        _pinCtrl.text += num;
      });
    }
  }

  void _deleteNum() {
    if (_pinCtrl.text.isNotEmpty) {
      setState(() {
        _pinCtrl.text = _pinCtrl.text.substring(0, _pinCtrl.text.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isSetup = authState.isReady && !authState.isConfigured;
    final errorText = _localError ?? authState.error;

    // Right after creating / resetting a PIN: show the recovery key first.
    final newKey = authState.recoveryKeyToShow;
    if (newKey != null) {
      return RecoveryKeyScreen(
        recoveryKey: newKey,
        onContinue: () {
          ref.read(authProvider.notifier).acknowledgeRecoveryKey();
          context.go('/');
        },
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): _submitPin,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): _submitPin,
        const SingleActivator(LogicalKeyboardKey.backspace): _deleteNum,
        const SingleActivator(LogicalKeyboardKey.digit0): () => _appendNum('0'),
        const SingleActivator(LogicalKeyboardKey.digit1): () => _appendNum('1'),
        const SingleActivator(LogicalKeyboardKey.digit2): () => _appendNum('2'),
        const SingleActivator(LogicalKeyboardKey.digit3): () => _appendNum('3'),
        const SingleActivator(LogicalKeyboardKey.digit4): () => _appendNum('4'),
        const SingleActivator(LogicalKeyboardKey.digit5): () => _appendNum('5'),
        const SingleActivator(LogicalKeyboardKey.digit6): () => _appendNum('6'),
        const SingleActivator(LogicalKeyboardKey.digit7): () => _appendNum('7'),
        const SingleActivator(LogicalKeyboardKey.digit8): () => _appendNum('8'),
        const SingleActivator(LogicalKeyboardKey.digit9): () => _appendNum('9'),
        const SingleActivator(LogicalKeyboardKey.numpad0): () =>
            _appendNum('0'),
        const SingleActivator(LogicalKeyboardKey.numpad1): () =>
            _appendNum('1'),
        const SingleActivator(LogicalKeyboardKey.numpad2): () =>
            _appendNum('2'),
        const SingleActivator(LogicalKeyboardKey.numpad3): () =>
            _appendNum('3'),
        const SingleActivator(LogicalKeyboardKey.numpad4): () =>
            _appendNum('4'),
        const SingleActivator(LogicalKeyboardKey.numpad5): () =>
            _appendNum('5'),
        const SingleActivator(LogicalKeyboardKey.numpad6): () =>
            _appendNum('6'),
        const SingleActivator(LogicalKeyboardKey.numpad7): () =>
            _appendNum('7'),
        const SingleActivator(LogicalKeyboardKey.numpad8): () =>
            _appendNum('8'),
        const SingleActivator(LogicalKeyboardKey.numpad9): () =>
            _appendNum('9'),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: const Color(0xFF0F172A), // Enterprise Dark Slate
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.black.withOpacity(0.4),
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    side: const BorderSide(color: Color(0xFF334155), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(36),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Brand Logo Container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F5FBF).withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    const Color(0xFF6366F1).withOpacity(0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              width: 56.r,
                              height: 56.r,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Titles
                        const Text(
                          'NexLedger',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSetup
                              ? 'Create a Security PIN to protect your data'
                              : 'Financial Ledger Security Lock',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // PIN Input Field
                        TextField(
                          controller: _pinCtrl,
                          obscureText: _obscure,
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            labelText: !isSetup
                                ? 'Enter Security PIN'
                                : (_firstPin == null
                                    ? 'Create new PIN (min 4 digits)'
                                    : 'Confirm new PIN'),
                            labelStyle:
                                const TextStyle(color: Color(0xFF94A3B8)),
                            fillColor: const Color(0xFF0F172A),
                            filled: true,
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: Color(0xFF6366F1)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF94A3B8),
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFF334155)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF6366F1), width: 2),
                            ),
                          ),
                          onSubmitted: (_) => _submitPin(),
                        ),
                        const SizedBox(height: 12),

                        // Error Message Display
                        if (errorText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7F1D1D).withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFEF4444)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    size: 16, color: Color(0xFFFCA5A5)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorText,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFCA5A5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Numeric Keypad Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.8,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            if (index == 9) {
                              return const SizedBox
                                  .shrink(); // Empty bottom-left
                            } else if (index == 10) {
                              return _buildKeyButton(
                                  '0', () => _appendNum('0'));
                            } else if (index == 11) {
                              return _buildKeyButton(
                                '⌫',
                                _deleteNum,
                                isAction: true,
                              );
                            } else {
                              final number = '${index + 1}';
                              return _buildKeyButton(
                                  number, () => _appendNum(number));
                            }
                          },
                        ),

                        const SizedBox(height: 24),

                        // Unlock Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _loading ? null : _submitPin,
                            icon: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.lock_open_rounded, size: 20),
                            label: Text(
                              _loading
                                  ? 'Please wait...'
                                  : (isSetup
                                      ? (_firstPin == null
                                          ? 'Continue'
                                          : 'Save PIN & Open')
                                      : 'Unlock NexLedger'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1F5FBF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        if (!isSetup) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => showDialog<void>(
                              context: context,
                              builder: (_) => const ForgotPinDialog(),
                            ),
                            child: const Text(
                              'Forgot PIN?',
                              style: TextStyle(color: Color(0xFF94A3B8)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyButton(String label, VoidCallback onTap,
      {bool isAction = false}) {
    return Material(
      color: isAction ? const Color(0xFF334155) : const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isAction ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: isAction ? const Color(0xFF94A3B8) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
