import 'package:nex_ledger/core/constants/enums.dart';

/// Represents a single chronological line item in any ledger statement.
class LedgerEntry {
  final int id;
  final DateTime date;
  final String? referenceNo;
  final String title;
  final String? subtitle;
  final String? projectCode;
  final String? projectName;
  final double debit; // Outflow / Paid / Drawings
  final double credit; // Inflow / Billed / Wages Earned / Capital Injected
  final double runningBalance;
  final String balanceType; // 'Dr' (Debit) or 'Cr' (Credit) or 'Due'
  final TransactionType? transactionType;
  final PaymentMode? paymentMode;
  final String? accountName;
  final String? notes;
  final bool isOpeningBalance;

  LedgerEntry({
    required this.id,
    required this.date,
    this.referenceNo,
    required this.title,
    this.subtitle,
    this.projectCode,
    this.projectName,
    required this.debit,
    required this.credit,
    required this.runningBalance,
    required this.balanceType,
    this.transactionType,
    this.paymentMode,
    this.accountName,
    this.notes,
    this.isOpeningBalance = false,
  });
}

/// Summary metrics for the active ledger header.
class LedgerSummary {
  final double openingBalance;
  final double totalDebit; // e.g. Total Payments Made / Total Outflows / Drawings
  final double totalCredit; // e.g. Total Billed / Total Inflows / Total Wages / Capital
  final double closingBalance; // Net Balance (e.g. Net Due, Bank Balance, Owner Capital)
  final int totalEntries;
  final String entityName;
  final String? entitySubtitle;
  final String debitLabel; // e.g. "Total Paid", "Total Outflow", "Personal Drawings"
  final String creditLabel; // e.g. "Total Billed", "Total Wages", "Capital Injected"
  final String balanceLabel; // e.g. "Net Payable Due", "Net Wage Due", "Available Balance", "Net Owner Balance"
  final bool isPayable; // True if positive balance means we owe money (Payable liability)

  LedgerSummary({
    this.openingBalance = 0.0,
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
    required this.totalEntries,
    required this.entityName,
    this.entitySubtitle,
    required this.debitLabel,
    required this.creditLabel,
    required this.balanceLabel,
    this.isPayable = false,
  });
}
