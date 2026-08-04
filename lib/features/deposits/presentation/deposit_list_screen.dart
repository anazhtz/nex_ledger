import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/deposits/providers/deposit_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class DepositListScreen extends ConsumerWidget {
  const DepositListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depositsAsync = ref.watch(filteredDepositListProvider);
    final totalHeldAsync = ref.watch(totalDepositsHeldProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final filterProject = ref.watch(depositProjectFilterProvider);
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
                      'Deposits',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    totalHeldAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (held) => Text(
                        'Total Held: ${CurrencyFormatter.format(held)}  •  Liability',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => context.go('/deposits/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Record Deposit'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (projects) => Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<int?>(
                          value: filterProject,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Project',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All Projects')),
                            ...projects.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.name,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: (v) => ref
                              .read(depositProjectFilterProvider.notifier)
                              .state = v,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: depositsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (deposits) => DataTableCard(
                  emptyMessage:
                      'No deposits recorded. Click "Record Deposit" to add one.',
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Project')),
                    DataColumn(label: Text('Amount'), numeric: true),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Reference')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: deposits.map((dd) {
                    return DataRow(cells: [
                      DataCell(Text(
                          DateFormatter.format(dd.transaction.date))),
                      DataCell(Text(dd.project.name,
                          overflow: TextOverflow.ellipsis)),
                      DataCell(Text(CurrencyFormatter.format(
                          dd.transaction.amount))),
                      DataCell(_DepositStatusChip(
                          status: dd.deposit.status)),
                      DataCell(Text(dd.deposit.adjustmentReference ?? '—')),
                      DataCell(
                        Row(
                          children: [
                            if (dd.deposit.status == DepositStatus.held ||
                                dd.deposit.status ==
                                    DepositStatus.partiallyAdjusted)
                              _ActionButton(
                                label: 'Adjust',
                                color: Colors.blue.shade700,
                                onTap: () => _showAdjustDialog(
                                    context, ref, dd),
                              ),
                            if (dd.deposit.status != DepositStatus.refunded)
                              _ActionButton(
                                label: 'Refund',
                                color: Colors.red.shade700,
                                onTap: () => _showRefundDialog(
                                    context, ref, dd),
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

  void _showAdjustDialog(BuildContext context, WidgetRef ref, dynamic dd) {
    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Deposit to Income'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Original deposit: ${CurrencyFormatter.format(dd.transaction.amount)}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount to adjust (₹)',
                prefixText: '₹ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: refCtrl,
              decoration: const InputDecoration(
                labelText: 'Work Order / Invoice Reference',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx);
              await ref.read(depositRepositoryProvider).adjustDepositToIncome(
                    depositId: dd.deposit.id,
                    projectId: dd.project.id,
                    adjustedAmount: amount,
                    date: DateTime.now(),
                    isFullyAdjusted: amount >= dd.transaction.amount,
                    adjustmentReference:
                        refCtrl.text.isNotEmpty ? refCtrl.text : null,
                  );
            },
            child: const Text('Adjust to Income'),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(BuildContext context, WidgetRef ref, dynamic dd) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refund Deposit'),
        content: Text(
          'Refund ${CurrencyFormatter.format(dd.transaction.amount)} to the client?\n\n'
          'This will decrease cash balance. P&L will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(depositRepositoryProvider).refundDeposit(
                    depositId: dd.deposit.id,
                    projectId: dd.project.id,
                    refundAmount: dd.transaction.amount,
                    date: DateTime.now(),
                  );
            },
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );
  }
}

class _DepositStatusChip extends StatelessWidget {
  final DepositStatus status;
  const _DepositStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      DepositStatus.held => (Colors.orange.shade800, Colors.orange.shade50),
      DepositStatus.adjusted => (Colors.green.shade700, Colors.green.shade50),
      DepositStatus.partiallyAdjusted => (Colors.blue.shade700, Colors.blue.shade50),
      DepositStatus.refunded => (Colors.grey.shade700, Colors.grey.shade100),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          textStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
