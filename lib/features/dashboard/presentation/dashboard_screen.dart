import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          padding: EdgeInsets.all(24.r),
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
                        'Company Overview & Project Breakdowns',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Stat cards row (Responsive & Interactive)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;

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
                    onTap: () => _showCashBalanceBreakdown(context, summary),
                    tooltip: 'Click to view Project-wise Cash Balance Breakdown',
                  );

                  final stat2 = StatCard(
                    label: 'Deposits Held',
                    value: CurrencyFormatter.format(summary.totalDepositsHeld),
                    icon: Icons.savings_outlined,
                    iconColor: Colors.orange.shade700,
                    subtitle: 'Liability — not income',
                    onTap: () => _showDepositsHeldBreakdown(context, summary),
                    tooltip: 'Click to view Project-wise Security Deposits Breakdown',
                  );

                  final stat3 = StatCard(
                    label: 'Active Projects',
                    value: summary.activeProjects.length.toString(),
                    icon: Icons.folder_open_outlined,
                    onTap: () => context.go('/projects'),
                    tooltip: 'Click to manage Projects',
                  );

                  if (isNarrow) {
                    return Column(
                      children: [
                        stat1,
                        SizedBox(height: 12.h),
                        stat2,
                        SizedBox(height: 12.h),
                        stat3,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: stat1),
                      SizedBox(width: 16.w),
                      Expanded(child: stat2),
                      SizedBox(width: 16.w),
                      Expanded(child: stat3),
                    ],
                  );
                },
              ),
              SizedBox(height: 24.h),

              // Active Project P&L Snapshot Table
              DataTableCard(
                title: 'Active Projects — P&L & Cash Flow Snapshot',
                action: TextButton.icon(
                  onPressed: () => context.go('/projects'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All Projects'),
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
                                fontSize: 11.sp,
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

  /// Dialog showing Project-Wise Cash Balance Breakdown
  void _showCashBalanceBreakdown(BuildContext context, DashboardSummary summary) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF15803D), size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash Balance — Project Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Physical Cash Inflows & Outflows by Project',
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 680.w,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Physical Cash Balance:',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        CurrencyFormatter.format(summary.cashBalance),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: summary.cashBalance >= 0
                              ? const Color(0xFF15803D)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2.5),
                    1: FlexColumnWidth(1.5),
                    2: FlexColumnWidth(1.5),
                    3: FlexColumnWidth(1.5),
                  },
                  border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                      children: [
                        _buildTableHeader('Project'),
                        _buildTableHeader('Income Received'),
                        _buildTableHeader('Total Costs'),
                        _buildTableHeader('Deposits Held'),
                      ],
                    ),
                    ...summary.projectPnls.map((pnl) {
                      final costs = pnl.expenses + pnl.purchases + pnl.labourCosts;
                      return TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pnl.project.code,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(pnl.project.name,
                                    style: TextStyle(
                                        fontSize: 11.sp, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Text(CurrencyFormatter.format(pnl.income),
                                style: const TextStyle(color: Color(0xFF15803D))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Text(CurrencyFormatter.format(costs),
                                style: const TextStyle(color: Color(0xFFDC2626))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Text(CurrencyFormatter.format(pnl.depositsHeld),
                                style: const TextStyle(color: Color(0xFFD97706))),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/cash-book');
            },
            icon: const Icon(Icons.menu_book_rounded, size: 16),
            label: const Text('Open Cash Book Ledger'),
          ),
        ],
      ),
    );
  }

  /// Dialog showing Project-Wise Security Deposits Held Breakdown
  void _showDepositsHeldBreakdown(BuildContext context, DashboardSummary summary) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.savings_rounded,
                  color: const Color(0xFFD97706), size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deposits Held — Project Breakdown',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Security Deposit Liabilities Held by Project',
                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        content: SizedBox(
          width: 620.w,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Security Deposit Liabilities Held:',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        CurrencyFormatter.format(summary.totalDepositsHeld),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1.5),
                  },
                  border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                      children: [
                        _buildTableHeader('Project'),
                        _buildTableHeader('Deposit Balance Held'),
                        _buildTableHeader('Status'),
                      ],
                    ),
                    ...summary.projectPnls.map((pnl) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pnl.project.code,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(pnl.project.name,
                                    style: TextStyle(
                                        fontSize: 11.sp, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Text(
                              CurrencyFormatter.format(pnl.depositsHeld),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: pnl.depositsHeld > 0
                                    ? const Color(0xFFB45309)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: pnl.depositsHeld > 0
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                pnl.depositsHeld > 0 ? 'Liability Held' : 'Settled',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  color: pnl.depositsHeld > 0
                                      ? const Color(0xFFB45309)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/deposits');
            },
            icon: const Icon(Icons.account_balance_wallet_rounded, size: 16),
            label: const Text('Open Deposits Ledger'),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String label) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11.sp,
          color: const Color(0xFF334155),
        ),
      ),
    );
  }
}
