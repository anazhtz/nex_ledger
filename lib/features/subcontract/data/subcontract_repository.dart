import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

class SubcontractRepository {
  final SubcontractDao _subcontractDao;
  final TransactionDao _transactionDao;
  final AppDatabase _db;

  SubcontractRepository(this._subcontractDao, this._transactionDao, this._db);

  // ─── Subcontractors Master ──────────────────────────────────────────────────

  Stream<List<Subcontractor>> watchAllSubcontractors() =>
      _subcontractDao.watchAllSubcontractors();

  Future<Subcontractor?> getSubcontractorById(int id) =>
      _subcontractDao.getSubcontractorById(id);

  Future<int> addSubcontractor({
    required String name,
    required String trade,
    String? contact,
    String? panOrGst,
    String? notes,
  }) {
    return _subcontractDao.insertSubcontractor(
      SubcontractorsCompanion.insert(
        name: name.trim(),
        trade: trade.trim(),
        contact: Value(contact?.trim()),
        panOrGst: Value(panOrGst?.trim()),
        notes: Value(notes?.trim()),
      ),
    );
  }

  Future<bool> updateSubcontractor({
    required int id,
    required String name,
    required String trade,
    String? contact,
    String? panOrGst,
    String? notes,
  }) {
    return _subcontractDao.updateSubcontractor(
      SubcontractorsCompanion(
        id: Value(id),
        name: Value(name.trim()),
        trade: Value(trade.trim()),
        contact: Value(contact?.trim()),
        panOrGst: Value(panOrGst?.trim()),
        notes: Value(notes?.trim()),
      ),
    );
  }

  Future<int> deleteSubcontractor(int id) =>
      _subcontractDao.deleteSubcontractor(id);

  Stream<List<SubcontractorSummary>> watchAllSubcontractorSummaries() =>
      _subcontractDao.watchAllSubcontractorSummaries();

  // ─── Work Orders ────────────────────────────────────────────────────────────

  Stream<List<WorkOrderDetail>> watchWorkOrders({
    int? projectId,
    int? subcontractorId,
    WorkOrderStatus? status,
  }) =>
      _subcontractDao.watchWorkOrders(
        projectId: projectId,
        subcontractorId: subcontractorId,
        status: status,
      );

  Future<WorkOrderDetail?> getWorkOrderDetailById(int id) =>
      _subcontractDao.getWorkOrderDetailById(id);

  Stream<WorkOrderFinancialSummary?> watchWorkOrderFinancialSummary(
          int workOrderId) =>
      _subcontractDao.watchWorkOrderFinancialSummary(workOrderId);

  Future<int> createWorkOrder({
    required String orderNumber,
    required int projectId,
    required int subcontractorId,
    required String title,
    required String trade,
    required String unit,
    required double agreedRate,
    required double estimatedQuantity,
    double retentionPercentage = 5.0,
    WorkOrderStatus status = WorkOrderStatus.active,
    required DateTime startDate,
    DateTime? targetDate,
    String? scopeOfWork,
  }) {
    final contractAmount = agreedRate * estimatedQuantity;
    return _subcontractDao.insertWorkOrder(
      WorkOrdersCompanion.insert(
        orderNumber: orderNumber.trim(),
        projectId: projectId,
        subcontractorId: subcontractorId,
        title: title.trim(),
        trade: trade.trim(),
        unit: unit.trim(),
        agreedRate: agreedRate,
        estimatedQuantity: estimatedQuantity,
        contractAmount: contractAmount,
        retentionPercentage: Value(retentionPercentage),
        status: Value(status),
        startDate: startDate,
        targetDate: Value(targetDate),
        scopeOfWork: Value(scopeOfWork?.trim()),
      ),
    );
  }

  Future<bool> updateWorkOrder({
    required int id,
    required String orderNumber,
    required int projectId,
    required int subcontractorId,
    required String title,
    required String trade,
    required String unit,
    required double agreedRate,
    required double estimatedQuantity,
    double retentionPercentage = 5.0,
    WorkOrderStatus status = WorkOrderStatus.active,
    required DateTime startDate,
    DateTime? targetDate,
    String? scopeOfWork,
  }) {
    final contractAmount = agreedRate * estimatedQuantity;
    return _subcontractDao.updateWorkOrder(
      WorkOrdersCompanion(
        id: Value(id),
        orderNumber: Value(orderNumber.trim()),
        projectId: Value(projectId),
        subcontractorId: Value(subcontractorId),
        title: Value(title.trim()),
        trade: Value(trade.trim()),
        unit: Value(unit.trim()),
        agreedRate: Value(agreedRate),
        estimatedQuantity: Value(estimatedQuantity),
        contractAmount: Value(contractAmount),
        retentionPercentage: Value(retentionPercentage),
        status: Value(status),
        startDate: Value(startDate),
        targetDate: Value(targetDate),
        scopeOfWork: Value(scopeOfWork?.trim()),
      ),
    );
  }

  Future<int> deleteWorkOrder(int id) => _subcontractDao.deleteWorkOrder(id);

  // ─── Measurement Bills (RA Bills) ───────────────────────────────────────────

  Stream<List<MeasurementBillDetail>> watchMeasurementBills({
    int? workOrderId,
    int? projectId,
  }) =>
      _subcontractDao.watchMeasurementBills(
        workOrderId: workOrderId,
        projectId: projectId,
      );

  /// Record a certified measurement bill:
  /// - Posts `Transaction(type: subcontractBill, affectsPnl: true, affectsCash: false)`
  /// - Records MeasurementBill with retention deduction
  /// - Project P&L recognizes the cost; Cash is untouched.
  Future<int> recordMeasurementBill({
    required int workOrderId,
    required String billNumber,
    required DateTime date,
    required double measuredQuantity,
    required double unitRate,
    double retentionPercentage = 5.0,
    String? locationOrDescription,
  }) async {
    final woDetail = await _subcontractDao.getWorkOrderDetailById(workOrderId);
    if (woDetail == null) {
      throw StateError('Work order $workOrderId not found');
    }

    final grossAmount = measuredQuantity * unitRate;
    final retentionAmount = grossAmount * (retentionPercentage / 100.0);
    final netAmount = grossAmount - retentionAmount;

    return _db.transaction(() async {
      final txnId = await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: woDetail.project.id,
          date: date,
          type: TransactionType.subcontractBill,
          affectsPnl: const Value(true), // Cost hits project P&L immediately
          affectsCash: const Value(false), // No physical cash out at measurement certification
          amount: grossAmount,
          narration: Value(
            'RA Bill $billNumber: ${woDetail.workOrder.title} (${woDetail.subcontractor.name}) - $measuredQuantity ${woDetail.workOrder.unit}',
          ),
          referenceNo: Value(billNumber),
        ),
      );

      return _db.into(_db.measurementBills).insert(
            MeasurementBillsCompanion.insert(
              transactionId: txnId,
              workOrderId: workOrderId,
              billNumber: billNumber.trim(),
              date: date,
              measuredQuantity: measuredQuantity,
              unitRate: unitRate,
              grossAmount: grossAmount,
              retentionPercentage: Value(retentionPercentage),
              retentionAmount: retentionAmount,
              netAmount: netAmount,
              locationOrDescription: Value(locationOrDescription?.trim()),
            ),
          );
    });
  }

  // ─── Subcontract Payments & Advances ────────────────────────────────────────

  Stream<List<SubcontractPaymentDetail>> watchSubcontractPayments({
    int? subcontractorId,
    int? workOrderId,
    int? projectId,
  }) =>
      _subcontractDao.watchSubcontractPayments(
        subcontractorId: subcontractorId,
        workOrderId: workOrderId,
        projectId: projectId,
      );

  /// Record a payment or advance to a subcontractor:
  /// - Posts `Transaction(type: subcontractPayment, affectsPnl: false, affectsCash: true)`
  /// - Cash decreases; P&L is NOT hit again (already booked by measurement bills).
  Future<int> recordSubcontractPayment({
    required int subcontractorId,
    int? workOrderId,
    required int projectId,
    required double amount,
    required DateTime paymentDate,
    required PaymentMode paymentMode,
    int? bankAccountId,
    bool isRetentionRelease = false,
    bool isAdvance = false,
    String? referenceNo,
    String? notes,
  }) async {
    final sub = await _subcontractDao.getSubcontractorById(subcontractorId);
    final subName = sub?.name ?? 'Subcontractor';

    return _db.transaction(() async {
      final txnId = await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: paymentDate,
          type: TransactionType.subcontractPayment,
          affectsPnl: const Value(false), // P&L already recognized by measurement bills
          affectsCash: const Value(true), // moves cash out
          amount: amount,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(
            isRetentionRelease
                ? 'Retention Release to $subName'
                : (isAdvance ? 'Advance to $subName' : 'Payment to $subName'),
          ),
          referenceNo: Value(referenceNo?.trim()),
        ),
      );

      return _db.into(_db.subcontractPayments).insert(
            SubcontractPaymentsCompanion.insert(
              transactionId: txnId,
              subcontractorId: subcontractorId,
              workOrderId: Value(workOrderId),
              amount: amount,
              paymentDate: paymentDate,
              paymentMode: paymentMode,
              bankAccountId: Value(bankAccountId),
              isRetentionRelease: Value(isRetentionRelease),
              isAdvance: Value(isAdvance),
              referenceNo: Value(referenceNo?.trim()),
              notes: Value(notes?.trim()),
            ),
          );
    });
  }
}
