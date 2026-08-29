import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/database/daos/project_budget_dao.dart';
import 'package:nex_ledger/features/budgets/data/project_budget_repository.dart';

/// Repository Provider for Project Budgets
final projectBudgetRepositoryProvider = Provider<ProjectBudgetRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProjectBudgetRepository(
    db.projectBudgetDao,
    db.projectDao,
    db.transactionDao,
    db,
  );
});

/// Selected project filter on the Budget Hub screen
final projectBudgetFilterProvider = StateProvider<int?>((ref) => null);

/// Search query filter for project budgets
final projectBudgetSearchQueryProvider = StateProvider<String>((ref) => '');

/// Stream of all project budget summaries
final allProjectBudgetSummariesProvider =
    StreamProvider<List<ProjectBudgetSummary>>((ref) {
  final repo = ref.watch(projectBudgetRepositoryProvider);
  return repo.watchAllProjectBudgetSummaries();
});

/// Stream of budget summary for a single project
final projectBudgetSummaryProvider =
    StreamProvider.family<ProjectBudgetSummary?, int>((ref, projectId) {
  final repo = ref.watch(projectBudgetRepositoryProvider);
  return repo.watchProjectBudgetSummary(projectId);
});

/// Stream of portfolio-wide budget metrics
final budgetPortfolioMetricsProvider =
    StreamProvider<BudgetPortfolioMetrics>((ref) {
  final repo = ref.watch(projectBudgetRepositoryProvider);
  return repo.watchBudgetPortfolioMetrics();
});

/// Filtered project budget summaries based on project selector & search query
final filteredProjectBudgetSummariesProvider =
    Provider<AsyncValue<List<ProjectBudgetSummary>>>((ref) {
  final allSummariesAsync = ref.watch(allProjectBudgetSummariesProvider);
  final filterProject = ref.watch(projectBudgetFilterProvider);
  final searchQuery = ref.watch(projectBudgetSearchQueryProvider).trim().toLowerCase();

  return allSummariesAsync.whenData((summaries) {
    return summaries.where((s) {
      if (filterProject != null && s.project.id != filterProject) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final matchesName = s.project.name.toLowerCase().contains(searchQuery);
        final matchesCode = s.project.code.toLowerCase().contains(searchQuery);
        final matchesClient = (s.project.clientName ?? '').toLowerCase().contains(searchQuery);
        if (!matchesName && !matchesCode && !matchesClient) return false;
      }
      return true;
    }).toList();
  });
});
