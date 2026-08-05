import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/expense_categories/data/expense_category_repository.dart';

final expenseCategoryRepositoryProvider =
    Provider<ExpenseCategoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExpenseCategoryRepository(db.expenseCategoryDao);
});

/// Live stream of all active expense categories.
final expenseCategoryListProvider =
    StreamProvider<List<ExpenseCategory>>((ref) {
  return ref
      .watch(expenseCategoryRepositoryProvider)
      .watchAllActiveCategories();
});
