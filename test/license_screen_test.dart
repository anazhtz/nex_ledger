import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/app.dart';
import 'package:nex_ledger/core/services/license_service.dart';
import 'package:nex_ledger/core/services/security_service.dart';
import 'package:nex_ledger/features/license/presentation/license_screen.dart';
import 'package:nex_ledger/features/license/providers/license_provider.dart';

import 'helpers/fake_firestore.dart';

void main() {
  late Directory dir;
  late FakeFirestore fs;
  late ProviderContainer container;

  // The notifier keeps a re-check timer; stop it before the test ends.
  void licTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    });
  }

  setUp(() {
    dir = Directory.systemTemp.createTempSync('license_ui');
    fs = FakeFirestore();
    fs.docs['licenses/NEX-AAAA'] = {
      'companyName': 'Builder One',
      'status': 'active',
      'maxDevices': 1,
    };
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> pump(WidgetTester tester) async {
    container = ProviderContainer(overrides: [
      licenseProvider.overrideWith((ref) => LicenseNotifier(
            enforce: true,
            service: LicenseService(
              client: fs.client,
              projectId: 't',
              apiKey: 'k',
              directory: dir,
              deviceNameOverride: 'TEST-PC',
              osOverride: 'windows',
              appVersion: '1.0.9',
            ),
          )),
    ]);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: LicenseScreen()),
    ));
    for (var i = 0; i < 5; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  licTest('first start asks for the key; wrong key shows an error',
      (tester) async {
    await pump(tester);
    expect(find.text('Activate NexLedger'), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('license_key_field')), 'nex-bad');
    await tester.tap(find.byKey(const Key('license_activate')));
    for (var i = 0; i < 4; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text('License key not accepted'), findsOneWidget);
    expect(find.textContaining('was not found'), findsOneWidget);
    expect(container.read(licenseProvider).gate, LicenseGate.invalidKey);
  });

  licTest('right key unlocks', (tester) async {
    await pump(tester);
    await tester.enterText(
        find.byKey(const Key('license_key_field')), ' nex-aaaa ');
    await tester.tap(find.byKey(const Key('license_activate')));
    for (var i = 0; i < 4; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    final s = container.read(licenseProvider);
    expect(s.gate, LicenseGate.active);
    expect(s.companyName, 'Builder One');
  });

  licTest('blocked: message shown, no key box, no way in', (tester) async {
    // already activated earlier
    await LicenseService(
            client: fs.client,
            projectId: 't',
            apiKey: 'k',
            directory: dir,
            deviceNameOverride: 'TEST-PC',
            osOverride: 'windows')
        .activate('NEX-AAAA');
    fs.docs['licenses/NEX-AAAA']!['status'] = 'blocked';
    fs.docs['licenses/NEX-AAAA']!['blockedMessage'] = 'Please pay the invoice.';
    await pump(tester);
    expect(find.text('Access suspended'), findsOneWidget);
    expect(find.text('Please pay the invoice.'), findsOneWidget);
    expect(find.byKey(const Key('license_key_field')), findsNothing);
    expect(find.byKey(const Key('license_retry')), findsOneWidget);

    // owner unblocks; "Try again" lets the client in
    fs.docs['licenses/NEX-AAAA']!['status'] = 'active';
    await tester.tap(find.byKey(const Key('license_retry')));
    for (var i = 0; i < 4; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(container.read(licenseProvider).gate, LicenseGate.active);
  });

  licTest('no internet: friendly screen with Try again', (tester) async {
    await LicenseService(
            client: fs.client,
            projectId: 't',
            apiKey: 'k',
            directory: dir,
            deviceNameOverride: 'TEST-PC',
            osOverride: 'windows')
        .activate('NEX-AAAA');
    fs.offline = true;
    await pump(tester);
    expect(find.text('Internet connection needed'), findsOneWidget);
    expect(find.textContaining('internet connection'), findsWidgets);
    expect(find.text('This computer: TEST-PC'), findsOneWidget);
  });

  licTest('the whole app is locked behind the license: any route goes to it',
      (tester) async {
    await LicenseService(
            client: fs.client,
            projectId: 't',
            apiKey: 'k',
            directory: dir,
            deviceNameOverride: 'TEST-PC',
            osOverride: 'windows')
        .activate('NEX-AAAA');
    fs.docs['licenses/NEX-AAAA']!['status'] = 'blocked';
    container = ProviderContainer(overrides: [
      licenseProvider.overrideWith((ref) => LicenseNotifier(
            enforce: true,
            service: LicenseService(
                client: fs.client,
                projectId: 't',
                apiKey: 'k',
                directory: dir,
                deviceNameOverride: 'TEST-PC',
                osOverride: 'windows'),
          )),
    ]);
    SecurityService.directoryOverride = dir;
    addTearDown(() => SecurityService.directoryOverride = null);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: container, child: const NexLedgerApp()));
    for (var i = 0; i < 5; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 30)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byType(LicenseScreen), findsOneWidget);
    expect(find.text('Access suspended'), findsOneWidget);
  });
}
