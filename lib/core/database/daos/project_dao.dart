import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/tables/projects_table.dart';

part 'project_dao.g.dart';

@DriftAccessor(tables: [Projects])
class ProjectDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectDaoMixin {
  ProjectDao(super.db);

  /// Stream of all projects ordered by creation date desc.
  Stream<List<Project>> watchAllProjects() =>
      (select(projects)..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .watch();

  /// Stream of active projects only.
  Stream<List<Project>> watchActiveProjects() =>
      (select(projects)
            ..where((p) => p.status.equalsValue(ProjectStatus.active))
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .watch();

  /// One-off read of all projects (for export/reports).
  Future<List<Project>> getAllProjects() => select(projects).get();

  /// Get a single project by id.
  Future<Project?> getProjectById(int id) =>
      (select(projects)..where((p) => p.id.equals(id))).getSingleOrNull();

  /// Insert a new project. Returns the new row's id.
  Future<int> insertProject(ProjectsCompanion entry) =>
      into(projects).insert(entry);

  /// Update an existing project.
  Future<bool> updateProject(ProjectsCompanion entry) =>
      update(projects).replace(entry);

  /// Soft-delete by setting status to closed (no hard deletes for audit trail).
  Future<int> closeProject(int id) => (update(projects)
        ..where((p) => p.id.equals(id)))
      .write(const ProjectsCompanion(status: Value(ProjectStatus.closed)));

  /// Hard delete — only used in tests / admin.
  Future<int> deleteProject(int id) =>
      (delete(projects)..where((p) => p.id.equals(id))).go();

  /// Check if project code is already taken (for validation).
  Future<bool> isCodeTaken(String code, {int? excludeId}) async {
    final q = select(projects)..where((p) => p.code.equals(code));
    if (excludeId != null) {
      q.where((p) => p.id.equals(excludeId).not());
    }
    final result = await q.getSingleOrNull();
    return result != null;
  }
}
