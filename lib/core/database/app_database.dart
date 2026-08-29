import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/projects_table.dart';
import 'tables/transactions_table.dart';
import 'tables/vendors_table.dart';
import 'tables/purchases_table.dart';
import 'tables/workers_table.dart';
import 'tables/attendance_table.dart';
import 'tables/deposits_table.dart';
import 'tables/expense_categories_table.dart';
import 'tables/bank_accounts_table.dart';
import 'tables/subcontractors_table.dart';
import 'tables/work_orders_table.dart';
import 'tables/measurement_bills_table.dart';
import 'tables/subcontract_payments_table.dart';
import 'daos/project_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/purchase_dao.dart';
import 'daos/labour_dao.dart';
import 'daos/deposit_dao.dart';
import 'daos/expense_category_dao.dart';
import 'daos/bank_account_dao.dart';
import 'daos/subcontract_dao.dart';

export 'tables/projects_table.dart';
export 'tables/transactions_table.dart';
export 'tables/vendors_table.dart';
export 'tables/purchases_table.dart';
export 'tables/workers_table.dart';
export 'tables/attendance_table.dart';
export 'tables/deposits_table.dart';
export 'tables/expense_categories_table.dart';
export 'tables/bank_accounts_table.dart';
export 'tables/subcontractors_table.dart';
export 'tables/work_orders_table.dart';
export 'tables/measurement_bills_table.dart';
export 'tables/subcontract_payments_table.dart';
export 'daos/project_dao.dart';
export 'daos/transaction_dao.dart';
export 'daos/purchase_dao.dart';
export 'daos/labour_dao.dart';
export 'daos/deposit_dao.dart';
export 'daos/expense_category_dao.dart';
export 'daos/bank_account_dao.dart';
export 'daos/subcontract_dao.dart';
export 'database_provider.dart';

part 'app_database.g.dart';

/// The single AppDatabase instance for the entire application.
///
/// Opened via [_openConnection] which resolves the platform app documents
/// directory and stores the SQLite file as `nex_ledger.sqlite`.
@DriftDatabase(
  tables: [
    Projects,
    Transactions,
    Vendors,
    Purchases,
    Workers,
    Attendance,
    Deposits,
    ExpenseCategories,
    BankAccounts,
    Subcontractors,
    WorkOrders,
    MeasurementBills,
    SubcontractPayments,
  ],
  daos: [
    ProjectDao,
    TransactionDao,
    PurchaseDao,
    LabourDao,
    DepositDao,
    ExpenseCategoryDao,
    BankAccountDao,
    SubcontractDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedInitialData();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(deposits, deposits.adjustedAmount);
            await m.addColumn(transactions, transactions.affectsCash);
          }
          if (from < 3) {
            await m.addColumn(workers, workers.trade);
          }
          if (from < 4) {
            await m.addColumn(transactions, transactions.workerId);
          }
          if (from < 5) {
            await m.createTable(expenseCategories);
            await m.addColumn(
                transactions, transactions.expenseCategoryId);
            await _seedExpenseCategories();
          }
          if (from < 6) {
            // Replace old multi-group categories with the new flat 18-category list.
            await delete(expenseCategories).go();
            await _seedExpenseCategories();
          }
          if (from < 7) {
            // Accrued expense support: pending/partial purchases should NOT move cash.
            // For existing purchases with status != 'paid', set affectsCash = false on
            // their linked transaction rows. Paid purchases are left as-is (affectsCash = true).
            await customStatement(
              '''
              UPDATE transactions
              SET affects_cash = 0
              WHERE type = 'purchase'
                AND id IN (
                  SELECT transaction_id FROM purchases
                  WHERE payment_status != 'paid'
                )
              ''',
            );
          }
          if (from < 8) {
            await m.addColumn(purchases, purchases.isAdvanceStock);
            await m.addColumn(purchases, purchases.allocatedAmount);
          }
          if (from < 9) {
            await m.addColumn(purchases, purchases.quantity);
            await m.addColumn(purchases, purchases.unitRate);
            await m.addColumn(purchases, purchases.unit);
            await m.addColumn(purchases, purchases.paidAmount);
            await customStatement(
              '''
              UPDATE purchases
              SET paid_amount = (
                SELECT amount FROM transactions WHERE transactions.id = purchases.transaction_id
              )
              WHERE payment_status = 'paid'
              ''',
            );
          }
          if (from < 10) {
            await m.createTable(bankAccounts);
            await m.addColumn(transactions, transactions.bankAccountId);
            await _seedBankAccounts();
          }
          if (from < 11) {
            await m.addColumn(deposits, deposits.depositType);
          }
          if (from < 12) {
            await m.addColumn(purchases, purchases.materialCategory);
          }
          if (from < 13) {
            await m.createTable(subcontractors);
            await m.createTable(workOrders);
            await m.createTable(measurementBills);
            await m.createTable(subcontractPayments);
          }
        },
      );

  /// Seed an "Admin / Overhead" project + all default expense categories and bank accounts on first run.
  Future<void> _seedInitialData() async {
    await into(projects).insert(
      ProjectsCompanion.insert(
        code: 'ADMIN-OVH',
        name: 'Admin / Overhead',
        type: ProjectType.adminOverhead,
        status: ProjectStatus.active,
        startDate: DateTime.now(),
        clientName: const Value(null),
        budget: const Value(null),
      ),
    );
    await _seedExpenseCategories();
    await _seedBankAccounts();
  }

  /// Seed default Petty Cash and Bank accounts if empty.
  Future<void> _seedBankAccounts() async {
    final existing = await select(bankAccounts).get();
    if (existing.isEmpty) {
      await into(bankAccounts).insert(
        BankAccountsCompanion.insert(
          accountName: 'Petty Cash Drawer',
          isCashAccount: const Value(true),
          isDefault: const Value(true),
          openingBalance: const Value(0.0),
        ),
      );
      await into(bankAccounts).insert(
        BankAccountsCompanion.insert(
          accountName: 'Primary Bank Current A/c',
          bankName: const Value('Main Business Bank'),
          isCashAccount: const Value(false),
          isDefault: const Value(true),
          openingBalance: const Value(0.0),
        ),
      );
    }
  }

  /// Seed all 18 default expense categories (flat list).
  Future<void> _seedExpenseCategories() async {
    final defaults = _defaultCategories();
    for (int i = 0; i < defaults.length; i++) {
      await into(expenseCategories).insert(
        ExpenseCategoriesCompanion.insert(
          groupName: 'Expense',
          subCategory: defaults[i],
          isDefault: const Value(true),
          isActive: const Value(true),
          sortOrder: Value(i),
        ),
      );
    }
  }

  /// 18 flat expense categories for a project-based ERP.
  List<String> _defaultCategories() => [
        'Material Purchase',
        'Petty Purchase',
        'Labour Payment',
        'Transport',
        'Fuel',
        'Equipment Rental',
        'Site Expense',
        'Office Expense',
        'Internet & Phone',
        'Utility Bills',
        'Maintenance',
        'Software Subscription',
        'Bank Charges',
        'Travel Expense',
        'Food & Refreshments',
        'Administrative Expense',
        'Miscellaneous',
        'Other Expense',
      ];

  /// Safely wipes all transactional data and resets the ledger on any OS (including Windows)
  /// without deleting or locking the physical SQLite database file.
  Future<void> wipeAndResetData() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(purchases).go();
      await delete(attendance).go();
      await delete(deposits).go();
      await delete(workers).go();
      await delete(vendors).go();
      await (delete(projects)..where((tbl) => tbl.code.isNotValue('ADMIN-OVH'))).go();
      await (delete(bankAccounts)..where((tbl) => tbl.isDefault.equals(false))).go();
      await (update(bankAccounts)..where((tbl) => tbl.isDefault.equals(true)))
          .write(const BankAccountsCompanion(openingBalance: Value(0.0)));
    });
  }

  /// Returns the absolute path of the database file (used for backup and Section 6a requirement).
  static Future<String> getDatabasePath() async {
    final dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return p.join(dir.path, 'nex_ledger.sqlite');
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    if (!await dbFolder.exists()) {
      await dbFolder.create(recursive: true);
    }
    final file = File(p.join(dbFolder.path, 'nex_ledger.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
