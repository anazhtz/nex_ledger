import 'package:drift/drift.dart';

/// Expense category master — stores group + sub-category pairs.
///
/// Default rows are seeded on DB creation and cannot be deleted.
/// Users may add custom rows (isDefault = false) which are deletable.
class ExpenseCategories extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Parent group label, e.g. "Vehicle Expenses"
  TextColumn get groupName => text().withLength(min: 1, max: 100)();

  /// Sub-category label, e.g. "Fuel (Vehicle)"
  TextColumn get subCategory => text().withLength(min: 1, max: 100)();

  /// Seeded rows are flagged true — UI must prevent deletion of these.
  BoolColumn get isDefault => boolean().withDefault(const Constant(true))();

  /// Soft-delete: false = hidden from dropdowns but data retained.
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Controls display order within a group.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
