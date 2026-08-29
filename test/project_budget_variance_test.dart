import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/budgets/data/project_budget_repository.dart';
import 'package:nex_ledger/features/budgets/presentation/project_budget_variance_hub_screen.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/budget_warning_banner.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/set_project_budget_dialog.dart';

void main() {
  late AppDatabase db;
  late ProjectBudgetRepository budgetRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    budgetRepo = ProjectBudgetRepository(
      db.projectBudgetDao,
      db.projectDao,
      db.transactionDao,
      db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Project Budget vs Actual Variance & Over-Budget Warnings Audit', () {
    test(
        '1. Multi-Head Budget Setup, Progressive Spend, Real-Time Variance & Over-Budget Warnings',
        () async {
      // 1. Create a Project with Client Contract Sum of ₹50,00,000
      final projId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          code: 'PRJ-VILLA-2026',
          name: 'Emerald Bay Luxury Villa',
          clientName: const drift.Value('Mr. Rajiv Oberoi'),
          clientContractValue: const drift.Value(5000000.0), // ₹50 Lakhs
          type: ProjectType.project,
          status: ProjectStatus.active,
          startDate: DateTime(2026, 1, 1),
        ),
      );
      expect(projId, greaterThan(0));

      // 2. Set Multi-Head Cost Budgets: Total Target Cost = ₹35,00,000 (Target Profit = ₹15,00,000 / 30% Margin)
      // - Materials: ₹15,00,000
      // - Labour: ₹8,00,000
      // - Subcontract: ₹9,00,000
      // - Overheads: ₹3,00,000
      await budgetRepo.setProjectBudgets(
        projectId: projId,
        allocations: {
          BudgetCostHead.materials: 1500000.0,
          BudgetCostHead.labour: 800000.0,
          BudgetCostHead.subcontract: 900000.0,
          BudgetCostHead.equipmentOverhead: 300000.0,
        },
        alertThresholdPercentage: 85.0,
      );

      // Verify Initial Clean State (0 spent, 100% surplus)
      var summary = await budgetRepo.watchProjectBudgetSummary(projId).first;
      expect(summary, isNotNull);
      expect(summary!.totalAllocatedBudget, 3500000.0);
      expect(summary.totalActualCost, 0.0);
      expect(summary.netVariance, 3500000.0);
      expect(summary.overallUtilizationPercentage, 0.0);
      expect(summary.overallStatus, BudgetHealthStatus.healthy);
      expect(summary.overBudgetCategoriesCount, 0);

      // 3. Evaluate Real-Time Alert before entry:
      // Entering ₹12,00,000 materials (80% of ₹15L) -> Healthy (below 85% threshold)
      var alert = await budgetRepo.evaluateBudgetImpact(
        projectId: projId,
        costHead: BudgetCostHead.materials,
        newAmount: 1200000.0,
      );
      expect(alert.hasBudget, isTrue);
      expect(alert.projectedUtilizationPct, 80.0);
      expect(alert.status, BudgetHealthStatus.healthy);

      // Entering ₹13,00,000 materials (86.7% of ₹15L) -> Warning (Caution Threshold >= 85%)
      alert = await budgetRepo.evaluateBudgetImpact(
        projectId: projId,
        costHead: BudgetCostHead.materials,
        newAmount: 1300000.0,
      );
      expect(alert.projectedUtilizationPct, closeTo(86.66, 0.1));
      expect(alert.status, BudgetHealthStatus.warning);

      // Entering ₹16,50,000 materials (110.0% of ₹15L) -> Critical Overrun!
      alert = await budgetRepo.evaluateBudgetImpact(
        projectId: projId,
        costHead: BudgetCostHead.materials,
        newAmount: 1650000.0,
      );
      expect(alert.projectedUtilizationPct, closeTo(110.0, 0.01));
      expect(alert.status, BudgetHealthStatus.overBudget);
      expect(alert.overrunAmount, 150000.0); // ₹1.5L Overrun

      // 4. Record Actual Costs:
      // A. Material Purchases: ₹13,00,000 (86.7% - Warning Zone)
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          type: TransactionType.purchase,
          amount: 1300000.0,
          date: DateTime(2026, 1, 15),
          affectsPnl: const drift.Value(true),
          affectsCash: const drift.Value(true),
        ),
      );

      // B. Direct Labour Payment: ₹7,00,000 (87.5% - Warning Zone)
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          type: TransactionType.labourPayment,
          amount: 700000.0,
          date: DateTime(2026, 1, 20),
          affectsPnl: const drift.Value(true),
          affectsCash: const drift.Value(true),
        ),
      );

      // C. Subcontract Work Order Bill: ₹10,50,000 (116.7% of ₹9L - Over-Budget Overrun!)
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          type: TransactionType.subcontractBill,
          amount: 1050000.0,
          date: DateTime(2026, 1, 25),
          affectsPnl: const drift.Value(true),
          affectsCash: const drift.Value(false),
        ),
      );

      // D. Overheads & Equipment: ₹2,00,000 (66.7% - Healthy)
      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projId,
          type: TransactionType.expense,
          amount: 200000.0,
          date: DateTime(2026, 1, 28),
          affectsPnl: const drift.Value(true),
          affectsCash: const drift.Value(true),
        ),
      );

      // 5. Verify Consolidated Variance & Over-Budget State
      summary = await budgetRepo.watchProjectBudgetSummary(projId).first;
      expect(summary, isNotNull);
      expect(summary!.totalAllocatedBudget, 3500000.0);
      expect(summary.totalActualCost, 3250000.0); // ₹13L + ₹7L + ₹10.5L + ₹2L
      expect(summary.netVariance, 250000.0); // ₹2.5L remaining
      expect(summary.overallUtilizationPercentage, closeTo(92.85, 0.1));
      expect(summary.overallStatus, BudgetHealthStatus.warning); // Overall is 92.8% (Warning)
      expect(summary.overBudgetCategoriesCount, 1); // Subcontract head is OVER BUDGET
      expect(summary.warningCategoriesCount, 2); // Materials & Labour are in CAUTION zone

      // Inspect individual cost heads
      final matHead = summary.costHeads.firstWhere((h) => h.costHead == BudgetCostHead.materials);
      expect(matHead.allocatedBudget, 1500000.0);
      expect(matHead.actualSpent, 1300000.0);
      expect(matHead.variance, 200000.0);
      expect(matHead.status, BudgetHealthStatus.warning);

      final subHead = summary.costHeads.firstWhere((h) => h.costHead == BudgetCostHead.subcontract);
      expect(subHead.allocatedBudget, 900000.0);
      expect(subHead.actualSpent, 1050000.0);
      expect(subHead.variance, -150000.0); // Negative = Deficit
      expect(subHead.overrunAmount, 150000.0);
      expect(subHead.status, BudgetHealthStatus.overBudget);
      expect(subHead.isOverBudget, isTrue);

      final ovhHead = summary.costHeads.firstWhere((h) => h.costHead == BudgetCostHead.equipmentOverhead);
      expect(ovhHead.allocatedBudget, 300000.0);
      expect(ovhHead.actualSpent, 200000.0);
      expect(ovhHead.variance, 100000.0);
      expect(ovhHead.status, BudgetHealthStatus.healthy);

      // 6. Portfolio Metrics Check
      final portfolio = await budgetRepo.watchBudgetPortfolioMetrics().first;
      expect(portfolio.totalPortfolioBudget, 3500000.0);
      expect(portfolio.totalPortfolioActualSpent, 3250000.0);
      expect(portfolio.netPortfolioVariance, 250000.0);
      expect(portfolio.budgetedProjectsCount, 1);
      expect(portfolio.overBudgetProjectsCount, 1); // Has at least 1 overrun category
    });

    testWidgets('2. Budget Screens & Warning Banner render cleanly with 0 overflows',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
      );
      addTearDown(container.dispose);

      // Seed Project
      final projId = await db.projectDao.insertProject(
        ProjectsCompanion.insert(
          code: 'PRJ-TEST-BUDGET',
          name: 'Civic Centre Commercial Complex',
          clientName: const drift.Value('Municipal Corp'),
          clientContractValue: const drift.Value(80000000.0),
          type: ProjectType.project,
          status: ProjectStatus.active,
          startDate: DateTime(2026, 1, 1),
        ),
      );

      await budgetRepo.setProjectBudgets(
        projectId: projId,
        allocations: {
          BudgetCostHead.materials: 25000000.0,
          BudgetCostHead.labour: 15000000.0,
          BudgetCostHead.subcontract: 18000000.0,
          BudgetCostHead.equipmentOverhead: 4000000.0,
        },
      );

      // 1. Pump ProjectBudgetVarianceHubScreen
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => const MaterialApp(
              home: SizedBox(
                width: 1280,
                height: 800,
                child: ProjectBudgetVarianceHubScreen(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ProjectBudgetVarianceHubScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 2. Pump SetProjectBudgetDialog
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => MaterialApp(
              home: Scaffold(
                body: SetProjectBudgetDialog(projectId: projId),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SetProjectBudgetDialog), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 3. Pump BudgetWarningBanner
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ScreenUtilInit(
            designSize: const Size(1440, 900),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, _) => const MaterialApp(
              home: Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(16),
                  child: BudgetWarningBanner(
                    projectId: 1,
                    costHead: BudgetCostHead.materials,
                    addedAmount: 500000.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BudgetWarningBanner), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
