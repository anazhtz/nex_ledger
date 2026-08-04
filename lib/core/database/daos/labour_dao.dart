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

/// Summary of a worker's attendance for payment calculation.
class WorkerPaymentSummary {
  final Worker worker;
  final double effectiveDays; // present=1.0, halfDay=0.5
  final double amountDue;
  WorkerPaymentSummary(this.worker, this.effectiveDays, this.amountDue);
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

  /// Upsert attendance (insert or replace if (worker,project,date) exists).
  Future<void> upsertAttendance(AttendanceCompanion entry) =>
      into(attendance).insertOnConflictUpdate(entry);

  /// Calculate payment summary for a worker over a date range.
  Future<WorkerPaymentSummary> getWorkerPaymentSummary(
    int workerId,
    int projectId,
    DateTime from,
    DateTime to,
  ) async {
    final worker = await getWorkerById(workerId);
    if (worker == null) throw StateError('Worker $workerId not found');

    final rows = await (select(attendance)
          ..where((a) => a.workerId.equals(workerId))
          ..where((a) => a.projectId.equals(projectId))
          ..where((a) => a.date.isBiggerOrEqualValue(from))
          ..where((a) => a.date.isSmallerOrEqualValue(to)))
        .get();

    double effectiveDays = 0.0;
    for (final row in rows) {
      effectiveDays += row.status.payFraction;
    }
    final amountDue = effectiveDays * worker.dailyRate;
    return WorkerPaymentSummary(worker, effectiveDays, amountDue);
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
}
