import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/number_to_words.dart';
import 'package:nex_ledger/core/utils/pdf_receipt_service.dart';
import 'package:nex_ledger/shared/widgets/pdf_preview_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Printable PDF Wage Receipts & Payment Vouchers Test Suite', () {
    test('1. NumberToWordsIndian formats numbers correctly in Indian numbering system', () {
      expect(NumberToWordsIndian.convert(0), 'Zero Rupees Only');
      expect(NumberToWordsIndian.convert(500), 'Five Hundred Rupees Only');
      expect(NumberToWordsIndian.convert(1000), 'One Thousand Rupees Only');
      expect(NumberToWordsIndian.convert(12500), 'Twelve Thousand Five Hundred Rupees Only');
      expect(NumberToWordsIndian.convert(75000.50), 'Seventy Five Thousand Rupees and Fifty Paise Only');
      expect(NumberToWordsIndian.convert(350000), 'Three Lakh Fifty Thousand Rupees Only');
      expect(NumberToWordsIndian.convert(12500000), 'One Crore Twenty Five Lakh Rupees Only');
    });

    test('2. PdfReceiptService generates valid Labour Wage Slip PDF bytes', () async {
      const worker = Worker(
        id: 101,
        name: 'Raju Mason',
        workerCode: 'WRK-001',
        trade: 'Mason',
        dailyRate: 1000.0,
      );

      final project = Project(
        id: 1,
        code: 'PRJ-2026-001',
        name: 'Greenfield Luxury Villa Renovation',
        clientName: 'Dr. Ramesh Babu',
        type: ProjectType.project,
        status: ProjectStatus.active,
        startDate: DateTime(2026, 1, 1),
        clientContractValue: 5000000.0,
        clientRetentionPercentage: 5.0,
        createdAt: DateTime(2026, 1, 1),
      );

      final pdfBytes = await PdfReceiptService.generateLabourWageReceipt(
        worker: worker,
        project: project,
        amountPaid: 10000.0,
        paymentDate: DateTime(2026, 3, 1),
        paymentMode: PaymentMode.cash,
        bankAccountName: 'Site Cash Drawer',
        narration: 'Settlement for 10 days masonry work',
        voucherNumber: 'WAG-202603-101',
        totalEffectiveDaysWorked: 15.0,
        totalGrossWagesEarned: 15000.0,
        totalPaymentsIssued: 15000.0,
        netBalanceDueRemaining: 0.0,
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // PDF documents start with '%PDF-' header
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, '%PDF-');
    });

    test('3. PdfReceiptService generates valid Payment Voucher PDF bytes', () async {
      final pdfBytes = await PdfReceiptService.generatePaymentVoucher(
        transactionId: 501,
        date: DateTime(2026, 3, 2),
        type: TransactionType.purchasePayment,
        amount: 85000.0,
        paymentMode: PaymentMode.bank,
        projectName: 'Metro Rail Station Site',
        projectCode: 'PRJ-METRO-02',
        partyName: 'Ambuja Cements Ltd',
        bankAccountName: 'HDFC Current Site Account',
        category: 'Cement Materials',
        narration: 'Invoice #INV-98402 for 250 bags Grade 53 cement',
        voucherRef: 'VCH-202603-0501',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, '%PDF-');
    });

    test('4. PdfReceiptService generates valid Petty Cash Imprest Voucher PDF bytes', () async {
      final voucher = PettyCashVoucher(
        id: 701,
        walletId: 1,
        projectId: 1,
        type: PettyCashTxnType.voucherExpense,
        date: DateTime(2026, 3, 3),
        amount: 3200.0,
        category: 'Worker Food & Refreshments',
        costHead: BudgetCostHead.labour,
        paymentMode: PaymentMode.cash,
        voucherNumber: 'PC-202603-701',
        narration: 'Evening overtime snacks for concrete slab casting team',
        verifiedBy: 'Engr. Suresh',
        createdAt: DateTime(2026, 3, 3),
      );

      final pdfBytes = await PdfReceiptService.generatePettyCashVoucher(
        voucher: voucher,
        supervisorName: 'Engr. Rajesh Sharma',
        projectCode: 'PRJ-2026-001',
        projectName: 'Greenfield Luxury Villa Renovation',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      final header = String.fromCharCodes(pdfBytes.sublist(0, 5));
      expect(header, '%PDF-');
    });

    testWidgets('5. PdfPreviewDialog renders cleanly with 0 layout overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1440, 900),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1280,
                height: 800,
                child: PdfPreviewDialog(
                  title: 'Labour Wage Receipt — Raju Mason',
                  pdfBuilder: (format) async => Uint8List.fromList([37, 80, 68, 70, 45]),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(PdfPreviewDialog), findsOneWidget);
      expect(find.text('Labour Wage Receipt — Raju Mason'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
