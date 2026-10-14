import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/services/security_service.dart';
import 'package:nex_ledger/features/auth/presentation/login_screen.dart';
import 'package:nex_ledger/features/auth/presentation/widgets/recovery_key_widgets.dart';

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('nex_login_test');
    SecurityService.directoryOverride = dir;
  });

  tearDown(() async {
    SecurityService.directoryOverride = null;
    await dir.delete(recursive: true);
  });

  /// Lets real file I/O finish, then flushes the resulting UI updates.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 120)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpLogin(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final router = GoRouter(initialLocation: '/login', routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/', builder: (_, __) => const Scaffold(body: Text('HOME'))),
    ]);
    await tester.pumpWidget(ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) => MaterialApp.router(routerConfig: router),
      ),
    ));
    // AuthNotifier reads the PIN file on start-up; give it real time.
    await settle(tester);
  }

  Future<void> typePin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
  }

  testWidgets('first run: create PIN, then must save the recovery key',
      (tester) async {
    await pumpLogin(tester);
    expect(find.text('Create a Security PIN to protect your data'),
        findsOneWidget);
    expect(find.text('Forgot PIN?'), findsNothing);

    await typePin(tester, '4821');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await typePin(tester, '4821');
    await tester.tap(find.text('Save PIN & Open'));
    await settle(tester);

    // Key screen, no way in until the box is ticked
    expect(find.text('Save your Recovery Key'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
    final continueBtn =
        find.widgetWithText(FilledButton, 'Continue to NexLedger');
    expect(tester.widget<FilledButton>(continueBtn).onPressed, isNull);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(tester.widget<FilledButton>(continueBtn).onPressed, isNotNull);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(await SecurityService.verifyPin('4821'), isTrue);
    expect(await SecurityService.hasRecoveryKey(), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('forgot PIN: recovery key resets it and a new key is issued',
      (tester) async {
    await SecurityService.updatePin('4821');
    final oldKey = await SecurityService.createRecoveryKey();
    await pumpLogin(tester);

    await tester.tap(find.text('Forgot PIN?'));
    await tester.pumpAndSettle();
    expect(find.text('Reset PIN with Recovery Key'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Recovery Key'), oldKey.toLowerCase());
    await tester.enterText(
        find.widgetWithText(TextField, 'New PIN (min 4 digits)'), '7392');
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm new PIN'), '7392');
    await tester.tap(find.text('Reset PIN'));
    await settle(tester);
    await tester.pumpAndSettle();

    expect(find.text('Save your Recovery Key'), findsOneWidget);
    expect(find.text(oldKey), findsNothing, reason: 'a NEW key is issued');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester
        .tap(find.widgetWithText(FilledButton, 'Continue to NexLedger'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(await SecurityService.verifyPin('7392'), isTrue);
    expect(await SecurityService.verifyPin('4821'), isFalse);
    expect(await SecurityService.verifyRecoveryKey(oldKey), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrong recovery key or mismatched PINs change nothing',
      (tester) async {
    await SecurityService.updatePin('4821');
    await SecurityService.createRecoveryKey();
    await pumpLogin(tester);

    await tester.tap(find.text('Forgot PIN?'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextField, 'Recovery Key'), 'AAAA-AAAA-AAAA-AAAA');
    await tester.enterText(
        find.widgetWithText(TextField, 'New PIN (min 4 digits)'), '7392');
    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm new PIN'), '7392');
    await tester.tap(find.text('Reset PIN'));
    await settle(tester);
    await tester.pumpAndSettle();
    expect(find.textContaining('not correct'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextField, 'Confirm new PIN'), '0000');
    await tester.tap(find.text('Reset PIN'));
    await tester.pumpAndSettle();
    expect(find.textContaining('do not match'), findsOneWidget);

    expect(await SecurityService.verifyPin('4821'), isTrue);
    expect(find.text('Save your Recovery Key'), findsNothing);
  });

  testWidgets('an older install with a PIN but no key is told what to do',
      (tester) async {
    await SecurityService.updatePin('4821'); // no recovery key created
    await pumpLogin(tester);
    await tester.tap(find.text('Forgot PIN?'));
    await tester.pumpAndSettle();
    expect(find.text('No recovery key found'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('No recovery key found'), findsNothing);
  });

  testWidgets(
      'Settings: new recovery key needs the PIN and retires the old key',
      (tester) async {
    await SecurityService.updatePin('4821');
    final oldKey = await SecurityService.createRecoveryKey();

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => const NewRecoveryKeyDialog()),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.textContaining('disables your current one'), findsOneWidget);

    // wrong PIN: no key issued
    await tester.enterText(find.byType(TextField), '0000');
    await tester.tap(find.text('Create Key'));
    await settle(tester);
    expect(find.text('Incorrect PIN.'), findsOneWidget);
    expect(await SecurityService.verifyRecoveryKey(oldKey), isTrue);

    // right PIN: a new key is shown, the old one stops working
    await tester.enterText(find.byType(TextField), '4821');
    await tester.tap(find.text('Create Key'));
    await settle(tester);
    expect(find.text('Your new Recovery Key'), findsOneWidget);
    expect(find.text(oldKey), findsNothing);
    expect(await SecurityService.verifyRecoveryKey(oldKey), isFalse);
    expect(tester.takeException(), isNull);
  });
}
