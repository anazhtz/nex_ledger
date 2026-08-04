import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/labour/data/labour_repository.dart';

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
  final projectId = ref.watch(attendanceProjectProvider);
  if (projectId == null) return const Stream.empty();
  return ref
      .watch(labourRepositoryProvider)
      .watchAttendanceForDate(date, projectId);
});
