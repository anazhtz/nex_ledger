import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import '../app_database.dart';
import '../tables/equipments_table.dart';
import '../tables/equipment_logs_table.dart';
import '../tables/projects_table.dart';
import '../tables/vendors_table.dart';

part 'equipment_dao.g.dart';

/// Equipment combined with Vendor, Project & Usage summary
class EquipmentWithDetails {
  final Equipment equipment;
  final Vendor? vendor;
  final Project? project;
  final double totalLoggedUnits;
  final double totalGrossRentalCost;
  final double totalFuelDeduction;
  final double totalNetCost;
  final int logCount;

  EquipmentWithDetails({
    required this.equipment,
    this.vendor,
    this.project,
    required this.totalLoggedUnits,
    required this.totalGrossRentalCost,
    required this.totalFuelDeduction,
    required this.totalNetCost,
    required this.logCount,
  });
}

/// Detailed Daily Equipment Log entry
class EquipmentLogDetail {
  final EquipmentLog log;
  final Equipment equipment;
  final Project project;
  final Vendor? vendor;

  EquipmentLogDetail({
    required this.log,
    required this.equipment,
    required this.project,
    this.vendor,
  });
}

/// Portfolio Machinery & Rental Metrics
class EquipmentFleetMetrics {
  final int totalMachineryCount;
  final int activeOnSiteCount;
  final int rentedCount;
  final int ownedCount;
  final double totalLoggedUnits;
  final double totalGrossRentalIncurred;
  final double totalFuelDeducted;
  final double totalNetRentalPayable;

  EquipmentFleetMetrics({
    required this.totalMachineryCount,
    required this.activeOnSiteCount,
    required this.rentedCount,
    required this.ownedCount,
    required this.totalLoggedUnits,
    required this.totalGrossRentalIncurred,
    required this.totalFuelDeducted,
    required this.totalNetRentalPayable,
  });
}

@DriftAccessor(tables: [Equipments, EquipmentLogs, Projects, Vendors, Transactions])
class EquipmentDao extends DatabaseAccessor<AppDatabase> with _$EquipmentDaoMixin {
  EquipmentDao(super.db);

  // ─── Equipment CRUD ────────────────────────────────────────────────────────

  Future<int> insertEquipment(EquipmentsCompanion companion) =>
      into(equipments).insert(companion);

  Future<bool> updateEquipment(EquipmentsCompanion companion) =>
      update(equipments).replace(companion);

  Future<int> deleteEquipment(int id) =>
      (delete(equipments)..where((e) => e.id.equals(id))).go();

  // ─── Equipment Log CRUD ───────────────────────────────────────────────────

  Future<int> insertEquipmentLog(EquipmentLogsCompanion companion) =>
      into(equipmentLogs).insert(companion);

  Future<bool> updateEquipmentLog(EquipmentLogsCompanion companion) =>
      update(equipmentLogs).replace(companion);

  Future<int> deleteEquipmentLog(int id) =>
      (delete(equipmentLogs)..where((l) => l.id.equals(id))).go();

  // ─── Stream Queries ───────────────────────────────────────────────────────

  /// Watch all equipment with linked vendor, active project and cumulative stats
  Stream<List<EquipmentWithDetails>> watchAllEquipments() {
    return customSelect(
      'SELECT 1',
      readsFrom: {equipments, equipmentLogs, projects, vendors},
    ).watch().asyncMap((_) async {
      final allEquipments = await (select(equipments)
            ..orderBy([(e) => OrderingTerm.asc(e.name)]))
          .get();

      final allVendors = await select(vendors).get();
      final vendorMap = {for (final v in allVendors) v.id: v};

      final allProjects = await select(projects).get();
      final projectMap = {for (final p in allProjects) p.id: p};

      final allLogs = await select(equipmentLogs).get();
      final logMap = <int, List<EquipmentLog>>{};
      for (final l in allLogs) {
        logMap.putIfAbsent(l.equipmentId, () => []).add(l);
      }

      return allEquipments.map((e) {
        final logs = logMap[e.id] ?? [];
        final totalUnits = logs.fold<double>(0.0, (sum, l) => sum + l.billableUnits);
        final totalGross = logs.fold<double>(0.0, (sum, l) => sum + l.grossRentalCost);
        final totalFuel = logs.fold<double>(0.0, (sum, l) => sum + l.fuelCostDeduction);
        final totalNet = logs.fold<double>(0.0, (sum, l) => sum + l.netPayableAmount);

        return EquipmentWithDetails(
          equipment: e,
          vendor: e.vendorId != null ? vendorMap[e.vendorId] : null,
          project: e.currentProjectId != null ? projectMap[e.currentProjectId] : null,
          totalLoggedUnits: totalUnits,
          totalGrossRentalCost: totalGross,
          totalFuelDeduction: totalFuel,
          totalNetCost: totalNet,
          logCount: logs.length,
        );
      }).toList();
    });
  }

  /// Watch single equipment with details
  Stream<EquipmentWithDetails?> watchEquipmentById(int id) {
    return watchAllEquipments().map((list) {
      final matches = list.where((item) => item.equipment.id == id);
      return matches.isNotEmpty ? matches.first : null;
    });
  }

  /// Watch filtered equipment logs
  Stream<List<EquipmentLogDetail>> watchEquipmentLogs({
    int? projectId,
    int? equipmentId,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return customSelect(
      'SELECT 1',
      readsFrom: {equipmentLogs, equipments, projects, vendors},
    ).watch().asyncMap((_) async {
      final query = select(equipmentLogs)
        ..orderBy([(l) => OrderingTerm.desc(l.logDate), (l) => OrderingTerm.desc(l.id)]);

      if (projectId != null) {
        query.where((l) => l.projectId.equals(projectId));
      }
      if (equipmentId != null) {
        query.where((l) => l.equipmentId.equals(equipmentId));
      }
      if (fromDate != null) {
        query.where((l) => l.logDate.isBiggerOrEqualValue(fromDate));
      }
      if (toDate != null) {
        query.where((l) => l.logDate.isSmallerOrEqualValue(toDate));
      }

      final logs = await query.get();
      final allEquipments = await select(equipments).get();
      final equipmentMap = {for (final e in allEquipments) e.id: e};

      final allProjects = await select(projects).get();
      final projectMap = {for (final p in allProjects) p.id: p};

      final allVendors = await select(vendors).get();
      final vendorMap = {for (final v in allVendors) v.id: v};

      final results = <EquipmentLogDetail>[];
      for (final log in logs) {
        final eq = equipmentMap[log.equipmentId];
        final proj = projectMap[log.projectId];
        if (eq != null && proj != null) {
          final vendor = eq.vendorId != null ? vendorMap[eq.vendorId] : null;
          results.add(EquipmentLogDetail(
            log: log,
            equipment: eq,
            project: proj,
            vendor: vendor,
          ));
        }
      }
      return results;
    });
  }

  /// Watch portfolio fleet metrics
  Stream<EquipmentFleetMetrics> watchEquipmentFleetMetrics() {
    return customSelect(
      'SELECT 1',
      readsFrom: {equipments, equipmentLogs},
    ).watch().asyncMap((_) async {
      final allEquipments = await select(equipments).get();
      final allLogs = await select(equipmentLogs).get();

      final totalMachinery = allEquipments.length;
      final activeOnSite = allEquipments.where((e) => e.status == EquipmentStatus.active).length;
      final rentedCount = allEquipments.where((e) => e.ownership == EquipmentOwnership.rented).length;
      final ownedCount = allEquipments.where((e) => e.ownership == EquipmentOwnership.owned).length;

      final totalUnits = allLogs.fold<double>(0.0, (sum, l) => sum + l.billableUnits);
      final totalGross = allLogs.fold<double>(0.0, (sum, l) => sum + l.grossRentalCost);
      final totalFuel = allLogs.fold<double>(0.0, (sum, l) => sum + l.fuelCostDeduction);
      final totalNet = allLogs.fold<double>(0.0, (sum, l) => sum + l.netPayableAmount);

      return EquipmentFleetMetrics(
        totalMachineryCount: totalMachinery,
        activeOnSiteCount: activeOnSite,
        rentedCount: rentedCount,
        ownedCount: ownedCount,
        totalLoggedUnits: totalUnits,
        totalGrossRentalIncurred: totalGross,
        totalFuelDeducted: totalFuel,
        totalNetRentalPayable: totalNet,
      );
    });
  }
}
