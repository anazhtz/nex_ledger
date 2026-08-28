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
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 700;
                final titleCol = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Deposit Ledger',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Track deposits paid to Govt/clients (Assets) and deposits received from clients (Liabilities)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                );
                final exportBtn = FilledButton.icon(
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
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleCol,
                      const SizedBox(height: 12),
                      exportBtn,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: titleCol),
                    const SizedBox(width: 16),
                    exportBtn,
                  ],
                );
              },
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
                  isExpanded: true,
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
                      double totalPaid = 0;
                      double totalPaidHeld = 0;
                      double totalReceived = 0;
                      double totalReceivedHeld = 0;

                      for (final d in deposits) {
                        final isPaid = d.deposit.depositType == DepositType.paid;
                        final amount = d.transaction.amount;
                        final isHeld = d.deposit.status == DepositStatus.held ||
                            d.deposit.status == DepositStatus.partiallyAdjusted;
                        final remaining = (amount - d.deposit.adjustedAmount).clamp(0.0, double.infinity);

                        if (isPaid) {
                          totalPaid += amount;
                          if (isHeld) totalPaidHeld += remaining;
                        } else {
                          totalReceived += amount;
                          if (isHeld) totalReceivedHeld += remaining;
                        }
                      }

                      return Column(
                        children: [
                          // Summary row (Responsive)
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isCompact = constraints.maxWidth < 750;

                              final s1 = _SummaryCard(
                                label: 'Deposits Paid to Govt (Asset)',
                                value: totalPaid,
                                subtitle: 'Held with Govt: ${CurrencyFormatter.format(totalPaidHeld)}',
                                color: Colors.blue.shade700,
                              );
                              final s2 = _SummaryCard(
                                label: 'Deposits Recovered Back',
                                value: totalPaid - totalPaidHeld,
                                subtitle: 'Received into bank/cash',
                                color: const Color(0xFF059669),
                              );
                              final s3 = _SummaryCard(
                                label: 'Client Deposits Received (Liability)',
                                value: totalReceived,
                                subtitle: 'Liability Held: ${CurrencyFormatter.format(totalReceivedHeld)}',
                                color: Colors.orange.shade700,
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
                                DataColumn(label: Text('Type')),
                                DataColumn(label: Text('Project')),
                                DataColumn(
                                    label: Text('Amount'), numeric: true),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Reference')),
                                DataColumn(label: Text('Narration')),
                              ],
                              rows: deposits.map((dd) {
                                final isPaid = dd.deposit.depositType == DepositType.paid;
                                return DataRow(cells: [
                                  DataCell(Text(DateFormatter.format(
                                      dd.transaction.date))),
                                  DataCell(Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isPaid ? Colors.blue.shade50 : Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isPaid ? Colors.blue.shade200 : Colors.orange.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      isPaid ? 'Paid to Govt' : 'From Client',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isPaid ? Colors.blue.shade800 : Colors.orange.shade900,
                                      ),
                                    ),
                                  )),
                                  DataCell(Text(dd.project.name,
                                      overflow: TextOverflow.ellipsis)),
                                  DataCell(Text(
                                    CurrencyFormatter.format(
                                        dd.transaction.amount),
                                    style: TextStyle(
                                        color: isPaid ? Colors.blue.shade700 : Colors.orange.shade700,
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
  final String? subtitle;
  final Color color;
  const _SummaryCard({
    required this.label,
    required this.value,
    this.subtitle,
    required this.color,
  });

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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
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
      DepositStatus.recovered => const Color(0xFF059669),
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
