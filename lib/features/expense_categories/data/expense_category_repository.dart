import 'package:drift/drift.dart';
import 'package:nex_ledger/core/database/app_database.dart';

class ExpenseCategoryRepository {
  final ExpenseCategoryDao _dao;
  ExpenseCategoryRepository(this._dao);

  /// Watch all active categories (live stream).
  Stream<List<ExpenseCategory>> watchAllActiveCategories() =>
      _dao.watchAllActiveCategories();

  /// Get all active categories as a one-shot read.
  Future<List<ExpenseCategory>> getAllActiveCategories() =>
      _dao.getAllActiveCategories();

  /// Get distinct active group names.
  Future<List<String>> getActiveGroups() => _dao.getActiveGroups();

  /// Watch categories for a specific group.
  Stream<List<ExpenseCategory>> watchCategoriesForGroup(String group) =>
      _dao.watchCategoriesForGroup(group);

  /// Add a new custom category (user-defined, not default).
  Future<int> addCustomCategory({
    required String groupName,
    required String subCategory,
  }) =>
      _dao.insertCategory(
        ExpenseCategoriesCompanion.insert(
          groupName: groupName.trim(),
          subCategory: subCategory.trim(),
          isDefault: const Value(false),
          isActive: const Value(true),
        ),
      );

  /// Soft-delete a custom category.
  /// Throws if the category is a built-in default.
  Future<void> deleteCustomCategory(int id) =>
      _dao.softDeleteCategory(id);
}
