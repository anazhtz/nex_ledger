import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfPreviewDialog extends StatelessWidget {
  final String title;
  final Future<Uint8List> Function(PdfPageFormat format) pdfBuilder;
  final String? defaultFileName;

  const PdfPreviewDialog({
    super.key,
    required this.title,
    required this.pdfBuilder,
    this.defaultFileName,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required Future<Uint8List> Function(PdfPageFormat format) pdfBuilder,
    String? defaultFileName,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => PdfPreviewDialog(
        title: title,
        pdfBuilder: pdfBuilder,
        defaultFileName: defaultFileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 850.w,
        height: 720.h,
        child: Column(
          children: [
            // Dialog Top Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded,
                          color: Color(0xFF38BDF8), size: 20),
                      SizedBox(width: 10.w),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // PDF Viewer Area
            Expanded(
              child: PdfPreview(
                build: pdfBuilder,
                maxPageWidth: 700,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                pdfFileName: defaultFileName ?? 'receipt.pdf',
                previewPageMargin: const EdgeInsets.all(16),
                loadingWidget: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Generating printable PDF document...'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
