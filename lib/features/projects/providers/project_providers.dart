import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/features/projects/data/project_repository.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProjectRepository(db.projectDao);
});

/// Stream of all projects.
final projectListProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchAllProjects();
});

/// Stream of active projects only.
final activeProjectsProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchActiveProjects();
});

/// Global Active Selected Project ID.
/// Null means "All Projects / Global View".
final selectedProjectIdProvider = StateProvider<int?>((ref) => null);

/// Get currently selected Project object (or null).
final currentSelectedProjectProvider = Provider<Project?>((ref) {
  final selectedId = ref.watch(selectedProjectIdProvider);
  if (selectedId == null) return null;
  final projectsAsync = ref.watch(projectListProvider);
  return projectsAsync.whenOrNull(
    data: (projects) => projects.where((p) => p.id == selectedId).firstOrNull,
  );
});
