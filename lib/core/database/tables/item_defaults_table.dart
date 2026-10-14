import 'package:drift/drift.dart';

/// Remembers the HSN code, GST rate and unit last used for a material, so the
/// next purchase of the same item fills them in. No GST rates are built in:
/// the user sets a rate once per material and the app remembers it.
class ItemDefaults extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Lower-cased, trimmed name used for matching.
  TextColumn get itemKey => text()();

  /// Name as the user typed it.
  TextColumn get itemName => text()();
  TextColumn get hsn => text().nullable()();
  RealColumn get gstRate => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {itemKey},
      ];
}
