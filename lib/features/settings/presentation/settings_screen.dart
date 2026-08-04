import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nex_ledger/core/database/app_database.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _backing = false;
  String? _lastBackupPath;

  Future<void> _backupDatabase() async {
    setState(() => _backing = true);
    try {
      final destDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose Backup Folder',
      );
      if (destDir == null) {
        setState(() => _backing = false);
        return;
      }

      final sourcePath = await AppDatabase.getDatabasePath();
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('Database file not found at: $sourcePath');
      }

      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-')
          .substring(0, 19);
      final destPath = '$destDir/nex_ledger_backup_$timestamp.db';
      await sourceFile.copy(destPath);

      setState(() => _lastBackupPath = destPath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database backed up to: $destPath'),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _backing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),

            // Backup section
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.backup_outlined,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Backup Database',
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Copy the local SQLite database file to a folder of your choice (USB, cloud drive, etc.).',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'How backup works',
                                  style: theme.textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '1. Click "Choose Folder & Backup"\n'
                              '2. Select a destination folder\n'
                              '3. The file nex_ledger_backup_<timestamp>.db will be copied there\n'
                              '4. Restore by copying the .db file back to the app data directory',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_lastBackupPath != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.green.shade700, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Last backup: $_lastBackupPath',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.green.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _backing ? null : _backupDatabase,
                          icon: _backing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.folder_open_outlined),
                          label: Text(_backing
                              ? 'Backing up...'
                              : 'Choose Folder & Backup'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // App info card
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.account_balance,
                          color: theme.colorScheme.primary, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NexLedger',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'v1.0.0  •  Offline-first Mini ERP',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
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
