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
import 'package:nex_ledger/core/database/daos/purchase_dao.dart';
import 'package:nex_ledger/features/purchase/data/purchase_invoice_repository.dart';
import 'package:nex_ledger/features/reports/data/gst_register.dart';
import 'package:nex_ledger/features/reports/data/input_gst.dart';
import 'package:nex_ledger/features/reports/data/purchase_register.dart';
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
    sheet.appendRow([
      TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')
    ]);
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
    sheet.appendRow([
      TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')
    ]);
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
          : ((originalAmount - adjustedAmount) > 0
              ? (originalAmount - adjustedAmount)
              : 0.0);

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
        DoubleCellValue(
            d.status == DepositStatus.refunded ? originalAmount : 0.0),
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

    sheet.appendRow(
        [TextCellValue('NEXLEDGER LABOUR & WORKER RUNNING WAGE LEDGER')]);
    sheet.appendRow([
      TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')
    ]);
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

    sheet.appendRow(
        [TextCellValue('NEXLEDGER FINANCIAL ERP — ACCOUNT STATEMENT')]);
    sheet.appendRow(
        [TextCellValue('Ledger: $ledgerTitle — ${summary.entityName}')]);
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
    sheet.appendRow([
      TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')
    ]);
    sheet.appendRow([TextCellValue('')]);

    // Summary KPIs Box
    sheet.appendRow([
      TextCellValue('SUMMARY'),
      TextCellValue(
          '${summary.creditLabel}: ₹${summary.totalCredit.toStringAsFixed(2)}'),
      TextCellValue(
          '${summary.debitLabel}: ₹${summary.totalDebit.toStringAsFixed(2)}'),
      TextCellValue(
          '${summary.balanceLabel}: ₹${summary.closingBalance.toStringAsFixed(2)}'),
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
        TextCellValue(
            '${e.title}${e.subtitle != null ? ' (${e.subtitle})' : ''}'),
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

    final safeName =
        summary.entityName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
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
    sheet.appendRow(
        [TextCellValue('NEXLEDGER ERP — PROJECT MATERIAL QUANTITY REGISTER')]);
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
      sheet.appendRow(
          [TextCellValue('Period: All-Time Project Inward Deliveries')]);
    }
    sheet.appendRow([
      TextCellValue('Generated On: ${DateFormatter.format(DateTime.now())}')
    ]);
    sheet.appendRow([TextCellValue('')]);

    // KPI Summary Block
    sheet.appendRow([
      TextCellValue('SUMMARY METRICS'),
      TextCellValue(
          'Total Material Spend: ₹${summary.totalMaterialSpend.toStringAsFixed(2)}'),
      TextCellValue(
          'Total Delivery Consignments: ${summary.totalDeliveriesCount}'),
      TextCellValue(
          'Distinct Material Items: ${summary.totalDistinctItemsCount}'),
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
        TextCellValue(item.lastDeliveryDate != null
            ? DateFormatter.format(item.lastDeliveryDate!)
            : '—'),
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

    final safeProjName = (summary.projectCode ?? summary.projectName)
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return _saveExcelFile(
      excel,
      'Materials_${safeProjName}_${DateFormatter.format(DateTime.now()).replaceAll(' ', '_')}.xlsx',
    );
  }

  // ─── Purchase Register ─────────────────────────────────────────────────────

  /// Builds the workbook: one sheet with every bill and one with the shop-wise
  /// totals. Kept separate from saving so it can be tested.
  static Excel buildPurchaseRegisterWorkbook({
    required List<PurchaseDetail> rows,
    required String filterText,
  }) {
    final excel = Excel.createExcel();
    final bills = excel['Purchase Register'];
    final shops = excel['By Shop'];
    excel.delete('Sheet1');

    final totals = purchaseTotals(rows);
    final generated = 'Generated On: ${DateFormatter.format(DateTime.now())}';

    // ── Sheet 1: every bill ──
    bills.appendRow([TextCellValue('NEXLEDGER ERP — PURCHASE REGISTER')]);
    bills.appendRow([TextCellValue(filterText)]);
    bills.appendRow([TextCellValue(generated)]);
    bills.appendRow([TextCellValue('')]);
    bills.appendRow([
      TextCellValue('#'),
      TextCellValue('Date'),
      TextCellValue('Shop / Supplier'),
      TextCellValue('Project'),
      TextCellValue('Item'),
      TextCellValue('Category'),
      TextCellValue('Qty'),
      TextCellValue('Unit'),
      TextCellValue('Rate (₹)'),
      TextCellValue('Bill Amount (₹)'),
      TextCellValue('Paid (₹)'),
      TextCellValue('Balance (₹)'),
      TextCellValue('Status'),
      TextCellValue('Type'),
    ]);
    var n = 1;
    for (final d in rows) {
      bills.appendRow([
        IntCellValue(n++),
        TextCellValue(DateFormatter.format(d.transaction.date)),
        TextCellValue(d.vendor.name),
        TextCellValue('${d.project.code} — ${d.project.name}'),
        TextCellValue(d.purchase.itemDescription),
        TextCellValue(d.purchase.materialCategory ?? '—'),
        DoubleCellValue(d.purchase.quantity),
        TextCellValue(d.purchase.unit ?? '—'),
        DoubleCellValue(d.purchase.unitRate),
        DoubleCellValue(d.transaction.amount),
        DoubleCellValue(d.purchase.paidAmount),
        DoubleCellValue(purchaseBalance(d)),
        TextCellValue(d.purchase.paymentStatus.displayName),
        TextCellValue(d.purchase.isAdvanceStock ? 'Stock' : 'Direct Cost'),
      ]);
    }
    bills.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('TOTAL (${totals.count} bills)'),
      DoubleCellValue(totals.total),
      DoubleCellValue(totals.paid),
      DoubleCellValue(totals.balance),
    ]);

    // ── Sheet 2: by shop ──
    shops.appendRow([TextCellValue('NEXLEDGER ERP — SHOP-WISE PURCHASES')]);
    shops.appendRow([TextCellValue(filterText)]);
    shops.appendRow([TextCellValue(generated)]);
    shops.appendRow([TextCellValue('')]);
    shops.appendRow([
      TextCellValue('#'),
      TextCellValue('Shop / Supplier'),
      TextCellValue('Contact'),
      TextCellValue('Bills'),
      TextCellValue('Total Purchased (₹)'),
      TextCellValue('Paid (₹)'),
      TextCellValue('Balance to Pay (₹)'),
      TextCellValue('Last Bill'),
    ]);
    var k = 1;
    for (final sh in summarizeByShop(rows)) {
      shops.appendRow([
        IntCellValue(k++),
        TextCellValue(sh.vendor.name),
        TextCellValue(sh.vendor.contact ?? '—'),
        IntCellValue(sh.bills),
        DoubleCellValue(sh.total),
        DoubleCellValue(sh.paid),
        DoubleCellValue(sh.balance),
        TextCellValue(DateFormatter.format(sh.lastBillDate)),
      ]);
    }
    shops.appendRow([
      TextCellValue(''),
      TextCellValue('TOTAL'),
      TextCellValue(''),
      IntCellValue(totals.count),
      DoubleCellValue(totals.total),
      DoubleCellValue(totals.paid),
      DoubleCellValue(totals.balance),
    ]);

    return excel;
  }

  static Future<String?> exportPurchaseRegister({
    required List<PurchaseDetail> rows,
    required String filterText,
  }) {
    final excel =
        buildPurchaseRegisterWorkbook(rows: rows, filterText: filterText);
    final stamp = DateFormatter.toDbString(DateTime.now());
    return _saveExcelFile(excel, 'Purchase_Register_$stamp.xlsx');
  }

  // ─── GST Purchase Register ─────────────────────────────────────────────────

  /// Four sheets for the accountant: invoice-wise, item-wise (with HSN),
  /// rate-wise and supplier-wise. Kept separate from saving so it can be tested.
  static Excel buildGstRegisterWorkbook({
    required List<InvoiceDetail> rows,
    required String filterText,
  }) {
    final excel = Excel.createExcel();
    final inv = excel['Invoice Register'];
    final items = excel['Item Details'];
    final rates = excel['By GST Rate'];
    final sup = excel['By Supplier'];
    excel.delete('Sheet1');

    final totals = gstRegisterTotals(rows);
    final generated = 'Generated On: ${DateFormatter.format(DateTime.now())}';
    void title(Sheet sh, String name) {
      sh.appendRow([TextCellValue('NEXLEDGER ERP — $name')]);
      sh.appendRow([TextCellValue(filterText)]);
      sh.appendRow([TextCellValue(generated)]);
      sh.appendRow([TextCellValue('')]);
    }

    // ── Invoice register ──
    title(inv, 'GST PURCHASE REGISTER (INVOICE-WISE)');
    inv.appendRow([
      TextCellValue('#'),
      TextCellValue('Purchase No'),
      TextCellValue('Purchase Date'),
      TextCellValue('Supplier Invoice No'),
      TextCellValue('Invoice Date'),
      TextCellValue('Supplier'),
      TextCellValue('Supplier GSTIN'),
      TextCellValue('State'),
      TextCellValue('Project'),
      TextCellValue('Type'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('CGST (₹)'),
      TextCellValue('SGST (₹)'),
      TextCellValue('IGST (₹)'),
      TextCellValue('Other Charges (₹)'),
      TextCellValue('Round Off (₹)'),
      TextCellValue('Invoice Total (₹)'),
      TextCellValue('Paid (₹)'),
      TextCellValue('Balance (₹)'),
      TextCellValue('Status'),
    ]);
    var n = 1;
    for (final d in rows) {
      final i = d.invoice;
      inv.appendRow([
        IntCellValue(n++),
        TextCellValue(i.purchaseNo),
        TextCellValue(DateFormatter.format(i.date)),
        TextCellValue(i.invoiceNo ?? '—'),
        TextCellValue(
            i.invoiceDate != null ? DateFormatter.format(i.invoiceDate!) : '—'),
        TextCellValue(d.vendor.name),
        TextCellValue(i.supplierGstin ?? '—'),
        TextCellValue(i.supplierState ?? '—'),
        TextCellValue('${d.project.code} — ${d.project.name}'),
        TextCellValue(
            i.isInterState ? 'Inter-state (IGST)' : 'Local (CGST+SGST)'),
        DoubleCellValue(i.taxableValue),
        DoubleCellValue(i.cgstAmount),
        DoubleCellValue(i.sgstAmount),
        DoubleCellValue(i.igstAmount),
        DoubleCellValue(i.otherCharges),
        DoubleCellValue(i.roundOff),
        DoubleCellValue(i.grandTotal),
        DoubleCellValue(d.paid),
        DoubleCellValue(d.balance),
        TextCellValue(d.status.displayName),
      ]);
    }
    inv.appendRow([
      TextCellValue(''),
      TextCellValue('TOTAL (${totals.invoices} invoices)'),
      for (var k = 0; k < 8; k++) TextCellValue(''),
      DoubleCellValue(totals.taxable),
      DoubleCellValue(totals.cgst),
      DoubleCellValue(totals.sgst),
      DoubleCellValue(totals.igst),
      DoubleCellValue(totals.otherCharges),
      DoubleCellValue(totals.roundOff),
      DoubleCellValue(totals.total),
    ]);

    // ── Item details (HSN) ──
    title(items, 'GST PURCHASE REGISTER (ITEM-WISE)');
    items.appendRow([
      TextCellValue('Purchase No'),
      TextCellValue('Date'),
      TextCellValue('Supplier'),
      TextCellValue('Item'),
      TextCellValue('HSN / SAC'),
      TextCellValue('Qty'),
      TextCellValue('Unit'),
      TextCellValue('Rate (₹)'),
      TextCellValue('Discount %'),
      TextCellValue('Taxable (₹)'),
      TextCellValue('GST %'),
      TextCellValue('CGST (₹)'),
      TextCellValue('SGST (₹)'),
      TextCellValue('IGST (₹)'),
    ]);
    for (final d in rows) {
      for (final l in d.lines.where((l) => !l.purchase.isOtherCharge)) {
        final p = l.purchase;
        items.appendRow([
          TextCellValue(d.invoice.purchaseNo),
          TextCellValue(DateFormatter.format(d.invoice.date)),
          TextCellValue(d.vendor.name),
          TextCellValue(p.itemDescription),
          TextCellValue(p.hsn ?? '—'),
          DoubleCellValue(p.quantity),
          TextCellValue(p.unit ?? '—'),
          DoubleCellValue(p.unitRate),
          DoubleCellValue(p.discountPercent),
          DoubleCellValue(p.taxableAmount),
          DoubleCellValue(p.gstRate),
          DoubleCellValue(p.cgstAmount),
          DoubleCellValue(p.sgstAmount),
          DoubleCellValue(p.igstAmount),
        ]);
      }
    }

    // ── Rate-wise ──
    title(rates, 'GST PURCHASES BY RATE');
    rates.appendRow([
      TextCellValue('GST Rate %'),
      TextCellValue('Items'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('CGST (₹)'),
      TextCellValue('SGST (₹)'),
      TextCellValue('IGST (₹)'),
      TextCellValue('Total GST (₹)'),
    ]);
    final byRate = summarizeByRate(rows);
    for (final r in byRate) {
      rates.appendRow([
        DoubleCellValue(r.rate),
        IntCellValue(r.items),
        DoubleCellValue(r.taxable),
        DoubleCellValue(r.cgst),
        DoubleCellValue(r.sgst),
        DoubleCellValue(r.igst),
        DoubleCellValue(r.totalGst),
      ]);
    }
    rates.appendRow([
      TextCellValue('TOTAL'),
      IntCellValue(byRate.fold<int>(0, (a, r) => a + r.items)),
      DoubleCellValue(byRate.fold<double>(0, (a, r) => a + r.taxable)),
      DoubleCellValue(byRate.fold<double>(0, (a, r) => a + r.cgst)),
      DoubleCellValue(byRate.fold<double>(0, (a, r) => a + r.sgst)),
      DoubleCellValue(byRate.fold<double>(0, (a, r) => a + r.igst)),
      DoubleCellValue(byRate.fold<double>(0, (a, r) => a + r.totalGst)),
    ]);

    // ── Supplier-wise ──
    title(sup, 'GST PURCHASES BY SUPPLIER');
    sup.appendRow([
      TextCellValue('#'),
      TextCellValue('Supplier'),
      TextCellValue('GSTIN'),
      TextCellValue('Invoices'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('GST (₹)'),
      TextCellValue('Invoice Total (₹)'),
    ]);
    var k = 1;
    for (final sm in summarizeBySupplier(rows)) {
      sup.appendRow([
        IntCellValue(k++),
        TextCellValue(sm.name),
        TextCellValue(sm.gstin ?? '—'),
        IntCellValue(sm.invoices),
        DoubleCellValue(sm.taxable),
        DoubleCellValue(sm.gst),
        DoubleCellValue(sm.total),
      ]);
    }

    return excel;
  }

  static Future<String?> exportGstRegister({
    required List<InvoiceDetail> rows,
    required String filterText,
  }) {
    final excel = buildGstRegisterWorkbook(rows: rows, filterText: filterText);
    final stamp = DateFormatter.toDbString(DateTime.now());
    return _saveExcelFile(excel, 'GST_Purchase_Register_$stamp.xlsx');
  }

  // ─── Input GST report ──────────────────────────────────────────────────────

  /// Three sheets: by project (with the split by source), by source, and
  /// every entry. Kept separate from saving so it can be tested.
  static Excel buildInputGstWorkbook({
    required List<InputGstEntry> entries,
    required String filterText,
    Map<int, double> projectCosts = const {},
  }) {
    final excel = Excel.createExcel();
    final byProject = excel['By Project'];
    final bySource = excel['By Source'];
    final all = excel['All Entries'];
    excel.delete('Sheet1');

    final generated = 'Generated On: ${DateFormatter.format(DateTime.now())}';
    void title(Sheet sh, String name) {
      sh.appendRow([TextCellValue('NEXLEDGER ERP — $name')]);
      sh.appendRow([TextCellValue(filterText)]);
      sh.appendRow([TextCellValue(generated)]);
      sh.appendRow([TextCellValue('')]);
    }

    // ── By project ──
    title(byProject, 'INPUT GST BY PROJECT');
    byProject.appendRow([
      TextCellValue('#'),
      TextCellValue('Project'),
      TextCellValue('Name'),
      TextCellValue('Project Costs incl. GST (₹)'),
      TextCellValue('GST inside Costs (₹)'),
      TextCellValue('Costs without GST (₹)'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('CGST (₹)'),
      TextCellValue('SGST (₹)'),
      TextCellValue('IGST (₹)'),
      TextCellValue('Total Input GST (₹)'),
      for (final s in InputGstSource.values)
        TextCellValue('${s.label} GST (₹)'),
    ]);
    var n = 1;
    var sumCosts = 0.0, sumGstInCosts = 0.0;
    for (final p in summarizeByProject(entries)) {
      final view = ProjectCostView(
          totalCosts: projectCosts[p.projectId] ?? 0.0,
          gstInCosts: p.gstInCosts);
      sumCosts += view.totalCosts;
      sumGstInCosts += view.gstInCosts;
      byProject.appendRow([
        IntCellValue(n++),
        TextCellValue(p.projectCode),
        TextCellValue(p.projectName),
        DoubleCellValue(view.totalCosts),
        DoubleCellValue(view.gstInCosts),
        DoubleCellValue(view.costsWithoutGst),
        DoubleCellValue(p.totals.taxable),
        DoubleCellValue(p.totals.cgst),
        DoubleCellValue(p.totals.sgst),
        DoubleCellValue(p.totals.igst),
        DoubleCellValue(p.totals.gst),
        for (final s in InputGstSource.values)
          DoubleCellValue(p.gstBySource[s] ?? 0.0),
      ]);
    }
    final t = inputGstTotals(entries);
    byProject.appendRow([
      TextCellValue(''),
      TextCellValue('TOTAL'),
      TextCellValue(''),
      DoubleCellValue(sumCosts),
      DoubleCellValue(sumGstInCosts),
      DoubleCellValue(
          ProjectCostView(totalCosts: sumCosts, gstInCosts: sumGstInCosts)
              .costsWithoutGst),
      DoubleCellValue(t.taxable),
      DoubleCellValue(t.cgst),
      DoubleCellValue(t.sgst),
      DoubleCellValue(t.igst),
      DoubleCellValue(t.gst),
      for (final s in InputGstSource.values)
        DoubleCellValue(
            inputGstTotals(entries.where((e) => e.source == s)).gst),
    ]);

    // ── By source ──
    title(bySource, 'INPUT GST BY SOURCE');
    bySource.appendRow([
      TextCellValue('Source'),
      TextCellValue('Bills'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('CGST (₹)'),
      TextCellValue('SGST (₹)'),
      TextCellValue('IGST (₹)'),
      TextCellValue('Total Input GST (₹)'),
    ]);
    for (final sm in summarizeBySource(entries)) {
      bySource.appendRow([
        TextCellValue(sm.source.label),
        IntCellValue(sm.totals.entries),
        DoubleCellValue(sm.totals.taxable),
        DoubleCellValue(sm.totals.cgst),
        DoubleCellValue(sm.totals.sgst),
        DoubleCellValue(sm.totals.igst),
        DoubleCellValue(sm.totals.gst),
      ]);
    }
    bySource.appendRow([
      TextCellValue('TOTAL'),
      IntCellValue(t.entries),
      DoubleCellValue(t.taxable),
      DoubleCellValue(t.cgst),
      DoubleCellValue(t.sgst),
      DoubleCellValue(t.igst),
      DoubleCellValue(t.gst),
    ]);

    // ── Every entry ──
    title(all, 'INPUT GST — ALL ENTRIES');
    all.appendRow([
      TextCellValue('Date'),
      TextCellValue('Project'),
      TextCellValue('Source'),
      TextCellValue('Party'),
      TextCellValue('GSTIN'),
      TextCellValue('Document'),
      TextCellValue('Details'),
      TextCellValue('Taxable Value (₹)'),
      TextCellValue('CGST (₹)'),
      TextCellValue('SGST (₹)'),
      TextCellValue('IGST (₹)'),
      TextCellValue('Total GST (₹)'),
      TextCellValue('Bill Total (₹)'),
    ]);
    for (final e in entries) {
      all.appendRow([
        TextCellValue(DateFormatter.format(e.date)),
        TextCellValue('${e.projectCode} — ${e.projectName}'),
        TextCellValue(e.source.label),
        TextCellValue(e.party),
        TextCellValue(e.gstin ?? '—'),
        TextCellValue(e.docNo),
        TextCellValue(e.detail ?? '—'),
        DoubleCellValue(e.taxable),
        DoubleCellValue(e.cgst),
        DoubleCellValue(e.sgst),
        DoubleCellValue(e.igst),
        DoubleCellValue(e.gst),
        DoubleCellValue(e.total),
      ]);
    }

    return excel;
  }

  static Future<String?> exportInputGst({
    required List<InputGstEntry> entries,
    required String filterText,
    Map<int, double> projectCosts = const {},
  }) {
    final excel = buildInputGstWorkbook(
        entries: entries, filterText: filterText, projectCosts: projectCosts);
    final stamp = DateFormatter.toDbString(DateTime.now());
    return _saveExcelFile(excel, 'Input_GST_Report_$stamp.xlsx');
  }
}
