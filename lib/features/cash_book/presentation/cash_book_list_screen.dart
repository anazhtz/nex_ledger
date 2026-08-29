import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/cash_book/providers/cash_book_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class CashBookListScreen extends ConsumerWidget {
  const CashBookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(cashBookListProvider);
    final cashBalanceAsync = ref.watch(cashBalanceProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final filter = ref.watch(cashBookFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Wrap(
              spacing: 16,
              runSpacing: 12,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash Book Ledger',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    cashBalanceAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (bal) => Text(
                        'Total Cash Flow Balance: ${CurrencyFormatter.format(bal)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: bal >= 0
                              ? const Color(0xFF047857)
                              : const Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final txns = await ref.read(cashBookListProvider.future);
                        final path = await ExcelExportService.exportCashBook(transactions: txns);
                        if (path != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cash Book exported to Excel: $path'),
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
                    FilledButton.icon(
                      onPressed: () => context.go('/cash-book/new'),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add Entry'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter bar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: projectsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (projects) => Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<int?>(
                          value: filter.projectId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Project',
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
                              .read(cashBookFilterProvider.notifier)
                              .state = filter.copyWith(
                            projectId: v,
                            clearProject: v == null,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<TransactionType?>(
                          value: filter.types?.firstOrNull,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            isDense: true,
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All Types')),
                            ...TransactionType.values.map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.displayName,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: (v) => ref
                              .read(cashBookFilterProvider.notifier)
                              .state = filter.copyWith(
                            types: v != null ? [v] : null,
                            clearTypes: v == null,
                          ),
                        ),
                      ),
                      if (filter.projectId != null ||
                          (filter.types?.isNotEmpty ?? false))
                        TextButton.icon(
                          onPressed: () => ref
                              .read(cashBookFilterProvider.notifier)
                              .state = CashBookFilter(),
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear Filters'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Transactions table
            Expanded(
              child: transactionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (txns) => DataTableCard(
                  emptyMessage: 'No transactions found.',
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Project')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Narration')),
                    DataColumn(label: Text('Ref No.')),
                    DataColumn(label: Text('Debit (−)'), numeric: true),
                    DataColumn(label: Text('Credit (+)'), numeric: true),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: txns.map((tw) {
                    final isDebit = tw.transaction.type.isDebit;
                    final amount = tw.transaction.amount;
                    final isDirectCashBook =
                        tw.transaction.type == TransactionType.income ||
                            tw.transaction.type == TransactionType.expense;

                    return DataRow(cells: [
                      DataCell(Text(DateFormatter.format(tw.transaction.date))),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 160.w),
                          child: Tooltip(
                            message: '${tw.project.code} — ${tw.project.name}',
                            child: Text(
                              tw.project.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        _TypeBadge(type: tw.transaction.type),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200.w),
                          child: Tooltip(
                            message: tw.transaction.narration ?? '',
                            child: Text(
                              tw.transaction.narration ?? '—',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 100.w),
                          child: Text(
                            tw.transaction.referenceNo ?? '—',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      DataCell(
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            isDebit ? CurrencyFormatter.format(amount) : '—',
                            style: isDebit
                                ? TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.w600)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            !isDebit ? CurrencyFormatter.format(amount) : '—',
                            style: !isDebit
                                ? TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600)
                                : null,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDirectCashBook)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 17),
                                tooltip: 'Edit Entry',
                                onPressed: () => context
                                    .go('/cash-book/${tw.transaction.id}/edit'),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 17),
                              tooltip: 'Delete Entry',
                              color: theme.colorScheme.error,
                              onPressed: () =>
                                  _deleteTransaction(context, ref, tw),
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

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    TransactionWithProject tw,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Delete Cash Entry?'),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete this ${tw.transaction.type.displayName} entry of ${CurrencyFormatter.format(tw.transaction.amount)} for project "${tw.project.name}"?\n\n'
          'This will remove the transaction and update your cash balance.',
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
            child: const Text('Delete Entry'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref
            .read(cashBookRepositoryProvider)
            .deleteTransaction(tw.transaction.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Transaction deleted successfully.'),
            backgroundColor: Color(0xFF059669),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting transaction: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
}

class _TypeBadge extends StatelessWidget {
  final TransactionType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (type) {
      TransactionType.income => (Colors.green.shade700, Colors.green.shade50),
      TransactionType.expense => (Colors.red.shade700, Colors.red.shade50),
      TransactionType.purchase => (
          Colors.orange.shade700,
          Colors.orange.shade50
        ),
      TransactionType.labourPayment => (
          Colors.purple.shade700,
          Colors.purple.shade50
        ),
      TransactionType.deposit => (Colors.blue.shade700, Colors.blue.shade50),
      TransactionType.depositRefund => (
          Colors.teal.shade700,
          Colors.teal.shade50
        ),
      TransactionType.depositAdjustment => (
          Colors.indigo.shade700,
          Colors.indigo.shade50
        ),
      TransactionType.depositPaid => (
          Colors.blueGrey.shade800,
          Colors.blueGrey.shade50
        ),
      TransactionType.depositRecovery => (
          const Color(0xFF059669),
          const Color(0xFFECFDF5)
        ),
      TransactionType.purchasePayment => (
          Colors.brown.shade700,
          Colors.brown.shade50
        ),
      TransactionType.stockAllocation => (
          Colors.deepOrange.shade700,
          Colors.deepOrange.shade50
        ),
      TransactionType.ownerCapital => (
          const Color(0xFF0D9488),
          const Color(0xFFF0FDFA)
        ),
      TransactionType.drawings => (
          const Color(0xFFE11D48),
          const Color(0xFFFFF1F2)
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.displayName,
        style:
            TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
