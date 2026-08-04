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
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit',
                              onPressed: () =>
                                  context.go('/projects/${p.id}/edit'),
                            ),
                            if (p.status != ProjectStatus.closed)
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                tooltip: 'Close Project',
                                color: theme.colorScheme.error,
                                onPressed: () async {
                                  final confirmed = await ConfirmDialog.show(
                                    context,
                                    title: 'Close Project?',
                                    message:
                                        'Mark "${p.name}" as closed? This cannot be undone.',
                                    confirmLabel: 'Close',
                                  );
                                  if (confirmed) {
                                    await ref
                                        .read(projectRepositoryProvider)
                                        .closeProject(p.id);
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
