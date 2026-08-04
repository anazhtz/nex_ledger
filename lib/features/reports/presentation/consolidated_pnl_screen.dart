import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/reports/data/report_repository.dart';
import 'package:nex_ledger/features/reports/providers/report_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class ConsolidatedPnlScreen extends ConsumerWidget {
  const ConsolidatedPnlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pnlAsync = ref.watch(consolidatedPnlProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consolidated P&L',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'All projects + Admin Overhead combined',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: pnlAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (pnls) {
                  if (pnls.isEmpty) {
                    return Center(
                      child: Text(
                        'No projects found. Create projects to see consolidated P&L.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    );
                  }

                  // Compute totals
                  double totalIncome = 0;
                  double totalExpenses = 0;
                  double totalPurchases = 0;
                  double totalLabour = 0;
                  double totalDepositsHeld = 0;
                  for (final p in pnls) {
                    totalIncome += p.income;
                    totalExpenses += p.expenses;
                    totalPurchases += p.purchases;
                    totalLabour += p.labourCosts;
                    totalDepositsHeld += p.depositsHeld;
                  }
                  final totalNet =
                      totalIncome - totalExpenses - totalPurchases - totalLabour;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company totals card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Company Totals',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _TotalChip(
                                      'Income',
                                      totalIncome,
                                      Colors.green.shade700),
                                  const SizedBox(width: 16),
                                  _TotalChip(
                                      'Expenses',
                                      totalExpenses,
                                      Colors.red.shade700),
                                  const SizedBox(width: 16),
                                  _TotalChip(
                                      'Purchases',
                                      totalPurchases,
                                      Colors.orange.shade700),
                                  const SizedBox(width: 16),
                                  _TotalChip(
                                      'Labour',
                                      totalLabour,
                                      Colors.purple.shade700),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: totalNet >= 0
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                          color: totalNet >= 0
                                              ? Colors.green.shade200
                                              : Colors.red.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Net P&L',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: totalNet >= 0
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700)),
                                        Text(
                                          CurrencyFormatter.format(totalNet),
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: totalNet >= 0
                                                ? Colors.green.shade700
                                                : Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Per-project table
                      Expanded(
                        child: DataTableCard(
                          title: 'Per-Project Breakdown',
                          columns: const [
                            DataColumn(label: Text('Code')),
                            DataColumn(label: Text('Project')),
                            DataColumn(label: Text('Type')),
                            DataColumn(
                                label: Text('Income'), numeric: true),
                            DataColumn(
                                label: Text('Expenses'), numeric: true),
                            DataColumn(
                                label: Text('Purchases'), numeric: true),
                            DataColumn(
                                label: Text('Labour'), numeric: true),
                            DataColumn(
                                label: Text('Net P&L'), numeric: true),
                            DataColumn(
                                label: Text('Deposit Held'),
                                numeric: true),
                          ],
                          rows: [
                            ...pnls.map((pnl) {
                              final isPositive = pnl.netPnl >= 0;
                              return DataRow(cells: [
                                DataCell(Text(pnl.project.code,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600))),
                                DataCell(Text(pnl.project.name,
                                    overflow: TextOverflow.ellipsis)),
                                DataCell(
                                    Text(pnl.project.type.displayName)),
                                DataCell(Text(
                                    CurrencyFormatter.format(pnl.income))),
                                DataCell(Text(CurrencyFormatter.format(
                                    pnl.expenses))),
                                DataCell(Text(CurrencyFormatter.format(
                                    pnl.purchases))),
                                DataCell(Text(CurrencyFormatter.format(
                                    pnl.labourCosts))),
                                DataCell(Text(
                                  CurrencyFormatter.format(pnl.netPnl),
                                  style: TextStyle(
                                    color: isPositive
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )),
                                DataCell(Text(CurrencyFormatter.format(
                                    pnl.depositsHeld))),
                              ]);
                            }),
                            // Totals row
                            DataRow(
                              color: WidgetStateProperty.all(
                                theme.colorScheme.surfaceContainerLow,
                              ),
                              cells: [
                                const DataCell(Text('')),
                                const DataCell(
                                  Text('TOTAL',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ),
                                const DataCell(Text('')),
                                DataCell(Text(
                                  CurrencyFormatter.format(totalIncome),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                )),
                                DataCell(Text(
                                  CurrencyFormatter.format(totalExpenses),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                )),
                                DataCell(Text(
                                  CurrencyFormatter.format(totalPurchases),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                )),
                                DataCell(Text(
                                  CurrencyFormatter.format(totalLabour),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                )),
                                DataCell(Text(
                                  CurrencyFormatter.format(totalNet),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: totalNet >= 0
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                )),
                                DataCell(Text(
                                  CurrencyFormatter.format(
                                      totalDepositsHeld),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _TotalChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _TotalChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: color)),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.format(value),
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
