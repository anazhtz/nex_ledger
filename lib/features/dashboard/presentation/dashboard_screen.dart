import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/dashboard/providers/dashboard_provider.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';
import 'package:nex_ledger/shared/widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (summary) => SingleChildScrollView(
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
                        'Dashboard',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Company Overview',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stat cards row (Responsive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobileOrSmallLaptop = constraints.maxWidth < 800;

                  final stat1 = StatCard(
                    label: 'Cash Balance',
                    value: CurrencyFormatter.format(summary.cashBalance),
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: summary.cashBalance >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    valueColor: summary.cashBalance >= 0
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  );

                  final stat2 = StatCard(
                    label: 'Deposits Held',
                    value: CurrencyFormatter.format(summary.totalDepositsHeld),
                    icon: Icons.savings_outlined,
                    iconColor: Colors.orange.shade700,
                    subtitle: 'Liability — not income',
                  );

                  final stat3 = StatCard(
                    label: 'Active Projects',
                    value: summary.activeProjects.length.toString(),
                    icon: Icons.folder_open_outlined,
                  );

                  if (isMobileOrSmallLaptop) {
                    return Column(
                      children: [
                        stat1,
                        const SizedBox(height: 12),
                        stat2,
                        const SizedBox(height: 12),
                        stat3,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: stat1),
                      const SizedBox(width: 16),
                      Expanded(child: stat2),
                      const SizedBox(width: 16),
                      Expanded(child: stat3),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Project P&L table
              DataTableCard(
                title: 'Active Projects — P&L Snapshot',
                action: TextButton.icon(
                  onPressed: () => context.go('/projects'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                ),
                emptyMessage: 'No active projects. Create one to get started.',
                columns: const [
                  DataColumn(label: Text('Code')),
                  DataColumn(label: Text('Project')),
                  DataColumn(label: Text('Income'), numeric: true),
                  DataColumn(label: Text('Costs'), numeric: true),
                  DataColumn(label: Text('Net P&L'), numeric: true),
                  DataColumn(label: Text('Deposit Held'), numeric: true),
                ],
                rows: summary.projectPnls.map((pnl) {
                  final netPositive = pnl.netPnl >= 0;
                  final netColor = netPositive
                      ? Colors.green.shade700
                      : Colors.red.shade700;
                  final totalCosts =
                      pnl.expenses + pnl.purchases + pnl.labourCosts;
                  return DataRow(cells: [
                    DataCell(Text(
                      pnl.project.code,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(pnl.project.name),
                          if (pnl.project.clientName != null)
                            Text(
                              pnl.project.clientName!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    DataCell(Text(CurrencyFormatter.format(pnl.income))),
                    DataCell(Text(CurrencyFormatter.format(totalCosts))),
                    DataCell(
                      Text(
                        CurrencyFormatter.format(pnl.netPnl),
                        style: TextStyle(
                          color: netColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(CurrencyFormatter.format(pnl.depositsHeld)),
                    ),
                  ]);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
