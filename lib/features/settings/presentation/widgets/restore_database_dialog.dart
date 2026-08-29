import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nex_ledger/core/database/database_provider.dart';
import 'package:nex_ledger/core/services/backup_restore_service.dart';
import 'package:nex_ledger/features/bank_accounts/providers/bank_account_providers.dart';
import 'package:nex_ledger/features/cash_book/providers/cash_book_providers.dart';
import 'package:nex_ledger/features/deposits/providers/deposit_providers.dart';
import 'package:nex_ledger/features/expense_categories/providers/expense_category_providers.dart';
import 'package:nex_ledger/features/labour/providers/labour_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/purchase/providers/purchase_providers.dart';

class RestoreDatabaseDialog extends ConsumerStatefulWidget {
  const RestoreDatabaseDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RestoreDatabaseDialog(),
    );
  }

  @override
  ConsumerState<RestoreDatabaseDialog> createState() => _RestoreDatabaseDialogState();
}

class _RestoreDatabaseDialogState extends ConsumerState<RestoreDatabaseDialog> {
  BackupFileInfo? _selectedFileInfo;
  bool _isInspecting = false;
  bool _isRestoring = false;
  String? _errorMessage;

  Future<void> _pickAndInspectFile() async {
    setState(() {
      _isInspecting = true;
      _errorMessage = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select NexLedger Database Backup (.db or .sqlite) to Restore',
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite', 'sqlite3', 'bak'],
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _isInspecting = false);
        return;
      }

      final filePath = result.files.single.path!;
      final info = await DatabaseBackupRestoreService.inspectBackupFile(filePath);

      setState(() {
        _selectedFileInfo = info;
        if (!info.isValidSqlite) {
          _errorMessage =
              'The selected file "${info.fileName}" is not a valid SQLite database.\n'
              'Please select a valid .db or .sqlite backup file created by NexLedger.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inspecting selected file: $e';
      });
    } finally {
      if (mounted) setState(() => _isInspecting = false);
    }
  }

  Future<void> _executeRestore() async {
    if (_selectedFileInfo == null || !_selectedFileInfo!.isValidSqlite) return;

    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      final currentDb = ref.read(appDatabaseProvider);
      final result = await DatabaseBackupRestoreService.restoreDatabase(
        sourceBackupPath: _selectedFileInfo!.path,
        currentDb: currentDb,
      );

      // Invalidate the root database provider to disconnect and reconnect fresh instance
      ref.invalidate(appDatabaseProvider);

      // Invalidate primary module stream providers for live reactive refresh
      ref.invalidate(projectListProvider);
      ref.invalidate(cashBookListProvider);
      ref.invalidate(cashBalanceProvider);
      ref.invalidate(bankAccountsListProvider);
      ref.invalidate(vendorListProvider);
      ref.invalidate(purchaseListProvider);
      ref.invalidate(workerListProvider);
      ref.invalidate(depositListProvider);
      ref.invalidate(expenseCategoryListProvider);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    '✓ Database successfully restored from "${_selectedFileInfo!.fileName}" (${_selectedFileInfo!.formattedSize})!\n'
                    'All project ledgers and financial records are refreshed.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Restore Failed: $e';
          _isRestoring = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 580.w),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.restore_page_rounded,
                      color: const Color(0xFF4F46E5),
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restore Database from Backup',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Replace current database records with a previous .db or .sqlite backup',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!_isRestoring)
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                ],
              ),
              SizedBox(height: 18.h),

              // File Selection Box
              if (_selectedFileInfo == null) ...[
                InkWell(
                  onTap: _isInspecting || _isRestoring ? null : _pickAndInspectFile,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFCBD5E1),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.file_upload_outlined,
                          size: 36.sp,
                          color: const Color(0xFF6366F1),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          _isInspecting
                              ? 'Inspecting Selected Backup File...'
                              : 'Click to Choose Backup File (.db / .sqlite)',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Compatible with Windows & macOS NexLedger backup files',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // File Inspected Card
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: _selectedFileInfo!.isValidSqlite
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: _selectedFileInfo!.isValidSqlite
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _selectedFileInfo!.isValidSqlite
                                ? Icons.verified_rounded
                                : Icons.error_outline_rounded,
                            color: _selectedFileInfo!.isValidSqlite
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              _selectedFileInfo!.fileName,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!_isRestoring)
                            TextButton.icon(
                              onPressed: _pickAndInspectFile,
                              icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                              label: const Text('Change File'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            'Size: ${_selectedFileInfo!.formattedSize}',
                            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF475569)),
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            'Modified: ${_selectedFileInfo!.formattedDate}',
                            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF475569)),
                          ),
                        ],
                      ),
                      if (_selectedFileInfo!.isValidSqlite) ...[
                        SizedBox(height: 6.h),
                        Text(
                          '✓ SQLite Database Signature Validated',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Error Banner
              if (_errorMessage != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: const Color(0xFFDC2626), size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF991B1B)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Safety Warning
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: const Color(0xFFD97706), size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Safety Guarantee: An emergency snapshot of your current database will be archived in the app data directory before replacement.',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isRestoring ? null : () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: 10.w),
                  FilledButton.icon(
                    onPressed: _selectedFileInfo == null ||
                            !_selectedFileInfo!.isValidSqlite ||
                            _isRestoring
                        ? null
                        : _executeRestore,
                    icon: _isRestoring
                        ? SizedBox(
                            width: 14.w,
                            height: 14.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.restore_rounded, size: 16),
                    label: Text(_isRestoring ? 'Restoring Database...' : 'Confirm & Restore'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
