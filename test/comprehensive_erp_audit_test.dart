import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/bank_accounts/data/bank_account_repository.dart';
import 'package:nex_ledger/features/budgets/data/project_budget_repository.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/client_billing/data/client_billing_repository.dart';
import 'package:nex_ledger/features/deposits/data/deposit_repository.dart';
import 'package:nex_ledger/features/equipment/data/equipment_repository.dart';
import 'package:nex_ledger/features/labour/data/labour_repository.dart';
import 'package:nex_ledger/features/reports/data/ledger_repository.dart';
import 'package:nex_ledger/features/petty_cash/data/petty_cash_repository.dart';
import 'package:nex_ledger/features/projects/data/project_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';
import 'package:nex_ledger/features/subcontract/data/subcontract_repository.dart';
import 'package:nex_ledger/core/utils/pdf_receipt_service.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository projectRepo;
  late BankAccountRepository bankRepo;
  late CashBookRepository cashBookRepo;
  late PurchaseRepository purchaseRepo;
  late LabourRepository labourRepo;
  late DepositRepository depositRepo;
  late ReportRepository reportRepo;
  late ProjectBudgetRepository budgetRepo;
  late SubcontractRepository subRepo;
  late ClientBillingRepository clientBillingRepo;
  late EquipmentRepository equipmentRepo;
  late PettyCashRepository pettyCashRepo;
  late LedgerRepository ledgerRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    projectRepo = ProjectRepository(db.projectDao);
    bankRepo = BankAccountRepository(db.bankAccountDao, db.transactionDao, db);
    cashBookRepo = CashBookRepository(db.transactionDao);
    purchaseRepo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
    labourRepo = LabourRepository(db.labourDao, db.transactionDao);
    depositRepo = DepositRepository(db.depositDao, db.transactionDao, db);
    reportRepo = ReportRepository(
      db.transactionDao,
      db.projectDao,
      db.depositDao,
      db.expenseCategoryDao,
    );
    budgetRepo = ProjectBudgetRepository(
      db.projectBudgetDao,
      db.projectDao,
      db.transactionDao,
      db,
    );
    subRepo = SubcontractRepository(db.subcontractDao, db.transactionDao, db);
    clientBillingRepo = ClientBillingRepository(
      db.clientBillingDao,
      db.transactionDao,
      db.projectDao,
      db,
    );
    equipmentRepo = EquipmentRepository(
      db.equipmentDao,
      db.transactionDao,
      db,
    );
    pettyCashRepo = PettyCashRepository(
      db.pettyCashDao,
      db.transactionDao,
      db,
    );
    ledgerRepo = LedgerRepository(db);
  });

  tearDown(() async => db.close());

  test('Comprehensive Master ERP Audit — Complete Financial Engine & Modules Verification', () async {
    // ═══════════════════════════════════════════════════════════════════════════
    // 1. BANK ACCOUNTS & INITIAL LIQUIDITY
    // ═══════════════════════════════════════════════════════════════════════════
    final cashAccId = await bankRepo.addAccount(
      accountName: 'Site Cash Drawer',
      isCashAccount: true,
      isDefault: true,
      openingBalance: 50000.0,
    );

    final bankAccId = await bankRepo.addAccount(
      accountName: 'HDFC Current Site Account',
      bankName: 'HDFC Bank',
      accountNumber: '50200012345678',
      isCashAccount: false,
      isDefault: true,
      openingBalance: 2000000.0,
    );

    var liq = await bankRepo.watchLiquiditySummary().first;
    expect(liq.cashInHand, 50000.0);
    expect(liq.inBanks, 2000000.0);
    expect(liq.totalLiquidity, 2050000.0);

    // ═══════════════════════════════════════════════════════════════════════════
    // 2. PROJECT MASTER & COST HEAD BUDGETING
    // ═══════════════════════════════════════════════════════════════════════════
    final pId = await projectRepo.createProject(
      code: 'PRJ-2026-METRO',
      name: 'Metro Line Underground Station',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    );

    // Set Budget Limits for Project
    await budgetRepo.setProjectBudgets(
      projectId: pId,
      allocations: {
        BudgetCostHead.materials: 1500000.0,
        BudgetCostHead.labour: 500000.0,
        BudgetCostHead.subcontract: 800000.0,
        BudgetCostHead.equipmentOverhead: 400000.0,
      },
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // 3. DUAL-DIRECTION DEPOSIT SYSTEM (Flow A: Govt EMD Paid & Recovered)
    // ═══════════════════════════════════════════════════════════════════════════
    // Contractor pays ₹1,00,000 EMD to Govt (Cash Outflow, Asset Created, P&L = 0)
    await depositRepo.paySecurityDeposit(
      projectId: pId,
      amount: 100000.0,
      date: DateTime(2026, 1, 2),
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
      referenceNo: 'EMD-METRO-01',
      narration: 'Earnest Money Deposit (EMD) to Metro Rail Corporation',
    );

    var pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.netPnl, 0.0, reason: 'Govt EMD paid is an asset, NEVER hits P&L');

    // Govt releases/returns ₹1,00,000 EMD back to bank (Cash Inflow, P&L = 0)
    final allDeposits = await depositRepo.watchDepositsByProject(pId).first;
    final emdDeposit = allDeposits.firstWhere((d) => d.deposit.depositType == DepositType.paid);

    await depositRepo.recoverDeposit(
      depositId: emdDeposit.deposit.id,
      projectId: pId,
      recoveredAmount: 100000.0,
      date: DateTime(2026, 1, 10),
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
      referenceNo: 'EMD-REFUND-01',
      narration: 'Tender EMD refunded back by Govt',
    );

    pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.netPnl, 0.0, reason: 'Govt EMD recovery is NOT income, P&L remains 0');

    // ═══════════════════════════════════════════════════════════════════════════
    // 4. DUAL-DIRECTION DEPOSIT SYSTEM (Flow B: Client Advance Received & Adjusted)
    // ═══════════════════════════════════════════════════════════════════════════
    // Receive ₹5,00,000 Security Deposit from Client (Cash In, Liability Created, P&L = 0)
    await depositRepo.receiveDeposit(
      projectId: pId,
      date: DateTime(2026, 1, 15),
      amount: 500000.0,
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
      referenceNo: 'CLIENT-SD-001',
      narration: 'Client Mobilization Advance',
    );

    pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.netPnl, 0.0, reason: 'Client deposit is a liability, P&L remains 0');
    expect(pnl.depositsHeld, 500000.0, reason: 'Deposit liability recorded');

    // ═══════════════════════════════════════════════════════════════════════════
    // 5. VENDOR PURCHASES & MATERIAL CATEGORIES (Accrual & Credit Settlement)
    // ═══════════════════════════════════════════════════════════════════════════
    final vId = await purchaseRepo.addVendor('Tata Steel BSL Ltd');
    await purchaseRepo.addPurchase(
      projectId: pId,
      vendorId: vId,
      date: DateTime(2026, 1, 16),
      itemDescription: 'Fe 550D TMT Rebar 16mm',
      quantity: 5.0,
      unitRate: 65000.0,
      unit: 'MT',
      amount: 325000.0,
      paymentStatus: PaymentStatus.pending, // On 30-day Vendor Credit
      paymentMode: PaymentMode.bank,
      referenceNo: 'INV-TATA-8821',
    );

    pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.purchases, 325000.0, reason: 'Material cost recognized on accrual basis');
    expect(pnl.accountsPayable, 325000.0, reason: 'Unpaid vendor balance in Accounts Payable');

    // Settle partial payment of ₹2,00,000 to steel vendor from Bank
    final purchases = await db.purchaseDao.watchPurchasesByProject(pId).first;
    await purchaseRepo.markPurchasePaid(
      purchaseId: purchases.first.purchase.id,
      paymentDate: DateTime(2026, 1, 20),
      amountPaid: 200000.0,
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
      referenceNo: 'NEFT-TATA-PAY1',
    );

    pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.purchases, 325000.0, reason: 'No double-counting on payment');
    expect(pnl.accountsPayable, 125000.0, reason: '₹325,000 - ₹200,000 = ₹125,000 remaining payable');

    // Verify Vendor Ledger in Ledgers Hub
    final vendorLedger = await ledgerRepo.watchVendorLedger(vId, projectId: pId).first;
    expect(vendorLedger.summary.totalCredit, 325000.0);
    expect(vendorLedger.summary.totalDebit, 200000.0);
    expect(vendorLedger.summary.closingBalance, 125000.0);

    // ═══════════════════════════════════════════════════════════════════════════
    // 6. LABOUR MODULE & ALL-TIME RUNNING WAGE LEDGER (Section 12c Invariant)
    // ═══════════════════════════════════════════════════════════════════════════
    final wId = await db.labourDao.insertWorker(
      const WorkersCompanion(
        name: drift.Value('Murugan Carpenter'),
        workerCode: drift.Value('WRK-007'),
        trade: drift.Value('Carpenter'),
        dailyRate: drift.Value(1200.0),
      ),
    );

    // 5 days of attendance
    for (int day = 1; day <= 5; day++) {
      await labourRepo.saveBatchAttendance(
        projectId: pId,
        date: DateTime(2026, 1, 20 + day),
        workerStatuses: {wId: AttendanceStatus.present},
      );
    }

    final wageSummary = await labourRepo.getPaymentSummary(
      wId,
      pId,
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 31),
    );
    expect(wageSummary.totalDaysWorked, 5.0);
    expect(wageSummary.totalEarnedWages, 6000.0); // 5 × ₹1,200
    expect(wageSummary.amountDue, 6000.0);

    // Disburse ₹6,000 wages from Site Cash Drawer
    await labourRepo.recordPayment(
      projectId: pId,
      workerId: wId,
      date: DateTime(2026, 1, 25),
      amount: 6000.0,
      paymentMode: PaymentMode.cash,
      bankAccountId: cashAccId,
      narration: 'Settlement for formwork carpentry',
    );

    pnl = await reportRepo.watchProjectPnl(pId).first;
    expect(pnl.labourCosts, 6000.0);

    // Verify Worker Ledger in Ledgers Hub
    final workerLedger = await ledgerRepo.watchWorkerLedger(wId).first;
    expect(workerLedger.summary.totalCredit, 6000.0);
    expect(workerLedger.summary.totalDebit, 6000.0);
    expect(workerLedger.summary.closingBalance, 0.0);

    // ═══════════════════════════════════════════════════════════════════════════
    // 7. SUBCONTRACTOR PIECE-RATE & MEASUREMENT BILLING
    // ═══════════════════════════════════════════════════════════════════════════
    final subId = await subRepo.addSubcontractor(
      name: 'Apex Reinforcement Bar-Bending Gang',
      trade: 'Bar Bending & Fixing',
      contact: '9840112233',
    );

    final woId = await subRepo.createWorkOrder(
      orderNumber: 'WO-2026-METRO-01',
      projectId: pId,
      subcontractorId: subId,
      title: 'TMT Steel Cutting, Bending & Fixing in Shoring Wall',
      trade: 'Bar Bending',
      unit: 'MT',
      agreedRate: 40000.0,
      estimatedQuantity: 5.0,
      retentionPercentage: 5.0,
      startDate: DateTime(2026, 1, 15),
    );

    // Record Measurement Bill: 5 MT @ ₹40,000 = ₹2,00,000 gross, 5% retention (₹10,000) -> Net Due = ₹1,90,000
    await subRepo.recordMeasurementBill(
      workOrderId: woId,
      billNumber: 'SUB-RA-01',
      date: DateTime(2026, 1, 26),
      measuredQuantity: 5.0,
      unitRate: 40000.0,
      retentionPercentage: 5.0,
      locationOrDescription: 'Certified 100% completion of pile cap steel',
    );

    // Settle Subcontractor Bill of ₹1,90,000 via Bank
    await subRepo.recordSubcontractPayment(
      subcontractorId: subId,
      workOrderId: woId,
      projectId: pId,
      amount: 190000.0,
      paymentDate: DateTime(2026, 1, 27),
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
      referenceNo: 'NEFT-SUB-PAY01',
    );

    // Verify Subcontractor Ledger
    final subLedger = await ledgerRepo.watchSubcontractorLedger(subId, projectId: pId).first;
    expect(subLedger.summary.totalCredit, 190000.0);
    expect(subLedger.summary.totalDebit, 190000.0);
    expect(subLedger.summary.closingBalance, 0.0);

    // ═══════════════════════════════════════════════════════════════════════════
    // 8. SITE MACHINERY & EQUIPMENT RENTAL TRACKER
    // ═══════════════════════════════════════════════════════════════════════════
    final eqId = await equipmentRepo.createEquipment(
      name: 'CAT 320D Excavator 20-Ton',
      assetOrRegNumber: 'EXC-01',
      category: 'Heavy Excavation',
      ownership: EquipmentOwnership.rented,
      rentalBasis: EquipmentRentalBasis.hourly,
      standardRate: 2500.0,
      fuelPolicy: EquipmentFuelPolicy.contractorSupplied,
    );

    // Log 10 hours operation with ₹3,000 contractor diesel supplied (deducted from supplier bill)
    await equipmentRepo.recordDailyLog(
      equipmentId: eqId,
      projectId: pId,
      logDate: DateTime(2026, 1, 26),
      totalUnitsLogged: 10.0,
      billableUnits: 10.0,
      unitRate: 2500.0,
      grossRentalCost: 25000.0,
      fuelCostDeduction: 3000.0,
      netPayableAmount: 22000.0,
      workDescription: 'Basement shoring wall excavation',
    );

    // Settle equipment supplier net bill ₹22,000 from Bank
    await equipmentRepo.recordEquipmentRentalPayment(
      projectId: pId,
      equipmentId: eqId,
      paymentAmount: 22000.0,
      paymentDate: DateTime(2026, 1, 27),
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
      referenceNo: 'CHQ-EQ-901',
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // 9. SITE SUPERVISOR IMPREST & PETTY CASH FLOAT
    // ═══════════════════════════════════════════════════════════════════════════
    final walletId = await pettyCashRepo.createWallet(
      supervisorName: 'Engr. Suresh Babu',
      phone: '9876543210',
      assignedProjectId: pId,
      maxFloatLimit: 50000.0,
    );

    // Disburse ₹20,000 initial float from Site Cash Drawer
    await pettyCashRepo.disburseCashAdvance(
      walletId: walletId,
      projectId: pId,
      date: DateTime(2026, 1, 25),
      amount: 20000.0,
      paymentMode: PaymentMode.cash,
      bankAccountId: cashAccId,
      narration: 'Site initial imprest float',
    );

    // Supervisor spends ₹12,000 across site supplies and courier
    await pettyCashRepo.recordExpenseVoucher(
      walletId: walletId,
      projectId: pId,
      date: DateTime(2026, 1, 27),
      amount: 12000.0,
      category: 'Site Safety Gear & Tools',
      narration: 'Safety helmets, reflective vests & caution tapes',
    );

    // Supervisor returns unspent ₹8,000 back to Site Cash Drawer
    await pettyCashRepo.returnUnspentCash(
      walletId: walletId,
      projectId: pId,
      date: DateTime(2026, 1, 28),
      amount: 8000.0,
      paymentMode: PaymentMode.cash,
      bankAccountId: cashAccId,
      narration: 'Unspent cash float return',
    );

    final allWallets = await db.pettyCashDao.watchAllWalletsWithBalances().first;
    final walletSummary = allWallets.firstWhere((w) => w.wallet.id == walletId);
    expect(walletSummary.currentUnspentCashBalance, 0.0, reason: 'Wallet fully reconciled (₹20k adv - ₹12k exp - ₹8k ret)');

    // ═══════════════════════════════════════════════════════════════════════════
    // 10. CLIENT RA BILLING & REVENUE RECOGNITION
    // ═══════════════════════════════════════════════════════════════════════════
    // Raise Client RA Bill #1: Gross ₹12,00,000, 5% Retention (₹60,000), Net Due = ₹11,40,000
    final raBillId = await clientBillingRepo.raiseClientRaBill(
      projectId: pId,
      billNumber: 'RA-BILL-01',
      billDate: DateTime(2026, 1, 28),
      stageOrDescription: 'Excavation, Shoring Wall & Foundation RCC complete',
      grossAmount: 1200000.0,
      retentionPercentage: 5.0,
    );

    // Receive ₹8,40,000 partial payment from Client in Bank
    await clientBillingRepo.recordClientReceipt(
      projectId: pId,
      clientRaBillId: raBillId,
      receiptDate: DateTime(2026, 1, 29),
      amount: 840000.0,
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
      referenceNo: 'RTGS-METRO-01',
    );

    // Adjust ₹3,00,000 of the Client Deposit from Step 4 against this RA Bill to clear the rest of the bill!
    final clientDeposits = await depositRepo.watchDepositsByProject(pId).first;
    final clientDeposit = clientDeposits.firstWhere((d) => d.deposit.depositType == DepositType.received);

    await depositRepo.adjustDepositToIncome(
      depositId: clientDeposit.deposit.id,
      projectId: pId,
      adjustedAmount: 300000.0,
      date: DateTime(2026, 1, 29),
      isFullyAdjusted: false,
      adjustmentReference: 'RA-BILL-01-ADJ',
    );

    // Verify Client Ledger
    final clientLedger = await ledgerRepo.watchClientLedger(pId).first;
    expect(clientLedger.summary.totalCredit, 1140000.0); // Net certified amount
    expect(clientLedger.summary.totalDebit, 840000.0);
    expect(clientLedger.summary.closingBalance, 300000.0); // ₹11,40,000 - ₹8,40,000 = ₹3,00,000 regular receivable

    // ═══════════════════════════════════════════════════════════════════════════
    // 11. FINAL COMPREHENSIVE PROJECT P&L & CONSOLIDATED AUDIT
    // ═══════════════════════════════════════════════════════════════════════════
    pnl = await reportRepo.watchProjectPnl(pId).first;

    // Recognized Income = ₹12,00,000 (from RA Bill) + ₹3,00,000 (Adjusted Deposit) = ₹15,00,000
    expect(pnl.income, 1500000.0);

    // Costs Breakdown:
    // Purchases: ₹325,000 (Steel)
    // Labour: ₹6,000 (Carpenter)
    // Expenses (Subcontract ₹200k + Equipment ₹22k + Imprest ₹12k): ₹234,000
    expect(pnl.purchases, 325000.0);
    expect(pnl.labourCosts, 6000.0);
    expect(pnl.expenses, 234000.0);

    // Net Profit = ₹15,00,000 - (₹325,000 + ₹6,000 + ₹234,000) = ₹9,35,000 Profit
    expect(pnl.netPnl, 935000.0);

    // Client Deposit Liability Remaining = ₹5,00,000 - ₹3,00,000 = ₹2,00,000
    expect(pnl.depositsHeld, 200000.0);

    // Accounts Payable Unpaid = ₹125,000 (Tata Steel)
    expect(pnl.accountsPayable, 125000.0);

    // ═══════════════════════════════════════════════════════════════════════════
    // 12. BUDGET VS ACTUAL VARIANCE AUDIT
    // ═══════════════════════════════════════════════════════════════════════════
    final budgetSummary = await budgetRepo.watchProjectBudgetSummary(pId).first;
    expect(budgetSummary, isNotNull);
    expect(budgetSummary!.totalAllocatedBudget, 3200000.0); // 15L + 5L + 8L + 4L
    expect(budgetSummary.totalActualCost, 565000.0); // 325k + 6k + 200k + 22k + 12k
    expect(budgetSummary.netVariance, 3200000.0 - 565000.0); // ₹26,35,000 Surplus
    expect(budgetSummary.overallStatus, BudgetHealthStatus.healthy);

    // ═══════════════════════════════════════════════════════════════════════════
    // 13. PRINTABLE PDF RECEIPT & VOUCHER GENERATION AUDIT
    // ═══════════════════════════════════════════════════════════════════════════
    final worker = (await db.labourDao.watchAllWorkers().first).first;
    final project = (await db.projectDao.watchAllProjects().first).first;

    final wagePdf = await PdfReceiptService.generateLabourWageReceipt(
      worker: worker,
      project: project,
      amountPaid: 6000.0,
      paymentDate: DateTime(2026, 1, 25),
      paymentMode: PaymentMode.cash,
      narration: 'Settlement for formwork carpentry',
      totalEffectiveDaysWorked: 5.0,
      totalGrossWagesEarned: 6000.0,
      totalPaymentsIssued: 6000.0,
      netBalanceDueRemaining: 0.0,
    );
    expect(wagePdf.isNotEmpty, isTrue);
    expect(String.fromCharCodes(wagePdf.sublist(0, 5)), '%PDF-');

    final paymentVoucherPdf = await PdfReceiptService.generatePaymentVoucher(
      transactionId: 101,
      date: DateTime(2026, 1, 20),
      type: TransactionType.purchasePayment,
      amount: 200000.0,
      paymentMode: PaymentMode.bank,
      projectName: project.name,
      projectCode: project.code,
      partyName: 'Tata Steel BSL Ltd',
    );
    expect(paymentVoucherPdf.isNotEmpty, isTrue);
    expect(String.fromCharCodes(paymentVoucherPdf.sublist(0, 5)), '%PDF-');
  });
}
