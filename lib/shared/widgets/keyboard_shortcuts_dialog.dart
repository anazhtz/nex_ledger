import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A modern dialog showing all NexLedger keyboard shortcuts.
class KeyboardShortcutsDialog extends StatelessWidget {
  const KeyboardShortcutsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const KeyboardShortcutsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.keyboard_rounded,
              color: const Color(0xFF4F46E5),
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NexLedger Keyboard Shortcuts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Quick key commands for high-speed accounting',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 580.w,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCategoryHeader('⚡ Quick Entry Creation'),
              _buildShortcutRow('Alt + N / Cmd + N', 'New Cash Book Entry'),
              _buildShortcutRow('Alt + P', 'New Purchase Entry'),
              _buildShortcutRow('Alt + A', 'Labour Daily Attendance'),
              _buildShortcutRow('Alt + W', 'Record Labour Pay'),
              _buildShortcutRow('Alt + J', 'Create New Project'),
              SizedBox(height: 16.h),
              _buildCategoryHeader('🧭 Gateway Navigation'),
              _buildShortcutRow('Alt + D', 'Go to Dashboard'),
              _buildShortcutRow('Alt + C', 'Go to Cash Book Ledger'),
              _buildShortcutRow('Alt + R', 'Go to Reports & P&L'),
              _buildShortcutRow('Alt + S', 'Go to Settings'),
              _buildShortcutRow('Ctrl + L / Cmd + L', 'Lock Financial Ledger (PIN Lock)'),
              SizedBox(height: 16.h),
              _buildCategoryHeader('📝 Form Commands'),
              _buildShortcutRow('Ctrl + Enter / Cmd + Enter', 'Save & Submit Form immediately'),
              _buildShortcutRow('Escape', 'Cancel / Close Modal'),
              _buildShortcutRow('Tab / Shift + Tab', 'Jump Next / Previous Field'),
              _buildShortcutRow('F1', 'Open Shortcuts Guide Modal'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close (Esc)'),
        ),
      ],
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4F46E5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildShortcutRow(String keys, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Text(
              keys,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
