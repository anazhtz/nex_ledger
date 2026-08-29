import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nex_ledger/core/constants/enums.dart';
import 'package:nex_ledger/core/database/app_database.dart';
import 'package:nex_ledger/core/utils/currency_formatter.dart';
import 'package:nex_ledger/core/utils/date_formatter.dart';
import 'package:nex_ledger/features/client_billing/providers/client_billing_providers.dart';
import 'package:nex_ledger/features/projects/providers/project_providers.dart';
import 'package:nex_ledger/shared/widgets/data_table_card.dart';

class ClientBillingHubScreen extends ConsumerStatefulWidget {
  const ClientBillingHubScreen({super.key});

  @override
  ConsumerState<ClientBillingHubScreen> createState() =>
      _ClientBillingHubScreenState();
}

class _ClientBillingHubScreenState extends ConsumerState<ClientBillingHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metricsAsync = ref.watch(clientPortfolioMetricsProvider);
    final projectsAsync = ref.watch(projectListProvider);
    final filterProject = ref.watch(clientBillingProjectFilterProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header & Action Buttons ──────────────────────────────────────
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
                        'Client RA Billing & Contract Revenue',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Progressive client invoices (RA bills), mobilization advance recovery & 5% retention holdbacks',
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
                    OutlinedButton.icon(
                      onPressed: () => _showContractSetupDialog(context),
                      icon: Icon(Icons.description_outlined, size: 16.sp),
                      label: const Text('Contract Setup'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => context.push('/client-billing/receipt/new'),
                      icon: Icon(Icons.payments_outlined, size: 16.sp),
                      label: const Text('Record Client Receipt'),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.push('/client-billing/ra-bills/new'),
                      icon: Icon(Icons.add_chart_rounded, size: 16.sp),
                      label: const Text('Raise Client RA Bill'),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ─── Portfolio Financial KPI Metrics Row ──────────────────────────
            metricsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (m) => _buildKpiRow(m),
            ),
            SizedBox(height: 16.h),

            // ─── Filter & Tabs Bar ────────────────────────────────────────────
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
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      indicatorColor: const Color(0xFF4F46E5),
                      labelColor: const Color(0xFF4F46E5),
                      unselectedLabelColor: const Color(0xFF64748B),
                      labelStyle: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w500),
                      tabs: const [
                        Tab(
                            icon: Icon(Icons.analytics_outlined, size: 16),
                            text: 'Contract Progress & Receivables'),
                        Tab(
                            icon: Icon(Icons.receipt_long_outlined, size: 16),
                            text: 'Client RA Bills History'),
                        Tab(
                            icon: Icon(Icons.savings_outlined, size: 16),
                            text: 'Collections & Receipts'),
                      ],
                    ),
                    projectsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (projects) => SizedBox(
                        width: 250.w,
                        child: DropdownButtonFormField<int?>(
                          value: filterProject,
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
                              .read(clientBillingProjectFilterProvider.notifier)
                              .state = v,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // ─── Tab Views ────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProjectProgressTab(context),
                  _buildRaBillsTab(context),
                  _buildReceiptsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── KPI Row Widget ─────────────────────────────────────────────────────────

  Widget _buildKpiRow(ClientPortfolioMetrics m) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 48.w) / 5 > 190.w
            ? (constraints.maxWidth - 48.w) / 5
            : 190.w;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Total Contract Value',
                    value: CurrencyFormatter.format(m.totalContractValue),
                    subtitle: '${m.activeProjectsCount} Client Contracts',
                    icon: Icons.business_center_rounded,
                    color: const Color(0xFF3B82F6),
                    bgColor: const Color(0xFFEFF6FF),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Certified Gross Invoiced',
                    value: CurrencyFormatter.format(m.totalGrossBilled),
                    subtitle: 'Progressive RA bills',
                    icon: Icons.receipt_long_rounded,
                    color: const Color(0xFF10B981),
                    bgColor: const Color(0xFFECFDF5),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Total Payments Collected',
                    value: CurrencyFormatter.format(m.totalCollected),
                    subtitle: 'Bank / Cheque receipts',
                    icon: Icons.savings_rounded,
                    color: const Color(0xFF6366F1),
                    bgColor: const Color(0xFFEEF2FF),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Retention Held by Client',
                    value: CurrencyFormatter.format(m.totalRetentionHeldByClient),
                    subtitle: '5% Defect liability asset',
                    icon: Icons.lock_clock_rounded,
                    color: const Color(0xFFF59E0B),
                    bgColor: const Color(0xFFFFFBEB),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: cardWidth,
                  child: _buildKpiCard(
                    title: 'Outstanding Receivables',
                    value: CurrencyFormatter.format(m.totalPendingReceivables),
                    subtitle: 'Pending from clients',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEF2F2),
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

  // ─── Tab 1: Project Contract Progress ───────────────────────────────────────

  Widget _buildProjectProgressTab(BuildContext context) {
    final summariesAsync = ref.watch(projectRevenueSummariesProvider);

    return summariesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (summaries) {
        return DataTableCard(
          emptyMessage:
              'No active client contracts. Click "Contract Setup" to configure client contract values for projects.',
          columns: const [
            DataColumn(label: Text('Project Code & Name')),
            DataColumn(label: Text('Client Name')),
            DataColumn(label: Text('Contract Sum (₹)')),
            DataColumn(label: Text('Gross Invoiced (₹)')),
            DataColumn(label: Text('Billing Progress')),
            DataColumn(label: Text('Collected (₹)')),
            DataColumn(label: Text('Pending Due (₹)')),
            DataColumn(label: Text('Retention Held (₹)')),
            DataColumn(label: Text('Unbilled Scope (₹)')),
            DataColumn(label: Text('Actions')),
          ],
          rows: summaries.map((s) {
            final p = s.project;
            final hasDue = s.clientOutstandingReceivables > 0.01;
            final pct = s.billingProgressPercentage;

            return DataRow(cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      p.code,
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              DataCell(Text(
                p.clientName ?? '—',
                style: const TextStyle(fontWeight: FontWeight.w500),
              )),
              DataCell(Text(
                CurrencyFormatter.format(s.clientContractValue),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              DataCell(Text(
                CurrencyFormatter.format(s.totalGrossBilled),
                style: const TextStyle(fontWeight: FontWeight.w600),
              )),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 60.w,
                      child: LinearProgressIndicator(
                        value: (pct / 100).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFFE2E8F0),
                        color: pct >= 100
                            ? const Color(0xFF10B981)
                            : const Color(0xFF4F46E5),
                        minHeight: 6.h,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: pct >= 100
                            ? const Color(0xFF10B981)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text(
                CurrencyFormatter.format(s.totalClientReceipts),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              )),
              DataCell(Text(
                CurrencyFormatter.format(s.clientOutstandingReceivables),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasDue ? Colors.red.shade700 : const Color(0xFF059669),
                ),
              )),
              DataCell(Text(
                CurrencyFormatter.format(s.clientRetentionHeldByClient),
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              )),
              DataCell(Text(
                CurrencyFormatter.format(s.unbilledContractValue),
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B)),
              )),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_chart_rounded, size: 17.sp),
                      tooltip: 'Raise RA Bill',
                      color: const Color(0xFF4F46E5),
                      onPressed: () => context.push(
                        '/client-billing/ra-bills/new?projectId=${p.id}',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.payments_outlined, size: 17.sp),
                      tooltip: 'Record Client Receipt',
                      color: const Color(0xFF059669),
                      onPressed: () => context.push(
                        '/client-billing/receipt/new?projectId=${p.id}',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_note_rounded, size: 18.sp),
                      tooltip: 'Contract Setup',
                      onPressed: () =>
                          _showEditProjectContractDialog(context, p),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        );
      },
    );
  }

  // ─── Tab 2: Client RA Bills History ─────────────────────────────────────────

  Widget _buildRaBillsTab(BuildContext context) {
    final billsAsync = ref.watch(clientRaBillsListProvider(null));

    return billsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bills) {
        return DataTableCard(
          emptyMessage: 'No client RA bills raised yet.',
          columns: const [
            DataColumn(label: Text('RA Bill #')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Project & Client')),
            DataColumn(label: Text('Work / Stage Description')),
            DataColumn(label: Text('Gross Bill (₹)')),
            DataColumn(label: Text('Retention (5%)')),
            DataColumn(label: Text('Adv Deduct (₹)')),
            DataColumn(label: Text('TDS (₹)')),
            DataColumn(label: Text('Net Certified (₹)')),
            DataColumn(label: Text('Actions')),
          ],
          rows: bills.map((bDetail) {
            final b = bDetail.bill;
            return DataRow(cells: [
              DataCell(Text(
                b.billNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F46E5),
                ),
              )),
              DataCell(Text(DateFormatter.format(b.billDate))),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bDetail.project.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      bDetail.project.clientName ?? 'Client',
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              DataCell(Text(
                b.stageOrDescription,
                overflow: TextOverflow.ellipsis,
              )),
              DataCell(Text(
                CurrencyFormatter.format(b.grossAmount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
              DataCell(Text(
                '- ${CurrencyFormatter.format(b.retentionAmount)}',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              )),
              DataCell(Text(
                b.advanceDeduction > 0
                    ? '- ${CurrencyFormatter.format(b.advanceDeduction)}'
                    : '—',
                style: TextStyle(color: Colors.amber.shade900),
              )),
              DataCell(Text(
                b.taxOrTdsDeduction > 0
                    ? '- ${CurrencyFormatter.format(b.taxOrTdsDeduction)}'
                    : '—',
                style: const TextStyle(color: Color(0xFF64748B)),
              )),
              DataCell(Text(
                CurrencyFormatter.format(b.netCertifiedAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669),
                ),
              )),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.payments_outlined, size: 17.sp),
                      tooltip: 'Record Payment for this Bill',
                      color: const Color(0xFF059669),
                      onPressed: () => context.push(
                        '/client-billing/receipt/new?projectId=${b.projectId}&raBillId=${b.id}',
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, size: 17.sp),
                      tooltip: 'Delete Bill',
                      color: Colors.red.shade600,
                      onPressed: () => _deleteRaBill(context, b.id),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        );
      },
    );
  }

  // ─── Tab 3: Collections & Receipts ──────────────────────────────────────────

  Widget _buildReceiptsTab(BuildContext context) {
    final receiptsAsync = ref.watch(clientReceiptsListProvider(null));

    return receiptsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (receipts) {
        return DataTableCard(
          emptyMessage: 'No client receipts recorded yet.',
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Project & Client')),
            DataColumn(label: Text('Linked RA Bill')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Mode & Bank Account')),
            DataColumn(label: Text('Amount Received (₹)')),
            DataColumn(label: Text('Reference / UTR #')),
            DataColumn(label: Text('Actions')),
          ],
          rows: receipts.map((rDetail) {
            final r = rDetail.receipt;
            final isRetention = r.isRetentionRelease;
            final isAdv = r.isAdvance;

            return DataRow(cells: [
              DataCell(Text(DateFormatter.format(r.receiptDate))),
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      rDetail.project.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      rDetail.project.clientName ?? 'Client',
                      style: TextStyle(
                          fontSize: 11.sp, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              DataCell(Text(
                rDetail.clientRaBill?.billNumber ?? 'General Account Receipt',
                style: const TextStyle(fontWeight: FontWeight.w500),
              )),
              DataCell(
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isRetention
                        ? const Color(0xFFFFFBEB)
                        : (isAdv
                            ? const Color(0xFFFEF3C7)
                            : const Color(0xFFEFF6FF)),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    isRetention
                        ? 'Retention Release'
                        : (isAdv ? 'Mobilization Advance' : 'RA Bill Payment'),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: isRetention
                          ? const Color(0xFFB45309)
                          : (isAdv
                              ? const Color(0xFFD97706)
                              : const Color(0xFF2563EB)),
                    ),
                  ),
                ),
              ),
              DataCell(Text(
                '${r.paymentMode.displayName}${rDetail.bankAccount != null ? ' (${rDetail.bankAccount!.accountName})' : ''}',
              )),
              DataCell(Text(
                CurrencyFormatter.format(r.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669),
                ),
              )),
              DataCell(Text(r.referenceNo ?? (r.notes ?? '—'))),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 17.sp),
                  tooltip: 'Delete Receipt',
                  color: Colors.red.shade600,
                  onPressed: () => _deleteReceipt(context, r.id),
                ),
              ),
            ]);
          }).toList(),
        );
      },
    );
  }

  // ─── Modal Dialogs ──────────────────────────────────────────────────────────

  Future<void> _showContractSetupDialog(BuildContext context) async {
    final projects = await ref.read(projectListProvider.future);
    if (!context.mounted) return;

    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a project first.')),
      );
      return;
    }

    await _showEditProjectContractDialog(context, projects.first);
  }

  Future<void> _showEditProjectContractDialog(
      BuildContext context, Project project) async {
    final clientNameCtrl =
        TextEditingController(text: project.clientName ?? '');
    final contractValCtrl = TextEditingController(
      text: project.clientContractValue > 0
          ? (project.clientContractValue % 1 == 0
              ? project.clientContractValue.toInt().toString()
              : project.clientContractValue.toString())
          : (project.budget != null ? project.budget!.toInt().toString() : ''),
    );
    final retentionPctCtrl = TextEditingController(
      text: project.clientRetentionPercentage.toString(),
    );
    final contactCtrl =
        TextEditingController(text: project.clientContact ?? '');
    final addressCtrl =
        TextEditingController(text: project.clientAddress ?? '');
    final gstCtrl = TextEditingController(text: project.clientGstOrPan ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Client Contract Setup: ${project.name}'),
        content: SizedBox(
          width: 500.w,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: clientNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Client / Developer Name *',
                      hintText: 'e.g. Skyline Infra Ltd / Mr. Rajesh Kumar',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: contractValCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Agreed Contract Sum (₹) *',
                            hintText: '25000000',
                            prefixText: '₹ ',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Required';
                            final num =
                                double.tryParse(v.replaceAll(',', '').trim());
                            if (num == null || num <= 0) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: retentionPctCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Retention %',
                            suffixText: '%',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: contactCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Client Phone / Email',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Site / Billing Address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: gstCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Client GST / PAN No',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final contractVal = double.parse(
                  contractValCtrl.text.replaceAll(',', '').trim());
              final retentionPct = double.tryParse(
                      retentionPctCtrl.text.replaceAll(',', '').trim()) ??
                  5.0;

              await ref
                  .read(clientBillingRepositoryProvider)
                  .updateProjectClientContract(
                    projectId: project.id,
                    clientName: clientNameCtrl.text.trim(),
                    clientContractValue: contractVal,
                    clientRetentionPercentage: retentionPct,
                    clientContact: contactCtrl.text.isNotEmpty
                        ? contactCtrl.text.trim()
                        : null,
                    clientAddress: addressCtrl.text.isNotEmpty
                        ? addressCtrl.text.trim()
                        : null,
                    clientGstOrPan:
                        gstCtrl.text.isNotEmpty ? gstCtrl.text.trim() : null,
                  );

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Contract'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRaBill(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Client RA Bill?'),
        content: const Text(
            'Are you sure you want to delete this progressive invoice? This will remove the revenue entry from P&L.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(clientBillingRepositoryProvider).deleteClientRaBill(id);
    }
  }

  Future<void> _deleteReceipt(BuildContext context, int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Client Receipt?'),
        content: const Text(
            'Are you sure you want to delete this client collection? This will update the bank balance and receivables.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(clientBillingRepositoryProvider).deleteClientReceipt(id);
    }
  }
}
