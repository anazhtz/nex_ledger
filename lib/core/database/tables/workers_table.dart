import 'package:drift/drift.dart';

/// Workers (labour) master.
class Workers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get workerCode => text().nullable()();
  TextColumn get trade => text().nullable()();
  RealColumn get dailyRate => real().withDefault(const Constant(0.0))();

  /// Overtime pay per hour. 0 means "not set" — the app then uses
  /// dailyRate ÷ 8 (a standard 8-hour day). See WorkerWageX.effectiveOvertimeRate.
  RealColumn get overtimeRate => real().withDefault(const Constant(0.0))();
}
