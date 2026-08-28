import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/deposits/providers/deposit_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class DepositListScreen extends ConsumerWidget {
  const DepositListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depositsAsync = ref.watch(filteredDepositListProvider);
    final totalPaidHeldAsync = ref.watch(totalDepositsPaidHeldProvider);
    final totalReceivedHeldAsync = ref.watch(totalDepositsReceivedHeldProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final filterProject = ref.watch(depositProjectFilterProvider);
    final filterType = ref.watch(depositTypeFilterProvider);
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Deposits',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          totalPaidHeldAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (paidHeld) => Text(
                              'Paid to Govt/Client: ${CurrencyFormatter.format(paidHeld)} (Asset)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Text('•', style: TextStyle(color: Colors.grey)),
                          totalReceivedHeldAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (receivedHeld) => Text(
                              'Received from Clients: ${CurrencyFormatter.format(receivedHeld)} (Liability)',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final deposits = await ref.read(depositListProvider.future);
                    final path = await ExcelExportService.exportDeposits(deposits: deposits);
                    if (path != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deposits exported to Excel: $path'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.table_chart_rounded, size: 18, color: Color(0xFF059669)),
                  label: const Text('Export Excel (.xlsx)', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF059669)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => context.go('/deposits/new'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Record Deposit'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filters
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Type filter
                    SizedBox(
                      width: 280,
                      child: DropdownButtonFormField<DepositType?>(
                        value: filterType,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Type',
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: null,
                              child: Text('All Deposit Types',
                                  overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(
                              value: DepositType.paid,
                              child: Text('Deposits Paid (To Govt/Client)',
                                  overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(
                              value: DepositType.received,
                              child: Text('Deposits Received (From Client)',
                                  overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) => ref
                            .read(depositTypeFilterProvider.notifier)
                            .state = v,
                      ),
                    ),
                    // Project filter
                    projectsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (projects) => SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<int?>(
                          value: filterProject,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Project',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null,
                                child: Text('All Projects',
                                    overflow: TextOverflow.ellipsis)),
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
                    ),
                  ],
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
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Project')),
                    DataColumn(label: Text('Amount'), numeric: true),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Reference')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: deposits.map((dd) {
                    final isPaidType = dd.deposit.depositType == DepositType.paid;
                    return DataRow(cells: [
                      DataCell(Text(
                          DateFormatter.format(dd.transaction.date))),
                      DataCell(_DepositTypeBadge(depositType: dd.deposit.depositType)),
                      DataCell(Text(dd.project.name,
                          overflow: TextOverflow.ellipsis)),
                      DataCell(Text(CurrencyFormatter.format(
                          dd.transaction.amount))),
                      DataCell(_DepositStatusChip(
                          status: dd.deposit.status)),
                      DataCell(Text(dd.deposit.adjustmentReference ?? '—')),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // If Paid to Govt: Action is "Receive Back / Recover"
                            if (isPaidType &&
                                (dd.deposit.status == DepositStatus.held ||
                                 dd.deposit.status == DepositStatus.partiallyAdjusted))
                              _ActionButton(
                                label: 'Receive Back',
                                color: const Color(0xFF059669),
                                onTap: () => _showRecoverDialog(
                                    context, ref, dd),
                              ),

                            // If Received from Client: Actions are "Adjust to Income" or "Refund"
                            if (!isPaidType &&
                                (dd.deposit.status == DepositStatus.held ||
                                 dd.deposit.status == DepositStatus.partiallyAdjusted))
                              _ActionButton(
                                label: 'Adjust',
                                color: Colors.blue.shade700,
                                onTap: () => _showAdjustDialog(
                                    context, ref, dd),
                              ),
                            if (!isPaidType &&
                                dd.deposit.status != DepositStatus.refunded &&
                                dd.deposit.status != DepositStatus.adjusted)
                              _ActionButton(
                                label: 'Refund',
                                color: Colors.red.shade700,
                                onTap: () => _showRefundDialog(
                                    context, ref, dd),
                              ),

                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 16),
                              tooltip: 'Delete Deposit',
                              color: Colors.red.shade700,
                              onPressed: () =>
                                  _deleteDeposit(context, ref, dd),
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

  void _showRecoverDialog(BuildContext context, WidgetRef ref, dynamic dd) {
    final remaining = (dd.transaction.amount - dd.deposit.adjustedAmount).clamp(0.0, double.infinity);
    final amountCtrl = TextEditingController(
      text: remaining > 0 ? remaining.toStringAsFixed(2) : dd.transaction.amount.toStringAsFixed(2),
    );
    final refCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Receive Back Deposit from Govt/Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Original deposit paid: ${CurrencyFormatter.format(dd.transaction.amount)}'
              '${dd.deposit.adjustedAmount > 0 ? " (Already recovered: ${CurrencyFormatter.format(dd.deposit.adjustedAmount)})" : ""}',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: const Text(
                'Receiving back your security deposit increases cash balance. It is NOT income and does NOT affect P&L.',
                style: TextStyle(fontSize: 12, color: Color(0xFF065F46)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Amount Recovered / Received Back (₹)',
                prefixText: '₹ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: refCtrl,
              decoration: const InputDecoration(
                labelText: 'Challan / Refund Order / Cheque Reference',
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
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF059669)),
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx);
              await ref.read(depositRepositoryProvider).recoverDeposit(
                    depositId: dd.deposit.id,
                    projectId: dd.project.id,
                    recoveredAmount: amount,
                    date: DateTime.now(),
                    referenceNo: refCtrl.text.isNotEmpty ? refCtrl.text : null,
                  );
            },
            child: const Text('Confirm Deposit Received Back'),
          ),
        ],
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
        title: const Text('Refund Deposit to Client'),
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

  Future<void> _deleteDeposit(
    BuildContext context,
    WidgetRef ref,
    dynamic dd,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Delete Deposit Record?'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete this deposit record of ${CurrencyFormatter.format(dd.transaction.amount)} for project "${dd.project.name}"?\n\n'
          'This will permanently delete the deposit record and its linked transaction, updating the cash balance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Delete Deposit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(depositRepositoryProvider)
            .deleteDeposit(dd.deposit.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Deposit record deleted successfully.'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting deposit: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}

class _DepositTypeBadge extends StatelessWidget {
  final DepositType depositType;
  const _DepositTypeBadge({required this.depositType});

  @override
  Widget build(BuildContext context) {
    final isPaid = depositType == DepositType.paid;
    return Container(
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
      DepositStatus.recovered => (const Color(0xFF065F46), const Color(0xFFECFDF5)),
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
