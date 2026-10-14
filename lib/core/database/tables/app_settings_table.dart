import 'package:drift/drift.dart';

/// Small key-value store for company-level settings (company GSTIN, state...).
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
