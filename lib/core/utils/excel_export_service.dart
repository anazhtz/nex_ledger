import 'dart:io';
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

/// Senior CA-Grade Financial Excel Export Engine for NexLedger.
/// Generates audit-ready .xlsx workbooks for P&L, Cash Book, Deposits, and Labour.
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
}
