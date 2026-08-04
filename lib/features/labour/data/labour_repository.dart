import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

export 'package:nex_ledger/core/database/app_database.dart' show WorkerPaymentSummary;

class LabourRepository {
  final LabourDao _labourDao;
  final TransactionDao _transactionDao;

  LabourRepository(this._labourDao, this._transactionDao);

  // --- Workers ---
  Stream<List<Worker>> watchAllWorkers() => _labourDao.watchAllWorkers();

  Future<int> addWorker({
    required String name,
    String? workerCode,
    String? trade,
    required double dailyRate,
  }) =>
      _labourDao.insertWorker(
        WorkersCompanion.insert(
          name: name.trim(),
          workerCode: Value(workerCode?.trim()),
          trade: Value(trade?.trim()),
          dailyRate: Value(dailyRate),
        ),
      );

  Future<void> updateWorker({
    required int id,
    required String name,
    String? workerCode,
    String? trade,
    required double dailyRate,
  }) =>
      _labourDao.updateWorker(
        WorkersCompanion(
          id: Value(id),
          name: Value(name.trim()),
          workerCode: Value(workerCode?.trim()),
          trade: Value(trade?.trim()),
          dailyRate: Value(dailyRate),
        ),
      );

  Future<void> deleteWorker(int id) => _labourDao.deleteWorker(id);

  // --- Attendance ---

  Stream<List<AttendanceWithWorker>> watchAttendanceForDate(
          DateTime date, int projectId) =>
      _labourDao.watchAttendanceForDate(date, projectId);

  /// Mark / update attendance for a worker on a date+project.
  Future<void> markAttendance({
    required int workerId,
    required int projectId,
    required DateTime date,
    required AttendanceStatus status,
  }) =>
      _labourDao.upsertAttendance(
        AttendanceCompanion.insert(
          workerId: workerId,
          projectId: projectId,
          date: DateTime(date.year, date.month, date.day, 12), // noon, no TZ drift
          status: status,
        ),
      );

  // --- Payments ---

  Future<WorkerPaymentSummary> getPaymentSummary(
    int workerId,
    int projectId,
    DateTime from,
    DateTime to,
  ) =>
      _labourDao.getWorkerPaymentSummary(workerId, projectId, from, to);

  /// Record a labour payment transaction.
  Future<void> recordPayment({
    required int projectId,
    required DateTime date,
    required double amount,
    PaymentMode? paymentMode,
    String? narration,
    String? referenceNo,
  }) =>
      _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: date,
          type: TransactionType.labourPayment,
          affectsPnl: const Value(true),
          amount: amount,
          paymentMode: Value(paymentMode),
          narration: Value(narration),
          referenceNo: Value(referenceNo),
        ),
      );
}
