import 'package:drift/drift.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/expense_categories_table.dart';

part 'expense_category_dao.g.dart';

@DriftAccessor(tables: [ExpenseCategories])
class ExpenseCategoryDao extends DatabaseAccessor<AppDatabase>
    with _$ExpenseCategoryDaoMixin {
  ExpenseCategoryDao(super.db);

  /// Watch all active categories ordered by group then sort order.
  Stream<List<ExpenseCategory>> watchAllActiveCategories() =>
      (select(expenseCategories)
            ..where((c) => c.isActive.equals(true))
            ..orderBy([
              (c) => OrderingTerm.asc(c.groupName),
              (c) => OrderingTerm.asc(c.sortOrder),
              (c) => OrderingTerm.asc(c.subCategory),
            ]))
          .watch();

  /// Get all active categories as a one-shot read.
  Future<List<ExpenseCategory>> getAllActiveCategories() =>
      (select(expenseCategories)
            ..where((c) => c.isActive.equals(true))
            ..orderBy([
              (c) => OrderingTerm.asc(c.groupName),
              (c) => OrderingTerm.asc(c.sortOrder),
            ]))
          .get();

  /// Get distinct active group names.
  Future<List<String>> getActiveGroups() async {
    final rows = await getAllActiveCategories();
    final seen = <String>{};
    final groups = <String>[];
    for (final r in rows) {
      if (seen.add(r.groupName)) groups.add(r.groupName);
    }
    return groups;
  }

  /// Watch categories for a specific group.
  Stream<List<ExpenseCategory>> watchCategoriesForGroup(String group) =>
      (select(expenseCategories)
            ..where((c) => c.isActive.equals(true))
            ..where((c) => c.groupName.equals(group))
            ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
          .watch();

  /// Get a single category by id.
  Future<ExpenseCategory?> getCategoryById(int id) =>
      (select(expenseCategories)..where((c) => c.id.equals(id)))
          .getSingleOrNull();

  /// Insert a new (custom) category.
  Future<int> insertCategory(ExpenseCategoriesCompanion entry) =>
      into(expenseCategories).insert(entry);

  /// Soft-delete a custom category (must not be a default one).
  Future<void> softDeleteCategory(int id) async {
    final cat = await getCategoryById(id);
    if (cat == null) return;
    if (cat.isDefault) throw Exception('Cannot delete a built-in category.');
    await (update(expenseCategories)..where((c) => c.id.equals(id)))
        .write(const ExpenseCategoriesCompanion(isActive: Value(false)));
  }
}
