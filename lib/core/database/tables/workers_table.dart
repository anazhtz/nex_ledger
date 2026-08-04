import 'package:drift/drift.dart';

/// Workers (labour) master.
class Workers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get workerCode => text().nullable()();
  RealColumn get dailyRate => real().withDefault(const Constant(0.0))();
}
