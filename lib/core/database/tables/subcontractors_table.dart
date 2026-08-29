import 'package:drift/drift.dart';

/// Subcontractors table — master list of subcontracting gangs, labour contractors, & piece-rate maistries.
class Subcontractors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get trade => text().withLength(min: 1, max: 100)(); // e.g. Plastering, Tile Laying, Painting, Masonry
  TextColumn get contact => text().nullable()();
  TextColumn get panOrGst => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
