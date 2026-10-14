import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/petty_cash/presentation/petty_cash_hub_screen.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> pumpHub(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light,
          home: const PettyCashHubScreen(),
        ),
      ),
    ));
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 100));
  }

  for (final size in const [Size(1024, 700), Size(1440, 900)]) {
    testWidgets(
        'new user sees the guide in the empty state at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
      await pumpHub(tester, size);
      expect(find.text('1. Add Supervisor'), findsOneWidget);
      expect(find.textContaining('Advances given'), findsOneWidget);
      expect(find.text('How it works'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('"How it works" opens the guide dialog and closes again',
      (tester) async {
    await db.pettyCashDao.insertWallet(PettyCashWalletsCompanion.insert(
        supervisorName: 'Site Eng', phone: '9999999999'));
    await pumpHub(tester, const Size(1280, 800));
    // With a supervisor the empty-state guide is gone.
    expect(find.text('1. Add Supervisor'), findsNothing);

    await tester.tap(find.text('How it works'));
    await tester.pumpAndSettle();
    expect(find.text('How does Petty Cash work?'), findsOneWidget);
    expect(find.text('1. Add Supervisor'), findsOneWidget);
    expect(find.text('4. Return Cash'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(find.text('How does Petty Cash work?'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
