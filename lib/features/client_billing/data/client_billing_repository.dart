import 'package:drift/drift.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';

class ClientBillingRepository {
  final ClientBillingDao _billingDao;
  final TransactionDao _transactionDao;
  final ProjectDao _projectDao;
  final AppDatabase _db;

  ClientBillingRepository(
    this._billingDao,
    this._transactionDao,
    this._projectDao,
    this._db,
  );

  // ─── Revenue Summaries & Progress Streams ───────────────────────────────────

  Stream<List<ProjectRevenueProgress>> watchAllProjectRevenueSummaries() =>
      _billingDao.watchAllProjectRevenueSummaries();

  Stream<ProjectRevenueProgress?> watchProjectRevenueProgress(int projectId) =>
      _billingDao.watchProjectRevenueProgress(projectId);

  Stream<List<ClientRaBillDetail>> watchClientRaBills({int? projectId}) =>
      _billingDao.watchClientRaBills(projectId: projectId);

  Future<ClientRaBillDetail?> getClientRaBillById(int id) =>
      _billingDao.getClientRaBillById(id);

  Stream<List<ClientReceiptDetail>> watchClientReceipts({
    int? projectId,
    int? raBillId,
  }) =>
      _billingDao.watchClientReceipts(
        projectId: projectId,
        raBillId: raBillId,
      );

  // ─── Raise Client RA Bill ───────────────────────────────────────────────────

  /// Record a certified Client RA Bill:
  /// - Posts `Transaction(type: clientRaBill, affectsPnl: true, affectsCash: false)`
  /// - Gross revenue hits Project P&L immediately; No cash is moved.
  /// - Creates Client Account Receivable asset.
  Future<int> raiseClientRaBill({
    required int projectId,
    required String billNumber,
    required DateTime billDate,
    required String stageOrDescription,
    required double grossAmount,
    double retentionPercentage = 5.0,
    double advanceDeduction = 0.0,
    double taxOrTdsDeduction = 0.0,
    DateTime? dueDate,
    String? notes,
  }) async {
    final retentionAmount = grossAmount * (retentionPercentage / 100.0);
    final netCertifiedAmount =
        grossAmount - retentionAmount - advanceDeduction - taxOrTdsDeduction;

    final project = await _projectDao.getProjectById(projectId);
    final clientName = project?.clientName ?? project?.name ?? 'Client';

    return _db.transaction(() async {
      final txnId = await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: billDate,
          type: TransactionType.clientRaBill,
          affectsPnl: const Value(true), // Revenue hits Project P&L immediately
          affectsCash: const Value(false), // No physical cash movement until collection
          amount: grossAmount,
          narration: Value(
            'Client RA Bill $billNumber ($clientName): ${stageOrDescription.trim()}',
          ),
          referenceNo: Value(billNumber.trim()),
        ),
      );

      return _billingDao.insertClientRaBill(
        ClientRaBillsCompanion.insert(
          transactionId: txnId,
          projectId: projectId,
          billNumber: billNumber.trim(),
          billDate: billDate,
          stageOrDescription: stageOrDescription.trim(),
          grossAmount: grossAmount,
          retentionPercentage: Value(retentionPercentage),
          retentionAmount: Value(retentionAmount),
          advanceDeduction: Value(advanceDeduction),
          taxOrTdsDeduction: Value(taxOrTdsDeduction),
          netCertifiedAmount: netCertifiedAmount,
          dueDate: Value(dueDate),
          notes: Value(notes?.trim()),
        ),
      );
    });
  }

  Future<int> deleteClientRaBill(int id) => _billingDao.deleteClientRaBill(id);

  // ─── Record Client Receipt / Collection ─────────────────────────────────────

  /// Record an incoming payment from the client:
  /// - Posts `Transaction(type: clientReceipt, affectsPnl: false, affectsCash: true)`
  /// - Cash / Bank increases; P&L is NOT hit again (already recognized by RA bills).
  /// - Clears Client Account Receivable.
  Future<int> recordClientReceipt({
    required int projectId,
    int? clientRaBillId,
    required DateTime receiptDate,
    required double amount,
    required PaymentMode paymentMode,
    int? bankAccountId,
    bool isAdvance = false,
    bool isRetentionRelease = false,
    String? referenceNo,
    String? notes,
  }) async {
    final project = await _projectDao.getProjectById(projectId);
    final clientName = project?.clientName ?? project?.name ?? 'Client';

    return _db.transaction(() async {
      final txnId = await _transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          projectId: projectId,
          date: receiptDate,
          type: TransactionType.clientReceipt,
          affectsPnl: const Value(false), // P&L already recognized by RA bills
          affectsCash: const Value(true), // Physical money received into bank/drawer
          amount: amount,
          paymentMode: Value(paymentMode),
          bankAccountId: Value(bankAccountId),
          narration: Value(
            isRetentionRelease
                ? 'Client Retention Released from $clientName'
                : (isAdvance
                    ? 'Mobilization Advance from $clientName'
                    : 'Client Receipt from $clientName'),
          ),
          referenceNo: Value(referenceNo?.trim()),
        ),
      );

      return _billingDao.insertClientReceipt(
        ClientReceiptsCompanion.insert(
          transactionId: txnId,
          projectId: projectId,
          clientRaBillId: Value(clientRaBillId),
          receiptDate: receiptDate,
          amount: amount,
          paymentMode: paymentMode,
          bankAccountId: Value(bankAccountId),
          isAdvance: Value(isAdvance),
          isRetentionRelease: Value(isRetentionRelease),
          referenceNo: Value(referenceNo?.trim()),
          notes: Value(notes?.trim()),
        ),
      );
    });
  }

  Future<int> deleteClientReceipt(int id) => _billingDao.deleteClientReceipt(id);

  // ─── Update Project Client Contract Master ──────────────────────────────────

  Future<bool> updateProjectClientContract({
    required int projectId,
    required String clientName,
    required double clientContractValue,
    double clientRetentionPercentage = 5.0,
    String? clientContact,
    String? clientAddress,
    String? clientGstOrPan,
  }) async {
    final project = await _projectDao.getProjectById(projectId);
    if (project == null) return false;

    return _projectDao.updateProject(
      ProjectsCompanion(
        id: Value(projectId),
        code: Value(project.code),
        name: Value(project.name),
        type: Value(project.type),
        status: Value(project.status),
        startDate: Value(project.startDate),
        budget: Value(project.budget),
        clientName: Value(clientName.trim()),
        clientContractValue: Value(clientContractValue),
        clientRetentionPercentage: Value(clientRetentionPercentage),
        clientContact: Value(clientContact?.trim()),
        clientAddress: Value(clientAddress?.trim()),
        clientGstOrPan: Value(clientGstOrPan?.trim()),
      ),
    );
  }
}
