import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    if (_pinCtrl.text.isEmpty) return;
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
                            color: const Color(0xFF4F46E5).withOpacity(0.15),
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
                        const Text(
                          'Financial Ledger Security Lock',
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
                            labelText: 'Enter Security PIN',
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
                        if (authState.error != null)
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
                                    authState.error!,
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
                              _loading ? 'Verifying...' : 'Unlock NexLedger',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Default PIN Help Pill Banner
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline_rounded,
                                  size: 15, color: Color(0xFF818CF8)),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Default PIN: 1234 (Changeable in Settings)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
