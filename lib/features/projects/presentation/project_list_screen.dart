import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/confirm_dialog.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projects',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Manage projects and overhead entries',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.go('/projects/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Project'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: projectsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (projects) => DataTableCard(
                  emptyMessage: 'No projects yet. Create your first project.',
                  columns: const [
                    DataColumn(label: Text('Code')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Client')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Start Date')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: projects.map((p) {
                    return DataRow(cells: [
                      DataCell(
                        Text(
                          p.code,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataCell(Text(p.name)),
                      DataCell(Text(p.clientName ?? '—')),
                      DataCell(Text(p.type.displayName)),
                      DataCell(_StatusChip(status: p.status)),
                      DataCell(
                          Text(DateFormatter.format(p.startDate))),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.inventory_2_outlined, size: 18),
                              tooltip: 'Material Register',
                              color: const Color(0xFF4F46E5),
                              onPressed: () =>
                                  context.go('/materials?projectId=${p.id}'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit Project',
                              onPressed: () =>
                                  context.go('/projects/${p.id}/edit'),
                            ),
                            if (p.status != ProjectStatus.closed)
                              IconButton(
                                icon: const Icon(Icons.archive_outlined, size: 18),
                                tooltip: 'Close Project',
                                color: Colors.orange.shade700,
                                onPressed: () async {
                                  final confirmed = await ConfirmDialog.show(
                                    context,
                                    title: 'Close Project?',
                                    message:
                                        'Mark "${p.name}" as closed? Active work will be stopped.',
                                    confirmLabel: 'Close Project',
                                  );
                                  if (confirmed) {
                                    await ref
                                        .read(projectRepositoryProvider)
                                        .closeProject(p.id);
                                  }
                                },
                              ),
                            if (p.code != 'ADMIN-OVH')
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                tooltip: 'Delete Project',
                                color: theme.colorScheme.error,
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Row(
                                        children: [
                                          Icon(Icons.delete_forever_rounded, color: Colors.red.shade700),
                                          const SizedBox(width: 8),
                                          const Text('Delete Project?'),
                                        ],
                                      ),
                                      content: Text(
                                        'Are you sure you want to permanently delete "${p.name}" (${p.code})?\n\n'
                                        'All transactions, purchases, and records linked to this project will be removed.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          style: FilledButton.styleFrom(
                                              backgroundColor: Colors.red.shade700),
                                          child: const Text('Delete Permanently'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    try {
                                      await ref
                                          .read(projectRepositoryProvider)
                                          .deleteProject(p.id);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('✓ Project "${p.name}" deleted.'),
                                          backgroundColor: const Color(0xFF059669),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red.shade700,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ProjectStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ProjectStatus.active => Colors.green,
      ProjectStatus.onHold => Colors.orange,
      ProjectStatus.closed => Colors.grey,
    };
    return Chip(
      label: Text(status.displayName),
      labelStyle: TextStyle(
          color: color.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w500),
      backgroundColor: color.shade50,
      side: BorderSide(color: color.shade200),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
