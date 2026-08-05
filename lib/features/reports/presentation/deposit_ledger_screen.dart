import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/deposits/providers/deposit_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class DepositLedgerScreen extends ConsumerStatefulWidget {
  const DepositLedgerScreen({super.key});

  @override
  ConsumerState<DepositLedgerScreen> createState() =>
      _DepositLedgerScreenState();
}

class _DepositLedgerScreenState extends ConsumerState<DepositLedgerScreen> {
  int? _selectedProject;

  @override
  void initState() {
    super.initState();
    _selectedProject = ref.read(selectedProjectIdProvider);
  }

  @override
  Widget build(BuildContext context) {
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
                      'Deposit Ledger',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Track received, adjusted, and refunded deposits per project',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () async {
                    final deposits = await ref.read(depositListProvider.future);
                    final path = await ExcelExportService.exportDeposits(deposits: deposits);
                    if (path != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deposit Ledger exported to Excel: $path'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.table_chart_rounded, size: 18),
                  label: const Text('Export Deposits (.xlsx)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Project selector
            projectsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (projects) => SizedBox(
                width: 300,
                child: DropdownButtonFormField<int?>(
                  value: _selectedProject,
                  decoration:
                      const InputDecoration(labelText: 'Select Project'),
                  items: [
                    const DropdownMenuItem(
                        value: null,
                        child: Text('— Show all projects —')),
                    ...projects.map(
                      (p) => DropdownMenuItem(
                        value: p.id,
                        child: Text('${p.code}  —  ${p.name}',
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedProject = v);
                    ref
                        .read(depositProjectFilterProvider.notifier)
                        .state = v;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final depositsAsync =
                      ref.watch(filteredDepositListProvider);
                  return depositsAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (deposits) {
                      double totalReceived = 0;
                      double totalHeld = 0;

                      for (final d in deposits) {
                        totalReceived += d.transaction.amount;
                        if (d.deposit.status == DepositStatus.held ||
                            d.deposit.status ==
                                DepositStatus.partiallyAdjusted) {
                          totalHeld += d.transaction.amount;
                        }
                      }

                      return Column(
                        children: [
                          // Summary row (Responsive)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 750;

                              final s1 = _SummaryCard(
                                label: 'Total Received',
                                value: totalReceived,
                                color: Colors.blue.shade700,
                              );
                              final s2 = _SummaryCard(
                                label: 'Currently Held',
                                value: totalHeld,
                                color: Colors.orange.shade700,
                              );
                              final s3 = _SummaryCard(
                                label: 'Adjusted / Released',
                                value: totalReceived - totalHeld,
                                color: Colors.green.shade700,
                              );

                              if (isCompact) {
                                return Column(
                                  children: [
                                    s1,
                                    const SizedBox(height: 8),
                                    s2,
                                    const SizedBox(height: 8),
                                    s3,
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: s1),
                                  const SizedBox(width: 12),
                                  Expanded(child: s2),
                                  const SizedBox(width: 12),
                                  Expanded(child: s3),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: DataTableCard(
                              emptyMessage:
                                  'No deposits found for this filter.',
                              columns: const [
                                DataColumn(label: Text('Date')),
                                DataColumn(label: Text('Project')),
                                DataColumn(
                                    label: Text('Received'), numeric: true),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Reference')),
                                DataColumn(label: Text('Narration')),
                              ],
                              rows: deposits.map((dd) {
                                return DataRow(cells: [
                                  DataCell(Text(DateFormatter.format(
                                      dd.transaction.date))),
                                  DataCell(Text(dd.project.name,
                                      overflow: TextOverflow.ellipsis)),
                                  DataCell(Text(
                                    CurrencyFormatter.format(
                                        dd.transaction.amount),
                                    style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500),
                                  )),
                                  DataCell(_StatusText(
                                      status: dd.deposit.status)),
                                  DataCell(Text(
                                      dd.deposit.adjustmentReference ??
                                          '—')),
                                  DataCell(Text(
                                      dd.transaction.narration ?? '—')),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _SummaryCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Text(
              CurrencyFormatter.format(value),
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  final DepositStatus status;
  const _StatusText({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      DepositStatus.held => Colors.orange.shade700,
      DepositStatus.adjusted => Colors.green.shade700,
      DepositStatus.partiallyAdjusted => Colors.blue.shade700,
      DepositStatus.refunded => Colors.grey.shade600,
    };
    return Text(
      status.displayName,
      style: TextStyle(color: color, fontWeight: FontWeight.w500),
    );
  }
}
