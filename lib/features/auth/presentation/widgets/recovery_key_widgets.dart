import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/services/security_service.dart';
import 'package:nex_ledger/features/auth/providers/auth_provider.dart';

/// The recovery key in a large, selectable box with a Copy button.
class RecoveryKeyBox extends StatelessWidget {
  final String recoveryKey;
  const RecoveryKeyBox({super.key, required this.recoveryKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              recoveryKey,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: Color(0xFFFBBF24),
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copy recovery key',
            icon: const Icon(Icons.copy_rounded, color: Color(0xFF94A3B8)),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: recoveryKey));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recovery key copied')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Full-screen "save your recovery key" step. The user cannot continue until
/// they confirm they have stored the key.
class RecoveryKeyScreen extends StatefulWidget {
  final String recoveryKey;
  final VoidCallback onContinue;
  const RecoveryKeyScreen(
      {super.key, required this.recoveryKey, required this.onContinue});

  @override
  State<RecoveryKeyScreen> createState() => _RecoveryKeyScreenState();
}

class _RecoveryKeyScreenState extends State<RecoveryKeyScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: const Color(0xFF1E293B),
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.vpn_key_rounded, color: Color(0xFFFBBF24)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Save your Recovery Key',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'If you ever forget your PIN, this key is the only way to set a new one. '
                      'Write it on paper or save it somewhere safe, away from this computer. '
                      'It is shown only once.',
                      style: TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
                    ),
                    const SizedBox(height: 18),
                    RecoveryKeyBox(recoveryKey: widget.recoveryKey),
                    const SizedBox(height: 14),
                    CheckboxListTile(
                      value: _saved,
                      onChanged: (v) => setState(() => _saved = v ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFF1F5FBF),
                      title: const Text(
                        'I have saved this recovery key',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: FilledButton(
                        onPressed: _saved ? widget.onContinue : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1F5FBF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Continue to NexLedger',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Forgot PIN?" — enter the recovery key and choose a new PIN.
class ForgotPinDialog extends ConsumerStatefulWidget {
  const ForgotPinDialog({super.key});

  @override
  ConsumerState<ForgotPinDialog> createState() => _ForgotPinDialogState();
}

class _ForgotPinDialogState extends ConsumerState<ForgotPinDialog> {
  final _keyCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _busy = false;
  bool _hasKey = true;

  @override
  void initState() {
    super.initState();
    SecurityService.hasRecoveryKey().then((v) {
      if (mounted) setState(() => _hasKey = v);
    });
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _pinCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_pinCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'The two PINs do not match.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final problem = await ref
        .read(authProvider.notifier)
        .resetPinWithRecoveryKey(_keyCtrl.text, _pinCtrl.text);
    if (!mounted) return;
    if (problem != null) {
      setState(() {
        _busy = false;
        _error = problem;
      });
      return;
    }
    // Success: the login screen now shows the replacement recovery key.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasKey) {
      return AlertDialog(
        title: const Text('No recovery key found'),
        content: const Text(
          'A recovery key was not created on this computer, so the PIN cannot be reset from here.\n\n'
          'Please contact your NexLedger support person for help. '
          'Your accounting data is not lost.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }
    return AlertDialog(
      title: const Text('Reset PIN with Recovery Key'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _keyCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Recovery Key',
                  hintText: 'XXXX-XXXX-XXXX-XXXX',
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'New PIN (min 4 digits)',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Confirm new PIN',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                onSubmitted: (_) => _busy ? null : _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!,
                    style: const TextStyle(
                        color: Color(0xFFDC2626), fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: const Text('Reset PIN'),
        ),
      ],
    );
  }
}

/// Settings: create a new recovery key after confirming the current PIN.
/// Creating a key replaces (and disables) any earlier one.
class NewRecoveryKeyDialog extends ConsumerStatefulWidget {
  const NewRecoveryKeyDialog({super.key});

  @override
  ConsumerState<NewRecoveryKeyDialog> createState() =>
      _NewRecoveryKeyDialogState();
}

class _NewRecoveryKeyDialogState extends ConsumerState<NewRecoveryKeyDialog> {
  final _pinCtrl = TextEditingController();
  String? _newKey;
  String? _error;
  bool _busy = false;
  bool _hadKey = false;

  @override
  void initState() {
    super.initState();
    SecurityService.hasRecoveryKey().then((v) {
      if (mounted) setState(() => _hadKey = v);
    });
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final key = await ref
        .read(authProvider.notifier)
        .regenerateRecoveryKey(_pinCtrl.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (key == null) {
        _error = 'Incorrect PIN.';
      } else {
        _newKey = key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_newKey != null) {
      return AlertDialog(
        title: const Text('Your new Recovery Key'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Write this down and keep it safe, away from this computer. '
                'It is shown only once. Any earlier recovery key no longer works.',
              ),
              const SizedBox(height: 14),
              RecoveryKeyBox(recoveryKey: _newKey!),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('I have saved it'),
          ),
        ],
      );
    }
    return AlertDialog(
      title: const Text('Create Recovery Key'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _hadKey
                  ? 'This creates a NEW key and disables your current one.'
                  : 'A recovery key lets you set a new PIN if you ever forget it.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinCtrl,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter your current PIN',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                errorText: _error,
              ),
              onSubmitted: (_) => _busy ? null : _create(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: const Text('Create Key'),
        ),
      ],
    );
  }
}
