import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/services/license_service.dart';
import 'package:nex_ledger/features/license/providers/license_provider.dart';

/// Shown instead of the app whenever the license is not "active": first
/// start (enter key), wrong key, blocked, maintenance, no internet, or a key
/// used on too many computers. Nothing else in the app can be reached.
class LicenseScreen extends ConsumerStatefulWidget {
  const LicenseScreen({super.key});

  @override
  ConsumerState<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends ConsumerState<LicenseScreen> {
  final _keyCtrl = TextEditingController();

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (ref.read(licenseProvider).busy) return;
    ref.read(licenseProvider.notifier).activate(_keyCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(licenseProvider);

    final askForKey =
        s.gate == LicenseGate.needsKey || s.gate == LicenseGate.invalidKey;

    final (IconData icon, Color color, String title, String body) =
        switch (s.gate) {
      LicenseGate.checking => (
          Icons.verified_user_outlined,
          const Color(0xFF1F5FBF),
          'Checking your license…',
          'Please wait a moment.'
        ),
      LicenseGate.needsKey => (
          Icons.vpn_key_rounded,
          const Color(0xFF1F5FBF),
          'Activate NexLedger',
          'Enter the license key you received from Aldrich Energy. '
              'You need an internet connection for this step.'
        ),
      LicenseGate.invalidKey => (
          Icons.vpn_key_rounded,
          const Color(0xFFDC2626),
          'License key not accepted',
          s.message
        ),
      LicenseGate.blocked => (
          Icons.block_rounded,
          const Color(0xFFDC2626),
          'Access suspended',
          s.message
        ),
      LicenseGate.maintenance => (
          Icons.build_circle_outlined,
          const Color(0xFFD97706),
          'Under maintenance',
          s.message
        ),
      LicenseGate.deviceLimit => (
          Icons.computer_rounded,
          const Color(0xFFDC2626),
          'License already in use',
          s.message
        ),
      LicenseGate.offline => (
          Icons.wifi_off_rounded,
          const Color(0xFFD97706),
          'Internet connection needed',
          s.message
        ),
      LicenseGate.active => (
          Icons.check_circle_rounded,
          const Color(0xFF059669),
          'Licensed',
          ''
        ),
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Icon(icon, size: 34, color: color),
                    ),
                    const SizedBox(height: 18),
                    Text(title,
                        key: const Key('license_title'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    if (body.isNotEmpty)
                      Text(body,
                          key: const Key('license_message'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: Color(0xFF475569))),
                    const SizedBox(height: 22),
                    if (askForKey) ...[
                      TextField(
                        key: const Key('license_key_field'),
                        controller: _keyCtrl,
                        autofocus: true,
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                            hintText: 'NEX-XXXX-XXXX-XXXX'),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (s.gate == LicenseGate.checking || s.busy)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(strokeWidth: 3)),
                      )
                    else if (askForKey)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: const Key('license_activate'),
                          onPressed: _submit,
                          child: const Text('Activate'),
                        ),
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const Key('license_retry'),
                          onPressed: () =>
                              ref.read(licenseProvider.notifier).check(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Try again'),
                        ),
                      ),
                    if (s.deviceName.isNotEmpty &&
                        s.gate != LicenseGate.checking) ...[
                      const SizedBox(height: 18),
                      Text('This computer: ${s.deviceName}',
                          style: const TextStyle(
                              fontSize: 11.5, color: Color(0xFF94A3B8))),
                    ],
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
