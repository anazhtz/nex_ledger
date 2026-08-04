import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash Book',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    cashBalanceAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (bal) => Text(
                        'Balance: ${CurrencyFormatter.format(bal)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: bal >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
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
                  label: const Text('Export Excel (.xlsx)', style: TextStyle(color: Color(0xFF059669))),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: () => context.go('/cash-book/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Entry'),
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
                  ],
                  rows: txns.map((tw) {
                    final isDebit = tw.transaction.type.isDebit;
                    final amount = tw.transaction.amount;
                    return DataRow(cells: [
                      DataCell(Text(DateFormatter.format(tw.transaction.date))),
                      DataCell(Text(tw.project.name,
                          overflow: TextOverflow.ellipsis)),
                      DataCell(
                        _TypeBadge(type: tw.transaction.type),
                      ),
                      DataCell(Text(tw.transaction.narration ?? '—')),
                      DataCell(Text(tw.transaction.referenceNo ?? '—')),
                      DataCell(Text(
                        isDebit ? CurrencyFormatter.format(amount) : '—',
                        style: isDebit
                            ? TextStyle(color: Colors.red.shade700)
                            : null,
                      )),
                      DataCell(Text(
                        !isDebit ? CurrencyFormatter.format(amount) : '—',
                        style: !isDebit
                            ? TextStyle(color: Colors.green.shade700)
                            : null,
                      )),
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
