import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/excel_export_service.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/features/reports/providers/report_providers.dart';
import 'package:nex_ledger/shared/widgets/stat_card.dart';

class ProjectPnlScreen extends ConsumerWidget {
  const ProjectPnlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);
    final globalProject = ref.watch(selectedProjectIdProvider);
    final selectedProjectId = ref.watch(reportProjectFilterProvider) ?? globalProject;
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
                      'Project P&L Report',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Income − Expenses − Purchases − Labour = Net P&L',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const Spacer(),
                if (selectedProjectId != null)
                  FilledButton.icon(
                    onPressed: () async {
                      final pnl = await ref.read(projectPnlProvider(selectedProjectId).future);
                      final path = await ExcelExportService.exportPnlReport(
                        projectPnls: [pnl],
                        singleProjectTitle: pnl.project.name,
                      );
                      if (path != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('P&L Report exported to Excel: $path'),
                            backgroundColor: const Color(0xFF059669),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.table_chart_rounded, size: 18),
                    label: const Text('Export P&L (.xlsx)'),
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
                width: 340,
                child: DropdownButtonFormField<int?>(
                  value: selectedProjectId,
                  decoration:
                      const InputDecoration(labelText: 'Select Target Project'),
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text('— Select a project —')),
                    ...projects.map(
                      (p) => DropdownMenuItem(
                        value: p.id,
                        child: Text('${p.code}  —  ${p.name}',
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (v) => ref
                      .read(reportProjectFilterProvider.notifier)
                      .state = v,
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (selectedProjectId == null)
              Expanded(
                child: Center(
                  child: Text(
                    'Select a project to view its P&L.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              Consumer(
                builder: (context, ref, _) {
                  final pnlAsync =
                      ref.watch(projectPnlProvider(selectedProjectId));
                  return pnlAsync.when(
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (pnl) => Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Summary cards
                            // Summary cards (Responsive)
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isCompact = constraints.maxWidth < 1100;

                                final c1 = StatCard(
                                  label: 'Total Income',
                                  value: CurrencyFormatter.format(pnl.income),
                                  icon: Icons.add_circle_outline,
                                  iconColor: Colors.green.shade700,
                                  valueColor: Colors.green.shade700,
                                );
                                final c2 = StatCard(
                                  label: 'Expenses',
                                  value: CurrencyFormatter.format(pnl.expenses),
                                  icon: Icons.remove_circle_outline,
                                  iconColor: Colors.red.shade700,
                                  valueColor: Colors.red.shade700,
                                );
                                final c3 = StatCard(
                                  label: 'Purchases',
                                  value: CurrencyFormatter.format(pnl.purchases),
                                  icon: Icons.shopping_cart_outlined,
                                  iconColor: Colors.orange.shade700,
                                  valueColor: Colors.orange.shade700,
                                );
                                final c4 = StatCard(
                                  label: 'Labour',
                                  value: CurrencyFormatter.format(pnl.labourCosts),
                                  icon: Icons.people_outline,
                                  iconColor: Colors.purple.shade700,
                                  valueColor: Colors.purple.shade700,
                                );
                                final c5 = StatCard(
                                  label: 'Net P&L',
                                  value: CurrencyFormatter.format(pnl.netPnl),
                                  icon: pnl.netPnl >= 0
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  iconColor: pnl.netPnl >= 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  valueColor: pnl.netPnl >= 0
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                  subtitle:
                                      'Deposits held: ${CurrencyFormatter.format(pnl.depositsHeld)}',
                                );

                                if (isCompact) {
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: c1),
                                          const SizedBox(width: 12),
                                          Expanded(child: c2),
                                          const SizedBox(width: 12),
                                          Expanded(child: c3),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(child: c4),
                                          const SizedBox(width: 12),
                                          Expanded(child: c5),
                                        ],
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(child: c1),
                                    const SizedBox(width: 12),
                                    Expanded(child: c2),
                                    const SizedBox(width: 12),
                                    Expanded(child: c3),
                                    const SizedBox(width: 12),
                                    Expanded(child: c4),
                                    const SizedBox(width: 12),
                                    Expanded(child: c5),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Breakdown table
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'P&L Breakdown — ${pnl.project.name}',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 16),
                                    _BreakdownRow('Income (affects P&L)',
                                        pnl.income, Colors.green.shade700),
                                    _BreakdownRow('Expenses',
                                        -pnl.expenses, Colors.red.shade700),
                                    _BreakdownRow('Purchases',
                                        -pnl.purchases, Colors.orange.shade700),
                                    _BreakdownRow('Labour Payments',
                                        -pnl.labourCosts, Colors.purple.shade700),
                                    const Divider(height: 24),
                                    _BreakdownRow(
                                      'Net P&L',
                                      pnl.netPnl,
                                      pnl.netPnl >= 0
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                      bold: true,
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    _BreakdownRow(
                                      'Deposits Held (Liability — not in P&L)',
                                      pnl.depositsHeld,
                                      Colors.orange.shade700,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Expense Category Breakdown ──
                            Consumer(
                              builder: (context, ref, _) {
                                final breakdownAsync = ref.watch(
                                    expenseCategoryBreakdownProvider(selectedProjectId));
                                return breakdownAsync.when(
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, __) => const SizedBox.shrink(),
                                  data: (breakdown) {
                                    if (breakdown.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    return _ExpenseCategoryBreakdownCard(
                                        breakdown: breakdown);
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool bold;
  const _BreakdownRow(this.label, this.value, this.color,
      {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            CurrencyFormatter.format(value.abs()),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Collapsible card showing expense breakdown by group → sub-category.
class _ExpenseCategoryBreakdownCard extends StatefulWidget {
  final Map<String, Map<String, double>> breakdown;
  const _ExpenseCategoryBreakdownCard({required this.breakdown});

  @override
  State<_ExpenseCategoryBreakdownCard> createState() =>
      _ExpenseCategoryBreakdownCardState();
}

class _ExpenseCategoryBreakdownCardState
    extends State<_ExpenseCategoryBreakdownCard> {
  final _expanded = <String, bool>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final groups = widget.breakdown.keys.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label_rounded,
                    color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Expense Breakdown by Category',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...groups.map((group) {
              final subs = widget.breakdown[group]!;
              final groupTotal =
                  subs.values.fold(0.0, (a, b) => a + b);
              final isOpen = _expanded[group] ?? false;

              return Column(
                children: [
                  // Group row (tappable to expand/collapse)
                  InkWell(
                    onTap: () =>
                        setState(() => _expanded[group] = !isOpen),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isOpen
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 18,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            group,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            CurrencyFormatter.format(groupTotal),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Sub-category rows (visible when expanded)
                  if (isOpen)
                    ...subs.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(left: 28, bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.subdirectory_arrow_right_rounded,
                                size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 6),
                            Text(
                              entry.key,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF475569)),
                            ),
                            const Spacer(),
                            Text(
                              CurrencyFormatter.format(entry.value),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const Divider(height: 1),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
