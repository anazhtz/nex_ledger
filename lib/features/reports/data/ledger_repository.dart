import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/reports/models/ledger_models.dart';

class LedgerRepository {
  final AppDatabase _db;

  LedgerRepository(this._db);

  // ─── 1. VENDOR / SUPPLIER LEDGER ──────────────────────────────────────────

  Stream<({LedgerSummary summary, List<LedgerEntry> entries})> watchVendorLedger(
    int vendorId, {
    int? projectId,
    DateTimeRange? dateRange,
  }) {
    // Watch vendor purchases and general transactions reactively
    return _db.purchaseDao.watchPurchasesByVendor(vendorId).asyncMap((purchases) async {
      final vendor = await _db.purchaseDao.getVendorById(vendorId);
      final vendorName = vendor?.name ?? 'Supplier #$vendorId';
      final vendorSubtitle = vendor?.contact != null ? 'Contact: ${vendor!.contact}' : null;

      // Filter by project if requested
      var filteredPurchases = purchases;
      if (projectId != null) {
        filteredPurchases = purchases.where((p) => p.project.id == projectId).toList();
      }

      // Collect raw events: (date, isCredit, amount, ref, title, subtitle, projectCode, projectName, notes)
      final rawEvents = <_RawLedgerEvent>[];

      for (final p in filteredPurchases) {
        final totalBill = p.purchase.quantity * p.purchase.unitRate > 0
            ? p.purchase.quantity * p.purchase.unitRate
            : p.transaction.amount;

        // 1. Credit entry: Purchase Bill / Material Invoice received (Payable increases)
        rawEvents.add(_RawLedgerEvent(
          id: p.transaction.id,
          date: p.transaction.date,
          referenceNo: p.transaction.referenceNo ?? 'PUR-${p.purchase.id.toString().padLeft(4, '0')}',
          title: p.purchase.itemDescription,
          subtitle: 'Qty: ${p.purchase.quantity} ${p.purchase.unit ?? 'units'} @ ${CurrencyFormatter.format(p.purchase.unitRate)}',
          projectCode: p.project.code,
          projectName: p.project.name,
          debit: 0.0,
          credit: totalBill,
          transactionType: TransactionType.purchase,
          paymentMode: p.transaction.paymentMode,
          notes: p.transaction.narration,
        ));

        // 2. Debit entry: Immediate paid portion at bill creation (Payable decreases)
        if (p.purchase.paidAmount > 0) {
          rawEvents.add(_RawLedgerEvent(
            id: p.transaction.id,
            date: p.transaction.date,
            referenceNo: p.transaction.referenceNo,
            title: 'Payment — ${p.transaction.paymentMode?.displayName ?? 'Paid'}',
            subtitle: 'Against Purchase #${p.purchase.id}',
            projectCode: p.project.code,
            projectName: p.project.name,
            debit: p.purchase.paidAmount,
            credit: 0.0,
            transactionType: TransactionType.purchasePayment,
            paymentMode: p.transaction.paymentMode,
            notes: 'Settled at time of purchase entry',
          ));
        }
      }

      // Also find any standalone purchasePayment transactions linked to this vendor's purchases
      final allTxns = await _db.transactionDao.watchAllRawTransactions().first;
      final standalonePayments = allTxns.where((t) {
        if (t.type != TransactionType.purchasePayment) return false;
        if (projectId != null && t.projectId != projectId) return false;
        // Check if narration references this vendor or purchase
        return t.narration?.contains(vendorName) == true ||
            t.referenceNo?.contains(vendorName) == true;
      }).toList();

      for (final pay in standalonePayments) {
        final proj = await _db.projectDao.getProjectById(pay.projectId);
        rawEvents.add(_RawLedgerEvent(
          id: pay.id,
          date: pay.date,
          referenceNo: pay.referenceNo,
          title: 'Direct Vendor Settlement',
          subtitle: pay.narration ?? 'Payment issued',
          projectCode: proj?.code,
          projectName: proj?.name,
          debit: pay.amount,
          credit: 0.0,
          transactionType: TransactionType.purchasePayment,
          paymentMode: pay.paymentMode,
          notes: pay.narration,
        ));
      }

      // Sort chronologically (Oldest first for running balance)
      rawEvents.sort((a, b) => a.date.compareTo(b.date));

      // Calculate running balance and date filtering
      double runningBal = 0.0;
      double totalBilled = 0.0;
      double totalPaid = 0.0;
      final statementEntries = <LedgerEntry>[];

      for (final event in rawEvents) {
        runningBal += (event.credit - event.debit);

        final inDateRange = dateRange == null ||
            (event.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
                event.date.isBefore(dateRange.end.add(const Duration(days: 1))));

        if (inDateRange) {
          totalBilled += event.credit;
          totalPaid += event.debit;

          statementEntries.add(LedgerEntry(
            id: event.id,
            date: event.date,
            referenceNo: event.referenceNo,
            title: event.title,
            subtitle: event.subtitle,
            projectCode: event.projectCode,
            projectName: event.projectName,
            debit: event.debit,
            credit: event.credit,
            runningBalance: runningBal,
            balanceType: runningBal >= 0 ? 'Cr (Due)' : 'Dr (Advance)',
            transactionType: event.transactionType,
            paymentMode: event.paymentMode,
            notes: event.notes,
          ));
        }
      }

      final summary = LedgerSummary(
        openingBalance: 0.0,
        totalDebit: totalPaid,
        totalCredit: totalBilled,
        closingBalance: runningBal,
        totalEntries: statementEntries.length,
        entityName: vendorName,
        entitySubtitle: vendorSubtitle,
        debitLabel: 'Total Payments Made',
        creditLabel: 'Total Purchases Billed',
        balanceLabel: runningBal >= 0 ? 'Net Outstanding Payable' : 'Net Advance Paid',
        isPayable: true,
      );

      // Return newest first for screen presentation
      return (summary: summary, entries: statementEntries.reversed.toList());
    });
  }

  // ─── 2. LABOUR / WORKER LEDGER ────────────────────────────────────────────

  Stream<({LedgerSummary summary, List<LedgerEntry> entries})> watchWorkerLedger(
    int workerId, {
    int? projectId,
    DateTimeRange? dateRange,
  }) {
    return _db.labourDao.watchWorkerAttendanceAll(workerId).asyncMap((attendanceList) async {
      final worker = await _db.labourDao.getWorkerById(workerId);
      final workerName = worker?.name ?? 'Worker #$workerId';
      final workerSubtitle = worker != null
          ? '${worker.trade ?? 'General'} • Code: ${worker.workerCode ?? '—'} • Daily Rate: ${CurrencyFormatter.format(worker.dailyRate)}'
          : null;

      final payments = await _db.labourDao.watchWorkerPayments(workerId).first;

      // Filter by project if requested
      var filteredAtt = attendanceList;
      var filteredPay = payments;
      if (projectId != null) {
        filteredAtt = attendanceList.where((a) => a.attendance.projectId == projectId).toList();
        filteredPay = payments.where((p) => p.projectId == projectId).toList();
      }

      final rawEvents = <_RawLedgerEvent>[];

      // 1. Credit entries from daily attendance (Gross wages earned)
      for (final att in filteredAtt) {
        final days = att.attendance.status.payFraction;
        if (days <= 0) continue; // Skip absent days

        final dailyRate = worker?.dailyRate ?? 0.0;
        final wageEarned = days * dailyRate;
        final proj = await _db.projectDao.getProjectById(att.attendance.projectId);

        rawEvents.add(_RawLedgerEvent(
          id: att.attendance.id,
          date: att.attendance.date,
          referenceNo: 'ATT-${att.attendance.id}',
          title: '${att.attendance.status.displayName} (${days}d)',
          subtitle: 'Daily Wage Rate: ${CurrencyFormatter.format(dailyRate)}',
          projectCode: proj?.code,
          projectName: proj?.name,
          debit: 0.0,
          credit: wageEarned,
          transactionType: null,
          paymentMode: null,
          notes: 'Attendance recorded on site',
        ));
      }

      // 2. Debit entries from labour payments (Wages paid out)
      for (final pay in filteredPay) {
        final proj = await _db.projectDao.getProjectById(pay.projectId);
        rawEvents.add(_RawLedgerEvent(
          id: pay.id,
          date: pay.date,
          referenceNo: pay.referenceNo ?? 'PAY-${pay.id}',
          title: 'Labour Wage Payment',
          subtitle: pay.narration ?? 'Wage disbursement',
          projectCode: proj?.code,
          projectName: proj?.name,
          debit: pay.amount,
          credit: 0.0,
          transactionType: TransactionType.labourPayment,
          paymentMode: pay.paymentMode,
          notes: pay.narration,
        ));
      }

      // Sort chronologically (Oldest first)
      rawEvents.sort((a, b) => a.date.compareTo(b.date));

      double runningBal = 0.0;
      double totalEarned = 0.0;
      double totalPaid = 0.0;
      final statementEntries = <LedgerEntry>[];

      for (final event in rawEvents) {
        runningBal += (event.credit - event.debit);

        final inDateRange = dateRange == null ||
            (event.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
                event.date.isBefore(dateRange.end.add(const Duration(days: 1))));

        if (inDateRange) {
          totalEarned += event.credit;
          totalPaid += event.debit;

          statementEntries.add(LedgerEntry(
            id: event.id,
            date: event.date,
            referenceNo: event.referenceNo,
            title: event.title,
            subtitle: event.subtitle,
            projectCode: event.projectCode,
            projectName: event.projectName,
            debit: event.debit,
            credit: event.credit,
            runningBalance: runningBal,
            balanceType: runningBal >= 0 ? 'Cr (Due)' : 'Dr (Advance)',
            transactionType: event.transactionType,
            paymentMode: event.paymentMode,
            notes: event.notes,
          ));
        }
      }

      final summary = LedgerSummary(
        openingBalance: 0.0,
        totalDebit: totalPaid,
        totalCredit: totalEarned,
        closingBalance: runningBal,
        totalEntries: statementEntries.length,
        entityName: workerName,
        entitySubtitle: workerSubtitle,
        debitLabel: 'Total Payments Paid',
        creditLabel: 'Total Wages Earned',
        balanceLabel: runningBal >= 0 ? 'Net Wage Due to Worker' : 'Net Advance Overpaid',
        isPayable: true,
      );

      return (summary: summary, entries: statementEntries.reversed.toList());
    });
  }

  // ─── 3. BANK & CASH ACCOUNT LEDGER ────────────────────────────────────────

  Stream<({LedgerSummary summary, List<LedgerEntry> entries})> watchAccountLedger({
    int? bankAccountId,
    DateTimeRange? dateRange,
  }) {
    return _db.bankAccountDao.watchAccountsWithBalances().asyncMap((_) async {
      BankAccount? targetAccount;
      if (bankAccountId != null) {
        targetAccount = await _db.bankAccountDao.getAccountById(bankAccountId);
      }

      final bool isCashInHand = bankAccountId == null || (targetAccount?.isCashAccount ?? false);
      final accountName = targetAccount != null
          ? targetAccount.accountName
          : '💵 Physical Cash Drawer / Cash in Hand';
      final accountSubtitle = targetAccount?.accountNumber != null
          ? 'A/c: ${targetAccount!.accountNumber} • ${targetAccount.bankName ?? ''} • IFSC: ${targetAccount.ifscCode ?? '—'}'
          : (isCashInHand ? 'Physical Cash in Hand & Petty Cash Drawer' : null);

      final openingBal = targetAccount?.openingBalance ?? 0.0;

      // Fetch all transactions that affect cash
      final allTxns = await (_db.select(_db.transactions)
            ..where((t) => t.affectsCash.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

      final rawEvents = <_RawLedgerEvent>[];

      for (final t in allTxns) {
        final matchesThisAccount = targetAccount != null
            ? (t.bankAccountId == targetAccount.id ||
                (targetAccount.isCashAccount &&
                    t.bankAccountId == null &&
                    (t.paymentMode == PaymentMode.cash || t.paymentMode == null)) ||
                (!targetAccount.isCashAccount &&
                    targetAccount.isDefault &&
                    t.bankAccountId == null &&
                    t.paymentMode != PaymentMode.cash &&
                    t.paymentMode != null))
            : (t.bankAccountId == null && (t.paymentMode == PaymentMode.cash || t.paymentMode == null));

        if (!matchesThisAccount) continue;

        final proj = await _db.projectDao.getProjectById(t.projectId);
        final isOutflow = t.type.isDebit;

        rawEvents.add(_RawLedgerEvent(
          id: t.id,
          date: t.date,
          referenceNo: t.referenceNo ?? 'TXN-${t.id}',
          title: t.narration?.isNotEmpty == true ? t.narration! : t.type.displayName,
          subtitle: 'Type: ${t.type.displayName} • Mode: ${t.paymentMode?.displayName ?? 'Cash'}',
          projectCode: proj?.code,
          projectName: proj?.name,
          debit: isOutflow ? t.amount : 0.0,
          credit: isOutflow ? 0.0 : t.amount,
          transactionType: t.type,
          paymentMode: t.paymentMode,
          notes: t.narration,
        ));
      }

      double runningBal = openingBal;
      double totalInflow = 0.0;
      double totalOutflow = 0.0;
      final statementEntries = <LedgerEntry>[];

      for (final event in rawEvents) {
        runningBal += (event.credit - event.debit);

        final inDateRange = dateRange == null ||
            (event.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
                event.date.isBefore(dateRange.end.add(const Duration(days: 1))));

        if (inDateRange) {
          totalInflow += event.credit;
          totalOutflow += event.debit;

          statementEntries.add(LedgerEntry(
            id: event.id,
            date: event.date,
            referenceNo: event.referenceNo,
            title: event.title,
            subtitle: event.subtitle,
            projectCode: event.projectCode,
            projectName: event.projectName,
            debit: event.debit,
            credit: event.credit,
            runningBalance: runningBal,
            balanceType: runningBal >= 0 ? 'Dr (Cleared)' : 'Cr (Overdrawn)',
            transactionType: event.transactionType,
            paymentMode: event.paymentMode,
            notes: event.notes,
          ));
        }
      }

      final summary = LedgerSummary(
        openingBalance: openingBal,
        totalDebit: totalOutflow,
        totalCredit: totalInflow,
        closingBalance: runningBal,
        totalEntries: statementEntries.length,
        entityName: accountName,
        entitySubtitle: accountSubtitle,
        debitLabel: 'Total Outflows (Debits)',
        creditLabel: 'Total Inflows (Credits)',
        balanceLabel: 'Live Account Balance',
        isPayable: false,
      );

      return (summary: summary, entries: statementEntries.reversed.toList());
    });
  }

  // ─── 4. PERSONAL / OWNER LEDGER ───────────────────────────────────────────

  Stream<({LedgerSummary summary, List<LedgerEntry> entries})> watchPersonalLedger({
    DateTimeRange? dateRange,
  }) {
    return _db.transactionDao.watchAllTransactions().asyncMap((_) async {
      final capitalTxns = await (_db.select(_db.transactions)
            ..where((t) => t.type.isIn([
                  TransactionType.ownerCapital.name,
                  TransactionType.drawings.name,
                ]))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

      final rawEvents = <_RawLedgerEvent>[];

      for (final t in capitalTxns) {
        final proj = await _db.projectDao.getProjectById(t.projectId);
        final isDrawings = t.type == TransactionType.drawings;

        BankAccount? acc;
        if (t.bankAccountId != null) {
          acc = await _db.bankAccountDao.getAccountById(t.bankAccountId!);
        }

        rawEvents.add(_RawLedgerEvent(
          id: t.id,
          date: t.date,
          referenceNo: t.referenceNo ?? 'CAP-${t.id}',
          title: isDrawings ? 'Owner Personal Drawings' : 'Owner Capital Introduced',
          subtitle: t.narration?.isNotEmpty == true
              ? t.narration!
              : (isDrawings ? 'Personal withdrawal from business funds' : 'Personal funds injected into business'),
          projectCode: proj?.code,
          projectName: proj?.name,
          debit: isDrawings ? t.amount : 0.0,
          credit: isDrawings ? 0.0 : t.amount,
          transactionType: t.type,
          paymentMode: t.paymentMode,
          accountName: acc?.accountName ?? 'Cash in Hand',
          notes: t.narration,
        ));
      }

      double runningEquity = 0.0;
      double totalCapitalInjected = 0.0;
      double totalDrawings = 0.0;
      final statementEntries = <LedgerEntry>[];

      for (final event in rawEvents) {
        runningEquity += (event.credit - event.debit);

        final inDateRange = dateRange == null ||
            (event.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
                event.date.isBefore(dateRange.end.add(const Duration(days: 1))));

        if (inDateRange) {
          if (event.transactionType == TransactionType.ownerCapital) {
            totalCapitalInjected += event.credit;
          } else {
            totalDrawings += event.debit;
          }

          statementEntries.add(LedgerEntry(
            id: event.id,
            date: event.date,
            referenceNo: event.referenceNo,
            title: event.title,
            subtitle: event.subtitle,
            projectCode: event.projectCode,
            projectName: event.projectName,
            debit: event.debit,
            credit: event.credit,
            runningBalance: runningEquity,
            balanceType: runningEquity >= 0 ? 'Cr (Net Invested)' : 'Dr (Net Withdrawn)',
            transactionType: event.transactionType,
            paymentMode: event.paymentMode,
            accountName: event.accountName,
            notes: event.notes,
          ));
        }
      }

      final summary = LedgerSummary(
        openingBalance: 0.0,
        totalDebit: totalDrawings,
        totalCredit: totalCapitalInjected,
        closingBalance: runningEquity,
        totalEntries: statementEntries.length,
        entityName: '👤 Owner Capital & Personal Drawings Ledger',
        entitySubtitle: 'Track proprietor investments, capital introduced, and personal drawings from business funds',
        debitLabel: 'Total Personal Drawings (Outflow)',
        creditLabel: 'Total Capital Injected (Inflow)',
        balanceLabel: runningEquity >= 0 ? 'Net Owner Capital in Business' : 'Net Overdrawn by Owner',
        isPayable: false,
      );

      return (summary: summary, entries: statementEntries.reversed.toList());
    });
  }

  // ─── 5. SUBCONTRACTOR / PIECE-RATE LEDGER ─────────────────────────────────

  Stream<({LedgerSummary summary, List<LedgerEntry> entries})> watchSubcontractorLedger(
    int subcontractorId, {
    int? projectId,
    DateTimeRange? dateRange,
  }) {
    return _db.subcontractDao.watchAllSubcontractors().asyncMap((subs) async {
      final sub = await _db.subcontractDao.getSubcontractorById(subcontractorId);
      final subName = sub?.name ?? 'Contractor #$subcontractorId';
      final subSubtitle = sub?.trade != null ? 'Trade: ${sub!.trade}' : null;

      final wos = await (_db.select(_db.workOrders)
            ..where((w) => w.subcontractorId.equals(subcontractorId)))
          .get();

      final woMap = {for (final w in wos) w.id: w};
      final woIds = wos.map((w) => w.id).toList();

      final rawEvents = <_RawLedgerEvent>[];

      // 1. Measurement Bills (Credit - contractor earns billable amount)
      if (woIds.isNotEmpty) {
        final bills = await (_db.select(_db.measurementBills)
              ..where((b) => b.workOrderId.isIn(woIds)))
            .get();

        for (final b in bills) {
          final wo = woMap[b.workOrderId];
          final prj = wo != null ? await _db.projectDao.getProjectById(wo.projectId) : null;

          if (projectId != null && wo?.projectId != projectId) continue;

          rawEvents.add(_RawLedgerEvent(
            id: b.transactionId,
            date: b.date,
            referenceNo: b.billNumber,
            title: 'RA Bill: ${wo?.title ?? 'Subcontract Work'}',
            subtitle: 'Measured: ${b.measuredQuantity} ${wo?.unit ?? ''} (Retention: ${CurrencyFormatter.format(b.retentionAmount)})',
            projectCode: prj?.code,
            projectName: prj?.name,
            debit: 0.0,
            credit: b.netAmount, // Net billable credited to contractor
            transactionType: TransactionType.subcontractBill,
            notes: b.locationOrDescription,
          ));
        }
      }

      // 2. Payments & Advances (Debit - developer pays contractor)
      final payments = await (_db.select(_db.subcontractPayments)
            ..where((p) => p.subcontractorId.equals(subcontractorId)))
          .get();

      for (final p in payments) {
        final wo = p.workOrderId != null ? woMap[p.workOrderId] : null;
        final prj = wo != null ? await _db.projectDao.getProjectById(wo.projectId) : null;

        if (projectId != null && wo != null && wo.projectId != projectId) continue;

        rawEvents.add(_RawLedgerEvent(
          id: p.transactionId,
          date: p.paymentDate,
          referenceNo: p.referenceNo ?? 'PAY-${p.id.toString().padLeft(4, '0')}',
          title: p.isRetentionRelease
              ? 'Retention Release'
              : (p.isAdvance ? 'Site Advance' : 'Bill Settlement'),
          subtitle: wo?.title,
          projectCode: prj?.code,
          projectName: prj?.name,
          debit: p.amount, // Debit reduces payable to contractor
          credit: 0.0,
          transactionType: TransactionType.subcontractPayment,
          paymentMode: p.paymentMode,
          notes: p.notes,
        ));
      }

      // Sort chronologically (oldest first for running balance)
      rawEvents.sort((a, b) {
        final cmp = a.date.compareTo(b.date);
        return cmp != 0 ? cmp : a.id.compareTo(b.id);
      });

      double runningBalance = 0.0;
      double openingBalance = 0.0;
      double periodDebits = 0.0;
      double periodCredits = 0.0;

      final statementEntries = <LedgerEntry>[];

      for (final ev in rawEvents) {
        final beforeDate = dateRange != null && ev.date.isBefore(dateRange.start);
        final inRange = dateRange == null ||
            (ev.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
                ev.date.isBefore(dateRange.end.add(const Duration(days: 1))));

        if (beforeDate) {
          openingBalance += (ev.credit - ev.debit);
          runningBalance = openingBalance;
        } else if (inRange) {
          runningBalance += (ev.credit - ev.debit);
          periodDebits += ev.debit;
          periodCredits += ev.credit;

          statementEntries.add(LedgerEntry(
            id: ev.id,
            date: ev.date,
            referenceNo: ev.referenceNo,
            title: ev.title,
            subtitle: ev.subtitle,
            projectCode: ev.projectCode,
            projectName: ev.projectName,
            debit: ev.debit,
            credit: ev.credit,
            runningBalance: runningBalance,
            balanceType: runningBalance >= 0 ? 'Cr (Due)' : 'Dr (Advance)',
            transactionType: ev.transactionType,
            paymentMode: ev.paymentMode,
            accountName: ev.accountName,
            notes: ev.notes,
          ));
        }
      }

      final summary = LedgerSummary(
        openingBalance: openingBalance,
        totalDebit: periodDebits,
        totalCredit: periodCredits,
        closingBalance: runningBalance,
        totalEntries: statementEntries.length,
        entityName: subName,
        entitySubtitle: subSubtitle,
        debitLabel: 'Total Payments & Advances',
        creditLabel: 'Total Certified Net Bills',
        balanceLabel: runningBalance >= 0 ? 'Net Balance Due to Contractor' : 'Net Advance Overpaid',
        isPayable: true,
      );

      return (summary: summary, entries: statementEntries.reversed.toList());
    });
  }

  // ─── Quick Actions for Owner Transactions ─────────────────────────────────

  Future<int> recordOwnerCapital({
    required double amount,
    required DateTime date,
    int? bankAccountId,
    PaymentMode paymentMode = PaymentMode.bank,
    String? narration,
    String? referenceNo,
  }) async {
    final adminProject = await _db.projectDao.getAdminOverheadProject();
    final projId = adminProject?.id ?? 1;

    return _db.transactionDao.insertTransaction(
      TransactionsCompanion.insert(
        projectId: projId,
        date: date,
        type: TransactionType.ownerCapital,
        affectsPnl: const Value(false), // Capital is equity, not income
        affectsCash: const Value(true), // Inflow to bank or cash
        amount: amount,
        bankAccountId: Value(bankAccountId),
        paymentMode: Value(paymentMode),
        narration: Value(narration?.trim() ?? 'Owner capital introduced'),
        referenceNo: Value(referenceNo?.trim()),
      ),
    );
  }

  Future<int> recordOwnerDrawings({
    required double amount,
    required DateTime date,
    int? bankAccountId,
    PaymentMode paymentMode = PaymentMode.cash,
    String? narration,
    String? referenceNo,
  }) async {
    final adminProject = await _db.projectDao.getAdminOverheadProject();
    final projId = adminProject?.id ?? 1;

    return _db.transactionDao.insertTransaction(
      TransactionsCompanion.insert(
        projectId: projId,
        date: date,
        type: TransactionType.drawings,
        affectsPnl: const Value(false), // Drawings is equity withdrawal, not project expense
        affectsCash: const Value(true), // Outflow from bank or cash
        amount: amount,
        bankAccountId: Value(bankAccountId),
        paymentMode: Value(paymentMode),
        narration: Value(narration?.trim() ?? 'Owner personal withdrawal / drawings'),
        referenceNo: Value(referenceNo?.trim()),
      ),
    );
  }
}

class _RawLedgerEvent {
  final int id;
  final DateTime date;
  final String? referenceNo;
  final String title;
  final String? subtitle;
  final String? projectCode;
  final String? projectName;
  final double debit;
  final double credit;
  final TransactionType? transactionType;
  final PaymentMode? paymentMode;
  final String? accountName;
  final String? notes;

  _RawLedgerEvent({
    required this.id,
    required this.date,
    this.referenceNo,
    required this.title,
    this.subtitle,
    this.projectCode,
    this.projectName,
    required this.debit,
    required this.credit,
    this.transactionType,
    this.paymentMode,
    this.accountName,
    this.notes,
  });
}
