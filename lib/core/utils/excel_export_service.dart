import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/database/daos/deposit_dao.dart';
import 'package:nex_ledger/core/database/daos/labour_dao.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';
import 'package:nex_ledger/features/reports/models/ledger_models.dart';
import 'package:nex_ledger/features/materials/models/project_material_entry.dart';

/// Senior CA-Grade Financial Excel Export Engine for NexLedger.
/// Generates audit-ready .xlsx workbooks for P&L, Cash Book, Deposits, Labour, and Ledgers.
class ExcelExportService {
  ExcelExportService._();

  /// Helper to save generated excel bytes to user chosen path or Downloads folder.
  static Future<String?> _saveExcelFile(
    Excel excel,
    String defaultFileName,
  ) async {
    final fileBytes = excel.save();
    if (fileBytes == null) return null;

    // Try prompt file picker
    String? selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Excel Report',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    // Fallback to Downloads folder if picker dismissed or restricted
    if (selectedPath == null) {
      String? targetDir;
      if (Platform.isMacOS) {
        final home = Platform.environment['HOME'] ?? '';
        final realHome = home.split('/Library/Containers').first;
        final userDownloads = p.join(realHome, 'Downloads');
        if (Directory(userDownloads).existsSync()) {
          targetDir = userDownloads;
        }
      }
      targetDir ??= (await getDownloadsDirectory())?.path;
      targetDir ??= (await getApplicationSupportDirectory()).path;
      selectedPath = p.join(targetDir, defaultFileName);
    }

    final file = File(selectedPath);
    await file.writeAsBytes(fileBytes);
    return selectedPath;
  }

  /// 1. Export Project P&L or Consolidated P&L Report to Excel
  static Future<String?> exportPnlReport({
    required List<ProjectPnl> projectPnls,
    String? singleProjectTitle,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['P&L Statement'];
    excel.delete('Sheet1'); // Remove default sheet

    // Styles & Headers
    final titleHeader = [
      TextCellValue('NEXLEDGER FINANCIAL REPORT — P&L STATEMENT'),
    ];
    sheet.appendRow(titleHeader);

    if (singleProjectTitle != null) {
      sheet.appendRow([TextCellValue('Project: $singleProjectTitle')]);
    }
    sheet.appendRow([
      TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}'),
    ]);
    sheet.appendRow([TextCellValue('')]); // Spacer

    // Column Headers
    final headers = [
      TextCellValue('Project Code'),
      TextCellValue('Project Name'),
      TextCellValue('Client / Customer'),
      TextCellValue('Recognized Income (₹)'),
      TextCellValue('Material Purchases (₹)'),
      TextCellValue('Labour Payments (₹)'),
      TextCellValue('Other Expenses (₹)'),
      TextCellValue('Total Project Costs (₹)'),
      TextCellValue('Net P&L Profit/Loss (₹)'),
      TextCellValue('Deposit Liabilities Held (₹)'),
    ];
    sheet.appendRow(headers);

    double totalIncome = 0.0;
    double totalPurchases = 0.0;
    double totalLabour = 0.0;
    double totalExpenses = 0.0;
    double totalCostsSum = 0.0;
    double totalNetPnl = 0.0;
    double totalDepositsHeld = 0.0;

    for (final pnl in projectPnls) {
      final costs = pnl.expenses + pnl.purchases + pnl.labourCosts;
      totalIncome += pnl.income;
      totalPurchases += pnl.purchases;
      totalLabour += pnl.labourCosts;
      totalExpenses += pnl.expenses;
      totalCostsSum += costs;
      totalNetPnl += pnl.netPnl;
      totalDepositsHeld += pnl.depositsHeld;

      sheet.appendRow([
        TextCellValue(pnl.project.code),
        TextCellValue(pnl.project.name),
        TextCellValue(pnl.project.clientName ?? '—'),
        DoubleCellValue(pnl.income),
        DoubleCellValue(pnl.purchases),
        DoubleCellValue(pnl.labourCosts),
        DoubleCellValue(pnl.expenses),
        DoubleCellValue(costs),
        DoubleCellValue(pnl.netPnl),
        DoubleCellValue(pnl.depositsHeld),
      ]);
    }

    // Append Total Summary Row
    sheet.appendRow([TextCellValue('')]); // Spacer
    sheet.appendRow([
      TextCellValue('TOTAL COMPANY SUMMARY'),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(totalIncome),
      DoubleCellValue(totalPurchases),
      DoubleCellValue(totalLabour),
      DoubleCellValue(totalExpenses),
      DoubleCellValue(totalCostsSum),
      DoubleCellValue(totalNetPnl),
      DoubleCellValue(totalDepositsHeld),
    ]);

    final fileName = singleProjectTitle != null
        ? 'Project_PnL_${singleProjectTitle.replaceAll(RegExp(r'\s+'), '_')}.xlsx'
        : 'Consolidated_Company_PnL_${DateFormatter.format(DateTime.now()).replaceAll(' ', '_')}.xlsx';

    return _saveExcelFile(excel, fileName);
  }

  /// 2. Export Cash Book Transaction Ledger to Excel
  static Future<String?> exportCashBook({
    required List<TransactionWithProject> transactions,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Cash Book Ledger'];
    excel.delete('Sheet1');

    sheet.appendRow([TextCellValue('NEXLEDGER CASH BOOK TRANSACTIONS LEDGER')]);
    sheet.appendRow([TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]);

    sheet.appendRow([
      TextCellValue('Txn ID'),
      TextCellValue('Date'),
      TextCellValue('Project Code'),
      TextCellValue('Project Name'),
      TextCellValue('Type'),
      TextCellValue('Cash Inflow / Income (₹)'),
      TextCellValue('Cash Outflow / Expense (₹)'),
      TextCellValue('P&L Impact'),
      TextCellValue('Cash Impact'),
      TextCellValue('Payment Mode'),
      TextCellValue('Narration / Description'),
      TextCellValue('Reference / Ref No'),
    ]);

    double totalInflow = 0.0;
    double totalOutflow = 0.0;

    for (final item in transactions) {
      final t = item.transaction;
      final p = item.project;
      final isOutflow = t.type.name.contains('expense') ||
          t.type.name.contains('purchase') ||
          t.type.name.contains('labour') ||
          t.type.name.contains('Refund');

      final inflow = isOutflow ? 0.0 : t.amount;
      final outflow = isOutflow ? t.amount : 0.0;

      if (t.affectsCash) {
        totalInflow += inflow;
        totalOutflow += outflow;
      }

      sheet.appendRow([
        IntCellValue(t.id),
        TextCellValue(DateFormatter.format(t.date)),
        TextCellValue(p.code),
        TextCellValue(p.name),
        TextCellValue(t.type.name.toUpperCase()),
        DoubleCellValue(inflow),
        DoubleCellValue(outflow),
        TextCellValue(t.affectsPnl ? 'YES' : 'NO (Liability)'),
        TextCellValue(t.affectsCash ? 'YES' : 'NO (Paper Adj)'),
        TextCellValue(t.paymentMode?.name.toUpperCase() ?? '—'),
        TextCellValue(t.narration ?? '—'),
        TextCellValue(t.referenceNo ?? '—'),
      ]);
    }

    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('TOTALS'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(totalInflow),
      DoubleCellValue(totalOutflow),
      TextCellValue('Net Cash Flow:'),
      DoubleCellValue(totalInflow - totalOutflow),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
    ]);

    return _saveExcelFile(
      excel,
      'Cash_Book_Ledger_${DateFormatter.format(DateTime.now()).replaceAll(' ', '_')}.xlsx',
    );
  }

  /// 3. Export Security Deposits to Excel
  static Future<String?> exportDeposits({
    required List<DepositDetail> deposits,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Security Deposits'];
    excel.delete('Sheet1');

    sheet.appendRow([TextCellValue('NEXLEDGER SECURITY DEPOSITS LEDGER')]);
    sheet.appendRow([TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]);

    sheet.appendRow([
      TextCellValue('Deposit ID'),
      TextCellValue('Date'),
      TextCellValue('Deposit Type'),
      TextCellValue('Project Code'),
      TextCellValue('Project Name'),
      TextCellValue('Original Amount (₹)'),
      TextCellValue('Recovered / Adjusted Amount (₹)'),
      TextCellValue('Refunded Amount (₹)'),
      TextCellValue('Net Balance Held (₹)'),
      TextCellValue('Status'),
      TextCellValue('Reference'),
    ]);

    double totalOriginal = 0.0;
    double totalAdjusted = 0.0;
    double totalHeld = 0.0;

    for (final item in deposits) {
      final d = item.deposit;
      final t = item.transaction;
      final p = item.project;

      final originalAmount = t.amount;
      final adjustedAmount = d.adjustedAmount;
      final netHeld = d.status == DepositStatus.refunded
          ? 0.0
          : ((originalAmount - adjustedAmount) > 0 ? (originalAmount - adjustedAmount) : 0.0);

      totalOriginal += originalAmount;
      totalAdjusted += adjustedAmount;
      totalHeld += netHeld;

      sheet.appendRow([
        IntCellValue(d.id),
        TextCellValue(DateFormatter.format(t.date)),
        TextCellValue(d.depositType.displayName),
        TextCellValue(p.code),
        TextCellValue(p.name),
        DoubleCellValue(originalAmount),
        DoubleCellValue(adjustedAmount),
        DoubleCellValue(d.status == DepositStatus.refunded ? originalAmount : 0.0),
        DoubleCellValue(netHeld),
        TextCellValue(d.status.displayName),
        TextCellValue(d.adjustmentReference ?? t.referenceNo ?? '—'),
      ]);
    }

    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('TOTALS'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(totalOriginal),
      DoubleCellValue(totalAdjusted),
      TextCellValue(''),
      DoubleCellValue(totalHeld),
      TextCellValue(''),
      TextCellValue(''),
    ]);

    return _saveExcelFile(
      excel,
      'Security_Deposits_Ledger_${DateFormatter.format(DateTime.now()).replaceAll(' ', '_')}.xlsx',
    );
  }

  /// 4. Export Labour & Worker Running Wage Balance Ledger to Excel
  static Future<String?> exportLabourLedger({
    required List<WorkerPaymentSummary> summaries,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Labour Wage Ledger'];
    excel.delete('Sheet1');

    sheet.appendRow([TextCellValue('NEXLEDGER LABOUR & WORKER RUNNING WAGE LEDGER')]);
    sheet.appendRow([TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]);

    sheet.appendRow([
      TextCellValue('Worker Code'),
      TextCellValue('Worker Name'),
      TextCellValue('Trade / Skill Role'),
      TextCellValue('Daily Wage Rate (₹)'),
      TextCellValue('Total Days Worked (All-Time)'),
      TextCellValue('Gross Earned Wages (₹)'),
      TextCellValue('Total Payments Disbursed (₹)'),
      TextCellValue('Net Wage Liability Due (₹)'),
    ]);

    double totalEarned = 0.0;
    double totalPaid = 0.0;
    double totalDue = 0.0;

    for (final s in summaries) {
      totalEarned += s.totalEarnedWages;
      totalPaid += s.totalPaymentsPaid;
      totalDue += s.amountDue;

      sheet.appendRow([
        TextCellValue(s.worker.workerCode ?? '—'),
        TextCellValue(s.worker.name),
        TextCellValue(s.worker.trade ?? 'General Helper'),
        DoubleCellValue(s.worker.dailyRate),
        DoubleCellValue(s.totalDaysWorked),
        DoubleCellValue(s.totalEarnedWages),
        DoubleCellValue(s.totalPaymentsPaid),
        DoubleCellValue(s.amountDue),
      ]);
    }

    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('TOTALS'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(totalEarned),
      DoubleCellValue(totalPaid),
      DoubleCellValue(totalDue),
    ]);

    return _saveExcelFile(
      excel,
      'Labour_Wage_Ledger_${DateFormatter.format(DateTime.now()).replaceAll(' ', '_')}.xlsx',
    );
  }

  /// 5. Export General / Party Ledger Statement (Suppliers, Labour, Bank & Cash, Personal)
  static Future<String?> exportLedgerStatement({
    required String ledgerTitle,
    required LedgerSummary summary,
    required List<LedgerEntry> entries,
    DateTimeRange? dateRange,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Account Statement'];
    excel.delete('Sheet1');

    sheet.appendRow([TextCellValue('NEXLEDGER FINANCIAL ERP — ACCOUNT STATEMENT')]);
    sheet.appendRow([TextCellValue('Ledger: $ledgerTitle — ${summary.entityName}')]);
    if (summary.entitySubtitle != null) {
      sheet.appendRow([TextCellValue(summary.entitySubtitle!)]);
    }
    if (dateRange != null) {
      sheet.appendRow([
        TextCellValue(
            'Statement Period: ${DateFormatter.format(dateRange.start)} to ${DateFormatter.format(dateRange.end)}'),
      ]);
    } else {
      sheet.appendRow([TextCellValue('Statement Period: All-Time')]);
    }
    sheet.appendRow([TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]);

    // Summary KPIs Box
    sheet.appendRow([
      TextCellValue('SUMMARY'),
      TextCellValue('${summary.creditLabel}: ₹${summary.totalCredit.toStringAsFixed(2)}'),
      TextCellValue('${summary.debitLabel}: ₹${summary.totalDebit.toStringAsFixed(2)}'),
      TextCellValue('${summary.balanceLabel}: ₹${summary.closingBalance.toStringAsFixed(2)}'),
    ]);
    sheet.appendRow([TextCellValue('')]);

    // Statement Table Header
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Ref / Bill No'),
      TextCellValue('Description / Narration'),
      TextCellValue('Project'),
      TextCellValue('Debit (₹ Outflow)'),
      TextCellValue('Credit (₹ Inflow)'),
      TextCellValue('Running Balance (₹)'),
      TextCellValue('Balance Type'),
    ]);

    for (final e in entries.reversed) {
      sheet.appendRow([
        TextCellValue(DateFormatter.format(e.date)),
        TextCellValue(e.referenceNo ?? '—'),
        TextCellValue('${e.title}${e.subtitle != null ? ' (${e.subtitle})' : ''}'),
        TextCellValue(e.projectCode ?? '—'),
        DoubleCellValue(e.debit),
        DoubleCellValue(e.credit),
        DoubleCellValue(e.runningBalance),
        TextCellValue(e.balanceType),
      ]);
    }

    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('TOTALS'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(summary.totalDebit),
      DoubleCellValue(summary.totalCredit),
      DoubleCellValue(summary.closingBalance),
      TextCellValue(''),
    ]);

    final safeName = summary.entityName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return _saveExcelFile(
      excel,
      'Ledger_${safeName}_${DateFormatter.format(DateTime.now()).replaceAll(' ', '_')}.xlsx',
    );
  }

  /// 6. Export Project Material Quantity Statement & Delivery Log to Excel
  static Future<String?> exportMaterialQuantityStatement({
    required ProjectMaterialSummary summary,
    DateTimeRange? dateRange,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Material Consumption'];
    excel.delete('Sheet1');

    // Title & Info
    sheet.appendRow([TextCellValue('NEXLEDGER ERP — PROJECT MATERIAL QUANTITY REGISTER')]);
    sheet.appendRow([
      TextCellValue(
        'Project: ${summary.projectCode != null ? '${summary.projectCode} — ' : ''}${summary.projectName}${summary.clientName != null ? ' (Client: ${summary.clientName})' : ''}',
      ),
    ]);
    if (dateRange != null) {
      sheet.appendRow([
        TextCellValue(
          'Period: ${DateFormatter.format(dateRange.start)} to ${DateFormatter.format(dateRange.end)}',
        ),
      ]);
    } else {
      sheet.appendRow([TextCellValue('Period: All-Time Project Inward Deliveries')]);
    }
    sheet.appendRow([TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]);

    // KPI Summary Block
    sheet.appendRow([
      TextCellValue('SUMMARY METRICS'),
      TextCellValue('Total Material Spend: ₹${summary.totalMaterialSpend.toStringAsFixed(2)}'),
      TextCellValue('Total Delivery Consignments: ${summary.totalDeliveriesCount}'),
      TextCellValue('Distinct Material Items: ${summary.totalDistinctItemsCount}'),
    ]);
    sheet.appendRow([TextCellValue('')]);

    // Table Headers
    sheet.appendRow([
      TextCellValue('#'),
      TextCellValue('Material Category'),
      TextCellValue('Item Description'),
      TextCellValue('Total Quantity Inward'),
      TextCellValue('Unit'),
      TextCellValue('Average Unit Rate (₹)'),
      TextCellValue('Total Amount (₹)'),
      TextCellValue('Delivery Bills Count'),
      TextCellValue('Last Delivery Date'),
      TextCellValue('Primary Supplier / Vendor'),
    ]);

    int index = 1;
    for (final item in summary.items) {
      sheet.appendRow([
        IntCellValue(index++),
        TextCellValue(item.materialCategory),
        TextCellValue(item.itemDescription),
        DoubleCellValue(item.totalQuantity),
        TextCellValue(item.unit),
        DoubleCellValue(item.avgUnitRate),
        DoubleCellValue(item.totalAmount),
        IntCellValue(item.inwardCount),
        TextCellValue(item.lastDeliveryDate != null ? DateFormatter.format(item.lastDeliveryDate!) : '—'),
        TextCellValue(item.primaryVendor ?? '—'),
      ]);
    }

    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('TOTALS'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      DoubleCellValue(summary.totalMaterialSpend),
      IntCellValue(summary.totalDeliveriesCount),
      TextCellValue(''),
      TextCellValue(''),
    ]);

    // ── Delivery Log Sheet ──
    final logSheet = excel['Delivery Inward Log'];
    logSheet.appendRow([TextCellValue('PROJECT MATERIAL INWARD DELIVERY LOG')]);
    logSheet.appendRow([TextCellValue('')]);
    logSheet.appendRow([
      TextCellValue('Delivery Date'),
      TextCellValue('Challan / Bill Ref No'),
      TextCellValue('Item Description'),
      TextCellValue('Material Category'),
      TextCellValue('Quantity'),
      TextCellValue('Unit'),
      TextCellValue('Unit Rate (₹)'),
      TextCellValue('Total Amount (₹)'),
      TextCellValue('Supplier / Vendor'),
      TextCellValue('Project'),
      TextCellValue('Payment Status'),
      TextCellValue('Payment Mode'),
      TextCellValue('Notes / Narration'),
    ]);

    for (final item in summary.items) {
      for (final del in item.deliveryHistory) {
        logSheet.appendRow([
          TextCellValue(DateFormatter.format(del.transaction.date)),
          TextCellValue(del.transaction.referenceNo ?? '—'),
          TextCellValue(del.purchase.itemDescription),
          TextCellValue(del.purchase.materialCategory ?? 'General Material'),
          DoubleCellValue(del.purchase.quantity),
          TextCellValue(del.purchase.unit ?? 'Units'),
          DoubleCellValue(del.purchase.unitRate),
          DoubleCellValue(del.transaction.amount),
          TextCellValue(del.vendor.name),
          TextCellValue(del.project.name),
          TextCellValue(del.purchase.paymentStatus.displayName),
          TextCellValue(del.transaction.paymentMode?.displayName ?? '—'),
          TextCellValue(del.transaction.narration ?? '—'),
        ]);
      }
    }

    final safeProjName = (summary.projectCode ?? summary.projectName).replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return _saveExcelFile(
      excel,
      'Materials_${safeProjName}_${DateFormatter.format(DateTime.now()).replaceAll(' ', '_')}.xlsx',
    );
  }
}

