import 'package:drift/drift.dart';

/// Vendors for purchase entries.
class Vendors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get contact => text().nullable()();
}
