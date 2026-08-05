import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/features/auth/providers/auth_provider.dart';
import 'package:nex_ledger/features/expense_categories/providers/expense_category_providers.dart';
import 'package:path_provider/path_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _backing = false;
  String? _lastBackupPath;

  /// Backup database to a selected folder or fallback directory
  Future<void> _backupDatabase({bool isQuick = false}) async {
    setState(() => _backing = true);
    try {
      String? destDir;

      if (isQuick) {
        if (Platform.isMacOS) {
          final home = Platform.environment['HOME'] ?? '';
          final realHome = home.split('/Library/Containers').first;
          final userDownloads = '$realHome/Downloads';
          if (Directory(userDownloads).existsSync()) {
            destDir = userDownloads;
          }
        }
        destDir ??= (await getDownloadsDirectory())?.path;
        destDir ??= (await getApplicationDocumentsDirectory())?.path;
      } else {
        destDir = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select Destination Folder for NexLedger Backup',
        );

        if (destDir == null) {
          setState(() => _backing = false);
          return;
        }
      }

      final sourcePath = await AppDatabase.getDatabasePath();
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Database file not found at: $sourcePath');
      }

      final now = DateTime.now();
      final timestamp =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}';
      final destPath = '$destDir/nex_ledger_backup_$timestamp.db';
      await sourceFile.copy(destPath);

      setState(() => _lastBackupPath = destPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text('Database successfully backed up to:\n$destPath'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _backing = false);
    }
  }

  /// Restore/Import database from a selected .db file (e.g. from colleague)
  Future<void> _restoreDatabase() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select NexLedger Backup Database (.db or .sqlite) to Import',
      type: FileType.custom,
      allowedExtensions: ['db', 'sqlite'],
    );

    if (result == null || result.files.single.path == null) return;
    final selectedFilePath = result.files.single.path!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEAB308)),
            SizedBox(width: 10),
            Text('Restore / Import Database?'),
          ],
        ),
        content: const Text(
          'Restoring this backup will replace your current local database with your colleague\'s financial records. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Yes, Import & Replace'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _backing = true);
    try {
      final destPath = await AppDatabase.getDatabasePath();
      final backupFile = File(selectedFilePath);
      final destFile = File(destPath);

      if (!await backupFile.exists()) {
        throw Exception('Selected backup file does not exist.');
      }

      await backupFile.copy(destPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database successfully restored! Restart app to load updated records.'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _backing = false);
    }
  }

  void _showChangePinDialog() {
    final oldPinCtrl = TextEditingController();
    final newPinCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: Color(0xFF4F46E5)),
            SizedBox(width: 10),
            Text('Change Security PIN'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Current Security PIN',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Security PIN',
                prefixIcon: Icon(Icons.password_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (oldPinCtrl.text.isEmpty || newPinCtrl.text.isEmpty) return;
              final success = await ref
                  .read(authProvider.notifier)
                  .changePin(oldPinCtrl.text, newPinCtrl.text);

              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Security PIN successfully updated!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect current PIN. Change failed.'),
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  );
                }
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 680.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings & Security',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Manage application security, master PIN, and database backups',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 20.h),

                // Master Security PIN Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.shield_rounded,
                                color: const Color(0xFF4F46E5),
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'App Security & Master PIN',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Protected with SHA-256 local encrypted PIN lock',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: _showChangePinDialog,
                              icon: const Icon(Icons.key_rounded, size: 16),
                              label: const Text('Change PIN'),
                            ),
                            SizedBox(width: 8.w),
                            FilledButton.icon(
                              onPressed: () {
                                ref.read(authProvider.notifier).lock();
                                context.go('/login');
                              },
                              icon: const Icon(Icons.lock_rounded, size: 16),
                              label: const Text('Lock App'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Backup Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.backup_rounded,
                                color: const Color(0xFF4F46E5),
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Database Backup & Recovery',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Export local SQLite database to external USB, cloud drive, or Downloads folder',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // Instructions
                        Container(
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 16.sp,
                                    color: const Color(0xFF475569),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'How Backup Works:',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '• Click "Choose Folder & Backup" to select any directory.\n'
                                '• Or click "Quick Backup to Downloads" for 1-click export.\n'
                                '• A timestamped .db backup file (nex_ledger_backup_*.db) will be created.\n'
                                '• To restore data, copy the .db file back to your app data folder.',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF475569),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_lastBackupPath != null) ...[
                          SizedBox(height: 14.h),
                          Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: const Color(0xFF059669), size: 18.sp),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    'Last Exported File: $_lastBackupPath',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF047857),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 20.h),

                        // Backup & Restore Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _backing ? null : () => _backupDatabase(isQuick: false),
                                icon: _backing
                                    ? SizedBox(
                                        width: 16.w,
                                        height: 16.h,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Icon(Icons.folder_open_rounded, size: 18.sp),
                                label: Text(_backing ? 'Exporting...' : 'Export Backup Folder'),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _backing ? null : () => _backupDatabase(isQuick: true),
                                icon: Icon(Icons.download_for_offline_rounded, size: 18.sp),
                                label: const Text('Quick Export (Downloads)'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _backing ? null : _restoreDatabase,
                                icon: Icon(Icons.upload_file_rounded, size: 18.sp, color: const Color(0xFF4F46E5)),
                                label: const Text('Import / Restore (.db)', style: TextStyle(color: Color(0xFF4F46E5))),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF6366F1)),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // System Info Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.account_balance_rounded,
                            color: const Color(0xFF4F46E5),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NexLedger Mini ERP',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'v1.0.0  •  Local SQLite Engine  •  SHA-256 PIN Security',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Expense Categories Management Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.label_rounded,
                                color: const Color(0xFFEA580C),
                                size: 22.sp,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expense Categories',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    'Manage tags for cash book expense entries. Built-in categories cannot be deleted.',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: () => _showAddCategoryDialog(context),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add Category'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFEA580C),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Consumer(
                          builder: (context, ref, _) {
                            final categoriesAsync =
                                ref.watch(expenseCategoryListProvider);
                            return categoriesAsync.when(
                              loading: () =>
                                  const LinearProgressIndicator(),
                              error: (e, _) =>
                                  Text('Error loading categories: $e'),
                              data: (categories) {
                                // Group by groupName
                                final grouped =
                                    <String, List<ExpenseCategory>>{};
                                for (final c in categories) {
                                  grouped
                                      .putIfAbsent(c.groupName, () => [])
                                      .add(c);
                                }
                                return Column(
                                  children: grouped.entries.map((entry) {
                                    return _CategoryGroupTile(
                                      groupName: entry.key,
                                      categories: entry.value,
                                      onDelete: (cat) =>
                                          _deleteCategory(context, ref, cat),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final groupCtrl = TextEditingController();
    final subCtrl = TextEditingController();

    // Predefined group options
    const groups = [
      'Site & Project Expenses',
      'Office & Administrative',
      'Employee Expenses',
      'Vehicle Expenses',
      'Financial & Legal',
      'Marketing & Sales',
      'Miscellaneous',
    ];
    String? selectedGroup;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Row(
            children: [
              Icon(Icons.add_rounded, color: Color(0xFFEA580C)),
              SizedBox(width: 8),
              Text('Add Custom Category'),
            ],
          ),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Group — pick existing or type new
                DropdownButtonFormField<String>(
                  value: selectedGroup,
                  decoration: const InputDecoration(
                      labelText: 'Group', prefixIcon: Icon(Icons.folder_outlined)),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('— Select or type below —')),
                    ...groups.map((g) =>
                        DropdownMenuItem(value: g, child: Text(g))),
                  ],
                  onChanged: (v) {
                    setDialogState(() {
                      selectedGroup = v;
                      if (v != null) groupCtrl.text = v;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: groupCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Group Name (or type custom)',
                    prefixIcon: Icon(Icons.folder_special_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Sub-Category Name *',
                    prefixIcon: Icon(Icons.label_outline_rounded),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final group = groupCtrl.text.trim();
                final sub = subCtrl.text.trim();
                if (group.isEmpty || sub.isEmpty) return;
                await ref
                    .read(expenseCategoryRepositoryProvider)
                    .addCustomCategory(groupName: group, subCategory: sub);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Custom category added!'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEA580C)),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(
      BuildContext context, WidgetRef ref, ExpenseCategory cat) async {
    if (cat.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Built-in categories cannot be deleted.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category?'),
        content:
            Text('Remove "${cat.subCategory}" from "${cat.groupName}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(expenseCategoryRepositoryProvider)
          .deleteCustomCategory(cat.id);
    }
  }
}

class _CategoryGroupTile extends StatefulWidget {
  final String groupName;
  final List<ExpenseCategory> categories;
  final void Function(ExpenseCategory) onDelete;
  const _CategoryGroupTile({
    required this.groupName,
    required this.categories,
    required this.onDelete,
  });

  @override
  State<_CategoryGroupTile> createState() => _CategoryGroupTileState();
}

class _CategoryGroupTileState extends State<_CategoryGroupTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: const Color(0xFFEA580C),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.groupName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Text(
                    '${widget.categories.length}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFEA580C),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          ...widget.categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.subdirectory_arrow_right_rounded,
                      size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    cat.subCategory,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: const Color(0xFF475569)),
                  ),
                  if (cat.isDefault) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('built-in',
                          style: TextStyle(
                              fontSize: 9, color: Color(0xFF64748B))),
                    ),
                  ],
                  const Spacer(),
                  if (!cat.isDefault)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 16, color: Color(0xFFEF4444)),
                      onPressed: () => widget.onDelete(cat),
                      tooltip: 'Delete',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                ],
              ),
            ),
          ),
        const Divider(height: 8),
      ],
    );
  }
}
