import 'package:flutter/material.dart';
import 'package:nex_ledger/core/services/update_service.dart';

class UpdatePromptDialog extends StatelessWidget {
  final AppUpdateInfo updateInfo;
  const UpdatePromptDialog({super.key, required this.updateInfo});

  static Future<void> show(BuildContext context, AppUpdateInfo updateInfo) {
    return showDialog(
      context: context,
      builder: (_) => UpdatePromptDialog(updateInfo: updateInfo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.system_update_alt_rounded,
                color: Color(0xFF4F46E5), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Version Available',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'NexLedger v${updateInfo.latestVersion}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _VersionTag(
                    label: 'Current', version: 'v${updateInfo.currentVersion}'),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                _VersionTag(
                  label: 'Latest',
                  version: 'v${updateInfo.latestVersion}',
                  isNew: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "What's New in this Release:",
              style: theme.textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: SingleChildScrollView(
                child: Text(
                  updateInfo.releaseNotes.isNotEmpty
                      ? updateInfo.releaseNotes
                      : 'Bug fixes and performance improvements.',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.security_rounded,
                    size: 14, color: Color(0xFF059669)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Your local financial data & ledger are 100% preserved during updates.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Remind Me Later'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            UpdateService.instance.openReleasePage(
              updateInfo.downloadUrl ?? updateInfo.htmlUrl,
            );
          },
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Download & Update'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
          ),
        ),
      ],
    );
  }
}

class _VersionTag extends StatelessWidget {
  final String label;
  final String version;
  final bool isNew;
  const _VersionTag(
      {required this.label, required this.version, this.isNew = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isNew
            ? const Color(0xFFECFDF5)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isNew
              ? const Color(0xFFA7F3D0)
              : const Color(0xFFCBD5E1),
        ),
      ),
      child: Text(
        '$label: $version',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isNew ? const Color(0xFF059669) : const Color(0xFF475569),
        ),
      ),
    );
  }
}
