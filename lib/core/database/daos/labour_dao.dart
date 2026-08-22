import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/workers_table.dart';
import 'package:nex_ledger/core/database/tables/attendance_table.dart';
import 'package:nex_ledger/core/database/tables/projects_table.dart';

part 'labour_dao.g.dart';

/// Attendance row joined with worker info.
class AttendanceWithWorker {
  final AttendanceData attendance;
  final Worker worker;
  AttendanceWithWorker(this.attendance, this.worker);
}

/// Summary of a worker's attendance for payment calculation using All-Time Running Balance.
class WorkerPaymentSummary {
  final Worker worker;
  final double totalDaysWorked; // All-time effective days
  final double totalEarnedWages; // All-time earned wages
  final double totalPaymentsPaid; // All-time payments issued
  final double amountDue; // Net running balance due
  final double rangeDays; // Selected date range days (for display)

  WorkerPaymentSummary({
    required this.worker,
    required this.totalDaysWorked,
    required this.totalEarnedWages,
    required this.totalPaymentsPaid,
    required this.amountDue,
    required this.rangeDays,
  });

  double get effectiveDays => rangeDays;
}

@DriftAccessor(tables: [Workers, Attendance, Projects])
class LabourDao extends DatabaseAccessor<AppDatabase> with _$LabourDaoMixin {
  LabourDao(super.db);

  // --- Worker CRUD ---

  Stream<List<Worker>> watchAllWorkers() =>
      (select(workers)..orderBy([(w) => OrderingTerm.asc(w.name)])).watch();

  Future<List<Worker>> getAllWorkers() => select(workers).get();

  Future<Worker?> getWorkerById(int id) =>
      (select(workers)..where((w) => w.id.equals(id))).getSingleOrNull();

  Future<int> insertWorker(WorkersCompanion entry) =>
      into(workers).insert(entry);

  Future<bool> updateWorker(WorkersCompanion entry) =>
      update(workers).replace(entry);

  Future<int> deleteWorker(int id) =>
      (delete(workers)..where((w) => w.id.equals(id))).go();

  // --- Attendance ---

  /// Watch attendance for a specific date and project.
  Stream<List<AttendanceWithWorker>> watchAttendanceForDate(
    DateTime date,
    int projectId,
  ) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final query = select(attendance).join([
      innerJoin(workers, workers.id.equalsExp(attendance.workerId)),
    ])
      ..where(attendance.projectId.equals(projectId))
      ..where(attendance.date.isBiggerOrEqualValue(dayStart))
      ..where(attendance.date.isSmallerThanValue(dayEnd))
      ..orderBy([OrderingTerm.asc(workers.name)]);
    return query.watch().map(
          (rows) => rows
              .map(
                (r) => AttendanceWithWorker(
                  r.readTable(attendance),
                  r.readTable(workers),
                ),
              )
              .toList(),
        );
  }

  /// Upsert attendance — update status if a record for (worker, project, date)
  /// already exists, otherwise insert a new one.
  ///
  /// NOTE: Drift's insertOnConflictUpdate only triggers on PRIMARY KEY conflicts.
  /// Our unique key is (workerId, projectId, date) — a secondary unique constraint.
  /// We therefore do a manual find-then-update-or-insert to guarantee the update.
  Future<void> upsertAttendance(AttendanceCompanion entry) async {
    final dateVal = entry.date.value;
    final dayStart = DateTime(dateVal.year, dateVal.month, dateVal.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final existing = await (select(attendance)
          ..where((a) => a.workerId.equals(entry.workerId.value))
          ..where((a) => a.projectId.equals(entry.projectId.value))
          ..where((a) => a.date.isBiggerOrEqualValue(dayStart))
          ..where((a) => a.date.isSmallerThanValue(dayEnd)))
        .getSingleOrNull();

    if (existing != null) {
      // Row exists — update just the status column
      await (update(attendance)..where((a) => a.id.equals(existing.id)))
          .write(AttendanceCompanion(status: entry.status));
    } else {
      // No row yet — insert fresh
      await into(attendance).insert(entry);
    }
  }

  /// Batch upsert attendance for multiple workers in a single database transaction.
  Future<void> saveBatchAttendance(List<AttendanceCompanion> entries) async {
    await db.transaction(() async {
      for (final entry in entries) {
        await upsertAttendance(entry);
      }
    });
  }

  /// Calculate payment summary for a worker using ALL-TIME Running Balance (prevents double payments).
  Future<WorkerPaymentSummary> getWorkerPaymentSummary(
    int workerId,
    int projectId,
    DateTime from,
    DateTime to,
  ) async {
    final worker = await getWorkerById(workerId);
    if (worker == null) throw StateError('Worker $workerId not found');

    // 1. All-Time Attendance
    final allRows = await (select(attendance)
          ..where((a) => a.workerId.equals(workerId))
          ..where((a) => a.projectId.equals(projectId)))
        .get();

    double allTimeDays = 0.0;
    for (final row in allRows) {
      allTimeDays += row.status.payFraction;
    }
    final allTimeEarned = allTimeDays * worker.dailyRate;

    // 2. Range Attendance (for UI display filter)
    final rangeRows = await (select(attendance)
          ..where((a) => a.workerId.equals(workerId))
          ..where((a) => a.projectId.equals(projectId))
          ..where((a) => a.date.isBiggerOrEqualValue(from))
          ..where((a) => a.date.isSmallerOrEqualValue(to)))
        .get();

    double rangeDays = 0.0;
    for (final row in rangeRows) {
      rangeDays += row.status.payFraction;
    }

    // 3. All-Time Payments Issued for this worker & project
    final paidRows = await (select(db.transactions)
          ..where((t) => t.projectId.equals(projectId))
          ..where((t) => t.workerId.equals(workerId))
          ..where((t) => t.type.equals(TransactionType.labourPayment.name)))
        .get();

    double totalPaid = 0.0;
    for (final t in paidRows) {
      totalPaid += t.amount;
    }

    final amountDue = (allTimeEarned - totalPaid) > 0 ? (allTimeEarned - totalPaid) : 0.0;

    return WorkerPaymentSummary(
      worker: worker,
      totalDaysWorked: allTimeDays,
      totalEarnedWages: allTimeEarned,
      totalPaymentsPaid: totalPaid,
      amountDue: amountDue,
      rangeDays: rangeDays,
    );
  }

  /// Get all attendance for a worker in a project for date range (for payment screen).
  Future<List<AttendanceData>> getAttendanceRange(
    int workerId,
    int projectId,
    DateTime from,
    DateTime to,
  ) =>
      (select(attendance)
            ..where((a) => a.workerId.equals(workerId))
            ..where((a) => a.projectId.equals(projectId))
            ..where((a) => a.date.isBiggerOrEqualValue(from))
            ..where((a) => a.date.isSmallerOrEqualValue(to))
            ..orderBy([(a) => OrderingTerm.asc(a.date)]))
          .get();

  /// Stream of ALL attendance records for a worker across all projects,
  /// newest first — used by the Worker Ledger detail screen.
  Stream<List<AttendanceWithWorker>> watchWorkerAttendanceAll(int workerId) {
    final query = select(attendance).join([
      innerJoin(workers, workers.id.equalsExp(attendance.workerId)),
    ])
      ..where(attendance.workerId.equals(workerId))
      ..orderBy([OrderingTerm.desc(attendance.date)]);
    return query.watch().map(
          (rows) => rows
              .map((r) => AttendanceWithWorker(
                    r.readTable(attendance),
                    r.readTable(workers),
                  ))
              .toList(),
        );
  }

  /// Stream of ALL labour payment transactions for a worker across all projects,
  /// newest first — used by the Worker Ledger detail screen.
  Stream<List<Transaction>> watchWorkerPayments(int workerId) =>
      (select(db.transactions)
            ..where((t) => t.workerId.equals(workerId))
            ..where(
                (t) => t.type.equals(TransactionType.labourPayment.name))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();
}
