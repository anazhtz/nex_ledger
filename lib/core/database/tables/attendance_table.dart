import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'workers_table.dart';
import 'projects_table.dart';

/// Daily attendance records per worker per project.
class Attendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workerId =>
      integer().references(Workers, #id, onDelete: KeyAction.cascade)();
  IntColumn get projectId =>
      integer().references(Projects, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => textEnum<AttendanceStatus>()();

  /// Each worker can only have one attendance record per project per day.
  @override
  List<Set<Column>> get uniqueKeys => [
        {workerId, projectId, date},
      ];
}
