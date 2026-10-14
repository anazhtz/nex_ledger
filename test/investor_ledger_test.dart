import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/theme/app_theme.dart';
import 'package:nex_ledger/features/reports/data/ledger_repository.dart';
import 'package:nex_ledger/features/reports/presentation/ledgers_hub_screen.dart';
import 'package:nex_ledger/features/reports/providers/ledger_providers.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = LedgerRepository(db);
  });

  tearDown(() async => db.close());

  group('investors', () {
    test('adding the same name twice (any case / spacing) reuses one investor',
        () async {
      final a = await repo.addInvestor(name: 'Ramesh Kumar');
      final b = await repo.addInvestor(name: '  ramesh kumar ');
      expect(b, a);
      expect(await db.select(db.investors).get(), hasLength(1));
      expect(() => repo.addInvestor(name: '   '), throwsArgumentError);
    });

    test('per-investor totals, filtering, and P&L isolation', () async {
      final ramesh = await repo.addInvestor(name: 'Ramesh');
      final suresh = await repo.addInvestor(name: 'Suresh');

      await repo.recordOwnerCapital(
          amount: 500000, date: DateTime(2026, 8, 1), investorId: ramesh);
      await repo.recordOwnerCapital(
          amount: 300000, date: DateTime(2026, 8, 2), investorId: suresh);
      await repo.recordOwnerDrawings(
          amount: 50000, date: DateTime(2026, 8, 5), investorId: ramesh);
      // Old-style entry with no investor
      await repo.recordOwnerCapital(amount: 100000, date: DateTime(2026, 8, 6));

      final sums = await repo.watchInvestorSummaries().first;
      final byName = {for (final s in sums) s.name: s};
      expect(byName['Ramesh']!.invested, 500000);
      expect(byName['Ramesh']!.withdrawn, 50000);
      expect(byName['Ramesh']!.net, 450000);
      expect(byName['Suresh']!.net, 300000);
      expect(byName['Owner (General)']!.net, 100000);

      // Whole ledger vs one investor
      final all = await repo.watchPersonalLedger().first;
      expect(all.summary.closingBalance, 850000);
      expect(all.entries, hasLength(4));

      final r = await repo.watchPersonalLedger(investorId: ramesh).first;
      expect(r.entries, hasLength(2));
      expect(r.summary.totalCredit, 500000);
      expect(r.summary.totalDebit, 50000);
      expect(r.summary.closingBalance, 450000);
      expect(r.entries.every((e) => e.title.contains('Ramesh')), isTrue);

      // Money rules unchanged: cash moves, P&L never does.
      expect(await db.transactionDao.watchCashBalance().first, 850000);
      final txns = await db.transactionDao.watchAllRawTransactions().first;
      expect(txns.where((t) => t.affectsPnl), isEmpty);
    });
  });

  testWidgets('dialog: add a new investor while recording capital',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    container.read(activeLedgerTabProvider.notifier).state =
        LedgerType.personal;

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: ScreenUtilInit(
        designSize: const Size(1440, 900),
        builder: (context, _) => MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(body: LedgersHubScreen()),
        ),
      ),
    ));
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('+ Add Investment'));
    await tester.pumpAndSettle();
    expect(find.text('Add Investment / Capital'), findsOneWidget);

    // choose "+ Add new investor..."
    await tester.tap(find.text('Owner (General)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ Add new investor...').last);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'New Investor Name *'), 'Anil Shah');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount (₹) *'), '250000');
    await tester.tap(find.text('Save Capital'));
    await tester
        .runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
    await tester.pumpAndSettle();

    final investors = await db.select(db.investors).get();
    expect(investors.map((i) => i.name), ['Anil Shah']);
    final txns = await db.select(db.transactions).get();
    expect(txns, hasLength(1));
    expect(txns.single.investorId, investors.single.id);
    expect(txns.single.type, TransactionType.ownerCapital);
    expect(txns.single.amount, 250000);
    expect(tester.takeException(), isNull);
  });
}
