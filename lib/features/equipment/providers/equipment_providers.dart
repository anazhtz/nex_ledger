import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/database/daos/equipment_dao.dart';
import 'package:nex_ledger/features/equipment/data/equipment_repository.dart';

/// Equipment Repository Provider
final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return EquipmentRepository(
    db.equipmentDao,
    db.transactionDao,
    db,
  );
});

// ─── Filter States ──────────────────────────────────────────────────────────

final equipmentFilterProjectProvider = StateProvider<int?>((ref) => null);
final equipmentFilterCategoryProvider = StateProvider<String?>((ref) => null);
final equipmentSearchQueryProvider = StateProvider<String>((ref) => '');

final equipmentLogsFilterEquipmentProvider = StateProvider<int?>((ref) => null);
final equipmentLogsFilterProjectProvider = StateProvider<int?>((ref) => null);
final equipmentLogsSearchQueryProvider = StateProvider<String>((ref) => '');

// ─── Streams ────────────────────────────────────────────────────────────────

final allEquipmentsProvider =
    StreamProvider<List<EquipmentWithDetails>>((ref) {
  final repo = ref.watch(equipmentRepositoryProvider);
  return repo.watchAllEquipments();
});

final singleEquipmentProvider =
    StreamProvider.family<EquipmentWithDetails?, int>((ref, id) {
  final repo = ref.watch(equipmentRepositoryProvider);
  return repo.watchEquipmentById(id);
});

final allEquipmentLogsProvider =
    StreamProvider<List<EquipmentLogDetail>>((ref) {
  final repo = ref.watch(equipmentRepositoryProvider);
  final proj = ref.watch(equipmentLogsFilterProjectProvider);
  final equip = ref.watch(equipmentLogsFilterEquipmentProvider);
  return repo.watchEquipmentLogs(projectId: proj, equipmentId: equip);
});

final equipmentFleetMetricsProvider =
    StreamProvider<EquipmentFleetMetrics>((ref) {
  final repo = ref.watch(equipmentRepositoryProvider);
  return repo.watchEquipmentFleetMetrics();
});

// ─── Filtered Data Providers ────────────────────────────────────────────────

final filteredEquipmentsProvider =
    Provider<AsyncValue<List<EquipmentWithDetails>>>((ref) {
  final allAsync = ref.watch(allEquipmentsProvider);
  final filterProject = ref.watch(equipmentFilterProjectProvider);
  final filterCat = ref.watch(equipmentFilterCategoryProvider);
  final search = ref.watch(equipmentSearchQueryProvider).trim().toLowerCase();

  return allAsync.whenData((list) {
    return list.where((item) {
      if (filterProject != null && item.equipment.currentProjectId != filterProject) {
        return false;
      }
      if (filterCat != null && item.equipment.category != filterCat) {
        return false;
      }
      if (search.isNotEmpty) {
        final matchesName = item.equipment.name.toLowerCase().contains(search);
        final matchesAsset = item.equipment.assetOrRegNumber.toLowerCase().contains(search);
        final matchesVendor = (item.vendor?.name ?? '').toLowerCase().contains(search);
        final matchesProject = (item.project?.name ?? '').toLowerCase().contains(search);
        if (!matchesName && !matchesAsset && !matchesVendor && !matchesProject) return false;
      }
      return true;
    }).toList();
  });
});

final filteredEquipmentLogsProvider =
    Provider<AsyncValue<List<EquipmentLogDetail>>>((ref) {
  final allLogsAsync = ref.watch(allEquipmentLogsProvider);
  final search = ref.watch(equipmentLogsSearchQueryProvider).trim().toLowerCase();

  return allLogsAsync.whenData((logs) {
    if (search.isEmpty) return logs;
    return logs.where((l) {
      final matchesEq = l.equipment.name.toLowerCase().contains(search);
      final matchesReg = l.equipment.assetOrRegNumber.toLowerCase().contains(search);
      final matchesDesc = l.log.workDescription.toLowerCase().contains(search);
      final matchesOp = (l.log.operatorName ?? '').toLowerCase().contains(search);
      return matchesEq || matchesReg || matchesDesc || matchesOp;
    }).toList();
  });
});
