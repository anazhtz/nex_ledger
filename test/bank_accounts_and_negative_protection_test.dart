import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/bank_accounts/data/bank_account_repository.dart';
import 'package:nex_ledger/features/cash_book/data/cash_book_repository.dart';
import 'package:nex_ledger/features/projects/data/project_repository.dart';
import 'package:nex_ledger/features/purchase/data/purchase_repository.dart';

void main() {
  late AppDatabase db;
  late ProjectRepository projectRepo;
  late BankAccountRepository bankRepo;
  late CashBookRepository cashBookRepo;
  late PurchaseRepository purchaseRepo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    projectRepo = ProjectRepository(db.projectDao);
    bankRepo = BankAccountRepository(db.bankAccountDao, db.transactionDao, db);
    cashBookRepo = CashBookRepository(db.transactionDao);
    purchaseRepo = PurchaseRepository(db.purchaseDao, db.transactionDao, db);
  });

  tearDown(() async => db.close());

  test('Bank Accounts Master, Opening Balances, and Multi-Account Liquidity', () async {
    // 1. Create a Project
    final pId = await projectRepo.createProject(
      code: 'PRJ-BANK-001',
      name: 'Bank Test Project',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    );

    // 2. Add Petty Cash Drawer with Opening Balance ₹10,000
    final cashAccId = await bankRepo.addAccount(
      accountName: 'Site Petty Cash Drawer',
      isCashAccount: true,
      isDefault: true,
      openingBalance: 10000.0,
    );

    // 3. Add HDFC Bank Account with Opening Balance ₹50,000
    final bankAccId = await bankRepo.addAccount(
      accountName: 'HDFC Current A/c',
      bankName: 'HDFC Bank',
      accountNumber: '50200012345678',
      ifscCode: 'HDFC0001234',
      isCashAccount: false,
      isDefault: true,
      openingBalance: 50000.0,
    );

    // Check Initial Liquidity
    var liq = await bankRepo.watchLiquiditySummary().first;
    expect(liq.cashInHand, 10000.0);
    expect(liq.inBanks, 50000.0);
    expect(liq.totalLiquidity, 60000.0);

    // 4. Record Cash Expense ₹2,000 from Petty Cash
    await cashBookRepo.addExpense(
      projectId: pId,
      date: DateTime(2026, 2, 1),
      amount: 2000.0,
      paymentMode: PaymentMode.cash,
      bankAccountId: cashAccId,
      narration: 'Site Stationery',
    );

    var balances = await bankRepo.watchAccountsWithBalances().first;
    var cashBal = balances.firstWhere((b) => b.account.id == cashAccId).currentBalance;
    var bankBal = balances.firstWhere((b) => b.account.id == bankAccId).currentBalance;
    expect(cashBal, 8000.0, reason: '₹10,000 - ₹2,000 = ₹8,000');
    expect(bankBal, 50000.0, reason: 'Bank unaffected');

    // 5. Record Purchase ₹15,000 paid from Bank
    final vId = await purchaseRepo.addVendor('Cement Corp');
    await purchaseRepo.addPurchase(
      projectId: pId,
      vendorId: vId,
      date: DateTime(2026, 2, 2),
      itemDescription: 'Cement Bags',
      amount: 15000.0,
      paymentStatus: PaymentStatus.paid,
      paymentMode: PaymentMode.bank,
      bankAccountId: bankAccId,
    );

    balances = await bankRepo.watchAccountsWithBalances().first;
    cashBal = balances.firstWhere((b) => b.account.id == cashAccId).currentBalance;
    bankBal = balances.firstWhere((b) => b.account.id == bankAccId).currentBalance;
    expect(cashBal, 8000.0);
    expect(bankBal, 35000.0, reason: '₹50,000 - ₹15,000 = ₹35,000');

    // 6. Contra Funds Transfer: Withdraw ₹5,000 from Bank to Cash
    await bankRepo.transferFunds(
      fromAccountId: bankAccId,
      toAccountId: cashAccId,
      amount: 5000.0,
      date: DateTime(2026, 2, 3),
      narration: 'ATM Cash withdrawal for site petty cash',
    );

    balances = await bankRepo.watchAccountsWithBalances().first;
    cashBal = balances.firstWhere((b) => b.account.id == cashAccId).currentBalance;
    bankBal = balances.firstWhere((b) => b.account.id == bankAccId).currentBalance;
    expect(cashBal, 13000.0, reason: '₹8,000 + ₹5,000 = ₹13,000');
    expect(bankBal, 30000.0, reason: '₹35,000 - ₹5,000 = ₹30,000');

    liq = await bankRepo.watchLiquiditySummary().first;
    expect(liq.cashInHand, 13000.0);
    expect(liq.inBanks, 30000.0);
    expect(liq.totalLiquidity, 43000.0, reason: 'Total funds unchanged by internal transfer');
  });

  test('Negative Cash Balance Calculation', () async {
    final pId = await projectRepo.createProject(
      code: 'PRJ-NEG-001',
      name: 'Negative Cash Test Project',
      type: ProjectType.project,
      status: ProjectStatus.active,
      startDate: DateTime(2026, 1, 1),
    );

    final cashAccId = await bankRepo.addAccount(
      accountName: 'Petty Cash',
      isCashAccount: true,
      openingBalance: 1000.0,
    );

    // Spend ₹3,500 with only ₹1,000 balance -> becomes negative -₹2,500
    await cashBookRepo.addExpense(
      projectId: pId,
      date: DateTime(2026, 2, 1),
      amount: 3500.0,
      paymentMode: PaymentMode.cash,
      bankAccountId: cashAccId,
      narration: 'Emergency site repairs',
    );

    final balances = await bankRepo.watchAccountsWithBalances().first;
    final cashBal = balances.firstWhere((b) => b.account.id == cashAccId).currentBalance;
    expect(cashBal, -2500.0, reason: '₹1,000 - ₹3,500 = -₹2,500 negative balance');

    final liq = await bankRepo.watchLiquiditySummary().first;
    expect(liq.cashInHand, -2500.0);
    expect(liq.totalLiquidity, -2500.0);
  });
}
