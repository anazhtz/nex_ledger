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
import 'daos/project_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/purchase_dao.dart';
import 'daos/labour_dao.dart';
import 'daos/deposit_dao.dart';
import 'daos/expense_category_dao.dart';

export 'tables/projects_table.dart';
export 'tables/transactions_table.dart';
export 'tables/vendors_table.dart';
export 'tables/purchases_table.dart';
export 'tables/workers_table.dart';
export 'tables/attendance_table.dart';
export 'tables/deposits_table.dart';
export 'tables/expense_categories_table.dart';
export 'daos/project_dao.dart';
export 'daos/transaction_dao.dart';
export 'daos/purchase_dao.dart';
export 'daos/labour_dao.dart';
export 'daos/deposit_dao.dart';
export 'daos/expense_category_dao.dart';

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
  ],
  daos: [
    ProjectDao,
    TransactionDao,
    PurchaseDao,
    LabourDao,
    DepositDao,
    ExpenseCategoryDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 5;

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
            // Create the expense_categories table
            await m.createTable(expenseCategories);
            // Add nullable FK column to existing transactions
            await m.addColumn(
                transactions, transactions.expenseCategoryId);
            // Seed default categories for existing installations
            await _seedExpenseCategories();
          }
        },
      );

  /// Seed an "Admin / Overhead" project + all default expense categories on first run.
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
  }

  /// Seed all 38 default expense categories.
  /// Called both on fresh install (onCreate) and on upgrade from < v5.
  Future<void> _seedExpenseCategories() async {
    final defaults = _defaultCategories();
    for (int i = 0; i < defaults.length; i++) {
      final entry = defaults[i];
      await into(expenseCategories).insert(
        ExpenseCategoriesCompanion.insert(
          groupName: entry.$1,
          subCategory: entry.$2,
          isDefault: const Value(true),
          isActive: const Value(true),
          sortOrder: Value(i),
        ),
      );
    }
  }

  /// Returns all (groupName, subCategory) pairs in display order.
  List<(String, String)> _defaultCategories() => [
        // Site & Project Expenses
        ('Site & Project Expenses', 'Fuel (Site)'),
        ('Site & Project Expenses', 'Equipment Rental'),
        ('Site & Project Expenses', 'Transport / Logistics'),
        ('Site & Project Expenses', 'Accommodation'),
        ('Site & Project Expenses', 'Food & Refreshments (Site)'),
        ('Site & Project Expenses', 'Petty Cash / Sundry'),
        // Office & Administrative
        ('Office & Administrative', 'Office Rent'),
        ('Office & Administrative', 'Electricity'),
        ('Office & Administrative', 'Water'),
        ('Office & Administrative', 'Internet & Wi-Fi'),
        ('Office & Administrative', 'Phone Bills'),
        ('Office & Administrative', 'Office Supplies'),
        ('Office & Administrative', 'Printing & Photocopying'),
        ('Office & Administrative', 'Courier & Postage'),
        ('Office & Administrative', 'Maintenance & Repairs'),
        // Employee Expenses
        ('Employee Expenses', 'Staff Welfare'),
        ('Employee Expenses', 'Travel Reimbursement'),
        ('Employee Expenses', 'Medical Expenses'),
        ('Employee Expenses', 'Visa / Work Permit Fees'),
        // Vehicle Expenses
        ('Vehicle Expenses', 'Fuel (Vehicle)'),
        ('Vehicle Expenses', 'Vehicle Maintenance'),
        ('Vehicle Expenses', 'Insurance'),
        ('Vehicle Expenses', 'Parking'),
        ('Vehicle Expenses', 'Salik / Toll Charges'),
        // Financial & Legal
        ('Financial & Legal', 'Bank Charges'),
        ('Financial & Legal', 'Loan Interest'),
        ('Financial & Legal', 'Taxes & Government Fees'),
        ('Financial & Legal', 'Audit & Accounting Fees'),
        ('Financial & Legal', 'Insurance (Financial)'),
        // Marketing & Sales
        ('Marketing & Sales', 'Advertising'),
        ('Marketing & Sales', 'Social Media Marketing'),
        ('Marketing & Sales', 'Website Hosting & Domain'),
        ('Marketing & Sales', 'Business Cards & Printing'),
        // Miscellaneous
        ('Miscellaneous', 'Entertainment'),
        ('Miscellaneous', 'Donations'),
        ('Miscellaneous', 'Other Expenses'),
      ];

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
