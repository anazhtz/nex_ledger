import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/daos/equipment_dao.dart';

class EquipmentRepository {
  final EquipmentDao _equipmentDao;
  final TransactionDao _txnDao;
  final AppDatabase _db;

  EquipmentRepository(
    this._equipmentDao,
    this._txnDao,
    this._db,
  );

  // ─── Equipment Master Operations ───────────────────────────────────────────

  Future<int> createEquipment({
    required String name,
    required String assetOrRegNumber,
    required String category,
    required EquipmentOwnership ownership,
    int? vendorId,
    int? currentProjectId,
    required EquipmentRentalBasis rentalBasis,
    required double standardRate,
    required EquipmentFuelPolicy fuelPolicy,
    String? operatorName,
    String? operatorContact,
    EquipmentStatus status = EquipmentStatus.active,
    String? notes,
  }) {
    return _equipmentDao.insertEquipment(
      EquipmentsCompanion.insert(
        name: name,
        assetOrRegNumber: assetOrRegNumber,
        category: Value(category),
        ownership: Value(ownership),
        vendorId: Value(vendorId),
        currentProjectId: Value(currentProjectId),
        rentalBasis: Value(rentalBasis),
        standardRate: Value(standardRate),
        fuelPolicy: Value(fuelPolicy),
        operatorName: Value(operatorName),
        operatorContact: Value(operatorContact),
        status: Value(status),
        notes: Value(notes),
      ),
    );
  }

  Future<bool> updateEquipment({
    required int id,
    required String name,
    required String assetOrRegNumber,
    required String category,
    required EquipmentOwnership ownership,
    int? vendorId,
    int? currentProjectId,
    required EquipmentRentalBasis rentalBasis,
    required double standardRate,
    required EquipmentFuelPolicy fuelPolicy,
    String? operatorName,
    String? operatorContact,
    required EquipmentStatus status,
    String? notes,
  }) {
    return _equipmentDao.updateEquipment(
      EquipmentsCompanion(
        id: Value(id),
        name: Value(name),
        assetOrRegNumber: Value(assetOrRegNumber),
        category: Value(category),
        ownership: Value(ownership),
        vendorId: Value(vendorId),
        currentProjectId: Value(currentProjectId),
        rentalBasis: Value(rentalBasis),
        standardRate: Value(standardRate),
        fuelPolicy: Value(fuelPolicy),
        operatorName: Value(operatorName),
        operatorContact: Value(operatorContact),
        status: Value(status),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteEquipment(int id) {
    return _equipmentDao.deleteEquipment(id);
  }

  // ─── Daily Log & Usage Operations ─────────────────────────────────────────

  Future<int> recordDailyLog({
    required int equipmentId,
    required int projectId,
    required DateTime logDate,
    double startReading = 0.0,
    double endReading = 0.0,
    required double totalUnitsLogged,
    double breakdownUnits = 0.0,
    required double billableUnits,
    required double unitRate,
    required double grossRentalCost,
    double fuelLitresIssued = 0.0,
    double fuelRatePerLitre = 0.0,
    double fuelCostDeduction = 0.0,
    required double netPayableAmount,
    required String workDescription,
    String? operatorName,
    bool supervisorVerified = true,
    String? notes,
  }) {
    return _equipmentDao.insertEquipmentLog(
      EquipmentLogsCompanion.insert(
        equipmentId: equipmentId,
        projectId: projectId,
        logDate: logDate,
        startReading: Value(startReading),
        endReading: Value(endReading),
        totalUnitsLogged: Value(totalUnitsLogged),
        breakdownUnits: Value(breakdownUnits),
        billableUnits: Value(billableUnits),
        unitRate: Value(unitRate),
        grossRentalCost: Value(grossRentalCost),
        fuelLitresIssued: Value(fuelLitresIssued),
        fuelRatePerLitre: Value(fuelRatePerLitre),
        fuelCostDeduction: Value(fuelCostDeduction),
        netPayableAmount: Value(netPayableAmount),
        workDescription: workDescription,
        operatorName: Value(operatorName),
        supervisorVerified: Value(supervisorVerified),
        notes: Value(notes),
      ),
    );
  }

  Future<bool> updateDailyLog({
    required int id,
    required int equipmentId,
    required int projectId,
    required DateTime logDate,
    required double startReading,
    required double endReading,
    required double totalUnitsLogged,
    required double breakdownUnits,
    required double billableUnits,
    required double unitRate,
    required double grossRentalCost,
    required double fuelLitresIssued,
    required double fuelRatePerLitre,
    required double fuelCostDeduction,
    required double netPayableAmount,
    required String workDescription,
    String? operatorName,
    required bool supervisorVerified,
    String? notes,
  }) {
    return _equipmentDao.updateEquipmentLog(
      EquipmentLogsCompanion(
        id: Value(id),
        equipmentId: Value(equipmentId),
        projectId: Value(projectId),
        logDate: Value(logDate),
        startReading: Value(startReading),
        endReading: Value(endReading),
        totalUnitsLogged: Value(totalUnitsLogged),
        breakdownUnits: Value(breakdownUnits),
        billableUnits: Value(billableUnits),
        unitRate: Value(unitRate),
        grossRentalCost: Value(grossRentalCost),
        fuelLitresIssued: Value(fuelLitresIssued),
        fuelRatePerLitre: Value(fuelRatePerLitre),
        fuelCostDeduction: Value(fuelCostDeduction),
        netPayableAmount: Value(netPayableAmount),
        workDescription: Value(workDescription),
        operatorName: Value(operatorName),
        supervisorVerified: Value(supervisorVerified),
        notes: Value(notes),
      ),
    );
  }

  Future<int> deleteDailyLog(int id) {
    return _equipmentDao.deleteEquipmentLog(id);
  }

  // ─── Equipment Payment & PnL Settlement ───────────────────────────────────

  Future<int> recordEquipmentRentalPayment({
    required int projectId,
    required int equipmentId,
    required double paymentAmount,
    required DateTime paymentDate,
    required PaymentMode paymentMode,
    int? bankAccountId,
    String? narration,
    String? referenceNo,
  }) async {
    return _db.transaction(() async {
      final txnId = await _txnDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          type: TransactionType.expense,
          amount: paymentAmount,
          date: paymentDate,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(narration ?? 'Machinery & Equipment Rental Settlement'),
          referenceNo: Value(referenceNo),
          affectsPnl: const Value(true),
          affectsCash: const Value(true),
        ),
      );
      return txnId;
    });
  }

  // ─── Reactive Streams ─────────────────────────────────────────────────────

  Stream<List<EquipmentWithDetails>> watchAllEquipments() =>
      _equipmentDao.watchAllEquipments();

  Stream<EquipmentWithDetails?> watchEquipmentById(int id) =>
      _equipmentDao.watchEquipmentById(id);

  Stream<List<EquipmentLogDetail>> watchEquipmentLogs({
    int? projectId,
    int? equipmentId,
    DateTime? fromDate,
    DateTime? toDate,
  }) =>
      _equipmentDao.watchEquipmentLogs(
        projectId: projectId,
        equipmentId: equipmentId,
        fromDate: fromDate,
        toDate: toDate,
      );

  Stream<EquipmentFleetMetrics> watchEquipmentFleetMetrics() =>
      _equipmentDao.watchEquipmentFleetMetrics();
}
