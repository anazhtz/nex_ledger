import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/daos/project_budget_dao.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/features/budgets/presentation/widgets/set_project_budget_dialog.dart';
import 'package:nex_ledger/features/budgets/providers/project_budget_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class ProjectBudgetVarianceHubScreen extends ConsumerStatefulWidget {
  const ProjectBudgetVarianceHubScreen({super.key});

  @override
  ConsumerState<ProjectBudgetVarianceHubScreen> createState() =>
      _ProjectBudgetVarianceHubScreenState();
}

class _ProjectBudgetVarianceHubScreenState
    extends ConsumerState<ProjectBudgetVarianceHubScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportBudgetReportToCsv(List<ProjectBudgetSummary> summaries) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln(
          'Project Code,Project Name,Client Name,Cost Head,Allocated Budget (INR),Actual Spent (INR),Variance (INR),Utilization %,Status');

      for (final s in summaries) {
        for (final head in s.costHeads) {
          buffer.writeln(
              '"${s.project.code}","${s.project.name}","${s.project.clientName ?? 'Direct Client'}","${head.costHead.displayName}",${head.allocatedBudget},${head.actualSpent},${head.variance},${head.utilizationPercentage.toStringAsFixed(2)}%,"${head.status.displayName}"');
        }
        buffer.writeln(
            '"${s.project.code}","${s.project.name}","${s.project.clientName ?? 'Direct Client'}","OVERALL TOTAL",${s.totalAllocatedBudget},${s.totalActualCost},${s.netVariance},${s.overallUtilizationPercentage.toStringAsFixed(2)}%,"${s.overallStatus.displayName}"');
      }

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/budget_variance_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(buffer.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Budget Variance CSV exported to: $path'),
            backgroundColor: const Color(0xFF059669),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(budgetPortfolioMetricsProvider);
    final filteredSummariesAsync = ref.watch(filteredProjectBudgetSummariesProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final selectedFilterProject = ref.watch(projectBudgetFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header & Action Bar ─────────────────────────────────────────
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16.w,
              runSpacing: 12.h,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 550.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project Budget vs Actual Variance',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Cost overrun prevention, cost-head variance tracking & real-time threshold warnings',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    filteredSummariesAsync.when(
                      data: (summaries) => OutlinedButton.icon(
                        onPressed: () => _exportBudgetReportToCsv(summaries),
                        icon: Icon(Icons.file_download_outlined, size: 16.sp),
                        label: const Text('Export CSV Report'),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showProjectSelectorForBudgetDialog(context),
                      icon: Icon(Icons.tune_rounded, size: 16.sp),
                      label: const Text('Set / Edit Project Budgets'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // ─── KPI Portfolio Metrics Row ───────────────────────────────────
            metricsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
              data: (m) => _buildKpiRow(m),
            ),
            SizedBox(height: 14.h),

            // ─── Filter & Search Bar ─────────────────────────────────────────
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12.w,
                  runSpacing: 8.h,
                  children: [
                    SizedBox(
                      width: 300.w,
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search by project name, code, client...',
                          prefixIcon: Icon(Icons.search, size: 18.sp),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 10.h),
                        ),
                        onChanged: (v) => ref
                            .read(projectBudgetSearchQueryProvider.notifier)
                            .state = v,
                      ),
                    ),
                    projectsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (projects) => SizedBox(
                        width: 260.w,
                        child: DropdownButtonFormField<int?>(
                          value: selectedFilterProject,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Filter by Project',
                            prefixIcon: Icon(Icons.folder_outlined, size: 18.sp),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Projects',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            ...projects.map(
                              (p) => DropdownMenuItem(
                                value: p.id,
                                child: Text('${p.code} — ${p.name}',
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ),
                          ],
                          onChanged: (v) => ref
                              .read(projectBudgetFilterProvider.notifier)
                              .state = v,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // ─── Budget Variance Matrix List ─────────────────────────────────
            Expanded(
              child: filteredSummariesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading budgets: $e')),
                data: (summaries) {
                  if (summaries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined,
                              size: 48.sp, color: const Color(0xFF94A3B8)),
                          SizedBox(height: 12.h),
                          Text(
                            'No project budget records match your filter.',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: summaries.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final summary = summaries[index];
                      return _buildProjectBudgetCard(context, summary);
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

  // ─── KPI Row Widget ─────────────────────────────────────────────────────────

  Widget _buildKpiRow(BudgetPortfolioMetrics m) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 36.w) / 4 > 220.w
            ? (constraints.maxWidth - 36.w) / 4
            : 220.w;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Total Allocated Budgets',
                    value: CurrencyFormatter.format(m.totalPortfolioBudget),
                    subtitle: '${m.budgetedProjectsCount} of ${m.totalProjectsCount} projects budgeted',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFFEFF6FF),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Actual Costs Incurred',
                    value: CurrencyFormatter.format(m.totalPortfolioActualSpent),
                    subtitle: '${m.portfolioUtilizationPercentage.toStringAsFixed(1)}% total utilized',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF6366F1),
                    bgColor: const Color(0xFFEEF2FF),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Net Budget Variance',
                    value: CurrencyFormatter.format(m.netPortfolioVariance),
                    subtitle: m.netPortfolioVariance >= 0 ? 'Portfolio Surplus' : 'Portfolio Deficit (Overrun)',
                    icon: m.netPortfolioVariance >= 0
                        ? Icons.savings_rounded
                        : Icons.warning_amber_rounded,
                    color: m.netPortfolioVariance >= 0
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    bgColor: m.netPortfolioVariance >= 0
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF2F2),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Budget Risk Status',
                    value: '${m.overBudgetProjectsCount} Overrun | ${m.warningProjectsCount} Caution',
                    subtitle: '${m.healthyProjectsCount} projects healthy & on track',
                    icon: m.overBudgetProjectsCount > 0
                        ? Icons.report_problem_rounded
                        : Icons.check_circle_rounded,
                    color: m.overBudgetProjectsCount > 0
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                    bgColor: m.overBudgetProjectsCount > 0
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFECFDF5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Individual Project Budget Card ────────────────────────────────────────

  Widget _buildProjectBudgetCard(BuildContext context, ProjectBudgetSummary s) {
    final p = s.project;
    final isOverBudget = s.isOverBudget;
    final isWarning = s.isWarning && !isOverBudget;
    final hasBudget = s.totalAllocatedBudget > 0;

    Color statusColor;
    Color statusBgColor;
    String statusLabel;
    IconData statusIcon;

    if (!hasBudget) {
      statusColor = const Color(0xFF64748B);
      statusBgColor = const Color(0xFFF1F5F9);
      statusLabel = 'Not Budgeted';
      statusIcon = Icons.help_outline;
    } else if (isOverBudget) {
      statusColor = const Color(0xFFDC2626);
      statusBgColor = const Color(0xFFFEF2F2);
      statusLabel = 'OVER BUDGET (${s.overBudgetCategoriesCount} heads overrun)';
      statusIcon = Icons.warning_amber_rounded;
    } else if (isWarning) {
      statusColor = const Color(0xFFD97706);
      statusBgColor = const Color(0xFFFFFBEB);
      statusLabel = 'CAUTION (${s.warningCategoriesCount} heads nearing limit)';
      statusIcon = Icons.notifications_active_outlined;
    } else {
      statusColor = const Color(0xFF059669);
      statusBgColor = const Color(0xFFECFDF5);
      statusLabel = 'ON TRACK';
      statusIcon = Icons.check_circle_outline;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(
          color: isOverBudget
              ? const Color(0xFFFCA5A5)
              : isWarning
                  ? const Color(0xFFFDE68A)
                  : const Color(0xFFE2E8F0),
          width: isOverBudget ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Project Title Bar ───────────────────────────────────────────
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        p.code,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                    Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '• Client: ${p.clientName ?? 'Direct Client'}',
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8.w,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14.sp, color: statusColor),
                          SizedBox(width: 4.w),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _openBudgetDialog(context, p.id),
                      icon: Icon(Icons.edit_outlined, size: 14.sp),
                      label: Text(hasBudget ? 'Edit Budgets' : '+ Set Budget'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        textStyle: TextStyle(fontSize: 11.sp),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.go('/reports/project-pnl'),
                      tooltip: 'View Project P&L',
                      icon: Icon(Icons.analytics_outlined, size: 18.sp, color: const Color(0xFF4F46E5)),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // ─── Financial Progress Overview ─────────────────────────────────
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 16.w,
                    runSpacing: 8.h,
                    children: [
                      _buildSummaryMetric(
                        'Total Allocated Budget',
                        CurrencyFormatter.format(s.totalAllocatedBudget),
                        const Color(0xFF334155),
                      ),
                      _buildSummaryMetric(
                        'Actual Cost Spent',
                        CurrencyFormatter.format(s.totalActualCost),
                        isOverBudget ? const Color(0xFFDC2626) : const Color(0xFF1E293B),
                      ),
                      _buildSummaryMetric(
                        'Net Variance',
                        CurrencyFormatter.format(s.netVariance),
                        s.netVariance >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                      _buildSummaryMetric(
                        'Budget Utilization',
                        hasBudget ? '${s.overallUtilizationPercentage.toStringAsFixed(1)}%' : 'N/A',
                        statusColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: hasBudget ? (s.overallUtilizationPercentage / 100).clamp(0.0, 1.0) : 0.0,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        s.overallUtilizationPercentage >= 100.0
                            ? const Color(0xFFDC2626)
                            : s.overallUtilizationPercentage >= 85.0
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981),
                      ),
                      minHeight: 6.h,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ─── Cost Heads Breakdown Table ──────────────────────────────────
            DataTableCard(
              minWidth: 800.w,
              showBorder: false,
              columns: const [
                DataColumn(label: Text('Cost Head / Category')),
                DataColumn(label: Text('Allocated Budget (₹)')),
                DataColumn(label: Text('Actual Cost (₹)')),
                DataColumn(label: Text('Variance (₹)')),
                DataColumn(label: Text('Utilization Progress')),
                DataColumn(label: Text('Status')),
              ],
              rows: s.costHeads.map((head) {
                final headUtil = head.utilizationPercentage;
                final headOver = head.isOverBudget;
                final headWarn = head.isWarning;

                Color hColor = const Color(0xFF059669);
                if (headOver) {
                  hColor = const Color(0xFFDC2626);
                } else if (headWarn) {
                  hColor = const Color(0xFFD97706);
                } else if (!head.isConfigured) {
                  hColor = const Color(0xFF94A3B8);
                }

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getHeadIcon(head.costHead), size: 16.sp, color: const Color(0xFF64748B)),
                          SizedBox(width: 8.w),
                          Text(head.costHead.displayName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
                        ],
                      ),
                    ),
                    DataCell(Text(
                      head.isConfigured ? CurrencyFormatter.format(head.allocatedBudget) : '— (Not set)',
                      style: TextStyle(fontSize: 12.sp, color: const Color(0xFF334155)),
                    )),
                    DataCell(Text(
                      CurrencyFormatter.format(head.actualSpent),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: headOver ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                      ),
                    )),
                    DataCell(Text(
                      head.isConfigured ? CurrencyFormatter.format(head.variance) : '—',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: head.variance >= 0 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      ),
                    )),
                    DataCell(
                      SizedBox(
                        width: 130.w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              head.isConfigured ? '${headUtil.toStringAsFixed(1)}%' : 'N/A',
                              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: hColor),
                            ),
                            SizedBox(height: 2.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3.r),
                              child: LinearProgressIndicator(
                                value: head.isConfigured ? (headUtil / 100).clamp(0.0, 1.0) : 0.0,
                                backgroundColor: const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(hColor),
                                minHeight: 4.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: hColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          head.isConfigured ? head.status.displayName : 'Unbudgeted',
                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: hColor),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF64748B))),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  IconData _getHeadIcon(BudgetCostHead head) {
    return switch (head) {
      BudgetCostHead.materials => Icons.inventory_2_outlined,
      BudgetCostHead.labour => Icons.groups_outlined,
      BudgetCostHead.subcontract => Icons.engineering_outlined,
      BudgetCostHead.equipmentOverhead => Icons.local_shipping_outlined,
      BudgetCostHead.overallTotal => Icons.account_balance_wallet_outlined,
    };
  }

  void _openBudgetDialog(BuildContext context, int projectId) {
    showDialog(
      context: context,
      builder: (_) => SetProjectBudgetDialog(projectId: projectId),
    );
  }

  void _showProjectSelectorForBudgetDialog(BuildContext context) async {
    final projects = await ref.read(projectListProvider.future);
    if (!mounted) return;

    final validProjects = projects.where((p) => p.type == ProjectType.project).toList();
    if (validProjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active projects available to set budgets.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Project to Set Budget'),
        children: validProjects
            .map((p) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _openBudgetDialog(context, p.id);
                  },
                  child: Text('${p.code} — ${p.name} (${p.clientName ?? 'Direct Client'})'),
                ))
            .toList(),
      ),
    );
  }
}
