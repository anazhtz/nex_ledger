import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/labour/data/labour_repository.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';

final labourRepositoryProvider = Provider<LabourRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LabourRepository(db.labourDao, db.transactionDao);
});

final workerListProvider = StreamProvider<List<Worker>>((ref) {
  return ref.watch(labourRepositoryProvider).watchAllWorkers();
});

/// Selected date for attendance screen.
final attendanceDateProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

/// Selected project for attendance screen.
final attendanceProjectProvider = StateProvider<int?>((ref) => null);

final attendanceListProvider =
    StreamProvider<List<AttendanceWithWorker>>((ref) {
  final date = ref.watch(attendanceDateProvider);
  final globalProject = ref.watch(selectedProjectIdProvider);
  final projectId = ref.watch(attendanceProjectProvider) ?? globalProject;
  if (projectId == null) return Stream.value(<AttendanceWithWorker>[]);
  return ref
      .watch(labourRepositoryProvider)
      .watchAttendanceForDate(date, projectId);
});

// ─── Worker Ledger Providers ──────────────────────────────────────────────────

/// Stream of all attendance records for a single worker (all projects, newest first).
final workerAttendanceAllProvider =
    StreamProvider.family<List<AttendanceWithWorker>, int>((ref, workerId) {
  final db = ref.watch(appDatabaseProvider);
  return db.labourDao.watchWorkerAttendanceAll(workerId);
});

/// Stream of all labour payment transactions for a single worker (newest first).
final workerPaymentsProvider =
    StreamProvider.family<List<Transaction>, int>((ref, workerId) {
  final db = ref.watch(appDatabaseProvider);
  return db.labourDao.watchWorkerPayments(workerId);
});

/// All-time ledger summary for a worker — totals computed reactively.
class WorkerLedgerSummary {
  final Worker worker;
  final double totalDaysWorked;
  final double totalEarned;
  final double totalPaid;
  final double balanceDue;

  const WorkerLedgerSummary({
    required this.worker,
    required this.totalDaysWorked,
    required this.totalEarned,
    required this.totalPaid,
    required this.balanceDue,
  });
}

/// Reactive summary for a worker: recomputes whenever attendance or payments change.
final workerLedgerSummaryProvider =
    StreamProvider.family<WorkerLedgerSummary, int>((ref, workerId) {
  final db = ref.watch(appDatabaseProvider);

  final workerStream =
      db.labourDao.watchAllWorkers().map((list) =>
          list.where((w) => w.id == workerId).firstOrNull);

  return _combine2(
    () => workerStream,
    () => _combineAttendanceAndPayments(
      db.labourDao.watchWorkerAttendanceAll(workerId),
      db.labourDao.watchWorkerPayments(workerId),
    ),
    (worker, pair) {
      if (worker == null) throw StateError('Worker $workerId not found');
      final (days, paid) = pair;
      final earned = days * worker.dailyRate;
      final due = (earned - paid) > 0 ? earned - paid : 0.0;
      return WorkerLedgerSummary(
        worker: worker,
        totalDaysWorked: days,
        totalEarned: earned,
        totalPaid: paid,
        balanceDue: due,
      );
    },
  );
});

/// Combines attendance + payment streams into a (totalDays, totalPaid) tuple.
Stream<(double, double)> _combineAttendanceAndPayments(
  Stream<List<AttendanceWithWorker>> attendanceStream,
  Stream<List<Transaction>> paymentsStream,
) =>
    _combine2(
      () => attendanceStream,
      () => paymentsStream,
      (attendance, payments) {
        final days = attendance.fold<double>(
            0.0, (s, a) => s + a.attendance.status.payFraction);
        final paid =
            payments.fold<double>(0.0, (s, t) => s + t.amount);
        return (days, paid);
      },
    );

/// Helper: combine two broadcast streams into one, emitting whenever either updates.
Stream<R> _combine2<A, B, R>(
  Stream<A> Function() createA,
  Stream<B> Function() createB,
  R Function(A a, B b) combiner,
) {
  late StreamController<R> controller;
  A? lastA;
  B? lastB;
  bool hasA = false;
  bool hasB = false;

  void tryEmit() {
    if (hasA && hasB && !controller.isClosed) {
      try {
        controller.add(combiner(lastA as A, lastB as B));
      } catch (e, st) {
        controller.addError(e, st);
      }
    }
  }

  StreamSubscription<A>? subA;
  StreamSubscription<B>? subB;

  controller = StreamController<R>.broadcast(
    onListen: () {
      subA = createA().listen(
        (a) { lastA = a; hasA = true; tryEmit(); },
        onError: controller.addError,
      );
      subB = createB().listen(
        (b) { lastB = b; hasB = true; tryEmit(); },
        onError: controller.addError,
      );
    },
    onCancel: () {
      subA?.cancel();
      subB?.cancel();
    },
  );

  return controller.stream;
}
