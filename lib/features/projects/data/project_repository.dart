import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

class ProjectRepository {
  final ProjectDao _dao;
  ProjectRepository(this._dao);

  Stream<List<Project>> watchAllProjects() => _dao.watchAllProjects();
  Stream<List<Project>> watchActiveProjects() => _dao.watchActiveProjects();
  Future<List<Project>> getAllProjects() => _dao.getAllProjects();
  Future<Project?> getProjectById(int id) => _dao.getProjectById(id);

  Future<int> createProject({
    required String code,
    required String name,
    String? clientName,
    required ProjectType type,
    required ProjectStatus status,
    required DateTime startDate,
    double? budget,
  }) async {
    final codeTaken = await _dao.isCodeTaken(code);
    if (codeTaken) throw Exception('Project code "$code" is already in use.');

    return _dao.insertProject(
      ProjectsCompanion.insert(
        code: code.trim().toUpperCase(),
        name: name.trim(),
        clientName: Value(clientName?.trim()),
        type: type,
        status: status,
        startDate: startDate,
        budget: Value(budget),
      ),
    );
  }

  Future<void> updateProject({
    required int id,
    required String code,
    required String name,
    String? clientName,
    required ProjectType type,
    required ProjectStatus status,
    required DateTime startDate,
    double? budget,
  }) async {
    final codeTaken = await _dao.isCodeTaken(code, excludeId: id);
    if (codeTaken) throw Exception('Project code "$code" is already in use.');

    await _dao.updateProject(
      ProjectsCompanion(
        id: Value(id),
        code: Value(code.trim().toUpperCase()),
        name: Value(name.trim()),
        clientName: Value(clientName?.trim()),
        type: Value(type),
        status: Value(status),
        startDate: Value(startDate),
        budget: Value(budget),
      ),
    );
  }

  Future<void> closeProject(int id) => _dao.closeProject(id);

  Future<void> deleteProject(int id) async {
    final project = await _dao.getProjectById(id);
    if (project != null && project.code == 'ADMIN-OVH') {
      throw Exception('The default Admin / Overhead system project cannot be deleted.');
    }
    await _dao.deleteProject(id);
  }
}
