import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/core/utils/number_to_words.dart';

class PdfReceiptService {
  PdfReceiptService._();

  static final PdfColor _primaryColor = PdfColor.fromInt(0xFF1E3A8A); // Deep Blue
  static final PdfColor _accentColor = PdfColor.fromInt(0xFF0D9488); // Teal
  static final PdfColor _darkNeutral = PdfColor.fromInt(0xFF0F172A); // Slate 900
  static final PdfColor _mutedNeutral = PdfColor.fromInt(0xFF64748B); // Slate 500
  static final PdfColor _lightBg = PdfColor.fromInt(0xFFF8FAFC); // Slate 50
  static final PdfColor _borderColor = PdfColor.fromInt(0xFFCBD5E1); // Slate 300

  static final NumberFormat _inrFormatter = NumberFormat('#,##,##0.00', 'en_IN');

  static String _formatInr(double amount) {
    return 'Rs. ${_inrFormatter.format(amount)}';
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 1. LABOUR WAGE PAYMENT RECEIPT & SLIP
  // ════════════════════════════════════════════════════════════════════════════
  static Future<Uint8List> generateLabourWageReceipt({
    required Worker worker,
    required Project project,
    required double amountPaid,
    required DateTime paymentDate,
    required PaymentMode paymentMode,
    String? bankAccountName,
    String? narration,
    String? voucherNumber,
    required double totalEffectiveDaysWorked,
    required double totalGrossWagesEarned,
    required double totalPaymentsIssued,
    required double netBalanceDueRemaining,
    String? firmName,
  }) async {
    final pdf = pw.Document(title: 'Wage Receipt - ${worker.name}');
    final receiptNum = voucherNumber ??
        'WAG-${paymentDate.year}${paymentDate.month.toString().padLeft(2, '0')}-${worker.id.toString().padLeft(3, '0')}';
    final amountWords = NumberToWordsIndian.convert(amountPaid);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ─── Header ──────────────────────────────────────────────────
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: _primaryColor, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          firmName ?? 'NEXLEDGER CONSTRUCTION & CONTRACTING',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Labour Wage Settlement & Daily Payment Receipt',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: _mutedNeutral,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: pw.BoxDecoration(
                        color: _primaryColor,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'WAGE PAYMENT SLIP',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // ─── Meta Bar ────────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Receipt #: $receiptNum',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Date: ${DateFormatter.format(paymentDate)}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Mode: ${paymentMode.displayName}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 12),

              // ─── Worker & Project Grids ───────────────────────────────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Worker Details
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: _lightBg,
                        border: pw.Border.all(color: _borderColor),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('WORKER / BENEFICIARY',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _primaryColor)),
                          pw.SizedBox(height: 4),
                          pw.Text(worker.name,
                              style: pw.TextStyle(
                                  fontSize: 13,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          if (worker.workerCode != null)
                            pw.Text('Worker Code: ${worker.workerCode}',
                                style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('Trade / Skill: ${worker.trade ?? 'General'}',
                              style: const pw.TextStyle(fontSize: 9)),
                          pw.Text(
                              'Daily Wage Rate: ${_formatInr(worker.dailyRate)} / day',
                              style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  // Project Details
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: _lightBg,
                        border: pw.Border.all(color: _borderColor),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('PROJECT SITE CHARGED',
                              style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                  color: _primaryColor)),
                          pw.SizedBox(height: 4),
                          pw.Text('${project.code} - ${project.name}',
                              style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 2),
                          if (project.clientName != null)
                            pw.Text('Client: ${project.clientName}',
                                style: const pw.TextStyle(fontSize: 9)),
                          if (bankAccountName != null)
                            pw.Text('Paid From: $bankAccountName',
                                style: const pw.TextStyle(fontSize: 9)),
                          if (narration != null && narration.isNotEmpty)
                            pw.Text('Remarks: $narration',
                                style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 14),

              // ─── Payment Highlight Banner ────────────────────────────────
              pw.Container(
                width: double.infinity,
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFF0FDF4), // Light Green
                  border: pw.Border.all(
                      color: PdfColor.fromInt(0xFF86EFAC)), // Green border
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('AMOUNT PAID (THIS VOUCHER):',
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(0xFF166534))),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Rupees: $amountWords',
                          style: pw.TextStyle(
                              fontSize: 9,
                              fontStyle: pw.FontStyle.italic,
                              color: PdfColor.fromInt(0xFF14532D)),
                        ),
                      ],
                    ),
                    pw.Text(
                      _formatInr(amountPaid),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // ─── All-Time Running Ledger Snapshot ────────────────────────
              pw.Text('WORKER ALL-TIME WAGE LEDGER AUDIT',
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _darkNeutral)),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: _borderColor, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: _lightBg),
                    children: [
                      _th('Total Days Worked (All-Time)'),
                      _th('Gross Wages Earned'),
                      _th('Total Wages Paid (Inc. Today)'),
                      _th('Outstanding Due Remaining'),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _td('${totalEffectiveDaysWorked.toStringAsFixed(1)} Days'),
                      _td(_formatInr(totalGrossWagesEarned)),
                      _td(_formatInr(totalPaymentsIssued)),
                      _td(
                        _formatInr(netBalanceDueRemaining),
                        bold: true,
                        color: netBalanceDueRemaining > 0
                            ? PdfColor.fromInt(0xFFB91C1C)
                            : PdfColor.fromInt(0xFF047857),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // ─── Signatures & Verification Section ───────────────────────
              pw.Text('AUTHORIZATION & RECEIPT CONFIRMATION',
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _darkNeutral)),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  // Worker Thumb / Signature Box
                  pw.Expanded(
                    child: pw.Container(
                      height: 75,
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: _borderColor,
                            style: pw.BorderStyle.dashed,
                            width: 1),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Worker Signature / Thumb Impression (LTI)',
                            style: const pw.TextStyle(
                                fontSize: 7, color: PdfColors.grey700),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text('Received Cash / Payment Confirmed',
                              style: const pw.TextStyle(
                                  fontSize: 6, color: PdfColors.grey600)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  // Site Supervisor Box
                  pw.Expanded(
                    child: pw.Container(
                      height: 75,
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: _borderColor,
                            style: pw.BorderStyle.dashed,
                            width: 1),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Site Supervisor / Timekeeper',
                            style: const pw.TextStyle(
                                fontSize: 7, color: PdfColors.grey700),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text('Attendance Verified',
                              style: const pw.TextStyle(
                                  fontSize: 6, color: PdfColors.grey600)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  // Project Manager / Accountant Box
                  pw.Expanded(
                    child: pw.Container(
                      height: 75,
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: _borderColor,
                            style: pw.BorderStyle.dashed,
                            width: 1),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            'Authorised Signatory / PM',
                            style: const pw.TextStyle(
                                fontSize: 7, color: PdfColors.grey700),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text('Passed for Payment',
                              style: const pw.TextStyle(
                                  fontSize: 6, color: PdfColors.grey600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // ─── Legal Footer ────────────────────────────────────────────
              pw.Divider(color: _borderColor, thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated by NexLedger Mini ERP',
                      style: const pw.TextStyle(
                          fontSize: 7, color: PdfColors.grey600)),
                  pw.Text(
                      'Print Timestamp: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}',
                      style: const pw.TextStyle(
                          fontSize: 7, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 2. GENERAL CASH BOOK / EXPENSE / VENDOR PAYMENT VOUCHER
  // ════════════════════════════════════════════════════════════════════════════
  static Future<Uint8List> generatePaymentVoucher({
    required int transactionId,
    required DateTime date,
    required TransactionType type,
    required double amount,
    required PaymentMode paymentMode,
    String? projectName,
    String? projectCode,
    String? category,
    String? narration,
    String? partyName,
    String? bankAccountName,
    String? voucherRef,
    String? firmName,
  }) async {
    final pdf = pw.Document(title: 'Payment Voucher - #$transactionId');
    final voucherNo = voucherRef ?? 'VCH-${date.year}${date.month.toString().padLeft(2, '0')}-${transactionId.toString().padLeft(4, '0')}';
    final amountWords = NumberToWordsIndian.convert(amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: _primaryColor, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          firmName ?? 'NEXLEDGER CONSTRUCTION & CONTRACTING',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Financial Accounts & Cash Book Voucher',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: _mutedNeutral,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: pw.BoxDecoration(
                        color: _primaryColor,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'PAYMENT VOUCHER',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              // Metadata row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Voucher No: $voucherNo',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Date: ${DateFormatter.format(date)}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Type: ${type.displayName}',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 14),

              // Main Details Table
              pw.Table(
                border: pw.TableBorder.all(color: _borderColor, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: _lightBg),
                    children: [
                      _th('Particulars / Debit Head', flex: 3),
                      _th('Project Site / Ref', flex: 2),
                      _th('Payment Mode', flex: 2),
                      _th('Amount (INR)', flex: 2),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _td(
                        '${partyName ?? category ?? type.displayName}\n${narration ?? ''}',
                        flex: 3,
                      ),
                      _td(
                        projectCode != null
                            ? '$projectCode\n${projectName ?? ''}'
                            : (projectName ?? 'General / Admin'),
                        flex: 2,
                      ),
                      _td(
                        '${paymentMode.displayName}${bankAccountName != null ? '\n($bankAccountName)' : ''}',
                        flex: 2,
                      ),
                      _td(
                        _formatInr(amount),
                        flex: 2,
                        bold: true,
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // Amount in words box
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: _lightBg,
                  border: pw.Border.all(color: _borderColor),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('AMOUNT IN WORDS:',
                            style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: _mutedNeutral)),
                        pw.SizedBox(height: 2),
                        pw.Text(amountWords,
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: _darkNeutral)),
                      ],
                    ),
                    pw.Text(
                      _formatInr(amount),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _sigBox('Prepared By (Accountant)'),
                  pw.SizedBox(width: 16),
                  _sigBox('Checked & Verified By'),
                  pw.SizedBox(width: 16),
                  _sigBox('Receiver Signature'),
                ],
              ),
              pw.Spacer(),

              // Legal Footer
              pw.Divider(color: _borderColor, thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('NexLedger Financial Record - System Generated',
                      style: const pw.TextStyle(
                          fontSize: 7, color: PdfColors.grey600)),
                  pw.Text(
                      'Printed: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(
                          fontSize: 7, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ════════════════════════════════════════════════════════════════════════════
  // 3. PETTY CASH IMPREST VOUCHER
  // ════════════════════════════════════════════════════════════════════════════
  static Future<Uint8List> generatePettyCashVoucher({
    required PettyCashVoucher voucher,
    required String supervisorName,
    String? projectName,
    String? projectCode,
    String? bankAccountName,
    String? firmName,
  }) async {
    final pdf = pw.Document(title: 'Petty Cash Voucher - #${voucher.id}');
    final amountWords = NumberToWordsIndian.convert(voucher.amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 12),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: _primaryColor, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          firmName ?? 'NEXLEDGER CONSTRUCTION & CONTRACTING',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Site Supervisor Imprest / Petty Cash Voucher',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: _mutedNeutral,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: pw.BoxDecoration(
                        color: _accentColor,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        voucher.type.displayName.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Voucher #: ${voucher.voucherNumber ?? 'PC-${voucher.id}'}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Date: ${DateFormatter.format(voucher.date)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text('Supervisor: $supervisorName',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                ],
              ),
              pw.SizedBox(height: 14),

              pw.Table(
                border: pw.TableBorder.all(color: _borderColor, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: _lightBg),
                    children: [
                      _th('Description / Category', flex: 3),
                      _th('Cost Head / Project', flex: 2),
                      _th('Payment Mode', flex: 2),
                      _th('Amount (INR)', flex: 2),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _td(
                        'Category: ${voucher.category ?? 'Site Expense'}\n${voucher.narration ?? ''}',
                        flex: 3,
                      ),
                      _td(
                        '${voucher.costHead?.displayName ?? 'General'}\n${projectCode ?? ''} ${projectName ?? ''}',
                        flex: 2,
                      ),
                      _td(
                        '${voucher.paymentMode?.displayName ?? 'Cash'}${bankAccountName != null ? '\n($bankAccountName)' : ''}',
                        flex: 2,
                      ),
                      _td(
                        _formatInr(voucher.amount),
                        flex: 2,
                        bold: true,
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: _lightBg,
                  border: pw.Border.all(color: _borderColor),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('AMOUNT IN WORDS:',
                            style: pw.TextStyle(
                                fontSize: 8,
                                fontWeight: pw.FontWeight.bold,
                                color: _mutedNeutral)),
                        pw.SizedBox(height: 2),
                        pw.Text(amountWords,
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: _darkNeutral)),
                      ],
                    ),
                    pw.Text(
                      _formatInr(voucher.amount),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _sigBox('Supervisor Signature ($supervisorName)'),
                  pw.SizedBox(width: 16),
                  _sigBox('Verified By (${voucher.verifiedBy ?? 'Accountant'})'),
                  pw.SizedBox(width: 16),
                  _sigBox('Passed / Project Manager'),
                ],
              ),
              pw.Spacer(),

              pw.Divider(color: _borderColor, thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('NexLedger Imprest Module - Single User Offline ERP',
                      style: const pw.TextStyle(
                          fontSize: 7, color: PdfColors.grey600)),
                  pw.Text(
                      'Printed: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: const pw.TextStyle(
                          fontSize: 7, color: PdfColors.grey600)),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // ─── Table Cell Helpers ──────────────────────────────────────────────────
  static pw.Widget _th(String text, {int flex = 1}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: _darkNeutral,
        ),
      ),
    );
  }

  static pw.Widget _td(
    String text, {
    int flex = 1,
    bool bold = false,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? _darkNeutral,
        ),
      ),
    );
  }

  static pw.Widget _sigBox(String title) {
    return pw.Expanded(
      child: pw.Container(
        height: 65,
        padding: const pw.EdgeInsets.all(6),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
              color: _borderColor,
              style: pw.BorderStyle.dashed,
              width: 0.8),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              title,
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text('Sign Above',
                style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500)),
          ],
        ),
      ),
    );
  }
}
