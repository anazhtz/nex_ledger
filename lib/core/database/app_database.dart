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
import 'daos/project_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/purchase_dao.dart';
import 'daos/labour_dao.dart';
import 'daos/deposit_dao.dart';

export 'tables/projects_table.dart';
export 'tables/transactions_table.dart';
export 'tables/vendors_table.dart';
export 'tables/purchases_table.dart';
export 'tables/workers_table.dart';
export 'tables/attendance_table.dart';
export 'tables/deposits_table.dart';
export 'daos/project_dao.dart';
export 'daos/transaction_dao.dart';
export 'daos/purchase_dao.dart';
export 'daos/labour_dao.dart';
export 'daos/deposit_dao.dart';

part 'app_database.g.dart';

/// The single AppDatabase instance for the entire application.
///
/// Opened via [_openConnection] which resolves the platform app documents
/// directory and stores the SQLite file as `nex_ledger.db`.
@DriftDatabase(
  tables: [
    Projects,
    Transactions,
    Vendors,
    Purchases,
    Workers,
    Attendance,
    Deposits,
  ],
  daos: [
    ProjectDao,
    TransactionDao,
    PurchaseDao,
    LabourDao,
    DepositDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
        },
      );

  /// Seed an "Admin / Overhead" project on first run.
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
